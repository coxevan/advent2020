import os.log
import Foundation
import PlaygroundSupport

struct PasswordData{
    let min : Int
    let max : Int
    let character : String
    let password : String
}

func get_file_contents(fileName: String) -> [String]? {
    let paths = Bundle.main.paths(forResourcesOfType: "txt", inDirectory: nil)
    for path in paths{
        let url = URL(fileURLWithPath: path)
        if url.lastPathComponent.contains(fileName){
            do{
                let contents = try String(contentsOf: URL(fileURLWithPath: path), encoding: .ascii).components(separatedBy: "\n")
                return contents
            }catch{
                fatalError("\(error)")
            }
        }
    }
    return nil
}

func get_password_data(fileName: String) -> [PasswordData]{
    guard let file_lines = get_file_contents(fileName:fileName) else{
        fatalError("File contents not valid \(fileName)")
    }
    var password_data_array = [PasswordData]()
    for line in file_lines{
        let split_line = line.components(separatedBy:" ")
        if split_line.count != 3{
            print("Skipping line...")
            print(split_line)
            continue
        }
        
        // grab the min and max values
        let min_max = split_line[0].split(separator: "-")
        
        let int_min = Int(min_max[0]) ?? 0
        let int_max = Int(min_max[1]) ?? 0
        
        let character = String(split_line[1].prefix(1))
        let password = String(split_line[2])
        
        let pass_data = PasswordData(min: int_min, max: int_max, character:character, password:password)
        password_data_array.append(pass_data)
    }
    return password_data_array
}

func validate_password_data(fileName: String) -> Int{
    let password_data_array = get_password_data(fileName: fileName)
    var valid_passwords = 0
    for password_data in password_data_array{
        let password = password_data.password
        var char1 = String(Array(password)[password_data.min - 1])//String(password[password.index(password.startIndex, offsetBy: password_data.min+1)])
        var char2 = String(Array(password)[password_data.max - 1])//String(password[password.index(password.startIndex, offsetBy: password_data.max+1)])
        if char1 != password_data.character && char2 == password_data.character{
            valid_passwords += 1
            continue
        }else if char1 == password_data.character && char2 != password_data.character{
            valid_passwords += 1
            continue
        }
    }
    return valid_passwords
}

print(validate_password_data(fileName: "input_day2"))
