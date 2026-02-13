extends Node
class_name Inventory

signal item_added(id: String, amount: int, total: int)
signal item_removed(id: String, amount: int, total: int)

var items: Dictionary = {}


func add(item_id: String, amount: int = 1) -> void:
	if item_id.is_empty():
		return

	var total: int = items.get(item_id, 0) + amount
	items[item_id] = total

	item_added.emit(item_id, amount, total)


func remove(item_id: String, amount: int = 1) -> bool:
	if not items.has(item_id):
		return false

	var total: int = items[item_id] - amount

	if total <= 0:
		items.erase(item_id)
		total = 0
	else:
		items[item_id] = total

	item_removed.emit(item_id, amount, total)
	return true


func get_amount(id: String) -> int:
	return int(items.get(id, 0))
