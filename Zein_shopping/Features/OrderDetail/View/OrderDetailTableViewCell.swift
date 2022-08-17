//
//  OrderDetailTableViewCell.swift
//  Zein_shopping
//
//  Created by Zein Abdalla on 16/08/2022.
//

import Foundation
import UIKit
import SwiftUI

class OrderDetailTableViewCell: UITableViewCell {

    private lazy var view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10.0
        view.layer.masksToBounds = false
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    private let idItem: UILabel = {
        let idItem = UILabel()
        idItem.translatesAutoresizingMaskIntoConstraints = false
        return idItem
    }()

    private let nameItem: UILabel = {
        let nameItem = UILabel()
        nameItem.numberOfLines = 0
        nameItem.translatesAutoresizingMaskIntoConstraints = false
        return nameItem
    }()

    private let priceItem: UILabel = {
        let priceItem = UILabel()
        priceItem.translatesAutoresizingMaskIntoConstraints = false
        return priceItem
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {

        defer {
            setupContraints()
        }
        contentView.addSubview(view)
        view.addSubview(idItem)
        view.addSubview(nameItem)
        view.addSubview(priceItem)

    }

    private func setupContraints() {

        NSLayoutConstraint.activate([

            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            idItem.topAnchor.constraint(equalTo: view.topAnchor,constant: 5),
            idItem.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 5),
            idItem.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            nameItem.topAnchor.constraint(equalTo: idItem.bottomAnchor,constant: 5),
            nameItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            nameItem.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            priceItem.topAnchor.constraint(equalTo: nameItem.bottomAnchor,constant: 5),
            priceItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            priceItem.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    public func populate(model: ItemsResponse) {

       // let id = "\(model.id)"
        self.idItem.text = "Id: \(model.id)"
        self.nameItem.text = "Name: " + model.name
        self.priceItem.text = "Price:" + model.price

    }
}
