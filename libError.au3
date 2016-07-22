#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.

	Error Handling. Parses errors and returns information

 MIT LICENSE

#ce ----------------------------------------------------------------------------

#include-once

;error main function
Func errorFun($errorCode)
	Switch $errorCode
		Case 1
			errorMsgBox("Error No config file")
		case 2
			errorMsgBox("Error Client Connection(s) failed")
		case else
			errorMsgBox("Unknown Error Occured, Please be vigilent")
	EndSwitch
EndFunc

Func errorMsgBox($Reason)
	MsgBox(0,$sProgramName,$Reason)
EndFunc

