extends Node3D
class_name PickupItem

## ============================================================
## PickupItem.gd (versão correta FINAL)
##
## - você arrasta .wav/.ogg/.mp3 no Inspector
## - usa AudioStreamPlayer3D interno
## - sem criar nodes dinamicamente
## - zero erro
## ============================================================

@export var destroy_on_pickup: bool = true
@export var hide_only: bool = false
@export var disable_collision: bool = true

@export var pickup_sound: AudioStream

@export var animation_player: AnimationPlayer
@export var pickup_animation: String = "pickup"

var _audio_player: AudioStreamPlayer3D


func _ready() -> void:
	_audio_player = AudioStreamPlayer3D.new()
	add_child(_audio_player)


func interact(_player: Node) -> void:
	print("PICKUP:", name)
	await _play_sound()
	_apply_removal()


# ============================================================
# SOM (CORRETO)
# ============================================================

func _play_sound() -> void:
	if pickup_sound == null:
		return

	var player := AudioStreamPlayer3D.new()
	player.stream = pickup_sound
	get_tree().current_scene.add_child(player)
	player.global_position = global_position
	player.play()

	player.finished.connect(player.queue_free)



# ============================================================
# REMOÇÃO
# ============================================================

func _apply_removal() -> void:

	if hide_only:
		visible = false

	if disable_collision:
		_disable_collisions(self)

	if destroy_on_pickup:
		queue_free()


func _disable_collisions(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionObject3D:
			child.set_deferred("disabled", true)
		_disable_collisions(child)
