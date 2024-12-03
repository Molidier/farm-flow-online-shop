import UIKit
import SnapKit

class CartItemCell: UITableViewCell {
	private let productImageView = UIImageView()
	private let nameLabel = UILabel()
	private let quantityLabel = UILabel()
	private let totalPriceLabel = UILabel()
	private let chatButton = UIButton(type: .system)
	private let bargainButton = UIButton(type: .system)
	var onBargainTapped: (() -> Void)?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		contentView.backgroundColor = .white

		// Product Image
		productImageView.contentMode = .scaleAspectFit
		productImageView.layer.cornerRadius = 8
		productImageView.clipsToBounds = true
		contentView.addSubview(productImageView)

		// Name Label
		nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		nameLabel.textColor = .black
		nameLabel.numberOfLines = 0
		contentView.addSubview(nameLabel)

		// Quantity Label
		quantityLabel.font = UIFont.systemFont(ofSize: 14)
		quantityLabel.textColor = .darkGray
		contentView.addSubview(quantityLabel)

		// Total Price Label
		totalPriceLabel.font = UIFont.systemFont(ofSize: 16)
		totalPriceLabel.textColor = .systemGreen
		contentView.addSubview(totalPriceLabel)

		// Chat Button
		chatButton.setTitle("Chat", for: .normal)
		chatButton.setTitleColor(.systemBlue, for: .normal)
		chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		chatButton.layer.cornerRadius = 5
		chatButton.layer.borderWidth = 1
		chatButton.layer.borderColor = UIColor.systemBlue.cgColor
		chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
		contentView.addSubview(chatButton)

		// Bargain Button
		bargainButton.setTitle("Bargain", for: .normal)
		bargainButton.setTitleColor(.systemBlue, for: .normal)
		bargainButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		bargainButton.layer.cornerRadius = 5
		bargainButton.layer.borderWidth = 1
		bargainButton.layer.borderColor = UIColor.systemBlue.cgColor
		bargainButton.addTarget(self, action: #selector(bargainButtonTapped), for: .touchUpInside)
		contentView.addSubview(bargainButton)

		// Constraints
		productImageView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(50)
		}

		nameLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(5)
			make.leading.equalTo(productImageView.snp.trailing).offset(10)
			make.trailing.equalTo(totalPriceLabel.snp.leading).offset(-10)
		}

		quantityLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(3)
			make.leading.equalTo(nameLabel.snp.leading)
			make.trailing.lessThanOrEqualTo(totalPriceLabel.snp.leading).offset(-10)
		}

		totalPriceLabel.snp.makeConstraints { make in
			make.trailing.equalTo(chatButton.snp.leading).offset(-10)
			make.centerY.equalToSuperview()
			make.width.equalTo(60)
		}

		chatButton.snp.makeConstraints { make in
			make.trailing.equalTo(bargainButton.snp.leading).offset(-8)
			make.centerY.equalToSuperview()
			make.width.equalTo(70)
			make.height.equalTo(30)
		}

		bargainButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().inset(16)
			make.centerY.equalToSuperview()
			make.width.equalTo(70)
			make.height.equalTo(30)
		}
	}

	func configure(with cartItem: CartItem, onBargain: @escaping () -> Void) {
		productImageView.image = UIImage(named: cartItem.product.imageName)
		nameLabel.text = cartItem.product.name
		quantityLabel.text = "Quantity: \(cartItem.quantity)"
		totalPriceLabel.text = "\(String(format: "%.2f", cartItem.product.price * Double(cartItem.quantity))) KZT"
		onBargainTapped = onBargain
	}

	@objc private func chatButtonTapped() {
		guard let url = URL(string: "https://t.me/kameow18") else { return }
		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	@objc private func bargainButtonTapped() {
		onBargainTapped?()
	}
}
