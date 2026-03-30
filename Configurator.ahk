#Requires Autohotkey v2

global DebugMode := 0
global SoundDisable := 0
global GIF := 0
global NoIntegr := 0

DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "Str", "Skill Panel Configurator")

TraySetIcon("shell32.dll","329")
myGui := Gui()
myGui.Title := "Skill Panel Configurator"
myGui.SetFont("s10", "Segoe UI")


HelpText := {
        Tutorial: "
        ( LTrim
        "Основная внутриигровая панель" - та, что у вас в игре, которую NCSoft в С1 сделали лишь одну единственную.
        "Дополнительная панель" - та, которую реализует этот скрипт.

        Как пользоваться конфигуратором:
        Укажите номер внутриигровой панельки, на которую в игре уже вынесены требуемые предметы и скиллы. Клик по Дополнительной панели будет вызывать активацию умения/предмета, расположенного в соответствующей ячейке заданной панели.

        Если хотите отобразить анимацию автоматического использования сосок на Основной внутриигровой панели - укажите номера ячеек с сосками.

        Если хотите использовать горячие клавиши - выберите пресет или задайте клавиши вручную справа от каждого действия. Чтобы активировать хоткей нужно включить CapsLock. Если для хоткеев используются только F1-F12 или цифры, то CapsLock не требуется.

        В выпадающих списках выберите подходящий тип действия и иконку для Дополнительной панели. Тип действия влияет (в том числе) на визуальное отображение реакции нажатия: для активируемых (toggle) способностей будет проигрываться циклическая анимация (вплоть до отключения), для расходников начнется отсчет фиксированного таймера обратного отсчета и т.д.

        Задайте дополнительные параметры  (там, где это предусмотрено):
        * Для типа действия "Чат" в самой игре дополнительно ничего настраивать не надо - оставьте там (в игре) ячейку пустой. Сообщения в группу и в клан можно дублировать, для других каналов дублирование запрещено.
        * Для типа "Экипировка" можно указать номер другой внутриигровой панели и одну или несколько ячеек на ней. По однократному нажатию все эти ячейки будут вызваны в игре. Таким образом, можно переодеть сразу сэт целиком. Пример: В игре вы пользуетесь 1ой панелью. На 7ую панель в игре выносите нужные вам скиллы и расходники, предположим у вас занято 7 из 10 ячеек, но вы хотите еще иметь возможность менять тяжелый сэт на робу - под это вам нужно четыре ячейки для тяжа и четыре ячейки для робы. Все эти предметы вы выносите, например, на 8 панель. Настройка в игре закончена. В конфигураторе выставляете общий (верхний) контрол Panel = 7 (для скиллов и расходников), а внутри каждого типа действия "Экипировка" выставляете Panel = 8 и в Slots через зяпятую пишите ячейки 1,2,3,4 в один; 5,6,7,8 в другой.

        В разделе Опции можно выбрать альтернативные методы работы скрипта, если базовые не подходят.

        Завершите формирование конфигурационного файл для дополнительной панели, нажав кнопку Create Config.

        Вы можете выгрузить в файл свои настройки или подгрузить данные из ранее сохраненного, используя кнопки Импорт / Экспорт

        Если у вас несколько персонажей, для которых нужно по-разному настроить Дополнительную панель, переименуйте конфиг файл, дописав в конце 1, 2, 3 и т.д. (config1.ini, config2.ini). Чтобы перезагрузить панель в игре нажмите Ctrl+Shift+Z для первой, Ctrl+Shift+X для второй и т.д. (максимум 7, 7 = m). Переключение панелей работает только в том случае, если запущен Starter.
        )",
        EN: "
        ( LTrim
        Specify the number of the panel where the required items and skills have already set in the game. Left Mousebutton click on the Custom Panel will trigger the activation of the skill/item located in the corresponding cell of the specified panel.

        If you want to display an animation of automatic soulshots usage on the Main (in-game) panel, specify the cell numbers with the soulshots.

        Select the appropriate action type and icon in drop-down menu for Custom Panel. The type of action determine the visual effect: for toggle-activated abilities a cyclic animation will be played till deactivation, for consumables a countdown timer will start, and etc.

        To activate hotkey usage select preset or set every hotkey manually. To use hotkey in game you need to set CapsLock. For F1-F12 or digits preset CapsLock is not needed.

        Set additional parameters (where provided) for Custom Panel:
        * For action type "Chat" you do not need to configure anything in game - just leave the cell empty there. Messages to the group and clan chat can be duplicated, but for other channels it is prohibited.
        * For the "Equipment" you need to specify another panel number and one (or more) cells. With a single click all these cells will be pushed in the game. So, you can change full armor set at one click.

        You can set alternative algorithms for scrip functions if basic has problems on your system.

        To finish prepare config file click "Create config".

        You can export your settings to a file or upload data from a previously saved file using the Import/Export buttons.

        If you have several chars and need several differently configured panels, you can rename config files to "config1.ini, config2.ini" and e.t. To change panel "Starter" process should be runnig, and you shoul use Ctrl+Shift+Z to change panel to #1, Ctrl+Shitft+X for 2nd C, V, B, N, M for others.
        )"
}

