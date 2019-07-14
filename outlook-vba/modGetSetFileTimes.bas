Attribute VB_Name = "modGetSetFileTimes"
Option Explicit
Option Compare Text
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' modGetSetFileTime
' By Chip Pearson, www.cpearson.com, chip@cpearson.com
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This module contains two functions for retrieving and setting the file
' time values (Creation Date, Last Access Date, and Last Modified Date).
' This module requires the conversion functions in modTimeConversionFunctions.
'
'   -   GetFileDateTime
'       -----------------
'       This procedure returns the value, in local VB/VBA format, the
'       specified time value. The requested time is specified in the
'       WhichDateToGet parameter. The valid values, listed in the
'       FileDateToProcess enum, are FileDateCreate, FileDateLastAccess, and
'       FileDateLastModified.
'       The result is the requested time, or -1 if an error occurred. Date/times
'       are returned in the local time zone as dddd.ttttt VB/VBA format.
'       An error is returned if the file does not exist.
'
'   -   GetFileTimeAsFILETIME
'       ---------------------
'       This procedure sets a FILETIME variable to the specified file
'       time of the specified file. By default, it will convert GMT
'       to Local time. You can prevent this, and return the GMT time
'       of a file as a FILETIME, by setting the NoGMTConversion parameter
'       to True (default is False).
'
'   -   SetFileDateTime
'       -----------------
'       This procedure sets any one of the 3 date/time values as specified
'       in the WhichDateToChange parameter. The valid values, listed in the
'       FileDateToProcess enum, are FileDateCreate, FileDateLastAccess, and
'       FileDateLastModified. The input value is a date/time in the VB/VBA
'       format of dddd.ttttttt Double value.
'       The result is True if the time was successfully changed, or False
'       if an error occurred.
'       An error is returned if the file does not exist.
'
' These functions use the GetFileTime and SetFileTime Windows API functions
' to read or write the time values.
'
' This module also includes the function GetSystemErrorMessageText which
' is used to get the descriptive text of a system error number. This
' function is Public.
'
' The comments in this module use the terms "Date" and "Time" interchangably.
' It should be understood that we are always refering to value that has
' both a Date and Time component. For example, "Create Date" should be
' interpreted to mean "Create Date And Time". If a procedure deals with only
' the Date component (ignoring the Time component) or only the Time component
' (ignoring the Date component) this will be made clear in the documentation.
'
' The comments in this module use the term "GMT" and "Greenwich Mean Time".
' These terms have the same meaning of "UTC" and "Univeral Coordinated Time" or,
' if you are in the military, "Zulu Time".
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This modules REQUIRES the modTimeTypeDefinition module.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''
' Misc Constants
'''''''''''''''''''''''''''''''''''
Private Const NULL_LONG As Long = 0&
Private Const C_ERROR As Long = -1&

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

'''''''''''''''''''''''''''''''''''
' used by CreateFile
'''''''''''''''''''''''''''''''''''
Private Const OPEN_EXISTING = &H3
Private Const FILE_SHARE_READ = &H1
Private Const FILE_SHARE_WRITE = &H2
Private Const CREATE_ALWAYS = &H2
Private Const OPEN_ALWAYS = &H4
Private Const INVALID_HANDLE_VALUE = -1
Private Const ERROR_ALREADY_EXISTS = &HB7
Private Const GENERIC_ALL = &H10000000
Private Const GENERIC_EXECUTE = &H20000000
Private Const GENERIC_READ = &H80000000
Private Const GENERIC_WRITE = &H40000000

'''''''''''''''''''''''''''''''''''''''''
' Used by GetTimeZoneInformation.
' Declared as Public so functions in
' other modules and projects can use
' the constants.
'''''''''''''''''''''''''''''''''''''''''
Public Const TIME_ZONE_ID_UNKNOWN = 0
Public Const TIME_ZONE_ID_STANDARD = 1
Public Const TIME_ZONE_ID_DAYLIGHT = 2
Public Const TIME_ZONE_ID_INVALID = -1


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Public Type And Enum Definitions. If you already have these
' declarations in your project, you may remove them from this
' module. Note that you may get a compiler error
' ("ByRef argument type mismatch") if you have a type declared
' Private in one module and Public in another module. You
' should have only one type declaration in your project.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Enum FileDateToProcess
    FileDateCreate = 1
    FileDateLastAccess = 2
    FileDateLastModified = 3
End Enum

Public Type FileTime
    dwLowDateTime As Long
    dwHighDateTime As Long
End Type

Public Type SYSTEMTIME
    wYear As Integer
    wMonth As Integer
    wDayOfWeek As Integer
    wDay As Integer
    wHour As Integer
    wMinute As Integer
    wSecond As Integer
    wMilliseconds As Integer
End Type

Public Type TIME_ZONE_INFORMATION
    Bias As Long
    StandardName(0 To 31) As Integer
    StandardDate As SYSTEMTIME
    StandardBias As Long
    DaylightName(0 To 31) As Integer
    DaylightDate As SYSTEMTIME
    DaylightBias As Long
End Type



'''''''''''''''''''''''''''''''''''
' Win API Declares
'''''''''''''''''''''''''''''''''''
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

Private Declare Function CompareFileTime Lib "kernel32" ( _
    lpFileTime1 As FileTime, _
    lpFileTime2 As FileTime) As Long

Private Declare Function GetVolumeInformation Lib "kernel32" Alias "GetVolumeInformationA" ( _
    ByVal lpRootPathName As String, _
    ByVal lpVolumeNameBuffer As String, _
    ByVal nVolumeNameSize As Long, _
    lpVolumeSerialNumber As Long, _
    lpMaximumComponentLength As Long, _
    lpFileSystemFlags As Long, _
    ByVal lpFileSystemNameBuffer As String, _
    ByVal nFileSystemNameSize As Long) As Long



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' SetFileTime* and GetFileTime* Declares
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' The following 6 Declares (SetFileTimeCreate, SetFileTimeLastAccess, and
' SetFileTimeLastModified, and GetFileTimeCreate, GetFileTimeLastAccess, and
' GetFileTimeLastModified) all point to one of two Windows API functions,
' either "SetFileTime" or "GetFileTime".
'
' The difference between the Declares is which one of the 3 parameters --
' CreateTime, LastAccessTime, and LastModified -- is declared "As FILETIME"
' and which are declared ByVal As Long. This is required since VB/VBA
' doesn't support pointers, which are necessary in the GetFileTime and
' SetFileTime API functions.  To set or return the file time of one
' of the file's times ("Created", "Last Access", "Last Modified"), call
' function that has that parameter declared "As FILETIME" and the other two
' parameters declared "By Val As Long". Set the "ByVal As Long" parameters
' to NULL_LONG. For example, to set the LastAccessTime, use code like
' the following:
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Type FILETIME
'     dwLowDateTime As Long
'     dwHighDateTime As Long
' End Type
' Dim Res As Long
' Dim pFileTime As FILETIME
' Res = SetFileTimeLastAccess(HFile:=FileHandle, _
'                           CreateTime:=NULL_LONG, _
'                           LastAccessTime:=pFileTime, _
'                           LastModifiedTime:=NULL_LONG)
' If Res = 0 Then
'     ' An error occurred
' Else
'     ' Success
' End If
'
' Where FileHandle is the result of the CreateFile API call. We
' use CreateFile to get the handle of opening an existing file.
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''
' SetFileTime functions.
''''''''''''''''''''''''
Private Declare Function SetFileTimeCreate Lib "kernel32" Alias "SetFileTime" _
   (ByVal hFile As Long, _
    CreateTime As FileTime, _
    ByVal LastAccessTime As Long, _
    ByVal LastModified As Long) As Long

Private Declare Function SetFileTimeLastAccess Lib "kernel32" Alias "SetFileTime" _
   (ByVal hFile As Long, _
    ByVal CreateTime As Long, _
    LastAccessTime As FileTime, _
    ByVal LastModified As Long) As Long

Private Declare Function SetFileTimeLastModified Lib "kernel32" Alias "SetFileTime" _
   (ByVal hFile As Long, _
    ByVal CreateTime As Long, _
    ByVal LastAccessTime As Long, _
    LastModified As FileTime) As Long

''''''''''''''''''''''''
' GetFileTime functions.
''''''''''''''''''''''''
Private Declare Function GetFileTimeCreate Lib "kernel32" Alias "GetFileTime" ( _
    ByVal hFile As Long, _
    CreateTime As FileTime, _
    ByVal LastAccessTime As Long, _
    ByVal LastModified As Long) As Long

Private Declare Function GetFileTimeLastAccess Lib "kernel32" Alias "GetFileTime" ( _
    ByVal hFile As Long, _
    ByVal CreateTime As Long, _
    LastAccessTime As FileTime, _
    ByVal LastModified As Long) As Long

Private Declare Function GetFileTimeLastModified Lib "kernel32" Alias "GetFileTime" ( _
    ByVal hFile As Long, _
    ByVal CreateTime As Long, _
    ByVal LastAccessTime As Long, _
    LastModified As FileTime) As Long
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' End of SetFileTime* GetFileTime* Declares
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' MAIN PROCEDURES
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Function SetFileDateTime(FileName As String, _
    FileDateTime As Double, WhichDateToChange As FileDateToProcess, _
    Optional NoGMTConvert As Boolean = False) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' SetFileDateTime
' This function sets the specified date/time of the specified file to the
' value in FileDateTime. The function returns True if the Date/Time value
' was successfully altered, or False if an error occurred.
'
' Which date/time to change is specified in the WhichDateToChange parameter,
' and this parameter must have a value listed in the FileDateToProcess
' enum:
'            Public Enum FileDateToProcess
'                FileDateCreate = 1
'                FileDateLastAccess = 2
'                FileDateLastModified = 3
'            End Enum
'
' The input date FileDateTime is assumed to be in the standard VB/VBA
' ddddd.ttttttt Double variable format. This value should be in Local Time,
' not GMT Time.
'
' If NoGMTConvert is omitted or False, the FileDateTime value is converted
' to GMT Time. This is the normal mode, since file times are GMT Times.
'
' If NoGMTConvert is True, the time is NOT converted to GMT
' Time. When you view a file's properites, the times are automatically
' converted to GMT for display. Thus, if you set a file's time with the
' NoGMTConvert option set to True, the displayed file time will be N hours
' later (or earlier if you're East of GMT) than the time passed in as
' FileDateTime. It recommended that you NOT set NoGMTConvert to TRUE.
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim FileHandle As Long
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String
Dim tFileTime As FileTime
Dim tLocalTime As FileTime
Dim tSystemTime As SYSTEMTIME


''''''''''''''''''''''''''''''''''''
' Ensure the file exists.
''''''''''''''''''''''''''''''''''''
If Dir(FileName) = vbNullString Then
    SetFileDateTime = False
    Exit Function
End If
''''''''''''''''''''''''''''''''''''''
' Break apart the input FileDateTime
' into the components of tSystemTime
' structure.
''''''''''''''''''''''''''''''''''''''
With tSystemTime
    .wYear = Year(FileDateTime)
    .wMonth = Month(FileDateTime)
    .wDay = Day(FileDateTime)
    ''''''''''''''''''''''''''''''''''''''''
    ' Note: Weekday returns Sunday = 1,
    ' and SYSTEMTIME requires Sunday = 0,
    ' so we subtract 1 from Weekday to get
    ' the value expected by SYSTEMTIME.
    ''''''''''''''''''''''''''''''''''''''''
    .wDayOfWeek = Weekday(FileDateTime) - 1
    .wHour = Hour(FileDateTime)
    .wMinute = Minute(FileDateTime)
    .wSecond = Second(FileDateTime)
End With
''''''''''''''''''''''''''''''''''''''''''''''''''''
' Convert the SystemTime value, which contains
' the date and time to which we will to change
' the file's Date/Time, to a FILETIME
' structure, still in local time.
''''''''''''''''''''''''''''''''''''''''''''''''''''
Res = SystemTimeToFileTime(lpSystemTime:=tSystemTime, lpFileTime:=tLocalTime)
If Res = 0 Then
    ''''''''''''''''''''''
    ' An error occurred.
    ''''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrorNumber:=ErrNum)
    Debug.Print "Error from SystemTimeToFileTime" & vbCrLf & _
        "Err:  " & CStr(ErrNum) & vbCrLf & _
        "Desc: " & ErrText
    SetFileDateTime = False
    Exit Function
End If
'''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Convert the local time in tLocalTime to a GMT-based
' tFileTime. This step can be skipped by setting the
' NoGMTConversion parameter to True. This is of limited
' practical value, and should be used only when
' the input value FileDateTime is already a GMT time.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

