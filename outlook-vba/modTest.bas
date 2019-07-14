Attribute VB_Name = "modTest"
Option Explicit
Option Compare Text
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' modTest
' By Chip Pearson, www.cpearson.com, chip@cpearson.com
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This module contains test and demonsration procedures for the
' functions in modGetSetFileTimes. To run the procedures as written,
' with no modification, create an empty text file named "test.txt" in
' the same folder as this workbook.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private Const pFileName = "C:\Test.txt" '<<<<<< CHANGE AS REQUIRED


Sub TestSetFileDateTime()
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' SetFileDateTime`
' This procedure demonstrates the SetFileDateTime.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim FName As String
Dim Result As Boolean
Dim TheNewTime As Double
Dim WhatTime As FileDateToProcess
Dim TheNewDate As Double
Dim NoGMTConversion As Boolean

TheNewDate = DateSerial(2006, 1, 2)   '<<< CHANGE AS REQUIRED
TheNewTime = TimeSerial(3, 4, 5)        '<<< CHANGE AS REQUIRED

'''''''''''''''''''''''''''''''''''''
' Set the variables to be passed to
' SetFileDateTime.
'''''''''''''''''''''''''''''''''''''
FName = pFileName
TheNewDate = TheNewDate + TheNewTime
WhatTime = FileDateCreate '<<< CHANGE AS REQUIRED
NoGMTConversion = True
'''''''''''''''''''''''''''''''''''''
' Call SetFileDateTime to change
' the file date/time.
'''''''''''''''''''''''''''''''''''''
Result = SetFileDateTime(FileName:=FName, FileDateTime:=TheNewDate, _
    WhichDateToChange:=WhatTime, NoGMTConvert:=NoGMTConversion)
If Result = True Then
    Debug.Print "File date/time successfully modified."
Else
    Debug.Print "An error occurred with SetFileDateTime."
End If

End Sub

Sub TestGetFileDateTime()
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' TestGetFileDateTime
' This procedure demonstrates the GetFileDateTime.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim FName As String
Dim Result As Boolean
Dim TheNewTime As Double
Dim WhatTime As FileDateToProcess
Dim NoGMTConversion As Boolean

FName = pFileName
WhatTime = FileDateCreate
NoGMTConversion = False
TheNewTime = GetFileDateTime(FileName:=FName, WhichDateToGet:=WhatTime, NoGMTConvert:=NoGMTConversion)

If TheNewTime < 0 Then
    Debug.Print "An error occurred in GetFileDateTime"
Else
    Debug.Print "File Time: " & Format(TheNewTime, "dd-mmm-yyyy hh:mm:ss")
End If
End Sub

Sub TestGetFileTimeAsFILETIME()

Dim FT As FileTime
Dim Res As Boolean
Dim FileName As String
Dim ConvertGMT As Boolean
Dim DateSerial As Date
Dim WhatTime As FileDateToProcess


FileName = "C:\Test.txt"
WhatTime = FileDateCreate

'''''''''''''''''''''''''''''''''''''
' NOT GMT CONVERSION
'''''''''''''''''''''''''''''''''''''
ConvertGMT = False
Res = GetFileDateTimeAsFILETIME(FileName:=FileName, _
    WhichDateToGet:=WhatTime, _
    FTime:=FT, _
    ConvertFromGMT:=ConvertGMT)

If Res = 0 Then
    Debug.Print "Error with GetFileTimeAsFILETIME"
Else
    ''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Convert FT to a serial date to display.
    ''''''''''''''''''''''''''''''''''''''''''''''''''''
    DateSerial = FileTimeToSerialTime(FileTimeValue:=FT)
End If
Debug.Print "FileTime Low: " & Hex(FT.dwLowDateTime) & _
        " High: " & Hex(FT.dwHighDateTime) & _
        " Serial: " & Format(DateSerial, "dd-mmm-yyyy hh:mm:ss")


''''''''''''''''''''''''''''''''
' GMT CONVERSION
''''''''''''''''''''''''''''''''
ConvertGMT = True
Res = GetFileDateTimeAsFILETIME(FileName:=FileName, _
    WhichDateToGet:=WhatTime, _
    FTime:=FT, _
    ConvertFromGMT:=ConvertGMT)

If Res = 0 Then
    Debug.Print "Error with GetFileTimeAsFILETIME"
Else
    DateSerial = FileTimeToSerialTime(FileTimeValue:=FT)
End If
Debug.Print "FileTime Low: " & Hex(FT.dwLowDateTime) & _
        " High: " & Hex(FT.dwHighDateTime) & _
        " Serial: " & Format(DateSerial, "dd-mmm-yyyy hh:mm:ss")
    

End Sub

Sub TestCompareFileTimes()

Dim Res As Variant
Res = CompareFileTimes(FileName1:="C:\Test1.txt", FileName2:="C:\Test2.txt", _
    WhichDate:=FileDateCreate)
If IsNull(Res) = True Then
    Debug.Print "An error occurred in CompareFileTimes"
Else
    If Res < 0 Then
        Debug.Print "File1 is earlier than File2"
    Else
        Debug.Print "File1 is later than File2"
    End If
End If


End Sub

