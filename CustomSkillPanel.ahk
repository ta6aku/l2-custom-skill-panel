#Requires AutoHotkey v2.0
#SingleInstance Force
#include "lib\ImagePut.ahk"
#Include "lib\FindText.ahk"
#Include "lib\Gdip_All.ahk"
#Include "lib\OCR.ahk"

global DEBUG_MODE := false
global LogFile := FileOpen(A_ScriptDir "\debug_log.txt", "a")

global isSoundDisable := false
global GIF := false
global NoIntegr := false

IsReady := false

/*
global DigitsPatterns := "|<1>**50$8.03loF7Eo51EI51k0U"
global DigitsPatterns .= "|<2>**50$9.03yMmuLHqBXQLm2Tk0U"
global DigitsPatterns .= "|<3>**50$9.03yMmuTF6DHuLH6Tk0U"
global DigitsPatterns .= "|<4>**50$9.00wAVaOnKKm2Skq3U0U"
global DigitsPatterns .= "|<5>**50$9.03yEGyLm6THuLH6Tk0U"
global DigitsPatterns .= "|<6>**50$9.03wMWwLm6LGuLH6Tk0U"
global DigitsPatterns .= "|<7>**50$9.03yEHu2kq6kg5Ug700U"
global DigitsPatterns .= "|<8>**50$9.03yMmuLH6LGeLH6Tk0U"
global DigitsPatterns .= "|<9>**50$9.03yMmuLGuMHuLH6Tk0U"
global DigitsPatterns .= "|<10>**50$13.007zbMm/dpIOe5J2eVLEgMTw00U"
*/

global DigitsPatterns := "|<1>*138$12.zzzzzTwTzTzTzTzTzTzTzzzzU"
global DigitsPatterns .= "|<2>*138$12.zzzzyDxrxrzjzTyzxzw7zzzzU"
global DigitsPatterns .= "|<3>**50$12.003s6A5o7o2A3o7I5o6A3s00U"
global DigitsPatterns .= "|<4>*138$12.zzzzzDzDyjyjxjw7zjzjzzzzU"
global DigitsPatterns .= "|<5>*138$12.zzzzw7xzxzwDzrzrxryDzzzzU"
global DigitsPatterns .= "|<6>*138$12.zzzzyDxzxzwDxrxrxryDzzzzU"
global DigitsPatterns .= "|<7>*138$12.zzzzw7zrzjzjzjzTzTzTzzzzU"
global DigitsPatterns .= "|<8>*138$12.zzzzyDxrxryDxrxrxryDzzzzU"
global DigitsPatterns .= "|<9>*138$12.zzzzyDxrxrxry7zrxryDzzzzU"
global DigitsPatterns .= "|<10>*136$12.zzzzv7Wvuvuvuvuvuvv7zzzzU"

global IsPanelHorizontal := true
global PanelPosX := 0
global PanelPosY := 0
global PanelWidth := 0
global PanelHeight := 0

global gamePanelNum := 1
global slot := 0
global isAutoSSAnimated := false

global mPosX := 0
global mPosY := 0

global x1 := 0
global y1 := 0

; A_Args[1] - Config_XXX.ini from Starter.ahk (z=1,x=2,c=3,v=4...)
; A_Args[2] - CapsLock state from Starter.ahk
AccountPanel := (A_Args.Length >= 1) ? A_Args[1] : 1
LastCapsLockState := (A_Args.Length >= 2) ? A_Args[2] : 0

IniPath := A_ScriptDir "\config" AccountPanel ".ini"
if !FileExist(IniPath) {
    IniPath := A_ScriptDir "\config.ini"
}

DEBUG_MODE := Number(IniRead(IniPath, "Options", "DEBUG_MODE"))

