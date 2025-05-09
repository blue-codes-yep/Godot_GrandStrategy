extends Node3D

enum DisplayMode {
	NORMAL = 0,    # Terrain with borders
	POLITICAL = 1, # Political map
	DEBUG_R = 2,   # Debug - Red channel
	DEBUG_G = 3,   # Debug - Green channel
	DEBUG_B = 4,   # Debug - Blue channel
	DEBUG_A = 5,   # Debug - Alpha channel
	DEBUG_RGB = 6  # Debug - RGB channels
}

# Reference to globe mesh
@export var globe_mesh: MeshInstance3D

# Parameters
@export var current_mode: DisplayMode = DisplayMode.NORMAL
@export var border_intensity: float = 0.3
@export var border_color: Color = Color(0.0, 0.0, 0.0)
@export var border_fade_factor: float = 0.2  # Controls the fade effect of borders
@export var political_color: Color = Color(0.8, 0.2, 0.2)
@export var zoom_min: float = 10.0
@export var zoom_max: float = 50.0

func _ready():
	if globe_mesh:
		update_shader_parameters()

func update_shader_parameters():
	if not globe_mesh:
		push_error("Globe mesh not assigned!")
		return
	
	# Debug output to help diagnose the issue
	print("Globe mesh node: ", globe_mesh.name)
	print("Globe mesh node type: ", globe_mesh.get_class())
	
	# Try different ways to get the material based on node structure
	var material = null
	
	# First try material_override (most common for 3D meshes)
	if globe_mesh.has_method("get_material_override") and globe_mesh.get_material_override():
		print("Using get_material_override")
		material = globe_mesh.get_material_override()
	# Try surface_override_material which is specific to MeshInstance3D
	elif globe_mesh is MeshInstance3D:
		if globe_mesh.get_surface_override_material(0):
			print("Using get_surface_override_material")
			material = globe_mesh.get_surface_override_material(0)
		elif globe_mesh.material_override:
			print("Using material_override property")
			material = globe_mesh.material_override
	
	# If we still don't have a material, check direct property access as a fallback
	if not material and 'material_override' in globe_mesh:
		print("Using material_override property directly")
		material = globe_mesh.material_override
	
	# Final check if we have a material
	if not material:
		push_error("No material found on globe mesh after all attempts")
		print("Available properties: ", globe_mesh.get_property_list())
		print("Available methods: ", globe_mesh.get_method_list())
		return
	
	# Update shader parameters
	material.set_shader_parameter("display_mode", current_mode)
	material.set_shader_parameter("border_intensity", border_intensity)
	material.set_shader_parameter("border_color", Vector3(border_color.r, border_color.g, border_color.b))
	material.set_shader_parameter("border_fade_factor", border_fade_factor)
	material.set_shader_parameter("political_color", Vector3(political_color.r, political_color.g, political_color.b))
	material.set_shader_parameter("zoom_min", zoom_min)
	material.set_shader_parameter("zoom_max", zoom_max)

# Public functions for controlling display modes
func set_normal_mode():
	current_mode = DisplayMode.NORMAL
	update_shader_parameters()

func set_political_mode():
	current_mode = DisplayMode.POLITICAL
	update_shader_parameters()

func set_debug_mode(channel: int = 0):
	# Use proper enum assignment based on channel
	match channel:
		0: current_mode = DisplayMode.DEBUG_R
		1: current_mode = DisplayMode.DEBUG_G
		2: current_mode = DisplayMode.DEBUG_B
		3: current_mode = DisplayMode.DEBUG_A
		4: current_mode = DisplayMode.DEBUG_RGB
		_: current_mode = DisplayMode.DEBUG_R
	update_shader_parameters()

func set_border_intensity(intensity: float):
	border_intensity = clamp(intensity, 0.0, 1.0)
	update_shader_parameters()

func set_political_color(color: Color):
	political_color = color
	update_shader_parameters()
