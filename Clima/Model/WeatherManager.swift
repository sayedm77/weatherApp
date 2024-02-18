//
//  WeatherManager.swift
//  Clima
//
//  Created by elsayed mansour mahfouz on 11/20/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
protocol WeatherManagerDelegete {
    func  didUpdateWeather(  _ weatherManager : WeatherManager, weather:WeatherModel)
    func didFailWithError( _ error : Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=5f6274ae5a684850f85eb85c17e9f8d3&units=metric"
    func fetchWeather (cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performReqeust(with: urlString )
    }
    func fetchWeather (latitude :CLLocationDegrees,longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat = \(latitude)&lon= \(longitude)"
        performReqeust(with: urlString)
    }
   
    var delegate : WeatherManagerDelegete?
    func performReqeust(with urlString:String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task =  session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON( safeData){
                        self.delegate?.didUpdateWeather( self, weather: weather)
                    }
                }
                
            }
            task.resume()
        }
    }
    func parseJSON( _ weatherData:Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
       let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let cityName = decodedData.name
            let temp = decodedData.main.temp
            let weather = WeatherModel(conditionId: id, name: cityName, temprature: temp)
            return weather
        }catch{
            delegate?.didFailWithError( error)
            return nil
        }
        
        
    }
    
}
