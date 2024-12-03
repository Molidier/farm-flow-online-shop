//
//  ChatFarmerViewController.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 21.11.2024.
//

//
//  FarmerChatsViewController.swift
//  FarmerMarketApp
//

import UIKit
import SnapKit

class ChatFarmerViewController: UIViewController {
	private var chats: [Chat] = [] // Store list of chats
	private let tableView = UITableView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "Chats"
		setupUI()
		fetchChats()
	}
	
	private func setupUI() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	private func fetchChats() {
		NetworkManager.shared.fetchFarmerChats { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success(let chats):
					self?.chats = chats
					self?.tableView.reloadData()
				case .failure(let error):
					print("Failed to fetch chats: \(error)")
				}
			}
		}
	}
}

extension ChatFarmerViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return chats.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
		let chat = chats[indexPath.row]
		cell.textLabel?.text = "Chat with \(chat.buyerName)"
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let chat = chats[indexPath.row]
		let chatVC = ChatsBuyerViewController() 
		chatVC.chatID = chat.id
		navigationController?.pushViewController(chatVC, animated: true)
	}
}
