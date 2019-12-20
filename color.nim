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

from colors import nil
import hashes
import nigui

const
  gameColors* = @[
      rgb(0x64, 0x95, 0xED),
      rgb(0x46, 0x82, 0xB4),
      rgb(0x00, 0xCE, 0xD1),
      rgb(0x2E, 0x8B, 0x57),
      rgb(0x6B, 0x8E, 0x23),
      rgb(0xBD, 0xB7, 0x6B),
      rgb(0xBC, 0x8F, 0x8F),
      rgb(0xCD, 0x5C, 0x5C),
      rgb(0xDD, 0xA0, 0xDD),
      rgb(0x93, 0x70, 0xDB),
      rgb(0xEE, 0xC9, 0x00),
      rgb(0x7F, 0x7F, 0x7F),
      rgb(0x38, 0x8E, 0x8E),
      rgb(0x71, 0xC6, 0x71),
      rgb(0x8E, 0x38, 0x8E),
      rgb(0xFF, 0x82, 0xAB),
      rgb(0xFF, 0xA5, 0x00),
    ]
  bgColor* = rgb(0xFF, 0xE0, 0xE0)
  outlineColor* = rgb(0xFF, 0xFE, 0xF0)
  selectedColor* = rgb(0xE0, 0xD0, 0xD0)
  invalidColor* = rgb(0xFF, 0xFF, 0xFE)

proc hash*(color: Color): Hash =
  var h: Hash = int(color.red)
  h = h !& int(color.green)
  h = h !& int(color.blue)
  !$h

# intensity: 0.0 = very dark, 1.0 = very light
proc morph*(color: Color, intensity: float): Color =
  let n = (int(color.red).shl(16) or int(color.green).shl(8) or
           int(color.blue))
  let color = colors.intensity(colors.Color(n), intensity)
  let components = colors.extractRGB(color)
  rgb(byte(components.r), byte(components.g), byte(components.b))
