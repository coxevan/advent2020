//
//  day16.swift
//  advent
//
//  Created by Evan on 12/16/20.
//

import Foundation

class TicketFieldRule {
    // An array with parameters, min/max values to validate by
    var rule_name = ""
    var rules = Array<(Int, Int)>()
    var index = -1
    var _potential_indicies = Array<Int>()
    
    func populate_rule(raw_rule: String){
        let rule_components = raw_rule.components(separatedBy: ": ")
        rule_name = rule_components.first!
        let rule_params = rule_components.last!.components(separatedBy: " or ")
        for rule_param in rule_params{
            let min_max = rule_param.components(separatedBy: "-")
            // Woah this is massively unsafe.
            rules.append((Int(min_max.first!)!, Int(min_max.last!)!))
        }
    }
    func value_fits_rule(value:Int)->Bool{
        for range in rules{
            if value >= range.0 && value <= range.1{
                return true
            }
        }
        return false
    }
    func find_rule_indices(tickets:Array<Ticket>, ticket_rules:Array<TicketFieldRule>, min: Int = 0){
        let index_max = tickets.first!.ticket_values.count - 1
        _potential_indicies = Array<Int>()
        // For each potential index...
        for i in min...index_max{
            // For each ticket...
            if rule_has_invalid_value_at_index(tickets: tickets, i: i){
                continue
            }
            _potential_indicies.append(i)
        }
    }
    func rule_has_invalid_value_at_index(tickets:Array<Ticket>, i:Int)->Bool{
        // if this rule is applied to all known valid at tickets to their values at index, this would make some tickets invalid
        for ticket in tickets{
            // If that value doesn't fit in the rule, it can't be that index...
            if !value_fits_rule(value:ticket.ticket_values[i]){
                // Can't be this index.
                return true
            }
        }
    return false
    }
}

class Ticket{
    var ticket_values = Array<Int>()
    var _invalid_ticket_values = Array<Int>() // Values here meet aleast one of the ticketfieldrules
    var valid_rule_array = Array<Array<TicketFieldRule>>() // An array of arrays which contain ticket field rules for values
    
    func populate_ticket(raw_ticket: String){
        // Add all of our values to the internal ticket values array
        for value in raw_ticket.components(separatedBy: ","){
            ticket_values.append(Int(value)!)
        }
    }
    func validate_ticket(ticket_rules:Array<TicketFieldRule>)->Bool{
        for value in ticket_values{
            let valid_rules = validate_value(value:value, ticket_rules:ticket_rules)
            if valid_rules.isEmpty{
                _invalid_ticket_values.append(value)
            }
            valid_rule_array.append(valid_rules)
        }
        if _invalid_ticket_values.isEmpty{
            return true
        }
        return false
    }
    func validate_value(value:Int, ticket_rules: Array<TicketFieldRule>)->Array<TicketFieldRule>{
        // Find if there's ANY rule this value fits within
        var valid_rule_array = Array<TicketFieldRule>()
        for rule in ticket_rules{
            if rule.value_fits_rule(value: value){
                valid_rule_array.append(rule)
            }
        }
        return valid_rule_array
    }
    func get_invalid_value_sum()->Int{
        var val = 0
        for value in _invalid_ticket_values{
            val += value
        }
        return val
    }
    func get_departure_factor(rules:Array<TicketFieldRule>)->Int{
        var departure_factor = 1
        for rule in rules{
            if !rule.rule_name.contains("departure"){
                // Skip any rules that don't lead with departure
                continue
            }
            departure_factor *= ticket_values[rule.index]
        }
        return departure_factor
    }
    func ticket_fits_rules()->Bool{
        for rule_array in valid_rule_array{
            if rule_array.count > 1{
                // The ticket has a value with more rules than one
                return false
            }
        }
        return true
    }
}

func get_ticket_rules(contents:Array<String>)-> Array<TicketFieldRule>{
    var ticket_rules = Array<TicketFieldRule>()
    for line in contents{
        if line == EMPTY_LINE{
            break
        }
        let ticket_rule = TicketFieldRule()
        ticket_rule.populate_rule(raw_rule: line)
        ticket_rules.append(ticket_rule)
    }
    return ticket_rules
}

