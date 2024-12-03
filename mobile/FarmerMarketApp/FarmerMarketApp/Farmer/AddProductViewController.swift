import UIKit
import SnapKit

class AddProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	private let scrollView = UIScrollView()
	private let contentView = UIView()

	private let nameTextField = createTextField(placeholder: "Enter product name")
	private let categoryPicker = UIPickerView()
	private let priceTextField = createTextField(placeholder: "Enter product price")
	private let descriptionTextField = createTextField(placeholder: "Enter product description")
	private let quantityTextField = createTextField(placeholder: "Enter quantity")
	private let uploadButton: UIButton = {
		let button = UIButton()
		button.setTitle("Upload Image", for: .normal)
		button.backgroundColor = .systemGray4
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
		return button
	}()
	private let addButton: UIButton = {
		let button = UIButton()
		button.setTitle("Add Product", for: .normal)
		button.backgroundColor = UIColor(red: 102 / 255, green: 187 / 255, blue: 106 / 255, alpha: 1.0)
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(addProductTapped), for: .touchUpInside)
		return button
	}()

	private var categories: [Category] = []
	private var selectedCategory: Category?
	private var selectedImage: UIImage?
	var farmerID: Int = 1 // Pass this from the main navigation page.

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
		fetchCategories()
	}

	private func setupUI() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)

		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		contentView.snp.makeConstraints { make in
			make.edges.equalTo(scrollView)
			make.width.equalTo(scrollView)
		}

		let stackView = UIStackView(arrangedSubviews: [
			AddProductViewController.createLabel(text: "Name"),
			nameTextField,
			AddProductViewController.createLabel(text: "Category"),
			categoryPicker,
			AddProductViewController.createLabel(text: "Price in KZT"),
			priceTextField,
			AddProductViewController.createLabel(text: "Description"),
			descriptionTextField,
			AddProductViewController.createLabel(text: "Quantity in KG"),
			quantityTextField,
			AddProductViewController.createLabel(text: "Image"),
			uploadButton,
			addButton
		])
		stackView.axis = .vertical
		stackView.spacing = 16

		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.equalTo(contentView).offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-16)
		}

		categoryPicker.delegate = self
		categoryPicker.dataSource = self
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

	@objc private func uploadImageTapped() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true)
	}

	@objc private func addProductTapped() {
		guard let name = nameTextField.text, !name.isEmpty,
			  let category = selectedCategory,
			  let priceText = priceTextField.text, let price = Double(priceText),
			  let description = descriptionTextField.text, !description.isEmpty,
			  let quantityText = quantityTextField.text, let quantity = Int(quantityText),
			  let image = selectedImage,
			  let imageData = image.jpegData(compressionQuality: 0.8) else {
			showAlert(message: "Please fill in all fields and upload an image.")
			return
		}

		// Create a product instance
		let product = Product(
			farmer: farmerID,
			category: category.id,
			name: name,
			price: price,
			description: description,
			quantity: quantity,
			image: imageData
		)

		// Call NetworkManager to post the product
		NetworkManager.shared.postProduct(product: product) { result in
			DispatchQueue.main.async {
				switch result {
				case .success:
					self.showAlert(message: "Product added successfully!")
				case .failure(let error):
					self.showAlert(message: "Failed to add product: \(error.localizedDescription)")
				}
			}
		}
	}

	private func fetchCategories() {
		NetworkManager.shared.fetchCategories { result in
			DispatchQueue.main.async {
				switch result {
				case .success(let categories):
					self.categories = categories
					self.categoryPicker.reloadAllComponents()
					if let firstCategory = categories.first {
						self.selectedCategory = firstCategory // Pre-select the first category
					}
				case .failure(let error):
					print("Failed to fetch categories: \(error.localizedDescription)")
				}
			}
		}
	}

	private func showAlert(message: String) {
		let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		picker.dismiss(animated: true)
		if let image = info[.originalImage] as? UIImage {
			selectedImage = image
			uploadButton.setTitle("Image Uploaded", for: .normal)
			uploadButton.backgroundColor = UIColor(red: 102 / 255, green: 187 / 255, blue: 106 / 255, alpha: 1.0)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
}

extension AddProductViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return categories.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return categories[row].name
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedCategory = categories[row]
	}
}
