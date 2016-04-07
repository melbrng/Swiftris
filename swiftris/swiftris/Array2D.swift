//
//  Array2D.swift
//  swiftris
//
//  Created by Melissa Boring on 4/5/16.
//  Copyright © 2016 melbo. All rights reserved.
//

// class is used throughout the game so we are using the same data
// we can pass class objects by reference ( same data )
// typed parameter <T> allows our array to store any data type and remain general purpose
class Array2D<T>
{
    let columns: Int
    let rows: Int
    
    // declare the swift array and declare with an optional type (optional may or may not contain data and in fact be nil or empty
    // nil locations found on the game board represent empty spots where no block is present
    // typed parameter <T> allows our array to store any data type and remain general purpose
    var array: Array<T?>
    
    init(columns: Int, rows: Int)
    {
        self.columns = columns
        self.rows = rows
        
        // instantiate our array
        // create array of certain size with all of its values set to the same default value ( repeatedValue )
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    // custom subscript for  Array2D
    // subscript are shortcuts for accessing member elements of a collection,list or sequence
    subscript(column: Int, row: Int) -> T?
        {
        
        get
        {
            return array[(row * columns) + column]
        }
        
        set(newValue)
        {
            array[(row * columns) + column] = newValue
        }
    }
}