myGui.SetFont("s10 underline", "Segoe UI")
Tut := myGui.Add("Text", "cBlue x20 y10 w50", "Tutorial")
Tut.OnEvent("Click", (*) => MsgBox(HelpText.Tutorial, "Help"))
myGui.Add("Text", "cBlue x+1 y10", "(EN)").OnEvent("Click", (*) => MsgBox(HelpText.EN, "Help"))
Opts := myGui.Add("Text", "x+125 yp cBlue", "Options")
Opts.OnEvent("Click", (*) => ShowOptions(myGui))
Import := myGui.Add("Text", "cBlue x+20 yp", "Import")
Export := myGui.Add("Text", "cBlue x+20 yp", "Export")
myGui.SetFont("norm s10", "Segoe UI")

;line := myGui.Add("Text", "x20 y55 w335 h2 +0x10")

autoss_cbx := myGui.Add("CheckBox", "x149 y42 w15 h16")
autoss_txt := myGui.Add("Text", "x+1 yp-2", "AutoSS animation for")
autoss_txt2 := myGui.Add("Text", "x+-1 yp", " slots #")
autoss_txt.Opt("cGray")
autoss_txt2.Opt("cGray")
autoss_edt := myGui.Add("Edit", "x+1 yp-3 w52 h21", "2,3")
autoss_edt.hasError := false
autoss_edt.Opt("+Disabled")

myGui.Add("Text", "x20 yp+30", "Panel #")
panel := myGui.Add("Edit", "x+1 yp-3 w22 h21", "10")
panel.hasError := false

myGui.Add("Text", "x+61 yp", "Hotkeys preset:")
myGui.SetFont("s9")
HkDDL := myGui.Add("DropDownList", "x+2 yp-2 w144", ["Q W E R T Y...", "F1 F2 F3 F4..." , "1 2 3 4 5 6...", "No", "Custom"])
HkDDL.Text := "No"
myGui.SetFont("s10")

BtnSave := myGui.Add("Button", "x" (20 + 32 + 12) " y700 w100 Disabled", "Create config")

Icons := Map()
ExtraCtrls := Map()
defaultIcon := A_ScriptDir "\resources\default_icon.png"

