//
//  advent_fileio.swift
//  advent
//
//  Created by Evan on 12/5/20.
//

import Foundation

func get_file_contents(fileName: String) -> [String]? {
    let dir = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first
    // Advent of code 2020 folder exists in user documents directory. YIKES
    let advent_dir = dir?.appendingPathComponent("advent_of_code_2020")
    let fileUrl = advent_dir?.appendingPathComponent(fileName)
    do{
        let contents = try String(contentsOf: fileUrl!, encoding: .ascii).components(separatedBy: "\n")
        return contents
    }catch{
        fatalError("\(error)")
    }
}
