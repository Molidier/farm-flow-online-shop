//
//  BuyerOrderPageViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 03.12.2024.
//

import UIKit
import SnapKit

class BuyerOrderPageViewController: UIViewController {
	private let productListView = UITableView()
	private let deliveryOptionSegmentedControl = UISegmentedControl(items: ["Pickup", "Delivery"])
	private let totalPriceLabel = UILabel()
	private let placeOrderButton = UIButton()
	private var isDeliverySelected = false
	private let deliveryCost: Double = 1000.0

	private var cartItems: [CartItem] {
		return CartManager.shared.getCartItems()
	}

	private var totalCost: Double {
		let cartTotal = cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
		return isDeliverySelected ? cartTotal + deliveryCost : cartTotal
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	private func setupUI() {
		view.backgroundColor = .white
		navigationItem.title = "Place Order"

		// Product List Table View
		productListView.delegate = self
		productListView.dataSource = self
		productListView.register(CartItemCell.self, forCellReuseIdentifier: "CartItemCell")
		productListView.rowHeight = UITableView.automaticDimension
		productListView.estimatedRowHeight = 100
		view.addSubview(productListView)
		productListView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(300)
		}

		// Delivery Option Segmented Control
		deliveryOptionSegmentedControl.selectedSegmentIndex = 0
		deliveryOptionSegmentedControl.addTarget(self, action: #selector(deliveryOptionChanged), for: .valueChanged)
		view.addSubview(deliveryOptionSegmentedControl)
		deliveryOptionSegmentedControl.snp.makeConstraints { make in
			make.top.equalTo(productListView.snp.bottom).offset(20)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(40)
		}

		// Total Price Label
		totalPriceLabel.font = UIFont.boldSystemFont(ofSize: 20)
		totalPriceLabel.textAlignment = .center
		totalPriceLabel.text = "Total: \(String(format: "%.2f", totalCost)) KZT"
		view.addSubview(totalPriceLabel)
		totalPriceLabel.snp.makeConstraints { make in
			make.top.equalTo(deliveryOptionSegmentedControl.snp.bottom).offset(20)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(30)
		}

		// Place Order Button
		placeOrderButton.setTitle("Place Order", for: .normal)
		placeOrderButton.setTitleColor(.white, for: .normal)
		placeOrderButton.backgroundColor = .systemBlue
		placeOrderButton.layer.cornerRadius = 10
		placeOrderButton.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
		view.addSubview(placeOrderButton)
		placeOrderButton.snp.makeConstraints { make in
			make.top.equalTo(totalPriceLabel.snp.bottom).offset(20)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(50)
		}
	}

	@objc private func deliveryOptionChanged() {
		isDeliverySelected = (deliveryOptionSegmentedControl.selectedSegmentIndex == 1)
		updateTotalPrice()
	}

	private func updateTotalPrice() {
		totalPriceLabel.text = "Total: \(String(format: "%.2f", totalCost)) KZT"
	}

	@objc private func placeOrder() {
		guard !cartItems.isEmpty else {
			let alert = UIAlertController(title: "Cart is Empty", message: "Please add items to your cart before placing an order.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
			return
		}

		let ordersByFarmer = Dictionary(grouping: cartItems, by: { $0.product.id }) // Group items by farmer ID

		for (farmerId, items) in ordersByFarmer {
			let orderDetails = OrderDetails(
				farmerId: farmerId,
				products: items.map { OrderProduct(name: $0.product.name, quantity: $0.quantity, price: $0.product.price) },
				totalPrice: items.reduce(0) { $0 + $1.product.price * Double($1.quantity) },
				deliveryOption: isDeliverySelected ? "Delivery" : "Pickup"
			)
			OrderManager.shared.addOrder(orderDetails)
		}

		for cartItem in cartItems {
			if let index = MockData.shared.sampleProducts.firstIndex(where: { $0.id == cartItem.product.id }) {
				MockData.shared.sampleProducts[index].quantity -= cartItem.quantity
			}
		}

		CartManager.shared.clearCart()

		let ordersVC = OrdersBuyerViewController()
		navigationController?.pushViewController(ordersVC, animated: true)
	}
	
	private func presentBargainAlert(for cartItem: CartItem) {
		let alert = UIAlertController(title: "Bargain Price", message: "Suggest a price for \(cartItem.product.name):", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Enter your price"
			textField.keyboardType = .decimalPad
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
			guard let self = self,
				  let textField = alert.textFields?.first,
				  let suggestedPrice = Double(textField.text ?? ""),
				  suggestedPrice > 0 else { return }

			print("Suggested price for \(cartItem.product.name): \(suggestedPrice) KZT")
			let confirmationAlert = UIAlertController(title: "Bargain Submitted", message: "Your price has been sent to the farmer.", preferredStyle: .alert)
			confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(confirmationAlert, animated: true)
		}))
		present(alert, animated: true)
	}
}

extension BuyerOrderPageViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cartItems.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as? CartItemCell else {
			return UITableViewCell()
		}
		let cartItem = cartItems[indexPath.row]
		cell.configure(with: cartItem, onBargain: { [weak self] in
			self?.showBargainDialog(for: cartItem)
		})
		return cell
	}

	private func showBargainDialog(for cartItem: CartItem) {
		let alert = UIAlertController(
			title: "Suggest a Price",
			message: "Enter your desired price for \(cartItem.product.name):",
			preferredStyle: .alert
		)
		
		alert.addTextField { textField in
			textField.placeholder = "Enter price"
			textField.keyboardType = .decimalPad
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self] _ in
			guard let priceText = alert.textFields?.first?.text,
				  let suggestedPrice = Double(priceText) else { return }
			
			// Create a bargain request
			let bargainRequest = BargainRequest(
				productId: cartItem.product.id,
				suggestedPrice: suggestedPrice, originalPrice: cartItem.product.price
			)
			
			// Add to BargainManager
			BargainManager.shared.addBargainRequest(bargain: bargainRequest)
			
			// Show success message
			self?.showSuccessMessage()
		}))
		
		present(alert, animated: true)
	}

	private func showSuccessMessage() {
		let successAlert = UIAlertController(
			title: "Bargain Sent",
			message: "Your suggested price has been sent to the farmer.",
			preferredStyle: .alert
		)
		successAlert.addAction(UIAlertAction(title: "OK", style: .default))
		present(successAlert, animated: true)
	}
}
