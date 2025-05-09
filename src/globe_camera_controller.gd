extends Camera3D

# Camera control parameters
@export var target_node: Node3D  # The globe we're orbiting around
@export var orbit_speed: float = 0.5
@export var zoom_speed: float = 0.5
@export var min_zoom_distance: float = 5.0
@export var max_zoom_distance: float = 50.0
@export var initial_distance: float = 15.0
@export var initial_pitch: float = 0.3  # Radians
@export var enable_input: bool = true

# Orbit state variables
var orbit_yaw: float = 0.0
var orbit_pitch: float = 0.0
var current_distance: float = 0.0
var dragging: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

# Internal state
var target_position: Vector3 = Vector3.ZERO

func _ready():
	# Set up initial position and orientation
	if target_node:
		target_position = target_node.global_position
		print("Camera controller initialized with target: ", target_node.name)
	else:
		target_position = Vector3.ZERO
		push_error("No target node assigned to camera controller!")
	
	orbit_pitch = initial_pitch
	current_distance = initial_distance
	
	# Set mouse mode for proper input capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_update_camera_transform()
	
	# Debug info
	print("Camera input enabled: ", enable_input)
	print("Camera initial position: ", global_position)

func _input(event):
	if not enable_input:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Start/stop dragging for orbit
			dragging = event.pressed
			if dragging:
				last_mouse_position = event.position
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in
			current_distance = max(current_distance - zoom_speed, min_zoom_distance)
			_update_camera_transform()
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out
			current_distance = min(current_distance + zoom_speed, max_zoom_distance)
			_update_camera_transform()
	
	elif event is InputEventMouseMotion and dragging:
		# Update orbit angles based on mouse movement
		var delta = event.position - last_mouse_position
		last_mouse_position = event.position
		
		orbit_yaw -= delta.x * orbit_speed * 0.01
		orbit_pitch -= delta.y * orbit_speed * 0.01
		
		# Clamp pitch to avoid flipping
		orbit_pitch = clamp(orbit_pitch, -1.4, 1.4)
		
		_update_camera_transform()

# Updates camera position and orientation based on orbit parameters
func _update_camera_transform():
	# Calculate the new position based on spherical coordinates
	var pos = Vector3()
	pos.x = sin(orbit_yaw) * cos(orbit_pitch) * current_distance
	pos.z = cos(orbit_yaw) * cos(orbit_pitch) * current_distance
	pos.y = sin(orbit_pitch) * current_distance
	
	# Position the camera and look at the target
	global_position = target_position + pos
	look_at(target_position, Vector3.UP)

# Set whether the camera responds to input
func set_input_enabled(enabled: bool):
	enable_input = enabled

# Focus on a specific location on the globe
func focus_on_position(globe_position: Vector3):
	# Adjust the target position to focus on the specific point
	var direction = (globe_position - target_position).normalized()
	target_position = globe_position - direction * 1.0  # Slight offset to center
	
	# Calculate new orbit angles based on this position
	var to_pos = globe_position - target_position
	orbit_yaw = atan2(to_pos.x, to_pos.z)
	var horizontal_distance = sqrt(to_pos.x * to_pos.x + to_pos.z * to_pos.z)
	orbit_pitch = atan2(to_pos.y, horizontal_distance)
	
	_update_camera_transform() 
