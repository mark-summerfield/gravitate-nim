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

import hashes
import sets

const Invalid = -1

type
  Point* = object
    x*: int
    y*: int

  PointSet* = HashSet[Point]

  GradedPoint* = object
    priority*: float
    point*: Point

proc newPoint*(x, y: int): Point =
  result.x = x
  result.y = y

proc newPoint*(): Point =
  result.x = Invalid
  result.y = Invalid

proc isValid*(point: Point): bool =
  point.x != Invalid and point.y != Invalid

proc invalidate*(point: var Point) =
  point.x = Invalid
  point.y = Invalid

proc hash*(point: Point): Hash =
  var h: Hash = 0
  h = h !& hash(point.x)
  h = h !& hash(point.y)
  !$h

proc newGradedPoint*(priority: float, point: Point): GradedPoint =
  result.priority = priority
  result.point = point

proc newGradedPoint*(priority: float, x, y: int): GradedPoint =
  result.priority = priority
  result.point.x = x
  result.point.y = y

proc `<`*(a, b: GradedPoint): bool =
  if a.priority != b.priority:
    a.priority < b.priority
  elif a.point.x != b.point.x:
    a.point.x < b.point.x
  else:
    a.point.y < b.point.y
