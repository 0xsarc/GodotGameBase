extends CharacterBody3D
class_name Player

@export_range(1, 35, 1) var speed: float = 8 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

@export_range(1, 50, 1) var sprint_speed: float = 14
@export_range(10, 600, 1) var sprint_acceleration: float = 150

@export_range(60, 120, 1) var base_fov: float = 75
@export_range(60, 140, 1) var sprint_fov: float = 90
@export_range(1, 20, 1) var fov_lerp_speed: float = 8

@export_range(0.0, 0.3, 0.01) var coyote_time: float = 0.12
@export_range(0.0, 0.3, 0.01) var jump_buffer: float = 0.12

@export_range(0.0, 0.2, 0.005) var bob_amount: float = 0.04
@export_range(0.0, 0.3, 0.005) var bob_amount_sprint: float = 0.07
@export_range(0.1, 30.0, 0.1) var bob_speed: float = 10.0

var _bob_t: float = 0.0
var _camera_base_y: float = 0.0
var _camera_base_x: float = 0.0

var _coyote_t: float = 0.0
var _jump_buf_t: float = 0.0

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity
var grav_vel: Vector3 # Gravity velocity
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $Camera

func _ready() -> void:
	_camera_base_y = camera.position.y
	_camera_base_x = camera.position.x
	camera.fov = base_fov
	capture_mouse()


func _interact():
	if not $Camera/RayCast3D.is_colliding(): return
	var obj = $Camera/RayCast3D.get_collider()
	if obj.has_method("interact"):
		obj.interact(self)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured:
			_rotate_camera()
	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# coyote + jump buffer
	_coyote_t = coyote_time if is_on_floor() else max(_coyote_t - delta, 0.0)
	_jump_buf_t = (jump_buffer if Input.is_action_just_pressed(&"jump") else max(_jump_buf_t - delta, 0.0))

	if _jump_buf_t > 0.0 and _coyote_t > 0.0:
		jumping = true
		_jump_buf_t = 0.0
		_coyote_t = 0.0

	if mouse_captured:
		_handle_joypad_camera_rotation(delta)

	var walk_vector: Vector3 = _walk(delta)
	velocity = walk_vector + _gravity(delta) + _jump(delta)

	_update_fov(delta)

	move_and_slide()
	_headbob(delta)

func _update_fov(delta: float) -> void:
	var moving_forward: bool = move_dir.y < 0
	var sprinting: bool = Input.is_action_pressed(&"sprint") and is_on_floor() and moving_forward

	var target_fov: float = sprint_fov if sprinting else base_fov
	camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

func _headbob(delta: float) -> void:
	var horiz_speed := Vector2(velocity.x, velocity.z).length()
	var moving := horiz_speed > 0.1 and is_on_floor()

	if not moving:
		_bob_t = 0.0
		camera.position.y = lerp(camera.position.y, _camera_base_y, 12.0 * delta)
		camera.position.x = lerp(camera.position.x, _camera_base_x, 12.0 * delta)
		return

	var moving_forward := move_dir.y < 0
	var sprinting := Input.is_action_pressed(&"sprint") and is_on_floor() and moving_forward
	var amt := bob_amount_sprint if sprinting else bob_amount

	_bob_t += delta * bob_speed * (1.3 if sprinting else 1.0)

	var y_offset := sin(_bob_t * 2.0) * amt
	var x_offset := cos(_bob_t) * amt * 0.5

	camera.position.y = lerp(camera.position.y, _camera_base_y + y_offset, 18.0 * delta)
	camera.position.x = lerp(camera.position.x, _camera_base_x + x_offset, 18.0 * delta)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")

	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()

	var moving_forward: bool = move_dir.y < 0
	var sprinting: bool = Input.is_action_pressed(&"sprint") and is_on_floor() and moving_forward

	var target_speed: float = sprint_speed if sprinting else speed
	var target_accel: float = sprint_acceleration if sprinting else acceleration

	walk_vel = walk_vel.move_toward(walk_dir * target_speed * move_dir.length(), target_accel * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor():
			jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel

	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
