import UIKit
import SnapKit

class BargainCell: UITableViewCell {
	private let productNameLabel = UILabel()
	private let suggestedPriceLabel = UILabel()
	private let originalPriceLabel = UILabel()
	private let acceptButton = UIButton(type: .system)
	private let declineButton = UIButton(type: .system)

	var onAccept: (() -> Void)?
	var onDecline: (() -> Void)?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		contentView.addSubview(productNameLabel)
		contentView.addSubview(suggestedPriceLabel)
		contentView.addSubview(originalPriceLabel)
		contentView.addSubview(acceptButton)
		contentView.addSubview(declineButton)

		productNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
		suggestedPriceLabel.font = UIFont.systemFont(ofSize: 14)
		originalPriceLabel.font = UIFont.systemFont(ofSize: 14)

		acceptButton.setTitle("Accept", for: .normal)
		acceptButton.setTitleColor(.systemGreen, for: .normal)
		acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)

		declineButton.setTitle("Decline", for: .normal)
		declineButton.setTitleColor(.systemRed, for: .normal)
		declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)

		productNameLabel.snp.makeConstraints { make in
			make.top.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
		}

		suggestedPriceLabel.snp.makeConstraints { make in
			make.top.equalTo(productNameLabel.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
		}

		originalPriceLabel.snp.makeConstraints { make in
			make.top.equalTo(suggestedPriceLabel.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
		}

		acceptButton.snp.makeConstraints { make in
			make.top.equalTo(originalPriceLabel.snp.bottom).offset(16)
			make.leading.equalToSuperview().offset(16)
			make.width.equalTo(100)
			make.bottom.equalToSuperview().offset(-16)
		}

		declineButton.snp.makeConstraints { make in
			make.top.equalTo(originalPriceLabel.snp.bottom).offset(16)
			make.leading.equalTo(acceptButton.snp.trailing).offset(16)
			make.width.equalTo(100)
			make.bottom.equalToSuperview().offset(-16)
		}
	}

	@objc private func acceptTapped() {
		onAccept?()
	}

	@objc private func declineTapped() {
		onDecline?()
	}

	func configure(with bargain: BargainRequest) {
		productNameLabel.text = "Product: \(bargain.productId)"
		suggestedPriceLabel.text = "Suggested Price: \(String(format: "%.2f", bargain.suggestedPrice)) KZT"
		originalPriceLabel.text = "Original Price: \(String(format: "%.2f", bargain.originalPrice)) KZT"
	}
}
