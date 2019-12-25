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

import nigui
import point

const
  AppName* = "Gravitate"
  Version* = "1.0.4"
  Margin* = if defined(windows): 60 else: 40
  Width* = 400
  Height* = Width + Margin
  InvalidPos* = -1
  ConfigFilename* = "gravitate.ini"
  DefColumns* = 9
  DefRows* = 9
  DefMaxColors* = 4
  DefDelayMs* = 200

type
  Game* = ref object
    board*: Control
    gameOver*: bool
    userWon*: bool
    score*: int
    tiles*: seq[seq[Color]]
    selected*: Point
    drawing*: bool
    onChangeScore*: proc(game: Game)
    columns*: int
    rows*: int
    maxColors*: int
    delayMs*: int

  UI* = ref object
    mainWindow*: Window
    newButton*: Button
    optionsButton*: Button
    helpButton*: Button
    aboutButton*: Button
    quitButton*: Button
    statusLabel*: Label
    game*: Game
    highScore*: int

  Way* = enum left, right, up, down
