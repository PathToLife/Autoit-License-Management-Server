#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.

	Graphical user interface Script

 MIT LICENSE

#ce ----------------------------------------------------------------------------

#include-once

#include <GUIConstantsEx.au3> ; GUI Functions
#include <EditConstants.au3> ; GUICtrlCreateEdit Func for editing GUI Constants
#include <MsgBoxConstants.au3> ; MSG boxes

; Program variables
$bNoCloseConfim = True ; Stop Close Confirm MsgBox

;-- For running gui standalone, testing purposes
If Not IsDeclared("sProgramName") Then

	Global $sProgramName = "!NOTE! GUI TEST ONLY MODE"

	startGUI()
	While 1
		Sleep(100)
	WEnd
EndIf

;-----------------------------GUI-----------------------------

Func startGUI()
	Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

	Local $mainGUI = GUICreate($sProgramName, 500, 600) ; X Width, Y Width

	; --- Interface Modules ---

	; -- Labels --
	GUICtrlCreateLabel("Console Output", 20, 40) ;x,y

	; -- Buttons --
	Local $iOKButton = GUICtrlCreateButton("OK", 380, 20, 100, 30) ; X Cord, Y Cords, X Width, Y Width

	; -- Text Fields --
	Global $g_idOutputEdit = GUICtrlCreateEdit("", 20, 60, 460, 150, $ES_READONLY) ; X Cord, Y Cords, X Width, Y Width

	; GUI Interrupts to run functions on click
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
	GUICtrlSetOnEvent($iOKButton, "OKButton")

	; Control GUI module data
	GUICtrlSetData($g_idOutputEdit, "Test information"&@CRLF&"12345678") ; Set the output box with the encrypted text.

	;Show GUI
	GUISetState(@SW_SHOW, $mainGUI)
EndFunc

Func OKButton()
    ; Note: At this point @GUI_CtrlId would equal $iOKButton,
    ; and @GUI_WinHandle would equal $hMainGUI
    MsgBox($MB_OK, "GUI Event", "Ok was clicked")
EndFunc   ;==>OKButton

Func CLOSEButton()
    ; Note: At this point @GUI_CtrlId would equal $GUI_EVENT_CLOSE,
    ; and @GUI_WinHandle would equal $hMainGUI

	If $bNoCloseConfim = False Then
		$ans = MsgBox($MB_OKCANCEL, "Confirm", "Are you sure you want to close license server?", 5)
		If $ans = 1 Then
			Exit
		EndIf
	Else
		Exit
	EndIf

EndFunc   ;==>CLOSEButton

;-----------------------------END_GUI-----------------------------