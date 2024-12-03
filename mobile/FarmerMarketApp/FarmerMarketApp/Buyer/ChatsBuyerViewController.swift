//
//  ChatsBuyerViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 23.11.2024.
//

import UIKit
import SnapKit

class ChatsBuyerViewController: UIViewController {
	private var messages: [Message] = []
	private let tableView = UITableView()
	private let messageInputView = UIView()
	private let messageTextField = UITextField()
	private let sendButton = UIButton(type: .system)
	var chatID: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		fetchMessages()
	}
	
	private func setupUI() {
		view.backgroundColor = .white
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.left.right.equalToSuperview()
			make.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
		}
		
		messageInputView.backgroundColor = .lightGray
		view.addSubview(messageInputView)
		messageInputView.snp.makeConstraints { make in
			make.left.right.bottom.equalToSuperview()
			make.height.equalTo(60)
		}
		
		messageTextField.placeholder = "Write a message..."
		messageTextField.borderStyle = .roundedRect
		messageInputView.addSubview(messageTextField)
		messageTextField.snp.makeConstraints { make in
			make.left.top.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
			make.right.equalToSuperview().inset(80)
		}
		
		sendButton.setTitle("Send", for: .normal)
		sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
		messageInputView.addSubview(sendButton)
		sendButton.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(10)
			make.width.equalTo(60)
		}
	}
	
	private func fetchMessages() {
		NetworkManager.shared.fetchMessages(for: chatID) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success(let messages):
					self?.messages = messages
					self?.tableView.reloadData()
				case .failure(let error):
					print("Failed to fetch messages: \(error)")
				}
			}
		}
	}
	
	@objc private func sendMessage() {
		guard let text = messageTextField.text, !text.isEmpty else { return }
		
		NetworkManager.shared.sendMessage(chatID: chatID, message: text) { [weak self] success in
			if success {
				self?.fetchMessages()
				DispatchQueue.main.async {
					self?.messageTextField.text = ""
				}
			} else {
				print("Failed to send message")
			}
		}
	}
}

extension ChatsBuyerViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
		let message = messages[indexPath.row]
		cell.textLabel?.text = "\(message.senderName): \(message.message ?? "")"
		return cell
	}
}
