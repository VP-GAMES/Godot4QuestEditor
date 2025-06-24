# Inventory data for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name InventoryData

# ***** EDITOR_PLUGIN *****
var _editor
var _undo_redo

func editor():
	return _editor

func set_editor(editor) -> void:
	_editor = editor
	for inventory in inventories:
		inventory.set_editor(_editor)
	for type in types:
		type.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/inventory_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

const default_path = "res://inventory/"

# ***** LOCALIZATION *****
var _locale

signal locale_changed(locale)

func get_locale() -> String:
	_locale = setting_dialogue_editor_locale()
	if _locale == null:
		_locale = TranslationServer.get_locale()
	return _locale

func set_locale(locale: String) -> void:
	_locale = locale
	setting_dialogue_editor_locale_put(_locale)
	TranslationServer.set_locale(_locale)
	locale_changed.emit(_locale)

# ***** INVENTORY *****
signal inventory_added(inventory)
signal inventory_removed(inventory)
signal inventory_selection_changed(inventory)
signal inventory_stacks_changed(inventory)
signal inventory_icon_changed(inventory)
signal inventory_scene_changed(inventory)

func emit_inventory_stacks_changed(inventory: InventoryInventory) -> void:
	inventory_stacks_changed.emit(inventory)

func emit_inventory_icon_changed(inventory: InventoryInventory) -> void:
	inventory_icon_changed.emit(inventory)

func emit_inventory_scene_changed(inventory: InventoryInventory) -> void:
	inventory_scene_changed.emit(inventory)

@export var inventories: Array = [_create_inventory()]
var _inventory_selected: InventoryInventory

func add_inventory(sendSignal = true) -> void:
	var inventory = _create_inventory()
	if _undo_redo != null:
		_undo_redo.create_action("Add inventory")
		_undo_redo.add_do_method(self, "_add_inventory", inventory)
		_undo_redo.add_undo_method(self, "_del_inventory", inventory)
		_undo_redo.commit_action()
	else:
		_add_inventory(inventory, sendSignal)

func _create_inventory() -> InventoryInventory:
	var inventory = InventoryInventory.new()
	inventory.set_editor(_editor)
	inventory.uuid = UUID.v4()
	inventory.name = _next_inventory_name()
	return inventory

func _next_inventory_name() -> String:
	var base_name = "Inventory"
	var value = -9223372036854775807
	var inventory_found = false
	if inventories:
		for inventory in inventories:
			var name = inventory.name
			if name.begins_with(base_name):
				inventory_found = true
				var behind = inventory.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif inventory_found:
		next_name += "1"
	return next_name

func _add_inventory(inventory: InventoryInventory, sendSignal = true, position = inventories.size()) -> void:
	if inventories == null:
		inventories = []
	inventories.insert(position, inventory)
	inventory_added.emit(inventory)
	select_inventory(inventory)

func del_inventory(inventory) -> void:
	if _undo_redo != null:
		var index = inventories.find(inventory)
		_undo_redo.create_action("Del inventory")
		_undo_redo.add_do_method(self, "_del_inventory", inventory)
		_undo_redo.add_undo_method(self, "_add_inventory", inventory, false, index)
		_undo_redo.commit_action()
	else:
		_del_inventory(inventory)

func _del_inventory(inventory) -> void:
	var index = inventories.find(inventory)
	if index > -1:
		inventories.remove_at(index)
		inventory_removed.emit(inventory)
		_inventory_selected = null
		var inventory_selected = selected_inventory()
		select_inventory(inventory_selected)

func selected_inventory() -> InventoryInventory:
	if _inventory_selected == null and not inventories.is_empty():
		_inventory_selected = inventories[0]
	return _inventory_selected

func select_inventory(inventory: InventoryInventory) -> void:
	_inventory_selected = inventory
	inventory_selection_changed.emit(_inventory_selected)

func get_inventory_by_uuid(uuid: String) -> InventoryInventory:
	for inventory in inventories:
		if inventory != null and inventory.uuid != null and inventory.uuid == uuid:
			return inventory
	return null

