//
//  day11.swift
//  advent
//
//  Created by Evan on 12/11/20.
//

import Foundation

fileprivate let FLOOR_SPOT_TOKEN = "."
fileprivate let TAKEN_SPOT_TOKEN = "#"
fileprivate let EMPTY_SPOT_TOKEN = "L"

let CARDINAL_DIRECTION_ARRAY = [[0,1], [0,-1], [1,0], [-1,0]]
let DIAGONAL_DIRECTION_ARRAY = [[1,1], [-1,-1], [-1,1], [1,-1]]

class Spot{
    var col: Int = 0
    var row: Int = 0
    
    var _new_token: String = ""
    var token: String = ""
    
    var changed : Bool = true
    var neighbors : Array<Spot> = []

    func update(){
        token = _new_token
    }
    
    func is_taken()->Bool{
        if TAKEN_SPOT_TOKEN.contains(token){
            return true
        }
        return false
    }
    func is_floor()->Bool{
        if FLOOR_SPOT_TOKEN.contains(token){
            // Detect floors and how they can never change
            _new_token = FLOOR_SPOT_TOKEN
            changed = false
            return true
        }
        return false
    }
    func _row_col_exists(spot_map:Dictionary<Int, Array<Spot>>, col:Int, row:Int)->Bool{
        // Potential neighbor col and row exists in spot map
        // todo: move outside spot class
        let row_exists = spot_map[row] != nil
        if !row_exists{
            // row does not exist, must be on a border
            return false
        }
        let neighbors_row = spot_map[row]
        let col_exists = neighbors_row!.count > col && col >= 0
        if !col_exists{
            // col does not exist, must be on a border
            return false
        }
        return true
    }
    func find_spot_in_direction(direction:Array<Int>, spot_map:Dictionary<Int, Array<Spot>>)->Spot?{
        // Move in the direction again and again until we find a non floor tile, or we reach the bounds of the array
        var potential_neighbor_row = row + direction.first!
        var potential_neighbor_col = col + direction.last!
        let neighbor_exists = _row_col_exists(spot_map: spot_map, col: potential_neighbor_col, row: potential_neighbor_row)
        if !neighbor_exists{
            return nil
        }
        var spot = spot_map[potential_neighbor_row]![potential_neighbor_col]
        // if part 1 validation, uncomment below line
        // return spot
        while spot.is_floor(){
            potential_neighbor_row += direction.first!
            potential_neighbor_col += direction.last!
            let neighbor_exists = _row_col_exists(spot_map: spot_map, col: potential_neighbor_col, row: potential_neighbor_row)
            if !neighbor_exists{
                return nil
            }
            spot = spot_map[potential_neighbor_row]![potential_neighbor_col]
        }
        return spot
    }
    func _find_neighbors(spot_map: Dictionary<Int, Array<Spot>>){
        // Find all neighbors for this spot
        let direction_list = DIAGONAL_DIRECTION_ARRAY + CARDINAL_DIRECTION_ARRAY
        for direction in direction_list{
            let spot = find_spot_in_direction(direction:direction, spot_map: spot_map) ?? nil
            if spot == nil{
                continue
            }
            neighbors.append(spot!)
        }
    }
    func take_seat(){
        // Try to take the seat
        if is_taken(){
            fatalError("Spot is already taken")
        }else if is_floor(){
            fatalError("Spot is the floor. Cant sit here")
        }
        _new_token = TAKEN_SPOT_TOKEN
        changed = true
    }
    func leave_seat(){
        // try to leave the seat
        if !is_taken(){
            fatalError("Spot is already vacant")
        }else if is_floor(){
            fatalError("Spot is the floor. Cant process here")
        }
        _new_token = EMPTY_SPOT_TOKEN
        changed = true
    }
    func get_occupied_neighbors()->Array<Spot>{
        // How many of our detected neighbors are occupied?
        var occupied_neighbors = Array<Spot>()
        for neighbor in neighbors{
            if neighbor.is_floor(){
                continue
            }
            if neighbor.is_taken(){
                occupied_neighbors.append(neighbor)
            }
        }
        return occupied_neighbors
    }
    func can_be_taken()->Bool{
        // Does the spot follow the rules outlined in the prompt?
        if is_floor(){
            return false
        }
        let occupied_neighbors = get_occupied_neighbors()
        if is_taken(){
            if occupied_neighbors.count >= 5{ // Originally was 4 for part 1 (part 2 = 5)
                // Seat should be left
                //print("Leave seat")
                return true
            }
        }else{
            if occupied_neighbors.count == 0{
                //print("Take Seat")
                // Seat should be taken
                return true
            }
        }
        return false
    }
    
}

