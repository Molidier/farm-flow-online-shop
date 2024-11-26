import UIKit

class BuyerOTPViewController: UIViewController {

	private let logoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "logoFFgreen")
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Verify OTP"
		label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		label.textColor = UIColor(red: 13/255, green: 101/255, blue: 59/255, alpha: 1.0)
		return label
	}()

	private let otpTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Enter OTP"
		textField.borderStyle = .roundedRect
		textField.keyboardType = .numberPad
		textField.textAlignment = .center
		textField.font = UIFont.systemFont(ofSize: 18)
		return textField
	}()

	private let verifyButton: UIButton = {
		let button = UIButton()
		button.setTitle("Verify", for: .normal)
		button.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
		button.layer.cornerRadius = 20
		button.addTarget(self, action: #selector(verifyOTP), for: .touchUpInside)
		return button
	}()

	var email: String? 

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}

	private func setupUI() {
		view.addSubview(logoImageView)
		view.addSubview(titleLabel)
		view.addSubview(otpTextField)
		view.addSubview(verifyButton)

		logoImageView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(40)
		}

		titleLabel.snp.makeConstraints { make in
			make.top.equalTo(logoImageView.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
		}

		otpTextField.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(40)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(44)
		}

		verifyButton.snp.makeConstraints { make in
			make.top.equalTo(otpTextField.snp.bottom).offset(30)
			make.centerX.equalToSuperview()
			make.width.equalTo(150)
			make.height.equalTo(44)
		}
	}

	@objc private func verifyOTP() {
		guard let otp = otpTextField.text, !otp.isEmpty, let email = email else {
			let alert = UIAlertController(title: "Error", message: "Please enter the OTP.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
			return
		}

		NetworkManager.shared.verifyOTP(email: email, otp: otp) { success, errorMessage in
			DispatchQueue.main.async {
				if (success != nil) {
					let welcomeVC = WelcomePageViewController()
					let navController = UINavigationController(rootViewController: welcomeVC)
					self.view.window?.rootViewController = navController
					self.view.window?.makeKeyAndVisible()
				} else {
					let alert = UIAlertController(title: "Error", message: errorMessage ?? "Invalid OTP. Please try again.", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default))
					self.present(alert, animated: true)
				}
			}
		}
	}
}
