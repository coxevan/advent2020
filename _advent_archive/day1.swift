import os.log
import Foundation
import PlaygroundSupport


func get_file_contents(fileName: String) -> [String]? {
    let paths = Bundle.main.paths(forResourcesOfType: "txt", inDirectory: nil)
    for path in paths{
        return try? String(contentsOf: URL(fileURLWithPath: path)).components(separatedBy: "\n")
    }
    return nil
}

func get_number_list(fileName: String) -> [Int]{
    guard let contents = get_file_contents(fileName: fileName) else{
        fatalError("Cannot load file \(fileName)")
    }
    var num_array = [Int]()
    for str in contents{
        num_array.append(Int(str) ?? 0)
    }
    return num_array
}

func find_2020(){
    let num_array = get_number_list(fileName: "input.txt")
    var multiple = 0
    for num in num_array{
        for num1 in num_array{
            for num2 in num_array{
                let value = num + num1 + num2
                if value == 2020{
                    print("found it: \(num) \(num1) \(num2)")
                    multiple = num * num1 * num2
                    print("end value: \(multiple)")
                    break
                }
            }
        }
    if multiple > 0{
        break
    }
    }
}

find_2020()
