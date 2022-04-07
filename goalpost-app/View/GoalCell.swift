//
//  GoalCell.swift
//  goalpost-app
//
//  Created by Gleb Sobolevsky on 05.04.2022.
//

import UIKit

class GoalCell: UITableViewCell {
    
    @IBOutlet weak var goalDescLabel: UILabel!
    @IBOutlet weak var goalTypeLabel: UILabel!
    @IBOutlet weak var goalProgressLabel: UILabel!
    
    var completeView: UIView?
    
    func configureCell(goal: Goal, cellSize: CGSize) {
        self.goalDescLabel.text = goal.goalDesc
        self.goalTypeLabel.text = goal.goalType
        self.goalProgressLabel.text = String(goal.goalProgress)

        if let completeView = completeView {
            completeView.removeFromSuperview()
        }
        if goal.goalProgress == goal.goalCompletionValue {
            showCompleteView(cellSize)
        }
    }
    
    func showCompleteView(_ cellSize: CGSize) {        
        completeView = UIView(frame: CGRect(origin: CGPoint.zero, size: cellSize))
        completeView!.backgroundColor = .orange.withAlphaComponent(0.75)
        self.addSubview(completeView!)
        
        var descriptor = UIFontDescriptor(fontAttributes: [.family: "Avenir Next"])
        descriptor = descriptor.withSymbolicTraits(.traitBold)!
        let completeLabelFont = UIFont(descriptor: descriptor, size: 32)
        
        let completeLabel = UILabel()
        completeLabel.frame = completeView!.frame
        completeLabel.text = "Complete!"
        completeLabel.font = completeLabelFont
        completeLabel.textColor = .white
        completeLabel.textAlignment = .center
        completeView!.addSubview(completeLabel)
    }
}
