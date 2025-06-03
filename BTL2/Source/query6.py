from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  
db = client["badminton_store"]

print("\nSố lượng hóa đơn của từng nhân viên:")
pipeline = [
    {"$group": {"_id": "$employee_id", "num_bills": {"$sum": 1}}},
    {"$sort": {"num_bills": -1}},
    {"$lookup": {
        "from": "employees",
        "localField": "_id",
        "foreignField": "_id",
        "as": "employee"
    }},
    {"$unwind": "$employee"}
]
for row in db.bills.aggregate(pipeline):
    print(row)