(DEBUG_MODE) && LogDebug(Format("`n*****************************************************************`n******************************СТАРТ******************************`n*****************************************************************`nCustom Panel Config Path:`n " A_ScriptDir "\" IniPath))
(DEBUG_MODE) && LogDebug("Считываем параметры из ini файла:")

isSoundDisable := Number(IniRead(IniPath, "Options", "DisableSound"))
GIF := Number(IniRead(IniPath, "Options", "GIF"))
NoIntegr := Number(IniRead(IniPath, "Options", "NoSetParent"))

(DEBUG_MODE) && LogDebug(Format("`nisSoundDisabled: {1}, isGIF: {2}, isNoIntegration: {3}`n", isSoundDisable, GIF, NoIntegr))

;------------------------------------------------------------------------------------------------------

aActionType := Array()
aActionType.Length := 10
; 0 - empty
; 1 - skill or usable item
; 2 - several actions from another panel (for example to wear upper body, lower body and helmet)
; 3 - chat
try {
	Loop 10 {
		idx := A_Index
		val := IniRead(IniPath, "Actions", "action" . idx)
		Parts := StrSplit(val, ";")

		switch Parts[1] {
			case "null":		aActionType[idx] := [0, 0]
			case "Single":		aActionType[idx] := [1, 0]
			case "Equipment":	aActionType[idx] := [2, Parts[2], Parts[3]] ; Parts[2] = panel num, Parts[3] = cells nums
			case "Chat":		aActionType[idx] := [3, Parts[2], Parts[3]] ; Parts[2] = repeat times, Parts[3] = String
		}
	}
} catch Error as err {
	MsgBox("Config file not found or corruped.", "Error", 0x10)
	ExitApp
}

(DEBUG_MODE) && LogDataArray(aActionType, "aActionType")

;------------------------------------------------------------------------------------------------------

aIconsData := []
ext := (GIF) ? ".agif" : ".webp"
try {
	Loop 10 {
		idx := A_Index
		value := IniRead(IniPath, "Icons", "icon" . idx)


		switch {
			case InStr(value, "\Toggles\"):
				ovlPath := "resources\Overlays\toggle" ext
				dur := 0

			case InStr(value, "\Buff_scrolls\"):
				ovlPath := "resources\Overlays\timer_15min" ext
				dur := 900000

			case InStr(value, "etc_antidote"):
				ovlPath := "resources\Overlays\timer_17sec" ext
				dur := 17000

			case InStr(value, "etc_bandage"):
				ovlPath := "resources\Overlays\timer_12sec" ext
				dur := 12000

			case InStr(value, "etc_potion_haste1"):
				ovlPath := "resources\Overlays\timer_5min" ext
				dur := 300000

			case InStr(value, "etc_potion_ww1"):
				ovlPath := "resources\Overlays\timer_5min" ext
				dur := 300000

			case InStr(value, "etc_potion_haste2"):
				ovlPath := "resources\Overlays\timer_10min" ext
				dur := 600000

			case InStr(value, "etc_potion_ww2"):
				ovlPath := "resources\Overlays\timer_10min" ext
				dur := 600000

			case InStr(value, "etc_bSoE"):
				ovlPath := "resources\Overlays\timer_10sec" ext
				dur := 10000

			case InStr(value, "bRes"):
				ovlPath := "resources\Overlays\timer_15sec" ext
				dur := 15000

			case value = "resources\default_icon.png":
				ovlPath := "null"
				dur := 300

			default:
				ovlPath := "resources\Overlays\flash" ext
				dur := 300
		}

		if (aActionType[idx][1] == 3) {
			if (RegExMatch(aActionType[idx][3], "^#") || RegExMatch(aActionType[idx][3], "^@")) {    ; Trade:  "^\+"  Shout: "^\!"
					ovlPath := "resources\Overlays\timer_2sec" ext
					dur := 1500
				}
				else {
					ovlPath := "resources\Overlays\timer_5min" ext
					dur := 300000
				}
			}

		aIconsData.Push({
			icon: A_ScriptDir "\" value,
			overlay: (ovlPath == "null" ? "null" : A_ScriptDir "\" ovlPath),
			duration: dur
		})

	}
} catch Error as err {
	MsgBox("Config file not found or corruped.", "Error", 0x10)
	ExitApp
}

(DEBUG_MODE) && LogDataArray(aIconsData, "aIconsData")

;------------------------------------------------------------------------------------------------------

global CustomPanelNum := IniRead(IniPath, "Panel", "CustomPanelNum")

global AutoSSanimation := []
AutoSSanimation := StrSplit(IniRead(IniPath, "AutoSSanimation", "animated"), ",")

;------------------------------------------------------------------------------------------------------
try {
	RelativePath := A_ScriptDir "\..\..\System\Option.ini"
	L2VideoConfigPath := ""
	Loop Files, RelativePath
	L2VideoConfigPath := A_LoopFileFullPath

	global VResolX := IniRead(L2VideoConfigPath, "Video", "GamePlayViewportX")
	global VResolY := IniRead(L2VideoConfigPath, "Video", "GamePlayViewportY")


	RelativePath := A_ScriptDir "\..\..\System\WindowsInfo.ini"
	L2ConfigPath := ""
	Loop Files, RelativePath
    L2ConfigPath := A_LoopFileFullPath

	global MainPanelPosX := IniRead(L2ConfigPath, "17", "posX")
	global MainPanelPosY := IniRead(L2ConfigPath, "17", "posY")
	global TargetPosX := IniRead(L2ConfigPath, "7", "posX")
	global TargetPosY := IniRead(L2ConfigPath, "7", "posY")
	global IsPanelHorizontal := (IniRead(L2ConfigPath, "17", "rotate", "false") = "true")


}
catch {
    MsgBox("Failed to find or read Lineage 2 WindowsInfo.ini config file.`n`nCheck that scrip is placed into folder:`nGame_Folder/Patches/CustomSkillPanel/", "Error", 0x10)
	ExitApp
}

;------------------------------------------------------------------------------------------------------

if IsPanelHorizontal
	panelPath := A_ScriptDir "\resources\panel_h.png"
else
	panelPath := A_ScriptDir "\resources\panel_v.png"

PanelWidth := ImageWidth(panelPath)
PanelHeight := ImageHeight(panelPath)

if IsPanelHorizontal {
	if (MainPanelPosY <= (2 * PanelHeight)) {
		MsgBox("Skill Panel on the top of screen is not supported in this version", "Error", 0x10)
		ExitApp
	}
	else {
		PanelPosX := MainPanelPosX
		PanelPosY := MainPanelPosY - PanelHeight
		PanelHeightFull := PanelHeight + 43
		PanelWidthFull := PanelWidth
		ShiftX := 0
		x1 := MainPanelPosX + 11 ;position for digital number of in-game panel
		y1 := MainPanelPosY + 16
	}
}
else {
	if (MainPanelPosX < ( VResolX // 2 )) {
		PanelPosY := MainPanelPosY
		PanelPosX := MainPanelPosX
		PanelHeightFull := PanelHeight
		PanelWidthFull := PanelWidth + 43
		x1 := MainPanelPosX + 16
		y1 := MainPanelPosY + 11
		ShiftX := 43
	}
	else {
		PanelPosY := MainPanelPosY
		PanelPosX := MainPanelPosX - PanelWidth
		PanelHeightFull := PanelHeight
		PanelWidthFull := 2 * PanelWidth
		x1 := PanelPosX + 16 + 43
		y1 := PanelPosY + 11
		ShiftX := 0
	}
}

(DEBUG_MODE) && LogDebug(Format("`nL2Config: {11}`n`nРазмер окна: `nx: {1}, y: {2}`n`nРасположение внутриигровой панели: `nx: {3}, y: {4}`n`nРасположение GUI: `nx: {5}, y: {6}`n`nОбласть сканирования № панели: `nx: {7} - {8}`ny: {9} - {10}`n", VResolX, VResolY, MainPanelPosX, MainPanelPosY, PanelPosX, PanelPosY, x1, (x1 + 12), y1, (y1 + 12), L2ConfigPath))

;------------------------------------------------------------------------------------------------------

global NeedsCapsLock := false
global HkConditions := (*) => false
global HotKeyMap := []
loop 10 {
    val := IniRead(IniPath, "HotKeys", "cell" A_Index, "")
    if (val != "" && !(RegExMatch(val,"i)^null$"))) {
        HotKeyMap.Push({Key: val, Idx: A_Index})

	if !(RegExMatch(val, "i)^(F\d+|\d)$")) ;i) — игнорировать регистр. ^ — начало строки. ( — начало группы условий. F\d+ — буква F и одна или более цифр (F1, F12). | — ИЛИ. \d — одна цифра. ) — конец группы. $ — конец строки.
		NeedsCapsLock := true
    }
}

;------------------------------------------------------------------------------------------------------

CoordMode "Mouse", "Client"

CustomPanel := Gui("-SysMenu -Caption -Border -DPIScale")
CustomPanel.BackColor := "EEAA99"
WinSetTransColor("EEAA99", CustomPanel)
CustomPanel.Title := "L2_CustomSkillPanel"
global hPanelID := CustomPanel.Hwnd
global hCustomCursor := DllCall("LoadCursorFromFile", "Str", A_ScriptDir "\resources\Cursor_default.cur", "Ptr")
TraySetIcon(A_ScriptDir "\resources\tray.ico", 1)
A_IconTip := "L2 Custom Skill Panel"

global L2Hwnd := WinExist("ahk_class L2UnrealWWindowsViewportWindow")

if L2Hwnd {
	if !NoIntegr {
		DllCall("SetParent", "ptr", CustomPanel.HWND, "ptr", L2Hwnd)
		WinGetPos(&WinX, &WinY, , , L2Hwnd)
        PanelPosX += WinX
        PanelPosY += WinY
		x1 += WinX
		y1 += WinY
	}
	else
		CustomPanel.Opt("+Owner" L2Hwnd)

	CustomPanel.Show("NA x" PanelPosX " y" PanelPosY " w" PanelWidthFull " h" PanelHeightFull)
}

; 37 = 32 pixel icon width + 3 pixel between icons + 1 pixel left black border + 1 right black border
Loop 10 {
	If IsPanelHorizontal {
		pX := 37 * A_Index - 6
		pY := 6
		aIconsData[A_Index].hwnd := ImageShow(aIconsData[A_Index].icon,, [pX, pY], 0x40000000 | 0x10000000 | 0x8000000,, CustomPanel.hwnd, False)
		aIconsData[A_Index].x := pX
		aIconsData[A_Index].y := pY
		DllCall("SetWindowPos", "ptr", aIconsData[A_Index].hwnd, "ptr", 0, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x13)
	}
	else {
		pX := ShiftX + 5
		pY := 37 * A_Index - 6
		aIconsData[A_Index].hwnd := ImageShow(aIconsData[A_Index].icon,, [pX, pY], 0x40000000 | 0x10000000 | 0x8000000,, CustomPanel.hwnd, False)
		aIconsData[A_Index].x := pX
		aIconsData[A_Index].y := pY
	}
}



BackgrndPanel := []
BackgrndPanel.hwnd := ImageShow(panelPath,, [ShiftX, 0], 0x40000000 | 0x10000000 | 0x8000000,, CustomPanel.hwnd, False)
BackgrndPanel.x := ShiftX
BackgrndPanel.y := 0

global IsActionRunning := false
global mOverlays := Map()
global mIsAnimating := Map()
global mTimers := Map()

OnExit(ExitHandler)
OnMessage(0x5555, AutoSSOnOFF)

SetTimer(() => CheckActivegamePanel(), 2000)
SetTimer(() => LogFile.Read(0), 10000)

if NeedsCapsLock {
	SetTimer(MonitorL2Focus, 500)
}

InstallMouseHook
SetStoreCapsLockMode(false) ;AHK не будет игнорировать состояние CapsLock при отправке Send, если явно не указано обратное
A_MenuMaskKey := "vkE8" ;замена стандартного MaskKey после нажатия на Alt или Win на неиспользуемую виртуальную клавишу (vkE8), иначе AHK по умолчанию отправлял бы (LCtrl)
SetKeyDelay 15, -1

IsReady := true



#HotIf IsReady and MouseIsOverIcon() and WinActive("Lineage II")
*LButton:: {
    BlockInput "MouseMove"
    try {
		if IsPanelHorizontal
			MouseMove mPosX, MainPanelPosY, 0
		else {
			if (slot == 0 && ShiftX != 0)
				MouseMove MainPanelPosX + 42, MainPanelPosY + 9, 0 ;center part of head of in-game skill panel, so mouse moved to safe zone for fake-click
			else
				MouseMove MainPanelPosX + ShiftX, mPosY, 0
		}

        Click "Down"
		Sleep(32)
		Click "Up"

		if (slot > 0)
			ExecuteAction(slot)

        MouseMove mPosX, mPosY, 0
    }
    finally {
        BlockInput "MouseMoveOff"
    }

	if slot >= 0
		ManageOverlay(slot)
}
#HotIf


#HotIf IsReady and MouseIsOverIcon() and WinActive("Lineage II")
RButton:: {
    global mTimers, mIsAnimating

	if !mIsAnimating.Get(slot, false)
        return

    if slot < 1
		return

	if mTimers.Has(slot) {
        SetTimer(mTimers[slot], 0)
        mTimers.Delete(slot)
    }

    if mTimers.Has(slot + 100) {
        SetTimer(mTimers[slot + 100], 0)
        mTimers.Delete(slot + 100)
    }

    ClearOverlay(slot)
    ClearOverlay(slot + 100)

    mIsAnimating[slot] := false
}
#HotIf

;------------------------------------------------------------------------------------------------------
if (HotKeyMap.Length > 0) {
	if (NeedsCapsLock)
		HkConditions := (*) => GetKeyState("CapsLock", "T") && WinActive("Lineage II")
	else
		HkConditions := (*) => WinActive("Lineage II")

	HotIf(HkConditions)

	for item in HotKeyMap {
		if (item.Key != "") {
			try{
				Hotkey("*" item.Key, HotkeyMapper.Bind(item.Idx))
			} catch as e{
				(DEBUG_MODE) && LogDebug("Попытка привязать хоткей как: " item.Key "")
			}
		}
	}

	HotIf()
}

HotkeyMapper(idx, KeyName) {
    (DEBUG_MODE) && LogDebug("Слот " idx " активирован клавишей: " KeyName)
	ExecuteAction(idx)
    ManageOverlay(idx)
}

;------------------------------------------------------------------------------------------------------

ExecuteAction(slot, *) {
	global IsActionRunning

	if (mIsAnimating.Get(slot, false) && !InStr(aIconsData[slot].overlay, "toggle.")) {
		if !isSoundDisable {
			navSound := A_WinDir "\Media\Windows Navigation Start.wav"
			if FileExist(navSound)
				SoundPlay navSound
			else
				SoundBeep 200, 150
		}
		return
	}

	;проверка на зажатые клавиши состояний
    mods := (GetKeyState("Ctrl", "P") << 2) | (GetKeyState("Shift", "P") << 1) | GetKeyState("Alt", "P") ; 4 (100) Ctrl, 2 (010) Shift, 1 (001) Alt
	if (mods) {
		SendEvent "{Ctrl Up}{Shift Up}{Alt Up}"
	}


	IsActionRunning := true
    try {
		switch aActionType[slot][1] {
			case 1:
				SendEvent "!{F" CustomPanelNum "}"
				prefix := ((mods & 4) ? "^" : "") . ((mods & 2) ? "+" : "")
				SendEvent(prefix "{F" slot "}")
				SendEvent "!{F" gamePanelNum "}"

			case 2:
				SetKeyDelay 15, 15
				num := aActionType[slot][2]
				SendEvent "!{F" num "}"
				for _, key in StrSplit(aActionType[slot][3], ",")
					SendEvent "{F" key "}"
				SendEvent "!{F" gamePanelNum "}"
				SetKeyDelay 15, -1

			case 3:
				textToSend := aActionType[slot][3]
				if InStr(textToSend, "%target%") {
					textToSend := StrReplace(textToSend, "%target%", ReadTarget())
				}
				Loop aActionType[slot][2] {
					SendEvent "{BackSpace}{Enter}{BackSpace}"
					SendText(textToSend) ;SendEvent("{Raw}" textToSend)
					SendEvent "{Enter}"
				}
		}
		Sleep(10)
		if (mods & 6) {
			restore := ((mods & 4) && GetKeyState("Ctrl", "P") ? "{Ctrl Down}" : "")
					 . ((mods & 2) && GetKeyState("Shift", "P") ? "{Shift Down}" : "")
			if (restore != "")
				SendEvent(restore)

		}
	} catch as e {
        (DEBUG_MODE) && LogDebug("Ошибка в ExecuteAction: " e.Message)
    } finally {
        IsActionRunning := false
    }
}

;------------------------------------------------------------------------------------------------------

MouseIsOverIcon() {
    global slot, mPosX, mPosY, hPanelID, L2Hwnd

	;получение координат экрана и перевод их в координаты относительно клиента игры
    MouseGetPos(&sX, &sY)
    pt := Buffer(8), NumPut("int", sX, "int", sY, pt)
    DllCall("ScreenToClient", "ptr", L2Hwnd, "ptr", pt)
    mPosX := NumGet(pt, 0, "int"), mPosY := NumGet(pt, 4, "int")

    if (mPosX >= (PanelPosX + ShiftX) and mPosX <= (PanelPosX + PanelWidth + ShiftX) and
        mPosY >= PanelPosY and mPosY <= (PanelPosY + PanelHeight))
    {
		localRelX := mPosX - (PanelPosX + ShiftX)
		localRelY := mPosY - PanelPosY

		if IsPanelHorizontal {
			if localRelX < 23 && localRelY < 41 {
				slot := 0
				return true
			}
		}
		else {
			if localRelX < 41 && localRelY < 23 {
				slot := 0
				return true
			}
		}
		Loop aIconsData.Length {
			if (localRelY >= aIconsData[A_Index].y and localRelY <= aIconsData[A_Index].y + 32) {
				if ((localRelX + ShiftX) >= aIconsData[A_Index].x and (localRelX + ShiftX) <= aIconsData[A_Index].x + 32) {
					slot := A_Index
					return true
				}
			}
		}
		slot := -1
		return true
	}
    return false
}

;------------------------------------------------------------------------------------------------------

AutoSSOnOFF(wParam, lParam, msg, hwnd) {
        ManageOverlay(0, wParam)
}

;------------------------------------------------------------------------------------------------------

ManageOverlay(index, state := -1) {
    global mOverlays, mIsAnimating, mTimers, isAutoSSAnimated

	(DEBUG_MODE) && LogDebug("Запуск ManageOverlay. Ячейка: " index "")

	try {
		if index == 0 {
			if AutoSSanimation[1] == "OFF" {
				(DEBUG_MODE) && LogDebug("AutoSSanimation is Disabled. Завершение ManageOverlay(0)")
				return
			}

			if (state != -1 && isAutoSSAnimated == !!state)
                return

			if (isAutoSSAnimated) {
				(DEBUG_MODE) && LogDebug("СТАТУС: Анимация автососок уже проигрывается. Остановка.")
				for idx, value in AutoSSanimation {
					ClearOverlay(idx + 200)
				}
				isAutoSSAnimated := false
				(DEBUG_MODE) && LogDebug("СТАТУС: isAutoSSAnimated = " isAutoSSAnimated)
				return
			} else {
				lastHwnd := 0
				for idx, value in AutoSSanimation {
					if IsPanelHorizontal
						ovlHwnd := ImageShow(A_ScriptDir "\resources\Overlays\toggle" ext,, [aIconsData[value].x, aIconsData[value].y + 43], 0x40000000 | 0x10000000 | 0x8000000,, CustomPanel.hwnd, true)
					else
						ovlHwnd := ImageShow(A_ScriptDir "\resources\Overlays\toggle" ext,, [aIconsData[value].x + 43 - (2 * ShiftX), aIconsData[value].y], 0x40000000 | 0x10000000 | 0x8000000,, CustomPanel.hwnd, true)
					(DEBUG_MODE) && LogDebug(Format("Создан Оверлей [HWND: 0x{:X}]", ovlHwnd))
					mOverlays[idx + 200] := ovlHwnd
					lastHwnd := ovlHwnd
				}
				isAutoSSAnimated := true
				(DEBUG_MODE) && LogDebug("СТАТУС: isAutoSSAnimated = " isAutoSSAnimated)
				return lastHwnd
			}
		}

		if aIconsData[index].overlay == "null" {
			(DEBUG_MODE) && LogDebug("ОТМЕНА: Пустая ячейка, игнорируем.")
			return
		}

		IsAnimating := mIsAnimating.Get(index, false)
		(DEBUG_MODE) && LogDebug("СТАТУС: mIsAnimating[" index "]: " (IsAnimating ? "TRUE" : "FALSE"))

		if IsAnimating {
			if InStr(aIconsData[index].overlay, "toggle" ext) {
				(DEBUG_MODE) && LogDebug("ИНФО: Это toggle. Будет запущено удаление Оверлея")
				ClearOverlay(index)
				mIsAnimating[index] := false ;
			} else
				(DEBUG_MODE) && LogDebug("ОТМЕНА: Клик проигнорирован, анимация еще идет.")
			return
		}

		mIsAnimating[index] := true
		(DEBUG_MODE) && LogDebug("Флаг mIsAnimating[" index "] установлен в TRUE. Duration: " aIconsData[index].duration)
		ovlHwnd := ImageShow(aIconsData[index].overlay,, [aIconsData[index].x, aIconsData[index].y], 0x40000000 | 0x10000000 | 0x8000000,, CustomPanel.hwnd, true)
		if (DEBUG_MODE)
			if !ovlHwnd
				LogDebug("ОШИБКА: ImageShow вернул 0 или null")
			else
				LogDebug(Format("Создан Оверлей [HWND: 0x{:X}]", ovlHwnd))
		DllCall("SetWindowPos", "ptr", ovlHwnd, "ptr", 0, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x3)
		mOverlays[index] := ovlHwnd

        if aIconsData[index].duration > 0 {
            if !InStr(aIconsData[index].overlay, "flash" ext) {
				(DEBUG_MODE) && LogDebug("ИНФО: Оверлей не flash.")
				tFinish := () => (
					(DEBUG_MODE) && LogDebug("Сработал таймер на FinishOverlay(" index ")"),
					FinishOverlay(index)
				)
                mTimers[index + 100] := tFinish
                SetTimer(tFinish, -(aIconsData[index].duration - 350))
				(DEBUG_MODE) && LogDebug("FinishOverlay будет запущен по mTimers[" (index + 100) "] через " (aIconsData[index].duration - 350) "  мс")
            }
            tClear := () => (
				(DEBUG_MODE) && LogDebug("Сработал таймер на ClearOverlay(" index ")"),
				ClearOverlay(index)
			)
            mTimers[index] := tClear
            SetTimer(tClear, -aIconsData[index].duration)
			(DEBUG_MODE) && LogDebug("ClearOverlay будет запущен по mTimers[" index "] через " aIconsData[index].duration "  мс")
        }
        return ovlHwnd

	} catch Any as e {
		(DEBUG_MODE) && LogDebug("ОШИБКА в блоке ManageOverlay: " e.Message " (Line: " e.Line ")")
		(DEBUG_MODE) && LogDebug("Стек вызовов: " e.What)
		if !WinExist("ahk_id " L2Hwnd)
		 ExitApp()
	}
}

FinishOverlay(index) {
    global mOverlays, mTimers
	(DEBUG_MODE) && LogDebug("FinishOverlay(" index "): Запуск")
    try {
        if mTimers.Has(index + 100) {
			(DEBUG_MODE) && LogDebug("FinishOverlay(" index "): Найдена запись о таймере idx:" (index + 100) ". Удаляем.")
            mTimers.Delete(index + 100)
		}

        ovlHwnd := ImageShow(A_ScriptDir "\resources\Overlays\flash.agif",, [aIconsData[index].x, aIconsData[index].y], 0x50000000 | 0x8000000,, CustomPanel.hwnd, true)
        DllCall("SetWindowPos", "ptr", ovlHwnd, "ptr", 0, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x3)
        mOverlays[index + 100] := ovlHwnd
		(DEBUG_MODE) && LogDebug(Format("FinishOverlay(" index "): Создан Оверлей mOverlays[" (index + 100) "] [HWND: 0x{:X}]", ovlHwnd))

        tFlashClear := () => ClearOverlay(index + 100)
        mTimers[index + 100] := tFlashClear
        SetTimer(tFlashClear, -300)
		(DEBUG_MODE) && LogDebug("FinishOverlay(" index "): ClearOverlay будет запущен по mTimers[" (index + 100) "] через стандратные 300 мс")

    } catch Any as e {
        (DEBUG_MODE) && LogDebug("ОШИБКА в блоке FinishOverlay: " e.Message " (Line: " e.Line ")")
		(DEBUG_MODE) && LogDebug("Стек вызовов: " e.What)
		if !WinExist("ahk_id " L2Hwnd)
		 ExitApp()
    }
}

ClearOverlay(index) {
    global mOverlays, mTimers, mIsAnimating

	(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Запуск.")
	if index < 100 {
		mIsAnimating[index] := false
		(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Флаг isAnimating сброшен в FALSE")
		if mOverlays.Has(index + 100) {
			(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Найден Оверлей idx:" (index+100) " Запускается ClearOverlay(" (index + 100) ")")
			ClearOverlay(index + 100)
			(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Завершено ClearOverlay (" (index+100) ")")
		}
	}

    if mTimers.Has(index) {
		(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Найдена запись о таймере idx:" index ". Удаляем.")
        SetTimer(mTimers[index], 0)
        mTimers.Delete(index)
		(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Таймер остановлен, запись из mTimers удалена")
    }

    if mOverlays.Has(index) {
		(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): mOverlay[" index "] найден --> DLL.DestroyWindow")
        DllCall("DestroyWindow", "ptr", mOverlays[index])
		(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Оверлей уничтожен")
        mOverlays.Delete(index)
    }
	(DEBUG_MODE) && LogDebug("ClearOverlay(" index "): Завершено")
}

;------------------------------------------------------------------------------------------------------

ReadTarget() {
	w := 121, h := 17, scale := 2
	pToken := Gdip_Startup()
	pBitmap := Gdip_BitmapFromScreen((TargetPosX + 14) "|" (TargetPosY + 3) "|" w "|" h)
	pBitmapBig := Gdip_CreateBitmap(w * scale, h * scale)
	G := Gdip_GraphicsFromImage(pBitmapBig)
	Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, pBitmap, 0, 0, w * scale, h * scale, 0, 0, w, h)

	Result := OCR.FromBitmap(pBitmapBig, "en")

	Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmapBig)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
	return Result.Text
}

;------------------------------------------------------------------------------------------------------

CheckActivegamePanel() {
    global gamePanelNum,
	start := A_TickCount

	if !WinActive("ahk_id " L2Hwnd)
        return

	if (IsActionRunning)
        return

	digit := GetCurrentgamePanelNum()
	;(DEBUG_MODE) && LogDebug(Format("GetCurrentGamePanelNum result: {1}", digit))
	if ((digit != "") and (digit != gamePanelNum))
		gamePanelNum := digit
}

GetCurrentgamePanelNum() {
    if (ok := FindText(&FoundX, &FoundY, x1, y1, (x1 + 12), (y1 + 12), 0, 0, DigitsPatterns)) {
        return Integer(ok[1].id)
    }
    return ""
}

;------------------------------------------------------------------------------------------------------

MonitorL2Focus() {
    global LastCapsLockState
    static wasL2Active := false

    CurrentHWND := WinActive("A")
    isL2Active := false


    isL2Active := (CurrentHWND = L2Hwnd)
               || (hPanelID && CurrentHWND = hPanelID && WinExist(hPanelID))
               || (CurrentHWND && DllCall("GetParent", "ptr", CurrentHWND, "ptr") = L2Hwnd)

    if (isL2Active && !wasL2Active) {
        if (LastCapsLockState && !GetKeyState("CapsLock", "T"))
            SetCapsLockState("On")
    }
    else if (!isL2Active && wasL2Active) {
        LastCapsLockState := GetKeyState("CapsLock", "T")
        if (LastCapsLockState)
            SetCapsLockState("Off")
    }

    wasL2Active := isL2Active
}

;------------------------------------------------------------------------------------------------------

; Some useful functions.
Play(hwnd) => PostMessage(0x8001,,,, hwnd)
Restart(hwnd) => PostMessage(0x8001, 1,,, hwnd)
Pause(hwnd) => PostMessage(0x8002,,,, hwnd)
Stop(hwnd) => PostMessage(0x8002, 1,,, hwnd)
PlayPause(hwnd) => PostMessage(0x202,,,, hwnd)
RestartStop(hwnd) => PostMessage(0x202, 1,,, hwnd)
IsPlaying(hwnd) => DllCall("GetWindowLong", "ptr", hwnd, "int", 4*A_PtrSize, "ptr")
Step(hwnd, n) => PostMessage(0x8000, n,,, hwnd)
NextFrame(hwnd) => Step(hwnd, 1)
PrevFrame(hwnd) => Step(hwnd, -1)

/*
F1:: Play("ahk_id " image_hwnd0)
F2:: Pause("ahk_id " image_hwnd0)
F3:: Stop("ahk_id " image_hwnd0)
F4:: PrevFrame("ahk_id " image_hwnd0)
F5:: NextFrame("ahk_id " image_hwnd0)
*/

/*
*F7:: {
    start := A_TickCount
    digit := GetCurrentgamePanelNum()
    elapsed := A_TickCount - start

    if (digit != "")
        ToolTip "Current Panel  #" digit " (Time: " elapsed "ms)"
    else
        ToolTip "Not found" x1 y1

    SetTimer () => ToolTip(), -2000
}
*/

LogDebug(msg) {
    try {
		static threadID := DllCall("GetCurrentThreadId")
        LogFile.WriteLine(FormatTime(, "HH:mm:ss") . "." . A_MSec . " [tID " . threadID . "] " . msg)
    }
}

LogDataArray(dataArray, name := "DataArray") {
    out := "--- Дамп " . name . " ---`n"
    for idx, item in dataArray {
        if IsObject(item) && !(item is Array) {
            for prop, value in item.OwnProps() {
                out .= Format("[{1}][{2}] = {3}`n", idx, prop, value)
            }
        }
        else if (item is Array) {
            for subIdx, value in item {
                out .= Format("[{1}][{2}] = {3}`n", idx, subIdx, value)
            }
        }
		out .= "`n"
    }
	LogDebug(out)
}

ExitHandler(ExitReason, ExitCode) {
    BlockInput "MouseMoveOff"
	SetCapsLockState("Off")
	global LogFile
    if (DEBUG_MODE) {
		LogDebug("--- Скрипт завершен (Причина: " ExitReason ") ---")
		LogFile.Read(0)
		LogFile.Close()
	}
}
