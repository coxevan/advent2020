//
//  day13.swift
//  advent
//
//  Created by Evan on 12/12/20.
//

import Foundation
let EMPTY_BUS_TOKEN = "x"
let TIME_TO_WAIT_MAX = 100000000000000000
let MAX_DEPARTURE_COUNT = 1000000000
let MIN_DEPARTURE_VALUE = 100000000000000 //test solution:1068781 100000000000000

class Bus{
    var bus_id = 0
    var last_departed = 0
    var time_offset = 0
    var departures: Array<Int> = []
    //var value_seek = 0
    var prior_bus: Array<Bus> = []
    
    func process_time(time:Int){
        let _time = time - time_offset
        if (bus_id % _time) == 0{
            // No time leftover, so we departed
            print(bus_id, last_departed)
            last_departed = time
        }
    }
    func calculate_departure(departure:Int)->Int{
        var _departure = departure
        let _raw_time = bus_id * _departure
        return _raw_time //+ time_offset
    }
}
func day13(){
    // modulo each value by the starting time
    // 939 % 59 = 54
    // 59 - 54 = 5 minutes we would wait
    //puzzle output for day 13 test is 54 * 5
    
    let notes = get_file_contents(fileName: "input_day13.txt")
    let earliest_time = Int(notes.first!)
    let bus_ids = get_bus_ids(notes: notes.last!)
    
    // Get all bus times
    var times_for_bus = Array<Int>()
    var time_to_wait = TIME_TO_WAIT_MAX
    var bus_to_beat = 0
    
    for bus_id in bus_ids{
        let id_mod = earliest_time! % bus_id
        let _time_to_wait = bus_id - id_mod
        if time_to_wait > _time_to_wait{
            time_to_wait = _time_to_wait
            bus_to_beat = bus_id
        }
        // Store all times for validation
        times_for_bus.append(time_to_wait)
    }
    print(bus_to_beat * time_to_wait)
    
    let result = part2(raw_time_line: notes.last!, bus_ids: bus_ids)
    print(result)
}
func get_bus_ids(notes:String)-> Array<Int>{
    let bus_ids = String(notes.last!).components(separatedBy: ",")
    var valid_ids = Array<Int>()
    for id in bus_ids{
        if id.contains(EMPTY_BUS_TOKEN){
            continue
        }
        valid_ids.append(Int(id)!)
    }
    return valid_ids
}

// OOOF THIS NEEDS TO BE REWORKED FROM THE GROUND UP
// NOTE FROM AJIT: if you find that a time stamp that obeys the rule, like it’s modulo is a certain number,
//                 how often does that reoccur, with one time stamp can you predict the next. Also if you found
//                 that two busses obey their rules can you find the next time stamp where their rules are obeyed together again. And so on...
func part2(raw_time_line: String, bus_ids: Array<Int>)->Int{
    let info = make_bus_array(raw_time_line: raw_time_line)
    let bus_array = info.0
    
    // Get the first bus and the longest bus
    // We'll use the first bus to check our chain
    // We'll skip around departure times using the last bus (longest cycle time)
    let first_bus = bus_array.first!
    let longest_bus = get_bus_with_longest_route(bus_array:bus_array)
    var first_departure = 0
    var i = 267177176626 // stored staring i 264933358081
    while true{
        // Calculate the departure time for the longest bus
        let departure = longest_bus.calculate_departure(departure: i)
        i += 1
        
        // If the departure is below our known floor, skip it
        if departure < MIN_DEPARTURE_VALUE{
            continue
        }
        // Find the potential first departure from the calculated departure - the longest_bus's time offset
        first_departure = departure - longest_bus.time_offset // when should the first bus have left
        
        // Confirm the first departure is valid
        if first_departure % first_bus.bus_id != 0{
            continue
        }
        
        // Assume this departure is the one we want
        var valid_departure = true
        
        var valid_chain = 0 // Store chain lengths for debug
        for (index, bus) in bus_array.enumerated(){ // start at index 1, we already processed first bus
            if index == 0{
                continue
            }
            // A bus's ID from the first departure will be it's modulo + time offset
            let bus_mod = first_departure % bus.bus_id
            if bus_mod + bus.time_offset != bus.bus_id{
                valid_departure = false
                break
            }
            // Make sure the bus actually left at that time
            let bus_departure = first_departure + bus.time_offset
            if bus_departure % bus.bus_id != 0{
                valid_departure = false
                break
            }
            
            valid_chain += 1
        }
        if valid_departure{
            print("first departure", first_departure)
            break
        }
    }
    return first_departure
}
func get_bus_with_longest_route(bus_array:Array<Bus>)->Bus{
    var route = 0
    var bus = Bus()
    for _bus in bus_array{
        if _bus.bus_id > route{
            route = _bus.bus_id
            bus = _bus
        }
    }
    return bus
}
func make_bus_array(raw_time_line:String)->(Array<Bus>, Int){
    var bus_array = Array<Bus>()
    var total_time = 0
    var valid_index = 0
    var _last_bus = Bus()
    for (index, bus_id) in raw_time_line.components(separatedBy: ",").enumerated(){
        if bus_id.contains("x"){
            continue
        }
        let bus = Bus()
        bus.bus_id = Int(bus_id)!
        bus.time_offset = index
        bus.last_departed = index
        //bus.value_seek = index - valid_index
        bus.prior_bus.append(_last_bus)
        bus_array.append(bus)
        
        total_time = index
        valid_index = index
        _last_bus = bus
    }
    return (bus_array, total_time)
}
