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

import strutils
import unicode

proc comma*[T](n: T): string =
  for (i, c) in reversed($n).pairs():
    result.add(c)
    if i mod 3 == 2:
      result.add(',')
  if result.endsWith(','):
    result = result[0 .. ^2]
  return reversed(result)
