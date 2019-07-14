Attribute VB_Name = "modWorksheetFunctions"
Option Explicit
Option Compare Text

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' modWorksheetFunctions
' By Chip Pearson, www.cpearson.com, chip@cpearson.com
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This module contains function designed to be called from worksheet cells.
' These function call upon the procedures in modTimeConversionFunctions
' and modGetSetFileTimes, so you must import those modules as well.
'
' The functions in this module are:
'   CreatedFileDateTime
'   -------------------
'   Returns the file creation time of the specified file.  By default, the returned time
'   is Local Time. Set the TimeAsGMT parameter flag to True to get GMT.
'
'   AccessedFileDateTime
'   --------------------
'   Returns the file last access time of the specified file.  By default, the returned time
'   is Local Time. Set the TimeAsGMT parameter flag to True to get GMT.
'
'   ModifiedFileDateTime
'   --------------------
'   Returns the file last modified time of the specified file.  By default, the returned time
'   is Local Time. Set the TimeAsGMT parameter flag to True to get GMT.
'
'   CurrentTimeZoneName
'   -------------------
'   Reutrns the name of the current time zone (e.g., "Central Standard Time".
'
'   IsCurrentlyDaylightTime
'   -----------------------
'   Returns TRUE or FALSE indicating whether the system is operating in Daylight
'   Savings Time.
'
'   GMTBias
'   -------
'   This function returns the number of minutes that should be added to the local time
'   to get GMT. This value is positive for locations West of GMT, and negative for locations
'   East of GMT. This works in the VBA Code like
'        Dim GMTTime As Date
'        Dim LocalTime As Date
'        Dim Bias As Long
'        LocalTime = Now
'        Bias = GMTBias()
'        GMTTime = LocalTime + TimeSerial(0, Bias, 0)
'        Debug.Print "Local Time: " & LocalTime & "  GMTTime: " & GMTTime
'   Or in a worksheet formula like
'        =NOW()+TIME(0,GMTBias(),0).
'
'   IsCurrentlyDaylightTime
'   -----------------------
'   Returns TRUE if the system is currently in Daylight Savings Time, FALSE
'   otherwise.
'
'   ExcelFileNameReferenceToFileName
'   --------------------------------
'   This converts the result of the formula =CELL("filename",A1) to
'   a regular file name.
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Declare Function GetTimeZoneInformation Lib "kernel32" ( _
    lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long



Public Function CreatedFileDateTime(Optional FileName As String = vbNullString, _
                Optional TimeAsGMT As Boolean = False) As Variant
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CreatedFileDateTime
' This function returns the create date of FileName. If FileName is omitted, this file's
' create date is returned. It will return the file's creation time.
' If the file named in FileName does not exist or is otherwise unavailable, the function
' returns a #VALUE error. Any other error will return #NULL.
' By default, time returned is Local Time. If TimeAsGMT is True (the default is False),
' the time returned is GMT.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Dim FileTime As Date
    Dim FName As String
    If FileName = vbNullString Then
        FName = ThisWorkbook.FullName
    Else
        FName = FileName
    End If
    If Dir(FName, vbNormal + vbHidden + vbSystem) = vbNullString Then
        CreatedFileDateTime = CVErr(xlErrValue)
        Exit Function
    End If
    CreatedFileDateTime = GetFileDateTime(FileName:=FName, WhichDateToGet:=FileDateCreate, NoGMTConvert:=False)
    '''''''''''''''''''''''''''''''
    ' If TimeAsGMT is True, convert
    ' local time to GMT time.
    ''''''''''''''''''''''''''''''
    If TimeAsGMT = True Then
        CreatedFileDateTime = LocalSerialTimeToGMTSerialTime(CDate(CreatedFileDateTime))
    End If
    
End Function


Public Function AccessedFileDateTime(Optional FileName As String = vbNullString, _
                Optional TimeAsGMT As Boolean = False) As Variant
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AccessedFileDateTime
' This function returns the last access date of FileName. If FileName is omitted, this file's
' create date is returned. It will return the file's creation time. The time is returned
' in local time, not GMT. If the file named in FileName does not exist, a #VALUE error
' is returned. If any other error occurs, the function returns a #NULL value.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Dim FileTime As Date
    Dim FName As String
    If FileName = vbNullString Then
        FName = ThisWorkbook.FullName
    Else
        FName = FileName
    End If
    If Dir(FName, vbNormal + vbHidden + vbSystem) = vbNullString Then
        AccessedFileDateTime = CVErr(xlErrValue)
        Exit Function
    End If
    AccessedFileDateTime = GetFileDateTime(FileName:=FName, WhichDateToGet:=FileDateLastAccess, NoGMTConvert:=False)
    '''''''''''''''''''''''''''''''
    ' If TimeAsGMT is True, convert
    ' local time to GMT time.
    ''''''''''''''''''''''''''''''
    If TimeAsGMT = True Then
        AccessedFileDateTime = LocalSerialTimeToGMTSerialTime(CDate(AccessedFileDateTime))
    End If

End Function

Public Function ModifiedFileDateTime(Optional FileName As String = vbNullString, _
                Optional TimeAsGMT As Boolean = False) As Variant
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ModifiedFileDateTime
' This function returns the last modified date of FileName. If FileName is omitted, this file's
' create date is returned. It will return the file's creation time. The time is returned
' in local time, not GMT. If the file named in FileName does not exist, a #VALUE error
' is returned. If any other error occurs, the function returns a #NULL value.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Dim FileTime As Date
    Dim FName As String
    If FileName = vbNullString Then
        FName = ThisWorkbook.FullName
    Else
        FName = FileName
    End If
    If Dir(FName, vbNormal + vbHidden + vbSystem) = vbNullString Then
        ModifiedFileDateTime = CVErr(xlErrValue)
        Exit Function
    End If
    ModifiedFileDateTime = GetFileDateTime(FileName:=FName, WhichDateToGet:=FileDateLastAccess, NoGMTConvert:=False)
    '''''''''''''''''''''''''''''''
    ' If TimeAsGMT is True, convert
    ' local time to GMT time.
    ''''''''''''''''''''''''''''''
    If TimeAsGMT = True Then
        ModifiedFileDateTime = LocalSerialTimeToGMTSerialTime(CDate(ModifiedFileDateTime))
    End If

    
End Function

Public Function CurrentTimeZoneName() As String
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CurrentTimeZoneName
' Returns the name of the current time zone, e.g.,
' "Central Standard Time". Returns vbNullString
' if the time zone could not be determined (result
' from GetTimeZoneInformation was TIME_ZONE_ID_UNKNOWN or
' TIME_ZONE_ID_INVALID).
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim TZI As TIME_ZONE_INFORMATION
Dim Res As Long
Dim TimeZoneName As String
Res = GetTimeZoneInformation(TZI)
Select Case Res
    Case TIME_ZONE_ID_UNKNOWN, TIME_ZONE_ID_INVALID
        '''''''''''''''''''''''''''''''''''''
        ' The Time Zone and DST could not be
        ' determined. Return False.
        '''''''''''''''''''''''''''''''''''''
        TimeZoneName = vbNullString
    Case TIME_ZONE_ID_STANDARD
        TimeZoneName = IntArrayToString(TZI.StandardName)
    Case TIME_ZONE_ID_DAYLIGHT
        TimeZoneName = IntArrayToString(TZI.DaylightName)
    Case Else
        ''''''''''''''''''''''''''''''''''''
        ' Unknown, unexpeted result from
        ' GetTimeZoneInformation. Should
        ' never happen, but return empty
        ' string just in case.
        ''''''''''''''''''''''''''''''''''''
        TimeZoneName = vbNullString
End Select

CurrentTimeZoneName = TimeZoneName

End Function

Public Function IsCurrentlyDaylightTime() As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' IsCurrentlyDaylightTime
' Returns True is the local system is currently operating
' in Daylight Time. False otherwise.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim TZI As TIME_ZONE_INFORMATION
Dim Res As Long
Res = GetTimeZoneInformation(TZI)
Select Case Res
    Case TIME_ZONE_ID_UNKNOWN, TIME_ZONE_ID_INVALID
        '''''''''''''''''''''''''''''''''''''
        ' The Time Zone and DST could not be
        ' determined. Return False.
        '''''''''''''''''''''''''''''''''''''
        IsCurrentlyDaylightTime = False
    Case TIME_ZONE_ID_STANDARD
        IsCurrentlyDaylightTime = False
    Case TIME_ZONE_ID_DAYLIGHT
        IsCurrentlyDaylightTime = True
    Case Else
        ''''''''''''''''''''''''''''''''''''
        ' Unknown, unexpeted result from
        ' GetTimeZoneInformation. Should
        ' never happen, but return False
        ' just in case.
        ''''''''''''''''''''''''''''''''''''
        IsCurrentlyDaylightTime = False
End Select

End Function

Public Function GMTBias() As Long
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GMTBias
' This returns the GMT Bias. This is the number of minutes
' added to Local Time to get GMT. It is positive for
' locations West of GMT, negative for East of GMT.
' GMT = LocalTime + TimeSerial(0,GMTBias,0).
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim TZI As TIME_ZONE_INFORMATION
Dim Res As Long
Res = GetTimeZoneInformation(TZI)

Select Case Res
    Case TIME_ZONE_ID_UNKNOWN, TIME_ZONE_ID_INVALID
        '''''''''''''''''''''''''''''''''''''
        ' The Time Zone and DST could not be
        ' determined. Return 0.
        '''''''''''''''''''''''''''''''''''''
        GMTBias = 0
    Case TIME_ZONE_ID_STANDARD, TIME_ZONE_ID_DAYLIGHT
        ''''''''''''''''''''''''''''''''''''''''
        ' Return the number of minutes that need
        ' be added to Local Time to get GMT.
        ''''''''''''''''''''''''''''''''''''''''
        GMTBias = TZI.Bias
        
    Case Else
        ''''''''''''''''''''''''''''''''''''
        ' Unknown, unexpeted result from
        ' GetTimeZoneInformation. Should
        ' never happen, but return empty
        ' string just in case.
        ''''''''''''''''''''''''''''''''''''
        GMTBias = 0
End Select



End Function

Public Function ExcelFileNameReferenceToFileName(ExcelFileNameReference As String) As String
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ExcelFileNameReferenceToFileName
' This converts the result of =CELL("filename",A1) to an actual file name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Pos As Integer
Dim S As String
If Trim(ExcelFileNameReference) = vbNullString Then
    ExcelFileNameReferenceToFileName = vbNullString
    Exit Function
End If
Pos = InStr(1, ExcelFileNameReference, "]")
ExcelFileNameReferenceToFileName = Replace(Left(ExcelFileNameReference, Pos - 1), "[", vbNullString)



End Function


Private Function IntArrayToString(A() As Integer) As String
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' IntArrayToString
' This converts an array of integers, each of which is
' an ASCII character value, to a VBA String.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim S As String
Dim N As Long
Dim Pos As Integer
For N = LBound(A) To UBound(A)
    S = S & Chr(A(N))
Next N
Pos = InStr(1, S, vbNullChar)
If Pos Then
    S = Left(S, Pos - 1)
Else
    ' do nothing
End If
IntArrayToString = S

End Function
Sub AAA()

Dim LocalTime As Date
Dim GMTTime As Date
Dim Bias As Long
Bias = GMTBias()
GMTTime = LocalTime + TimeSerial(0, Bias, 0)

Debug.Print LocalTime

Debug.Print GMTTime



End Sub
