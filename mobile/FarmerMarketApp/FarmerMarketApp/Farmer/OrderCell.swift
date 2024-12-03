//
//  OrderCell.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 02.12.2024.
//

import UIKit

class OrderCell: UITableViewCell {
	private let productNameLabel = UILabel()
	private let quantityLabel = UILabel()
	private let priceLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		contentView.addSubview(productNameLabel)
		contentView.addSubview(quantityLabel)
		contentView.addSubview(priceLabel)

		productNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		quantityLabel.font = UIFont.systemFont(ofSize: 14)
		priceLabel.font = UIFont.systemFont(ofSize: 14)

		productNameLabel.snp.makeConstraints { make in
			make.top.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
		}

		quantityLabel.snp.makeConstraints { make in
			make.top.equalTo(productNameLabel.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
		}

		priceLabel.snp.makeConstraints { make in
			make.top.equalTo(quantityLabel.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
			make.bottom.equalToSuperview().offset(-16)
		}
	}

	func configure(with order: OrderDetails) {
		productNameLabel.text = "Order ID: \(order.farmerId)"
		quantityLabel.text = "Total Items: \(order.products.count)"
		priceLabel.text = "Total Price: \(String(format: "%.2f", order.totalPrice)) KZT"
	}
}

