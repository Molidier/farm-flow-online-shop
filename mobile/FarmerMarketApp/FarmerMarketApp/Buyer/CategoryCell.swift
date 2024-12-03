//
//  CategoryCell.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 24.11.2024.
//

import UIKit
import SnapKit

class CategoryCell: UITableViewCell {
	private let stackView = UIStackView()
	private let categoryLabel = UILabel()
	private let arrowButton = UIButton()
	var onArrowTapped: (() -> Void)?
	
	func configure(category: String, items: [Products]) {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		selectionStyle = .none
		contentView.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
		contentView.layer.cornerRadius = 10
		contentView.layer.masksToBounds = true
		
		categoryLabel.text = category
		categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		contentView.addSubview(categoryLabel)
		categoryLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.leading.equalToSuperview().offset(16)
		}
		
		stackView.axis = .horizontal
		stackView.spacing = 10
		stackView.distribution = .fillEqually
		
		for product in items.prefix(3) {
			let imageView = UIImageView()
			imageView.image = UIImage(named: product.imageName)
			imageView.contentMode = .scaleAspectFit
			imageView.layer.cornerRadius = 5
			imageView.layer.masksToBounds = true
			stackView.addArrangedSubview(imageView)
		}
		
		contentView.addSubview(stackView)
		contentView.addSubview(arrowButton)
		
		stackView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.top.equalTo(categoryLabel.snp.bottom).offset(8)
			make.height.equalTo(60)
			make.trailing.lessThanOrEqualTo(arrowButton.snp.leading).offset(-16)
		}
		
		arrowButton.setImage(UIImage(systemName: "arrow.forward"), for: .normal)
		arrowButton.tintColor = .darkGray
		arrowButton.addTarget(self, action: #selector(arrowTapped), for: .touchUpInside)
		
		arrowButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().inset(16)
			make.centerY.equalTo(stackView.snp.centerY)
			make.size.equalTo(30)
		}
	}
	
	@objc private func arrowTapped() {
		onArrowTapped?()
	}
}
