extends CanvasLayer
class_name InventoryUI

@export_range(4, 64, 1) var visible_slots: int = 16
@export var columns: int = 4

var inventory: Inventory
var _root: PanelContainer
var _grid: GridContainer
var _placeholder_icon: Texture2D = preload("res://Assets/DarkPrototypeTexture.png")


func _ready() -> void:
	layer = 3
	visible = false
	_build_ui()


func bind_inventory(inv: Inventory) -> void:
	inventory = inv
	if not inventory.inventory_changed.is_connected(_refresh):
		inventory.inventory_changed.connect(_refresh)
	_refresh()


func set_open(is_open: bool) -> void:
	visible = is_open
	if is_open:
		_refresh()


func _build_ui() -> void:
	_root = PanelContainer.new()
	_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_root.position = Vector2(16, 16)
	_root.custom_minimum_size = Vector2(430, 320)
	add_child(_root)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_root.add_child(margin)

	var vb := VBoxContainer.new()
	margin.add_child(vb)

	var title := Label.new()
	title.text = "Inventário"
	vb.add_child(title)

	_grid = GridContainer.new()
	_grid.columns = columns
	_grid.custom_minimum_size = Vector2(400, 260)
	vb.add_child(_grid)


func _refresh() -> void:
	if _grid == null:
		return

	for child in _grid.get_children():
		child.queue_free()

	if inventory == null:
		return

	var entries := inventory.get_entries()
	for i in visible_slots:
		if i < entries.size():
			_create_filled_slot(entries[i])
		else:
			_create_empty_slot()


func _create_filled_slot(entry: Dictionary) -> void:
	var slot := _base_slot()

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(72, 48)
	icon.texture = _resolve_icon(entry.get("id", ""))
	(slot.get_child(0) as VBoxContainer).add_child(icon)

	var label := Label.new()
	label.text = "%s x%d" % [entry.get("id", "item"), int(entry.get("amount", 0))]
	(slot.get_child(0) as VBoxContainer).add_child(label)

	_grid.add_child(slot)


func _create_empty_slot() -> void:
	var slot := _base_slot()

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(72, 48)
	icon.modulate = Color(1, 1, 1, 0.2)
	icon.texture = _placeholder_icon
	(slot.get_child(0) as VBoxContainer).add_child(icon)

	var label := Label.new()
	label.text = "vazio"
	label.modulate = Color(1, 1, 1, 0.4)
	(slot.get_child(0) as VBoxContainer).add_child(label)

	_grid.add_child(slot)


func _base_slot() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(92, 72)
	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vb)
	return panel


func _resolve_icon(item_id: String) -> Texture2D:
	var item_data := PickupItem.get_item_data(item_id)
	var icon: Texture2D = item_data.get("icon", _placeholder_icon)
	return icon if icon != null else _placeholder_icon
