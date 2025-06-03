from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

print("Tồn kho chỉ có ở CN1 mà không có ở CN2:")
# Tìm product_id có ở branch_id=1 nhưng không có ở branch_id=2
products_cn1 = set([x['product_id'] for x in db.inventory.find({"branch_id": 1})])
products_cn2 = set([x['product_id'] for x in db.inventory.find({"branch_id": 2})])
only_cn1 = products_cn1 - products_cn2
for inv in db.inventory.find({"branch_id": 1, "product_id": {"$in": list(only_cn1)}}):
    print(inv)
