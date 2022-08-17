//
//  StorageProvider.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 16/08/2022.
//

import Foundation
import CoreData
import UIKit
import SwiftUI

class StorageProvider {

    static let shared: StorageProvider = .init()

    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = .init(name: "OrderFaves")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core data store failed to load with error: \(error)")
            }
        }
    }

    func getAllOrdersItem() throws -> [OrdersDataBase] {
        let fetchRequest: NSFetchRequest<OrdersDataBase> = OrdersDataBase.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            rollBack()
            print("error fetching data.")
            throw error
        }
    }

    func updateOrdersFromDataBase(order: [OrderResponse]) {
        let newEntity = OrdersDataBase(context: persistentContainer.viewContext)

        newEntity.orderId = order.first?.id
        newEntity.imageUrl = order.first?.image
        newEntity.createdAt = order.first?.created_at
        newEntity.total = (order.first?.total ?? "") + " " + (order.first?.currency ?? "")

        do {
            try saveData()
        } catch {
            print(error)
            rollBack()
        }

    }

    func getAllItems() throws -> [OrderFaves] {
        let fetchRequest: NSFetchRequest<OrderFaves> = OrderFaves.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            rollBack()
            print("error fetching data.")
            throw error
        }
    }

    func isOrderFavorite(id: String) -> Bool {
        guard let entity = getFavoritesForOrderId(id: id)
        else { return false }
        return entity.isFavorite
    }

    func getFavoritesForOrderId(id: String) -> OrderFaves? {
        let fetchRequest: NSFetchRequest<OrderFaves> = OrderFaves.fetchRequest()

        let idPredicate: NSPredicate = NSPredicate(format: "id=%@", id)
        fetchRequest.predicate = idPredicate
        return try? persistentContainer.viewContext.fetch(fetchRequest).first
    }

    func updateFavorite(order: OrderResponse, favorite: Bool) {
        if let existingEntity = getFavoritesForOrderId(id: order.id) {
            existingEntity.isFavorite = favorite
            removeFromCoreData(id: order.id)
        } else {
            let newEntity = OrderFaves(context: persistentContainer.viewContext)
            newEntity.id = order.id
            newEntity.imageUrl = order.image
            newEntity.total = order.total + " " + order.currency
            newEntity.isFavorite = favorite

        }

        do {
            try saveData()
        } catch {
            print(error)
            rollBack()
        }
    }

}
extension StorageProvider {
    private func rollBack() {
        DispatchQueue.main.async {
            self.persistentContainer.viewContext.rollback()
        }
    }

    func saveData() throws {
        try self.persistentContainer.viewContext.save()
    }

    func removeFromCoreData(id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedcontext = appDelegate.persistentcontainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "OrderFaves")
        let idPredicate: NSPredicate = NSPredicate(format: "id=%@", id)
        fetchRequest.predicate = idPredicate
        let deleterequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedcontext.execute(deleterequest)
        } catch {
            print(error)
        }
    }
}
