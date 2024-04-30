//
//  DetailCalorieController.swift
//  FitLife
//
//  Created by Yaroslav on 4/23/24.
//

import UIKit

class DetailCalorieController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var servingSize: UILabel!
    @IBOutlet weak var totalFatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var potassiumLabel: UILabel!
    @IBOutlet weak var cholesterolLabel: UILabel!
    @IBOutlet weak var carbohydratesLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    
    var food: Food?
    var onFoodAdded: ((Double) -> Void)?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            if let food = food {
                nameLabel.text = food.name.capitalized
                caloriesLabel.text = "\(Int(food.calories))"
                servingSize.text = "\( food.serving_size_g)" + (" g")
                totalFatLabel.text = "\(food.fat_total_g)" + (" g")
                saturatedFatLabel.text = "\(food.fat_saturated_g)" + (" g")
                proteinLabel.text = "\(food.protein_g)" + (" g")
                sodiumLabel.text = "\(food.sodium_mg)" + (" mg")
                potassiumLabel.text = "\(food.potassium_mg)" + (" mg")
                cholesterolLabel.text = "\(food.cholesterol_mg)" + (" mg")
                carbohydratesLabel.text = "\(food.carbohydrates_total_g)" + (" g")
                fiberLabel.text = "\(food.fiber_g)" + (" g")
                sugarLabel.text = "\(food.sugar_g)" + (" g")
            }
        }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let selectedFood = food else { return }
            // Access the tab bar controller
        if let tabBarController = presentingViewController as? UITabBarController {
                // Access the selected view controller
                if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                    // Access the root view controller of the navigation controller
                    if let viewController = navigationController.viewControllers.first as? ViewController {
                        // Update ViewController's foods array
                        viewController.addFood(selectedFood)
                    }
                }
            }
            
            onFoodAdded?(selectedFood.calories)
            dismiss(animated: true, completion: nil)
        }
    
}
