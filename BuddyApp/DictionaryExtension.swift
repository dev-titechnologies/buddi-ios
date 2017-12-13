//
//  DictionaryExtension.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 10/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}
     
