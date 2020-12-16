//
//  strings.swift
//  advent
//
//  Created by Evan on 12/12/20.
//

import Foundation

func get_string_after_character(base_string: String, character: String)->String{
    // Get the base string after the passed character
    var value_str = ""
    if let range = base_string.range(of: character) {
        value_str = String(base_string[range.upperBound...])
    }
    return value_str
}

func get_string_before_character(base_string: String, character: String)->String{
    // Get the base string before the passed character
    var value_str = ""
    if let range = base_string.range(of: character){
        value_str = String(base_string[...range.lowerBound])
    }
    return value_str
}

func pad(string : String, toSize: Int) -> String {
    // Pad with 0's until the incoming string reaches the desired size
    var padded = string
    for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
        }
    return padded
}

func int_to_binary_string(value:Int, length: Int)->String{
    // convert an integar to a binary string with leading 0's to make it the length specified
    // input : 2, length 4
    // output: 0010
    return pad(string: String(value, radix: 2), toSize: length)
}
