//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Hossam Sherif on 3/3/26.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        WeatherWidgetControl()
    }
}
