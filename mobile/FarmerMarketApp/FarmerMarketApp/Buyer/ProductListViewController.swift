////
////  ProductListViewController.swift
////  FarmerMarketApp
////
////  Created by Saltanat on 25.11.2024.
////
//
//import UIKit
//
//class ProductListViewController: UIViewController {
//	private var tableView = UITableView()
//	private var products: [Product] = []
//	private var category: Category
//
//	init(category: Category) {
//		self.category = category
//		super.init(nibName: nil, bundle: nil)
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		title = category.name
//		view.backgroundColor = .white
//		setupTableView()
//		fetchProducts()
//	}
//
//	private func setupTableView() {
//		tableView.delegate = self
//		tableView.dataSource = self
//		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
//		tableView.frame = view.bounds
//		view.addSubview(tableView)
//	}
//
//	private func fetchProducts() {
//		guard let url = URL(string: "https://my-django-app8-109965421953.europe-north1.run.app/products/product/") else { return }
//		
//		URLSession.shared.dataTask(with: url) { data, response, error in
//			guard let data = data, error == nil else { return }
//			do {
//				let allProducts = try JSONDecoder().decode([Product].self, from: data)
//				self.products = allProducts.filter { $0.categoryId == self.category.id }
//				DispatchQueue.main.async {
//					self.tableView.reloadData()
//				}
//			} catch {
//				print("Error decoding products: \(error)")
//			}
//		}.resume()
//	}
//}
//
//extension ProductListViewController: UITableViewDelegate, UITableViewDataSource {
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return products.count
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
//		let product = products[indexPath.row]
//		cell.textLabel?.text = "\(product.name) - $\(product.price)"
//		return cell
//	}
//}
