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
        ServerMonitoringEntry(date: Date(), serverStats: ServerStats.getDummy())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = ServerMonitoringEntry(date: Date(), serverStats: ServerStats.getDummy())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ServerMonitoringEntry>) -> Void) {
        fetchUbuntuServerStats { (result) in
            switch result {
            case .success(let success):
                let timeline = Timeline(entries: [success], policy: .after(Date().addingTimeInterval(60 * 10)))
                completion(timeline)
            case .failure(_):
                let timeline = Timeline(entries: [ServerMonitoringEntry.placeholder()], policy: .after(Date().addingTimeInterval(60 * 10)))
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
        ServerMonitoringEntry(date: Date(), serverStats: ServerStats.getDummy())
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
                let current = geo.size.width * (currentUnit / maxUnit)
                Color("LineUsageBackgroundColor")
                    .frame(width: .infinity)
                    .cornerRadius(10)
                Color("LineUsageAccentColor")
                    .frame(width: .infinity)
                    .cornerRadius(10)
                    .mask {
                        HStack(spacing: 0) {
                            Color("LineUsageAccentColor")
                                .frame(width: current)
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
//                HStack(spacing: 0) {
//                    Color("LineUsageAccentColor")
//                        .frame(width: current)
//                        .cornerRadius(10)
//                    Spacer()
//                }
            }
        }
        .frame(height: 15)
    }
}

struct Server_MonitoringEntryView : View {
    var entry: ServerMonitoringProvider.Entry

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Image(systemName: "cpu.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(currentUnit: entry.serverStats.cpu_usage)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.cpu_usage))
                        .font(.custom("", size: 15))
                    Text(" %")
                        .font(.custom("", size: 12))
                }
                .frame(minWidth: 65)
            }
            Spacer()
            HStack {
                Image(systemName: "externaldrive.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(currentUnit: entry.serverStats.disk_usage)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.disk_usage))
                        .font(.custom("", size: 15))
                    Text(" %")
                        .font(.custom("", size: 12))
                }
                .frame(minWidth: 65)
            }
            Spacer()
            HStack {
                Image(systemName: "memorychip.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(currentUnit: entry.serverStats.memory_usage)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.memory_usage))
                        .font(.custom("", size: 15))
                    Text(" %")
                        .font(.custom("", size: 12))
                }
                .frame(minWidth: 65)
            }
            Spacer()
            HStack {
                Image(systemName: "thermometer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 25)
                LineUsageView(maxUnit: 105, currentUnit: entry.serverStats.temperature)
                HStack(spacing: 0) {
                    Text(String(entry.serverStats.temperature) + "°")
                        .font(.custom("", size: 15))
                    Text(" C")
                        .font(.custom("", size: 12))
                }
                .frame(minWidth: 65)
            }
            Spacer()
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
    ServerMonitoringEntry(date: .now, serverStats: ServerStats.getDummy())
}
