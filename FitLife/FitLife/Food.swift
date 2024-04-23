//
//  Food.swift
//  FitLife
//
//  Created by Yaroslav on 4/23/24.
//

import Foundation

struct Food: Codable, Identifiable {
    private(set) var id = UUID()

    var name: String
    var calories: Double
    var serving_size_g: Double
    var fat_total_g: Double
    var fat_saturated_g: Double
    var protein_g: Double
    var sodium_mg: Double
    var potassium_mg: Double
    var cholesterol_mg: Double
    var carbohydrates_total_g: Double
    var fiber_g: Double
    var sugar_g: Double

    private enum CodingKeys: String, CodingKey {
        case name
        case calories
        case serving_size_g
        case fat_total_g
        case fat_saturated_g
        case protein_g
        case sodium_mg
        case potassium_mg
        case cholesterol_mg
        case carbohydrates_total_g
        case fiber_g
        case sugar_g
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.calories = try container.decode(Double.self, forKey: .calories)
        self.serving_size_g = try container.decode(Double.self, forKey: .serving_size_g)
        self.fat_total_g = try container.decode(Double.self, forKey: .fat_total_g)
        self.fat_saturated_g = try container.decode(Double.self, forKey: .fat_saturated_g)
        self.protein_g = try container.decode(Double.self, forKey: .protein_g)
        self.sodium_mg = try container.decode(Double.self, forKey: .sodium_mg)
        self.potassium_mg = try container.decode(Double.self, forKey: .potassium_mg)
        self.cholesterol_mg = try container.decode(Double.self, forKey: .cholesterol_mg)
        self.carbohydrates_total_g = try container.decode(Double.self, forKey: .carbohydrates_total_g)
        self.fiber_g = try container.decode(Double.self, forKey: .fiber_g)
        self.sugar_g = try container.decode(Double.self, forKey: .sugar_g)
    }
}
class Api : ObservableObject{
    @Published var foods = [Food]()
    
    func loadData(query: String, completion:@escaping ([Food]) -> ()) {
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "https://api.api-ninjas.com/v1/nutrition?query="+query!)!
        var request = URLRequest(url: url)
        request.setValue("3hApeZy/1CKIxp8W02F7kw==nfjbWcrMUtPmJ531", forHTTPHeaderField: "X-Api-Key")
        URLSession.shared.dataTask(with: request) { data, response, error in
            let foods = try! JSONDecoder().decode([Food].self, from: data!)
            print(foods)
            DispatchQueue.main.async {
                completion(foods)
            }
        }.resume()
    }
}
