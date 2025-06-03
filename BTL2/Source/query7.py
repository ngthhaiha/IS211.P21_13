from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

print("\nTồn kho của từng sản phẩm ở từng chi nhánh:")
pipeline = [
    {"$group": {
        "_id": {"product_id": "$product_id", "branch_id": "$branch_id"},
        "quantity": {"$sum": "$quantity"}
    }},
    {"$lookup": {
        "from": "products",
        "localField": "_id.product_id",
        "foreignField": "_id",
        "as": "product"
    }},
    {"$unwind": "$product"},
    {"$project": {
        "branch_id": "$_id.branch_id",
        "product_id": "$_id.product_id",
        "name": "$product.name",
        "quantity": 1
    }},
    {"$sort": {"branch_id": 1, "quantity": -1}}
]
for row in db.inventory.aggregate(pipeline):
    print(row)
