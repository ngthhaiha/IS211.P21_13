from pymongo import MongoClient

# Kết nối MongoDB
client = MongoClient("mongodb://26.73.81.60:27017")
db = client["badminton_store"]

# Đọc products
print("Danh sách products:")
for doc in db.products.find():
    print(doc)

# Đọc customers
print("\nDanh sách customers:")
for doc in db.customers.find():
    print(doc)

# Đọc employees
print("\nDanh sách employees:")
for doc in db.employees.find():
    print(doc)

# Đọc inventory
print("\nDanh sách inventory:")
for doc in db.inventory.find():
    print(doc)

# Đọc bills
print("\nDanh sách bills:")
for doc in db.bills.find():
    print(doc)

client.close()
