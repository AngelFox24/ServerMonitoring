//
//  ServersStats.swift
//  ServerMonitoring
//
//  Created by Angel Curi Laurente on 25/05/2024.
//

import Foundation

class ServerStats: Decodable {
    let date: Date
    let cpu_usage: Double
    let disk_usage: Double
    let memory_usage: Double
    let temperature: Double
    
    init(cpu_usage: Double, disk_usage: Double, memory_usage: Double, temperature: Double) {
            self.date = Date()
            self.cpu_usage = cpu_usage
            self.disk_usage = disk_usage
            self.memory_usage = memory_usage
            self.temperature = temperature
        }
    
    static func getDummy() -> ServerStats {
        return ServerStats(cpu_usage: 0.0, disk_usage: 0.0, memory_usage: 0.0, temperature: 0.0)
    }
    private enum CodingKeys: String, CodingKey {
        case cpu_usage
        case disk_usage
        case memory_usage
        case temperature
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = Date()
        self.cpu_usage = try container.decode(Double.self, forKey: .cpu_usage)
        self.disk_usage = try container.decode(Double.self, forKey: .disk_usage)
        self.memory_usage = try container.decode(Double.self, forKey: .memory_usage)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
    }
}
