from pymongo import MongoClient

client = MongoClient("mongodb://26.73.81.60:27017")  # Đổi IP nếu dùng mongos trên máy khác
db = client["badminton_store"]

print("\nTop 3 sản phẩm giá cao nhất của mỗi chi nhánh:")
pipeline = [
    # Join inventory với products để lấy giá
    {
        "$lookup": {
            "from": "products",
            "localField": "product_id",
            "foreignField": "_id",
            "as": "product"
        }
    },
    {"$unwind": "$product"},
    # Nhóm theo branch_id và product_id để loại trùng sản phẩm ở 1 chi nhánh (nếu có)
    {
        "$group": {
            "_id": {"branch_id": "$branch_id", "product_id": "$product_id"},
            "name": {"$first": "$product.name"},
            "price": {"$first": "$product.price"},
            "quantity": {"$sum": "$quantity"}
        }
    },
    # Sắp xếp theo branch và price giảm dần
    {"$sort": {"_id.branch_id": 1, "price": -1}},
    # Gom lại thành từng nhóm chi nhánh, push từng sản phẩm vào mảng
    {
        "$group": {
            "_id": "$_id.branch_id",
            "products": {
                "$push": {
                    "product_id": "$_id.product_id",
                    "name": "$name",
                    "price": "$price",
                    "quantity": "$quantity"
                }
            }
        }
    },
    # Lấy top 3 của mỗi chi nhánh
    {
        "$project": {
            "products": {"$slice": ["$products", 3]}
        }
    }
]
for row in db.inventory.aggregate(pipeline):
    print(f"Chi nhánh {row['_id']}:")
    for prod in row["products"]:
        print("  ", prod)
