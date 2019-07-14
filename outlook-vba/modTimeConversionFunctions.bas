Attribute VB_Name = "modTimeConversionFunctions"
Option Explicit
Option Compare Text
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' modConversionFunctions
' By Chip Pearson, www.cpearson.com, chip@cpearson.com
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This module contains conversion functions used to convert FILETIMEs, SYSTEMTIMEs, and Serial Times,
' including functions for converting to/from Local Time To GMTTime.
'
' Note that the functions in this module call upon one another. You should import this entire
' module into your project rather than copy/pasting the individual functions.
'
' -------------------------
' Functions In This Module:
' -------------------------
'
' FileTimeToSerialTime
' --------------------
'   This function converts a FILETIME to a Serial Time. This function is the converse of
'   the SerialTimeToFileTime function.
'
' GMTSerialTimeToLocalSerialTime
' ------------------------------
'   This function converts a GMT serial time to the local serial time. This is the
'   converse of the LocalSerialTimeToGMTSerialTime function.
'
' GMTSystemTimeToLocalSystemTime
' ------------------------------
'   This function converts a SYSTEMTIME containing a GMT value to a SYSTEMTIME containing
'   the local time. This is the converse of the LocalSystemTimeToGMTSystemTime function.
'
' GMTFileTimeToLocalFileTime
' --------------------------
'   This function covnerts a FILETIME containing a GMT value to a FILETIME containing
'   the equivalent local time.
'
' LocalFileTimeToGMTFileTime
' --------------------------
'   This function converts a FILETIME containing the local time to a FILETIME containing
'   the GMT Time. This is the converse of GMTFileTimeToLocalFileTime.
'
' LocalSerialTimeToGMTSerialTime
' ------------------------------
'   This function converts a Local serial time to the GMT serial time. This is the
'   converse of the GMTSerialTimeToLocalSerialTime function.
'
' LocalSystemTimeToGMTSystemTime
' ------------------------------
'   This funtion converts a SYSTEMTIME containing the local time to a SYSTEMTIME
'   containing the GMT Time. This is the converse of the GMTSystemTimeToLocalSystemTime
'   function.
'
' SerialTimeToFileTime
' --------------------
'   This function converts a Serial Time to a FILETIME. This function is the converse
'   of the FileTimeToSerialTime function.
'
' SerialTimeToSystemTime
' ----------------------
'   This function converts a Serial Time to a SYSTEMTIME.
'
' SystemTimeToSerialTime
' ----------------------
'   This function converts a SYSTEMTIME to a Serial time.
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''
' used by FormatMessage
'''''''''''''''''''''''''''''''''''
Private Const FORMAT_MESSAGE_ALLOCATE_BUFFER = &H100
Private Const FORMAT_MESSAGE_ARGUMENT_ARRAY = &H2000
Private Const FORMAT_MESSAGE_FROM_HMODULE = &H800
Private Const FORMAT_MESSAGE_FROM_STRING = &H400
Private Const FORMAT_MESSAGE_FROM_SYSTEM = &H1000
Private Const FORMAT_MESSAGE_MAX_WIDTH_MASK = &HFF
Private Const FORMAT_MESSAGE_IGNORE_INSERTS = &H200
Private Const FORMAT_MESSAGE_TEXT_LEN = &HA0 ' from ERRORS.H C++ include file.

'''''''''''''''''''''''''''''''''''''''
' Windows API Functions
'''''''''''''''''''''''''''''''''''''''
Private Declare Function FormatMessage Lib "kernel32" Alias "FormatMessageA" ( _
    ByVal dwFlags As Long, _
    lpSource As Any, _
    ByVal dwMessageId As Long, _
    ByVal dwLanguageId As Long, _
    ByVal lpBuffer As String, _
    ByVal nSize As Long, _
    Arguments As Long) As Long

Private Declare Function LocalFileTimeToFileTime Lib "kernel32" _
   (lpLocalFileTime As FileTime, _
     lpFileTime As FileTime) As Long

Private Declare Function FileTimeToLocalFileTime Lib "kernel32" ( _
    lpFileTime As FileTime, _
    lpLocalFileTime As FileTime) As Long

Private Declare Function SystemTimeToFileTime Lib "kernel32" _
    (lpSystemTime As SYSTEMTIME, _
    lpFileTime As FileTime) As Long

Private Declare Function CreateFile Lib "kernel32" Alias "CreateFileA" _
    (ByVal lpFilename As String, _
    ByVal dwDesiredAccess As Long, _
    ByVal dwShareMode As Long, _
    ByVal lpSecurityAttributes As Long, _
    ByVal dwCreationDisposition As Long, _
    ByVal dwFlagsAndAttributes As Long, _
    ByVal hTemplateFile As Long) As Long

Private Declare Function CloseHandle Lib "kernel32" _
    (ByVal hObject As Long) As Long

Private Declare Function FileTimeToSystemTime Lib "kernel32" ( _
    lpFileTime As FileTime, _
    lpSystemTime As SYSTEMTIME) As Long

Private Declare Function GetTimeZoneInformation Lib "kernel32" ( _
    lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long

Private Declare Function CompareFileTime Lib "kernel32" ( _
    lpFileTime1 As FileTime, _
    lpFileTime2 As FileTime) As Long




Public Function GMTFileTimeToLocalFileTime(GmtFileTime As FileTime, ByRef LocalFileTime As FileTime) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GMTFileTimeToLocalFileTime
' This converts a FILETIME containing a GMT time value to a FILETIME containing
' the local file time. You pass in as the LocalFileTime a variable of type
' FILETIME which will receive the local file time.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String

Res = FileTimeToLocalFileTime(lpFileTime:=GmtFileTime, lpLocalFileTime:=LocalFileTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToLocalFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    GMTFileTimeToLocalFileTime = False
    Exit Function
End If

GMTFileTimeToLocalFileTime = True

End Function

Public Function LocalFileTimeToGMTFileTime(LocalFileTime As FileTime, GmtFileTime As FileTime) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' LocalFileTimeToGMTFileTime
' This converts a local FILETIME to a GMT FILETIME. The value LocalFileTime
' is the local FILETIME to be converted. GMTFileTime is a variable in the
' calling process, of type FILETIME, in which the GMT FILETIME is to be
' stored.
' The function returns True if the conversion was successful, or
' False if a conversion error occurred.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String

Res = LocalFileTimeToFileTime(LocalFileTime, GmtFileTime)

If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With LocalFileTimeToFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    LocalFileTimeToGMTFileTime = False
    Exit Function
End If

LocalFileTimeToGMTFileTime = True


End Function

Public Function GMTSystemTimeToLocalSystemTime(GMTSystemTime As SYSTEMTIME, _
    LocalSystemTime As SYSTEMTIME) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GMTSystemTimeToLocalSystemTime
' This function converts the GMT time stored in GMTSystemTime to a
' SYSTEMTIME structure containing the local time. The parameter
' LocalSystemTime is a variable in the calling procedure that
' will be populated with the converted time value.
' The function returns True if the conversion was successful, or
' False if a conversion error occurred.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String
Dim LocalFileTime As FileTime
Dim GmtFileTime As FileTime

'''''''''''''''''''''''''''''''''''''''''''
' Convert GTMSystemTime to a FILETIME
' value.
'''''''''''''''''''''''''''''''''''''''''''
Res = SystemTimeToFileTime(GMTSystemTime, GmtFileTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With SystemTimeToFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    GMTSystemTimeToLocalSystemTime = False
    Exit Function
End If

''''''''''''''''''''''''''''''''''''''''''''
' Convert the GMT FileTime in GMTFileTime
' to the local time LocalFileTime.
''''''''''''''''''''''''''''''''''''''''''''
Res = FileTimeToLocalFileTime(lpFileTime:=GmtFileTime, lpLocalFileTime:=LocalFileTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToLocalFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    GMTSystemTimeToLocalSystemTime = False
    Exit Function
End If
'''''''''''''''''''''''''''''''''''''''''''
' Convert the local LocalFileTime to
' a SYSTEMTIME.
'''''''''''''''''''''''''''''''''''''''''''
Res = FileTimeToSystemTime(lpFileTime:=LocalFileTime, lpSystemTime:=LocalSystemTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToSystemTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    GMTSystemTimeToLocalSystemTime = False
    Exit Function
End If

GMTSystemTimeToLocalSystemTime = True


End Function

Public Function LocalSystemTimeToGMTSystemTime(LocalSystemTime As SYSTEMTIME, _
    ByRef GMTSystemTime As SYSTEMTIME) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' LocalSystemTimeToGMTSystemTime
' This converts a SYSTEMTIME containing the local time to a SYSTEMTIME
' containing the GMT time.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String
Dim LocalFileTime As FileTime
Dim GmtFileTime As FileTime

'''''''''''''''''''''''''''''''''''''''''''''
' Convert LocalSystemTime to a FILETIME
' containing the local time.
'''''''''''''''''''''''''''''''''''''''''''''
Res = SystemTimeToFileTime(LocalSystemTime, LocalFileTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With SystemTimeToFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    LocalSystemTimeToGMTSystemTime = False
    Exit Function
End If
''''''''''''''''''''''''''''''''''''''''''''''''
' Convert LocalFileTime to GMTFileTime
''''''''''''''''''''''''''''''''''''''''''''''''
Res = LocalFileTimeToFileTime(LocalFileTime, GmtFileTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With LocalFileTimeToFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    LocalSystemTimeToGMTSystemTime = False
    Exit Function
End If
''''''''''''''''''''''''''''''''''''''''''''''''
' Convert the GMTFileTime to a SYSTEMTIME.
''''''''''''''''''''''''''''''''''''''''''''''''
Res = FileTimeToSystemTime(lpFileTime:=GmtFileTime, lpSystemTime:=GMTSystemTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToSystemTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    LocalSystemTimeToGMTSystemTime = False
    Exit Function
End If

LocalSystemTimeToGMTSystemTime = True

End Function

Public Function SystemTimeToSerialTime(SysTime As SYSTEMTIME) As Date
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' SystemTimeToSerialTime
' This function converts a SYSTEMTIME to a Double Serial DateTime
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
With SysTime
    SystemTimeToSerialTime = DateSerial(.wYear, .wMonth, .wDay) + _
                        TimeSerial(.wHour, .wMinute, .wSecond)
End With

End Function

Public Function FileTimeToSerialTime(FileTimeValue As FileTime) As Date
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' FileTimeToSerialTime
' This function converts a FILETIME to a Double Serial DateTime.
' TESTED
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim SysTime As SYSTEMTIME
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String
Dim ResultDate As Date

'''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Convert FileTimeValue FILETIME to SysTime SYSTEMTIME.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
Res = FileTimeToSystemTime(lpFileTime:=FileTimeValue, lpSystemTime:=SysTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToSystemTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    FileTimeToSerialTime = False
    Exit Function
End If

With SysTime
    ResultDate = DateSerial(.wYear, .wMonth, .wDay) + _
                TimeSerial(.wHour, .wMinute, .wSecond)
End With

FileTimeToSerialTime = ResultDate


End Function

Public Function SerialTimeToFileTime(SerialTime As Date, ByRef FileTimeValue As FileTime) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' SerialTimeToFileTime
' This function converts a serial time to a FILETIME.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim SysTime As SYSTEMTIME
Dim FTime As FileTime
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String

''''''''''''''''''''''''''''''''''''''''''''
' Load up SysTime with the values from
' SerialTime.
''''''''''''''''''''''''''''''''''''''''''''
With SysTime
    .wYear = Year(SerialTime)
    .wMonth = Month(SerialTime)
    .wDay = Day(SerialTime)
    .wDayOfWeek = Weekday(SerialTime) - 1
    .wHour = Hour(SerialTime)
    .wMinute = Minute(SerialTime)
    .wSecond = Second(SerialTime)
    .wMilliseconds = 0
End With

'''''''''''''''''''''''''''''''''''''''''
' Convert the SystemTime to a FileTime
'''''''''''''''''''''''''''''''''''''''''
Res = SystemTimeToFileTime(SysTime, FileTimeValue)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With SystemTimeToFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    SerialTimeToFileTime = False
    Exit Function
End If
SerialTimeToFileTime = True

End Function

Public Function SerialTimeToSystemTime(SerialTime As Date, SysTime As SYSTEMTIME) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' SerialTimeToSystemTime
' This function converts a serial date/time to a SYSTEMTIME.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

With SysTime
    .wYear = Year(SerialTime)
    .wMonth = Month(SerialTime)
    .wDay = Day(SerialTime)
    .wDayOfWeek = Weekday(SerialTime) - 1
    .wHour = Hour(SerialTime)
    .wMinute = Minute(SerialTime)
    .wSecond = Second(SerialTime)
    .wMilliseconds = 0
End With

SerialTimeToSystemTime = True

End Function

Public Function LocalSerialTimeToGMTSerialTime(LocalSerialTime As Date) As Date
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' LocalSerialTimeToGMTSerialTime
' This function converts LocalSerialTime to a GMT Serial Time
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim TZI As TIME_ZONE_INFORMATION
Dim Res As Long
Res = GetTimeZoneInformation(TZI)
''''''''''''''''''''''''''''''''''''''''''''''''
' The arithatic used to convert between
' local and GMT times is
'   GMT = LocalTime + Bias
' where Bias is taken from TZI. The Bias in TZI
' is the number of minutes to be added to LocalTime
' to get the GMT Time.
'   LocalTime = GMT - Bias
' Since Bias is the number of minutes
' between Local and GMT, we get
'  GMT = LocalTime + TimeSerial(0,Bias,0)
' or
'  LocalTime = GMT - TimeSerial(0,Bias,0)
''''''''''''''''''''''''''''''''''''''''''''''''
    LocalSerialTimeToGMTSerialTime = LocalSerialTime + TimeSerial(0, TZI.Bias, 0)
End Function

Public Function GMTSerialTimeToLocalSerialTime(GMTSerialTime As Date) As Date
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GMTSerialTimeToLocalSerialTime
' This function converts a GMT Serial date to a local serial date.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim TZI As TIME_ZONE_INFORMATION
Dim Res As Long
Dim IsInDST As Boolean
Res = GetTimeZoneInformation(TZI)
''''''''''''''''''''''''''''''''''''''''''''''''
' The arithatic used to convert between
' local and GMT times is
'   GMT = LocalTime + Bias
' where Bias is taken from TZI. The Bias in TZI
' is the number of minutes to be added to LocalTime
' to get the GMT Time.
'   LocalTime = GMT - Bias
' Since Bias is the number of minutes
' between Local and GMT, we get
'  GMT = LocalTime + TimeSerial(0,Bias,0)
' or
'  LocalTime = GMT - TimeSerial(0,Bias,0)
' We also have to take Daylight Savings Time
' (DST) into account. Thus, we check whether the
' date GMTSerialTime is within Daylight
' Savings Time. If the date is within DST,
' we add an additional hour to the local time.
' DST is
' Examples:
'
'''''''''''''''''''''''''''''''''''''''''''''''
IsInDST = IsDateWithinDST(GMTSerialTime)
GMTSerialTimeToLocalSerialTime = GMTSerialTime - TimeSerial(0, TZI.Bias, 0) + TimeSerial(Abs(IsInDST), 0, 0)


End Function

Public Function IsDateWithinDST(DateValue As Date) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' IsDateWithinDST
' This returns True if DateValue falls within Daylight Savings Time,
' or False if the date falls outside of Daylight Savings Time. This
' works USA standards. If the year is less than 2007, Daylight Savings
' Time begins on the first Sunday in April and Standard Time begins
' on the last Sunday in October. For years 2007 and later, DayLight
' Savings Time begins on the second Sunday of March and ends the
' first Sunday in November.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim DstStart As Date
Dim StdStart As Date
Dim Y As Long
Dim M As Long
Dim D As Long
Dim DT As Date

Const C_MARCH = 3
Const C_APRIL = 4
Const C_OCTOBER = 10
Const C_NOVEMBER = 11


'''''''''''''''''''''''''''''''''''''
' Ensure DateValue is valid.
'''''''''''''''''''''''''''''''''''''
If DateValue <= 0 Then
    IsDateWithinDST = False
    Exit Function
End If

Y = Year(DateValue)
M = Month(DateValue)
D = Day(DateValue)

If Y < 2007 Then
    ''''''''''''''''''''''''''''''''''''
    ' Calculate the start dates of
    ' Daylight and Standard times for
    ' years < 2007.
    ' DST starts on the first Sunday
    ' of April.
    ' Std starts on the last Sunday
    ' in October.
    ''''''''''''''''''''''''''''''''''''
    DstStart = FirstDayOfWeekOfMonthAndYear(DayOfWeek:=vbSunday, DateValue:=DateSerial(Y, C_APRIL, 1))
    StdStart = LastDayOfWeekOfMonthAndYear(DayOfWeek:=vbSunday, DateValue:=DateSerial(Y, C_OCTOBER, 1))
Else
    ''''''''''''''''''''''''''''''''''''
    ' Calculate the start dates of
    ' Daylight and Standard times for
    ' years >= 2007.
    ' DST starts on the 2nd Sunday
    ' in March.
    ' Std starts on the 1st Sunday
    ' in November.
    ''''''''''''''''''''''''''''''''''''
    DstStart = NthDayOfWeekInMonth(DayOfWeek:=vbSunday, Number:=2, DateValue:=DateSerial(Y, M, D))
    StdStart = FirstDayOfWeekOfMonthAndYear(DayOfWeek:=vbSunday, DateValue:=DateSerial(Y, C_NOVEMBER, 1))
End If

If (DateValue >= DstStart) And (DateValue < StdStart) Then
    IsDateWithinDST = True
Else
    IsDateWithinDST = False
End If

End Function



Public Function LastDayOfWeekOfMonthAndYear(DayOfWeek As VbDayOfWeek, DateValue As Date) As Date
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' LastDayOfWeekOfMonthAndYear
' This returns the last DayOfWeek for the month and year of the
' date in DateValue. DateValue may be any day of the month and
' year to be tested. The Day value of DateValue is not used, so
' it may be set to any valid day for the given month.
' This function works only for dates in years 1900 and later; i.e.,
' DateValue must be greater than 0.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Y As Long
Dim M As Long
Dim D As Long
Dim LastD As Long
Dim DT As Date
Dim NumDays As Long

'''''''''''''''''''''''''''''''''''''''''
' Ensure we have a valid DayOfWeek value.
'''''''''''''''''''''''''''''''''''''''''
If Not ((DayOfWeek >= vbSunday) And (DayOfWeek <= vbSaturday)) Then
    LastDayOfWeekOfMonthAndYear = -1
    Exit Function
End If

''''''''''''''''''''''''''''''''''''''
' Ensure DateValue is positive.
''''''''''''''''''''''''''''''''''''''
If DateValue <= 0 Then
    LastDayOfWeekOfMonthAndYear = -1
    Exit Function
End If

'''''''''''''''''''''''''''''''''''''''''
' Save the Month and Year of DateValue
' so we don't have to calculate them
' repeatedly.
'''''''''''''''''''''''''''''''''''''''''
Y = Year(DateValue)
M = Month(DateValue)

'''''''''''''''''''''''''''''''''''''''''
' Get the number of days in the month
' and year of DateValue. This code works
' because the 0th day of a month is the
' last day of the previous month.
'''''''''''''''''''''''''''''''''''''''''
NumDays = Day(DateSerial(Year(DateValue), Month(DateValue) + 1, 0))
'''''''''''''''''''''''''''''''''''''''''''''
' Loop through the days of the month, setting
' DT to the date DateSerial(Y, M, D). When
' the loop ends (after looping for each
' day in the month), LastD will contain
' the last day of week of the given
' month and year.
'''''''''''''''''''''''''''''''''''''''''''''
For D = 1 To NumDays
    DT = DateSerial(Y, M, D)
    If Weekday(DT) = DayOfWeek Then
        LastD = DT
    End If
Next D
'''''''''''''''''''''''''''''''''''
' Return the LastD value.
'''''''''''''''''''''''''''''''''''
LastDayOfWeekOfMonthAndYear = LastD

End Function

Public Function NthDayOfWeekInMonth(DayOfWeek As VbDayOfWeek, Number As Long, DateValue As Date) As Date
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' NthDayOfWeekInMonth
' This returns the date of the Nth DayOfWeek in the month and year of the
' date in DateValue. The Day component of DateValue is not used, so
' any valid day for the month and year may be used. The function returns
' -1 if an error occurred.
' This function works only for dates in years 1900 and later; i.e.,
' DateValue must be greater than 0.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim N As Long
Dim Y As Long
Dim M As Long
Dim D As Long
Dim NumDays As Long
Dim DT As Date

'''''''''''''''''''''''''''''''''''''''''
' Ensure we have a valid DayOfWeek value.
'''''''''''''''''''''''''''''''''''''''''
If Not ((DayOfWeek >= vbSunday) And (DayOfWeek <= vbSaturday)) Then
    NthDayOfWeekInMonth = -1
    Exit Function
End If

''''''''''''''''''''''''''''''''''''''
' Ensure DateValue is positive.
''''''''''''''''''''''''''''''''''''''
If DateValue <= 0 Then
    NthDayOfWeekInMonth = -1
    Exit Function
End If

'''''''''''''''''''''''''''''''''''''''''
' Save the Month and Year of DateValue
' so we don't have to calculate them
' repeatedly.
'''''''''''''''''''''''''''''''''''''''''
Y = Year(DateValue)
M = Month(DateValue)

'''''''''''''''''''''''''''''''''''''''''
' Get the number of days in the month
' and year of DateValue. This code works
' because the 0th day of a month is the
' last day of the previous month.
'''''''''''''''''''''''''''''''''''''''''
NumDays = Day(DateSerial(Year(DateValue), Month(DateValue) + 1, 0))
For D = 1 To NumDays
    DT = DateSerial(Y, M, D)
    If Weekday(DT) = DayOfWeek Then
        N = N + 1
    End If
    If N >= Number Then
        NthDayOfWeekInMonth = DT
        Exit Function
    End If
Next D
''''''''''''''''''''''''''''''''
' If we make it out of the loop,
' then Number was greater than
' the number of the specified
' DayOfWeek in the month.
' Return -1.
'''''''''''''''''''''''''''''''
NthDayOfWeekInMonth = -1
End Function

Public Function FirstDayOfWeekOfMonthAndYear(DayOfWeek As VbDayOfWeek, DateValue As Date) As Date
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' FirstDayOfWeekOfMonthAndYear
' This function returns the date of the first DayOfWeek for the month
' and year in DateValue. DateValue may be any day of the month
' and year to be tested. The Day value of DateValue is not used,
' so it may be set to any valid day for the given month.
' This function works only for dates in years 1900 and later; i.e.,
' DateValue must be greater than 0.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim Y As Long
Dim M As Long
Dim D As Long
Dim DT As Date

'''''''''''''''''''''''''''''''''''''''''
' Ensure we have a valid DayOfWeek value.
'''''''''''''''''''''''''''''''''''''''''
If Not ((DayOfWeek >= vbSunday) And (DayOfWeek <= vbSaturday)) Then
    FirstDayOfWeekOfMonthAndYear = -1
    Exit Function
End If

''''''''''''''''''''''''''''''''''''''
' Ensure DateValue is positive.
''''''''''''''''''''''''''''''''''''''
If DateValue <= 0 Then
    FirstDayOfWeekOfMonthAndYear = -1
    Exit Function
End If

''''''''''''''''''''''''''''''''''''''
' Save the Year and Month so we don't
' have to calculate them within the
' loop.
''''''''''''''''''''''''''''''''''''''
Y = Year(DateValue)
M = Month(DateValue)
''''''''''''''''''''''''''''''''''''''
' Loop from Day = 1 to 7. The first
' DayOfWeek will be between the
' first and seventh of the month.
''''''''''''''''''''''''''''''''''''''
For D = 1 To 7
    DT = DateSerial(Y, M, D)
    If Weekday(DT) = DayOfWeek Then
        FirstDayOfWeekOfMonthAndYear = DT
        Exit Function
    End If
Next D

End Function