If NoGMTConvert = False Then
    '''''''''''''''''''''''''''''''''''''''''''''''''''
    ' Convert the Local Time to GMT. GMT is what is
    ' actually written to the file.
    '''''''''''''''''''''''''''''''''''''''''''''''''''
    Res = LocalFileTimeToFileTime(lpLocalFileTime:=tLocalTime, lpFileTime:=tFileTime)
Else
    ''''''''''''''''''''''''''''''''''''''''''''''''''''
    ' We are NOT converting the GMT. Since Windows
    ' converts times from GMT to Local time when
    ' it displays a file time, the file time displayed
    ' will NOT be the same as the value passed in
    ' as FileDateTime. Setting NoGMTConvert to True
    ' is NOT recommended.
    ''''''''''''''''''''''''''''''''''''''''''''''''''''
    tFileTime.dwHighDateTime = tLocalTime.dwHighDateTime
    tFileTime.dwLowDateTime = tLocalTime.dwLowDateTime
    Res = 2
End If
If Res = 0 Then
    ''''''''''''''''''''''
    ' An error occurred.
    ''''''''''''''''''''''syst
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrorNumber:=ErrNum)
    Debug.Print "Error from LocalFileTimeToFileTime" & vbCrLf & _
        "Err:  " & CStr(ErrNum) & vbCrLf & _
        "Desc: " & ErrText
    SetFileDateTime = False
    Exit Function
