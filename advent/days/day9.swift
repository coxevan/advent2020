//
//  day9.swift
//  advent
//
//  Created by Evan on 12/8/20.
//

import Foundation

let DELTA_INT = 25 // from where we are, minus this number is how far back to look | test is 5, real is 25

func get_all_numbers() -> Array<Int>{
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

func check_number(number: Int, number_array: Array<Int>, index: Int) -> Bool{
    // Check to see if this number is valid by checking against the previous DELTA_INT values in the array, if two of them equal the value, it's valid.
    // if no two DIFFERENT values don't equal our number, it's invalid (return False)
    let bottom_range = index - DELTA_INT
    for i in number_array[bottom_range...index]{
        for k in number_array[bottom_range...index]{
            if i == k{
                continue
            }
            let value = i + k
            if value == number{
                return true
            }
        }
    }
    return false
}

func sum_list(number: Int, number_array: Array<Int>, index: Int, target: Int) ->Array<Int>{
    // Add all values together in the array ahead of this number until it equals our target number
    // If our calc number goes above the target, get out
    var _index = index
    var calc_number = 0
    var target_range = Array<Int>()
    while calc_number < target{
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
        let valid_number = check_number(number:number, number_array:number_array, index:index)
        if !valid_number{
            invalid_number = number
            break
        }
    }
    print("Part 1:", invalid_number)
    
    // Part 2
    var weakness = 0
    for (index, number) in number_array.enumerated(){
        // add each number infront until it's bigger than the invalid number
        let result_range = sum_list(number:number, number_array:number_array, index:index, target: invalid_number)
        if !result_range.isEmpty{
            weakness = result_range.first! + result_range.last!
            break
        }
    }
    print("Part 2:", weakness)
}