func any_spot_changed(spot_array: Array<Spot>)->Bool{
    // Did any spot change within the array?
    for spot in spot_array{
        if spot.changed{
            return true
        }
    }
    return false
}

fileprivate func get_all_rows()->Array<String>{
    // Get the data from input file
    guard let rows = get_file_contents_safe(fileName: "input_day11.txt") else{
        fatalError("Invalid file, does it exist?")
    }
    return rows
}

fileprivate func get_all_spots(rows:Array<String>)->Array<Spot>{
    // Get all spots from the list of rows
    var spot_array = Array<Spot>()
    for (row_index, row) in rows.enumerated(){
        for (col_index, token) in row.enumerated(){
            let spot = Spot()
            spot.col = col_index
            spot.row = row_index
            spot.token = String(token)
            spot_array.append(spot)
        }
    }
    return spot_array
}

fileprivate func print_spot_graph_array(row_array: Array<String>, spot_array: Array<Spot>){
    // Debug print the parsed array as a graph to console
    var spot_index = 0
    for row in row_array{
        var row_string = ""
        for _ in row{
            row_string += spot_array[spot_index].token
            spot_index+=1
        }
        print(row_string)
    }
}
fileprivate func sort_spot_array(row_array: Array<String>, spot_array: Array<Spot>)->Dictionary<Int, Array<Spot>>{
    // Sort all spots into an array where the row is the Key -> Array, and the column is the index in the Array
    var spot_index = 0
    var spot_map = Dictionary<Int, Array<Spot>>()
    
    for (index, row) in row_array.enumerated(){
        var row_spot_array = Array<Spot>()
        for _ in row{
            row_spot_array.append(spot_array[spot_index])
            spot_index+=1
        }
        spot_map[index] = row_spot_array
    }
    return spot_map
}

func day11(){
    let row_array = get_all_rows()
    let spot_array = get_all_spots(rows: row_array)
    let spot_map = sort_spot_array(row_array:row_array, spot_array:spot_array)

    // Find all neighbors
    for spot in spot_array{
        spot._find_neighbors(spot_map: spot_map)
    }
    // Debug print statement prints starting graph, parsed, for comparison and validation with input data raw
    //print_spot_graph_array(row_array: row_array, spot_array: spot_array)
    while any_spot_changed(spot_array:spot_array){
        // Run all rules with all original token values (all seats are evaluated at once, no update happens on the fly)
        for spot in spot_array{
            // Reset changed
            spot.changed = false
            if spot.is_floor(){
                // Don't process floor
                continue
            }
            // Can the spot be taken?
            let can_be_taken = spot.can_be_taken()
            if can_be_taken && !spot.is_taken(){
                spot.take_seat()
            }else if can_be_taken && spot.is_taken(){
                spot.leave_seat()
            }
        }
        for spot in spot_array{
            // Update the internal spot token so we can run the process again
            spot.update()
        }
    }
    
    // Calculate how many spots are taken
    var taken_spots = 0
    for spot in spot_array{
        if spot.is_taken(){
            taken_spots += 1
        }
    }
    print(taken_spots)
}
