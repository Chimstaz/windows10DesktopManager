#SingleInstance
if(! A_IsAdmin)
{
    ;dll calls window movers will not work without admin
    Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
    ExitApp
}

Rename() ;change process name to "unglue" from other ahk icons in tray -- Chimstaz
 /*
  * Alternatively you can use the hotkeyManager to set the hotkeys after the JPGIncDesktopManagerClass has been
  * constructed like this
  */
;added global to have access in commonFunctions
global globalDesktopManager := new JPGIncDesktopManagerClass()
globalDesktopManager.setGoToDesktop("Capslock")
    .setMoveWindowToDesktop("+#")
    .afterGoToDesktop("postSwitchDesktop")			;changed post function -- Chimstaz
    .afterMoveWindowToDesktop("postMoveWin")		;-"- -- Chimstaz
    .setGoToNextDesktop("Capslock & w")
    .setGoToPreviousDesktop("Capslock & q")
    .setMoveWindowToNextDesktop("Capslock & s")
    .setMoveWindowToPreviousDesktop("Capslock & a")
    ;~ .followToDesktopAfterMovingWindow(true)
	;~ .setCloseDesktop("Capslock & x")
	;~ .setNewDesktop("Capslock & n")

;Author of changes: Chimstaz
;allow to post message 0x2000 from not elevated process
;I added message 0x2000 to inform script that desktop might changed
;My another script can change desktops
DllCall("ChangeWindowMessageFilter","UInt",0x2000,"UInt",1) ; 1 == MSGFLT_ADD
OnMessage(0x2000, "showDesktopNumber")
showDesktopNumber()
;end of changes

return

#c::ExitApp

#Include desktopManager.ahk
#Include desktopChanger.ahk
#Include windowMover.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include hotkeyManager.ahk
#Include commonFunctions.ahk
#Include dllWindowMover.ahk


;copied from https://autohotkey.com/boards/viewtopic.php?f=6&t=21817  -- Chimstaz

Rename(NewName:="", reloading:=0)
{
	if NewName
		NewName.= RegExMatch(NewName,"\.exe$") ? "":".exe"
	else
		NewName := RegExReplace(A_ScriptName,"\.ahk$",".exe") ;-- Grabs current script name (script.ahk)

	SplitPath, A_AHKPath, Name, AHKDir
	AHKDir.="\"
	AHK_CB_Dir := AHKDir . NewName ;--Appends the current script's name with EXE extension to the AHK path
	AHK_AH_Dir := AHKDir . "AutoHotkey.exe" ;-- Build default AHK path
	;MsgBox, % Name "`n" NewName
 	If (Name != NewName || reloading) ;-- Tests to see if script name matches AHK name
 	{
 		FileMove, %AHK_AH_Dir%, %AHK_CB_Dir% ;-- Renames AutoHotkey.exe to current script.exe
 		If ErrorLevel ;-- Unable to rename?
  		{
 			MsgBox, Unable to rename AutoHotkey.exe
 			Run, %AHKDir%
 			ExitApp
 		}

		IfExist, %AHK_CB_Dir% ;-- Verifies new AHK executable is in place
 			Run, % AHK_CB_Dir " " RegExReplace(A_ScriptFullPath,"([ ]+)","""$1"""), UseErrorLevel ;-- Reloads script via new AHK name

  		If ErrorLevel ;-- Unable to run new ahk name?
  		{
  			MsgBox, Error running %A_ScriptFullPath%
  			FileMove, %AHK_CB_Dir%, %AHK_AH_Dir%
  			ExitApp
		}
		ExitApp ;-- Ensures rest of code does not run after
	}
 	else ;-- AHK path matches script name
	{
		FileMove, %A_AHKPath%, %AHKDir%AutoHotkey.exe ;-- Renames AHK back to AutoHotkey.exe
		If ErrorLevel ;-- Unable to rename?
		{
			MsgBox, Unable to rename %NewName%
			Run, %AHKDir%
			ExitApp
		}
		Menu,Tray,Add,Reload renamed script,Rename_Reload
  	}
	return
	Rename_Reload:
		SplitPath, A_AHKPath, exeName
		Rename(exeName,1)
	return
}
