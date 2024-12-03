//
//  CartBuyerViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 21.11.2024.
//

import UIKit
import SnapKit

class CartBuyerViewController: UIViewController {

	private let tableView = UITableView()
	private let totalPriceContainerView = UIView()
	private let totalPriceLabel = UILabel()
	private let placeOrderButton = UIButton()

	private var cartItems: [CartItem] {
		return CartManager.shared.getCartItems()
	}

	private var totalCost: Double {
		return cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()

		// Listen for cart updates
		NotificationCenter.default.addObserver(self, selector: #selector(cartUpdated), name: NSNotification.Name("CartUpdated"), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData() // Reload cart data when the view appears
		updateTotalPrice() // Update total price
	}

	private func setupUI() {
		view.backgroundColor = .white
		navigationItem.title = "Your Cart"

		// Table View Setup
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(CartItemCell.self, forCellReuseIdentifier: "CartItemCell")
		view.addSubview(tableView)

		// Total Price and Place Order Container
		totalPriceContainerView.backgroundColor = .white
		totalPriceContainerView.layer.shadowColor = UIColor.black.cgColor
		totalPriceContainerView.layer.shadowOpacity = 0.1
		totalPriceContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
		totalPriceContainerView.layer.shadowRadius = 5
		view.addSubview(totalPriceContainerView)

		// Total Price Label
		totalPriceLabel.font = UIFont.boldSystemFont(ofSize: 16)
		totalPriceLabel.text = "Total: \(String(format: "%.2f", totalCost)) KZT"
		totalPriceContainerView.addSubview(totalPriceLabel)

		// Place Order Button
		placeOrderButton.setTitle("Place Order", for: .normal)
		placeOrderButton.setTitleColor(.white, for: .normal)
		placeOrderButton.backgroundColor = .systemBlue
		placeOrderButton.layer.cornerRadius = 10
		placeOrderButton.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
		totalPriceContainerView.addSubview(placeOrderButton)

		// Constraints for Table View
		tableView.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview()
			make.bottom.equalTo(totalPriceContainerView.snp.top) // Bottom aligns with the top of the container
		}

		// Constraints for Total Price Container View
		totalPriceContainerView.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview()
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
			make.height.equalTo(60)
		}

		// Constraints for Total Price Label
		totalPriceLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalToSuperview()
		}

		// Constraints for Place Order Button
		placeOrderButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
			make.height.equalTo(40)
			make.width.equalTo(150)
		}
	}

	@objc private func placeOrder() {
		let orderVC = BuyerOrderPageViewController()
		navigationController?.pushViewController(orderVC, animated: true)
	}

	private func updateTotalPrice() {
		totalPriceLabel.text = "Total: \(String(format: "%.2f", totalCost)) KZT"
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

	@objc private func cartUpdated() {
		tableView.reloadData()
		updateTotalPrice()
	}
}

// MARK: - Table View Methods
extension CartBuyerViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cartItems.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as? CartItemCell else {
			return UITableViewCell()
		}

		let cartItem = cartItems[indexPath.row]

		// Provide the `onBargain` closure
		cell.configure(with: cartItem, onBargain: { [weak self] in
			self?.showBargainDialog(for: cartItem)
		})

		return cell
	}
}
