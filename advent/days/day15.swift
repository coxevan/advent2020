//
//  day15.swift
//  advent
//
//  Created by Evan on 12/16/20.
//

import Foundation

let TARGET_TURN = 30000000 // What turn do you want to know the output value of?


func get_starting_numbers()->Array<Int>{
    let str_numbers = get_file_contents(fileName: "input_day15.txt")
    var number_array = Array<Int>()
    for num in str_numbers{
        number_array.append(Int(num)!)
    }
    return number_array
}
func day15(){
    let starting_numbers = get_starting_numbers()
    var turn = 1
    var numbers_spoken_on_turn = Array<Int>()
    var turn_map = Dictionary<Int,Array<Int>>()
    
    while turn <= target_turn{
        var number_spoken_on_turn = 0
        // Handle starting numbers
        let _index = turn-1
        if _index < starting_numbers.count{
            number_spoken_on_turn = starting_numbers[_index]
            numbers_spoken_on_turn.append(number_spoken_on_turn)
            turn_map[number_spoken_on_turn] = [turn]
            turn += 1
            continue
        }
        // Get the last number spoken
        let last_number_spoken = numbers_spoken_on_turn.last!

        if turn_map[last_number_spoken]!.count > 1{
            // Get the last two times this number was spoken
            let turns_spoken = turn_map[last_number_spoken]!.suffix(2)
            number_spoken_on_turn = turns_spoken.last! - turns_spoken.first!
        }else{
            number_spoken_on_turn = 0
        }
        if !turn_map.keys.contains(number_spoken_on_turn){
            turn_map[number_spoken_on_turn] = [turn]
        }else{
            turn_map[number_spoken_on_turn]!.append(turn)
        }
        numbers_spoken_on_turn.append(number_spoken_on_turn)
        turn += 1
    }
    print(numbers_spoken_on_turn[TARGET_TURN-1])
}
