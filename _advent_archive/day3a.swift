import os.log
import Foundation
import PlaygroundSupport

let TREE = "#"
let NOT_TREE = "."

let SLOPES = [(3,1)]

struct Geography{
    let hills : Array<String>
    var current_y = 0
    var current_x = 0
    
    mutating func go_to_next_tile(slope_x: Int = 3, slope_y: Int = 1)->String{
        let line = hills[current_y]
        if line.count <= current_x{
            current_x = current_x - line.count
        }
        let line_array = Array(line)
        
        let my_char = String(line_array[current_x])
        current_y += slope_y
        current_x += slope_x
        if current_y == get_hill_count(){
            print("Hit hill max")
        }
        return my_char
    }
    
    mutating func reset_hills(){
        current_y = 0
        current_x = 0
    }
    
    func get_hill_count() -> Int{
        return hills.count
    }
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

func navigate_trees()->Int{
    guard let tile_array = get_file_contents(fileName:"input_day3") else { return 0 }
    var geo_cache = Geography(hills:tile_array)

    var tree_count = 0
    for slope_set in SLOPES{
        for _ in 0...geo_cache.get_hill_count() - 1{
            var tile = geo_cache.go_to_next_tile(slope_x: slope_set.0, slope_y: slope_set.1)
            if tile == TREE{
                tree_count += 1
            }
        }
    }
    return tree_count
}
print(navigate_trees())
