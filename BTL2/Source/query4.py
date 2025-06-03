from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

print("Danh sách khách hàng có hóa đơn ở cả 2 chi nhánh:")

pipeline = [
    {
        "$group": {
            "_id": "$customer_id",
            "branches": {"$addToSet": "$branch_id"}
        }
    },
    {
        "$match": {
            "branches": {"$all": [1, 2]}
        }
    },
    {
        "$lookup": {
            "from": "customers",
            "localField": "_id",
            "foreignField": "_id",
            "as": "customer"
        }
    },
    {
        "$unwind": "$customer"
    }
]

for row in db.bills.aggregate(pipeline):
    print(row["customer"])
