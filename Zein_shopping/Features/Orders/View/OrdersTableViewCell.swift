//
//  OrdersTableViewCell.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 15/08/2022.
//

import Foundation
import UIKit
import Kingfisher

class OrdersTableViewCell: UITableViewCell {


    private let orderImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "person")
        image.layer.borderWidth = 2
        image.layer.backgroundColor = UIColor.black.cgColor
        return image
    }()

    lazy var favoriteStatusImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "12033"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "3,000,000 LBP"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2022-03-25T21:14:20.572Z"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout () {
        defer {
            setupConstraints()
        }
        contentView.addSubview(orderImage)
        contentView.addSubview(favoriteStatusImage)
        contentView.addSubview(idLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(dateLabel)
    }

    private func setupConstraints () {

        NSLayoutConstraint.activate([
            orderImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            orderImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            orderImage.heightAnchor.constraint(equalToConstant: 110),
            orderImage.widthAnchor.constraint(equalTo: orderImage.heightAnchor),

            idLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            idLabel.leadingAnchor.constraint(equalTo: orderImage.trailingAnchor, constant: 5),

            priceLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            dateLabel.bottomAnchor.constraint(equalTo: orderImage.bottomAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            favoriteStatusImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -4),
            favoriteStatusImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            favoriteStatusImage.heightAnchor.constraint(equalToConstant: 30),
            favoriteStatusImage.widthAnchor.constraint(equalToConstant: 30),
        ])
    }

    public func populate(model: OrderResponse) {
        downloadImage(model.image)
        self.idLabel.text = "Order id: " + model.id
        self.priceLabel.text = "Total: " + model.total + " " + model.currency
        dateLabel.text = dateFormatter(date: model.created_at)

    }

    public func populateFromDataBase(model: OrdersDataBase) {
        if let id = model.orderId, let total = model.total, let imageurl = model.imageUrl, let createdAt = model.createdAt {
            idLabel.text = "Order id: " + id
            priceLabel.text = "Total: " + total
            dateLabel.text = dateFormatter(date: createdAt)
            downloadImage(imageurl)

        }
    }

    private func downloadImage(_ url: String) {

        let placeholderImage = UIImage(systemName: "person")

        if let url = URL(string: url) {
            self.orderImage.kf.setImage(with: url, placeholder: placeholderImage) { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case.success(let image):
                        self.orderImage.image = image.image
                    case.failure(let error):
                        print(error)
                        self.orderImage.image = placeholderImage
                    }
                }
            }
        }
    }

    private func dateFormatter(date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        let date1 =  formatter.date(from: date)
        formatter.dateFormat = "MM-dd-yyyy"

        let resultTime = formatter.string(from: date1!)
        return resultTime
    }
}

