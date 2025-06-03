from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")
db = client["badminton_store"]

print("Khách hàng có nhiều hóa đơn nhất:")
pipeline = [
    {"$group": {"_id": "$customer_id", "count": {"$sum": 1}}},
    {"$sort": {"count": -1}},
    {"$limit": 1},
    {"$lookup": {
        "from": "customers",
        "localField": "_id",
        "foreignField": "_id",
        "as": "customer"
    }},
    {"$unwind": "$customer"}
]
for row in db.bills.aggregate(pipeline):
    print(row)
