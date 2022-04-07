//
//  FinishGoalVC.swift
//  goalpost-app
//
//  Created by Gleb Sobolevsky on 06.04.2022.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class FinishGoalVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var createGoalButton: UIButton!
    @IBOutlet weak var pointsTextField: UITextField!
    
    var goalDesc: String!
    var goalType: GoalType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointsTextField.delegate = self
        
        createGoalButton.bindToKeyboard()
    }
    
    func initData(desc: String, type: GoalType) {
        self.goalDesc = desc
        self.goalType = type
    }
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func createGoalButtonWasPressed(_ sender: Any) {
        if pointsTextField.text != "" {
            self.saveGoal(completion: { (complete) in
                dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func saveGoal(completion: (_ finish: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let goal = Goal(context: managedContext)
        goal.goalDesc = goalDesc
        goal.goalType = goalType.rawValue
        goal.goalCompletionValue = Int32(pointsTextField.text!)!
        goal.goalProgress = Int32(0)
        
        do {
            try managedContext.save()
            print("Successfully save")
            completion(true)
        } catch {
            debugPrint("Could not save \(error.localizedDescription)")
        }
    }
}
