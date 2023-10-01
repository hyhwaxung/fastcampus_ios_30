//
//  ViewController.swift
//  Weather
//
//  Created by 정현화 on 2023/09/05.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func tapFetchWeatherbutton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func getCurrentWeather(cityName: String){
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=e638d40a0940c9a0b62393498047df4f") else { return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { /*completion handler*/ data, response, error in
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            let weatherIntormation = try? decoder.decode(WeatherInformation.self, from: data)
                debugPrint(weatherIntormation)
        }.resume()
    }
}

