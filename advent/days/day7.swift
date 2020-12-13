//
//  day7.swift
//  advent
//
//  Created by Evan on 12/6/20.
//

import Foundation

let EMPTY_TOKEN = "no other bags"

// learned the hard way about structs vs. class today.
class BagRule{
    // Raw string value of the rule from input
    var raw_rule : String = ""
    // What line in the file was this rule defined
    var rule_int : Int = 0
    // Tuple, 0 = Name of the bag it can contain, 1 = number of that bag it can contain
    var contain_rule : [(String,Int)]?
    // Array of all child BagRules that this type of bag can contain
    var child_bags : Array<BagRule> = []
    var name : String {
        get {
            let split_string = raw_rule.components(separatedBy: " bags")
            return String(split_string.first!)
        }
    }
    func add_children(children:Array<BagRule>){
        for child in children{
            child_bags.append(child)
        }
    }
    
    func get_child_bag_count()-> Int {
        // Get total number of bags this bag will contain, takes into account all children and their counts (critical to part 2)
        if is_empty(){
            return 0
        }
        var sub_bags = 0
        for rule in contain_rule!{
            for bag in child_bags{
                // child bag matches
                if bag.name == rule.0{
                    let bag_count = bag.get_child_bag_count() * rule.1
                    sub_bags += bag_count
                }
            }
            sub_bags += rule.1
        }
        
        return sub_bags
    }
    
    func can_contain(bag_color:String) -> Int{
        // Determine if this bag can legally contain a bag color/type, takes into account all children and their rules (critical to part 1)
        if is_empty(){
            return 0
        }
        var valid_sub_bags = 0
        var rule_names = Array<String>()
        for rule in contain_rule!{
            if bag_color == rule.0{
                valid_sub_bags += rule.1
            }
            rule_names.append(rule.0)
        }
        for child in child_bags{
            if child.can_contain(bag_color: bag_color)>0{
                valid_sub_bags += 1
            }
        }
        return valid_sub_bags
    }
    
    func determine_allowed_bags() -> [(String, Int)]{
        // String parse string parse string parse
        var rule_array = [(String,Int)]()
        let raw_contain_rule = String(raw_rule.components(separatedBy: "contain ").last ?? "")
        for rule in raw_contain_rule.components(separatedBy: ", "){
            let count = Int(String(rule.first!)) ?? -1
            if count < 0{
                fatalError(name)
            }
            let bag_rule = String(rule.substring(from: String.Index(encodedOffset: 2)))
            let filtered_bag_rule = bag_rule.components(separatedBy: " bag").first!
            rule_array.append((filtered_bag_rule, count))

        }
        return rule_array
    }
    
    func is_empty() -> Bool{
        return raw_rule.contains(EMPTY_TOKEN)
    }
}

func get_all_bag_rules() -> [BagRule]{
    guard let rules = get_file_contents_safe(fileName: "input_day7.txt") else{
        fatalError("Bad file name")
    }
    var bag_array = [BagRule]()
    for (index, rule) in rules.enumerated(){
        let bag = BagRule()
        bag.raw_rule = rule
        bag.rule_int = index
        if !bag.is_empty(){
            bag.contain_rule = bag.determine_allowed_bags()
        }
        bag_array.append(bag)
    }
    return bag_array
}

func day7(){
    let bag_array = get_all_bag_rules()
    var total_rules = 0
    var bag_tree = Dictionary<String, Array<BagRule>>()
    
    // Make initial bag tree
    for bag in bag_array{
        let bag_name_exists = bag_tree[bag.name] != nil
        if bag_name_exists{
            bag_tree[bag.name]!.append(bag)
        }else{
            bag_tree[bag.name] = [bag]
        }
    }
    // Setup children dependencies
    for (_, bag_array) in bag_tree{
        // for each bag color/name
        for bagrule in bag_array{
            if bagrule.is_empty(){
                continue
            }
            // for each bagrule in that bag name's array
            for (rule_name, _) in bagrule.contain_rule!{
                let child_bags = bag_tree[rule_name] ?? []
                bagrule.add_children(children: child_bags)
            }
        }
    }
    // look for bags that have shiny gold in thier children
    for bag in bag_array{
        if bag.can_contain(bag_color: "shiny gold")>0{
            total_rules += 1
        }
    }
    print("Part 1: ", total_rules)

    let shiny_gold_bags = bag_tree["shiny gold"] ?? []
    var total_child_bags = 0
    for bag in shiny_gold_bags{
        total_child_bags += bag.get_child_bag_count()
    }
    print("Part 2: ", total_child_bags)
}
