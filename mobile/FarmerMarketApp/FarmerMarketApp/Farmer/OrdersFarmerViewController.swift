import UIKit
import SnapKit

class OrdersFarmerViewController: UIViewController {
	private let tableView = UITableView()
	private var orders: [OrderDetails] {
		return OrderManager.shared.farmerOrders
	}
	private var bargains: [BargainRequest] = BargainManager.shared.getBargainRequests()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	private func setupView() {
		view.backgroundColor = .white

		setupNavigationBar()
		setupTableView()
	}

	private func setupNavigationBar() {
		let navBarView = UIView()
		navBarView.backgroundColor = UIColor(red: 34 / 255, green: 73 / 255, blue: 47 / 255, alpha: 1)

		view.addSubview(navBarView)
		navBarView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(70)
		}

		let navigationTitleLabel = UILabel()
		navigationTitleLabel.text = "Order History"
		navigationTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		navigationTitleLabel.textColor = .white
		navBarView.addSubview(navigationTitleLabel)
		navigationTitleLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.leading.equalToSuperview().offset(16)
		}

		let notificationButton = UIButton(type: .system)
		notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
		notificationButton.tintColor = .white
		navBarView.addSubview(notificationButton)
		notificationButton.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.trailing.equalToSuperview().offset(-16)
		}
	}

	private func setupTableView() {
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
			make.leading.trailing.bottom.equalToSuperview()
		}

		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(OrderCell.self, forCellReuseIdentifier: "OrderCell")
		tableView.register(BargainCell.self, forCellReuseIdentifier: "BargainCell")
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 150
	}
}

extension OrdersFarmerViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		// One section for orders, one for bargains
		return 2
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Orders"
		} else {
			return "Bargains"
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return orders.count
		} else {
			return bargains.count
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			// Order Cell
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as? OrderCell else {
				return UITableViewCell()
			}
			let order = orders[indexPath.row]
			cell.configure(with: order)
			return cell
		} else {
			// Bargain Cell
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "BargainCell", for: indexPath) as? BargainCell else {
				return UITableViewCell()
			}
			let bargain = bargains[indexPath.row]
			cell.configure(with: bargain)

			// Accept or Decline Handlers
			cell.onAccept = { [weak self] in
				BargainManager.shared.acceptBargain(bargain: bargain)

				self?.bargains = BargainManager.shared.getBargainRequests()
				self?.tableView.reloadData()

				NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
			}

			cell.onDecline = { [weak self] in
				BargainManager.shared.declineBargain(bargain: bargain)
				self?.bargains = BargainManager.shared.getBargainRequests() // Refresh bargains
				self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
			}
			return cell
		}
	}
}
