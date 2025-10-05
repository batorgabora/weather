import SwiftUI
import UIKit
import Foundation
import CoreLocation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
    let visibility: Int
    let wind: Wind
    let sys: Sys

    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let pressure: Int
        let humidity: Int
    }

    struct Weather: Codable {
        let description: String
        let icon: String
    }

    struct Wind: Codable {
        let speed: Double
    }

    struct Sys: Codable {
        let country: String
        let sunrise: Int
        let sunset: Int
    }
}

class WeatherService {
    static let shared = WeatherService()
    private init() {}

    private let baseUrl = "https://api.openweathermap.org/data/2.5"

    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENWEATHER_API_KEY"] as? String else {
            fatalError("❌ Missing API key in Secrets.plist")
        }
        return key
    }

    func fetchWeather(for city: String) async throws -> WeatherResponse {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseUrl)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric")
        else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var globe = vars.shared
    private let weatherService = WeatherService.shared

    func getWeather(for city: String) {
        Task {
            do {
                let weatherResponse = try await weatherService.fetchWeather(for: city)

                globe.city = city
                globe.country = weatherResponse.sys.country
                globe.degrees = weatherResponse.main.temp
                globe.feels = weatherResponse.main.feels_like
                globe.pressure = weatherResponse.main.pressure
                globe.humidity = weatherResponse.main.humidity
                globe.visibility = weatherResponse.visibility
                globe.wind = weatherResponse.wind.speed

                if let description = weatherResponse.weather.first?.description {
                    globe.descript = description
                }

                // Sunrise and sunset times
                let sunriseTime = Date(timeIntervalSince1970: TimeInterval(weatherResponse.sys.sunrise))
                let sunsetTime = Date(timeIntervalSince1970: TimeInterval(weatherResponse.sys.sunset))
                globe.sunrise = sunriseTime
                globe.sunset = sunsetTime

                // Calculate day length / time until event
                if let _ = Optional(globe.time) {
                    let currentTime = globe.time
                    if currentTime > sunriseTime && currentTime < sunsetTime {
                        globe.sunTime = sunsetTime.timeIntervalSince(currentTime)
                    } else if currentTime < sunriseTime {
                        globe.sunTime = sunriseTime.timeIntervalSince(currentTime)
                    } else {
                        globe.sunTime = (sunriseTime.addingTimeInterval(24 * 60 * 60))
                            .timeIntervalSince(currentTime)
                    }
                }

                // Icon choice
                if globe.sunTime < 600 {
                    globe.weatherIcon = "sun.horizon.fill"
                } else {
                    globe.weatherIcon = appleiconate(
                        description: globe.descript,
                        sunset: globe.sunset,
                        sunrise: globe.sunrise
                    )
                }

            } catch {
                print("❌ Error fetching weather: \(error)")
            }
        }
    }
}

func appleiconate(description: String, sunset: Date, sunrise: Date) -> String {
    switch description.lowercased() {
    case "clear sky":
        return !night(sunset: sunset, sunrise: sunrise) ? "sun.max.fill" : "moon.fill"
    case "few clouds", "scattered clouds", "broken clouds":
        return !night(sunset: sunset, sunrise: sunrise) ? "cloud.sun.fill" : "cloud.moon.fill"
    case "overcast clouds": return "cloud.fill"
    case "rain", "light rain", "moderate rain": return "cloud.rain.fill"
    case "heavy rain", "very heavy rain", "heavy intensity rain", "extreme rain": return "cloud.heavyrain.fill"
    case "freezing rain": return "cloud.snow.fill"
    case "shower rain", "heavy intensity shower rain":
        return !night(sunset: sunset, sunrise: sunrise) ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
    case "snow", "light snow", "heavy snow": return "cloud.snow.fill"
    case "sleet": return "cloud.sleet.fill"
    case "thunderstorm", "light thunderstorm", "heavy thunderstorm", "ragged thunderstorm": return "cloud.bolt.rain.fill"
    case "light intensity drizzle", "shower drizzle": return "cloud.drizzle.fill"
    case "mist", "fog", "dust", "sand", "ash", "squalls": return "cloud.fog.fill"
    case "haze": return !night(sunset: sunset, sunrise: sunrise) ? "sun.haze.fill" : "moon.haze.fill"
    case "smoke": return "smoke.fill"
    case "tornado": return "tornado"
    default: return "exclamationmark.triangle.fill"
    }
}

func night(sunset: Date, sunrise: Date) -> Bool {
    let currentDate = Date()
    return currentDate >= sunset || currentDate <= sunrise
}
