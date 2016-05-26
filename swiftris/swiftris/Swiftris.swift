//
//  Swiftris.swift
//  swiftris
//
//  Created by Melissa Boring on 4/5/16.
//  Copyright © 2016 melbo. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 500

protocol SwiftrisDelegate
{
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    // Invoked after a new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
}

class Swiftris
{
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    
    var score = 0
    var level = 1
    
    init()
    {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame()
    {
        if (nextShape == nil)
        {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        
        delegate?.gameDidBegin(self)
    }
    
    //The game ends when a new shape located at the designated starting location collides with existing blocks. 
    //This is the case where the player no longer has room to move the new shape, and we must destroy their tower of terror.
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?)
    {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        guard detectIllegalPlacement() == false else
        {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil,nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    
    //checks block boundary conditions
    func detectIllegalPlacement() -> Bool
    {
        guard let shape = fallingShape else
        {
            return false
        }
        
        for block in shape.blocks
        {
            if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows
            {
                return true
            }
            else if blockArray[block.column,block.row] != nil
            {
                return true
            }
        }
        return false
    }

    //adds the falling shape to the collection of blocks maintained by Swiftris
    func settleShape()
    {
        guard let shape = fallingShape else
        {
            return
        }
        for block in shape.blocks
        {
            blockArray[block.column, block.row] = block
        }
        
        fallingShape = nil
        delegate?.gameShapeDidLand(self)
    }
    
    // Swiftris needs to be able to tell when a shape should settle. This happens under two conditions: when one of the shapes' bottom blocks touches a block on the game board or when one of those same blocks has reached the bottom of the game board.
    func detectTouch() -> Bool
    {
        guard let shape = fallingShape else
        {
            return false
        }
        
        for bottomBlock in shape.bottomBlocks
        {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil
            {
                return true
            }
        }
        return false
    }
    
    func endGame()
    {
        score = 0
        level = 1
       // scene.gameCounter = 0
        delegate?.gameDidEnd(self)
    }

    // linesRemoved each row of blocks the user has filled in
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>)
    {
        var removedLines = Array<Array<Block>>()
        for var row = NumRows - 1; row > 0; row -= 1
        {
            var rowOfBlocks = Array<Block>()
            
            // add every block in a row to rowOfBlocks
            for column in 0..<NumColumns
            {
                guard let block = blockArray[column, row] else
                {
                    continue
                }
                rowOfBlocks.append(block)
            }
            
            // if ends up with a full set, counted as removed line and adds to return variable
            if rowOfBlocks.count == NumColumns
            {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks
                {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // did we recover any lines? if not return empty arrays
        if removedLines.count == 0
        {
            return ([], [])
        }
        
        // add points to player's score based on number of lines created and level
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        
        // if score exceeds their level , level up and inform the delegate
        if score >= level * LevelThreshold
        {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        // array of arrays
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns
        {
            var fallenBlocksArray = Array<Block>()
            
            // count upwards from lower left and above bottom most removed line, count upwards to top of game board 
            // take each remaining block we find on game board and lower it as far as possible
            for var row = removedLines[0][0].row - 1; row > 0; row -= 1
            {
                guard let block = blockArray[column, row] else
                {
                    continue
                }
                
                var newRow = row
                
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil)
                {
                    newRow += 1
                }
                
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0
            {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    //Dropping a shape is the act of sending it plummeting towards the bottom of the game board. The user will elect to do this when their patience for the slow-moving Tetromino wears thin. #4 provides a convenient function to achieve this. It will continue dropping the shape by a single row until it detects an illegal placement state, at which point it will raise it and then notify the delegate that a drop has occurred.
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(self)
    }
    
    // function to call once every tick. This attempts to lower the shape by one row and ends the game if it fails to do so without finding legal placement for it
    func letShapeFall()
    {
        guard let shape = fallingShape else
        {
            return
        }
        
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement()
        {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement()
            {
                endGame()
            }
            else
            {
                settleShape()
            }
            
        }
        else
        {
            delegate?.gameShapeDidMove(self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    // allow the player to rotate the shape clockwise as it falls 
    //If its new block positions violate the boundaries of the game or overlap with settled blocks, we revert the rotation and return. Otherwise, we let the delegate know that the shape has moved.
    func rotateShape()
    {
        guard let shape = fallingShape else
        {
            return
        }
        
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else
        {
            shape.rotateCounterClockwise()
            return
        }
        
        delegate?.gameShapeDidMove(self)
    }
    
    // moving the shape either leftwards or rightwards
    func moveShapeLeft()
    {
        guard let shape = fallingShape else
        {
            return
        }
        
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else
        {
            shape.shiftRightByOneColumn()
            return
        }
        
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeRight()
    {
        guard let shape = fallingShape else
        {
            return
        }
        shape.shiftRightByOneColumn()
        
        guard detectIllegalPlacement() == false else
        {
            shape.shiftLeftByOneColumn()
            return
        }
        
        delegate?.gameShapeDidMove(self)
    }
    
    // allow ui to remove blocks
    // loops through and creates rows of blocks in order for the game scene to animate them off the game board. 
    // it nullifies each location in the block array to empty it entirely, preparing it for a new game.
    //
    func removeAllBlocks() -> Array<Array<Block>>
    {
        var allBlocks = Array<Array<Block>>()
        
        for row in 0..<NumRows
        {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns
            {
                guard let block = blockArray[column, row] else
                {
                    continue
                }
                
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
}
