#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Sean Zeng

 Script Function:
	Server for passing license information to network clients via udp.
	Main Loop

 MIT LICENSE

 func WIKI: https://www.autoitscript.com/wiki/Function_list
 good coding practises: https://www.autoitscript.com/wiki/Best_coding_practices

#ce ----------------------------------------------------------------------------

; Program variables
Global $sProgramName = "MegaWeb License Server" ; Name of server for GUI and clients to recieve
Global $sServerIP = "192.168.88.241:3347" ; IP for license Server
Global $numconditions = 20

; Dependancies
#include <File.au3> ; For doing operations on files
#include <FileConstants.au3> ; Constants to be included in an AutoIt v3 script when using File functions. Modifying these will change the operation of the File Functions.
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3> ; Same as above but for MSG boxes
#include <WinAPIFiles.au3> ; Win API for UDP communications

#include <WindowsConstants.au3>

; Program Function Scripts from working directories
#include "libConfig.au3" ; Includes Configuration file writer
#include "libGUI.au3" ; Includes GUI
#include "libError.au3" ; Includes Error Msg boxes etc

; Main Loop

ProgramStart()
Func ProgramStart()

   ; Read config information from config.txt
   ; uses @WorkingDir to find the file
   cmStart()

   ; GUI start
   StartGUI()

EndFunc

;-----------------------------MAIN_LOOP-----------------------------

While 1
   Sleep(100); Sleep to save CPU Usage
WEnd

#cs--
For $i = 0 to $numconditions
	;do somthing
ExitLoop
Next

;If statement
If $numconditions = 1 then
	errorFun(0);
Endif

#ce--
