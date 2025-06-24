# List of creted items for InventoryManger to use in source code: MIT License
# @author Vladimir Petrenko
@tool
class_name InventoryManagerItem


enum ItemEnum { NONE,  HealthBig_2D, HealthBig_3D, Health_2D, Health_3D}

const HEALTHBIG_2D = "2fab9287-821f-4d81-8eb2-a7523c19db14"
const HEALTHBIG_3D = "f08dc85a-ef0a-4158-9af5-0b845b265709"
const HEALTH_2D = "29e273d0-c864-4f32-8511-923ba53a0399"
const HEALTH_3D = "6550b66f-7b71-4737-b2d1-f70fe102d6b8"

const ITEMS = [
 "HealthBig_2D",
 "HealthBig_3D",
 "Health_2D",
 "Health_3D"
]

static func item_by_enum(item_enum: ItemEnum) -> String:
	match item_enum:
		ItemEnum.HealthBig_2D:
			return InventoryManagerItem.HEALTHBIG_2D
		ItemEnum.HealthBig_3D:
			return InventoryManagerItem.HEALTHBIG_3D
		ItemEnum.Health_2D:
			return InventoryManagerItem.HEALTH_2D
		ItemEnum.Health_3D:
			return InventoryManagerItem.HEALTH_3D
		_:
			return ""
