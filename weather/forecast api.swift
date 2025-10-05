//
//  forecast api.swift
//  weather
//
//  Created by Gábora Bátor on 2024. 12. 21..
//

import SwiftUI
import UIKit
import Foundation
import CoreLocation

struct ForecastResponse: Codable {
    let list: [Forecast]
    let city: City

    struct Forecast: Codable {
        let dt: Int
        let main: WeatherResponse.Main
        let weather: [WeatherResponse.Weather]
        let wind: WeatherResponse.Wind
    }

    struct City: Codable {
        let name: String
        let country: String
    }
}

struct ForecastItem {
    let date: Date
    let temperature: Double
    let description: String
    let windSpeed: Double
}


class ForecastService {
    private let baseUrl = "https://api.openweathermap.org/data/2.5"
    
    // Load API key from Secrets.plist instead of hardcoding
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENWEATHER_API_KEY"] as? String else {
            fatalError("❌ Missing API key in Secrets.plist")
        }
        return key
    }

    func fetchForecast(for city: String, completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        let urlString = "\(baseUrl)/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                return
            }

            do {
                let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                completion(.success(forecastResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

class ForecastViewModel: ObservableObject {
    @Published var globe = vars.shared
    private let forecastService = ForecastService()
    
    func getForecast(for city: String) {
        forecastService.fetchForecast(for: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let forecastResponse):
                
                    self?.globe.forecasts = forecastResponse.list.map { forecast in
                                        ForecastItem(
                                            date: Date(timeIntervalSince1970: TimeInterval(forecast.dt)),
                                            temperature: forecast.main.temp,
                                            description: forecast.weather.first?.description ?? "",
                                            windSpeed: forecast.wind.speed
                                        )
                                    }
                    
                    let forecasts = forecastResponse.list       //create a list based on the structure of ForecastResponse
                                        
                    // map the forecast data to the dayplus variables
                            self?.globe.dayplus = getDay(for: forecasts[7].dt)
                    self?.globe.weatherIconplus = forecasticonate(description: forecasts[7].weather.first?.description ?? "")
                            self?.globe.degreesplus = forecasts[7].main.temp
                            
                            self?.globe.dayplus2 = getDay(for: forecasts[15].dt)
                    self?.globe.weatherIconplus2 = forecasticonate(description: forecasts[15].weather.first?.description ?? "")
                            self?.globe.degreesplus2 = forecasts[15].main.temp
                            
                            self?.globe.dayplus3 = getDay(for: forecasts[23].dt)
                    self?.globe.weatherIconplus3 = forecasticonate(description: forecasts[23].weather.first?.description ?? "")
                            self?.globe.degreesplus3 = forecasts[23].main.temp
                            
                            self?.globe.dayplus4 = getDay(for: forecasts[31].dt)
                    self?.globe.weatherIconplus4 = forecasticonate(description: forecasts[31].weather.first?.description ?? "")
                            self?.globe.degreesplus4 = forecasts[31].main.temp
                            
                            self?.globe.dayplus5 = getDay(for: forecasts[39].dt)
                    self?.globe.weatherIconplus5 = forecasticonate(description: forecasts[39].weather.first?.description ?? "")
                            self?.globe.degreesplus5 = forecasts[39].main.temp
                    
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }
        }
    }
}

func getDay(for timestamp: Int) -> String
{
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // get abbreviated day (e.g., "Mon") format
        return dateFormatter.string(from: date).uppercased() //uppercase it
}

func forecasticonate(description: String) -> String {
        switch description.lowercased() {
        case "clear sky":
            return "sun.max.fill"
        case "few clouds":
            return "cloud.sun.fill"
        case "scattered clouds":
           return "cloud.sun.fill"
        case "broken clouds":
            return "cloud.sun.fill"
        case "overcast clouds":
            return "cloud.fill"
        case "rain":
            return "cloud.rain.fill"
        case "light rain":
            return "cloud.rain.fill"
        case "moderate rain":
            return "cloud.rain.fill"
        case "heavy rain":
            return "cloud.heavyrain.fill"
        case "very heavy rain":
            return "cloud.heavyrain.fill"
        case "heavy intensity rain":
            return "cloud.heavyrain.fill"
        case "extreme rain":
            return "cloud.heavyrain.fill"
        case "freezing rain":
            return "cloud.snow.fill"
        case "shower rain":
            return "cloud.sun.rain.fill"
        case "heavy intensity shower rain":
           return "cloud.sun.rain.fill"
        case "snow":
            return "snowflake"
        case "light snow":
            return "cloud.snow.fill"
        case "heavy snow":
            return "cloud.snow.fill"
        case "sleet":
            return "cloud.sleet.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "thunderstorm with light rain":
            return "cloud.bolt.rain.fill"
        case "light thunderstorm":
            return "cloud.bolt.rain.fill"
        case "heavy thunderstorm":
            return "cloud.bolt.rain.fill"
        case "ragged thunderstorm":
            return "cloud.bolt.rain.fill"
        case "light intensity drizzle":
            return "cloud.drizzle.fill"
        case "shower drizzle":
            return "cloud.drizzle.fill"
        case "mist":
            return "cloud.fog.fill"
        case "haze":
          return "sun.haze.fill"
        case "fog":
            return "cloud.fog.fill"
        case "smoke":
            return "smoke.fill"
        case "dust":
            return "cloud.fog.fill"
        case "sand":
            return "cloud.fog.fill"
        case "ash":
            return "cloud.fog.fill"
        case "squalls":
            return "cloud.fog.fill"
        case "tornado":
            return "tornado"
        default: return "exclamationmark.triangle.fill"
        }
    }
