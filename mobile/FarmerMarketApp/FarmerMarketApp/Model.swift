//
//  Model.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 11.11.2024.
//

import Foundation

// MARK: - User Model
struct User: Codable {
	let first_name: String
	let last_name: String
	let email: String
	let phone_number: String
	let password: String

	enum CodingKeys: String, CodingKey {
		case first_name
		case last_name
		case email
		case phone_number
		case password
	}
}


// MARK: - Buyer Model
struct Buyer: Codable {
	let user: User
	let deliveryAddress: String

	enum CodingKeys: String, CodingKey {
		case user
		case deliveryAddress = "deliveryAdress"
	}
}

// MARK: - Farmer Model
struct Farmer: Codable {
	let id: Int?
	let user: User
	let Fname: String

	enum CodingKeys: String, CodingKey {
		case id
		case user
		case Fname
	}
}

// MARK: - OTP Model
struct OTP: Codable {
	let email: String
	let otp: String
}

// MARK: - Category Model
struct Category: Codable {
	let id: Int
	let name: String
	let description: String?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case description
	}
}

// MARK: - Farm Model
struct Farm: Codable {
	let farmerId: Int
	let farmName: String
	let farmPassport: String
	let farmLocation: String?

	enum CodingKeys: String, CodingKey {
		case farmerId = "farmer_id"
		case farmName = "farm_name"
		case farmPassport = "farm_passport"
		case farmLocation = "farm_location"
	}
}

// MARK: - Product Model
struct Product {
	let name: String
	let price: Double
	let quantity: Int 
	let category: String
	let description: String
	let imageName: String
}

// MARK: - Inventory Model
struct Inventory: Codable {
	let farmId: Int
	let productId: Int
	let quantity: Int
	let availability: Bool

	enum CodingKeys: String, CodingKey {
		case farmId = "farm_id"
		case productId = "product_id"
		case quantity
		case availability
	}
}

// MARK: - Cart Model
struct Cart: Codable {
	let buyerId: Int
	let createdDate: String
	let cartStatus: String

	enum CodingKeys: String, CodingKey {
		case buyerId = "buyer_id"
		case createdDate = "created_date"
		case cartStatus = "cart_status"
	}
}

// MARK: - CartItem Model
struct CartItem: Codable {
	let cartId: Int
	let productId: Int
	let quantity: Int
	let pricePerUnit: Decimal
	let verified: Bool
	let adminId: Int?

	enum CodingKeys: String, CodingKey {
		case cartId = "cart_id"
		case productId = "product_id"
		case quantity
		case pricePerUnit = "price_per_unit"
		case verified
		case adminId = "admin_id"
	}
}

struct SignInResponse: Decodable {
	struct User: Decodable {
		let firstName: String
		let lastName: String
		let email: String
		let role: String
		let phoneNumber: String
	}
	let user: User
	let buyer: Buyer?
	let farmer: Farmer?
}