func get_inventory_by_name(inventory_name: String) -> InventoryInventory:
	for inventory in inventories:
		if inventory.name == inventory_name:
			return inventory
	return null

# ***** TYPE *****
signal type_added(type)
signal type_removed(type)
signal type_selection_changed(type)
signal type_icon_changed(item)

func emit_type_icon_changed(type: InventoryType) -> void:
	type_icon_changed.emit(type)

@export var types: Array = [_create_type()]
var _type_selected: InventoryType

func add_type(sendSignal = true) -> void:
	var type = _create_type()
	if _undo_redo != null:
		_undo_redo.create_action("Add type")
		_undo_redo.add_do_method(self, "_add_type", type)
		_undo_redo.add_undo_method(self, "_del_type", type)
		_undo_redo.commit_action()
	else:
		_add_type(type, sendSignal)

func _create_type() -> InventoryType:
	var type = InventoryType.new()
	type.set_editor(_editor)
	type.uuid = UUID.v4()
	type.name = _next_type_name()
	type.items = []
	return type

func _next_type_name() -> String:
	var base_name = "Type"
	var value = -9223372036854775807
	var type_found = false
	if types:
		for type in types:
			var name = type.name
			if name.begins_with(base_name):
				type_found = true
				var behind = type.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif type_found:
		next_name += "1"
	return next_name

func _add_type(type: InventoryType, sendSignal = true, position = types.size()) -> void:
	if types == null:
		types = []
	types.insert(position, type)
	type_added.emit(type)
	select_type(type)

func del_type(type) -> void:
	if _undo_redo != null:
		var index = types.find(type)
		_undo_redo.create_action("Del type")
		_undo_redo.add_do_method(self, "_del_type", type)
		_undo_redo.add_undo_method(self, "_add_type", type, false, index)
		_undo_redo.commit_action()
	else:
		_del_type(type)

func _del_type(type) -> void:
	var index = types.find(type)
	if index > -1:
		types.remove_at(index)
		type_removed.emit(type)
		_type_selected = null
		var type_selected = selected_type()
		select_type(type_selected)

func selected_type() -> InventoryType:
	if _type_selected == null and not types.is_empty():
		_type_selected = types[0]
	return _type_selected

func select_type(type: InventoryType) -> void:
	_type_selected = type
	type_selection_changed.emit(_type_selected)

func get_type_by_uuid(uuid: String) -> InventoryType:
	for type in types:
		if type.uuid == uuid:
			return type
	return null

func get_type_by_name(type_name: String) -> InventoryType:
	for type in types:
		if type.name == type_name:
			return type
	return null

# ***** ITEM *****
signal item_added(item)
signal item_removed(item)
signal item_selection_changed(item)
signal item_icon_changed(item)

func emit_item_icon_changed(item: InventoryItem) -> void:
	item_icon_changed.emit(item)

func all_items() -> Array:
	var items = []
	for type in types:
		for item in type.items:
			items.append(item)
	for recipe in recipes:
		items.append(recipe)
	items.sort_custom(func(a, b): return a.name < b.name)
	return items

func add_item(sendSignal = true) -> void:
	var item = _create_item()
	if _undo_redo != null:
		_undo_redo.create_action("Add item")
		_undo_redo.add_do_method(self, "_add_item", item)
		_undo_redo.add_undo_method(self, "_del_item", item)
		_undo_redo.commit_action()
	else:
		_add_item(item, sendSignal)

func _create_item() -> InventoryItem:
	var item = InventoryItem.new()
	item.set_editor(_editor)
	item.uuid = UUID.v4()
	item.type_uuid = _type_selected.uuid
	item.name = _next_item_name()
	return item

func _next_item_name(base_name = "Item") -> String:
	var value = -9223372036854775807
	var item_found = false
	if _type_selected.items:
		for item in _type_selected.items:
			var name = item.name
			if name.begins_with(base_name):
				item_found = true
				var behind = item.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif item_found:
		next_name += "1"
	return next_name

