//
//  day9.swift
//  advent
//
//  Created by Evan on 12/8/20.
//

import Foundation

let DELTA_INT = 25 // from where we are, minus this number is how far back to look | test is 5, real is 25

fileprivate func get_all_numbers() -> Array<Int>{
    guard let numbers = get_file_contents(fileName: "input_day9.txt") else{
        fatalError("Failed to read file")
    }
    var number_array = Array<Int>()
    for number in numbers{
        let num = Int(number)!
        number_array.append(num)
    }
    return number_array
}

func can_sum_backward_to_target(slice_index: Int, delta: Int, number_array: Array<Int>, target: Int) -> Bool{
    // Check to see if this number is valid by checking against the previous DELTA_INT values in the array, if two of them equal the value, it's valid.
    // if no two DIFFERENT values don't equal our number, it's invalid (return False)
    let bottom_range = slice_index - delta
    for i in number_array[bottom_range...slice_index]{
        for k in number_array[bottom_range...slice_index]{
            if i == k{
                continue
            }
            let value = i + k
            if value == target{
                return true
            }
        }
    }
    return false
}

func can_sum_forward_to_target(starting_index: Int, number_array: Array<Int>, target: Int) ->Array<Int>{
    // Starting at this index, can the list equal the target number
    // Returns the list of numbers, sorted that can sum to target
    
    var _index = starting_index
    var calc_number = 0
    var target_range = Array<Int>()
    while calc_number < target{
        // Add all values together in the array ahead of the starting index
        // If our calc number goes above the target, get out
        let add_num = number_array[_index]
        target_range.append(add_num)
        calc_number += add_num
        if calc_number == target{
            return target_range.sorted()
        }
        _index += 1
    }
    return Array<Int>()
}

func day9(){
    let number_array = get_all_numbers()
    // Part 1
    var invalid_number = 0
    for (index, number) in number_array.enumerated(){
        if index < DELTA_INT{
            continue
        }
        let valid_number = can_sum_backward_to_target(slice_index:index, delta: DELTA_INT, number_array:number_array, target: number)
        if !valid_number{
            invalid_number = number
            break
        }
    }
    print("Part 1:", invalid_number)
    
    // Part 2
    var weakness = 0
    for (index, _) in number_array.enumerated(){
        // determine if the list summed starting at each number will equal the target value
        let result_range = can_sum_forward_to_target(starting_index:index, number_array:number_array, target: invalid_number)
        if !result_range.isEmpty{
            weakness = result_range.first! + result_range.last!
            break
        }
    }
    print("Part 2:", weakness)
}
