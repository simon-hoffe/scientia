Attribute VB_Name = "SJH_Email_Export"
Option Explicit

'------------------------------------------------------------------------
Function BrowseForFolder(Optional OpenAt As Variant) As Variant
  Dim ShellApp As Object
  Set ShellApp = CreateObject("Shell.Application"). _
 BrowseForFolder(0, "Please choose a folder", 0, OpenAt)
 
 On Error Resume Next
    BrowseForFolder = ShellApp.self.Path
 On Error GoTo 0
 
 Set ShellApp = Nothing
    Select Case Mid(BrowseForFolder, 2, 1)
        Case Is = ":"
            If Left(BrowseForFolder, 1) = ":" Then GoTo Invalid
        Case Is = "\"
            If Not Left(BrowseForFolder, 1) = "\" Then GoTo Invalid
        Case Else
            GoTo Invalid
    End Select
 Exit Function
 
Invalid:
 BrowseForFolder = False
End Function

'------------------------------------------------------------------------
Public Sub ShowSenders()
    Dim oMail As Outlook.MailItem
    Dim objItem As Object
    Dim sPath As String
    Dim dtDate As Date
    Dim sName As String
    Dim enviro As String
    Dim sSender As String
    Dim sSubject As String
    Dim sDateTime As String
 
    enviro = CStr(Environ("USERPROFILE"))
    For Each objItem In ActiveExplorer.Selection
        If objItem.MessageClass = "IPM.Note" Then
            Set oMail = objItem
               
            GetDateString oMail, sDateTime
            GetSenderString oMail, sSender
            GetSubjectString oMail, sSubject
                        
            sName = "E " & sDateTime & " - " & sSender & " - " & sSubject & ".msg"
     
            sPath = enviro & "\Documents\Emails"
            
            MsgBox "Subject: " & oMail.Subject & vbCrLf & _
                "SentOn: " & oMail.SentOn & vbCrLf & _
                "SenderName: " & oMail.SenderName & vbCrLf & _
                "SenderAddress: " & oMail.SenderEmailAddress & vbCrLf & _
                "SenderEmailType: " & oMail.SenderEmailType & vbCrLf & _
                vbCrLf & _
                "Folder: " & sPath & vbCrLf & _
                "Filename: " & sName
               
        End If
    Next
  
End Sub
'------------------------------------------------------------------------
Public Sub SaveSelectedEmails()
    Dim oMail As Outlook.MailItem
    Dim objItem As Object
    Dim enviro As String
    Dim sPath As String
    Dim nMsgResult As Long
    
    Dim oRegEx As Object
    Set oRegEx = CreateObject("vbscript.regexp")

 
    enviro = CStr(Environ("USERPROFILE"))
    sPath = enviro & "\Documents\Emails\"
    
    If Not TestDirExist(sPath) Then
        nMsgResult = MsgBox( _
            Prompt:=sPath & " does not exist.", _
            Title:="Critical Error", _
            Buttons:=vbCritical + vbOKOnly)
        Exit Sub
    End If

    For Each objItem In ActiveExplorer.Selection
        If objItem.MessageClass = "IPM.Note" Then
            Set oMail = objItem
               
            SaveOneMessageAsMsg oMail
        End If
    Next
End Sub
 
'------------------------------------------------------------------------
Public Sub SaveOpenEmail()
    Dim oMail As Outlook.MailItem
    Dim objItem As Object
    Dim enviro As String
    Dim sPath As String
    Dim nMsgResult As Long
    
    Dim oRegEx As Object
    Set oRegEx = CreateObject("vbscript.regexp")

 
    enviro = CStr(Environ("USERPROFILE"))
    sPath = enviro & "\Documents\Emails\"
    
    If Not TestDirExist(sPath) Then
        nMsgResult = MsgBox( _
            Prompt:=sPath & " does not exist.", _
            Title:="Critical Error", _
            Buttons:=vbCritical + vbOKOnly)
        Exit Sub
    End If

    Set objItem = ActiveInspector.CurrentItem
    
    If objItem.MessageClass = "IPM.Note" Then
        Set oMail = objItem
           
        SaveOneMessageAsMsg oMail
    End If