End If

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Here, we use CreateFile to open the existing file
' named in FileName.  The OPEN_EXISTING flag indicates
' that we are opening an existing flag.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
FileHandle = CreateFile(lpFilename:=FileName, _
                        dwDesiredAccess:=GENERIC_WRITE, _
                        dwShareMode:=FILE_SHARE_READ Or FILE_SHARE_WRITE, _
                        lpSecurityAttributes:=ByVal 0&, _
                        dwCreationDisposition:=OPEN_EXISTING, _
                        dwFlagsAndAttributes:=0, _
                        hTemplateFile:=0)

If FileHandle = INVALID_HANDLE_VALUE Then
    ''''''''''''''''''''''
    ' An error occurred.
    ''''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrorNumber:=ErrNum)
    Debug.Print "Error from CreateFile" & vbCrLf & _
        "Err:  " & CStr(ErrNum) & vbCrLf & _
        "Desc: " & ErrText
    SetFileDateTime = False
    Exit Function
End If

'''''''''''''''''''''''''''''''''''''''''''''''''
' Call SetFileTime to actually set the file's
' Last Modification Date. Note that the name
' of the function that is called varies with
' the date being updated, but all these functions
' really just call the SetFileTime API function.
'''''''''''''''''''''''''''''''''''''''''''''''''
Select Case WhichDateToChange
    Case FileDateCreate
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the SetFileTimeCreate flavor of SetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = SetFileTimeCreate( _
            hFile:=FileHandle, _
            CreateTime:=tFileTime, _
            LastAccessTime:=NULL_LONG, _
            LastModified:=NULL_LONG)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With SetFileTimeCreate:" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            SetFileDateTime = False
            Exit Function
        End If
    
    Case FileDateLastAccess
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the SetFileTimeLastAccess flavor of SetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = SetFileTimeLastAccess( _
            hFile:=FileHandle, _
            CreateTime:=NULL_LONG, _
            LastAccessTime:=tFileTime, _
            LastModified:=NULL_LONG)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With SetFileTimeLastAccess:" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            SetFileDateTime = False
            Exit Function
        End If
    
    Case FileDateLastModified
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the SetFileTimeLastModified flavor of SetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = SetFileTimeLastModified( _
            hFile:=FileHandle, _
            CreateTime:=NULL_LONG, _
            LastAccessTime:=NULL_LONG, _
            LastModified:=tFileTime)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With SetFileTimeLastModified:" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            SetFileDateTime = False
            Exit Function
        End If
    
    Case Else
        ''''''''''''''''''''''''''''''''''''''
        ' Invalid value for WhichDateToChange.
        ''''''''''''''''''''''''''''''''''''''
        Debug.Print "Invalid value for WhichDateToChange: " & CStr(WhichDateToChange)
        CloseHandle FileHandle
        SetFileDateTime = False
        Exit Function

