//
//  SquareShape.swift
//  swiftris
//
//  Created by Melissa Boring on 4/5/16.
//  Copyright © 2016 melbo. All rights reserved.
//

class SquareShape:Shape
{
    /*
     // #9
     | 0•| 1 |
     | 2 | 3 |
     
     • marks the row/column indicator for the shape
     
     */
    
    // The square shape will not rotate
    
    // overridden the blockRowColumnPositions computed property to provide a full dictionary of tuple arrays
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]
    {
        return [
            Orientation.Zero: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.OneEighty: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.Ninety: [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.TwoSeventy: [(0, 0), (1, 0), (0, 1), (1, 1)]
        ]
    }
    
    // by providing a dictionary of bottom block arrays
    override var bottomBlocksForOrientations: [Orientation: Array<Block>]
    {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
