# swe-a-star-team

FarmFlow is a comprehensive system which represents web and mobile application designed to allow ordering of desired products in the most convinient way for buyers, whilst farmers can sell their products and effectively manage their sales. It facilitates product search, delivery and payment management, communication between buyers and farmers, and orders and sales reporting, aiming to streamline agricultural commerce and foster a direct-to-consumer ecosystem.

## Features

- [Features](#features)
  - [General Features](#General-features)
  - [Admin Interface](#Admin-intergace)
    - [Admin Dashboard](#Admin-dashboard)
    - [List of all Buyers](#List-of-all-buyers)
    - [List of Farmers](#List-of-farmers)
  - [Farmer Interface](#Farmer-interface)
  - [Buyer Interface](#Buyer-interface)
- [Demo](#demo)
- [Tech stack](#tech-stack)
  
# Features
## General Features
Multi-platform Access: Web-based admin interface and mobile applications for farmers and buyers.
Role-Based Access: Separate functionalities for administrators, farmers, and buyers.
Real-time Synchronization: Consistent experience across web and mobile platforms.

FarmFlow mobile application offers a role-based authentication, where users can choose to be Farmer or Buyer.

## Admin Interface
* List Manage user accounts:Farmers and Buyers.
* List Review and approve/reject farmer registrations.
* List View, edit, and deactivate user accounts.
* List Oversee product listings and marketplace activities.

## Admin Dashboard

Admin dashboard after login.

Admin can view list of all users and their account details.

Admins can edited any user entries.

## List of all Buyers

Admin can view all buyers in a list

## List of Farmers

Admins may approve or reject newly registered farmers with a single click.

List of pending farmers

Admin may specify a reason in case of farmer reject.

After rejecting the "Reject" form, admin is redirected back to the "Pending Farmer" page.

List of approved farmers.

List of rejected farmers.

## Farmer Interface

* List List products with detailed descriptions and images.
* List Update and remove product details in real time.
* List Track sales and performance metrics.

Farmers can register and specify farm details.

After registration as a farmer, you will see the "Pending Approval" page. As soon as admin will review and approve your registration, you will be redirected to the "Farmer's Home Page".

In the Farmer's Home page, you can add the products and corresponding details. You can provide name, specify the category and upload images of your product.

In "Orders Page" you will see the history of old and new incoming orders. In the upper right crner of the new order's window, you may see the bargain offer incoming from a buyer. Farmers may accept or reject bargain offers.

## Buyer Interface

* List Browse and search for products by categories, price, or farm brand.
* List Filter and sort products to refine searches.
* List View detailed product descriptions, images, and seller information.

Buyers can view all the products currently available grouped by the categories. After choosing a category, you can see the products with pricing and farm name details.

Buyers can browse for a product by its category, price, or farm brand.

The search bar allows product filtering and sorting.

## Demo



## Tech stack

- **Backend** : Django
- **Frontend(Web)**: Django 
- **Mobile Application** UIkit
- **Database** PostgreSQL
- **APIs**: RESTful APIs for backend communication
