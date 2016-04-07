//
//  Block.swift
//  swiftris
//
//  Created by Melissa Boring on 4/5/16.
//  Copyright © 2016 melbo. All rights reserved.
//

import SpriteKit

let NumberOfColors: UInt32 = 6

//enumeration is type of Int and implements CustomStringConvertible
enum BlockColor: Int, CustomStringConvertible {
    
    case Blue = 0,Orange,Purple,Red,Teal,Yellow
    
    //define COMPUTED PROPERTY - one that behaves like a typical variable but when accessing it, a code blocks generates its value each time
    var spriteName: String
    {
        switch self
        {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    //another computed property - adheres to the CustomStringConvertible property requires this function. Will fail to compile without it
    var description: String
    {
        return self.spriteName
    }
    
    // status function that returns a random choice of colors
    static func random() -> BlockColor
    {
        //creates a blockcolor
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

    //declare class that implements protocols
    class Block: Hashable, CustomStringConvertible
    {

        // Constants - cannot be reassigned (let )
        let color: BlockColor
        
        // Represent location of the block on our game board
        // Properties
        var column: Int
        var row: Int
        
        //visual element of the block used by GameScene to render and animate each Block
        var sprite: SKSpriteNode?
        
        // convenient short cut to recover the sprite's file name
        var spriteName: String
        {
            return color.spriteName
        }
        
        // calculated property
        // return exclusive or to generate unique integer for each block
        var hashValue: Int
        {
            return self.column ^ self.row
        }
        
        // must adhere to CustomStringConvertible protocol
        var description: String
        {
            return "\(color): [\(column), \(row)]"
        }
        
        //
        init(column:Int, row:Int, color:BlockColor)
        {
            self.column = column
            self.row = row
            self.color = color
        }
    }
    
    // custom operator when comparing one Block with another
    // returns true if both blocks are same location and color
    // Hashable protocol inherits from Equatable protocols; requires to provide this operator
    func ==(lhs: Block, rhs: Block) -> Bool
    {
        return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
    }

