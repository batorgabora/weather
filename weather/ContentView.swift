//
//  ContentView.swift
//  weather
//
//  Created by Gábora Bátor on 2024. 12. 10..
//

import SwiftUI
import UIKit
import Foundation
import CoreLocation

class GlobalState: ObservableObject                 //define pieces of state --> shared across
    {
    @Published var city = "nono"                    //different views
    @Published var country = "no work"              // --> automatically updates
    @Published var degrees = 0.00
    @Published var feels = 0.00
    @Published var pressure = 0
    @Published var visibility = 0
    @Published var wind = 0.00
    @Published var humidity = 0
    @Published var percipitation = 0.0
    @Published var sunrise: Date = Date() + 1
    @Published var sunset: Date = Date() - 1
    @Published var sunTime: TimeInterval = 2
    @Published var time: Date = Date()
    @Published var weatherIcon = "tornado"
    
    @Published var descript = "no worky"
    
    @Published var forecasts: [ForecastItem] = []
    
    @Published var dayplus = "nah"
    @Published var weatherIconplus = "hare.fill"
    @Published var degreesplus = 0.0
    
    @Published var dayplus2 = "cro"
    @Published var weatherIconplus2 = "hare.fill"
    @Published var degreesplus2 = 0.0
    
    @Published var dayplus3 = "why"
    @Published var weatherIconplus3 = "hare.fill"
    @Published var degreesplus3 = 0.0
    
    @Published var dayplus4 = "not"
    @Published var weatherIconplus4 = "hare.fill"
    @Published var degreesplus4 = 0.0
    
    @Published var dayplus5 = "work"
    @Published var weatherIconplus5 = "tortoise.fill"
    @Published var degreesplus5 = 0.0
    
    @Published var location = "Szekszárd"
    
    @Published var typed = "Szekszárd"
    
    @Published var toCheck = ""
    
    @Published var textview = false
}
class vars {                                    //singleton holder for the GlobalState
    static let shared = GlobalState()           //shared instance --> accessed globally
}

struct ContentView: View
{
    @ObservedObject var globe = vars.shared
    @ObservedObject var forecastt = ForecastViewModel()
    @State var weatherr = WeatherViewModel()
    @State var locationn = LocationManager.shared
    
    
    var body: some View
    {
        ZStack
        {
            backgrounds(top: .black, center: .bluey, bottom: .greeny)
            
            VStack
            {
                location(city: globe.city, country: globe.country)
                
                Spacer()
                
                info(icon: globe.weatherIcon, degrees: globe.degrees)
                
                Text("feels like: \(String(format: "%.2f", globe.feels))°C")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold, design: .default))
                
                Spacer()
                
                HStack {
                    Spacer()
                    HStack(spacing: 25)
                    {
                        weatherDay(day: globe.dayplus,
                                   icon: globe.weatherIconplus,
                                   temp: Int(globe.degreesplus))
                        weatherDay(day: globe.dayplus2,
                                   icon: globe.weatherIconplus2,
                                   temp: Int(globe.degreesplus2))
                        weatherDay(day: globe.dayplus3,
                                   icon: globe.weatherIconplus3,
                                   temp: Int(globe.degreesplus3))
                        weatherDay(day: globe.dayplus4,
                                   icon: globe.weatherIconplus4,
                                   temp: Int(globe.degreesplus4))
                        weatherDay(day: globe.dayplus5,
                                   icon: globe.weatherIconplus5,
                                   temp: Int(globe.degreesplus5))
                    }
                    Spacer()
                }.frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .padding(20)
                    .onAppear
                        {
                        // Fetch weather when the view appears
                            weatherr.getWeather(for: "Budakeszi")
                            forecastt.getForecast(for: "Budakeszi")
                            locationn.fetchCurrentCity()
                        }
                
                Spacer()
                
                HStack {
                    Spacer()
                    buttonOne()
                    Spacer()
                    extra()
                    Spacer()
                    buttonTwo()
                    Spacer()
                }
                Spacer()
                
                HStack {
                    Spacer()
                    buttonThree(
                                    globe: vars.shared,
                                    weatherr: WeatherViewModel(),
                                    forecastt: ForecastViewModel(),
                                    locationn: LocationManager.shared
                                )
                    Spacer()
                    buttonFour()
                    Spacer()
                }
            }
        }
    }
}
#Preview
{
    ContentView()
}
func cityran() -> String {
    let randomIndex = Int.random(in: 0..<20)
    
    switch randomIndex {
    case 0: return "New York"
    case 1: return "Tokyo"
    case 2: return "Paris"
    case 3: return "Melbourne"
    case 4: return "Woodridge"
    case 5: return "Budapest"
    case 6: return "Rio de Janeiro"
    case 7: return "Cape Town"
    case 8: return "Horsens"
    case 9: return "Aarhus"
    case 10: return "Los Angeles"
    case 11: return "Shanghai"
    case 12: return "Hong Kong"
    case 13: return "Kathmandu"
    case 14: return "Reggio di Calabria"
    case 15: return "Detroit"
    case 16: return "Caracas"
    case 17: return "Stockholm"
    case 18: return "Lahti"
    case 19: return "Létavértes"
    default: return "Kiskunfélegyháza" // this case is just for safety, won't be reached
    }
}