End Select

'''''''''''''''''''''''''''''''''
' Close the file and return True.
'''''''''''''''''''''''''''''''''
CloseHandle FileHandle
SetFileDateTime = True

End Function


Public Function GetFileDateTime(FileName As String, _
        WhichDateToGet As FileDateToProcess, _
        Optional NoGMTConvert As Boolean = False) As Double
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetFileDateTime
' This function returns the Create, Last Accessed or Last Modified date/time
' of the specified file name. It returns -1 is an error occurred.
' The date to be retrieved is indicated in the WhichDateToGet parameter.
' Valid values for this are in the FileDateToProcess enum.
'
'        Public Enum FileDateToProcess
'            FileDateCreate = 1
'            FileDateLastAccess = 2
'            FileDateLastModified = 3
'        End Enum
'
' The function returns the requested date/time, or -1 if an error occurs.
'
' File times are GMT times. By default, the procedure converts the GMT time
' returned by GetFileTime to the local time. This is the default mode and
' will take place if NoGMTConvert is omitted or False. If NoGMTConvert is True,
' the file's date and time are NOT converted from GMT to local time. Since
' Windows converts to Local Time when displaying a file's date and time,
' this displayed value will not match value returned by this function.
' The value returned by this function will be N hours earlier (or later
' if you are East of GMT) than the file time displayed by Windows.
' It is recommended that you NOT set NoGMTConvert to True.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim FileHandle As Long
Dim Res As Long
Dim ErrNum As Long
Dim ErrText As String
Dim tFileTime As FileTime
Dim tLocalTime As FileTime
Dim tSystemTime As SYSTEMTIME
Dim ResultTime As Double


