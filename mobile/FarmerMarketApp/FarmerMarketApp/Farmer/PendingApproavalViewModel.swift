//
//  PendingApproavalViewModel.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 11.11.2024.
//

import UIKit
import SnapKit

class PendingApproavalViewModel: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	private let pendingLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.text = "Account Pending Approval"
		titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		return titleLabel
	}()
	private let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
		spinner.color = .white
		spinner.startAnimating()
		return spinner
	}()
	private let descriptionLabel: UILabel = {
		let descriptionLabel = UILabel()
		descriptionLabel.text = """
		Thank you for registering! Your account is now pending approval.
		Our team is reviewing your details. This usually takes 1-2 business days.
		You’ll receive an email once approved.
		"""
		descriptionLabel.font = UIFont.systemFont(ofSize: 16)
		descriptionLabel.textColor = .white
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 0
		return descriptionLabel
	}()
	private func setupUI(){
		view.backgroundColor = UIColor(red: 0.5, green: 0.75, blue: 0.5, alpha: 1.0)
		view.addSubview(spinner)
		view.addSubview(pendingLabel)
		view.addSubview(descriptionLabel)
		
		spinner.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(-80)
			make.width.height.equalTo(50)
		}
		pendingLabel.snp.makeConstraints { make in
			make.top.equalTo(spinner.snp.bottom).offset(30)
			make.centerX.equalToSuperview()
		}
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(pendingLabel.snp.bottom).offset(10)
			make.leading.equalTo(view).offset(16)
			make.trailing.equalTo(view).offset(-16)
		}
	}
}
