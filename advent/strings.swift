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
