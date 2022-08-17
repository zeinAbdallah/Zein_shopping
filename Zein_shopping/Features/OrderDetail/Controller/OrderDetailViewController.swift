//
//  OrderDetailViewController.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 15/08/2022.
//

import Foundation
import UIKit
import GoogleMaps
import AVFoundation
import UserNotifications

class OrderDetailViewController: UIViewController {

    private let order: OrderResponse
    private var isFavorite: Bool?
    private let storgeProvider = StorageProvider.shared

    var player: AVAudioPlayer?

    let mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(OrderDetailTableViewCell.self, forCellReuseIdentifier:OrderDetailTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView

    }()

    private let totalLabel: UILabel = {
        let totalLabel = UILabel()
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        return totalLabel
    }()

    private lazy var favoriteButton: UIButton = {
        let favoriteButton = UIButton()
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .light)
        let heartImage = UIImage(systemName: "heart", withConfiguration: largeConfig)
        favoriteButton.setImage(heartImage, for: .normal)
        favoriteButton.tintColor = .red
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return favoriteButton
    }()

    init(order: OrderResponse) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoriteButton.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        favoriteButton.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Order: \(order.id)"
        let camera = GMSCameraPosition.camera(withLatitude: Double(order.address.lat) ?? 0.0, longitude: Double(order.address.lng) ?? 0.0, zoom: 2.0)
        mapView.camera = camera
        showMarker(position: camera.target)

        totalLabel.text = "Total: " + order.total + " " + order.currency

        let isFavorite = storgeProvider.isOrderFavorite(id: order.id)
        self.isFavorite = isFavorite
        if isFavorite == true {
            setHeartFillButtonImage()

        } else {
            setHeartButtonImage()
        }

        UNUserNotificationCenter.current().delegate = self

        setupLayout()
    }
    
    private func setupLayout () {

        defer {
            setupConstraints()
        }

        view.addSubview(mapView)
        view.addSubview(totalLabel)
        view.addSubview(tableView)
        navigationController?.navigationBar.addSubview(favoriteButton)


    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            favoriteButton.topAnchor.constraint(equalTo: (navigationController?.navigationBar.topAnchor)!),
            favoriteButton.bottomAnchor.constraint(equalTo: (navigationController?.navigationBar.bottomAnchor)!),
            favoriteButton.trailingAnchor.constraint(equalTo: (navigationController?.navigationBar.trailingAnchor)!, constant: -5),


            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -5),
            mapView.heightAnchor.constraint(equalToConstant: 250),

            totalLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            totalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),

            tableView.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
    private func showMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = position
        marker.map = mapView
    }

    @objc func favoriteButtonTapped() {
        didTappedFavoriteButton()
    }

    func didTappedFavoriteButton() {
        let currentValue = self.isFavorite
        storgeProvider.updateFavorite(order: order, favorite: !currentValue!)

        let newValue = storgeProvider.isOrderFavorite(id: order.id)
        self.isFavorite = newValue

        updateFavoriteButton(isFavorite: newValue)
    }

    func updateFavoriteButton(isFavorite: Bool) {
        if isFavorite {
            setHeartFillButtonImage()
            setupLocalNotification()
        } else {
            setHeartButtonImage()
            playSound()
        }
    }

    private func setHeartFillButtonImage() {
              let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .light)
              let largeBoldDoc = UIImage(systemName: "heart.fill", withConfiguration: largeConfig)
              favoriteButton.setImage(largeBoldDoc, for: .normal)
              favoriteButton.tintColor = .red
          }

          private func setHeartButtonImage() {
              let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .light)
              let largeBoldDoc = UIImage(systemName: "heart", withConfiguration: largeConfig)
              favoriteButton.setImage(largeBoldDoc, for: .normal)
              favoriteButton.tintColor = .red
          }

    private func setupLocalNotification() {
            UNUserNotificationCenter.current().getNotificationSettings { notificationSetting in
                switch notificationSetting.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization { success in
                        guard success else { return }
                        self.scheduleLocalNotification()
                    }
                case.authorized:
                    self.scheduleLocalNotification()
                case.denied:
                    print("Application Not Allowed to Display Notifications")
                default:
                    break
                }
            }
        }

        private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                if let error = error {
                    print("Request Authorization Failed (\(error), \(error.localizedDescription))")
                }
                completionHandler(success)
            }
        }

    private func scheduleLocalNotification() {
            let notificationContent = UNMutableNotificationContent()

            notificationContent.title = "Added to favorite"
            notificationContent.body = "You have been added this order: \(order.id) to your favorite list!"

        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

            let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)

            UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                if let error = error {
                    print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                }
            }
        }

    func playSound() {
            guard let url = Bundle.main.url(forResource: "whoosh1", withExtension: "wav") else { return }

            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

                guard let player = player else { return }

                player.play()

            } catch let error {
                print(error.localizedDescription)
            }
        }

}

extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:OrderDetailTableViewCell.identifier  , for: indexPath) as! OrderDetailTableViewCell
        cell.populate(model: order.items[indexPath.row] )
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}

extension OrderDetailViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