func _add_item(item: InventoryItem, sendSignal = true, position = _type_selected.items.size(), select = true) -> void:
	if _type_selected.items == null:
		_type_selected.items = []
	_type_selected.items.insert(position, item)
	item_added.emit(item)
	if select:
		select_item(item)

func copy_item(item: InventoryItem) -> void:
	var new_item = _create_item()
	new_item.name = _next_item_name()
	new_item.stacksize = item.stacksize
	new_item.stacks = item.stacks
	new_item.icon = "" + item.icon
	new_item.properties = item.properties.duplicate(true)
	if _undo_redo != null:
		_undo_redo.create_action("Copy item")
		_undo_redo.add_do_method(self, "_add_item", new_item, true, _type_selected.items.size())
		_undo_redo.add_undo_method(self, "_del_item", new_item)
		_undo_redo.commit_action()
	else:
		_add_item(new_item, true, _type_selected.items.size())

func del_item(item) -> void:
	if _undo_redo != null:
		var index = _type_selected.items.find(item)
		_undo_redo.create_action("Del item")
		_undo_redo.add_do_method(self, "_del_item", item)
		_undo_redo.add_undo_method(self, "_add_item", item, false, index)
		_undo_redo.commit_action()
	else:
		_del_item(item)

func _del_item(item) -> void:
	var index = _type_selected.items.find(item)
	if index > -1:
		_type_selected.items.remove_at(index)
		item_removed.emit(item)
		_type_selected.selected = null
		var item_selected = selected_item()
		select_item(item_selected)

func selected_item() -> InventoryItem:
	if _type_selected != null and _type_selected.selected == null and not _type_selected.items.is_empty():
		_type_selected.selected = _type_selected.items[0]
	return _type_selected.selected if _type_selected else null

func select_item(item: InventoryItem) -> void:
	_type_selected.selected = item
	item_selection_changed.emit(_type_selected.selected)

func get_item_by_uuid(uuid: String) -> InventoryItem:
	for type in types:
		if type != null:
			for item in type.items:
				if item != null and item.uuid == uuid:
					return item
	for recipe in recipes:
		if recipe != null and recipe.uuid == uuid:
			return recipe
	return null

func get_item_by_name(item_name: String) -> InventoryItem:
	for type in types:
		for item in type.items:
			if item.name == item_name:
				return item
	for recipe in recipes:
		if recipe.name == item_name:
			return recipe
	return null

# ***** RECIPE *****
signal recipe_added(recipe)
signal recipe_removed(recipe)
signal recipe_selection_changed(recipe)
signal recipe_icon_changed(item)

func emit_recipe_icon_changed(recipe: InventoryRecipe) -> void:
	recipe_icon_changed.emit(recipe)

@export var recipes: Array = []
var _recipe_selected: InventoryRecipe

func add_recipe(sendSignal = true) -> void:
	var recipe = _create_recipe()
	if _undo_redo != null:
		_undo_redo.create_action("Add recipe")
		_undo_redo.add_do_method(self, "_add_recipe", recipe)
		_undo_redo.add_undo_method(self, "_del_recipe", recipe)
		_undo_redo.commit_action()
	else:
		_add_recipe(recipe, sendSignal)

func _create_recipe() -> InventoryRecipe:
	var recipe = InventoryRecipe.new()
	recipe.set_editor(_editor)
	recipe.uuid = UUID.v4()
	recipe.name = _next_recipe_name()
	recipe.ingredients = []
	return recipe

func _next_recipe_name() -> String:
	var base_name = "Recipe"
	var value = -9223372036854775807
	var recipe_found = false
	if recipes:
		for recipe in recipes:
			var name = recipe.name
			if name.begins_with(base_name):
				recipe_found = true
				var behind = recipe.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif recipe_found:
		next_name += "1"
	return next_name

func _add_recipe(recipe: InventoryRecipe, sendSignal = true, position = recipes.size()) -> void:
	if recipes == null:
		recipes = []
	recipes.insert(position, recipe)
	recipe_added.emit(recipe)
	select_recipe(recipe)

