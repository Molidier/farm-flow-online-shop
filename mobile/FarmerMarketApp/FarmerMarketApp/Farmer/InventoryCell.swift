//
//  InventoryCell.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 25.11.2024.
//
// MARK: - InventoryCell
import UIKit
import SnapKit

class InventoryCell: UITableViewCell {
	
	private let productImageView = UIImageView()
	private let nameLabel = UILabel()
	private let categoryLabel = UILabel()
	private let priceLabel = UILabel()
	private let quantityLabel = UILabel()
	private let descriptionLabel = UILabel()
	private let outOfStockLabel = UILabel()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		// Product Image
		productImageView.contentMode = .scaleAspectFit
		productImageView.layer.cornerRadius = 8
		productImageView.clipsToBounds = true
		contentView.addSubview(productImageView)
		
		// Name Label
		nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		nameLabel.textColor = .black
		contentView.addSubview(nameLabel)
		
		// Category Label
		categoryLabel.font = UIFont.systemFont(ofSize: 12)
		categoryLabel.textColor = .darkGray
		contentView.addSubview(categoryLabel)
		
		// Price Label
		priceLabel.font = UIFont.systemFont(ofSize: 14)
		priceLabel.textColor = .systemGreen
		contentView.addSubview(priceLabel)
		
		// Quantity Label
		quantityLabel.font = UIFont.systemFont(ofSize: 14)
		quantityLabel.textColor = .darkGray
		contentView.addSubview(quantityLabel)
		
		// Description Label
		descriptionLabel.font = UIFont.systemFont(ofSize: 12)
		descriptionLabel.textColor = .darkGray
		contentView.addSubview(descriptionLabel)
		
		// Out of Stock Label
		outOfStockLabel.text = "OUT OF STOCK"
		outOfStockLabel.font = UIFont.boldSystemFont(ofSize: 12)
		outOfStockLabel.textColor = .white
		outOfStockLabel.backgroundColor = .systemRed
		outOfStockLabel.textAlignment = .center
		outOfStockLabel.isHidden = true
		contentView.addSubview(outOfStockLabel)
		
		// Constraints
		productImageView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(60)
		}
		
		nameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.leading.equalTo(productImageView.snp.trailing).offset(12)
		}
		
		categoryLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel)
		}
		
		priceLabel.snp.makeConstraints { make in
			make.top.equalTo(categoryLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel)
		}
		
		quantityLabel.snp.makeConstraints { make in
			make.top.equalTo(priceLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel)
		}
		
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(quantityLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel)
			make.trailing.equalToSuperview().inset(16)
		}
		
		outOfStockLabel.snp.makeConstraints { make in
			make.trailing.equalToSuperview().inset(16)
			make.top.equalToSuperview().offset(8)
			make.width.equalTo(100)
			make.height.equalTo(20)
		}
	}
	
	func configure(with product: Products) {
		productImageView.image = UIImage(named: product.imageName)
		nameLabel.text = "Product: \(product.name)"
		categoryLabel.text = "Category: \(product.category)"
		priceLabel.text = "Price: \(String(format: "%.2f", product.price)) KZT"
		quantityLabel.text = "Quantity: \(product.quantity)"
		descriptionLabel.text = "Description: \(product.description)"
		
		// Show "OUT OF STOCK" label if quantity is 0
		outOfStockLabel.isHidden = product.quantity > 0
	}
}
