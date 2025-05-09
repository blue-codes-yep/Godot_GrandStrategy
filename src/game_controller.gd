extends Node

# References to other nodes
@export var main_menu: Control
@export var game_ui: Control
@export var globe_controller: Node
@export var camera_controller: Node

# Game state
var game_running: bool = false
var country_data = {
	"USA": Vector3(2.8, 4.2, -0.5),
	"China": Vector3(-2.2, 4.0, 1.9),
	"India": Vector3(-1.5, 3.9, 2.8),
	"Brazil": Vector3(1.5, 2.5, 3.5),
	"Russia": Vector3(-1.0, 4.5, 1.0),
	# Add more countries and approximate globe positions
}

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect signals from UI components
	if main_menu:
		main_menu.start_game.connect(_on_start_game)
		main_menu.show()
	
	if game_ui:
		game_ui.return_to_menu.connect(_on_return_to_menu)
		game_ui.hide()
	
	# Enable camera control right away for testing
	if camera_controller:
		print("Enabling camera controls for globe spinning")
		camera_controller.set_input_enabled(true)
	
	# Initialize globe to normal mode
	if globe_controller:
		print("Globe controller path: ", globe_controller.get_path())
		print("Globe controller type: ", globe_controller.get_class())
		print("Globe controller children: ", globe_controller.get_children())
		
		# Try to find the controller script in various places based on your scene hierarchy
		var controller = null
		
		# First check if the controller is on this node
		if globe_controller.has_method("set_normal_mode"):
			print("Controller found directly on referenced node")
			controller = globe_controller
		# Check if we need to go up a level (GlobeNoTexture might be the controller)
		elif globe_controller.get_parent() and globe_controller.get_parent().has_method("set_normal_mode"):
			print("Controller found on parent node")
			controller = globe_controller.get_parent()
		# Check if the script is on the first child named 'GlobeNoTexture'
		elif globe_controller.has_node("GlobeNoTexture") and globe_controller.get_node("GlobeNoTexture").has_method("set_normal_mode"):
			print("Controller found on GlobeNoTexture child")
			controller = globe_controller.get_node("GlobeNoTexture")
		# Check all direct children
		else:
			for child in globe_controller.get_children():
				if child.has_method("set_normal_mode"):
					print("Controller found on child: ", child.name)
					controller = child
					break
		
		if controller:
			controller.set_normal_mode()
		else:
			push_warning("Could not find globe controller with set_normal_mode method. Check node paths.")
		
	# Set up country click detection
	setup_country_detection()

# Set up the ability to detect clicks on the globe to select countries
func setup_country_detection():
	# We'll rely on ray casting to detect clicks on the globe surface
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event):
	if not game_running:
		return
		
	# Handle country selection via mouse clicks
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera = get_viewport().get_camera_3d()
		if camera:
			# Cast a ray from the camera through the mouse position
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 1000.0
			
			# Check for intersection with the globe
			var space_state = get_tree().get_root().get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider is MeshInstance3D:
				# Found an intersection with the globe
				_handle_globe_click(result.position)

# Handle a click on the globe surface
func _handle_globe_click(position: Vector3):
	# Find the closest country to the clicked position
	var closest_country = ""
	var closest_distance = 999999.0
	
	for country in country_data.keys():
		var country_pos = country_data[country]
		var distance = position.distance_to(country_pos)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_country = country
	
	# If we found a country close enough, select it
	if closest_distance < 2.0 and not closest_country.is_empty():
		if game_ui:
			game_ui.select_country(closest_country, country_data[closest_country])
	else:
		# Clicked on ocean or unidentified area
		if game_ui:
			game_ui.clear_selection()

# Signal handlers
func _on_start_game():
	game_running = true
	
	# Show game UI
	if game_ui:
		game_ui.show_game_ui()
	
	# Enable camera controls
	if camera_controller:
		camera_controller.set_input_enabled(true)

func _on_return_to_menu():
	game_running = false
	
	# Show main menu
	if main_menu:
		main_menu.show_menu()
	
	# Disable camera controls
	if camera_controller:
		camera_controller.set_input_enabled(false)
	
	# Reset globe to normal mode
	if globe_controller:
		globe_controller.set_normal_mode() 
