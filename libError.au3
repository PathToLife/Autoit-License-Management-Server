#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.

	Error Handling. Parses errors and returns information

 MIT LICENSE

#ce ----------------------------------------------------------------------------

#include-once

If Not IsDeclared("sProgramName") Then

	Global $sProgramName = "!NOTE! TEST ONLY MODE"

EndIf

;error main function
Func errorFun($errorCode)
	Switch $errorCode
		case 1
			errorMsgBox("Error No config file")
		case 2
			errorMsgBox("Error Client Connection(s) failed")
		case 3
			errorMsgBox("Error Unable to Intialize Socket")
		case 4
			errorMsgBox("Listening Socket taken, unable to use")
		case else
			errorMsgBox("Unknown Error Occured, Please be vigilent")
	EndSwitch
EndFunc

Func errorMsgBox($Reason)
	MsgBox(0,$sProgramName,$Reason)
EndFunc

