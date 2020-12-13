//
//  day8.swift
//  advent
//
//  Created by Evan on 12/7/20.
//

import Foundation
let ACC_TOKEN = "acc "
let JMP_TOKEN = "jmp "
let NOP_TOKEN = "nop "

let TOKENS = [ ACC_TOKEN, JMP_TOKEN, NOP_TOKEN ]

class GameManager{
    var accumulator    : Int = 0
    var frame_event    : String = ""
    var frame_events   : Array<String> = []
    var event_action   : String = ""
    var events         : Array<String> = []
    
    // when game reset is flagged true, we stop updating the game_state_array.
    // we use the game state array to track what game states we should try to reset to and flip jmp to nop and nop to jmp
    var game_reset : Bool = false
    var game_state_array : Array<String> = []
    // before resetting game states, we check to see if we've already tried resetting the frame event it holds by storing it in and checking against this array
    var attempted_reset_frame_events : Array<String> = []

    
    var event_index : Int = 0 // index of the list we're processing (input file line number == +1)
    
    var last_operation : String = "" // last valid interaction that did anything to the accum (for debug)

    func check_valid_ending() -> Bool{
        if event_index == events.count{
            // if we break here, the program ran as expected (tried to run a line one after the last line, no jmp)
            return false
        }
        return true
    }
    func check_duplicate_action() -> Bool{
        if frame_events.contains(frame_event){
            // any action, nop/acc/ or jmp
            return false
        }
        return true
    }
    
    func run(lines:Array<String>, fix:Bool){
        events = lines
        event_index = 0
        while true{
            // Event pre-process
            // before the frame is increased, get the next event to process and make a string out of it to identify it and its index later
            if !check_valid_ending(){
                break
            }
            event_action = events[event_index]
            if !check_valid_ending(){
                break
            }
            
            frame_event = event_action + " \(event_index)" //"jmp -306 534"
            //we have detected an infinite loop, reset game state to last valid state (last jmp operation)
            if !check_duplicate_action(){
                if fix{
                    _reset_game_state()
                    print("Loop detected, resetting to line \(event_index) with new frame_event \(frame_event)")
                }else{
                    break
                }
            }
            process_event()
            
            // Append the frame event after we've processed it so we can recheck again before we process the event.
            frame_events.append(frame_event)
            
            // We haven't reset yet, continue to update the internal game state array
            if !game_reset{
                game_state_array.append(frame_event + " \(accumulator)") // "jmp -306 534 100" which is a jump action, to -306, line is 534, accum is 100
            }
        }
    }
    
    // reset the game state, and set line to the new line, and replace jmp in our new event_action
    func _reset_game_state(){
        // Store the game state when we first hit an infinite loop, we'll iterate through this to try new states.
        game_reset = true
        for game_state in game_state_array.reversed(){
            if game_state.contains(ACC_TOKEN){
                // pass on operations that are not jmp or nop
                continue
            }
            
            // split the game state so we can get the event_action, line etc.
            let split_game_state = game_state.split(separator: " ")
            accumulator = Int(String(split_game_state.last!))!
            let split_token = String(split_game_state.first!)
            let token : String
            if JMP_TOKEN.contains(split_token){
                token = NOP_TOKEN
            }else{
                token = JMP_TOKEN
            }
            
            // Set internal values
            event_action = token + String(split_game_state[1])
            event_index = Int(String(split_game_state[2]))!
            frame_event = event_action + " \(event_index)" //"jmp -306 534"
            
            // Check to see if we already tried resetting to this line
            if attempted_reset_frame_events.contains(frame_event){
                // we've already tried to reset this frame event and it didn't work, keep goin
                continue
            }
            attempted_reset_frame_events.append(frame_event)
            break
        }
        
        // Reset the frame events list we use to detect infinite loops
        // because we might revisit a line we attempted as part of a modified state, and don't wanna have a false positive
        // this might make sense to be broken out into its own func for visibility
        var _frame_events = Array<String>()
        for _frame_event in frame_events{
            if _frame_event == frame_event{
                break
            }
            _frame_events.append(_frame_event)
        }
        
        frame_events = _frame_events
        frame_event = frame_event.replacingOccurrences(of: JMP_TOKEN, with: NOP_TOKEN)
    }
    func process_event(){
        // which line should we jump to, and what value to set accumulator to based on frame event
        print(event_action, event_index, accumulator) //this is a full game state log

        let token = String(event_action.prefix(4))
        let raw_action_str = String(event_action.dropFirst(4))
        let frame_modifier = Int(raw_action_str)! // var for determining jumping frame and acc amount
            
        switch token{
        case ACC_TOKEN :
            // modify the accumulator with frame events modifier
            accumulator += frame_modifier
            // line increases by 1
            event_index += 1

        case JMP_TOKEN :
            // modify the line with the frame events modifier, acc is not modified
            event_index += frame_modifier
            
        case NOP_TOKEN :
            // line increases by 1, standard op
            event_index += 1
            
        default:
            fatalError("COULDNT DETECT \(String(describing: token)), \(String(describing: event_action))")
        }
    }
}


func day8(){
    let lines = get_file_contents_safe(fileName: "input_day8.txt")!
    let gameManager = GameManager()
    // Part 1
    print("-------------Starting Part 1")
    gameManager.run(lines: lines, fix:false)
    print("---Part 1 Results---")
    print("accumulator", gameManager.accumulator)
    print("total line", gameManager.event_index)
    
    // Part 2
    print("-------------Starting Part 2")
    gameManager.run(lines: lines, fix:true)
    print("---Part 2 Results---")
    print("accumulator", gameManager.accumulator)
    print("total line", gameManager.event_index)
}
