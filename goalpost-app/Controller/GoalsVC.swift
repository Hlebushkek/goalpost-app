//
//  ViewController.swift
//  goalpost-app
//
//  Created by Gleb Sobolevsky on 05.04.2022.
//

import UIKit
import CoreData

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var goals: [Goal] = []
    var lastGoalsSize = 0
    var goalsDifference: Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCoreDataGoals()
        tableView.reloadData()
        
        if let goal = goalsDifference {
            createUndoButton(forUndoAction: {
                self.removeGoal(goal: goal)
                self.fetchCoreDataGoals()
                self.tableView.deleteRows(at: [IndexPath(row: self.goals.count, section: 0)], with: .automatic)
            }, onButtonDisapear: nil)
        }
    }
    
    func fetchCoreDataGoals() {
        self.fetch { (complete) in
            if complete {
                if goals.count >= 1 { tableView.isHidden = false }
                else { tableView.isHidden = true }
            }
        }
    }

    @IBAction func addGoalButtonWasPressed(_ sender: Any) {
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "createGoalVC") else { return }
        
        presentDetail(createGoalVC)
    }
}

extension GoalsVC {
    func setProgress(atIndexPath indexPath: IndexPath) {
        guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let chosenGoal = goals[indexPath.row]
        
        if chosenGoal.goalProgress < chosenGoal.goalCompletionValue {
            chosenGoal.goalProgress += 1
            
            do {
                try manageContext.save()
                print("Successfully set progress")
            } catch {
                debugPrint("Could not set progress: \(error.localizedDescription)")
            }
        } else { return }
    }
    
    func removeGoal(goal: Goal) {
        guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
        
        manageContext.delete(goal)
        
        do {
            try manageContext.save()
        } catch {
            debugPrint("Could not delete: \(error.localizedDescription)")
        }
    }
    
    func fetch(completion: (_ complete: Bool)->()) {
        guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")

        do {
            let updatedGoals = try manageContext.fetch(fetchRequest)
            
            if (!tableView.isHidden && !goals.isEmpty) { //preven undo button to appear on launch
                lastGoalsSize = goals.count
                goalsDifference = Array(Set(goals).symmetricDifference(Set(updatedGoals))).first
            }
            goals = updatedGoals

            print("Successfully fetched data")
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
}

extension GoalsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else { return UITableViewCell() }
        
        let goal = goals[indexPath.row]
        cell.configureCell(goal: goal, cellSize: tableView.rectForRow(at: indexPath).size)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            
            let goal = self.goals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.createUndoButton(forUndoAction: {
                self.fetchCoreDataGoals()
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }, onButtonDisapear: {
                self.removeGoal(goal: goal)
                self.fetchCoreDataGoals()
            })

        }
        deleteAction.backgroundColor = .red
        
        let addProgressAction = UIContextualAction(style: .normal, title: "Add 1") { (_, _, _) in
            self.setProgress(atIndexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        addProgressAction.backgroundColor = .orange
        
        return UISwipeActionsConfiguration(actions: [deleteAction, addProgressAction])
    }
}

extension GoalsVC {
    func createUndoButton(forUndoAction action: @escaping ()->(), onButtonDisapear completion: (()->())?, needPerformCompletionIfUndoActionHappend: Bool = false) {
        var needPerformCompletion = true
        //button pref
        let bWidth: CGFloat = 120; let bHeight: CGFloat = 40
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.width / 2 - bWidth / 2, y: self.view.frame.height - bHeight - 40, width: bWidth, height: bHeight)
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        button.setTitle("Undo", for: .normal)
        button.transform = CGAffineTransform(translationX: 0, y: bHeight + 40)
        //add button to view
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
        //
        button.addAction(UIAction(handler: {_ in
            button.backgroundColor = .orange
            action()
            needPerformCompletion = needPerformCompletionIfUndoActionHappend
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
                button.transform = CGAffineTransform(translationX: 0, y: bHeight + 40)
            }, completion: nil)
        }), for: UIControl.Event.touchUpInside)
        //remove button animation
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
            button.transform = .identity
        }, completion: {_ in
            UIView.animate(withDuration: 3, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                button.alpha = 0.02
            }, completion: {_ in
                if (completion != nil && needPerformCompletion) { completion!() }
                button.removeFromSuperview()
            })
        })
    }
}