Const C_ERROR As Double = -1

''''''''''''''''''''''''''''''''''''
' Ensure the file exists.
''''''''''''''''''''''''''''''''''''
If Dir(FileName) = vbNullString Then
    GetFileDateTime = C_ERROR
    Exit Function
End If

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Here, we use CreateFile to open the existing file
' named in FileName.  The OPEN_EXISTING flag indicates
' that we are opening an existing flag.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
FileHandle = CreateFile(lpFilename:=FileName, dwDesiredAccess:=GENERIC_READ, _
    dwShareMode:=FILE_SHARE_READ Or FILE_SHARE_WRITE, lpSecurityAttributes:=ByVal 0&, _
      dwCreationDisposition:=OPEN_EXISTING, dwFlagsAndAttributes:=0, hTemplateFile:=0)
    
If FileHandle = INVALID_HANDLE_VALUE Then
    ''''''''''''''''''''''
    ' An error occurred.
    ''''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrorNumber:=ErrNum)
    Debug.Print "Error from SystemTimeToFileTime" & vbCrLf & _
        "Err:  " & CStr(ErrNum) & vbCrLf & _
        "Desc: " & ErrText
    GetFileDateTime = C_ERROR
    Exit Function
End If


Select Case WhichDateToGet
    Case FileDateCreate
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the GetFileTimeCreate flavor of GetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = GetFileTimeCreate( _
            hFile:=FileHandle, _
            CreateTime:=tFileTime, _
            LastAccessTime:=NULL_LONG, _
            LastModified:=NULL_LONG)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With GetFileTimeCreate (GetFileTime):" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            GetFileDateTime = C_ERROR
            Exit Function
        End If
    
    Case FileDateLastAccess
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the GetFileTimeLastAccess flavor of GetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = GetFileTimeLastAccess( _
            hFile:=FileHandle, _
            CreateTime:=NULL_LONG, _
            LastAccessTime:=tFileTime, _
            LastModified:=NULL_LONG)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With SetFileTimeLastAccess (SetFileTime):" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            GetFileDateTime = C_ERROR
            Exit Function
        End If
    
    Case FileDateLastModified
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the GetFileTimeLastModified flavor of GetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = GetFileTimeLastModified( _
            hFile:=FileHandle, _
            CreateTime:=NULL_LONG, _
            LastAccessTime:=NULL_LONG, _
            LastModified:=tFileTime)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With GetFileTimeLastModified (GetFileTime):" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            GetFileDateTime = C_ERROR
            Exit Function
        End If
    
    Case Else
        ''''''''''''''''''''''''''''''''''''''
        ' Invalid value for WhichDateToChange.
        ''''''''''''''''''''''''''''''''''''''
        Debug.Print "Invalid value for WhichDateToChange: " & CStr(WhichDateToGet)
        CloseHandle FileHandle
        GetFileDateTime = C_ERROR
        Exit Function

End Select

''''''''''''''''''''''''''''''''''''''''''''''
' Convert the FileTime (GMT) to LocalFileTime)
' if NoGMTConvert is omitted or False.
''''''''''''''''''''''''''''''''''''''''''''''
If NoGMTConvert = False Then
    Res = FileTimeToLocalFileTime(lpFileTime:=tFileTime, lpLocalFileTime:=tLocalTime)
Else
    '''''''''''''''''''''''''''''''''''''''''''''''''''
    ' We are NOT converting from GMT.
    '''''''''''''''''''''''''''''''''''''''''''''''''''
    tLocalTime.dwHighDateTime = tFileTime.dwHighDateTime
    tLocalTime.dwLowDateTime = tFileTime.dwLowDateTime
    Res = 2
