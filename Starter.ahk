#Requires AutoHotkey v2.0
#SingleInstance Force

global MainScriptName := "CustomSkillPanel.ahk"
global L2Class := "ahk_class L2UnrealWWindowsViewportWindow"

TraySetIcon(A_ScriptDir "\resources\StarterIco.ico", 1)
A_IconTip := "Starter for L2_Skill_Panel"

SetTitleMatchMode 2
DetectHiddenWindows(True)

SetTimer(MonitorGameExit, 3000)

#HotIf WinActive(L2Class)
    ^+z:: StartPanel(1)
    ^+x:: StartPanel(2)
    ^+c:: StartPanel(3)
    ^+v:: StartPanel(4)
    ^+b:: StartPanel(5)
    ^+n:: StartPanel(6)
    ^+m:: StartPanel(7)
#HotIf

StartPanel(AccountPanel) {
    if !WinExist(L2Class)
        return

    if (A_ThisHotkey == A_PriorHotkey && A_TimeSincePriorHotkey < 250)
        return

    KillPanel()

    CapsLockState := GetKeyState("CapsLock", "T") ? 1 : 0

    try {
        Run(A_AhkPath ' "' A_ScriptDir '\' MainScriptName '" ' AccountPanel ' ' CapsLockState)
    }
}

MonitorGameExit() {
    if !WinExist(L2Class)
        KillPanel()
}

KillPanel() {
    if WinExist(MainScriptName " ahk_class AutoHotkey") {
        PostMessage(0x0012, 0, 0,, MainScriptName " ahk_class AutoHotkey")
        WinWaitClose(MainScriptName " ahk_class AutoHotkey", , 1)
    }
}