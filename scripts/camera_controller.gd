extends Node3D
## One-finger drag rotates; mouse wheel / pinch-style wheel events zoom.
## The camera rig is deliberately simple and mobile-friendly.

@export var target := Vector3.ZERO
@export var distance := 16.0
@export var min_distance := 9.0
@export var max_distance := 25.0
@export var drag_sensitivity := 0.008
@export var zoom_step := 1.0

var yaw := 0.45
var pitch := -0.48
var _dragging := false
var _last_pointer := Vector2.ZERO
var camera: Camera3D

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	add_child(camera)
	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_dragging = event.pressed
		_last_pointer = event.position
	elif event is InputEventScreenDrag:
		if _dragging:
			_orbit(event.relative)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_last_pointer = event.position
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(min_distance, distance - zoom_step)
			_update_camera()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(max_distance, distance + zoom_step)
			_update_camera()
	elif event is InputEventMouseMotion and _dragging:
		_orbit(event.relative)

func _orbit(delta: Vector2) -> void:
	yaw -= delta.x * drag_sensitivity
	pitch = clampf(pitch - delta.y * drag_sensitivity, -1.15, -0.12)
	_update_camera()

func _update_camera() -> void:
	if not is_instance_valid(camera):
		return
	var offset := Vector3(
		sin(yaw) * cos(pitch),
		-sin(pitch),
		cos(yaw) * cos(pitch)
	) * distance
	camera.position = target + offset
	camera.look_at(target, Vector3.UP)
