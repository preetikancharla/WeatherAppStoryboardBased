//
//  DataHandler.swift
//  WeatherAppStoryboardBased
//
//  Created by Preeti Kancharla on 5/19/23.
//

import Foundation
import UIKit

enum AppError: Error {
    case invalidCity
    case noCurrentLocation
    case invalidURL
    case invalidServerResponse
    case invalidData
    case invalidImageData
}

class DataHandler {
    
    let API_KEY = "47bee6a3ec2a5d73a12e741580d066f7"

    private func getWeatherForLocation(coordinates: Coord) async throws -> Weather? {
        
        // form a url
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(coordinates.lat)),
            URLQueryItem(name: "lon", value: String(coordinates.lon)),
            URLQueryItem(name: "appid", value: API_KEY)
        ]
        
        guard let url = components.url  else {
            throw AppError.invalidURL
        }
      
        // get data from url
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AppError.invalidServerResponse
        }

        guard let weatherAllData = try? JSONDecoder().decode(WeatherDataModel.self, from: data) else {
            throw AppError.invalidData
        }
        
        // return data
        return weatherAllData.weather.first
    }
    
    private func getCoordinatesFor(cityName: String) async throws -> Coord? {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/geo/1.0/direct"
        components.queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "limit", value: "1"), // always pass 1 as we only want 1 match
            URLQueryItem(name: "appid", value: API_KEY)
        ]
        
        guard let url = components.url  else {
            throw AppError.invalidURL
        }
   
        // get data from url
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AppError.invalidServerResponse
        }
        
        guard let cityData = try? JSONDecoder().decode([CityDataModel].self, from: data) else {
            throw AppError.invalidData
        }
        print(cityData)
        guard let firstMatch = cityData.first else {
            return nil
        }
        
        //return data
        return Coord(lon: firstMatch.lon, lat: firstMatch.lat)
    }
    
    func getWeatherForDefaultLocation() async throws -> Weather? {
        
        // Get current location. If location is not found, return nil
        guard let currentLocation = LocationHandler.shared.getCurrentLocation() else {
            throw AppError.noCurrentLocation
        }
        
        // return data
        return try await getWeatherForLocation(coordinates: currentLocation)
    }
    
    func getWeatherFor(cityName: String) async throws -> Weather? {
        
        // Get current location. If location is not found, return nil
        guard let coordinates = try await getCoordinatesFor(cityName: cityName) else {
            throw AppError.invalidCity
        }
        
        //return data
        return try await getWeatherForLocation(coordinates: coordinates)
    }
    
    func fetchImageFor(code: String) async throws -> UIImage {
        guard let url = URL(string: "https://openweathermap.org/img/wn/" + code + "@2x.png") else {
            throw AppError.invalidURL
        }
       
        // get data from url
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AppError.invalidServerResponse
        }
        
        guard let image = UIImage(data: data)   else {
            throw AppError.invalidImageData
        }
        
        return image
    }
    
    
}
