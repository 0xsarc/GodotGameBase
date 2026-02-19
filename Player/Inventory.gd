extends Node
class_name Inventory

signal item_added(id: String, amount: int, total: int)
signal item_removed(id: String, amount: int, total: int)
signal inventory_changed

@export_range(1, 64, 1) var max_slots: int = 16

var _items: Dictionary = {}
var _item_order: Array[String] = []


func add(item_id: String, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0:
		return false

	if not _items.has(item_id) and _items.size() >= max_slots:
		return false

	if not _items.has(item_id):
		_item_order.append(item_id)

	var total: int = int(_items.get(item_id, 0)) + amount
	_items[item_id] = total

	item_added.emit(item_id, amount, total)
	inventory_changed.emit()
	return true


func remove(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or not _items.has(item_id):
		return false

	var total: int = int(_items[item_id]) - amount

	if total <= 0:
		_items.erase(item_id)
		_item_order.erase(item_id)
		total = 0
	else:
		_items[item_id] = total

	item_removed.emit(item_id, amount, total)
	inventory_changed.emit()
	return true


func get_amount(item_id: String) -> int:
	return int(_items.get(item_id, 0))


func has_space_for(item_id: String) -> bool:
	return _items.has(item_id) or _items.size() < max_slots


func get_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item_id in _item_order:
		entries.append({
			"id": item_id,
			"amount": int(_items[item_id])
		})
	return entries


func is_empty() -> bool:
	return _items.is_empty()
