' Pre-commit hook by msangel (msangel.com.ua) (c) 2014 
' This software is provided "as is", without warranty of any kind.
' License: Apache Public License V2, see "LICENSE" file for details.
' Fresh copy always available here: https://github.com/msangel/version-to-files-svn-pre-commit-hook

' rewrited by timhok

pathToRootOfSVNRepo = "D:\home\source_code\"
pathToWatchingDirectory = "D:\home\source_code\hooktest"
whereToWriteArr = Array ("D:\home\source_code\hooktest\1.txt", "D:\home\source_code\hooktest\2.txt")



' Directive
On Error Resume Next

Set fso = CreateObject ("Scripting.FileSystemObject") 
Set stderr = fso.GetStandardStream(2) 

Sub handleError(message)
	stderr.WriteLine "Message: " & message
	If Not(Err.Number = 0) Then
		stderr.WriteLine "Description: " &  Err.Description
		stderr.WriteLine "Source: " &  Err.Source
		Err.Clear
	End If
	Wscript.quit(1)
End Sub

count = WScript.Arguments.Count
If count = 0 Then
	WScript.Echo "This is pre-commit hook by msangel, open it source for configure and more details."
	Wscript.quit(0)
elseif count < 3  Then
	WScript.Echo "Wrong usage. Script expect at least 3 args. Please check usage and if all correct  - contact author."
	Wscript.quit(0)
End If

workingDir =  WScript.Arguments.Item(3) 
' this is checking before

pathToRootOfSVNRepo = fso.GetAbsolutePathName(pathToRootOfSVNRepo)
If Not(Err.Number = 0) Then handleError("Can not get absolute path name for pathToRootOfSVNRepo: " & pathToRootOfSVNRepo & " , please set this variable as absolute path")
If Not(fso.FolderExists(pathToRootOfSVNRepo)) Then handleError("This pathToRootOfSVNRepo is not exist: " & pathToRootOfSVNRepo & " , but it must exist, fix your settings in script or check this folder if exist")


pathToWatchingDirectory = fso.GetAbsolutePathName(pathToWatchingDirectory)
If Not(Err.Number = 0) Then handleError("Can not get absolute path name for pathToWatchingDirectory: " & pathToWatchingDirectory & " , please set this variable as absolute path")
If Not(fso.FolderExists(pathToWatchingDirectory)) Then handleError("This pathToWatchingDirectory is not exist: " & pathToWatchingDirectory & " , but it must exist, fix your settings in script or check this folder if exist")



If Len(workingDir) > Len(pathToWatchingDirectory) Then  workingDir = Left(workingDir, Len(pathToWatchingDirectory))
	' workingDir is bigger then pathToWatchingDirectory, so make it shorter

' if our real working dir is equals to that is in settings
'       (where to search        ,what search)
If InStr(pathToWatchingDirectory,workingDir) = 1 Then
	' Yes, it is in our directory, script is working
	' just continue
Else
	' No, it is NOT in our directory, script is NOT working, but commit will do
	Wscript.quit(0)
End If





' Create working objects
Set objShell = WScript.CreateObject("WScript.Shell")
Set regEx = New RegExp
regEx.Pattern = "Last committed at revision (\d+)"
strText = ""
strRev = ""


' Get version
Set objExecObject = objShell.Exec("cmd /c subwcrev "& pathToRootOfSVNRepo)
Do While Not objExecObject.StdOut.AtEndOfStream
	line = objExecObject.StdOut.ReadLine()
	
	If regEx.test(line) Then
		Set matches = regEx.Execute(line)
		strRev = matches(0).SubMatches(0)
    End If
	strText = strText & line & vbNewLine
Loop

If Len(strText) = 0 Then handleError("Problem with subwcrev - check if you have it in environment")



' Checking
If Len(strRev) = 0 Then handleError("Revision number can not be found. Be sure you set pathToRootOfSVNRepo to real repo or check environment, More details: " & strText)

rev = CInt(strRev)
rev = rev + 1

needToWrite = False
For Each currentFile In whereToWriteArr

	If  Not(fso.FileExists(currentFile)) Then
		strFileText = "0" ' avoid reading empty file and skip checking for empty file content in future
	ElseIf fso.GetFile(currentFile).Size = 0 Then
		strFileText = "0" ' skip checking for empty file content in future
	Else
		Set objFileToRead = fso.OpenTextFile(currentFile,1)
		strFileText = objFileToRead.ReadAll()
		objFileToRead.Close
		If Not(Err.Number = 0) Then
			handleError("File "& currentFile & "already exist, but before writting to it we must check content, though file cannot be read")
		End If
	End If



	If Not(IsNumeric(strFileText)) Then
		handleError("File "& currentFile & " already contain not only number, exiting to prevent any bad things, be sure file (already contain ONLY number) OR  (is empty) OR (even not exist)")
	End If
	
		
	If Not(CInt(strFileText) = rev) Then
		' File not contain latest revision
		needToWrite = True
	End If
Next

If Not(needToWrite) Then
	' We do not need to write files as far as there are already latests versions
	If Not(Err.Number = 0) Then
		' but will check for error before, if one
		handleError("Unexpected error")
	End If
	Wscript.quit(0)
End If


' Writting
For Each currentFile In whereToWriteArr
	Set objFileToWrite = fso.OpenTextFile(currentFile,2,true)
	If Not(Err.Number = 0) Then
		handleError("Can not open file " & currentFile & " for writing.")
	End If
	objFileToWrite.WriteLine(rev)
	objFileToWrite.Close
	If Not(Err.Number = 0) Then
		handleError("Can not write to file " & currentFile)
	End If
Next

If Not(Err.Number = 0) Then
	handleError("Unexpected error")
End If
	
' Return 'ok' code
Wscript.quit(0)

