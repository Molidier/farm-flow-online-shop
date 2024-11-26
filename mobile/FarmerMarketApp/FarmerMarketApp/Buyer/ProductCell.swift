import UIKit
import SnapKit

class ProductCell: UITableViewCell {
	
	private let productImageView = UIImageView()
	private let nameLabel = UILabel()
	private let priceLabel = UILabel()
	private let quantityLabel = UILabel()
	private let descriptionLabel = UILabel()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		productImageView.contentMode = .scaleAspectFit
		productImageView.layer.cornerRadius = 8
		productImageView.layer.masksToBounds = true
		contentView.addSubview(productImageView)
		
		nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
		nameLabel.textColor = .black
		contentView.addSubview(nameLabel)
		
		priceLabel.font = UIFont.systemFont(ofSize: 16)
		priceLabel.textColor = .systemGreen
		contentView.addSubview(priceLabel)
		
		quantityLabel.font = UIFont.systemFont(ofSize: 16)
		quantityLabel.textColor = .systemGray
		contentView.addSubview(quantityLabel)
		
		descriptionLabel.font = UIFont.systemFont(ofSize: 14) // Increase font size for better readability
		descriptionLabel.textColor = .darkGray
		descriptionLabel.numberOfLines = 2
		descriptionLabel.lineBreakMode = .byWordWrapping
		contentView.addSubview(descriptionLabel)
		
		productImageView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(80)
		}
		
		nameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(16)
			make.leading.equalTo(productImageView.snp.trailing).offset(16)
			make.trailing.equalToSuperview().inset(16)
		}
		
		priceLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(5)
			make.leading.equalTo(nameLabel.snp.leading)
		}
		
		quantityLabel.snp.makeConstraints { make in
			make.top.equalTo(priceLabel.snp.bottom).offset(5)
			make.leading.equalTo(priceLabel.snp.leading)
		}
		
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(quantityLabel.snp.bottom).offset(5)
			make.leading.equalTo(nameLabel.snp.leading)
			make.trailing.equalToSuperview().inset(8)
			make.bottom.lessThanOrEqualToSuperview().inset(8)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		productImageView.image = nil
		nameLabel.text = nil
		priceLabel.text = nil
		quantityLabel.text = nil
		descriptionLabel.text = nil
	}
	
	func configure(with product: Product) {
		productImageView.image = UIImage(named: product.imageName)
		nameLabel.text = product.name
		priceLabel.text = "\(String(format: "%.2f", product.price)) KZT"
		quantityLabel.text = "Quantity: \(product.quantity)"
		descriptionLabel.text = product.description
	}
}
