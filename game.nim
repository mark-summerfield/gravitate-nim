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
import color
import common
import config
import heapqueue
import math
import nigui
import parsecfg
import point
import random
import sequtils
import sets
import tables

proc prepareGame*(ui: var UI, config: Config) =
  ui.game.board = newControl()
  ui.game.board.width = ui.mainWindow.width - Margin
  ui.game.board.height = ui.mainWindow.height - (2 * Margin)
  ui.makeBindings()
  ui.game.init(config)

proc init(game: Game, config: Config) =
  game.columns = config.getInt(cfgBoard, cfgColumns, DefColumns)
  game.rows = config.getInt(cfgBoard, cfgRows, DefRows)
  game.maxColors = config.getInt(cfgBoard, cfgMaxColors, DefMaxColors)
  game.delayMs = config.getInt(cfgBoard, cfgDelayMs, DefDelayMs)
  game.prepare()

proc prepare(game: Game) =
  game.gameOver = false
  game.userWon = false
  game.score = 0
  game.selected = newPoint()
  game.drawing = false

proc makeBindings(ui: UI) =
  ui.game.onChangeScore = proc(game: Game) =
    ui.onChangeScore(game.score, game.gameOver, game.userWon)

  ui.game.board.onDraw = proc(event: DrawEvent) =
    if len(ui.game.tiles) > 0:
      ui.game.draw(event)

  ui.game.board.onMouseButtonDown = proc(event: MouseEvent) =
    ui.game.onTileClick(event)

# In theory, especially if the board is small and the number of colors is
# large, it is possible to have a tile with a unique color, i.e., "game
# over". But I've never seen it in practice so haven't added code to
# prevent it.
proc start*(game: Game) =
  game.prepare()
  var colors = gameColors
  shuffle(colors)
  colors = colors[0 ..< game.maxColors]
  game.tiles = @[]
  for x in 0 ..< game.columns:
    game.tiles &= @[]
    for y in 0 ..< game.rows:
      game.tiles[x] &= sample(colors)
  game.draw()
  game.onChangeScore(game)

proc draw(game: Game; delayMs = 0) =
  if delayMs > 0:
    app.sleep(float(delayMs))
  game.board.forceRedraw()

proc draw(game: Game; event: DrawEvent) =
  if game.drawing:
    return
  game.drawing = true
  try:
    let canvas = game.board.canvas
    let (width, height) = game.tileSize()
    for x in 0 ..< len(game.tiles):
      for y in 0 ..< len(game.tiles[0]):
        game.drawTile(canvas, x, y, width, height)
  finally:
    game.drawing = false

proc drawTile(game: Game; canvas: Canvas; x, y, width, height: int) =
  let color = game.tiles[x][y]
  let isSelected = (game.selected.isValid() and game.selected.x == x and
                    game.selected.y == y)
  let x = x * width
  let y = y * height
  if color == invalidColor:
    canvas.areaColor = bgColor
    canvas.drawRectArea(x, y, width, height)
  else:
    canvas.areaColor = if game.gameOver: morph(color, 0.75) else: color
    canvas.lineColor = outlineColor
    canvas.lineWidth = 2.5
    canvas.drawRectArea(x, y, width, height)
    canvas.drawRectOutline(x, y, width, height)
    if isSelected:
      game.drawFocus(canvas, x, y, width, height)

proc drawFocus(game: Game, canvas: Canvas, x, y, width, height: int) =
  canvas.lineWidth = 2.0
  canvas.lineColor = morph(selectedColor, 0.65)
  var indent = 5
  canvas.drawRectOutline(x + indent, y + indent, width - (2 * indent),
                         height - (2 * indent))
  canvas.lineColor = selectedColor
  indent += 2
  canvas.drawRectOutline(x + indent, y + indent, width - (2 * indent),
                         height - (2 * indent))

proc tileSize(game: Game): (int, int) =
  (game.board.canvas.width div game.columns,
   game.board.canvas.height div game.rows)

proc onTileClick(game: Game; event: MouseEvent) =
  if game.gameOver or game.drawing:
    return
  let (width, height) = game.tileSize()
  let x = event.x div width
  let y = event.y div height
  invalidate(game.selected)
  game.deleteTiles(x, y)

proc deleteTiles(game: Game; x, y: int) =
  let color = game.tiles[x][y]
  if color == invalidColor or not game.isLegal(x, y, color):
    return
  game.dimAdjoining(x, y, color)

proc isLegal(game: Game; x, y: int; color: Color): bool =
  # A legal click is on a colored tile that is adjacent to another tile
  # of the same color.
  if x > 0 and game.tiles[x - 1][y] == color:
    true
  elif x + 1 < game.columns and game.tiles[x + 1][y] == color:
    true
  elif y > 0 and game.tiles[x][y - 1] == color:
    true
  elif y + 1 < game.rows and game.tiles[x][y + 1] == color:
    true
  else:
    false

proc dimAdjoining(game: Game; x, y: int; color: Color) =
  var adjoining = PointSet()
  game.populateAdjoining(x, y, color, adjoining)
  for p in adjoining: # darken
    game.tiles[p.x][p.y] = game.tiles[p.x][p.y].morph(0.5)
  game.draw(delayMs = game.delayMs)
  app.sleep(float(game.delayMs))
  game.deleteAdjoining(adjoining)