func get_tickets(contents:Array<String>)-> Array<Ticket>{
    var tickets = Array<Ticket>()
    for line in contents{
        if line == EMPTY_LINE || ALPHABET.contains(line[0]){
            // skip any line that starts with a letter or is empty
            continue
        }
        let ticket = Ticket()
        ticket.populate_ticket(raw_ticket: line)
        tickets.append(ticket)
    }
    return tickets
}


func day16(){
    let file_contents = get_file_contents(fileName: "input_day16.txt")
    let ticket_rules = get_ticket_rules(contents:file_contents)
    let tickets = get_tickets(contents:file_contents)
    
    // Part 1, get all nearby tickets and determine the error rate (All values that are invalid summed)
    let nearby_tickets = tickets[1...]
    var scanning_error_rate = 0
    var valid_tickets = Array<Ticket>()
    for ticket in nearby_tickets{
        let valid_ticket = ticket.validate_ticket(ticket_rules:ticket_rules)
        scanning_error_rate += ticket.get_invalid_value_sum()
        if valid_ticket{
            // Store this ticket as valid
            valid_tickets.append(ticket)
        }
    }
    print("Part 1: Scanning error rate: \(scanning_error_rate)")
    // Add my ticket to the valid ticket array
    let my_ticket = tickets.first!
    valid_tickets.append(my_ticket)
    
    // Part 2, find what rules match what value indicies
    // Get all potential rule indicies
    for rule in ticket_rules{
        rule.find_rule_indices(tickets: valid_tickets, ticket_rules:ticket_rules)
        if rule._potential_indicies.count == 1{
            // If this rule can only fit in one spot, set it. We'll use it to base all the other stuff
            rule.index = rule._potential_indicies.first!
        }
    }
    
    // Find valid rules
    while _validate_ticket_rules(ticket_rules: ticket_rules){ // This will continue as long as rules exist which are unset
        for rule in ticket_rules{
            if rule._potential_indicies.count <= 1{
                continue
            }
            for potential_index in rule._potential_indicies{
                if potential_index_is_unique(index: potential_index, rule: rule, rules: ticket_rules){
                    rule.index = potential_index
                    break
                }
            }
        }
        // Find all unset rules after first pass
        let unset_rules = get_unset_rules(ticket_rules: ticket_rules)
        for rule in unset_rules{
            for potential_index in rule._potential_indicies{
                // set all unset rules to their potential indicies that none of them share
                if potential_index_is_unique(index: potential_index, rule: rule, rules: unset_rules){
                    rule.index = potential_index
                }
            }
        }
    }
    apply_rules_to_tickets(tickets:valid_tickets, ticket_rules: ticket_rules)
    // Run a validation step on rules, if we didnt successfully set one, we will not pass
    //_validate_ticket_rules(ticket_rules: ticket_rules)
    let departure_factor = my_ticket.get_departure_factor(rules: ticket_rules)
    if departure_factor != 426362917709{
        fatalError("Ya done broke it")
    }
    print("Part 2: Departure factor:", departure_factor)
}

func apply_rules_to_tickets(tickets: Array<Ticket>, ticket_rules: Array<TicketFieldRule>){
    for ticket in tickets{
        for rule in ticket_rules{
            if !rule.value_fits_rule(value: ticket.ticket_values[rule.index]){
                fatalError("Invalid rule index set.")
            }
        }
    }
}

func _validate_ticket_rules(ticket_rules:Array<TicketFieldRule>)->Bool{
    let unset_rules = get_unset_rules(ticket_rules: ticket_rules)
    if unset_rules.isEmpty{
        return false
    }
    return true
}
func get_unset_rules(ticket_rules:Array<TicketFieldRule>)->Array<TicketFieldRule>{
    var unset_rules = Array<TicketFieldRule>()
    for rule in ticket_rules{
        if rule.index < 0{
            unset_rules.append(rule)
        }
    }
    return unset_rules
}
func potential_index_is_unique(index:Int, rule: TicketFieldRule, rules:Array<TicketFieldRule>)->Bool{
    let _starting_rule = rule
    for rule in rules{
        if rule === _starting_rule{
            continue
        }
        if rule.index > 0{
            continue
        }
        if rule._potential_indicies.contains(index){
            return false
        }
    }
    return true
}
