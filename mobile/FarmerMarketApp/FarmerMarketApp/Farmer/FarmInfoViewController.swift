import UIKit
import SnapKit

class FarmInfoViewController: UIViewController {
	
	private let farmNameTextField = createTextField(placeholder: "Enter your farm's name")
	private let farmPassportTextField = createTextField(placeholder: "Enter your farm's passport ID")
	private let farmLocationTextField = createTextField(placeholder: "Enter your farm's location (optional)")
	private let submitButton: UIButton = {
		let button = UIButton()
		button.setTitle("Submit", for: .normal)
		button.backgroundColor = UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}
	
	private func setupUI() {
		let stackView = UIStackView(arrangedSubviews: [
			FarmInfoViewController.createLabel(text: "Farm Name"),
			farmNameTextField,
			FarmInfoViewController.createLabel(text: "Farm Passport ID"),
			farmPassportTextField,
			FarmInfoViewController.createLabel(text: "Farm Location (Optional)"),
			farmLocationTextField,
			submitButton
		])
		stackView.axis = .vertical
		stackView.spacing = 16
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
		}
	}
	
	private static func createTextField(placeholder: String) -> UITextField {
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.borderStyle = .roundedRect
		return textField
	}
	
	private static func createLabel(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.textColor = .darkGray
		return label
	}
	
	@objc private func submitTapped() {
		guard let farmName = farmNameTextField.text, !farmName.isEmpty,
			  let farmPassport = farmPassportTextField.text, !farmPassport.isEmpty else {
			let alert = UIAlertController(title: "Error", message: "Please fill in all required fields.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
			return
		}
		
		let farmLocation = farmLocationTextField.text
		
		let mainPageVC = MainPageFarmerViewController()
		navigationController?.pushViewController(mainPageVC, animated: true)
	}
}
