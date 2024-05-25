//
//  GetServerStatsProvider.swift
//  ServerMonitoring
//
//  Created by Angel Curi Laurente on 25/05/2024.
//

import Foundation
import Alamofire

func fetchServerStats(completion: @escaping (Result<ServerStats, Error>) -> Void) {
    let url = "http://192.168.2.13:5000/status"
    
    AF.request(url).responseDecodable(of: ServerStats.self) { response in
        switch response.result {
        case .success(let serverStats):
            print("Temperatura: \(serverStats.temperature)")
            completion(.success(serverStats))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