Loop 10 {
    currY := A_Index * 60 + 30
    myGui.Add("Text", "x12 y" (currY - 3), (A_Index == 10 ? 0 : A_Index))
    Icons[A_Index] := myGui.Add("Picture", "x20 y" currY " w32 h32", defaultIcon)
    Icons[A_Index].Path := defaultIcon
    slot := myGui.Add("DropDownList", "x+12 y" currY " w290", ["Fast Skills", "Toggles", "Supplies", "Equipment", "Chat", ""])
    slot.Index := A_Index
    slot.GetPos(&X, &Y, &W, &H)

    ;Hotkeys
    myGui.SetFont("s9")
    hkedt := myGui.Add("Edit", "x+5 yp w24 h24 Center Limit3", "")
    myGui.SetFont("s10")
    hkedt.hasError := false
    hkedt.Opt("+Disabled")

	;Equipment
	txt0 := myGui.Add("Text", "x" X " y" (Y + H + 23) " w182 h2 +0x10 +Hidden")
    txt1 := myGui.Add("Text", "x" X " y" (Y + H + 5) " +Hidden", "Panel #")
    edt1 := myGui.Add("Edit", "x+1 yp-3 w22 h21 +Hidden", "9")
    edt1.hasError := false
    txt2 := myGui.Add("Text", "x+8 yp+3 +Hidden", "Slots #")
    edt2 := myGui.Add("Edit", "x+1 yp-3 w65 h21 +Hidden", "1,2,3")
    edt2.hasError := false
    edt2.Index := A_Index


    ;Chat
    chatEdt := myGui.Add("Edit", "x" X " y" (Y + H + 5) " w" (W - 32) " h21 +Hidden -Wrap +Multi -vScroll -WantReturn", "ку")
    chatEdt.Index := A_Index
    chatEdt.hasError := false
    chatEdt.scrollPos := 0
    chatEdt.lastAction := A_TickCount
    chatEdt.isScrolling := false
    chatEdt.AnimationStatus := "Preparing"
    x2txt := myGui.Add("Text", "x+3 yp+2 +Hidden", "x2")
    x2txt.hasError := false
    x2cbx := myGui.Add("CheckBox", "x+3 yp+1 w15 h16 +Hidden", "")
    x2cbx.Index := A_Index



    ExtraCtrls[A_Index] := {
        equip: [txt0, txt1, edt1, txt2, edt2],
        chat: [chatEdt, x2txt, x2cbx],
        slots: slot,
        hk: hkedt
        ;equippanel: edt1
        ;equipslots: edt2
        ;chatstr: chatEdt
        ;chatx2: x2cbx
    }

    slot.OnEvent("Change", (ctrl, *) => DisplayGroup(ctrl))
    slot.OnEvent("Change", (ctrl, *) => UpdateSaveButton(ctrl))
    edt1.OnEvent("Change", (ctrl, *) => ValidatePanelNumber(ctrl))
    edt2.OnEvent("Change", (ctrl, *) => ValidateSlotsString(ctrl))
    chatEdt.OnEvent("Change", (ctrl, *) => (ValidateChatString(ctrl), CheckX2(ctrl)))
    x2cbx.OnEvent("Click", (ctrl, *) => CheckX2(ctrl))
    hkedt.OnEvent("Change", (ctrl, *) => ValidateHotkeys(ctrl))

}

    HkDDL.OnEvent("Change", FillHotkeys)
    Import.OnEvent("Click", ImportData)
    Export.OnEvent("Click", (*) => CreateConfig(true))
    panel.OnEvent("Change", (ctrl, *) => ValidatePanelNumber(ctrl))
    autoss_edt.OnEvent("Change", (ctrl, *) => ValidateSlotsString(ctrl, autoss_cbx))
    autoss_cbx.OnEvent("Click", (ctrl, *) => CheckSScbx(ctrl))
    BtnSave.OnEvent("Click", CreateConfig)

    SetTimer(AnimateString, 100)


