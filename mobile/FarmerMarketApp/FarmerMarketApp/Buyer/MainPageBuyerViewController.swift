//
//  MainPageBuyerViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 11.11.2024.
//

import UIKit
import SnapKit

class MainPageBuyerViewController: UIViewController {
	

	private let tableView = UITableView()
	private let categories: [String: [Product]] = [
		"Fruits": [
			Product(name: "Apple", price: 700, quantity: 10, category: "Fruits", description: "Fresh and juicy apples.", imageName: "apple"),
			Product(name: "Banana", price: 1000, quantity: 20, category: "Fruits", description: "Sweet and ripe bananas.", imageName: "banana"),
			Product(name: "Orange", price: 2000, quantity: 20, category: "Fruits", description: "Citrusy and refreshing oranges.", imageName: "orange")
		],
		"Vegetables": [
			Product(name: "Potato", price: 300, quantity: 20, category: "Vegetables", description: "Fresh potatoes, perfect for cooking.", imageName: "potato"),
			Product(name: "Tomato", price: 600, quantity: 20, category: "Vegetables", description: "Red and ripe tomatoes.", imageName: "tomato"),
			Product(name: "Carrot", price: 500, quantity: 30, category: "Vegetables", description: "Crunchy and sweet carrots.", imageName: "carrot")
		],
		"Meat": [
			Product(name: "Chicken", price: 2000, quantity: 40, category: "Meat", description: "Fresh and high-quality chicken meat.", imageName: "chicken"),
			Product(name: "Beef", price: 5000, quantity: 50, category: "Meat", description: "Premium-grade beef.", imageName: "beef"),
			Product(name: "Pork", price: 4000, quantity: 50, category: "Meat", description: "Tender and delicious pork meat.", imageName: "pork")
		]
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	private func setupUI() {
		view.backgroundColor = .white
		
		navigationItem.title = "Explore"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
		tableView.separatorStyle = .none
		view.addSubview(tableView)
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainPageBuyerViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return categories.keys.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Array(categories.keys)[section]
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
			return UITableViewCell()
		}

		let category = Array(categories.keys)[indexPath.section]
		if let products = categories[category] {
			cell.configure(category: category, items: products)
			
			cell.onArrowTapped = { [weak self] in
				guard let self = self else { return }
				let detailVC = CategoryDetailViewController(category: category, products: products)
				self.navigationController?.pushViewController(detailVC, animated: true)
			}
		}
		return cell
	}
}


	
