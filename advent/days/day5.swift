//
//  day5.swift
//  advent
//
//  Created by Evan on 12/5/20.
//

import Foundation

let UPPER_RANGE_ROW_MAP = ["F": "0",  "B": "1"]
let UPPER_RANGE_COL_MAP = ["L": "0",  "R": "1"]

func get_row(seat_guid:String) -> Int?{
    return _get_int_from_id(seat_guid:seat_guid, range_char_map:UPPER_RANGE_ROW_MAP, starting_index:0)
}

func get_column(seat_guid:String) -> Int?{
    return _get_int_from_id(seat_guid:seat_guid, range_char_map:UPPER_RANGE_COL_MAP, starting_index:7)
}

func _get_int_from_id(seat_guid:String, range_char_map:Dictionary<String, String>, starting_index:Int=0) -> Int?{
    // The seat id is just two binary numbers smashed together, the first 7 digits make up the row, the last 3 are the column.
    // Convert F to 0 and B to 1
    // Convert L to 0 and R to 1
    // Long term can probably convert this to a full string find/replace and then split, to determine seperate row and column numbers
    var bin_string = ""
    for (index, char) in seat_guid.enumerated(){
        if index < starting_index{
            continue
        }
        let keyExists = range_char_map[String(char)] != nil
        if !keyExists{
            break
        }
        bin_string += range_char_map[String(char)]!
        }
    
    if let number = Int(bin_string, radix: 2) {
        return number
    }
    return nil
}


func day5(){
    guard let boarding_passes = get_file_contents_safe(fileName:"input_day5.txt") else{
        fatalError("Failed to read file")
    }
    
    // Find all the seat ids
    var max_seat_id = 0
    var seat_array = Array<Int>()
    for seat_guid in boarding_passes{
        let row = get_row(seat_guid:seat_guid) ?? -1
        let col = get_column(seat_guid:seat_guid) ?? -1

        if row < 0 || col < 0{
            print("failed to find row or column for seat guid \(seat_guid), row \(row), col \(col)")
        }
        
        let seat_id = row * 8 + col
        if seat_id > max_seat_id{
            max_seat_id = seat_id
        }
        seat_array.append(seat_id)
    }
    print("Max seat id is \(max_seat_id)")

    // Find my seat
    seat_array.sort()
    for element in seat_array{
        let potential_seat = element + 1
        let index = seat_array.contains(potential_seat)
        if !index{
            print("My Seat is : \(potential_seat)")
            break
        }
    }
}
