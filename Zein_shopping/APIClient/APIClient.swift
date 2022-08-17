//
//  APIClient.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 15/08/2022.
//

enum HTTPMethod: String {
    case GET
    case POST
}

import Foundation
import UIKit

class APIClient {

    static let shared = APIClient()

    public func getOrders(completion: @escaping (Result<APIClientResponse, Error>) -> Void) {

        let urlRequest = URL(string: Constants.baseUrl + Constants.endPoint)

        createRequest(with: urlRequest, type: .GET) { request in

            let task = URLSession.shared.dataTask(with: request) { data, _, error in

                guard let data = data, error == nil else {
                    completion(.failure(error!))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(APIClientResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {

        guard let url = url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.timeoutInterval = 30
        completion(request)

    }
}
