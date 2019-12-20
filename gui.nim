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

import common
import config
import game
import mainwindow
import nigui

proc newUI*(title: string): UI =
  result = UI()
  let config = readConfig()
  result.game = Game()
  result.makeMainWindow(title, config)
  result.prepareGame(config)
  result.highScore = config.getInt(cfgBoard, cfgHighScore)
  result.makeLayout()
  result.game.board.focus()

proc show*(ui: UI) =
  ui.mainWindow.show()
  ui.game.start()

proc makeLayout(ui: UI) =
  var vbox = newLayoutContainer(Layout_Vertical)
  vbox.widthMode = WidthMode_Expand
  vbox.heightMode = HeightMode_Expand
  vbox.xAlign = XAlign_Center
  var hbox = newLayoutContainer(Layout_Horizontal)
  hbox.widthMode = WidthMode_Expand
  hbox.heightMode = HeightMode_Static
  hbox.padding = 7
  hbox.add(ui.newButton)
  hbox.add(ui.optionsButton)
  hbox.add(ui.helpButton)
  hbox.add(ui.aboutButton)
  hbox.add(ui.quitButton)
  vbox.add(hbox)
  vbox.add(ui.game.board)
  vbox.add(ui.statusLabel)
  ui.equalizeButtonWidths()
  ui.mainWindow.add(vbox)

proc equalizeButtonWidths(ui: UI) =
  var width = 0
  let buttons = [ui.newButton, ui.optionsButton, ui.helpButton,
                 ui.aboutButton, ui.quitButton]
  for button in buttons:
    if button.width > width:
      width = button.width
  for button in buttons:
    button.width = width