End Sub
 
'------------------------------------------------------------------------
Public Sub SaveOneMessageAsMsg(oMail As Outlook.MailItem)
    Dim oAttachment As Outlook.Attachment
    Dim objItem As Object
    Dim sPath As String
    Dim dtDate As Date
    Dim sName As String
    Dim sAttName As String
    Dim sAttExt As String
    Dim sExt As String
    Dim enviro As String
    Dim sSender As String
    Dim sSubject As String
    Dim sDateTime As String
    Dim bSkipAttachment As Boolean
    Dim iSize As Long
    Dim iSizeLimit As Long
    Dim nMsgResult As Long
    Dim bSkipEmail As Boolean
    Dim vTemp As Variant
    Dim vPropNames() As Variant
    Dim bHiddenProp As Boolean
        
    Dim oRegEx As Object
    Set oRegEx = CreateObject("vbscript.regexp")

 
    enviro = CStr(Environ("USERPROFILE"))
    sPath = enviro & "\Documents\Emails\"
    
    If Not TestDirExist(sPath) Then
        nMsgResult = MsgBox( _
            Prompt:=sPath & " does not exist.", _
            Title:="Critical Error", _
            Buttons:=vbCritical + vbOKOnly)
        Exit Sub
    End If

    GetDateString oMail, sDateTime
    GetSenderString oMail, sSender
    GetSubjectString oMail, sSubject
                
    sName = "E " & sDateTime & " - " & sSender & " - " & sSubject

    
    sExt = ".msg"
    
    
'            MsgBox "Subject: " & oMail.Subject & vbCrLf & _
'                "SentOn: " & oMail.SentOn & vbCrLf & _
'                "SenderName: " & oMail.SenderName & vbCrLf & _
'                "SenderAddress: " & oMail.SenderEmailAddress & vbCrLf & _
'                "SenderEmailType: " & oMail.SenderEmailType & vbCrLf & _
'                vbCrLf & _
'                "Folder: " & sPath & vbCrLf & _
'                "Filename: " & sName & sExt
'
'            Debug.Print sPath & sName
    
    bSkipEmail = False
    If TestFileExist(sPath & sName & sExt) Then
        nMsgResult = MsgBox( _
            Prompt:="This file already exists:" & vbCrLf & vbCrLf & _
                    sName & sExt & vbCrLf & vbCrLf & _
                    "Overwrite?", _
            Title:="Warning: File Exists", _
            Buttons:=vbQuestion + vbYesNoCancel)
        
        If nMsgResult = vbCancel Then
            Exit Sub
        End If
        
        If nMsgResult = vbYes Then
            bSkipEmail = False
        Else
            bSkipEmail = True
        End If
    End If
    
    If Not bSkipEmail Then
        oMail.SaveAs sPath & sName & sExt, olMSG
        
        For Each oAttachment In oMail.Attachments
            bSkipAttachment = False
            oRegEx.Pattern = "^(.*?)(\.?[^.]*)$"
            sAttName = oRegEx.Replace(oAttachment.FileName, "$1")
            sAttExt = LCase(oRegEx.Replace(oAttachment.FileName, "$2"))
            iSize = oAttachment.Size
            
            
            ' Differentiate between attachments which are embedded inline, and explicit attachments
            Const PR_ATTACHMENT_HIDDEN = "http://schemas.microsoft.com/mapi/proptag/0x7FFE000B"
            
            vPropNames = Array(PR_ATTACHMENT_HIDDEN)
            vTemp = oAttachment.PropertyAccessor.GetProperties(vPropNames)
            
            bHiddenProp = Not IsError(vTemp(0))
            
            bSkipAttachment = False
            
            If bHiddenProp Then
                Select Case sAttExt
                    Case ".png"
                        bSkipAttachment = True
                    Case ".jpg"
                        bSkipAttachment = True
                    Case ".gif"
                        bSkipAttachment = True
                    Case Else
                        bSkipAttachment = False
                End Select
            End If
            
            If Not bSkipAttachment Then
                sName = "E " & sDateTime & " ___ " & sAttName
                
                MakeFileNameUnique sPath, sName, sAttExt
                
                oAttachment.SaveAsFile sPath & sName & sAttExt
            End If
        Next
    End If
