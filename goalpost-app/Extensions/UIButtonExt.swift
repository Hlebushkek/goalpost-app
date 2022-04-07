//
//  UIButtonExt.swift
//  goalpost-app
//
//  Created by Gleb Sobolevsky on 06.04.2022.
//

import UIKit

extension UIButton {
    func setSelectedColor() {
        self.backgroundColor = UIColor(red: 0.204, green: 0.780, blue: 0.349, alpha: 1)
    }
    func setDeselectedColor() {
        self.backgroundColor = UIColor(red: 0.698, green: 0.867, blue: 0.686, alpha: 1)
    }
}