func del_recipe(recipe) -> void:
	if _undo_redo != null:
		var index = recipes.find(recipe)
		_undo_redo.create_action("Del recipe")
		_undo_redo.add_do_method(self, "_del_recipe", recipe)
		_undo_redo.add_undo_method(self, "_add_recipe", recipe, false, index)
		_undo_redo.commit_action()
	else:
		_del_recipe(recipe)

func _del_recipe(recipe) -> void:
	var index = recipes.find(recipe)
	if index > -1:
		recipes.remove_at(index)
		recipe_removed.emit(recipe)
		_recipe_selected = null
		var recipe_selected = selected_recipe()
		select_recipe(recipe_selected)

func selected_recipe() -> InventoryRecipe:
	if _recipe_selected == null and not recipes.is_empty():
		_recipe_selected = recipes[0]
	return _recipe_selected

func select_recipe(recipe: InventoryRecipe) -> void:
	_recipe_selected = recipe
	recipe_selection_changed.emit(_recipe_selected)

func get_recipe_by_uuid(uuid: String) -> InventoryRecipe:
	for recipe in recipes:
		if recipe.uuid == uuid:
			return recipe
	return null

func get_recipe_by_name(recipe_name: String) -> InventoryRecipe:
	for recipe in recipes:
		if recipe.name == recipe_name:
			return recipe
	return null

# ***** EDITOR SETTINGS *****
const BACKGROUND_COLOR_SELECTED = Color("#868991")

const PATH_TO_SAVE = "res://addons/inventory_editor/InventorySave.res"
const AUTHOR = "# @author Vladimir Petrenko\n"
const SETTINGS_INVENTORIES_SPLIT_OFFSET = "inventory_editor/inventories_split_offset"
const SETTINGS_INVENTORIES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_TYPES_SPLIT_OFFSET = "inventory_editor/types_split_offset"
const SETTINGS_TYPES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_ITEMS_SPLIT_OFFSET = "inventory_editor/items_split_offset"
const SETTINGS_ITEMS_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_CRAFT_SPLIT_OFFSET = "inventory_editor/craft_split_offset"
const SETTINGS_CRAFT_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_INVENTORY_EDITOR_LOCALE = "inventory_editor/inventory_editor_locale"
const SUPPORTED_IMAGE_RESOURCES = ["bmp", "jpg", "jpeg", "png", "svg", "svgz", "tres"]

func setting_inventories_split_offset() -> int:
	var offset = SETTINGS_INVENTORIES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_INVENTORIES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_INVENTORIES_SPLIT_OFFSET)
	return offset

func setting_inventories_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_INVENTORIES_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_types_split_offset() -> int:
	var offset = SETTINGS_TYPES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_TYPES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_TYPES_SPLIT_OFFSET)
	return offset

func setting_types_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_TYPES_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_items_split_offset() -> int:
	var offset = SETTINGS_ITEMS_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_ITEMS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_ITEMS_SPLIT_OFFSET)
	return offset

func setting_items_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_ITEMS_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_craft_split_offset() -> int:
	var offset = SETTINGS_CRAFT_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_CRAFT_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_CRAFT_SPLIT_OFFSET)
	return offset

func setting_craft_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_CRAFT_SPLIT_OFFSET, offset)
	ProjectSettings.save()

func setting_dialogue_editor_locale():
	if ProjectSettings.has_setting(SETTINGS_INVENTORY_EDITOR_LOCALE):
		return ProjectSettings.get_setting(SETTINGS_INVENTORY_EDITOR_LOCALE)
	return null

func setting_dialogue_editor_locale_put(locale: String) -> void:
	ProjectSettings.set_setting(SETTINGS_INVENTORY_EDITOR_LOCALE, locale)
	ProjectSettings.save()

func setting_localization_editor_enabled() -> bool:
	if ProjectSettings.has_setting("editor_plugins/enabled"):
		var enabled_plugins = ProjectSettings.get_setting("editor_plugins/enabled") as Array
		for plugin in enabled_plugins:
			if "localization_editor" in plugin:
				return true
	return false