End Sub
 
 
Private Sub ReplaceCharsForFileName(sName As String, _
    sChr As String _
)
    sName = Replace(sName, "'", sChr)
    sName = Replace(sName, "*", sChr)
    sName = Replace(sName, "/", sChr)
    sName = Replace(sName, "\", sChr)
    sName = Replace(sName, ":", sChr)
    sName = Replace(sName, "?", sChr)
    sName = Replace(sName, Chr(34), sChr)
    sName = Replace(sName, "<", sChr)
    sName = Replace(sName, ">", sChr)
    sName = Replace(sName, "|", sChr)
End Sub

Private Sub GetDateString(oMail As Outlook.MailItem, _
sDateString As String _
)
    Dim dtDate As Date
    
    dtDate = oMail.SentOn
    sDateString = Format(dtDate, "yyyymmdd", vbUseSystemDayOfWeek, vbUseSystem) & _
        Format(dtDate, "-hhnn", vbUseSystemDayOfWeek, vbUseSystem)
End Sub

Private Sub GetSenderString(oMail As Outlook.MailItem, _
sSenderString As String _
)
    Dim objRegEx As Object
    Dim oMatches As Object
    Dim oMatch As Object
    Dim sSenderName As String
    Dim sInitials As String
    Dim sSenderAddress As String
    Dim sDomain As String
    Dim sTemp As String
    
    Set objRegEx = CreateObject("vbscript.regexp")

'    MsgBox "Subject: " & oMail.Subject & vbCrLf & _
'        "SentOn: " & oMail.SentOn & vbCrLf & _
'        "SenderName: " & oMail.SenderName & vbCrLf & _
'        "SenderAddress: " & oMail.SenderEmailAddress & vbCrLf & _
'        "SenderEmailType: " & oMail.SenderEmailType

    ' Process the Sender Name
    
    With objRegEx
        .Global = True
        .MultiLine = True
        .IgnoreCase = True
    End With
    
    sSenderName = oMail.SenderName
    sSenderAddress = oMail.SenderEmailAddress
    
    ' Remove any email address add on in the sender name
    objRegEx.Pattern = "\S+@[^\.]\S*\.\w{2,}"
    If objRegEx.Test(sSenderName) Then
        sTemp = objRegEx.Replace(sSenderName, "")
    End If
    
    ' Trim any leading and/or trailing white space
    objRegEx.Pattern = "^\s*(.*?)\s*$"
    sTemp = objRegEx.Replace(sTemp, "$1")
    
    If Len(sTemp) = 0 Then
        objRegEx.Pattern = "(\S+)@[^\.]\S*\.\w{2,}"
        sTemp = objRegEx.Replace(sSenderName, "$1")
    End If
    
    sSenderName = sTemp
    
    ' Remove anything between brackets
    objRegEx.Pattern = "(\([^()]*\)|\[[^\[\]]*\]|\{[^{}]*\}|<[^<>]*>)"
    If objRegEx.Test(sSenderName) Then
        sSenderName = objRegEx.Replace(sSenderName, "")
    End If
    
    ' If the Sender name is in "Surname, Name" format, then switch it around
    objRegEx.Pattern = "^([^,]+),([^,]+)$"
    If objRegEx.Test(sSenderName) Then
        sSenderName = objRegEx.Replace(sSenderName, "$2 $1")
    End If
    
    objRegEx.Pattern = "\b\w"
    Set oMatches = objRegEx.Execute(sSenderName)
    
    sInitials = ""
    For Each oMatch In oMatches
        sInitials = sInitials & UCase(oMatch.Value)
    Next
    
    sDomain = ""
    If oMail.SenderEmailType = "SMTP" Then
        objRegEx.Pattern = "@[^.]*"
        Set oMatches = objRegEx.Execute(sSenderAddress)
        For Each oMatch In oMatches
            sDomain = LCase(oMatch.Value)
            Exit For
        Next
    Else
        sDomain = "@local"
    End If
    
    sSenderString = sInitials & sDomain
End Sub

Private Sub GetSubjectString(oMail As Outlook.MailItem, _
sSubjectString As String _
)
    Dim objRegEx As Object
    Dim sName As String
    
    sName = oMail.Subject
        
    Set objRegEx = CreateObject("vbscript.regexp")

    With objRegEx
        .Global = True
        .MultiLine = True
        .IgnoreCase = True
    End With
        
    ' Remove duplicate "RE" strings
    objRegEx.Pattern = "(re\W+)(re\W+)+"
    sName = objRegEx.Replace(sName, "$1")
    
    ' Remove duplicate "FW" strings
    objRegEx.Pattern = "(fwd?\W+)(fwd?\W+)+"
    sName = objRegEx.Replace(sName, "$1")
    
    ReplaceCharsForFileName sName, " "

    ' Trim any leading and/or trailing white space
    objRegEx.Pattern = "^\s*(.*?)\.*\s*$"
    sName = objRegEx.Replace(sName, "$1")

    ' Trim any double spaces
    objRegEx.Pattern = "\s+"
    sName = objRegEx.Replace(sName, " ")
    
    ' Limit the length to 100 characters
    sName = Left(sName, 100)
    
    If Len(sName) = 0 Then
        sName = "No Subject"
    End If

    sSubjectString = sName
End Sub

Private Sub MakeFileNameUnique(sPath As String, sFileName As String, sExt As String _
)
    Dim oRegEx As Object
    Dim sIntExt As String
    Dim sIntPath As String
    Dim sIntFileName As String
    Dim sTestName As String
    Dim i As Integer
        
    Set oRegEx = CreateObject("vbscript.regexp")

    If Len(sExt) <> 0 Then
        oRegEx.Pattern = "^\.*"
        sIntExt = oRegEx.Replace(sExt, ".") ' Make sure the ext has a "."
    Else
        sIntExt = ""
    End If
        
   
    oRegEx.Pattern = "\\*$"
    sIntPath = oRegEx.Replace(sPath, "") ' Remove the trailing backslash, for now
    
    If Len(Dir(sIntPath, vbDirectory)) = 0 Then
        ' Bigger problems, the directory doesn't exist!
        Exit Sub
    End If
    
    sIntPath = sIntPath + "\"
    sIntFileName = sFileName
    sTestName = Dir(sIntPath & sIntFileName & sIntExt)
    
    i = 0
    Do While sTestName <> ""
        i = i + 1
        sIntFileName = sFileName & "-" & i
        sTestName = Dir(sIntPath & sIntFileName & sIntExt)
    Loop
    sFileName = sIntFileName
End Sub

Private Function TestDirExist(sPath As String) As Boolean
    Dim sIntPath As String
    Dim oRegEx As Object
    Set oRegEx = CreateObject("vbscript.regexp")

    oRegEx.Pattern = "\\*$"
    sIntPath = oRegEx.Replace(sPath, "") ' Remove any trailing backslash
    If Len(Dir(sIntPath, vbDirectory)) = 0 Then
        TestDirExist = False
    Else
        TestDirExist = True
    End If
End Function

Private Function TestFileExist(sPath As String) As Boolean
    If Len(Dir(sPath)) = 0 Then
        TestFileExist = False
    Else
        TestFileExist = True
    End If
End Function




