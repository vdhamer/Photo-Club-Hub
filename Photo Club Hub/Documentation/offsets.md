#  Offset calculation

constants
    maxCellRepeat = 32 // works as Int, but stored as Double
    minFrameDimension = 320-ish // min of frame.size.x and frame.size.y
var
    logCellRepeat = 5 // 2-log of implicit CellRepeat
    logScale = 5 // zoom setting in range 0 ... 5
    
cellPitchInPixels = minFrameDimension / maxCellRepeat // e.g. 320/32 = 10

offset = // (0...minFrameDimension, 0...minFrameDimension)
     cellPitchInPixels x offsetInCells // or zero if logScale == 0

offsetInCells = logScale==0 ? 0 : round(offset / cellPitechInPixels)
