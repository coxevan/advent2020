//
//  day6.swift
//  advent
//
//  Created by Evan on 12/5/20.
//

import Foundation
let ALPHABET = "abcdefghijklmnopqrstuvwxyz" // didnt end up needing this but meh

struct Group{
    var raw_group_answers : String?
    let people : Int
    
    func get_filtered_group_answers() -> String{
        var filtered_answer = ""
        for char in raw_group_answers!{
            if !ALPHABET.contains(char){
                continue
            }
            filtered_answer += String(char)
        }
        return filtered_answer
    }
    func get_total_questions_answered() -> Int{
        let set_questions = Set(Array(get_filtered_group_answers()))
        return set_questions.count
    }
    func get_answers_with_everyone() -> String{
        var inclusive_answers = ""
        let answer = get_filtered_group_answers()
        for char in answer{
            if inclusive_answers.contains(char){
                continue
            }
            let str_char = String(char)
            let answer_count = answer.count(of: char)
            if answer_count == people {
                inclusive_answers += str_char
            }
        }
        return inclusive_answers
    }
}

func get_answers_by_group() -> [Group]?{
    guard let answers = get_file_contents_safe(fileName: "input_day6.txt") else {
        return nil
    }
    var groups = [Group]()
    var group_answer = ""
    var people = 0
    for answer in answers{
        if answer.count <= 0{
            //make a group based on the string
            let group = Group(raw_group_answers: group_answer, people: people)
            groups.append(group)
            group_answer = ""
            people = 0
            continue
        }
        // build up the answer string
        group_answer += answer
        people += 1
    }
    // GUYS THIS IS WHERE I MESSED UP
    // my loop wasn't including the last group :(
    groups.append(Group(raw_group_answers: group_answer, people: people))
    return groups
}

func day6(){
    let group_array = get_answers_by_group()!
    
    // part 1
    var total_answers = 0
    for group in group_array{
        total_answers += group.get_total_questions_answered()
    }
    // part 2
    var inclusive_answers = 0
    for group in group_array{
        inclusive_answers += group.get_answers_with_everyone().count
    }
    print("answers with ANYONE")
    print(total_answers)
    print("answers with EVERYONE")
    print(inclusive_answers)
}