End If
    
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToLocalFileTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    GetFileDateTime = C_ERROR
    Exit Function
End If



''''''''''''''''''''''''''''''''''''
' Convert the FileTime to SystemTime
''''''''''''''''''''''''''''''''''''
Res = FileTimeToSystemTime(lpFileTime:=tLocalTime, lpSystemTime:=tSystemTime)
If Res = 0 Then
    '''''''''''''''''''''
    ' An error occurred
    '''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrNum)
    Debug.Print "Error With FileTimeToSystemTime:" & vbCrLf & _
                "Err:  " & CStr(ErrNum) & vbCrLf & _
                "Desc: " & ErrText
    GetFileDateTime = C_ERROR
    Exit Function
End If

'''''''''''''''''''''''''''''''''
' Convert from SystemTime to VB
' Time value.
'''''''''''''''''''''''''''''''''
ResultTime = DateSerial(tSystemTime.wYear, tSystemTime.wMonth, tSystemTime.wDay) + _
             TimeSerial(tSystemTime.wHour, tSystemTime.wMinute, tSystemTime.wSecond)
    
'''''''''''''''''''''''''''''''''
' Close the file and return True.
'''''''''''''''''''''''''''''''''
CloseHandle FileHandle
GetFileDateTime = ResultTime

End Function


Public Function GetFileDateTimeAsFILETIME(FileName As String, _
  WhichDateToGet As FileDateToProcess, FTime As FileTime, _
  Optional ConvertFromGMT As Boolean = False) As Boolean
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetFileTimeAsFILETIME
' This function populates the FTime FILETIME structure with the file data
' specified by WhichDateToGet for the file FileName. Note that there
' is no conversion from GMT Time here
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim FileHandle As Long
Dim ErrNum As Long
Dim ErrText As String
Dim tFileTime As FileTime
Dim Res As Long
Dim tLocalFileTime As FileTime

Const C_ERROR As Boolean = False

''''''''''''''''''''''''''''''''''''
' Ensure the file exists.
''''''''''''''''''''''''''''''''''''
If Dir(FileName) = vbNullString Then
    GetFileDateTimeAsFILETIME = C_ERROR
    Exit Function
End If

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Here, we use CreateFile to open the existing file
' named in FileName.  The OPEN_EXISTING flag indicates
' that we are opening an existing flag.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
FileHandle = CreateFile(lpFilename:=FileName, dwDesiredAccess:=GENERIC_READ, _
    dwShareMode:=FILE_SHARE_READ Or FILE_SHARE_WRITE, lpSecurityAttributes:=ByVal 0&, _
      dwCreationDisposition:=OPEN_EXISTING, dwFlagsAndAttributes:=0, hTemplateFile:=0)
    
If FileHandle = INVALID_HANDLE_VALUE Then
    ''''''''''''''''''''''
    ' An error occurred.
    ''''''''''''''''''''''
    ErrNum = Err.LastDllError
    ErrText = GetSystemErrorMessageText(ErrorNumber:=ErrNum)
    Debug.Print "Error from SystemTimeToFileTime" & vbCrLf & _
        "Err:  " & CStr(ErrNum) & vbCrLf & _
        "Desc: " & ErrText
    GetFileDateTimeAsFILETIME = C_ERROR
    Exit Function
End If


