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

import actions
import common
import config
import game
import nigui
import options
import parsecfg

proc makeMainWindow*(ui: UI, title: string, config: Config) =
  ui.mainWindow = newWindow(title)
  ui.mainWindow.width = config.getInt(cfgWindow, cfgWidth, Width)
  ui.mainWindow.height = config.getInt(cfgWindow, cfgHeight, Height)
  let x = config.getInt(cfgWindow, cfgX, InvalidPos)
  let y = config.getInt(cfgWindow, cfgY, InvalidPos)
  if x != InvalidPos and y != InvalidPos:
    ui.mainWindow.x = x
    ui.mainWindow.y = y
  ui.makeButtons()
  ui.statusLabel = newLabel()
  ui.makeBindings()

proc makeButtons(ui: UI) =
  ui.newButton = newButton("New")
  ui.optionsButton = newButton("Options")
  ui.helpButton = newButton("Help")
  ui.aboutButton = newButton("About")
  ui.quitButton = newButton("Quit")

proc makeBindings(ui: UI) =
  ui.mainWindow.onResize = proc(event: ResizeEvent) =
    ui.game.board.width = ui.mainWindow.width - Margin
    ui.game.board.height = ui.mainWindow.height - int(2.3 * float(Margin))

  ui.newButton.onClick = proc(event: ClickEvent) =
    ui.game.start()

  ui.optionsButton.onClick = proc(event: ClickEvent) =
    ui.onOptions()

  ui.helpButton.onClick = proc(event: ClickEvent) =
    ui.onHelp()

  ui.aboutButton.onClick = proc(event: ClickEvent) =
    ui.onAbout()

  ui.quitButton.onClick = proc(event: ClickEvent) =
    ui.onClose()

  ui.mainWindow.onCloseClick = proc(event: CloseClickEvent) =
    ui.onClose()

  ui.mainWindow.onKeyDown = proc(event: KeyboardEvent) =
    ui.onKey(event.key)

# Can't put this in actions since it would be a circular import
proc onKey(ui: UI, key: Key) =
  case key
  of Key_A: ui.onAbout()
  of Key_D: ui.game.chooseTile() # delete tiles
  of Key_H, Key_F1: ui.onHelp()
  of Key_N: ui.game.start() # new game
  of Key_O: ui.onOptions()
  of Key_Q, Key_Escape: ui.onClose()
  of Key_Left: ui.game.navigate(Way.left)
  of Key_Right: ui.game.navigate(Way.right)
  of Key_Up: ui.game.navigate(Way.up)
  of Key_Down: ui.game.navigate(Way.down)
  else: discard

proc onOptions(ui: UI) =
  if ui.showOptionsWindow():
    ui.game.start()