func timeInter(for timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = (Int(timeInterval) % 3600) / 60
    let seconds = Int(timeInterval) % 60
    
    return String(format: "%02dh %02dmin", hours, minutes, seconds)
    //return in hh:mm:ss format
    //return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

struct backgrounds: View {
    var top: Color
    var center: Color
    var bottom: Color
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [top, center, bottom]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
}

struct location: View {
    var city: String
    var country: String
    var body: some View {
        HStack
        {
            Text(city + ",")  //city and country from API
            Text(country)
        }.foregroundColor(.white)
            .font(.system(size: 24, weight: .bold, design: .default))
            .padding(.top, 5)
    }
}

struct info: View {
    var icon: String
    var degrees: Double
    var body: some View {
        VStack(spacing: 5)
        {
            Image(systemName: icon)  //icon variable from API
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
                .padding(.bottom, 8)
            
            Text("\(String(format: "%.2f", degrees))°C")
                .font(.system(size: 37, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, 2)
        }.padding(5)
    }
}

struct weatherDay: View {
    @ObservedObject var globe = vars.shared
    
    var day = ""
    var icon = ""
    var temp = 4
    
    var body: some View {
        VStack
        {
            Text(day)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.white)
            Image(systemName: icon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            Text("\(temp)°")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.white)
        }
    }
}

struct extra: View {
    @ObservedObject var globe = vars.shared
    var body: some View {
        VStack(spacing: 8)
        {
            Text("\(globe.descript)").italic()
            Text("pressure: \(globe.pressure) hPa")
            Text("visibility: \(globe.visibility)m")
            Text("wind speed: \(String(format: "%.1f", globe.wind)) m/s")
            Text("humidity: \(globe.humidity)%")
            if globe.time > globe.sunrise && globe.time < globe.sunset{
                Text("sunset: \(timeInter(for: globe.sunTime))")
            }
            else
            {
                Text("sunrise: \(timeInter(for: globe.sunTime))")
            }
            
        }.foregroundColor(.white)
            .font(.system(size: 21, weight: .bold, design: .default))
            .padding(10)
    }
}

struct buttonOne: View {
    @ObservedObject var globe = vars.shared
    @State var weatherr = WeatherViewModel()
    @State var forecastt = ForecastViewModel()
    @State var pressed = false
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                pressed.toggle() // Toggle between true and false
            }
            let cityy = cityran()
            weatherr.getWeather(for: cityy)
            forecastt.getForecast(for: cityy)
        }) {
            ZStack
            {
                Circle().frame(width: 30, height: 30).foregroundStyle(.black)
                Circle().frame(width: 28, height: 28)
                Image(systemName: "globe.europe.africa.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 30, weight: .bold))
                    .rotationEffect(.degrees(pressed ? 360 : 0))
                    .shadow(radius: 20)
            }
        }
    }
}

struct buttonTwo: View {
    @ObservedObject var globe = vars.shared
    @State var weatherr = WeatherViewModel()
    @State var forecastt = ForecastViewModel()
    @State var pressed = false
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                pressed.toggle() // Toggle between true and false
            }
            weatherr.getWeather(for: "Debrecen")
            forecastt.getForecast(for: "Debrecen")
        }) {
            Image(systemName: "building.2.fill")
                .foregroundStyle(.gray)
                .font(.system(size: 25, weight: .bold))
                .rotationEffect(.degrees(pressed ? 360 : 0))
                .shadow(radius: 20)
        }
    }
}

struct buttonThree: View {
    @ObservedObject var globe = vars.shared
    @State var weatherr = WeatherViewModel()
    @State var forecastt = ForecastViewModel()
    @State var locationn = LocationManager.shared
    @State var pressed = false

    var body: some View {
        if !globe.textview {
            Button(action: {
                withAnimation(.spring()) {
                    pressed.toggle() // Toggle animation
                }
                locationn.fetchCurrentCity()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("Updated location: \(vars.shared.location)")
                    weatherr.getWeather(for: globe.location)
                    forecastt.getForecast(for: globe.location)
                }
            }) {
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 20, weight: .bold))
                    .rotationEffect(.degrees(pressed ? 360 : 0))
                    .shadow(radius: 20)
            }
        }
        
    }
}

struct buttonFour: View {
    @ObservedObject var globe = vars.shared
    @State var weatherr = WeatherViewModel()
    @State var forecastt = ForecastViewModel()
    @State private var cityName = ""

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Show magnifying glass button only when input view isn't presented
                if !globe.textview {
                    Button(action: {
                        withAnimation {
                            globe.textview = true // Show the input field
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .font(.system(size: 25, weight: .bold))
                            .shadow(radius: 20)
                    }
                }
            }

            // Input field overlay
            if globe.textview {
                VStack {
                    TextField("enter city", text: $cityName, onCommit: {
                        // Automatically dismiss and update weather
                        globe.typed = cityName
                        weatherr.getWeather(for: globe.typed)
                        forecastt.getForecast(for: globe.typed)
                        withAnimation {
                            globe.textview = false
                        }
                    })
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
                    .overlay(
                        HStack {
                            Spacer()
                            if !cityName.isEmpty {
                                Button(action: {
                                    cityName = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 40)
                    .keyboardAvoiding()
                }
                .padding()
                .transition(.opacity)
                .zIndex(1)
                .scaleEffect(globe.textview ? 1 : 0.8)
                .rotationEffect(.degrees(globe.textview ? 0 : 15))
            }
        }
    }
}

