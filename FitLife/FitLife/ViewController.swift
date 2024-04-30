//
//  ViewController.swift
//  FitLife
//
//  Created by Yaroslav on 4/16/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCaloriesFieldText: UITextField!
    var workoutVC: workoutViewController?
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
    }
    let lastResetDateKey = "lastResetDate"
    let api = Api()
    var foods: [Food] = []
    var selectedFood: Food?
    var totalCalories: Int = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        totalCaloriesFieldText.layer.masksToBounds = true
        totalCaloriesFieldText.layer.cornerRadius = 15
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        if let savedData = UserDefaults.standard.data(forKey: "savedFoods") {
                // Print out the saved data to check its contents
                print("Saved data: \(savedData)")
                
                // Attempt to decode saved data into [Food]
                do {
                    let savedFoods = try JSONDecoder().decode([Food].self, from: savedData)
                    print("Saved foods: \(savedFoods)")
                    foods = savedFoods
                } catch {
                    print("Error decoding saved data: \(error)")
                }
            } else {
                print("No saved data found")
            }
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
                    let currentDate = Date()
                    // Compare dates to check if it's a new day
                    if !Calendar.current.isDate(lastResetDate, inSameDayAs: currentDate) {
                        // Reset stored food data
                        resetStoredFoods()
                    }
                } else {
                    // Set current date as last reset date
                    UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
                }
        if let savedTotalCalories = UserDefaults.standard.value(forKey: "totalCalories") as? Int {
                totalCalories = savedTotalCalories
                updateTotalCaloriesLabel() // Update the label with the saved total calories
            }
    }
    
    func saveTotalCalories() {
        UserDefaults.standard.set(totalCalories, forKey: "totalCalories")
    }
    
    func resetStoredFoods() {
            foods = []
            saveFoods()
            // Update last reset date to current date
            UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
            print("Stored food data reset for the new day.")
        }
    
    func saveFoods() {
        print("saveFoods is called")
            // Convert foods array to data
            if let encodedData = try? JSONEncoder().encode(foods) {
                // Save data to UserDefaults
                print("Encoded data: \(encodedData)")
                UserDefaults.standard.set(encodedData, forKey: "savedFoods")
                print("Foods saved successfully!")
            } else {
                print("Failed to encode foods array")
            }
    }	
    
    func addFood(_ food: Food) {
        foods.append(food)
        totalCalories += Int(food.calories)
        saveTotalCalories() // Save after updating totalCalories
        saveFoods() // Save foods array
        tableView.reloadData()
        updateTotalCaloriesLabel()
        print("Food added. Saving foods...")
    }
    
    func updateTotalCaloriesLabel() {
        print("Updating total calories label with value: \(totalCalories)")
        totalCaloriesFieldText.text = "\(totalCalories) 🔥"
        workoutVC?.updateCaloriesLabel(caloriesBurned: 0, consumedCalories: Double(totalCalories))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let food = foods[indexPath.row]
        cell.textLabel?.text = "\(food.name.capitalized): \(Int(food.calories))"
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetail", sender: indexPath.row)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedFood = foods[indexPath.row]
            foods.remove(at: indexPath.row)
            totalCalories -= Int(deletedFood.calories)
            updateTotalCaloriesLabel()
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveFoods()
        }
    }
        
        // MARK: - UISearchBarDelegate
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            guard let query = searchBar.text else { return }
               api.loadData(query: query) { [weak self] foods in
                   DispatchQueue.main.async {
                       // Only perform segue if there are search results
                       if let firstFood = foods.first {
                           self?.performSegue(withIdentifier: "ShowDetail", sender: firstFood)
                       }
                   }
               }
        }
            
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let selectedFood = sender as? Food,
               let destinationVC = segue.destination as? DetailCalorieController {
                    destinationVC.food = selectedFood
                    destinationVC.onFoodAdded = { [weak self] calories in
                        self?.updateTotalCaloriesLabel()
                        
                        // Check if workoutVC is not nil before calling updateCaloriesLabel
                        if let workoutVC = self?.workoutVC {
                            workoutVC.updateCaloriesLabel(caloriesBurned: 0, consumedCalories: Double(self?.totalCalories ?? 0))
                        }
                    }
            }
        } else if let workoutVC = segue.destination as? workoutViewController {
            self.workoutVC = workoutVC
        }
    }


}
