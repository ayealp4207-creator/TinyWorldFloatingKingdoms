extends Node3D
## Builds a lightweight placeholder world so the project runs without external assets.

const CAMERA_SCRIPT = preload("res://scripts/camera_controller.gd")
const RESOURCE_SCRIPT = preload("res://scripts/resource_node.gd")

var status_label: Label
var wood_count := 0
var stone_count := 0

func _ready() -> void:
	_build_lighting()
	_build_island()
	_build_camera()
	_build_resources()
	_build_ui()

func _build_lighting() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.82, 0.95)
	env.ambient_light_energy = 0.65
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -30.0, 0.0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _make_material(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _build_island() -> void:
	var grass := MeshInstance3D.new()
	var grass_mesh := CylinderMesh.new()
	grass_mesh.top_radius = 7.0
	grass_mesh.bottom_radius = 5.4
	grass_mesh.height = 1.2
	grass_mesh.radial_segments = 48
	grass.mesh = grass_mesh
	grass.position.y = 0.0
	grass.material_override = _make_material(Color(0.27, 0.57, 0.25))
	add_child(grass)

	var earth := MeshInstance3D.new()
	var earth_mesh := SphereMesh.new()
	earth_mesh.radius = 5.7
	earth_mesh.height = 7.2
	earth.mesh = earth_mesh
	earth.position.y = -2.9
	earth.scale = Vector3(1.0, 0.75, 1.0)
	earth.material_override = _make_material(Color(0.42, 0.28, 0.17))
	add_child(earth)

	var water := MeshInstance3D.new()
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(200.0, 200.0)
	water.mesh = water_mesh
	water.position.y = -8.0
	water.material_override = _make_material(Color(0.12, 0.48, 0.72), 0.35)
	add_child(water)

	# Simple landmark rocks around the island edge.
	for i in range(9):
		var rock := MeshInstance3D.new()
		var rock_mesh := SphereMesh.new()
		rock_mesh.radius = 0.55
		rock_mesh.height = 0.8
		rock.mesh = rock_mesh
		var angle := TAU * float(i) / 9.0
		rock.position = Vector3(cos(angle) * 5.8, 0.65, sin(angle) * 5.8)
		rock.scale = Vector3(1.0, 0.7, 0.85)
		rock.material_override = _make_material(Color(0.35, 0.38, 0.39))
		add_child(rock)

func _build_camera() -> void:
	var rig := Node3D.new()
	rig.name = "CameraRig"
	rig.set_script(CAMERA_SCRIPT)
	rig.target = Vector3(0.0, 0.0, 0.0)
	add_child(rig)

func _build_resources() -> void:
	_add_resource(Vector3(-2.5, 0.8, -1.0), "wood", 3)
	_add_resource(Vector3(2.2, 0.8, -1.8), "stone", 3)
	_add_resource(Vector3(1.8, 0.8, 2.2), "wood", 3)

func _add_resource(at: Vector3, kind: String, amount: int) -> void:
	var node := Area3D.new()
	node.name = kind.capitalize() + "Resource"
	node.position = at
	node.set_script(RESOURCE_SCRIPT)
	node.resource_type = kind
	node.amount = amount
	add_child(node)

func collect_resource(kind: String, amount: int) -> void:
	if kind == "wood":
		wood_count += amount
	elif kind == "stone":
		stone_count += amount
	_update_ui()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(280, 80)
	layer.add_child(panel)
	status_label = Label.new()
	status_label.text = "TINY WORLD\nWood: 0   Stone: 0\nTap a resource to collect"
	status_label.add_theme_font_size_override("font_size", 20)
	panel.add_child(status_label)

	var hint := Label.new()
	hint.text = "Drag to rotate • Pinch / wheel to zoom"
	hint.position = Vector2(18, 112)
	hint.add_theme_font_size_override("font_size", 16)
	layer.add_child(hint)

func _update_ui() -> void:
	if is_instance_valid(status_label):
		status_label.text = "TINY WORLD\nWood: %d   Stone: %d\nTap a resource to collect" % [wood_count, stone_count]
