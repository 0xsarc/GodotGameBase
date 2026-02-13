extends Node3D

func _ready() -> void:
	add_to_group("interactable")
	pass
	
func _process(delta: float) -> void:
	pass
func interact(player: Node) -> void:
	print("FUNCIONOU CARALHO")
