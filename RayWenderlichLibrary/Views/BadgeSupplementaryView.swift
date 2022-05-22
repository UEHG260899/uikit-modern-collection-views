//
//  BadgeSupplementaryView.swift
//  RayWenderlichLibrary
//
//  Created by Uriel Hernandez Gonzalez on 22/05/22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import UIKit

class BadgeSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: BadgeSupplementaryView.self)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = UIColor(named: "rw-green")
        let radius = bounds.width / 2
        layer.cornerRadius = radius
    }
}
