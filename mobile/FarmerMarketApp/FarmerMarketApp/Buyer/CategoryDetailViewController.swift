import UIKit
import SnapKit

class CategoryDetailViewController: UIViewController, UISearchBarDelegate {
	private let searchBar = UISearchBar()
	private let tableView = UITableView()
	private let filterButton = UIButton(type: .system)
	private var products: [Products]
	private var filteredProducts: [Products]
	private let category: String

	init(category: String, products: [Products]) {
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

		// Setup Search Bar
		searchBar.placeholder = "Search for products"
		searchBar.delegate = self
		view.addSubview(searchBar)
		searchBar.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(50)
		}

		// Setup Filter Button
		filterButton.setTitle("Filter", for: .normal)
		filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
		view.addSubview(filterButton)
		filterButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().inset(16)
			make.centerY.equalTo(searchBar)
		}

		// Setup Table View
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ProductCell.self, forCellReuseIdentifier: "ProductCell")
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 140
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchBar.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
		}
	}

	// MARK: - Filter Options
	@objc private func showFilterOptions() {
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
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}

	private func showPriceRangeFilter() {
		let alert = UIAlertController(title: "Filter by Price Range", message: nil, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Minimum Price"
			textField.keyboardType = .numberPad
		}
		alert.addTextField { textField in
			textField.placeholder = "Maximum Price"
			textField.keyboardType = .numberPad
		}
		alert.addAction(UIAlertAction(title: "Apply", style: .default, handler: { _ in
			if let minPrice = Double(alert.textFields?[0].text ?? ""),
			   let maxPrice = Double(alert.textFields?[1].text ?? "") {
				self.filteredProducts = self.products.filter { $0.price >= minPrice && $0.price <= maxPrice }
				self.tableView.reloadData()
			}
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}
}

// MARK: - Search Bar Delegate
extension CategoryDetailViewController {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filteredProducts = products
		} else {
			filteredProducts = products.filter { $0.name.lowercased().contains(searchText.lowercased()) }
		}
		tableView.reloadData()
	}
}

// MARK: - Table View Delegate & Data Source
extension CategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredProducts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
			return UITableViewCell()
		}
		let product = filteredProducts[indexPath.row]
		cell.configure(with: product) { [weak self] selectedQuantity in
			guard let self = self else { return }
			CartManager.shared.addToCart(product: product, quantity: selectedQuantity)
			let alert = UIAlertController(title: "Added to Cart", message: "\(product.name) x\(selectedQuantity) has been added to your cart.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(alert, animated: true)
		}
		return cell
	}
}
