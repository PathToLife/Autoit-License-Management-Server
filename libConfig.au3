#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.

	Parses files from directory, if not found will load defaults

	Also allows logging

 MIT LICENSE

#ce ----------------------------------------------------------------------------

#include-once

; Dependancies
#include <File.au3> ; For doing operations on files
#include <FileConstants.au3> ; Constants to be included in an AutoIt v3 script when using File functions. Modifying these will change the operation of the File Functions.

$cmProgramName = "Config File Reader"
$bShowComplete = False


Func CONFIGStart()

	Local $strFilesCreated = ": "
	Local $iCreated = 0

	; Start Checking files

	If not FileExists(@ScriptDir&"\autoLicense-config.txt") Then
		$iCreated += 1
		$strFilesCreated = $strFilesCreated & "config, "

		If Not _FileCreate(@ScriptDir&"\autoLicense-config.txt") Then
			MsgBox($MB_SYSTEMMODAL, "Error", " Error Creating Config Files, Directory must be Writable. error:" & @error)
		EndIf

	EndIf

   ; Empty the Msg Box string for files created.
	If $iCreated = 0 then
		$strFilesCreated = ""
	EndIf

	If $bShowComplete then
		MsgBox(0,$sProgramName, "File check completed"&@CRLF&@ScriptDir&@CRLF&"Created "&$iCreated&" Files"&$strFilesCreated)
	EndIf
EndFunc