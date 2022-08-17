//
//  ViewController.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 15/08/2022.
//

import UIKit
import SystemConfiguration

class OrdersViewController: UIViewController {

    private var orders: [OrderResponse] = []
    private var ordersDataBase: [OrdersDataBase] = []
    private var isFavorite: Bool?
    private let storgeProvider = StorageProvider.shared

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(OrdersTableViewCell.self, forCellReuseIdentifier:OrdersTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView

    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    fileprivate func fetchData() {
        APIClient.shared.getOrders { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let model):
                self.orders = model.data
                self.storgeProvider.updateOrdersFromDataBase(order: model.data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case.failure(let error):
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My orders"
        view.backgroundColor = .red
        
        fetchData()

        setupLayout()

        do {
            ordersDataBase = try storgeProvider.getAllOrdersItem()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func setupLayout() {

        defer {
            setupConstraints()
        }

        view.addSubview(tableView)

    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

        ])

    }
}


extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isInternetAvailable() {
            return orders.count
        } else {
            return ordersDataBase.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:OrdersTableViewCell.identifier  , for: indexPath) as! OrdersTableViewCell
            
            if isInternetAvailable() {
                cell.populate(model: orders[indexPath.row])
                let newValue = storgeProvider.isOrderFavorite(id: orders[indexPath.row].id)
                isFavorite = newValue
            } else {
                cell.populateFromDataBase(model: ordersDataBase[indexPath.row])
            }



        if let isFavorite = isFavorite {
            if isFavorite {
                cell.favoriteStatusImage.image = UIImage(systemName: "heart.fill")
            } else {
                cell.favoriteStatusImage.image = UIImage(systemName: "heart")
            }
        }

        cell.selectionStyle = .none



        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            navigationController?.pushViewController(OrderDetailViewController(order: orders[indexPath.row] ), animated: true)

    }


}
// MARK: - Network check
extension OrdersViewController {
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
