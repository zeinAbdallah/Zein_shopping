//
//  APIClientResponse.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 15/08/2022.
//

import Foundation

struct APIClientResponse: Codable {
    let data: [OrderResponse]
    let code: Int
    let message: String
    let paginate: PaginateResponse
}

struct OrderResponse: Codable {
    let total: String
    let created_at: String
    let image: String
    let currency: String
    let id: String
    let address: AddressResponse
    let items: [ItemsResponse]
}

struct AddressResponse: Codable {
    let lat: String
    let lng: String
}

struct ItemsResponse: Codable {
    let id: Int
    let name: String
    let price: String
}

struct PaginateResponse: Codable {
    let total: Int
    let per_page: Int
}

