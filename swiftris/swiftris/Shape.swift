//
//  Shape.swift
//  swiftris
//
//  Created by Melissa Boring on 4/5/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

//shapes orientation
enum Orientation: Int, CustomStringConvertible
{
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String
    {
        switch self
        {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    
    static func random() -> Orientation
    {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    //return next orientation when traveling clockwith or counterclockwise
    static func rotate(orientation:Orientation, clockwise: Bool) -> Orientation
    {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.TwoSeventy.rawValue
        {
            rotated = Orientation.Zero.rawValue
        }
        else if rotated < 0
        {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
}



    // The number of total shape varieties
    let NumShapeTypes: UInt32 = 7
    
    // Shape indexes
    let FirstBlockIdx: Int = 0
    let SecondBlockIdx: Int = 1
    let ThirdBlockIdx: Int = 2
    let FourthBlockIdx: Int = 3
    
    class Shape: Hashable, CustomStringConvertible
    {
        // The color of the shape
        let color:BlockColor
        
        // The blocks comprising the shape
        var blocks = Array<Block>()
        
        // The current orientation of the shape
        var orientation: Orientation
        
        // The column and row representing the shape's anchor point
        var column, row:Int
        
        // Required Overrides
        // #computed dictionary
        // Subclasses must override this property
        var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]
        {
            return [:]
        }

        // Subclasses must override this property
        //computed property that returns the bottom blocks of the shape at its current orientation
        var bottomBlocksForOrientations: [Orientation: Array<Block>]
        {
            return [:]
        }
        
        // iterate through our entire blocks array
        var bottomBlocks:Array<Block>
        {
            guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
                return []
            }
            return bottomBlocks
        }
        
        // Hashable
        // we use the reduce<S : Sequence, U>(sequence: S, initial: U, combine: (U, S.GeneratorType.Element) -> U) -> U 
        // method to iterate through our entire blocks array. We exclusive-or (XOR) each block's hashValue together 
        // to create a single hashValue for the Shape they comprise
        var hashValue:Int
        {
            // A convenience initializer must call down to a standard initializer or otherwise your class will fail to compile
            return blocks.reduce(0) { $0.hashValue ^ $1.hashValue }
        }
        
        // CustomStringConvertible
        var description:String {
            return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
        }
        
        init(column:Int, row:Int, color: BlockColor, orientation:Orientation) {
            self.color = color
            self.column = column
            self.row = row
            self.orientation = orientation
            initializeBlocks()
        }
        
        //  A convenience initializer must call down to a standard initializer or otherwise your class will fail to compile
        convenience init(column:Int, row:Int)
        {
            self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
        }
        
        // cannot be overwritten
        final func initializeBlocks()
        {
            guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else
            {
                return
            }
            // use map to create blocks array
            // maps lets us create one array after looking over contents of another
            blocks = blockRowColumnTranslations.map { (diff) -> Block in
                return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
            }
        }
    }
    
    func ==(lhs: Shape, rhs: Shape) -> Bool
    {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }

