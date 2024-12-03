//
//  Model.swift
//  FarmerMarketApp
//
//  Created by Saltanat on 11.11.2024.
//

import Foundation
import UIKit

// MARK: - Login Response
struct LoginResponse: Codable {
	let message: String
	let access: String
	let refresh: String
	let api_token: String
	let user: UserWrapper
}

// MARK: - User Wrapper
struct UserWrapper: Codable {
	let id: Int?
	let user: User
	let Fname: String?
	let farm_location: String?
	let farm_size: String?
	let deliveryAdress: String?
}

// MARK: - User Model
struct User: Codable {
	let id: Int?
	let first_name: String
	let last_name: String
	let email: String
	let phone_number: String
	let password: String?
	let role: String
	let image: String?
}

// MARK: - Buyer Model
struct Buyer: Codable {
	let id: Int?
	let user: User
	let deliveryAddress: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case user
		case deliveryAddress = "deliveryAdress"
	}
}

// MARK: - Farmer Model
struct Farmer: Codable {
	let id: Int?
	let user: User
	let Fname: String
	let farm_location: String
	let farm_size: String
}

// MARK: - OTP Model
struct OTP: Codable {
	let email: String
	let otp: String
}

// MARK: - Category Model
struct CategoriesResponse: Codable {
	let categories: [Category]
}

struct Category: Codable {
	let id: Int
	let name: String
	let description: String
}


// MARK: - Product Model
struct Product: Codable {
	let farmer: Int
	let category: Int
	let name: String
	let price: Double
	let description: String
	let quantity: Int
	let image: Data?
}

struct Products: Codable {
	let id: Int
	let category: String
	let name: String
	var price: Double
	let description: String
	var quantity: Int
	let imageName: String
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
	let product: Products
	var quantity: Int
}

class CartManager {
	static let shared = CartManager()

	private(set) var cart: [CartItem] = []

	private init() {
		loadCart()
	}

	func addToCart(product: Products, quantity: Int) {
		guard let productIndex = MockData.shared.sampleProducts.firstIndex(where: { $0.id == product.id }) else { return }

		if MockData.shared.sampleProducts[productIndex].quantity >= quantity {
			if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
				cart[index].quantity += quantity
			} else {
				cart.append(CartItem(product: product, quantity: quantity))
			}
			saveCart() // Save the cart to persist changes
		}
	}

	func removeFromCart(productId: Int) {
		cart.removeAll { $0.product.id == productId }
		saveCart() // Save the cart to persist changes
	}

	func getCartItems() -> [CartItem] {
		return cart
	}

	func clearCart() {
		cart.removeAll()
		saveCart() // Clear persistent storage
	}

	private func saveCart() {
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(cart) {
			UserDefaults.standard.set(data, forKey: "cartItems")
		}
	}

	private func loadCart() {
		let decoder = JSONDecoder()
		if let data = UserDefaults.standard.data(forKey: "cartItems"),
		   let savedCart = try? decoder.decode([CartItem].self, from: data) {
			cart = savedCart
		}
	}
}



struct OrderDetails: Codable {
	let farmerId: Int
	let products: [OrderProduct]
	let totalPrice: Double
	let deliveryOption: String
}


struct OrderProduct: Codable {
	let name: String
	let quantity: Int
	let price: Double
}

class OrderManager {
	static let shared = OrderManager()
	
	private(set) var buyerOrders: [OrderDetails] = []
	private(set) var farmerOrders: [OrderDetails] = []
	
	private init() {
		loadOrders()
	}

	func addOrder(_ order: OrderDetails) {
		buyerOrders.append(order)
		farmerOrders.append(order)
		saveOrders()
	}
	
	func getFarmerOrders(for farmerId: Int) -> [OrderDetails] {
		return farmerOrders.filter { $0.farmerId == farmerId }
	}
	
	private func saveOrders() {
		let encoder = JSONEncoder()
		if let buyerData = try? encoder.encode(buyerOrders),
		   let farmerData = try? encoder.encode(farmerOrders) {
			UserDefaults.standard.set(buyerData, forKey: "buyerOrders")
			UserDefaults.standard.set(farmerData, forKey: "farmerOrders")
		}
	}
	
	private func loadOrders() {
		let decoder = JSONDecoder()
		if let buyerData = UserDefaults.standard.data(forKey: "buyerOrders"),
		   let farmerData = UserDefaults.standard.data(forKey: "farmerOrders") {
			buyerOrders = (try? decoder.decode([OrderDetails].self, from: buyerData)) ?? []
			farmerOrders = (try? decoder.decode([OrderDetails].self, from: farmerData)) ?? []
		}
	}
}

class BargainManager {
	static let shared = BargainManager()

	private var bargainRequests: [BargainRequest] = []