proc populateAdjoining(game: Game; x, y: int; color: Color;
                       adjoining: var PointSet) =
  if not (0 <= x and x < game.columns and 0 <= y and y < game.rows):
    return # Fallen off an edge
  let p = newPoint(x, y)
  if p in adjoining or game.tiles[x][y] != color:
    return # Color doesn't match or already done
  adjoining.incl(p)
  game.populateAdjoining(x - 1, y, color, adjoining)
  game.populateAdjoining(x + 1, y, color, adjoining)
  game.populateAdjoining(x, y - 1, color, adjoining)
  game.populateAdjoining(x, y + 1, color, adjoining)

proc deleteAdjoining(game: Game; adjoining: var PointSet) =
  for p in adjoining:
    game.tiles[p.x][p.y] = invalidColor
  game.draw(delayMs = max(5, game.delayMs div 50))
  app.sleep(float(game.delayMs))
  game.closeTilesUp(len(adjoining))

proc closeTilesUp(game: Game; count: int) =
  game.moveTiles()
  if game.selected.isValid():
    if game.tiles[game.selected.x][game.selected.y] == invalidColor:
      game.selected = newPoint(game.columns div 2, game.rows div 2)
  game.draw()
  game.score += int(math.round(math.sqrt(float(game.columns * game.rows)) +
                    math.pow(float(count), float(game.maxColors) / 2)))
  game.checkGameOver()
  game.onChangeScore(game)

proc moveTiles(game: Game) =
  var moved = true
  var moves = initTable[Point, Point]()
  while moved:
    moved = false
    for x in randomRange(game.columns):
      for y in randomRange(game.rows):
        if game.tiles[x][y] != invalidColor:
          if game.moveIsPossible(x, y, moves):
            moved = true
            break

proc randomRange(limit: int): seq[int] =
  result = toSeq(0 ..< limit)
  shuffle(result)

proc moveIsPossible(game: Game; x, y: int;
                    moves: var Table[Point, Point]): bool =
  let p = newPoint(x, y)
  let empties = game.emptyNeighbours(x, y)
  if len(empties) > 0:
    let (move, np) = game.nearestToMiddle(x, y, empties)
    let seen = moves.getOrDefault(np, newPoint())
    if seen.isValid() and seen == p:
      return false # avoid endless loop back and forth
    if move:
      game.tiles[np.x][np.y] = game.tiles[x][y]
      game.tiles[x][y] = invalidColor
      moves[p] = np
      game.draw(max(1, game.delayMs div 7))
      return true
  return false


proc emptyNeighbours(game: Game; x, y: int): PointSet =
  result.init()
  for (x, y) in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]:
    if (0 <= x and x < game.columns and 0 <= y and y < game.rows and
        game.tiles[x][y] == invalidColor):
      result.incl(newPoint(x, y))

proc nearestToMiddle(game: Game; x, y: int; empties: PointSet):
    (bool, Point) =
  let color = game.tiles[x][y]
  let midx = game.columns div 2
  let midy = game.rows div 2
  let dold = math.hypot(float(midx - x), float(midy - y))
  var dnew = 0.0
  var heap = initHeapQueue[GradedPoint]()
  for p in empties:
    if game.isSquare(p.x, p.y):
      dnew = math.hypot(float(midx - p.x), float(midy - p.y))
      if game.isLegal(p.x, p.y, color):
        dnew -= 0.1 # Make same colors slightly attractive
      heap.push(newGradedPoint(dnew, p))
  let gradedPoint = heap[0]
  dnew = gradedPoint.priority
  if dold > dnew: (true, gradedPoint.point) else: (false, newPoint(x, y))

proc isSquare(game: Game; x, y: int): bool =
  if x > 0 and game.tiles[x - 1][y] != invalidColor:
    true
  elif x + 1 < game.columns and game.tiles[x + 1][y] != invalidColor:
    true
  elif y > 0 and game.tiles[x][y - 1] != invalidColor:
    true
  elif y + 1 < game.rows and game.tiles[x][y + 1] != invalidColor:
    true
  else:
    false

proc checkGameOver(game: Game) =
  var countForColor = initCountTable[Color]()
  game.userWon = true
  var canMove = false
  for x in 0 ..< game.columns:
    for y in 0 ..< game.rows:
      let color = game.tiles[x][y]
      if color != invalidColor:
        game.userWon = false
        countForColor.inc(color)
        if game.isLegal(x, y, color):
          canMove = true
  for count in countForColor.values():
    if count == 1:
      canMove = false
      break
  if not game.userWon and not canMove:
    game.gameOver = true

proc chooseTile*(game: Game) =
  if game.gameOver or game.userWon:
    return
  if game.selected.isValid():
    game.deleteTiles(game.selected.x, game.selected.y)

proc navigate*(game: Game, way: Way) =
  if game.gameOver or game.userWon:
    return
  if not game.selected.isValid():
    game.selected = newPoint(game.columns div 2, game.rows div 2)
  else:
    var x = game.selected.x
    var y = game.selected.y
    case way
    of Way.left: dec x
    of Way.right: inc x
    of Way.up: dec y
    of Way.down: inc y
    if (0 <= x and x < game.columns and 0 <= y and y < game.rows and
        game.tiles[x][y] != invalidColor):
      game.selected = newPoint(x, y)
  game.draw()
