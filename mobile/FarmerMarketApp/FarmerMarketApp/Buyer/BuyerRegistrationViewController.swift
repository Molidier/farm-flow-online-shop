import UIKit
import MapKit
import SnapKit

class BuyerRegistrationViewController: UIViewController {

	// MARK: - UI Components
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = true
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
	}()

	private let contentView: UIView = UIView()

	private let logoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "logoFFgreen")
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Register as Buyer"
		label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		label.textColor = UIColor(red: 13/255, green: 101/255, blue: 59/255, alpha: 1.0)
		return label
	}()

	private let firstNameTextField = createTextField(placeholder: "Enter your first name")
	private let lastNameTextField = createTextField(placeholder: "Enter your last name")
	private let passwordTextField = createTextField(placeholder: "Enter your password")
	private let emailTextField = createTextField(placeholder: "Enter a valid email address for account verification")
	private let phoneTextField = createTextField(placeholder: "Enter your mobile number")

	private let deliveryAddressTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter the delivery address"
		textField.borderStyle = .roundedRect
		textField.autocapitalizationType = .none
		return textField
	}()

	private let resultsTableView = UITableView()

	private let nextButton: UIButton = {
		let button = UIButton()
		button.setTitle("Next", for: .normal)
		button.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
		return button
	}()

	// MARK: - Data Components
	private var searchCompleter = MKLocalSearchCompleter()
	private var searchResults: [MKLocalSearchCompletion] = []
	private var debounceTimer: Timer?

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
		configureSearchCompleter()

		deliveryAddressTextField.addTarget(self, action: #selector(deliveryAddressTextChanged(_:)), for: .editingChanged)
	}

	// MARK: - Helper Function for Text Fields
	private static func createTextField(placeholder: String) -> UITextField {
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.borderStyle = .roundedRect
		textField.font = UIFont.systemFont(ofSize: 16)
		return textField
	}

	// MARK: - Setup Methods
	private func setupUI() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)

		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		contentView.snp.makeConstraints { make in
			make.edges.equalTo(scrollView)
			make.width.equalToSuperview()
		}

		// Add UI components
		[logoImageView, titleLabel, firstNameTextField, lastNameTextField,
		 passwordTextField, emailTextField, phoneTextField, deliveryAddressTextField,
		 resultsTableView, nextButton].forEach {
			contentView.addSubview($0)
		}

		resultsTableView.delegate = self
		resultsTableView.dataSource = self
		resultsTableView.isHidden = true
		resultsTableView.layer.borderWidth = 1
		resultsTableView.layer.borderColor = UIColor.gray.cgColor
		resultsTableView.layer.cornerRadius = 10

		setupConstraints()
	}

	private func setupConstraints() {
		logoImageView.snp.makeConstraints { make in
			make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(16)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(40)
		}

		titleLabel.snp.makeConstraints { make in
			make.top.equalTo(logoImageView.snp.bottom).offset(20)
			make.leading.equalToSuperview().offset(24)
		}

		firstNameTextField.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(20)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		lastNameTextField.snp.makeConstraints { make in
			make.top.equalTo(firstNameTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		passwordTextField.snp.makeConstraints { make in
			make.top.equalTo(lastNameTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		emailTextField.snp.makeConstraints { make in
			make.top.equalTo(passwordTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		phoneTextField.snp.makeConstraints { make in
			make.top.equalTo(emailTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		deliveryAddressTextField.snp.makeConstraints { make in
			make.top.equalTo(phoneTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		resultsTableView.snp.makeConstraints { make in
			make.top.equalTo(deliveryAddressTextField.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(200)
		}

		nextButton.snp.makeConstraints { make in
			make.top.equalTo(resultsTableView.snp.bottom).offset(30)
			make.centerX.equalToSuperview()
			make.width.equalTo(150)
			make.height.equalTo(44)
			make.bottom.equalTo(contentView).offset(-20)
		}
	}

	private func configureSearchCompleter() {
		searchCompleter.delegate = self
		searchCompleter.region = MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 51.1694, longitude: 71.4491),
			span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
		)
	}

	// MARK: - Actions
	@objc private func deliveryAddressTextChanged(_ textField: UITextField) {
		debounceTimer?.invalidate()
		let query = textField.text ?? ""
		if !query.isEmpty {
			debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
				self?.searchCompleter.queryFragment = query
				self?.resultsTableView.isHidden = false
			}
		} else {
			resultsTableView.isHidden = true
		}
	}

	@objc private func nextButtonTapped() {
		guard let firstName = firstNameTextField.text, !firstName.isEmpty,
			  let lastName = lastNameTextField.text, !lastName.isEmpty,
			  let password = passwordTextField.text, !password.isEmpty,
			  let email = emailTextField.text, !email.isEmpty,
			  let phone = phoneTextField.text, !phone.isEmpty,
			  let deliveryAddress = deliveryAddressTextField.text, !deliveryAddress.isEmpty else {
			showAlert(message: "All fields are required.")
			return
		}

		let user = User(id: nil, first_name: firstName, last_name: lastName, email: email, phone_number: phone, password: password, role: "buyer", image: nil)
		let buyer = Buyer(id: nil, user: user, deliveryAddress: deliveryAddress)

		NetworkManager.shared.registerBuyer(buyer) { success, errorMessage in
			DispatchQueue.main.async {
				if success {
					let otpVC = BuyerOTPViewController()
					otpVC.email = email
					self.navigationController?.pushViewController(otpVC, animated: true)
				} else {
					self.showAlert(message: errorMessage ?? "Registration failed. Please try again.")
				}
			}
		}
	}
	private func showAlert(message: String) {
		let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BuyerRegistrationViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
		let result = searchResults[indexPath.row]
		cell.textLabel?.text = result.title
		cell.detailTextLabel?.text = result.subtitle
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let result = searchResults[indexPath.row]
		deliveryAddressTextField.text = result.title
		resultsTableView.isHidden = true
	}
	
}

// MARK: - MKLocalSearchCompleterDelegate
extension BuyerRegistrationViewController: MKLocalSearchCompleterDelegate {
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		searchResults = completer.results
		resultsTableView.reloadData()
	}

	func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		print("Error: \(error.localizedDescription)")
	}
}
