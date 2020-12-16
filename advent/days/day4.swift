//
//  day4.swift
//  advent
//
//  Created by Evan on 12/4/20.
//

import Foundation
import os.log

let EMPTY_LINE = ""
let DEFAULT_MINMAX = -10000000000

let VALID_COLORS = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
let VALID_COLOR_CHARS = ["0", "1", "2", "3", "4", "5" , "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
let CM_MIN_MAX = [150, 193]
let IN_MIN_MAX = [59, 76]
fileprivate let VALID_METRICS = ["in", "cm"]


struct Passport{
    var birth_year : String?
    var issue_year : String?
    var expiration_year : String?
    var height : String?
    var hair_color : String?
    var eye_color : String?
    var passport_id : String?
    var country_id : String?
    
    var valid = true
    
    func is_passport_valid() -> Bool{
        if !valid{
            // passport has been deemed in valid some how before our check.
            return false
        }
        // check all properties for valid entries, if any are nil, it's invalid.
        //country Id's status is optional
        let property_array = [birth_year, issue_year, expiration_year, height, hair_color, eye_color, passport_id]
        for property in property_array{
            if property == nil{
                return false
            }
        }
        // valid passport
        return true
    }
    func validate_int_value(value:String, min:Int=0, max:Int=10000000000, length:Int) -> Bool {
        if value.count != length{
            // must match length
            return false
        }
        if let int_value = Int(value){
            if int_value < min || int_value > max{
                return false
            }
        }
        return true
    }
    
    func validate_hex_color(value:String) -> Bool{
        if value.count != 7{
            return false
        }
        if !value.starts(with: "#"){
            return false
        }
        for char in Array(value){
            if char == "#"{
                continue
            }
            if !VALID_COLOR_CHARS.contains(String(char)){return false}
        }
        return true
    }
    
    func validate_eye_color(value:String) -> Bool{
        if !VALID_COLORS.contains(value){
            return false
        }
        return true
    }
    
    func validate_height(value:String) -> Bool{
        let metric = String(value.suffix(2))
        if !VALID_METRICS.contains(metric){
            print("\(metric) not found")
            return false}
        
        let str_array = value.replacingOccurrences(of: metric, with: "")
        let str_num = String(str_array)
        let int_value = Int(str_num)!
        switch metric{
        case "in" :
            if int_value < IN_MIN_MAX[0] || int_value > IN_MIN_MAX[1]{
                return false
            }
        case "cm" :
            if int_value < CM_MIN_MAX[0] || int_value > CM_MIN_MAX[1]{
                return false
            }
        default:
            print("invalid token \(metric)")
            }
        return true
    }
    
    mutating func set_property(token:String, value:String){
        switch token{
        case "byr" :
            if validate_int_value(value: value, min: 1920, max: 2002, length: 4){
                birth_year = value
            }
        case "iyr" :
            if validate_int_value(value: value, min: 2010, max: 2020, length: 4){
                issue_year = value
            }
        case "eyr" :
            if validate_int_value(value: value, min: 2020, max: 2030, length: 4){
                expiration_year = value
            }
        case "hgt" :
            if validate_height(value: value){
                height = value
            }
        case "hcl" :
            if validate_hex_color(value: value){
                hair_color = value
            }
        case "ecl" :
            if validate_eye_color(value: value){
                eye_color = value
            }
        case "pid" :
            if validate_int_value(value: value, length: 9){
                passport_id = value
            }
        case "cid" :
            country_id = value
        default:
            print("invalid token \(token)")
        }
    }
}

func make_passport(passportString: String) -> Passport{
    let key_value_array = passportString.split(separator:" ")
    var passport = Passport()
    for each in key_value_array{
        let token_value_array = each.split(separator: ":")
        if token_value_array.count != 2{
            continue
        }
        passport.set_property(token: String(token_value_array[0]), value: String(token_value_array[1]))
    }
    return passport
}

func get_passports(rawPassports: [String]) ->[Passport] {
    var passport_array = [Passport]()
    var held_passport = ""
    for line in rawPassports{
        if line == EMPTY_LINE{
            print("making passport")
            let passport = make_passport(passportString: held_passport)
            passport_array.append(passport)
            // reset held passport
            held_passport = ""
        }
        held_passport = held_passport + line + " "
    }
    return passport_array
}

func day4()->Int?{
    guard let raw_passport_data = get_file_contents_safe(fileName:"input_day4.txt") else { return 10 }
    let passports = get_passports(rawPassports: raw_passport_data)
    var valid_items = 0
    for passport in passports{
        if passport.is_passport_valid(){
            valid_items += 1
        }
    }
    return valid_items
}
