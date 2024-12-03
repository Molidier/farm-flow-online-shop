//
//  OrdersBuyerViewController.swift
//  FarmerMarketApp
//

import UIKit
import SnapKit

class OrdersBuyerViewController: UIViewController {
	private let tableView = UITableView()
	
	private var orders: [OrderDetails] {
		return OrderManager.shared.buyerOrders
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData() // Reload the orders when the view appears
	}
	
	private func setupUI() {
		view.backgroundColor = .white
		navigationItem.title = "Order History"
		
		// Table View Setup
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 150
		view.addSubview(tableView)
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
}

extension OrdersBuyerViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return orders.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return orders[section].products.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let order = orders[section]
		return "Order \(section + 1): \(order.deliveryOption) - \(String(format: "%.2f", order.totalPrice)) KZT"
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
		let product = orders[indexPath.section].products[indexPath.row]
		cell.textLabel?.numberOfLines = 0
		cell.textLabel?.text = """
		Product: \(product.name)
		Quantity: \(product.quantity)
		Price per Unit: \(String(format: "%.2f", product.price)) KZT
		Total: \(String(format: "%.2f", product.price * Double(product.quantity))) KZT
		"""
		return cell
	}
}