	func addBargainRequest(bargain: BargainRequest) {
		bargainRequests.append(bargain)
	}

	func getBargainRequests() -> [BargainRequest] {
		return bargainRequests
	}

	func acceptBargain(bargain: BargainRequest) {
		if let index = MockData.shared.sampleProducts.firstIndex(where: { $0.id == bargain.productId }) {
			MockData.shared.sampleProducts[index].price = bargain.suggestedPrice
		}
		bargainRequests.removeAll { $0 == bargain }
	}


	func declineBargain(bargain: BargainRequest) {
		bargainRequests.removeAll { $0 == bargain }
	}
}

struct BargainRequest: Equatable {
	let productId: Int
	let suggestedPrice: Double
	let originalPrice: Double
	
	// Conformance to Equatable
	static func == (lhs: BargainRequest, rhs: BargainRequest) -> Bool {
		return lhs.productId == rhs.productId &&
			   lhs.suggestedPrice == rhs.suggestedPrice &&
			   lhs.originalPrice == rhs.originalPrice
	}
}


class MockData {
	static let shared = MockData()
	
	private let productsKey = "sampleProducts"
	
	private init() {
		loadProducts()
	}
	
	var sampleProducts: [Products] = [] {
		didSet {
			saveProducts()
		}
	}
	
	private func saveProducts() {
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(sampleProducts) {
			UserDefaults.standard.set(data, forKey: productsKey)
		}
	}
	
	private func loadProducts() {
		let decoder = JSONDecoder()
		if let data = UserDefaults.standard.data(forKey: productsKey),
		   let products = try? decoder.decode([Products].self, from: data) {
			sampleProducts = products
		} else {
			// Initialize with default products if no data exists
			sampleProducts = [
				Products(id: 1, category: "Fruits", name: "Apple", price: 700, description: "Fresh and juicy apples.", quantity: 10, imageName: "apple"),
				Products(id: 2, category: "Fruits", name: "Banana", price: 1000, description: "Sweet and ripe bananas.", quantity: 20, imageName: "banana"),
				Products(id: 3, category: "Fruits", name: "Orange", price: 2000, description: "Citrusy and refreshing oranges.", quantity: 20, imageName: "orange"),
				Products(id: 13, category: "Fruits", name: "Grape", price: 3000, description: "Fresh grapes.", quantity: 0, imageName: "grape"),
				
				// Vegetables
				Products(id: 4, category: "Vegetables", name: "Potato", price: 300, description: "Fresh potatoes, perfect for cooking.", quantity: 20, imageName: "potato"),
				Products(id: 5, category: "Vegetables", name: "Tomato", price: 600, description: "Red and ripe tomatoes.", quantity: 20, imageName: "tomato"),
				Products(id: 6, category: "Vegetables", name: "Carrot", price: 500, description: "Crunchy and sweet carrots.", quantity: 30, imageName: "carrot"),
				
				// Grains
				Products(id: 7, category: "Grains", name: "Wheat", price: 250, description: "High-quality wheat for baking and cooking.", quantity: 50, imageName: "wheat"),
				Products(id: 8, category: "Grains", name: "Rice", price: 400, description: "Premium long-grain rice, ideal for all dishes.", quantity: 100, imageName: "rice"),
				Products(id: 9, category: "Grains", name: "Barley", price: 350, description: "Nutritious barley grains for soups and salads.", quantity: 40, imageName: "barley"),
				
				// Dairy
				Products(id: 10, category: "Dairy", name: "Milk", price: 200, description: "Fresh cow milk, full of nutrients.", quantity: 30, imageName: "milk"),
				Products(id: 11, category: "Dairy", name: "Cheese", price: 800, description: "Delicious cheddar cheese, perfect for sandwiches.", quantity: 15, imageName: "cheese"),
				Products(id: 12, category: "Dairy", name: "Yogurt", price: 300, description: "Creamy and healthy yogurt for all ages.", quantity: 20, imageName: "yogurt")
			]
		}
	}
}




// MARK: - Chat Model
struct Chat: Codable {
	let id: Int
	let farmer: Int
	let buyer: Int
	let farmerName: String
	let buyerName: String
	let createdAt: String
	
	enum CodingKeys: String, CodingKey {
		case id, farmer, buyer
		case farmerName = "farmer_name"
		case buyerName = "buyer_name"
		case createdAt = "created_at"
	}
}

// MARK: - Message Model
struct Message: Codable {
	let id: Int
	let chat: Int
	let sender: Int
	let senderName: String
	let message: String?
	let attachment: String?
	let timestamp: String
	
	enum CodingKeys: String, CodingKey {
		case id, chat, sender
		case senderName = "sender_name"
		case message, attachment, timestamp
	}
}


