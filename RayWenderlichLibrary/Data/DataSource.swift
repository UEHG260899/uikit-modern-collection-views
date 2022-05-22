//
//  DataSOurce.swift
//  RayWenderlichLibrary
//
//  Created by Uriel Hernandez Gonzalez on 21/05/22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import Foundation

class DataSource {
    static let shared = DataSource()
    
    private let decoder = PropertyListDecoder()
    
    var tutorials: [TutorialCollection]
    
    private init() {
        guard let url = Bundle.main.url(forResource: "Tutorials", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let tutorials = try? decoder.decode([TutorialCollection].self, from: data) else {
            self.tutorials = []
            return
        }
        
        self.tutorials = tutorials
    }
}
