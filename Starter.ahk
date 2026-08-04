#Requires AutoHotkey v2.0
#SingleInstance Force

global MainScriptName := "CustomSkillPanel.ahk"
global L2Class := "ahk_class (?i)^L2UnrealWWindowsViewportWindow$"

TraySetIcon(A_ScriptDir "\resources\StarterIco.ico", 1)
A_IconTip := "Starter for L2_Skill_Panel"

; Режим поиска окон RegEx для случая использования сторонних лоунчеров, которые меняют имя класса окна (например ZZapuskatr.exe меняет L2UnrealWWindowsViewportWindow (заглавную L) на l2UnrealWWindowsViewportWindow)
SetTitleMatchMode "RegEx"
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
    ; Так как глобально включен RegEx, экранируем точку через \ и ищем скрытый класс AutoHotkey без учета регистра
    if WinExist("CustomSkillPanel\.ahk ahk_class (?i)^AutoHotkey$") {
        PostMessage(0x0012, 0, 0,, "CustomSkillPanel\.ahk ahk_class (?i)^AutoHotkey$")
        WinWaitClose("CustomSkillPanel\.ahk ahk_class (?i)^AutoHotkey$", , 1)
    }
}
