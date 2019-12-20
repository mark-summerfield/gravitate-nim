# Copyright © 2019-20 Mark Summerfield
#
# This program or module is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version. It is provided for
# educational purposes and is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
{.experimental: "codeReordering".}

import color
import common
import nigui
import strformat
import strutils

type
  OptionsUI = ref object
    window: Window
    columnsLabel: Label
    columnsText: TextBox
    rowsLabel: Label
    rowsText: TextBox
    maxColorsLabel: Label
    maxColorsText: TextBox
    delayLabel: Label
    delayText: TextBox
    statusLabel: Label
    okButton: Button
    cancelButton: Button
    allValid: bool
    ok: bool

proc showOptionsWindow*(ui: UI): bool =
  var optionsUI = OptionsUI()
  optionsUI.allValid = true
  optionsUI.ok = false
  ui.makeWidgets(optionsUI)
  optionsUI.makeLayout()
  ui.makeBindings(optionsUI)
  optionsUI.window.showModal(ui.mainwindow)
  while not optionsUI.window.disposed:
    app.sleep(100)
  optionsUI.ok

proc makeWidgets(ui: UI, optionsUI: var OptionsUI) =
  let labelWidth = 100
  let textWidth = 80
  let buttonWidth = 80
  optionsUI.window = newWindow(&"Options — {AppName}")
  optionsUI.window.width = labelWidth + textWidth + Margin
  optionsUI.window.height = 6 * Margin
  optionsUI.columnsLabel = newLabel("Columns")
  optionsUI.columnsLabel.width = labelWidth
  optionsUI.columnsText = newTextBox($ui.game.columns)
  optionsUI.columnsText.width = textWidth
  optionsUI.rowsLabel = newLabel("Rows")
  optionsUI.rowsLabel.width = labelWidth
  optionsUI.rowsText = newTextBox($ui.game.rows)
  optionsUI.rowsText.width = textWidth
  optionsUI.maxColorsLabel = newLabel("Max. Colors")
  optionsUI.maxColorsLabel.width = labelWidth
  optionsUI.maxColorsText = newTextBox($ui.game.maxColors)
  optionsUI.maxColorsText.width = textWidth
  optionsUI.delayLabel = newLabel("Delay (ms)")
  optionsUI.delayLabel.width = labelWidth
  optionsUI.delayText = newTextBox($ui.game.delayMs)
  optionsUI.delayText.width = textWidth
  optionsUI.statusLabel = newLabel("Current options")
  optionsUI.okButton = newButton("OK")
  optionsUI.okButton.width = buttonWidth
  optionsUI.cancelButton = newButton("Cancel")
  optionsUI.cancelButton.width = buttonWidth

proc makeLayout(optionsUI: var OptionsUI) =
  var vbox = newLayoutContainer(Layout_Vertical)
  vbox.widthMode = WidthMode_Expand
  vbox.xAlign = XAlign_Center
  var hbox = newLayoutContainer(Layout_Horizontal)
  hbox.add(optionsUI.columnsLabel)
  hbox.add(optionsUI.columnsText)
  vbox.add(hbox)
  hbox = newLayoutContainer(Layout_Horizontal)
  hbox.add(optionsUI.rowsLabel)
  hbox.add(optionsUI.rowsText)
  vbox.add(hbox)
  hbox = newLayoutContainer(Layout_Horizontal)
  hbox.add(optionsUI.maxColorsLabel)
  hbox.add(optionsUI.maxColorsText)
  vbox.add(hbox)
  hbox = newLayoutContainer(Layout_Horizontal)
  hbox.add(optionsUI.delayLabel)
  hbox.add(optionsUI.delayText)
  vbox.add(hbox)
  vbox.add(optionsUI.statusLabel)
  hbox = newLayoutContainer(Layout_Horizontal)
  hbox.xAlign = XAlign_Center
  hbox.padding = 7
  hbox.add(optionsUI.okButton)
  hbox.add(optionsUI.cancelButton)
  vbox.add(hbox)
  optionsUI.window.add(vbox)

proc makeBindings(ui: UI, optionsUI: OptionsUI) =
  let checkIsInt = proc(event: TextChangeEvent) =
    optionsUI.checkInts()

  optionsUI.columnsText.onTextChange = checkIsInt
  optionsUI.rowsText.onTextChange = checkIsInt
  optionsUI.maxColorsText.onTextChange = checkIsInt
  optionsUI.delayText.onTextChange = checkIsInt

  optionsUI.okButton.onClick = proc(event: ClickEvent) =
    ui.onOk(optionsUI)

  optionsUI.window.onKeyDown = proc(event: KeyboardEvent) =
    case event.key
    of Key_O, Key_Return: ui.onOk(optionsUI)
    of Key_C, Key_Escape: optionsUI.window.dispose()
    else: discard

  optionsUI.cancelButton.onClick = proc(event: ClickEvent) =
    optionsUI.window.dispose()

  optionsUI.window.onCloseClick = proc(event: CloseClickEvent) =
    optionsUI.window.dispose()

proc onOk(ui: UI, optionsUI: OptionsUI) =
  if not optionsUI.allValid:
    return
  ui.game.columns = getInt(optionsUI.columnsText.text, ui.game.columns)
  ui.game.rows = getInt(optionsUI.rowsText.text, ui.game.rows)
  ui.game.maxColors = getInt(optionsUI.maxColorsText.text,
                             ui.game.maxColors)
  ui.game.delayMs = getInt(optionsUI.delayText.text, ui.game.delayMs)
  optionsUI.ok = true
  optionsUI.window.dispose()

proc checkInts(optionsUI: OptionsUI) =
  optionsUI.statusLabel.text = "All options are valid"
  optionsUI.allValid = false
  for (name, textBox, minimum, maximum, default) in [
      ("columns", optionsUI.columnsText, 5, 30, DefColumns),
      ("rows", optionsUI.rowsText, 5, 30, DefRows),
      ("max. colors", optionsUI.maxColorsText, 2, len(gameColors),
       DefMaxColors),
      ("delay", optionsUI.delayText, 0, 1000, DefDelayMs)]:
    try:
      textBox.backgroundColor = rgb(0xFF, 0xFF, 0xFF) # white
      let i = parseInt(textBox.text)
      if i < minimum:
        optionsUI.onInvalid(textBox,
                            &"{name} is too small: min = {minimum}")
        return
      elif i > maximum:
        optionsUI.onInvalid(textBox, &"{name} is too big: max = {maximum}")
        return
    except ValueError:
      optionsUI.onInvalid(textBox, &"Invalid {name}: default = {default}")
      return
  optionsUI.allValid = true

proc onInvalid(optionsUI: OptionsUI, textBox: TextBox, message: string) =
  textBox.backgroundColor = rgb(0xFF, 0xB6, 0xC1) # light pink
  optionsUI.statusLabel.text = message

proc getInt(text: string, default: int): int =
  result = default
  try:
    let n = parseInt(text)
    result = n
  except ValueError:
    discard # use default
