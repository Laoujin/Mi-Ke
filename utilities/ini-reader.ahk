FileReplacements(fileName)
{
	; https://autohotkey.com/docs/Variables.htm#os
	StringReplace, fileName, fileName, <A_DESKTOP>, %A_DESKTOP%
	StringReplace, fileName, fileName, <A_TEMP>, %A_TEMP%
	StringReplace, fileName, fileName, <A_SCRIPTDIR>, %A_SCRIPTDIR%
	StringReplace, fileName, fileName, <USERPROFILE>, %USERPROFILE%
	StringReplace, fileName, fileName, <A_WINDIR>, %A_WINDIR%
	StringReplace, fileName, fileName, <A_PROGRAMFILES>, %A_PROGRAMFILES%
	StringReplace, fileName, fileName, <A_APPDATA>, %A_APPDATA%
	StringReplace, fileName, fileName, <A_MYDOCUMENTS>, %A_MYDOCUMENTS%
	return fileName
}


ReadMikeIni(sectionName, key, replacePaths := false)
{
	; TODO: IfNotExist mike.ini -> then pick mini.default.ini

	IniRead, value, %A_Scriptdir%\mike.ini, %sectionName%, %key%
	if (value = "ERROR") {
		MsgBox Error reading from ini. Section=%sectionName% Key=%key%

	} else {
		if replacePaths
			value := FileReplacements(value)
		return value
	}

}