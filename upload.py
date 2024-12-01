import requests

# API URL where you're sending the POST request
url = 'http://127.0.0.1:8000/users/register/farmer/'  # Replace with your API URL

# Open the image file in binary mode
image_path = r"C:\Users\user\Pictures\Обои\5oPLsu.jpg"  # Make sure the path is correct
image_file = open(image_path, "rb")

# Data to send in JSON format (excluding the image)
data = {
    "user": {
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example.com",
        "phone_number": "87776665544",
        "password": "123123"
    },
    "Fname": "John's Farm",
    "farm_location": "123 Farm Road",
    "farm_size": 50
}

# Files to upload (image as a file)
files = {
    "user[image]": image_file  # Sending the image with the key 'user[image]'
}

# Send the request to the API
response = requests.post(url, data=data, files=files)

# Check the response status
if response.status_code == 201:
    print("Profile created successfully!")
    print(response.json())  # Print the response from the server (JSON)
else:
    print(f"Error: {response.status_code}")
    print(response.text)  # Print the error message
