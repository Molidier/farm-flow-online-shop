//
//  AddProductViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 21.11.2024.
//

import UIKit
import SnapKit

class AddProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	private let nameTextField = createTextField(placeholder: "Enter product name")
	private let categoryPicker = UIPickerView()
	private let priceTextField = createTextField(placeholder: "Enter product price")
	private let descriptionTextField = createTextField(placeholder: "Enter product description")
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
	
	private var categories: [String] = ["Fruits", "Vegetables", "Dairy", "Grains", "Meat"]
	private var selectedCategory: String?
	private var selectedImage: UIImage?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUI()
	}
	
	private func setupUI() {
		let stackView = UIStackView(arrangedSubviews: [
			AddProductViewController.createLabel(text: "Name"),
			nameTextField,
			AddProductViewController.createLabel(text: "Category"),
			categoryPicker,
			AddProductViewController.createLabel(text: "Price in KZT"),
			priceTextField,
			AddProductViewController.createLabel(text: "Description"),
			descriptionTextField,
			AddProductViewController.createLabel(text: "Image"),
			uploadButton,
			addButton
		])
		stackView.axis = .vertical
		stackView.spacing = 16
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
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
			  let priceText = priceTextField.text, !priceText.isEmpty,
			  let description = descriptionTextField.text, !description.isEmpty,
			  let _ = selectedImage else {
			let alert = UIAlertController(title: "Error", message: "Please fill in all fields and upload an image.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
			return
		}
		
		let alert = UIAlertController(title: "Success", message: "Product '\(name)' added successfully under '\(category)' category!", preferredStyle: .alert)
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
		return categories[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedCategory = categories[row]
	}
}
