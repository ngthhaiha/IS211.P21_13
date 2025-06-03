from pymongo import MongoClient
client = MongoClient("mongodb://26.73.81.60:27017")  
db = client["badminton_store"]

print("Khách hàng đã mua 'Vợt Lining Turbo Charging' ở CN1 nhưng chưa từng mua ở CN2:")

# 1. Lấy id sản phẩm
product = db.products.find_one({"name": "Vợt Lining Turbo Charging"})
if product:
    product_id = product["_id"]
    # 2. Danh sách KH đã mua sp này ở CN1
    cust_c1 = set(db.bills.distinct("customer_id", {"products.product_id": product_id, "branch_id": 1}))
    # 3. Danh sách KH đã mua sp này ở CN2
    cust_c2 = set(db.bills.distinct("customer_id", {"products.product_id": product_id, "branch_id": 2}))
    # 4. Lấy KH chỉ có ở CN1 mà không có ở CN2
    only_cn1 = cust_c1 - cust_c2
    # 5. In thông tin KH này
    for c in db.customers.find({"_id": {"$in": list(only_cn1)}}):
        print(c)
else:
    print("Không tìm thấy sản phẩm này.")
