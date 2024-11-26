//
//  InventoryCell.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 25.11.2024.
//

import UIKit

class InventoryCell: UITableViewCell {
	
	private let productImageView = UIImageView()
	private let productDetailsLabel = UILabel()
	private let outOfStockLabel = UILabel()
	private let editButton = UIButton()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		
		contentView.layer.cornerRadius = 10
		contentView.layer.masksToBounds = true
		
		productImageView.contentMode = .scaleAspectFit
		productImageView.layer.cornerRadius = 8
		productImageView.layer.masksToBounds = true
		contentView.addSubview(productImageView)
		productImageView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.leading.equalToSuperview().offset(10)
			make.width.height.equalTo(80)
		}
		
		outOfStockLabel.text = "OUT OF STOCK"
		outOfStockLabel.font = UIFont.boldSystemFont(ofSize: 16)
		outOfStockLabel.textColor = .white
		outOfStockLabel.backgroundColor = .red
		outOfStockLabel.textAlignment = .center
		outOfStockLabel.layer.cornerRadius = 5
		outOfStockLabel.layer.masksToBounds = true
		contentView.addSubview(outOfStockLabel)
		outOfStockLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.width.equalTo(120)
			make.height.equalTo(30)
		}
		
		productDetailsLabel.numberOfLines = 0
		productDetailsLabel.font = UIFont.systemFont(ofSize: 14)
		productDetailsLabel.textColor = .black
		contentView.addSubview(productDetailsLabel)
		productDetailsLabel.snp.makeConstraints { make in
			make.top.equalTo(productImageView.snp.top)
			make.leading.equalTo(productImageView.snp.trailing).offset(10)
			make.trailing.equalToSuperview().inset(10)
			make.bottom.lessThanOrEqualToSuperview().inset(10)
		}
		
		editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
		editButton.tintColor = .black
		contentView.addSubview(editButton)
		editButton.snp.makeConstraints { make in
			make.top.equalTo(outOfStockLabel.snp.bottom).offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.width.height.equalTo(30)
		}
	}
	
	func configure(with product: Product) {
		productImageView.image = UIImage(named: product.imageName)
		
		productDetailsLabel.text = """
			Product: \(product.name)
			Category: \(product.category)
			Price: \(String(format: "%.2f", product.price))KZT
			Quantity: \(product.quantity)
			Description: \(product.description)
		"""
		
		outOfStockLabel.isHidden = product.quantity > 0
		
		if product.quantity > 0 {
					contentView.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0) // Green
				} else {
					contentView.backgroundColor = UIColor(red: 255/255, green: 235/255, blue: 235/255, alpha: 1) // Red
				}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
		outOfStockLabel.isHidden = true
	}
}
