//
//  SignInViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 01.11.2024.
//

import UIKit

class SignInViewController: UIViewController {
	private var selectedRole: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
		passwordTextField.rightView = togglePasswordVisibilityButton
	}

	private let phoneTextField = createTextField(placeholder: "Enter your mobile number")
	private let passwordTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter your password"
		textField.isSecureTextEntry = true
		textField.borderStyle = .none
		textField.rightViewMode = .always
		return textField
	}()
	private lazy var togglePasswordVisibilityButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setImage(UIImage(systemName: "eye"), for: .normal)
		button.setImage(UIImage(systemName: "eye.slash"), for: .selected)
		button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
		return button
	}()
	private let buyerButton: UIButton = {
		let button = UIButton()
		button.setTitle("I am Buyer", for: .normal)
		button.backgroundColor = UIColor(red: 102 / 255, green: 187 / 255, blue: 106 / 255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(selectBuyerRole), for: .touchUpInside)
		return button
	}()
	private let farmerButton: UIButton = {
		let button = UIButton()
		button.setTitle("I am Farmer", for: .normal)
		button.backgroundColor = UIColor(red: 255 / 255, green: 165 / 255, blue: 0 / 255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(selectFarmerRole), for: .touchUpInside)
		return button
	}()
	private let nextButton: UIButton = {
		let button = UIButton()
		button.setTitle("Next", for: .normal)
		button.backgroundColor = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
		return button
	}()

	private func setupUI() {
		view.addSubview(phoneTextField)
		view.addSubview(passwordTextField)
		view.addSubview(buyerButton)
		view.addSubview(farmerButton)
		view.addSubview(nextButton)
		
		phoneTextField.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}
		
		passwordTextField.snp.makeConstraints { make in
			make.top.equalTo(phoneTextField.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}
		
		buyerButton.snp.makeConstraints { make in
			make.top.equalTo(passwordTextField.snp.bottom).offset(30)
			make.leading.equalToSuperview().inset(24)
			make.width.equalTo(150)
			make.height.equalTo(44)
		}
		
		farmerButton.snp.makeConstraints { make in
			make.top.equalTo(passwordTextField.snp.bottom).offset(30)
			make.trailing.equalToSuperview().inset(24)
			make.width.equalTo(150)
			make.height.equalTo(44)
		}
		
		nextButton.snp.makeConstraints { make in
			make.top.equalTo(buyerButton.snp.bottom).offset(20)
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

	@objc private func togglePasswordVisibility() {
		passwordTextField.isSecureTextEntry.toggle()
		togglePasswordVisibilityButton.isSelected.toggle()
	}

	@objc private func selectBuyerRole() {
		selectedRole = "buyer"
		showMessage("Selected role: Buyer")
	}

	@objc private func selectFarmerRole() {
		selectedRole = "farmer"
		showMessage("Selected role: Farmer")
	}

	@objc private func nextButtonTapped() {
		guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty,
			  let password = passwordTextField.text, !password.isEmpty else {
			showError("All fields are required.")
			return
		}

		guard let role = selectedRole else {
			showError("Please select a role.")
			return
		}

		// Navigate to the appropriate page based on the role
		if role == "buyer" {
			let buyerTabBar = SceneDelegate().createBuyerTabBarController()
			navigationController?.viewControllers = [buyerTabBar]
		} else if role == "farmer" {
			let farmerTabBar = SceneDelegate().createFarmerTabBarController()
			navigationController?.viewControllers = [farmerTabBar]
		}
	}

	private func showError(_ message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	private func showMessage(_ message: String) {
		let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}
