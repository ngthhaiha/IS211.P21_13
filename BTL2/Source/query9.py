from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

print("\nHóa đơn chưa thanh toán của chi nhánh 2:")
for bill in db.bills.find({"status": "Chưa thanh toán", "branch_id": 2}):
    print(bill)
