//
//  day10.swift
//  advent
//
//  Created by Evan on 12/9/20.
//

import Foundation

let JOLT_DELTA_LIMIT = 3

func get_joltages() -> Array<Int>{
    let file_contents = get_file_contents(fileName: "input_day10.txt")!
    var joltage_array = Array<Int>()
    for line in file_contents{
        joltage_array.append(Int(line)!)
    }
    return joltage_array
}

func is_outlet_joltage_in_range(outlet_joltage: Int, joltage: Int)->Bool{
    var i = 0
    while i <= JOLT_DELTA_LIMIT{
        // outlets within this range are valid and can be connected
        let potential_joltage = i + joltage
        if potential_joltage == outlet_joltage{
            return true
        }
        i+=1
    }
    return false
}

func day10(){
    //Part 1
    var joltage_array = get_joltages()
    let my_adapter = joltage_array.sorted().last! + 3
    let joltage_map = part1(joltage_array_full: joltage_array)
    
    //Part 2
    
    // Add my adapter value (highest adapter + 3) and 0 to joltage array
    joltage_array += [my_adapter, 0]
    let sorted_joltage_array = joltage_array.sorted()
    var outlet_possibilities = Dictionary<Int, Int>()
    // Set our starting adapter (0) to 1, as we have only 1 way to start.
    outlet_possibilities[0] = 1
    
    // For each outlet in the sorted joltage array
    for outlet in sorted_joltage_array{
        if outlet == 0{
            // Skip zero, preprocessed
            continue
        }
        var possible_variants = 0
        // Search the already computed possible variants for a value set and carry it forward
        // The only way to get to adapter n, you have to be able to reach n-1 or n-k where K is JOLT_DELTA_LIMIT
        for i in 1...JOLT_DELTA_LIMIT{
            let joltage_to_check = outlet - i
            if sorted_joltage_array.contains(joltage_to_check){
                possible_variants += outlet_possibilities[joltage_to_check]!
            }
        }
        // Store the possible variants so we can access it as we move forward in the list
        outlet_possibilities[outlet] = possible_variants
    }
    // All available permutations are the final adapters possibilities (possible ways to reach it)
    print("Possibilities", outlet_possibilities[my_adapter]!)
}

func part1(joltage_array_full:Array<Int>)->Dictionary<Int,Array<Int>>{
    var joltage_array = joltage_array_full
    var available_outlets = joltage_array.sorted()
    
    let my_adapter_joltage = available_outlets.last! + 3
    joltage_array.append(my_adapter_joltage)
    available_outlets.append(my_adapter_joltage)
    
    var joltage = 0
    var joltage_map = Dictionary<Int,Array<Int>>()
    for outlet_joltage in available_outlets{
        //print("Processing outlet with joltage \(outlet_joltage)")
        if is_outlet_joltage_in_range(outlet_joltage: outlet_joltage, joltage:joltage){
            let differential = outlet_joltage - joltage
            joltage = outlet_joltage
            
            // store differential
            let keyExists = joltage_map[differential] != nil
            if keyExists{
                joltage_map[differential]!.append(outlet_joltage)
            }else{
                joltage_map[differential] = [outlet_joltage]
            }
            if !joltage_array.contains(joltage){
                break
            }
            joltage_array = pop_first_index(array: joltage_array, value: joltage)
        }else{
            break
        }
    }
    joltage_map[-1] = [joltage]
    return joltage_map
}