myGui.OnEvent('Close', (*) => ExitApp())
myGui.Show("x" (A_ScreenWidth // 6) " y" (A_ScreenHeight // 5) " w400 h750")
Tut.Focus()



Presets := [
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
    ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10"],
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
    ["", "", "", "", "", "", "", "", "", ""]
]

;------------------------------------------------------------------------------------------------------------------------------------------------------------
ShowOptions(ParentGui) {

    optGui := Gui("+Owner" ParentGui.Hwnd " +ToolWindow -SysMenu", "Adv. Settings:")
    ParentGui.Opt("+Disabled")


    optDM := optGui.Add("Checkbox", "x20 y20 h20", "Debug Mode")
    optDM.Value := DebugMode

    optSoundDis := optGui.Add("Checkbox", "x20 yp+24 h20", "Disable Sound")
    optSoundDis.Value := SoundDisable

    optGIF := optGui.Add("Checkbox", "x20 yp+24 h20", "Low Quality GIF")
    optGIF.Value := GIF

    optNoIntegr := optGui.Add("Checkbox", "x20 yp+24 h20", "Disable integration to L2")
    optNoIntegr.Value := NoIntegr

    btnOk := optGui.Add("Button", "Default w60", "OK")

    ParentGui.GetPos(&px, &py, &pw, &ph)

    CloseModal(*) {
        global DebugMode := optDM.Value
        global SoundDisable := optSoundDis.Value
        global GIF := optGIF.Value
        global NoIntegr := optNoIntegr.Value
        (DebugMode || SoundDisable || GIF ||  NoIntegr) ? Opts.Opt("cMaroon") : Opts.Opt("cBlue")
        ParentGui.Opt("-Disabled")
        optGui.Destroy()
    }

    btnOk.OnEvent("Click", CloseModal)
    optGui.OnEvent("Close", CloseModal)

    optGui.Show("Hide")
    ParentGui.GetPos(&px, &py, &pw, &ph)
    cx := px + pw - 15
    cy := py + (ph // 6)
    optGui.Show("x" cx " y" cy)
}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

FillHotkeys(ctrl, *) {
    if (ctrl.Value == 5) {
        Loop 10 {
            ExtraCtrls[A_Index].hk.Opt("-Disabled")
        }
        return
    }

    currentSet := Presets[ctrl.Value]
    Loop 10 {
        ExtraCtrls[A_Index].hk.Value := currentSet[A_Index]
        ExtraCtrls[A_Index].hk.hasError := false
        ExtraCtrls[A_Index].hk.Opt("cDefault")
        if (ctrl.Value == 4)
            ExtraCtrls[A_Index].hk.Opt("+Disabled")
        else
            ExtraCtrls[A_Index].hk.Opt("-Disabled")
    }


}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

AnimateString() {
    for idx, group in ExtraCtrls {
        ctrl := group.chat[1]

        if (!ctrl.Visible || StrLen(ctrl.Value) <= 40) {
            if (ctrl.scrollPos > 0) { ;если анимация шла, но пользователь отредактировал строку, сделав ее короче 40, то сбрасываем позицию
                ResetCtrl(ctrl)
            }
            continue
        }

        if (ControlGetFocus(myGui.Hwnd) == ctrl.Hwnd) {
            ctrl.AnimationStatus := "Idle"
            continue
        }

        currTime := A_TickCount

        switch ctrl.AnimationStatus {
            case "Preparing":
                if (currTime - ctrl.lastAction > 5000) {
                    ctrl.AnimationStatus := "Animating"
                }

            case "Animating":
                ; Прокрутка вправо на 1 символ (EM_LINESCROLL)
                SendMessage(0x00B6, 1, 0, ctrl.Hwnd)
                ctrl.scrollPos += 1

                if (ctrl.scrollPos >= StrLen(ctrl.Value)) {
                    ctrl.AnimationStatus := "Finishing"
                    ctrl.lastAction := currTime
                }

            case "Finishing":
                if (currTime - ctrl.lastAction > 100) {
                    ResetCtrl(ctrl)
                }

            case "Idle":
                if (ControlGetFocus(myGui.Hwnd) != ctrl.Hwnd) {
                    ctrl.AnimationStatus := "Preparing"
                    ctrl.lastAction := currTime
                }
        }
    }
}

    ResetCtrl(ctrl) {
        ; Прокручиваем назад на всё пройденное расстояние
        SendMessage(0x00B6, -ctrl.scrollPos, 0, ctrl.Hwnd)
        ctrl.scrollPos := 0
        ctrl.AnimationStatus := "Preparing"
        ctrl.lastAction := A_TickCount
    }

;------------------------------------------------------------------------------------------------------------------------------------------------------------

DisplayGroup(ctrl, *) {
    global myGui

    slotNum := ctrl.Index
    selectedAction := ctrl.Text

    for ctrl in ExtraCtrls[slotNum].equip
        ctrl.Visible := false
    for ctrl in ExtraCtrls[slotNum].chat
        ctrl.Visible := false

    switch selectedAction {
        case "Fast Skills":
            path := A_ScriptDir "\resources\No_Cooldown_Skills"
            myGui.Opt("+OwnDialogs")
            image := FileSelect(1, path, "Select Image:", "Images (*.png)")
            if image != "" {
                Icons[slotNum].Value := image
                Icons[slotNum].Path := image
                ;для отрисовки на GUI используем предопределенное свойство .Value. Но если изображение будет подменено или кэш AHK очистить, то .Value вернет дескриптор, а не путь, поэтому для надежности дублируем кастомным свойством .Path
            } else {
                ctrl.Text := ""
				Icons[slotNum].Value := defaultIcon
                Icons[slotNum].Path := defaultIcon
			}

        case "Toggles":
            path := A_ScriptDir "\resources\Toggles"
            myGui.Opt("+OwnDialogs")
            image := FileSelect(1, path, "Select Image:", "Images (*.png)")
            if image != "" {
                Icons[slotNum].Value := image
                Icons[slotNum].Path := image
            } else {
                ctrl.Text := ""
				Icons[slotNum].Value := defaultIcon
                Icons[slotNum].Path := defaultIcon
			}

        case "Supplies":
            path := A_ScriptDir "\resources\Supplies"
            myGui.Opt("+OwnDialogs")
            image := FileSelect(1, path, "Select Image:", "Images (*.png)")
            if image != "" {
                Icons[slotNum].Value := image
                Icons[slotNum].Path := image
            } else {
                ctrl.Text := ""
				Icons[slotNum].Value := defaultIcon
                Icons[slotNum].Path := defaultIcon
			}

        case "Equipment":
            path := A_ScriptDir "\resources\Equip"
            myGui.Opt("+OwnDialogs")
            image := FileSelect(1, path, "Select Item:", "Images (*.png)")
            if image != "" {
                Icons[slotNum].Value := image
                Icons[slotNum].Path := image
                for ctrl in ExtraCtrls[slotNum].equip
                    ctrl.Visible := true
            } else {
                ctrl.Text := ""
				Icons[slotNum].Value := defaultIcon
                Icons[slotNum].Path := defaultIcon
            }

        case "Chat":
            path := A_ScriptDir "\resources\Chat"
            myGui.Opt("+OwnDialogs")
            image := FileSelect(1, path, "Select Item:", "Images (*.png)")
            if image != "" {
                Icons[slotNum].Value := image
                Icons[slotNum].Path := image
                SplitPath(image, &fileName)

                switch filename {
                    case "alarm.png":
                    ExtraCtrls[slotNum].chat[1].Value := "#Вары! Вары!"
                    ExtraCtrls[slotNum].chat[3].Value := 1
                    ExtraCtrls[slotNum].chat[2].Opt("cDefault")

                    case "regroup.png":
                    ExtraCtrls[slotNum].chat[1].Value := "#Не растягиваемся. Регрупп по ПЛу"
                    ExtraCtrls[slotNum].chat[3].Value := 0
                    ExtraCtrls[slotNum].chat[2].Opt("cGray")


                    case "assist.png":
                    ExtraCtrls[slotNum].chat[1].Value := "#Нагнем по ассисту >> %target% !"
                    ExtraCtrls[slotNum].chat[3].Value := 1
                    ExtraCtrls[slotNum].chat[2].Opt("cDefault")

                    case "attack.png":
                    ExtraCtrls[slotNum].chat[1].Value := "#Дэнс. Сонг. Погнали."
                    ExtraCtrls[slotNum].chat[3].Value := 0
                    ExtraCtrls[slotNum].chat[2].Opt("cGray")

                    case "heal.png":
                    ExtraCtrls[slotNum].chat[1].Value := "#Биш! Сука, хиль!!"
                    ExtraCtrls[slotNum].chat[3].Value := 1
                    ExtraCtrls[slotNum].chat[2].Opt("cDefault")

                    case "shout.png":
                    ExtraCtrls[slotNum].chat[1].Value := "!Набор в клан КОЛЯСКИ. Осады, эпики, замесы, ASMR и доминирование от Mori. Связь Дискорд."
                    ExtraCtrls[slotNum].chat[3].Value := 0
                    ExtraCtrls[slotNum].chat[2].Opt("cGray")

                    case "trade.png":
                    ExtraCtrls[slotNum].chat[1].Value := "+WTB rec: Sword of Nightmare"
                    ExtraCtrls[slotNum].chat[3].Value := 0
                    ExtraCtrls[slotNum].chat[2].Opt("cGray")
                    }

                    for ctrl in ExtraCtrls[slotNum].chat {
                        ctrl.Visible := true
                        if (ctrl.HasProp("AnimationStatus"))
                            ResetCtrl(ctrl)
                    }
            }
            else {
                ctrl.Text := ""
				Icons[slotNum].Value := defaultIcon
                Icons[slotNum].Path := defaultIcon
            }

        case "":
            Icons[slotNum].Value := defaultIcon
            Icons[slotNum].Path := defaultIcon
    }
}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

CheckSScbx(ctrl) {
    if ctrl.Value {
        autoss_txt.Opt("cDefault")
        autoss_txt2.Opt("cDefault")
        autoss_edt.Opt("-Disabled")
    }
    else {
        autoss_txt.Opt("cGray")
        autoss_txt2.Opt("cGray")
        autoss_edt.Opt("+Disabled")
    }

}

ValidatePanelNumber(ctrl) {
    val := ctrl.Value
    if (IsNumber(val) && Integer(val) >= 2 && Integer(val) <= 10) {
        ctrl.Opt("cDefault")
        ctrl.hasError := false
    }
    else {
        ctrl.Opt("cRed")
        ctrl.hasError := true
    }
}

ValidateSlotsString(ctrl, cbx := "") {
        global ExtraCtrls

        if (IsObject(cbx) && !cbx.Value)
        return

        val := ctrl.Value
        ; ^\d - начинается с одной цифры
        ; (,\d)* - блок "запятая и одна цифра"
        ; $ - конец строки
        if (val ~= "^\d(,\d)*$" && StrLen(val) <= 12) {
            aDigits := StrSplit(val, ",")
            local uniqDigits := Map()
            for digit in aDigits {
                if uniqDigits.Has(digit) {
                ctrl.Opt("cRed")
                ctrl.hasError := true
                return
                }
            uniqDigits[digit] := true
            }

            ctrl.Opt("cDefault")
            ctrl.hasError := false
            if (IsObject(cbx) && cbx.Value)
               autoss_txt2.Opt("cDefault")
            if cbx == ""
                ExtraCtrls[ctrl.Index].equip[4].Opt("cDefault")
        }
        else {
            ctrl.Opt("cRed")
            ctrl.hasError := true
            if (IsObject(cbx) && cbx.Value)
                autoss_txt2.Opt("cRed")
            if cbx == ""
                ExtraCtrls[ctrl.Index].equip[4].Opt("cRed")
        }
}


ValidateChatString(ctrl) {
    val := ctrl.Value
    if StrLen(val) <= 110 {
        ctrl.Opt("cDefault")
        ctrl.hasError := false
    }
    else {
        ctrl.Opt("cRed")
        ctrl.hasError := true
    }
}

CheckX2(ctrl) {
    global ExtraCtrls
    idx := ctrl.Index

    ;чекбокс выбран И (строка пуста ИЛИ первый символ НЕ #)
    if (ExtraCtrls[idx].chat[3].Value == 1) {
        if (ExtraCtrls[idx].chat[1].Value == "" || SubStr(ExtraCtrls[idx].chat[1].Value, 1, 1) != "#") {
            ExtraCtrls[idx].chat[2].Opt("cRed")
            ExtraCtrls[idx].chat[2].hasError := true
        }
        else {
            ExtraCtrls[idx].chat[2].Opt("cDefault")
            ExtraCtrls[idx].chat[2].hasError := false
        }
    }
    else {
        ExtraCtrls[idx].chat[2].Opt("cGray")
        ExtraCtrls[idx].chat[2].hasError := false
    }
    ExtraCtrls[idx].chat[2].Redraw()
}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

ValidateHotkeys(ctrl, *) {
    ;Авто-замена на upper-case и удаление лишних пробелов
    upVal := StrUpper(Trim(ctrl.Value))
    if (ctrl.Value !== upVal) {
        pos := SendMessage(0x00B0, 0, 0, ctrl) & 0xFFFF
        ctrl.Value := upVal
        SendMessage(0x00B1, Min(pos, StrLen(upVal)), Min(pos, StrLen(upVal)), ctrl)
    }

    allValues := []
    Loop 10 {
        allValues.Push(StrUpper(Trim(ExtraCtrls[A_Index].hk.Value)))
    }

    Loop 10 {
        outerIdx := A_Index
        thisCtrl := ExtraCtrls[outerIdx].hk
        thisVal := allValues[outerIdx]

        ;Цифры (0-9), латиница (a-zA-Z), символы: / , . \ [ ] = - `
        validPattern := "^[a-zA-Z0-9\/,\.\\\[\]\= \- \``]$"
        isFormatBad := false
        if (thisVal !== "") {
            if !(RegExMatch(thisVal, validPattern) || RegExMatch(thisVal, "^F([1-9]|1[0-2])$")) {
                isFormatBad := true
            }
        }

        isDuplicate := false
        if (thisVal !== "") {
            Loop 10 {
                if (A_Index !== outerIdx && thisVal == allValues[A_Index]) {
                    isDuplicate := true
                    break
                }
            }
        }

        if (isFormatBad || isDuplicate) {
            thisCtrl.hasError := true
            thisCtrl.SetFont("cRed")
        } else {
            thisCtrl.hasError := false
            thisCtrl.SetFont("cDefault")
        }
    }
}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

UpdateSaveButton(*) {
    hasValue := false
    Loop 10
        if (ExtraCtrls[A_Index].slots.Text != "") {
            hasValue := true
            break
        }
    btnSave.Enabled := hasValue
}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

CreateConfig(customPath := false, *) {
    global myGui

        UnsupportedParams := panel.hasError
        if (autoss_cbx.Value && autoss_edt.hasError)
            UnsupportedParams := true

        Loop 10 {
            idx := A_Index
            if (ExtraCtrls[idx].slots.Text == "Equipment" && (ExtraCtrls[idx].equip[3].hasError == 1 || ExtraCtrls[idx].equip[5].hasError == 1)) {
                UnsupportedParams := true
                break
            }
            else if (ExtraCtrls[idx].slots.Text == "Chat" && (ExtraCtrls[idx].chat[1].hasError == 1 || ExtraCtrls[idx].chat[2].hasError == 1)) {
                UnsupportedParams := true
                break
            }
        }

        slothasValue := false
        Loop 10 {
            idx := A_Index
            if (ExtraCtrls[idx].slots.Text != "") {
                slothasValue := true
                break
            }
        }

        Loop 10 {
            idx := A_Index
            if (ExtraCtrls[idx].hk.hasError) {
                UnsupportedParams := true
                break
            }
        }

        if !slothasValue {
            MsgBox("Nothig is configured", "Error", 0x10)
            return
        }

    if UnsupportedParams {
        MsgBox("Unsupported parameters!`n`nCheck and correct red controls.`n`n", "Error", 0x10)
        return
    }
    else {
        if (customPath = true) {
            defaultName := FormatTime(, "yyyy_MM_dd") "_config.ini"
            myGui.Opt("+OwnDialogs")
            iniPath := FileSelect("S16", A_ScriptDir "\" defaultName, "Save Config As", "Configuration Files (*.ini)")
        if !iniPath
            return
        } else {
            iniPath := A_ScriptDir "\config.ini"
        }

        if FileExist(iniPath)
            FileDelete(iniPath)

        IniWrite(DebugMode, iniPath, "Options", "DEBUG_MODE")
        IniWrite(SoundDisable, iniPath, "Options", "DisableSound")
        IniWrite(GIF, iniPath, "Options", "GIF")
        IniWrite(NoIntegr, iniPath, "Options", "NoSetParent")
        FileAppend("`n", iniPath)

        IniWrite(panel.Value, iniPath, "Panel", "customPanelNum")
        FileAppend("`n", iniPath)

        if autoss_cbx.Value == 1
            IniWrite(autoss_edt.Value, iniPath, "AutoSSanimation", "animated")
        else
            IniWrite("OFF", iniPath, "AutoSSanimation", "animated")
        FileAppend("`n", iniPath)

        Loop 10 {
        idx := A_Index
        IniWrite((StrReplace(Icons[idx].Path, A_ScriptDir "\", "")), iniPath, "Icons", "icon" idx)
        if idx = 10
            FileAppend("`n", iniPath)
        }

        Loop 10 {
        idx := A_Index
        ActionType := ExtraCtrls[idx].slots.Text

        data := (ActionType == "Equipment") ? ActionType ";" ExtraCtrls[idx].equip[3].Value ";" ExtraCtrls[idx].equip[5].Value :
                (ActionType == "Chat")      ? ActionType ";" (ExtraCtrls[idx].chat[3].Value + 1) ";" ExtraCtrls[idx].chat[1].Value :
                (ActionType == "Fast Skills" || ActionType == "Supplies" || ActionType == "Toggles") ? "Single" :
                "null"

        IniWrite(data, iniPath, "Actions", "action" idx)
        if idx = 10
            FileAppend("`n", iniPath)
        }

        Loop 10 {
            idx := A_Index
            hkval := (ExtraCtrls[idx].hk.Value == "") ? "null" : ExtraCtrls[idx].hk.Value
            IniWrite(hkval, iniPath, "HotKeys", "cell" idx)
        }

        MsgBox(iniPath, "Config successfuly created!", 0x40)
    }

}

;------------------------------------------------------------------------------------------------------------------------------------------------------------

ImportData(*) {
    global myGui, panel, autoss_edt, autoss_cbx, autoss_txt2, ExtraCtrls, Icons, DebugMode, SoundDisable, GIF, NoIntegr

    myGui.Opt("+OwnDialogs")
    iniPath := FileSelect(3, A_ScriptDir, "Select config file", "Configuration Files (*.ini)")

    if !iniPath
        return

    panel.Value := IniRead(iniPath, "Panel", "customPanelNum")
    ValidatePanelNumber(panel)

    autoSSVal := IniRead(iniPath, "AutoSSanimation", "animated")
    if (autoSSVal == "OFF") {
        autoss_cbx.Value := 0
        autoss_edt.Value := "-"
    } else {
        autoss_cbx.Value := 1
        autoss_edt.Value := autoSSVal
    }
    ValidateSlotsString(autoss_edt, autoss_cbx)
    CheckSScbx(autoss_cbx)

    DebugMode := Number(IniRead(iniPath, "Options", "DEBUG_MODE"))
    SoundDisable := Number(IniRead(iniPath, "Options", "DisableSound"))
    GIF := Number(IniRead(iniPath, "Options", "GIF"))
    NoIntegr := Number(IniRead(iniPath, "Options", "NoSetParent"))
    (DebugMode || SoundDisable || GIF ||  NoIntegr) ? Opts.Opt("cMaroon") : Opts.Opt("cBlue")

    Problems := []
    hkcount := 0
    Loop 10 {
        idx := A_Index

        try {
            relPath := IniRead(iniPath, "Icons", "icon" idx, "resources\default_icon.png")
            fullPath := A_ScriptDir "\" relPath

            if FileExist(fullPath) {
                Icons[idx].Value := fullPath
                Icons[idx].Path := fullPath
            } else {
                Icons[idx].Value := defaultIcon
                Icons[idx].Path := defaultIcon
            }

            for ctrl in ExtraCtrls[idx].equip
                ctrl.Visible := false
            for ctrl in ExtraCtrls[idx].chat
                ctrl.Visible := false

            hkData := IniRead(iniPath, "HotKeys", "cell" idx, "null")
            if (hkData == "null")
                ExtraCtrls[idx].hk.Value := ""
            else {
                ExtraCtrls[idx].hk.Value := hkData
                hkcount++
            }
            if hkcount > 0 {
                HkDDL.Text := "Custom"
                FillHotkeys(HkDDL)
            }
            else {
                HkDDL.Text := "No"
                FillHotkeys(HkDDL)
            }

            rawData := IniRead(iniPath, "Actions", "action" idx, "null")
            if (rawData == "null") {
                ExtraCtrls[idx].slots.Text := ""
                continue
            }
            parts := StrSplit(rawData, ";", , 3)
            actionType := parts[1]
            if (actionType == "Single") {
                if (InStr(relPath, "Supplies") || InStr(relPath, "Solshots"))
                    actionType := "Supplies"
                else if InStr(relPath, "No_Cooldown_Skills")
                    actionType := "Fast Skills"
                else if InStr(relPath, "Toggles")
                    actionType := "Toggles"
            }
            ExtraCtrls[idx].slots.Text := actionType

            if (actionType == "Equipment") {
                for ctrl in ExtraCtrls[idx].equip
                    ctrl.Visible := true

                ExtraCtrls[idx].equip[3].Value := parts[2]
                ExtraCtrls[idx].equip[5].Value := parts[3]

                ValidatePanelNumber(ExtraCtrls[idx].equip[3])
                ValidateSlotsString(ExtraCtrls[idx].equip[5])
            }
            else if (actionType == "Chat") {
                for ctrl in ExtraCtrls[idx].chat
                    ctrl.Visible := true

                ExtraCtrls[idx].chat[3].Value := parts[2] - 1 ; Множитель повторов переводим в значение чекбокса
                ExtraCtrls[idx].chat[1].Value := parts[3]     ; Сообщение

                ValidateChatString(ExtraCtrls[idx].chat[1])
                CheckX2(ExtraCtrls[idx].chat[1])
                CheckX2(ExtraCtrls[idx].chat[3])
            }
            else if (actionType != "null") {
                ;
            }
        } catch as err {
            Problems.Push(idx)
            ExtraCtrls[idx].slots.Text := ""
            Icons[idx].Value := defaultIcon
            Icons[idx].Path := defaultIcon
        }
    }

    if (Problems.Length > 0) {
        msg := "Import completed with errors in cells: "
        for i, val in Problems
            msg .= (i == 1 ? "" : ", ") . (val == 10 ? 0 : val)
        MsgBox(msg, "Warning", 0x30)
    } else {
        MsgBox("Settings have been successfully imported!", "Completed", 0x40)
    }

    UpdateSaveButton()
}