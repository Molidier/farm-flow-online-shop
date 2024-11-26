//
//  FarmerRegistrationPage.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 01.11.2024.
//

import UIKit
import SnapKit

class FarmerRegistrationViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}

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
	private let passwordTextField = createTextField(placeholder: "Enter your password")
	private let emailTextField = createTextField(placeholder: "Enter a valid email address for account verification")
	private let phoneTextField = createTextField(placeholder: "Enter your mobile number")
	private let farmNameTextField = createTextField(placeholder: "Enter the farm name")
	private let farmLocationTextField = createTextField(placeholder: "Enter the location of your farm (city, state)")

	private let nextButton: UIButton = {
		let button = UIButton()
		button.setTitle("Next", for: .normal)
		button.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
		return button
	}()

	private func setupUI() {
		view.addSubview(logoImageView)
		view.addSubview(titleLabel)
		view.addSubview(firstNameTextField)
		view.addSubview(lastNameTextField)
		view.addSubview(passwordTextField)
		view.addSubview(emailTextField)
		view.addSubview(phoneTextField)
		view.addSubview(farmNameTextField)
		view.addSubview(farmLocationTextField)
		view.addSubview(nextButton)

		logoImageView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
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

		farmNameTextField.snp.makeConstraints { make in
			make.top.equalTo(phoneTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		farmLocationTextField.snp.makeConstraints { make in
			make.top.equalTo(farmNameTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		nextButton.snp.makeConstraints { make in
			make.top.equalTo(farmLocationTextField.snp.bottom).offset(30)
			make.centerX.equalToSuperview()
			make.width.equalTo(150)
			make.height.equalTo(44)
		}
	}

	private static func createTextField(placeholder: String) -> UITextField {
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.borderStyle = .none
		return textField
	}

	@objc private func nextButtonTapped() {
		let allFieldsEmpty = [
			firstNameTextField.text?.isEmpty ?? true,
			lastNameTextField.text?.isEmpty ?? true,
			passwordTextField.text?.isEmpty ?? true,
			emailTextField.text?.isEmpty ?? true,
			phoneTextField.text?.isEmpty ?? true,
			farmNameTextField.text?.isEmpty ?? true,
			farmLocationTextField.text?.isEmpty ?? true
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
			  let farmName = farmNameTextField.text, !farmName.isEmpty else {
			showAlert(message: "All fields are required.")
			return
		}

		let user = User(first_name: firstName, last_name: lastName, email: email, phone_number: phone, password: password)
		let farmer = Farmer(id: nil, user: user, Fname: farmName)

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
