from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")
db = client["badminton_store"]

print("Sản phẩm bán chạy nhất:")
pipeline = [
    {"$unwind": "$products"},
    {"$group": {"_id": "$products.product_id", "total_sold": {"$sum": "$products.qty"}}},
    {"$sort": {"total_sold": -1}},
    {"$limit": 1},
    {"$lookup": {
        "from": "products",
        "localField": "_id",
        "foreignField": "_id",
        "as": "product"
    }},
    {"$unwind": "$product"}
]
for row in db.bills.aggregate(pipeline):
    print(row)
