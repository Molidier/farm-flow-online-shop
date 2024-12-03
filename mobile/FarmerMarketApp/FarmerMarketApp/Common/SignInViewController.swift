import UIKit

class SignInViewController: UIViewController {
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

	private let nextButton: UIButton = {
		let button = UIButton()
		button.setTitle("Sign In", for: .normal)
		button.backgroundColor = UIColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
		return button
	}()

	private func setupUI() {
		view.addSubview(phoneTextField)
		view.addSubview(passwordTextField)
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

		nextButton.snp.makeConstraints { make in
			make.top.equalTo(passwordTextField.snp.bottom).offset(30)
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

	private func debugUserObject(user: UserWrapper) {
		print("===== DEBUGGING USER OBJECT =====")
		print("ID: \(user.id ?? -1)")
		print("First Name: \(user.user.first_name)")
		print("Last Name: \(user.user.last_name)")
		print("Email: \(user.user.email)")
		print("Phone Number: \(user.user.phone_number)")
		print("Role: \(user.user.role)")
		print("Image: \(user.user.image ?? "nil")")
		print("Fname: \(user.Fname ?? "nil")")
		print("Farm Location: \(user.farm_location ?? "nil")")
		print("Farm Size: \(String(describing: user.farm_size))")
		print("Delivery Address: \(user.deliveryAdress ?? "nil")")
		print("==================================")
	}

	@objc private func nextButtonTapped() {
		guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty,
			  let password = passwordTextField.text, !password.isEmpty else {
			showError("All fields are required.")
			return
		}

		NetworkManager.shared.authenticateUser(phoneNumber: phoneNumber, password: password) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success(let response):
					NetworkManager.shared.accessToken = response.access

					self?.debugUserObject(user: response.user)

					let user = response.user.user
					switch user.role {
					case "farmer":
						print("Logged in as Farmer: \(user.first_name)")
						let farmerTabBar = SceneDelegate().createFarmerTabBarController(farmer: response.user)
						self?.navigationController?.viewControllers = [farmerTabBar]
					case "buyer":
						print("Logged in as Buyer: \(user.first_name)")
						let buyerTabBar = SceneDelegate().createBuyerTabBarController(buyer: response.user)
						self?.navigationController?.viewControllers = [buyerTabBar]
					default:
						self?.showError("Invalid user role.")
					}
				case .failure(let error):
					self?.showError("Authentication failed: \(error.localizedDescription)")
				}
			}
		}
	}

	private func showError(_ message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}
