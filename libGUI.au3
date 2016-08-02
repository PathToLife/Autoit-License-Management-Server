#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.

	Graphical user interface Script

 MIT LICENSE

 Control Fucntion WIKI https://www.autoitscript.com/autoit3/docs/functions/GUICtrlUpdate%20Management.htm
 Create Funtction WIKI https://www.autoitscript.com/autoit3/docs/functions/GUICtrlCreateEdit.htm

#ce ----------------------------------------------------------------------------

#include-once

#include <GUIConstantsEx.au3> ; GUI Functions
#Include <GUIEdit.au3> ; GUI Edit
#include <EditConstants.au3> ; GUICtrlCreateEdit Func for editing GUI Constants
#Include <ScrollBarConstants.au3> ; GUI Scroll Settings
#include <Date.au3> ; Date and time
#include <MsgBoxConstants.au3> ; MSG boxes
#include <WindowsConstants.au3> ; Windows Fourms

; Program variables, Dim will reuse/overwrite global variables if set
Dim $g_bCloseConfim = False ; Show Close Confirm MsgBox
Dim $g_bShowDate = False ; Show date in console
Dim $g_MainWinW = 500 ; Main window width
Dim $g_MainWinH = 600 ; Main window height

;-- For running gui standalone, testing purposes
If Not IsDeclared("sProgramName") Then

	Global $sProgramName = "!NOTE! GUI TEST ONLY MODE"

	$bTestMode = True ; A way for close loop to choose how to handle exit

	startGUI()

	For $i = 0 to 40
		GUIConsoleOut("GUI standalone TEST")
	Next

	GUIConsoleOut("fjfkl;jel;kfjwlek;jfl;weqjl;fjlew;jfkljwelkqjfklwqjel;fjwelq;kfjl;wejfklewfl;weqnfkewmlckewjklqflkwe;fckl;wejflkjwlek")

	While 1
		Sleep(100)
	WEnd
EndIf

;-----------------------------GUI-----------------------------

Func startGUI()
	Opt("GUIOnEventMode", 1) ; Change to OnEvent mode



	; --- Interface Modules ---
	Local $mainGUI = GUICreate($sProgramName, $g_MainWinW, $g_MainWinH) ; X Width, Y Width

	; -- Labels --
	Global $g_labelConsole = GUICtrlCreateLabel("Console Output", 20, 40) ;x,y
	Global $g_labelIP = GUICtrlCreateLabel("Server: Not Ready", 10, $g_MainWinH - 20, $g_MainWinW - 40)

	; -- Buttons --
	Local $iOKButton = GUICtrlCreateButton("Test Console", 380, 20, 100, 30) ; X Cord, Y Cords, X Width, Y Width
	Local $iClientsButton = GUICtrlCreateButton("Clients", 380, 380, 100, 30)

	; -- Text Fields --
	Global $g_idOutputEdit = GUICtrlCreateEdit("", 20, 60, $g_MainWinW - 40, 300, $GUI_SS_DEFAULT_EDIT + $ES_READONLY) ; X Cord, Y Cords, X Width, Y Width

	; -- Check Boxes --
	Global $g_idCheckbox = GUICtrlCreateCheckbox("Show Date", 20, 360)

	; GUI Interrupts to run functions on click
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
	GUICtrlSetOnEvent($iOKButton, "OKButton") ; Testing purposes currently
	GUICtrlSetOnEvent($g_idCheckbox, "DATECheckbox") ; redundant for no since we use _IsChecked($GUIid)

	; Control GUI module data
	GUICtrlSetState($g_idCheckbox, $g_bShowDate)

	;Show GUI
	GUISetState(@SW_SHOW, $mainGUI)


EndFunc

; -- Control Functions --

; Scrolls and adds text to console output
; Thanks to Melba23 for scroll code on Autoit Fourms
Func GUIConsoleOut($sText)


	$iEnd = StringLen(GUICtrlRead($g_idOutputEdit))
	_GUICtrlEdit_SetSel($g_idOutputEdit, $iEnd, $iEnd)
	_GUICtrlEdit_Scroll($g_idOutputEdit, $SB_SCROLLCARET)

	GUIConsoleOutID($g_idOutputEdit, $sText) ; Calls the function below with ID of edit box and text
EndFunc

; Adds text with date and time if checked to the defined GUI edit box
Func GUIConsoleOutID($gID, $sText)

	Local $sOutput = _NowTime(5); 5 = 24 hr + sec, 3 = default

	If _IsChecked($g_idCheckbox) Then
		$sOutput = $sOutput & " " & _NowDate() ; Add date if checked
	EndIf

	$sOutput = $sOutput & " - " & $sText; Append log text to end of output string

	GUICtrlSetData($gID,$sOutput & @LF, 1)
EndFunc

Func OKButton()
    ; Note: At this point @GUI_CtrlId would equal $iOKButton,
    ; and @GUI_WinHandle would equal $hMainGUI
    ; MsgBox($MB_OK, "GUI Event", "Ok was clicked")

	GUIConsoleOut("Test")

EndFunc   ;==>OKButton

Func CLOSEButton()
    ; Note: At this point @GUI_CtrlId would equal $GUI_EVENT_CLOSE,
    ; and @GUI_WinHandle would equal $hMainGUI

	If $g_bCloseConfim Then
		$ans = MsgBox($MB_OKCANCEL, "Confirm", "Are you sure you want to close license server?", 5)
		If $ans = 1 Then
			Exit
		EndIf
	Else
		Exit
	EndIf

EndFunc   ;==>CLOSEButton

Func DATECheckbox()
	$g_bShowDate = _IsChecked($g_idCheckbox)
EndFunc

; -- GUI Control Helper functions --

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

;-----------------------------END_GUI-----------------------------