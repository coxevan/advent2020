//
//  day14.swift
//  advent
//
//  Created by Evan on 12/14/20.
//

import Foundation

let STARTING_VALUE = 0
var MEMORY = Dictionary<Int,Int>()


class MaskGroup{
    var version = 0
    var mask_string = ""
    var address_value_array = Array<(Int,Int)>()
    var _result = ""
    
    func compute_value(){
        if version == 1{
            // Computed the masked_bits var we'll use to add values to addresses
            for address_value in address_value_array{
                let address = address_value.0
                let value = address_value.1
                set_masked_value_to_address(value: value, address: address)
            }
        }else{
            // Run version 2
            for address_value in address_value_array{
                let address = address_value.0
                let value = address_value.1
                
                let bin_address_str = mask_address(address: address)
                let addresses_array = compute_valid_addresses(address: bin_address_str)
                for _address in addresses_array{
                    set_value_to_bin_address(value: value, address: _address)
                }
            }
        }
    }
    func set_masked_value_to_address(value: Int, address: Int){
        let bin_string = int_to_binary_string(value: value, length: mask_string.count)
        let new_string = _mask_bin_str(value: bin_string)
        set_bin_value_to_address(value: new_string, address: address)
    }
    func set_bin_value_to_address(value:String, address:Int){
        // Set binary value to int address
        let _value = Int(value, radix: 2)!
        MEMORY[address] = _value
    }
    func set_value_to_bin_address(value:Int, address:String){
        // Set a value to address at binary string
        let _address = Int(address, radix:2)!
        MEMORY[_address] = value
    }
    func _mask_bin_str(value: String)->String{
        // Used for version 1 value masking
        var new_string = ""
        for (index, char) in value.enumerated(){
            let mask_value = mask_string[index]
            if mask_value == "X"{
                new_string += String(char)
                continue
            }
            new_string += mask_value
        }
        return new_string
    }
    func mask_address(address: Int)->String{
        // Mask the address int, returning a binary string
        let bin_address = int_to_binary_string(value: address, length: mask_string.count)
        let masked_address = _mask_bin_address(value: bin_address)
        return masked_address
    }
    func _mask_bin_address(value: String)->String{
        // Mask the binary string of the address, returns 0 and 1 with &, but leaves X's as floating vals (can be either 0 or 1)
        // This must be handled using compute_valid_addresses to get all possible X combinations
        var new_string = ""
        for (index, char) in value.enumerated(){
            let mask_value = mask_string[index]
            if mask_value == "X" || mask_value == "1"{
                // Override the address with 1's or X's from the mask
                new_string += mask_value
                continue
            }
            new_string += String(char)
        }
        return new_string
    }
    func compute_valid_addresses(address: String, addresses_to_modify: Array<String> = [])->Array<String>{
        // Apply the mask to the address
        let masked_address = address
        var _addresses_to_modify = Array<String>()
        var _addresses = Array<String>()
        
        // Replace 0's and 1's in the bin string
        for _replace in ["0", "1"]{
            var new_address = ""
            var switched = false
            for char in masked_address{
                if char != "X" || switched{
                    // This character is not floating, so it's set in the address
                    new_address += String(char)
                    continue
                }
                switched = true
                new_address += _replace
            }
            _addresses.append(new_address)
        }
        // Check for addresses we should modify
        for _mod_address in _addresses{
            if _mod_address.contains("X"){
                // we gotta continue building this address
                let addresses = compute_valid_addresses(address: _mod_address)
                _addresses_to_modify.append(contentsOf: addresses)
            }else{
                // This address is built, no more possible permutations
                _addresses_to_modify.append(_mod_address)
            }
        }
        //_addresses_to_modify += addresses_to_modify
        return _addresses_to_modify
    }
}

func day14(){
    let raw_input = get_file_contents(fileName: "input_day14.txt")
    let bitmasks = get_bitmask_groups(input:raw_input)
    
    // Part 1
    for mask in bitmasks{
        // Run part 1
        mask.version = 1
        mask.compute_value()
    }
    var final_value = 0
    for value in MEMORY.values{
        final_value += value
    }
    print("Part 1 :", final_value)
    
    // Part 2
    // Clear memory and final value
    MEMORY = Dictionary<Int,Int>()
    final_value = 0

    for mask in bitmasks{
        mask.version = 2
        mask.compute_value()
    }
    for value in MEMORY.values{
        final_value += value
    }
    print("Part 2 :", final_value)
}


func get_bitmask_groups(input: Array<String>)-> Array<MaskGroup>{
    // Build mask groups out of raw input data.
    var masks = Array<MaskGroup>()
    var mask_group = MaskGroup()
    for line in input{
        if !line.contains("["){
            // We're setting a bitmask to use
            mask_group = MaskGroup()
            mask_group.mask_string = line.components(separatedBy: " ").last!
            masks.append(mask_group)
            continue
        }
        let _components = line.components(separatedBy:" = ")
        let value = Int(_components.last!)!
        let _address = _components.first!.components(separatedBy: "[").last!.components(separatedBy: "]").first!
        let address = Int(_address)!
        mask_group.address_value_array.append((address, value))
    }
    return masks
}
