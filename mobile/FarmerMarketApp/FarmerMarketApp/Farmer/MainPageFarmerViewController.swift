import UIKit
import SnapKit
import UserNotifications

class MainPageFarmerViewController: UIViewController {
	private let tableView = UITableView()
	private var inventory: [Products] = [] // Mocked inventory
	var farmer: UserWrapper? // This should hold the farmer's data passed from the previous view.
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let farmer = farmer {
			print("Welcome, Farmer \(farmer.user.first_name)!")
			loadMockInventory()
		}
		setupUI()
		scheduleNotification()
	}
	
	private func setupUI() {
		view.backgroundColor = .white

		// Navigation Bar
		let navBarView = UIView()
		navBarView.backgroundColor = UIColor(red: 34/255, green: 73/255, blue: 47/255, alpha: 1)
		view.addSubview(navBarView)
		navBarView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(70)
		}

		// Navigation Title
		let navigationTitleLabel = UILabel()
		navigationTitleLabel.text = "My Inventory"
		navigationTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		navigationTitleLabel.textColor = .white
		navBarView.addSubview(navigationTitleLabel)
		navigationTitleLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.leading.equalToSuperview().offset(16)
		}

		// Greeting Label
		let greetingLabel = UILabel()
		if let firstName = farmer?.user.first_name {
			greetingLabel.text = "Hi, Farmer \(firstName)!"
		} else {
			greetingLabel.text = "Hi, Farmer Guest!"
		}
		greetingLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		greetingLabel.textColor = .black
		view.addSubview(greetingLabel)
		greetingLabel.snp.makeConstraints { make in
			make.top.equalTo(navBarView.snp.bottom).offset(16)
			make.leading.equalToSuperview().offset(16)
		}

		// TableView Setup
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(InventoryCell.self, forCellReuseIdentifier: "InventoryCell")
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.top.equalTo(greetingLabel.snp.bottom).offset(20)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // Adjusted to avoid overlap with the tab bar
		}
	}

	
	// Load all products, including out-of-stock items
	private func loadMockInventory() {
		inventory = MockData.shared.sampleProducts
		tableView.reloadData()
	}
	
	private func scheduleNotification() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			let content = UNMutableNotificationContent()
			content.title = "Low Stock Alert"
			content.body = "You have products that are out of stock. Time to restock!"
			content.sound = .default
			
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: "LowStockNotification", content: content, trigger: trigger)
			
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Failed to schedule notification: \(error.localizedDescription)")
				}
			}
		}
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainPageFarmerViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return inventory.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as? InventoryCell else {
			return UITableViewCell()
		}
		let product = inventory[indexPath.row]
		cell.configure(with: product)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 150
	}
}
