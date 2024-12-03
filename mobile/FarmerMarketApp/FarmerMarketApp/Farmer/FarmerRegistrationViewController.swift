//
//  FarmerRegistrationPage.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 01.11.2024.
//

import UIKit
import MapKit

class FarmerRegistrationViewController: UIViewController {

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
		label.text = "Register as Farmer"
		label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		label.textColor = UIColor(red: 13/255, green: 101/255, blue: 59/255, alpha: 1.0)
		return label
	}()

	private let firstNameTextField = createTextField(placeholder: "Enter your first name")
	private let lastNameTextField = createTextField(placeholder: "Enter your last name")
	private let emailTextField = createTextField(placeholder: "Enter a valid email")
	private let phoneTextField = createTextField(placeholder: "Enter your mobile number")
	private let passwordTextField = createTextField(placeholder: "Enter your password")
	private let farmNameTextField = createTextField(placeholder: "Enter the farm name")

	private let farmLocationTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter the location of the farm"
		textField.borderStyle = .roundedRect
		textField.autocapitalizationType = .none
		return textField
	}()

	private let resultsTableView = UITableView()

	private let farmSizeTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter the size of the farm"
		textField.borderStyle = .roundedRect
		textField.keyboardType = .decimalPad
		return textField
	}()

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

		farmLocationTextField.addTarget(self, action: #selector(farmLocationTextChanged(_:)), for: .editingChanged)
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
		 emailTextField, phoneTextField, passwordTextField, farmNameTextField,
		 farmLocationTextField, resultsTableView, farmSizeTextField, nextButton].forEach {
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

		emailTextField.snp.makeConstraints { make in
			make.top.equalTo(lastNameTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		phoneTextField.snp.makeConstraints { make in
			make.top.equalTo(emailTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		passwordTextField.snp.makeConstraints { make in
			make.top.equalTo(phoneTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		farmNameTextField.snp.makeConstraints { make in
			make.top.equalTo(passwordTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		farmLocationTextField.snp.makeConstraints { make in
			make.top.equalTo(farmNameTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		resultsTableView.snp.makeConstraints { make in
			make.top.equalTo(farmLocationTextField.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(200)
		}

		farmSizeTextField.snp.makeConstraints { make in
			make.top.equalTo(resultsTableView.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		nextButton.snp.makeConstraints { make in
			make.top.equalTo(farmSizeTextField.snp.bottom).offset(30)
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
	@objc private func farmLocationTextChanged(_ textField: UITextField) {
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
		let allFieldsEmpty = [
			firstNameTextField.text?.isEmpty ?? true,
			lastNameTextField.text?.isEmpty ?? true,
			passwordTextField.text?.isEmpty ?? true,
			emailTextField.text?.isEmpty ?? true,
			phoneTextField.text?.isEmpty ?? true,
			farmNameTextField.text?.isEmpty ?? true,
			farmLocationTextField.text?.isEmpty ?? true,
			farmSizeTextField.text?.isEmpty ?? true
		].allSatisfy { $0 }
		
		if allFieldsEmpty {
			navigateToPendingPage()
			return
		}
		
		guard let firstName = firstNameTextField.text, !firstName.isEmpty,
			  let lastName = lastNameTextField.text, !lastName.isEmpty,
			  let password = passwordTextField.text, !password.isEmpty,
			  let email = emailTextField.text, !email.isEmpty,
			  let phone = phoneTextField.text, !phone.isEmpty,
			  let farmName = farmNameTextField.text, !farmName.isEmpty,
			  let farm_location = farmLocationTextField.text, !farm_location.isEmpty,
			  let farm_size = farmSizeTextField.text, !farm_size.isEmpty else {
			showAlert(message: "All fields are required.")
			return
		}
		let user = User(id: nil, first_name: firstName, last_name: lastName, email: email, phone_number: phone, password: password, role: "farmer", image: nil)
		let farmer = Farmer(id: nil, user: user, Fname: farmName, farm_location: farm_location, farm_size: farm_size)
		
		NetworkManager.shared.registerFarmer(farmer) { success, error in
			DispatchQueue.main.async {
				if success {
					self.navigateToPendingPage()
				} else {
					self.showAlert(message: error ?? "Registration failed.")
				}
			}
		}
	}
	private func navigateToPendingPage() {
		let pendingViewController = PendingApproavalViewModel()
		navigationController?.pushViewController(pendingViewController, animated: true)
	}
	
	private func showAlert(message: String) {
		let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FarmerRegistrationViewController: UITableViewDelegate, UITableViewDataSource {
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
		farmLocationTextField.text = result.title
		resultsTableView.isHidden = true
	}
}

// MARK: - MKLocalSearchCompleterDelegate
extension FarmerRegistrationViewController: MKLocalSearchCompleterDelegate {
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		searchResults = completer.results
		resultsTableView.reloadData()
	}

	func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		print("Error: \(error.localizedDescription)")
	}
}
