import UIKit
import SnapKit

class ProductCell: UITableViewCell {
	private let productImageView = UIImageView()
	private let nameLabel = UILabel()
	private let priceLabel = UILabel()
	private let availableQuantityLabel = UILabel()
	private let descriptionLabel = UILabel()
	private let addToCartButton = UIButton()
	private let quantityStepper = UIStepper()
	private let selectedQuantityLabel = UILabel()
	
	var onAddToCart: ((Int) -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		// Product Image
		productImageView.contentMode = .scaleAspectFit
		productImageView.layer.cornerRadius = 8
		productImageView.layer.masksToBounds = true
		contentView.addSubview(productImageView)
		
		// Product Name
		nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		nameLabel.textColor = .black
		contentView.addSubview(nameLabel)
		
		// Price Label
		priceLabel.font = UIFont.systemFont(ofSize: 14)
		priceLabel.textColor = .systemGreen
		contentView.addSubview(priceLabel)
		
		// Available Quantity
		availableQuantityLabel.font = UIFont.systemFont(ofSize: 12)
		availableQuantityLabel.textColor = .darkGray
		contentView.addSubview(availableQuantityLabel)
		
		// Product Description
		descriptionLabel.font = UIFont.systemFont(ofSize: 12)
		descriptionLabel.textColor = .darkGray
		descriptionLabel.numberOfLines = 2
		contentView.addSubview(descriptionLabel)
		
		// Quantity Stepper
		quantityStepper.minimumValue = 1
		quantityStepper.maximumValue = 100
		quantityStepper.value = 1
		quantityStepper.addTarget(self, action: #selector(quantityStepperChanged), for: .valueChanged)
		contentView.addSubview(quantityStepper)
		
		// Selected Quantity Label
		selectedQuantityLabel.font = UIFont.systemFont(ofSize: 14)
		selectedQuantityLabel.text = "1"
		selectedQuantityLabel.textColor = .black
		selectedQuantityLabel.textAlignment = .center
		contentView.addSubview(selectedQuantityLabel)
		
		// Add to Cart Button
		addToCartButton.setTitle("Add to Cart", for: .normal)
		addToCartButton.setTitleColor(.white, for: .normal)
		addToCartButton.backgroundColor = .systemBlue
		addToCartButton.layer.cornerRadius = 5
		addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
		contentView.addSubview(addToCartButton)
		
		// Constraints
		productImageView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.top.equalToSuperview().offset(8)
			make.width.height.equalTo(60)
		}
		
		nameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.leading.equalTo(productImageView.snp.trailing).offset(12)
			make.trailing.equalToSuperview().inset(16)
		}
		
		priceLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel.snp.leading)
		}
		
		availableQuantityLabel.snp.makeConstraints { make in
			make.top.equalTo(priceLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel.snp.leading)
		}
		
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(availableQuantityLabel.snp.bottom).offset(4)
			make.leading.equalTo(nameLabel.snp.leading)
			make.trailing.equalToSuperview().inset(16)
		}
		
		quantityStepper.snp.makeConstraints { make in
			make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
			make.trailing.equalToSuperview().inset(16)
		}
		
		selectedQuantityLabel.snp.makeConstraints { make in
			make.centerY.equalTo(quantityStepper.snp.centerY)
			make.trailing.equalTo(quantityStepper.snp.leading).offset(-8)
			make.width.equalTo(30)
		}
		
		addToCartButton.snp.makeConstraints { make in
			make.top.equalTo(quantityStepper.snp.bottom).offset(8)
			make.trailing.equalToSuperview().inset(16)
			make.width.equalTo(100)
			make.height.equalTo(30)
			make.bottom.equalToSuperview().inset(8) // Ensures the button anchors the bottom
		}
	}
	
	@objc private func quantityStepperChanged() {
		selectedQuantityLabel.text = "\(Int(quantityStepper.value))"
	}
	
	@objc private func addToCartTapped() {
		let selectedQuantity = Int(quantityStepper.value)
		onAddToCart?(selectedQuantity)
	}
	
	func configure(with product: Products, onAddToCart: @escaping (Int) -> Void) {
		productImageView.image = UIImage(named: product.imageName)
		nameLabel.text = product.name
		priceLabel.text = "\(String(format: "%.2f", product.price)) KZT"
		availableQuantityLabel.text = "Quantity: \(product.quantity)"
		descriptionLabel.text = product.description
		self.onAddToCart = onAddToCart
	}
}