Select Case WhichDateToGet
    Case FileDateCreate
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the GetFileTimeCreate flavor of GetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = GetFileTimeCreate( _
            hFile:=FileHandle, _
            CreateTime:=tFileTime, _
            LastAccessTime:=NULL_LONG, _
            LastModified:=NULL_LONG)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With GetFileTimeAsFILETIME:" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            GetFileDateTimeAsFILETIME = C_ERROR
            Exit Function
        End If
    
    Case FileDateLastAccess
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the GetFileTimeLastAccess flavor of GetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = GetFileTimeLastAccess( _
            hFile:=FileHandle, _
            CreateTime:=NULL_LONG, _
            LastAccessTime:=tFileTime, _
            LastModified:=NULL_LONG)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With GetFileTimeAsFILETIME:" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            GetFileDateTimeAsFILETIME = C_ERROR
            Exit Function
        End If
    
    Case FileDateLastModified
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        ' Call the GetFileTimeLastModified flavor of GetFileTime.
        '''''''''''''''''''''''''''''''''''''''''''''''''''
        Res = GetFileTimeLastModified( _
            hFile:=FileHandle, _
            CreateTime:=NULL_LONG, _
            LastAccessTime:=NULL_LONG, _
            LastModified:=tFileTime)
        If Res = 0 Then
            ErrNum = Err.LastDllError
            ErrText = GetSystemErrorMessageText(ErrNum)
            Debug.Print "Error With GetFileTimeAsFILETIME:" & vbCrLf & _
                        "Err:  " & CStr(ErrNum) & vbCrLf & _
                        "Desc: " & ErrText
            GetFileDateTimeAsFILETIME = C_ERROR
            Exit Function
        End If
    
    Case Else
        ''''''''''''''''''''''''''''''''''''''
        ' Invalid value for WhichDateToChange.
        ''''''''''''''''''''''''''''''''''''''
        Debug.Print "Invalid value for WhichDateToChange: " & CStr(WhichDateToGet)
        CloseHandle FileHandle
        GetFileDateTimeAsFILETIME = C_ERROR
        Exit Function
End Select

If ConvertFromGMT = False Then
    '''''''''''''''''''''''''''''''''''''''''''''''
    ' ConvertFromGMT is False, so we don't do any
    ' conversion from GMT. The value placed in FTime
    ' is a GMT value. Set the elements of the FTime
    ' variable that was passed in to this function.
    '''''''''''''''''''''''''''''''''''''''''''''''
    FTime.dwHighDateTime = tFileTime.dwHighDateTime
    FTime.dwLowDateTime = tFileTime.dwLowDateTime
Else
    '''''''''''''''''''''''''''''''''''''''''''''''
    ' ConvertFromGMT is True, so we must convert
    ' fFileTime from GMT to a local time value.
    ' Convert to local time and then set the elements
    ' of the FTime variable that was passed into
    ' this procedure.
    '''''''''''''''''''''''''''''''''''''''''''''''
    Res = FileTimeToLocalFileTime(lpFileTime:=tFileTime, lpLocalFileTime:=tLocalFileTime)
    If Res = 0 Then
        ErrNum = Err.LastDllError
        ErrText = GetSystemErrorMessageText(ErrNum)
        Debug.Print "Error With FileTimeToLocalFileTime:" & vbCrLf & _
                    "Err:  " & CStr(ErrNum) & vbCrLf & _
                    "Desc: " & ErrText
        GetFileDateTimeAsFILETIME = C_ERROR
        Exit Function
    End If
    FTime.dwHighDateTime = tLocalFileTime.dwHighDateTime
    FTime.dwLowDateTime = tLocalFileTime.dwLowDateTime
End If
'''''''''''''''''''''''''''''''''''''
' If we made it this far, we're
' successful so return True.
'''''''''''''''''''''''''''''''''''''

GetFileDateTimeAsFILETIME = True

End Function

Public Function CompareFileTimes(FileName1 As String, FileName2 As String, _
    WhichDate As FileDateToProcess) As Variant
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' CompareFileTimes
' This function compares the FILETIMES of two files, FileName1 and FileName2, and
' returns -1 if FileName1 has an earlier date than FileName2, 0 if the file
' dates are equal, or +1 if FileName1 has a later date than FileName2. It returns
' NULL if an error occurs.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim FT1 As FileTime
Dim FT2 As FileTime
Dim Res As Boolean


'''''''''''''''''''''''''''''''''''
' Ensure Files Exist
'''''''''''''''''''''''''''''''''''
If (Dir(FileName1) = vbNullString) Or (Dir(FileName2) = vbNullString) Then
    CompareFileTimes = Null
    Exit Function
End If
''''''''''''''''''''''''''''''''''
' Ensure we have a valid value for
' WhichDate.
''''''''''''''''''''''''''''''''''
Select Case WhichDate
    Case FileDateCreate, FileDateLastAccess, FileDateLastModified
    Case Else
        CompareFileTimes = Null
        Exit Function
End Select

Res = GetFileDateTimeAsFILETIME(FileName1, WhichDate, FT1, False)
If Res = False Then
    CompareFileTimes = Null
    Exit Function
End If


Res = GetFileDateTimeAsFILETIME(FileName2, WhichDate, FT2, False)
If Res = False Then
    CompareFileTimes = Null
    Exit Function
End If

''''''''''''''''''''''''''''''''''''''''''''
' Call CompareFileTime to get the result.
''''''''''''''''''''''''''''''''''''''''''''
CompareFileTimes = CompareFileTime(FT1, FT2)

End Function



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private support functions. The are support/utility functions  that
' are used by the main functions, but are not directly related to getting
' or setting file times.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Function GetFileSystemName(DriveLetter As String) As String
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetFileSystemName
' This function returns the name of the file system (e.g., "FAT" or
' "NTFS" of drive specified by DriveLetter. If an error occurs,
' it returns vbNullString.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim RootPath As String
Dim VolumeName As String
Dim SerialNumber As Long
Dim MaxCompLength As Long
Dim FileSystemName As String
Dim Res As Long
Dim Pos As Integer

''''''''''''''''''''''''''''''''''''
' Initialize strings
''''''''''''''''''''''''''''''''''''
VolumeName = String$(260, vbNullChar)
FileSystemName = String$(260, vbNullChar)

''''''''''''''''''''''''''''''''''''
' Get RootPath from DriveLetter
''''''''''''''''''''''''''''''''''''
If Len(Trim(DriveLetter)) = 1 Then
    RootPath = DriveLetter & ":\"
ElseIf InStr(DriveLetter, ":") And Len(DriveLetter) = 2 Then
    RootPath = DriveLetter & "\"
Else
    RootPath = DriveLetter
End If


If Trim(DriveLetter) = vbNullString Then
    GetFileSystemName = vbNullString
    Exit Function
End If

Res = GetVolumeInformation(RootPath, VolumeName, Len(VolumeName), _
    SerialNumber, MaxCompLength, 0&, FileSystemName, Len(FileSystemName))
If Res = 0 Then
    GetFileSystemName = vbNullString
    Exit Function
End If
    
Pos = InStr(FileSystemName, vbNullChar)
If Pos Then
    FileSystemName = Left(FileSystemName, Pos - 1)
End If
Pos = InStr(VolumeName, vbNullChar)
If Pos Then
    VolumeName = Left(VolumeName, Pos - 1)
End If

GetFileSystemName = FileSystemName

End Function


Public Function GetSystemErrorMessageText(ErrorNumber As Long) As String
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetSystemErrorMessageText
'
' This function gets the system error message text that corresponds
' to the error code returned by the GetLastError API function or the
' Err.LastDllError property.
'
' It may be used ONLY for these error codes. These are NOT the error numbers
' returned by Err.Number (for these errors, use Err.Description to get the
' description of the message). The error number MUST be the value returned by
' GetLastError or Err.LastDLLError.
'
' In general, you should use Err.LastDllError rather than GetLastError
' because under some circumstances the value of GetLastError will be
' reset to 0 before the value is returned to VB. Err.LastDllError will
' always reliably return the last error number raised in a DLL.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim ErrorText As String
Dim TextLen As Long
Dim FormatMessageResult As Long
Dim LangID As Long

' initialize the variables
LangID = 0&  'default language
ErrorText = String$(FORMAT_MESSAGE_TEXT_LEN, vbNullChar)
TextLen = Len(ErrorText)
On Error Resume Next
' Call FormatMessage to get the text of the error message
' associated with ErrorNumber.
FormatMessageResult = FormatMessage( _
                dwFlags:=FORMAT_MESSAGE_FROM_SYSTEM Or _
                         FORMAT_MESSAGE_IGNORE_INSERTS, _
                lpSource:=0&, _
                dwMessageId:=ErrorNumber, _
                dwLanguageId:=0&, _
                lpBuffer:=ErrorText, _
                nSize:=TextLen, _
                Arguments:=0&)
On Error GoTo 0
If FormatMessageResult = 0& Then
    ' An error occured. Display the error number, but
    ' don't call GetSystemErrorMessageText  to get the
    ' text, which would likely cause the error again,
    ' getting us into a loop.
    MsgBox "An error occurred with the FormatMessage" & _
        " API functiopn call. Error: " & _
        CStr(Err.LastDllError) & _
        " Hex(" & Hex(Err.LastDllError) & ")."
    GetSystemErrorMessageText = vbNullString
    Exit Function
End If
If FormatMessageResult > 0 Then
    ' success
    ' FormatMessage returned some text. Take the left
    ' FormatMessageResult characters and return that text.
    ErrorText = Left$(ErrorText, FormatMessageResult)
    GetSystemErrorMessageText = ErrorText
Else
    ' an error occurred
    ' Format message didn't return any text.
    ' There is no text description for the specified error.
    GetSystemErrorMessageText = "NO ERROR DESCRIPTION AVAILABLE"
End If

End Function





