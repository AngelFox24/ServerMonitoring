//
//  Server_Monitoring.swift
//  Server Monitoring
//
//  Created by Angel Curi Laurente on 25/05/2024.
//

import WidgetKit
import SwiftUI
import Alamofire

struct ServerMonitoringProvider: TimelineProvider {
    func placeholder(in context: Context) -> ServerMonitoringEntry {
        ServerMonitoringEntry.placeholder()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = ServerMonitoringEntry.placeholder()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ServerMonitoringEntry>) -> Void) {
        fetchUbuntuServerStats { (result) in
            switch result {
            case .success(let success):
                let timeline = Timeline(entries: [success], policy: .after(Date().addingTimeInterval(60 * 5)))
                completion(timeline)
            case .failure(_):
                let timeline = Timeline(entries: [ServerMonitoringEntry.placeholder()], policy: .after(Date().addingTimeInterval(60 * 5)))
                completion(timeline)
            }
        }
    }

    private func fetchUbuntuServerStats(completion: @escaping (Result<ServerMonitoringEntry, Error>) -> ()) {
        fetchServerStats { (result) in
            switch result {
            case .success(let serverStats):
                let entry = ServerMonitoringEntry(date: Date(), serverStats: serverStats)
                completion(.success(entry))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}

struct ServerMonitoringEntry: TimelineEntry {
    let date: Date
    let serverStats: ServerStats
    var isPlaceholder = false
    static func placeholder() -> ServerMonitoringEntry {
        ServerMonitoringEntry(date: Date(), serverStats: ServerStats.getDummy(), isPlaceholder: true)
    }
}
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
struct LineUsageView: View {
    let maxUnit: Double
    let currentUnit: Double
    init(maxUnit: Double = 100, currentUnit: Double) {
        self.maxUnit = maxUnit
        self.currentUnit = currentUnit
    }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                let currentMax = geo.size.width
                let current: Double = currentMax * (currentUnit / maxUnit)
                //                let _ = print("Max: \(currentMax) & Current: \(current.rounded(toPlaces: 2))")
                Color("LineUsageBackgroundColor")
                    .cornerRadius(10)
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green, Color.yellow, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .mask {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(width: current.rounded(toPlaces: 2))
                            .cornerRadius(10)
                        Spacer(minLength: 0)
                    }
                    .cornerRadius(10)
                }
            }
        }
        .frame(height: 15)
    }
}

struct Server_MonitoringEntryView : View {
    var entry: ServerMonitoringProvider.Entry

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack {
                Spacer()
                if entry.isPlaceholder {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
                Text("Next Review: \(entry.date.addingTimeInterval(60 * 5).formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
            }
            Spacer(minLength: 0)
            HStack {
                Image(systemName: "thermometer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(maxUnit: 105, currentUnit: entry.serverStats.temperature)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.temperature) + "°")
                        .font(.subheadline)
//                        .font(.custom("", size: 15))
                    Text(" C")
                        .font(.caption2)
                }
                .frame(minWidth: 65)
            }
            Spacer(minLength: 0)
            HStack {
                Image(systemName: "cpu.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(currentUnit: entry.serverStats.cpu_usage)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.cpu_usage))
                        .font(.subheadline)
                    Text(" %")
                        .font(.caption2)
                }
                .frame(minWidth: 65)
            }
            Spacer(minLength: 0)
            HStack {
                Image(systemName: "memorychip.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(currentUnit: entry.serverStats.memory_usage)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.memory_usage))
                        .font(.subheadline)
                    Text(" %")
                        .font(.caption2)
                }
                .frame(minWidth: 65)
            }
            Spacer(minLength: 0)
            HStack {
                Image(systemName: "externaldrive.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(currentUnit: entry.serverStats.disk_usage)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.disk_usage))
                        .font(.subheadline)
                    Text(" %")
                        .font(.caption2)
                }
                .frame(minWidth: 65)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Color.white)
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}

struct Server_Monitoring: Widget {
    let kind: String = "Server Monitoring"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ServerMonitoringProvider()) { entry in
            if #available(iOS 17.0, *) {
                Server_MonitoringEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Server_MonitoringEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemMedium) {
    Server_Monitoring()
} timeline: {
    ServerMonitoringEntry(date: .now, serverStats: ServerStats.getDummy(), isPlaceholder: true)
}
