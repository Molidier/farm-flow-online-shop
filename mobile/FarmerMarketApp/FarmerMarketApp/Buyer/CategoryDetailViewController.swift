//
//  CategoryDetailViewController.swift
//  FarmerMarketApp
//

import UIKit
import SnapKit

class CategoryDetailViewController: UIViewController {
	private let searchBar = UISearchBar()
	private let tableView = UITableView()
	private var products: [Product]
	private var filteredProducts: [Product]
	private let category: String
	private let filterButton = UIButton()

	init(category: String, products: [Product]) {
		self.category = category
		self.products = products
		self.filteredProducts = products
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	private func setupUI() {
		view.backgroundColor = .white
		navigationItem.title = category
		navigationController?.navigationBar.prefersLargeTitles = true

		searchBar.placeholder = "Search for products"
		searchBar.delegate = self
		view.addSubview(searchBar)
		searchBar.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(50)
		}

		filterButton.setTitle("Filter", for: .normal)
		filterButton.setTitleColor(.systemBlue, for: .normal)
		filterButton.addTarget(self, action: #selector(openFilterOptions), for: .touchUpInside)
		view.addSubview(filterButton)
		filterButton.snp.makeConstraints { make in
			make.top.equalTo(searchBar.snp.bottom).offset(10)
			make.trailing.equalToSuperview().inset(16)
			make.height.equalTo(30)
			make.width.equalTo(100)
		}

		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ProductCell.self, forCellReuseIdentifier: "ProductCell")
		tableView.rowHeight = 120
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.top.equalTo(filterButton.snp.bottom).offset(10)
			make.leading.trailing.bottom.equalToSuperview()
		}
	}

	@objc private func openFilterOptions() {
		let alert = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Sort by Price: Low to High", style: .default, handler: { _ in
			self.filteredProducts.sort { $0.price < $1.price }
			self.tableView.reloadData()
		}))
		alert.addAction(UIAlertAction(title: "Sort by Price: High to Low", style: .default, handler: { _ in
			self.filteredProducts.sort { $0.price > $1.price }
			self.tableView.reloadData()
		}))
		alert.addAction(UIAlertAction(title: "Filter by Price Range", style: .default, handler: { _ in
			self.showPriceRangeFilter()
		}))
		alert.addAction(UIAlertAction(title: "Clear Filters", style: .destructive, handler: { _ in
			self.filteredProducts = self.products
			self.tableView.reloadData()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	private func showPriceRangeFilter() {
		let alert = UIAlertController(title: "Enter Price Range", message: nil, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Min Price"
			textField.keyboardType = .numberPad
		}
		alert.addTextField { textField in
			textField.placeholder = "Max Price"
			textField.keyboardType = .numberPad
		}
		alert.addAction(UIAlertAction(title: "Apply", style: .default, handler: { _ in
			guard let minText = alert.textFields?[0].text,
				  let maxText = alert.textFields?[1].text,
				  let minPrice = Double(minText),
				  let maxPrice = Double(maxText) else {
				return
			}
			self.filteredProducts = self.products.filter {
				$0.price >= minPrice && $0.price <= maxPrice
			}
			self.tableView.reloadData()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
}

// MARK: - UISearchBarDelegate
extension CategoryDetailViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filteredProducts = products
		} else {
			filteredProducts = products.filter {
				$0.name.lowercased().contains(searchText.lowercased())
			}
		}
		tableView.reloadData()
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredProducts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
			return UITableViewCell()
		}
		let product = filteredProducts[indexPath.row]
		cell.configure(with: product)
		return cell
	}
}