# ***** LOAD SAVE *****
func init_data() -> void:
	if FileAccess.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as InventoryData
		if resource.types != null and not resource.types.is_empty():
			types = resource.types
		if resource.inventories != null and not resource.inventories.is_empty():
			inventories = resource.inventories
		if resource.recipes != null and not resource.recipes.is_empty():
			recipes = resource.recipes

func save(update_script_classes = false) -> void:
	ResourceSaver.save(self, PATH_TO_SAVE)
	if update_script_classes:
		_save_data_inventories()
		_save_data_items()
		_editor.get_editor_interface().get_resource_filesystem().scan()

func _save_data_inventories() -> void:
	var directory:= DirAccess.open(default_path)
	if not directory.dir_exists(default_path):
		directory.make_dir(default_path)
	var file = FileAccess.open(default_path + "InventoryManagerInventory.gd", FileAccess.WRITE)
	var source_code = "# List of creted inventories for InventoryManger to use in source code: MIT License\n"
	source_code += AUTHOR
	source_code += "@tool\n"
	source_code += "class_name InventoryManagerInventory\n\n"
	for inventory in inventories:
		var namePrepared = inventory.name.replace(" ", "")
		namePrepared = namePrepared.to_upper()
		source_code += "const " + namePrepared + " = \"" + inventory.uuid +"\"\n"
	source_code += "\nconst INVENTORIES = [\n"
	for index in range(inventories.size()):
		source_code += " \"" + inventories[index].name + "\""
		if index != inventories.size() - 1:
			source_code += ",\n"
	source_code += "\n]"
	file.store_string(source_code)

func _save_data_items() -> void:
	var file = FileAccess.open(default_path + "InventoryManagerItem.gd", FileAccess.WRITE)
	var source_code = "# List of creted items for InventoryManger to use in source code: MIT License\n"
	source_code += AUTHOR
	source_code += "@tool\n"
	source_code += "class_name InventoryManagerItem\n\n"
	var items = all_items()
	source_code += "\nenum ItemEnum { NONE, "
	for index in range(items.size()):
		source_code += " " + items[index].name
		if index != items.size() - 1:
			source_code += ","
	source_code += "}\n\n"
	for item in items:
		var namePrepared = item.name.replace(" ", "")
		namePrepared = namePrepared.to_upper()
		source_code += "const " + namePrepared + " = \"" + item.uuid +"\"\n"
	source_code += "\nconst ITEMS = [\n"
	for index in range(items.size()):
		source_code += " \"" + items[index].name + "\""
		if index != items.size() - 1:
			source_code += ",\n"
	source_code += "\n]\n\n"
	source_code += "static func item_by_enum(item_enum: ItemEnum) -> String:\n"
	source_code += "	match item_enum:\n"
	for index in range(items.size()):
		source_code += "		ItemEnum." + items[index].name + ":\n"
		source_code += "			return InventoryManagerItem." + (items[index].name).to_upper() + "\n"
	source_code += "		_:\n"
	source_code += "			return \"\"\n"
	file.store_string(source_code)

# ***** UTILS *****
func filename(value: String) -> String:
	var index = value.rfind("/")
	return value.substr(index + 1)

func filename_only(value: String) -> String:
	var first = value.rfind("/")
	var second = value.rfind(".")
	return value.substr(first + 1, second - first - 1)

func file_path(value: String) -> String:
	var index = value.rfind("/")
	return value.substr(0, index)

func file_extension(value: String):
	var index = value.rfind(".")
	if index == -1:
		return null
	return value.substr(index + 1)

func resource_exists(resource_path) -> bool:
	return FileAccess.file_exists(resource_path)

func sort_types_by_name() -> void:
	types.sort_custom(func(a, b): return a.name < b.name)

func sort_inventories_by_name() -> void:
	inventories.sort_custom(func(a, b): return a.name < b.name)

func sort_recipes_by_name() -> void:
	recipes.sort_custom(func(a, b): return a.name < b.name)
