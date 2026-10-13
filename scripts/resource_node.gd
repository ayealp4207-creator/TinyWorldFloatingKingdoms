extends Area3D
## Minimal clickable resource node. Replace placeholder visuals with models later.

@export_enum("wood", "stone") var resource_type := "wood"
@export_range(1, 99) var amount := 3
var _main: Node

func _ready() -> void:
	var visual := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.35 if resource_type == "wood" else 0.45
	mesh.bottom_radius = 0.45
	mesh.height = 1.0
	mesh.radial_segments = 8
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.25, 0.11) if resource_type == "wood" else Color(0.48, 0.52, 0.56)
	visual.material_override = mat
	add_child(visual)

	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.8
	collision.shape = shape
	add_child(collision)
	input_ray_pickable = true
	input_event.connect(_on_input_event)
	_main = get_parent()

func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var pressed := false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if pressed:
		if is_instance_valid(_main) and _main.has_method("collect_resource"):
			_main.collect_resource(resource_type, amount)
		queue_free()
