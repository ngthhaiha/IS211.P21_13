from pymongo import MongoClient
 
# Kết nối MongoDB (thay IP nếu cần)
client = MongoClient("mongodb://26.73.81.60:27017")
 
# Chọn database
db = client["badminton_store"]
 
# Xóa từng collection (nếu tồn tại)
db.products.drop()
db.customers.drop()
db.employees.drop()
db.inventory.drop()
db.bills.drop()
 
print("Đã xóa toàn bộ collections!")