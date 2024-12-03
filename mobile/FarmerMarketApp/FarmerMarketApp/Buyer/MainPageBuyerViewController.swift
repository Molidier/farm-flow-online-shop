import UIKit
import SnapKit

class MainPageBuyerViewController: UIViewController {
	private let tableView = UITableView()
	var buyer: UserWrapper?

	private var categories: [(String, [Products])] {
		let products = MockData.shared.sampleProducts.filter { $0.quantity > 0 }
		let groupedCategories = Dictionary(grouping: products, by: { $0.category })
		return groupedCategories.sorted { $0.key < $1.key }
	}
	
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainPageBuyerViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return categories.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	// Add empty headers for spacing
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return " "
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 20 // Adjust the height for more or less space
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
			return UITableViewCell()
		}

		let (category, products) = categories[indexPath.section]
		cell.configure(category: category, items: products)
		
		cell.onArrowTapped = { [weak self] in
			guard let self = self else { return }
			let detailVC = CategoryDetailViewController(category: category, products: products)
			self.navigationController?.pushViewController(detailVC, animated: true)
		}
		return cell
	}
}
