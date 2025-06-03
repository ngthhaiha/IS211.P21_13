from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")
db = client["badminton_store"]

# Update tên sản phẩm
db.products.update_one(
    {"_id": 1},
    {"$set": {"name": "Vợt Yonex Astrox 88D Pro"}}
)