import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let location: String
    let temperature: String
    let condition: String
    let description: String
}

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), location: "Location", temperature: "--°", condition: "unknown", description: "Loading...")
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(date: Date(), location: "Cairo", temperature: "25°", condition: "clear", description: "Clear Sky")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        // Must match the group ID in WidgetService.dart
        let prefs = UserDefaults(suiteName: "group.com.pixelweather.app")
        
        let entry = WeatherEntry(
            date: Date(),
            location: prefs?.string(forKey: "location_name") ?? "Unknown",
            temperature: prefs?.string(forKey: "temperature") ?? "--°",
            condition: prefs?.string(forKey: "condition_type") ?? "unknown",
            description: prefs?.string(forKey: "condition_description") ?? ""
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct WeatherWidgetEntryView : View {
    var entry: WeatherProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.location)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            Text(entry.temperature)
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(entry.description)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.blue.opacity(0.8))
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetEntryView(entry: entry)
                    .containerBackground(Color(red: 26/255, green: 28/255, blue: 30/255), for: .widget)
            } else {
                WeatherWidgetEntryView(entry: entry)
                    .background(Color(red: 26/255, green: 28/255, blue: 30/255))
            }
        }
        .configurationDisplayName("Pixel Weather")
        .description("Quick view of the current weather.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: .now, location: "Cairo", temperature: "25°", condition: "clear", description: "Clear Sky")
}
