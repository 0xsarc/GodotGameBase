extends Node3D
class_name PickupItem

const PLACEHOLDER_ICON: Texture2D = preload("res://Assets/DarkPrototypeTexture.png")

const ITEM_DB := {
	"moeda": {
		"name": "Moeda",
		"icon": PLACEHOLDER_ICON
	},
	"chave": {
		"name": "Chave",
		"icon": PLACEHOLDER_ICON
	},
	"item": {
		"name": "Item",
		"icon": PLACEHOLDER_ICON
	}
}

@export var item_id: String = "item"
@export var amount: int = 1

@export var destroy_on_pickup: bool = true
@export var hide_only: bool = false
@export var disable_collision: bool = true

@export var pickup_sound: AudioStream


static func get_item_data(id: String) -> Dictionary:
	return ITEM_DB.get(id, ITEM_DB["item"])


func interact(player: Node) -> void:
	var inv: Inventory = null
	if player is Player:
		inv = (player as Player).inventory
	elif player.has_node("Inventory"):
		inv = player.get_node("Inventory") as Inventory

	if inv == null:
		push_warning("Interação sem inventário no player")
		return

	if not inv.add(item_id, amount):
		push_warning("Inventário cheio: não foi possível pegar %s" % item_id)
		return

	_play_sound()
	_apply_removal()


func _play_sound() -> void:
	if pickup_sound == null:
		return

	var player := AudioStreamPlayer3D.new()
	player.stream = pickup_sound
	get_tree().current_scene.add_child(player)
	player.global_position = global_position
	player.play()
	player.finished.connect(player.queue_free)


func _apply_removal() -> void:
	if hide_only:
		visible = false

	if disable_collision:
		_disable_collisions(self)

	if destroy_on_pickup:
		queue_free()


func _disable_collisions(node: Node) -> void:
	if node is CollisionShape3D:
		(node as CollisionShape3D).set_deferred("disabled", true)

	for child in node.get_children():
		_disable_collisions(child)
