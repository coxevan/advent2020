//
//  arrays.swift
//  advent
//
//  Created by Evan on 12/11/20.
//

import Foundation

func pop_first_index(array:Array<Int>, value:Int)->Array<Int>{
    var _array = array
    if let index = _array.firstIndex(of: value) {
        _array.remove(at: index)
    }
    return _array
}
func split_array_at_value(array:Array<Int>, value:Int)->Array<Int>{
    var _array = array
    if let index = _array.firstIndex(of: value) {
        _array = Array(array[index..<array.count])
    }
    return _array
}
