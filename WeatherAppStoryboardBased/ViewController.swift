//
//  ViewController.swift
//  WeatherAppStoryboardBased
//
//  Created by Preeti Kancharla on 5/18/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, LocationHandlerDelegate {

    private let LAST_CITY_SEARCHED = "lastCitySearched"
    private var imageCache: [String:UIImage] = [:]
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        configureUIControls()
        
        if LocationHandler.shared.isCurrentLocationFetched() {
            getWeatherDataForCurrentLocation()
        } else if let lastCitySearched = UserDefaults.standard.string(forKey: LAST_CITY_SEARCHED), !lastCitySearched.isEmpty {
            getWeatherDataFor(cityName: lastCitySearched)
        } else {
            DisplayNoDataToShow()
        }
    }
    
    
    func configureUIControls() {
        
        // Reset controls
        errorMessage.text = ""
        cityTextField.text = ""
        cityLabel.text = ""
        weatherDescription.text = ""
        weatherImage.image = nil
       
        // Configure delegates
        cityTextField.delegate = self
        LocationHandler.shared.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    func getWeatherDataForCurrentLocation() {
        Task{
            do {
                if let weather = try await DataHandler().getWeatherForDefaultLocation() {
                    
                    // display weather data
                    cityLabel.text = "Current Location"
                    weatherDescription.text =  weather.description.capitalized
                    if let image = imageCache[weather.icon] {
                        weatherImage.image = image
                    } else {
                        do {
                            let image = try await DataHandler().fetchImageFor(code: weather.icon)
                            weatherImage.image = image
                            imageCache[weather.icon] = image
                        } catch AppError.invalidImageData {
                            weatherImage.image = nil
                        }
                    }
                    errorMessage.text = ""
                }
            } catch AppError.invalidCity {
                print("Invalid City")
            } catch AppError.noCurrentLocation {
                print(" Current location is unknown")
            } catch (let e){
                print(e.localizedDescription)
            }
        }
    }

    func getWeatherDataFor(cityName: String) {
        Task{
            do {
                
                if let weather = try await DataHandler().getWeatherFor(cityName: cityName) {
                
                    // display weather data
                    cityLabel.text = cityName.capitalized
                    weatherDescription.text =  weather.description.capitalized
                    if let image = imageCache[weather.icon] {
                        weatherImage.image = image
                    } else {
                        do {
                            let image = try await DataHandler().fetchImageFor(code: weather.icon)
                            weatherImage.image = image
                            imageCache[weather.icon] = image
                        } catch AppError.invalidImageData {
                            weatherImage.image = nil
                        }
                    }
                    errorMessage.text = ""
                    UserDefaults.standard.set(cityName, forKey: LAST_CITY_SEARCHED)
                }
            } catch AppError.invalidCity {
                errorMessage.text = "Not a valid city"
                print("Invalid City")
            } catch AppError.noCurrentLocation {
                print(" Current location is unknown")
            } catch (let e){
                print(e.localizedDescription)
            }
        }
    }
    
    func DisplayNoDataToShow() {
        // display weather data
        cityLabel.text = "No data to show"
        weatherDescription.text =  ""
        weatherImage.image = nil
        errorMessage.text = ""
    }
    
    func coordinatesUpdated() {
        if LocationHandler.shared.isCurrentLocationFetched() {
            getWeatherDataForCurrentLocation()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        errorMessage.text = ""
        getWeatherDataFor(cityName: textField.text ?? "")
        return true
    }
}
