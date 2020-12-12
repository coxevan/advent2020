//
//  day12.swift
//  advent
//
//  Created by Evan on 12/11/20.
//

import Foundation

let BOAT_COMPASS = ["E": 0, "S": 90, "W": 180, "N": 270]
let BOAT_TURN_FACTOR = ["R": 1, "L": -1]

class Boat{
    var current_heading = 0 // boat starts facing east
    var _raw_heading = 0
    var east = 0
    var north = 0
    
    // store the position of the waypoint
    var waypoint_values = ["E": 10, "N":1, "S": 0, "W": 0]
    
    func turn(direction: String, value: Int){
        // Turn the waypoint around the ship
        let starting_heading = _raw_heading
        
        // part 1
        if !BOAT_TURN_FACTOR.keys.contains(direction){
            fatalError("boat direction map does not contain direction \(direction)")
        }
        let heading_value = value * BOAT_TURN_FACTOR[direction]!
        current_heading += heading_value
        _raw_heading += heading_value
        _normalize_heading()
        // part 1 end
        
        // Detect the difference in heading, then turn that amount
        // Potentially shouldn't normalize heading
        let heading_differential = _raw_heading - starting_heading
        if heading_differential == 0{
            fatalError("No heading differential, why did we turn?")
        }
        // How many turns should we do
        let turn_count = heading_differential / 90
        var right = true
        if turn_count < 0{
            right = false
        }
        let abs_turn_count = abs(turn_count)
        var i = 0
        while i < abs_turn_count{
            do_turn(right:right)
            i+=1
        }
    }
    func do_turn(right:Bool){
        // OOF, shuffle some values around. there's a better way to do this here.
        // Probably something with multiplying across axis
        var _new_east  : Int
        var _new_north : Int
        var _new_west  : Int
        var _new_south : Int
        if right{
            _new_east = waypoint_values["N"]!
            _new_north = waypoint_values["W"]!
            _new_west  = waypoint_values["S"]!
            _new_south = waypoint_values["E"]!
        }else{
            _new_east = waypoint_values["S"]!
            _new_north = waypoint_values["E"]!
            _new_west  = waypoint_values["N"]!
            _new_south = waypoint_values["W"]!
        }
        waypoint_values["E"] = _new_east
        waypoint_values["N"] = _new_north
        waypoint_values["W"] = _new_west
        waypoint_values["S"] = _new_south
    }
    func move_boat(direction: String, value: Int){
        var _direction = direction
        // move towards the waypoint
        if direction == "F"{
            for (dir, val) in waypoint_values{
                if val == 0{
                    // value has no impact
                    continue
                }
                // move the ship in that direction
                move_boat(direction: dir, value: value*val)
            }
            _direction = get_current_heading()
            return
        }
        switch _direction{
        case "N" :
            north += value
        case "S":
            north -= value
        case "E":
            east += value
        case "W":
            east -= value
        default:
            fatalError("Direction cannot be parsed \(_direction)")
        }
    }
    func move_waypoint(direction: String, value:Int){
        // Add the direction and value to the waypoint map
        waypoint_values[direction]! += value
    }
    func process_command(direction: String, value:Int){
        if ["R", "L"].contains(direction){
            turn(direction: direction, value: value)
        }else if direction == "F"{
            // move the ship in the direction of the way point
            move_boat(direction: direction, value: value)
        }else{
            // move the way point
            move_waypoint(direction: direction, value: value)
        }
        //print(east, north)
    }
    func get_current_heading()->String{
        // Get the heading direction based on the compass and normalized heading
        _normalize_heading()
        for (heading, value) in BOAT_COMPASS{
            if current_heading == value{
                return heading
            }
        }
        fatalError("No valid heading found for \(current_heading)")
    }
    func _normalize_heading(){
        // Run everytime we change heading or get heading
        // If we're storing values greater than 360, pop it back down and abs it
        if current_heading >= 360{
            current_heading -= 360
            current_heading = abs(current_heading)
        }else if current_heading <= 0{
            // current heading is negative, pop it up 360
            current_heading += 360
        }
        if current_heading == 360{
            // If current heading is 360, set it to 0
            current_heading = 0
        }
    }
}
func get_all_commands()->Array<(String, Int)>{
    guard let command_array = get_file_contents(fileName: "input_day12.txt") else {
        fatalError("woah dude: Commands couldn't be parsed")
    }
    var command_list = Array<(String, Int)>()
    for command in command_array{
        let command_token = String(command.first!)
        let value_str = get_string_after_character(base_string: command, character: command_token)
        let command_value = Int(value_str)!
        command_list.append((String(command_token), command_value))
    }
    return command_list
}

func day12(){
    let command_array = get_all_commands()
    let boat = Boat()
    for command in command_array{
        let token = command.0
        let value = command.1
        boat.process_command(direction: token, value: value)
    }
    let manhattan_direction = abs(boat.north) + abs(boat.east)
    
    // Test against known valid number
    if manhattan_direction != 58637{
        print("Failed")
    }else{
        print("Success")
    }
}
