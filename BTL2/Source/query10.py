from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

product_ids = set(p["_id"] for p in db.products.find())
pipeline = [
    {"$unwind": "$products"},
    {"$group": {
        "_id": "$customer_id",
        "purchased_products": {"$addToSet": "$products.product_id"}
    }},
    {"$project": {
        "all_products": {"$setEquals": ["$purchased_products", list(product_ids)]}
    }},
    {"$match": {"all_products": True}},
    {"$lookup": {
        "from": "customers",
        "localField": "_id",
        "foreignField": "_id",
        "as": "customer"
    }},
    {"$unwind": "$customer"}
]
print("Danh sách khách hàng đã mua toàn bộ sản phẩm:")
for row in db.bills.aggregate(pipeline):
    print(row["customer"])
