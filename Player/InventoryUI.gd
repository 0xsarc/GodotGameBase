extends CanvasLayer
class_name InventoryUI

## UI mínima garantida

var inventory: Inventory
var label: Label


func _ready() -> void:
	print("InventoryUI READY") # 🔥 debug

	visible = true  # 🔥 força visível pra teste

	# label simples (garantido aparecer)
	label = Label.new()
	label.position = Vector2(20, 20)
	label.text = "Inventory vazio"
	add_child(label)


func bind_inventory(inv: Inventory) -> void:
	inventory = inv

	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_refresh)

	_refresh()


func _on_item_added(_id: String, _amount: int, _total: int) -> void:
	_refresh()


func _refresh() -> void:
	if inventory == null:
		return

	var text := ""

	for id in inventory.items:
		text += "%s x%d\n" % [id, inventory.items[id]]

	if text == "":
		text = "Inventory vazio"

	label.text = text
