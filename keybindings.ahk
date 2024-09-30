#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1

#Include VD.ah2
VD.animation_on:=false

global USERPROFILE := EnvGet("USERPROFILE")

; Activate start menu with ctrl+alt+space:
#d Up::Send "{Control Up}{Alt Up}{LWin}" 
; Disables start menu from activating on a single press:
~LWin::Send "{Blind}{vkE8}" 
; Rebind Appskey (menu key) to LWin and stop it from activating:
AppsKey::
{
	Send "{LWin down}"
	KeyWait "AppsKey"
	Send "{Ctrl down}{LWin up}{Ctrl up}"
}

#1::VD.goToDesktopNum(1)
#2::VD.goToDesktopNum(2)
#3::VD.goToDesktopNum(3)
#4::VD.goToDesktopNum(4)
#5::VD.goToDesktopNum(5)
#6::VD.goToDesktopNum(6)
#7::VD.goToDesktopNum(7)
#8::VD.goToDesktopNum(8)
#9::VD.goToDesktopNum(9)
#0::VD.goToDesktopNum(10)

#+1::VD.MoveWindowToDesktopNum("A",1)
#+2::VD.MoveWindowToDesktopNum("A",2)
#+3::VD.MoveWindowToDesktopNum("A",3)
#+4::VD.MoveWindowToDesktopNum("A",4)
#+5::VD.MoveWindowToDesktopNum("A",5)
#+6::VD.MoveWindowToDesktopNum("A",6)
#+7::VD.MoveWindowToDesktopNum("A",7)
#+8::VD.MoveWindowToDesktopNum("A",8)
#+9::VD.MoveWindowToDesktopNum("A",9)
#+0::VD.MoveWindowToDesktopNum("A",0)

VD.RegisterDesktopNotifications()
VD.DefineProp("CurrentVirtualDesktopChanged", {Call:CurrentVirtualDesktopChanged})
VD.previous_desktopNum:=1
CurrentVirtualDesktopChanged(desktopNum_Old, desktopNum_New) {
  VD.previous_desktopNum:=desktopNum_Old
}
#Tab::VD.goToDesktopNum(VD.previous_desktopNum)

#\::
{   
  Send "{LWin Down}{Tab}"          
  KeyWait "LWin"  ; Wait to release left Win key
  Send "{LWin Up}" ; Close switcher on hotkey release
}

; MICROSOFT WINDOWS ACTIONS

; session control gui
SysAct := Gui()
SysAct.Title := "System Management Options"
SysAct.Opt("+ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
SysAct.SetFont("s12")
SysAct.Add("Text", , "Choose an Action:")

ShutdownSys := SysAct.AddButton("Default w450", "[&S] Shutdown")
RebootSys:= SysAct.AddButton("w450", "[&R] Reboot")
Logoff:= SysAct.AddButton("w450", "[&O] Logoff")
LockSys:= SysAct.AddButton("w450", "[&L] Lock")

ShutdownSys.OnEvent("Click", p1)
RebootSys.OnEvent("Click", p2)
Logoff.OnEvent("Click", p0)
LockSys.OnEvent("Click", Lock)
SysAct.OnEvent("Escape", CloseWithEscape)

p1(*) {
  Shutdown 1
}
p2(*) {
  Shutdown 2
}
p0(*) {
  Shutdown 0
}
; need to re-enable lockworkstation in registry for this to work
; https://techlogon.com/how-to-change-permissions-of-a-registry-key/
Lock(*) {
RegWrite 0, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation"
WinClose(WinGetTitle("A")) ;close session control gui before locking
DllCall("LockWorkStation")
Sleep(1000) ; without delay regWrite will swap back to value 1 before locking can take place
RegWrite 1, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation"
}
CloseWithEscape(*) {
  WinClose(WinGetTitle("A"))
}

#Backspace::
{
SysAct.Show
; WinSetStyle "-0xC00000", "A" ; Disable titlebar, causes windows to offset a little
}

#b::HideShowTaskbar()


HideShowTaskbar() {
    static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
    static hide := 0
    hide := !hide
    APPBARDATA := Buffer(size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
    NumPut("UInt", size, APPBARDATA), NumPut("Ptr", WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
    NumPut("UInt", hide ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
    DllCall("Shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", APPBARDATA)
}

#f::Send "{F11}"


#Enter::Run "wt.exe"

; browser lol
#w:: 
{
	Run USERPROFILE . "\scoop\apps\firefox\current\firefox.exe"
	WinWait("Mozilla Firefox")
	WinActivate
}
; file explorer with user home directory
#r:: Run Format("explorer.exe {1}", USERPROFILE)
; screenshot app
+PrintScreen:: Run "SnippingTool.exe"
; system run
#+d:: Run USERPROFILE . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\Run.lnk"

TrayTip "Hotkeys initialized", "Keybindings", 16
SetTimer HideTrayTip, -3000
HideTrayTip() {
    TrayTip
}

;#q::WinClose(WinGetTitle("A"))

#j::Send "{Alt down}{Esc}{Alt up}" 
#k::Send "{Alt down}{Shift down}{Esc}{Alt up}{Shift up}" 
#+m::Send "{Volume_Mute}"

; activate keyboard layers
Run("kanata.exe -p 1337 --cfg " . USERPROFILE . "\.config\kanata\config.kbd", , "Hide")
;Run("C:\Users\Null\.config\kanata\kanata_helper_daemon.exe --port=1337 --config-file='C:\Users\Null\.config\kanata\config.kbd' --default-layer=default", , "Hide")
Run "C:\Users\Null\.config\kanata\kanata_helper_daemon.exe -p 1337 --config-file=C:\Users\Null\.config\kanata\config.kbd --default-layer=default",, "Hide"
