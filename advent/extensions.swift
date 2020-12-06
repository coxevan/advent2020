//
//  extensions.swift
//  advent
//
//  Created by Evan on 12/5/20.
//

import Foundation

extension String {
    func count(of needle: Character) -> Int {
        return reduce(0) {
            $1 == needle ? $0 + 1 : $0
        }
    }
}
