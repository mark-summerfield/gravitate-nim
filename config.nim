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
import nigui
import os
import parsecfg
import strutils
import strformat

const
  cfgBoard* = "Board"
  cfgWindow* = "Window"
  cfgColumns* = "columns"
  cfgRows* = "rows"
  cfgMaxColors* = "maxColors"
  cfgDelayMs* = "delayMs"
  cfgHighScore* = "HighScore"
  cfgWidth* = "width"
  cfgHeight* = "height"
  cfgX* = "x"
  cfgY* = "y"

proc readConfig*(): Config =
  var filename = getConfigDir() / ConfigFilename
  if not existsFile(filename):
    filename = getHomeDir() / ".config" / ConfigFilename
    if not existsFile(filename):
      filename = getHomeDir() / ConfigFilename
      if not existsFile(filename):
        var config = newConfig()
        config.setSectionKey(cfgBoard, cfgColumns, $DefColumns)
        config.setSectionKey(cfgBoard, cfgRows, $DefRows)
        config.setSectionKey(cfgBoard, cfgMaxColors, $DefMaxColors)
        config.setSectionKey(cfgBoard, cfgDelayMs, $DefDelayMs)
        config.setSectionKey(cfgBoard, cfgHighScore, $0)
        config.setSectionKey(cfgWindow, cfgWidth, $Width)
        config.setSectionKey(cfgWindow, cfgHeight, $Height)
        config.setSectionKey(cfgWindow, cfgX, $InvalidPos)
        config.setSectionKey(cfgWindow, cfgY, $InvalidPos)
        return config
  return loadConfig(filename)

proc saveConfig*(ui: UI) =
  let filename = getConfigDir() / ConfigFilename
  var config = newConfig()
  config.setSectionKey(cfgBoard, cfgColumns, $ui.game.columns)
  config.setSectionKey(cfgBoard, cfgRows, $ui.game.rows)
  config.setSectionKey(cfgBoard, cfgMaxColors, $ui.game.maxColors)
  config.setSectionKey(cfgBoard, cfgDelayMs, $ui.game.delayMs)
  config.setSectionKey(cfgBoard, cfgHighScore, $ui.highScore)
  config.setSectionKey(cfgWindow, cfgWidth, $ui.mainwindow.width)
  config.setSectionKey(cfgWindow, cfgHeight, $ui.mainwindow.height)
  config.setSectionKey(cfgWindow, cfgX, $ui.mainwindow.x)
  config.setSectionKey(cfgWindow, cfgY, $ui.mainwindow.y)
  config.writeConfig(filename)

proc getInt*(config: Config, section, key: string, default=0): int =
  result = default
  let value = config.getSectionValue(section, key)
  if value != "":
    try:
      let n = parseInt(value)
      result = n
    except ValueError:
      echo(&"Invalid [{section}]{key}={value}")
  else:
    echo(&"Missing [{section}]{key}")
