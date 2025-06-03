from pymongo import MongoClient
from datetime import datetime, timedelta
import random

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

# Xóa sạch cũ (chỉ khi bạn test lại nhiều lần)
db.products.delete_many({})
db.customers.delete_many({})
db.employees.delete_many({})
db.inventory.delete_many({})
db.bills.delete_many({})

# Sản phẩm
product_names = [
    ("Vợt Yonex Astrox 88D", "Yonex", "attack"),
    ("Vợt Victor Brave Sword 12", "Victor", "defense"),
    ("Vợt Lining Turbo Charging", "Lining", "attack"),
    ("Quả cầu RSL", "RSL", "shuttlecock"),
    ("Giày Mizuno Wave", "Mizuno", "shoes"),
    ("Quả cầu Vina Star", "Vina", "shuttlecock"),
    ("Vợt ProAce Stroke 318", "ProAce", "allround"),
    ("Vợt Apacs Virtuoso", "Apacs", "allround"),
    ("Giày Yonex Eclipsion Z", "Yonex", "shoes"),
    ("Vợt Fleet Triotec", "Fleet", "attack")
]
products = []
for i, (name, brand, type_) in enumerate(product_names, 1):
    products.append({
        "_id": i,
        "name": name,
        "brand": brand,
        "type": type_,
        "price": random.randint(600000, 2500000),
        "warranty_months": random.choice([0, 6, 12])
    })
db.products.insert_many(products)

# Thêm 300 khách hàng
cities = ["Hà Nội", "Đà Nẵng", "Hải Phòng", "Hồ Chí Minh", "Cần Thơ", "Nghệ An", "Bắc Giang", "Huế", "Quảng Nam"]
customers = []
for i in range(1, 301):
    customers.append({
        "_id": i,
        "name": f"Khách hàng {i}",
        "phone": "09" + ''.join(str(random.randint(0,9)) for _ in range(8)),
        "dob": f"19{random.randint(70, 99)}-{random.randint(1,12):02d}-{random.randint(1,28):02d}",
        "address": random.choice(cities)
    })
db.customers.insert_many(customers)

# Thêm 10 nhân viên (2 chi nhánh)
employees = []
for i in range(1, 11):
    employees.append({
        "_id": 100 + i,
        "name": f"Nhân viên {i}",
        "position": random.choice(["Quản lý", "Bán hàng", "Thu ngân"]),
        "branch_id": random.choice([1, 2]),
        "phone": "09" + ''.join(str(random.randint(0,9)) for _ in range(8))
    })
db.employees.insert_many(employees)

# Tồn kho (mỗi chi nhánh mỗi loại sản phẩm đều có, số lượng random)
inventory = []
for branch in [1,2]:
    for prod in range(1, 11):
        inventory.append({
            "_id": branch * 1000 + prod,
            "product_id": prod,
            "quantity": random.randint(5, 60),   
            "branch_id": branch,
            "last_update": datetime.now()
        })
db.inventory.insert_many(inventory)

# Tạo 500 hóa đơn (mỗi hóa đơn 1-4 sản phẩm, khách hàng và nhân viên random)
bills = []
for i in range(1, 501):
    cust_id = random.randint(1, 300)
    emp_id = random.choice([x["_id"] for x in employees])
    branch_id = random.choice([1, 2])
    products_list = []
    total = 0
    n_products = random.randint(1, 4)
    prods_used = random.sample(range(1, 11), n_products)
    for prod_id in prods_used:
        qty = random.randint(1, 7)
        price = next(x['price'] for x in products if x['_id'] == prod_id)
        products_list.append({"product_id": prod_id, "qty": qty, "price": price})
        total += price * qty
    bill_date = datetime(2023, random.randint(1,12), random.randint(1,28), random.randint(7,20), random.randint(0,59))
    bills.append({
        "_id": 10000 + i,
        "customer_id": cust_id,
        "employee_id": emp_id,
        "products": products_list,
        "total": total,
        "date": bill_date,
        "status": random.choice(["Đã thanh toán", "Chưa thanh toán"]),
        "branch_id": branch_id
    })
db.bills.insert_many(bills)

print("ĐÃ TẠO 300 KHÁCH HÀNG, 500 HÓA ĐƠN VÀ NHIỀU DỮ LIỆU KHÁC!")
