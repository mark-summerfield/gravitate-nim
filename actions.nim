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
import nigui
import nigui/msgbox
import strformat
import strutils
import times

proc onClose*(ui: UI) =
  ui.saveConfig()
  app.quit()

proc onHelp*(ui: UI) =
  ui.mainWindow.msgBox(&"""
The purpose of the game is to remove all the tiles.

Click a tile that has at least one vertically or
horizontally adjoining tile of the same color to remove it
and any vertically or horizontally adjoining tiles of the
same color, and their vertically or horizontally adjoining
tiles, and so on.
(So clicking a tile with no adjoining
tiles of the same color does nothing.)

The more tiles that are removed in one go,
the higher the score.

{AppName} works like TileFall and the SameGame except that
instead of tiles falling to the bottom and moving off to the
left, they “gravitate” to the middle.

Key — Action
a — About
d — Delete focused tile
h or F1 — Help (this window)
n — New game
o — Options
q or Esc — Quit
← — Move left
→ — Move right
↑ — Move up
↓ — Move down""", &"Help — {AppName}")

proc onAbout*(ui: UI) =
  let thisYear = now().year
  let year = if thisYear == 2019: "2019-20" else: &"2019-{thisYear - 2000}"
  let bits = 8 * sizeof(int)
  ui.mainWindow.msgBox(
    &"{AppName} v{Version}.\n\n" &
    &"Copyright © {year} Mark Summerfield. All Rights Reserved.\n\n" &
    &"{AppName} is free open source software licensed under the " &
    "GPLv3.\n\n" &
    "http://www.qtrac.eu/gravitate.html.\n\n" &
    &"Nim v{NimVersion} on {bits}-bit {capitalizeAscii(hostOS)} " &
    &"({hostCPU}).",
    &"About — {AppName}")

proc onChangeScore*(ui: UI, score: int, gameOver, userWon: bool) =
  if userWon:
    if score > ui.highScore:
      ui.statusLabel.text = &"{score} — New High!"
      ui.highScore = score
      ui.saveConfig()
    else:
      ui.statusLabel.text = &"{score} — You Won!"
  elif gameOver:
    ui.statusLabel.text = &"{score} — Game Over"
  elif score == 0 and ui.highScore == 0: # have never won
    ui.statusLabel.text = "Click a tile (or press Arrows, then 'd') to play"
  else: # playing or played before
    ui.statusLabel.text = &"{score}/{ui.highScore}"
