//
//  workoutViewController.swift
//  FitLife
//
//  Created by Yaroslav on 4/23/24.
//

import UIKit
import HealthKit

class workoutViewController: UIViewController {

    // Tile connections
    @IBOutlet weak var stepsTile: UIView!
    @IBOutlet weak var runningTile: UIView!
    @IBOutlet weak var cyclingTile: UIView!
    @IBOutlet weak var swimmingTile: UIView!
    @IBOutlet weak var weightsTile: UIView!
    @IBOutlet weak var flightsTile: UIView!
    @IBOutlet weak var activeCaloriesTile: UIView!
    @IBOutlet weak var ahikingTile: UIView!
    
    // Label connections
    @IBOutlet weak var runningLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var cyclingLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var swimmingLabel: UILabel!
    @IBOutlet weak var fligthsLabel: UILabel!
    @IBOutlet weak var hikingLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        queryWorkouts()
        queryStepCount()
        queryBurnedCalories()
        setupTileUI()
        // Request authorization status for HealthKit data access
        checkHealthKitAuthorization()
    }
    
    func setupTileUI(){
        let tileView: [UIView] = [stepsTile, runningTile, cyclingTile, swimmingTile, weightsTile, flightsTile, activeCaloriesTile, ahikingTile]
        for tile in tileView{
            tile.layer.cornerRadius = 10
            tile.layer.masksToBounds = true
        }
    }
    
    func updateWorkoutUI(workouts: [HKWorkout]){
        let runningWorkouts = workouts.filter { $0.workoutActivityType == .running}
        runningLabel.text = "\(runningWorkouts.count) Running Workouts"
    }
    
    
    func updateSwimmingUI(workouts: [HKWorkout]){
        let swimmingWorkouts = workouts.filter{
            $0.workoutActivityType == .swimming}
        swimmingLabel.text = "\(swimmingWorkouts.count) Swimming Workout"
        }

    func updateCyclingUI(workouts: [HKWorkout]){
        let cyclingWorkouts = workouts.filter{
            $0.workoutActivityType == .cycling}
        cyclingLabel.text = "\(cyclingWorkouts.count) Cycling Workout"
        }

    func updateWeightsUI(workouts: [HKWorkout]){
        let weightsWorkouts = workouts.filter{
            $0.workoutActivityType == .functionalStrengthTraining}
        weightLabel.text = "\(weightsWorkouts.count) Strength Workout"
        }
    
    func updateStairClimbUI(workouts: [HKWorkout]){
        let stairsClimbed = workouts.filter{
            $0.workoutActivityType == .stairClimbing}
        fligthsLabel.text = "\(stairsClimbed.count) Stairs Climbed"
        }
    
    func updateHikingUI(workouts: [HKWorkout]){
        let hikingWorkouts = workouts.filter{
            $0.workoutActivityType == .hiking}
        hikingLabel.text = "\(hikingWorkouts.count) Hiking Workout"
        }
    
    
    
    func requestAuthorization() {
            // Request authorization for required HealthKit data types
            let typesToRead: Set<HKObjectType> = [
                HKObjectType.workoutType(),
                HKObjectType.quantityType(forIdentifier: .stepCount)!
            ]
            
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if !success {
                print("Error requesting HealthKit authorization: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func queryWorkouts() {
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let workouts = results as? [HKWorkout] {
                DispatchQueue.main.async {
                    self.updateWorkoutUI(workouts: workouts)
                    self.updateSwimmingUI(workouts: workouts)
                    self.updateCyclingUI(workouts: workouts)
                    self.updateWeightsUI(workouts: workouts)
                    self.updateStairClimbUI(workouts: workouts)
                    self.updateHikingUI(workouts: workouts)
                }
            }
        }
        healthStore.execute(query)
    }

    func queryStepCount() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            if let result = result, let sum = result.sumQuantity() {
                let steps = sum.doubleValue(for: HKUnit.count())
                DispatchQueue.main.async {
                    self.stepsLabel.text = "\(Int(steps)) Steps"
                    print("Steps label updated")
                }
            } else {
                print("Failed to query step count: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        healthStore.execute(query)
    }


    
    let healthStore = HKHealthStore()
    
    // Define the types of data from HealthKit
    let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    
    func checkHealthKitAuthorization() {
        healthStore.getRequestStatusForAuthorization(toShare: [], read: typesToRead) { (status, error) in
            switch status {
            case .unknown:
                print("Authorization status is unknown.")
                self.requestAuthorization()
            case .shouldRequest:
                print("HealthKit data access has not been requested yet.")
                self.requestAuthorization()
            case .unnecessary:
                print("HealthKit data access is unnecessary.")
            @unknown default:
                print("Unknown authorization status.")
            }
        }
    }

    func queryBurnedCalories() {
            let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: activeEnergyBurnedType, quantitySamplePredicate: predicate) { [unowned self] (query, result, error) in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("Failed to query burned calories: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
                DispatchQueue.main.async {
                    self.updateCaloriesLabel(caloriesBurned: caloriesBurned, consumedCalories: 0)
                }
            }
            healthStore.execute(query)
        }
        
        func updateCaloriesLabel(caloriesBurned: Double, consumedCalories: Double) {
            let totalCalories = Int(caloriesBurned )
            DispatchQueue.main.async {
                self.calorieLabel.text = "\(totalCalories) Calories Burned"
            }
        }
    
    func promptForAuthorization() {
        //Placeholder, to be implemented
    }

    
    
}
