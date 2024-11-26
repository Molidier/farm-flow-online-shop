//
//  OrdersFarmerViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 21.11.2024.
//

import UIKit
import SnapKit

class OrdersFarmerViewController: UIViewController {
	private let greetingLabel: UILabel = {
		let label = UILabel()
		label.text = "All orders"
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		label.textColor = .black
		return label
	}()
	
	private let navigationTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Order History"
		label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .white
		return label
	}()
	
	private let notificationButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "bell"), for: .normal)
		button.tintColor = .white
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	private func setupView() {
		view.backgroundColor = .white
		
		setupNavigationBar()
		setupGreetingLabel()
	}
	
	private func setupNavigationBar() {
		let navBarView = UIView()
		navBarView.backgroundColor = UIColor(red: 34/255, green: 73/255, blue: 47/255, alpha: 1)

		view.addSubview(navBarView)
		navBarView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(70)
		}

		navBarView.addSubview(navigationTitleLabel)
		navigationTitleLabel.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.leading.equalToSuperview().offset(16)
		}

		navBarView.addSubview(notificationButton)
		notificationButton.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.trailing.equalToSuperview().offset(-16)
		}
	}

	
	private func setupGreetingLabel() {
		view.addSubview(greetingLabel)
		greetingLabel.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
			make.leading.equalToSuperview().offset(16)
		}
	}
}
