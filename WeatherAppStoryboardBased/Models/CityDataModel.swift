//
//  CityDataModel.swift
//  WeatherAppStoryboardBased
//
//  Created by Preeti Kancharla on 5/19/23.
//

import Foundation


// MARK: - CityDataModel
struct CityDataModel: Codable {
    let name: String
    let localNames: [String: String]?
    let lat, lon: Double
    let country, state: String

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

typealias CityMatches = [CityDataModel]
