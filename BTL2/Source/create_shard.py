from pymongo import MongoClient

# Kết nối MongoDB (thay connection string của bạn)
client = MongoClient("mongodb://26.73.81.60:27017")

# Chọn database
db = client["badminton_store"]

# Tạo các collection (tạo trước, giống SQL "CREATE TABLE")
db.create_collection("products")
db.create_collection("customers")
db.create_collection("employees")
db.create_collection("inventory")
db.create_collection("bills")

print("Đã tạo toàn bộ collections!")
