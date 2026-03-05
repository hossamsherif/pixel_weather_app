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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.location)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(colorScheme == .dark ? .gray : .gray.opacity(0.7))
                .lineLimit(1)

            Text(entry.temperature)
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(colorScheme == .dark ? .white : .onSurface)

            Spacer()

            Text(entry.description)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(colorScheme == .dark ?
                    Color.blue.opacity(0.8) :
                    Color.blue.opacity(0.6))
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
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill(.secondary), for: .widget)
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
