extends Control

signal return_to_menu

# References to other nodes
@export var globe_controller: Node
@export var camera_controller: Node

# Country selection
var selected_country: String = ""
var highlighted_position: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect UI buttons if they exist
	if $TopPanel/HBoxContainer/ReturnButton:
		$TopPanel/HBoxContainer/ReturnButton.pressed.connect(_on_return_button_pressed)
		print("Return button connected")
	else:
		push_error("Return button not found in UI")
	
	if $TopPanel/HBoxContainer/NormalModeButton:
		$TopPanel/HBoxContainer/NormalModeButton.pressed.connect(_on_normal_mode_pressed)
		print("Normal mode button connected")
	else:
		push_error("Normal mode button not found in UI")
	
	if $TopPanel/HBoxContainer/PoliticalModeButton:
		$TopPanel/HBoxContainer/PoliticalModeButton.pressed.connect(_on_political_mode_pressed)
		print("Political mode button connected")
	else:
		push_error("Political mode button not found in UI")
	
	# Initialize UI elements
	update_country_info()
	
	# Hide initially - will be shown when game starts
	hide()

# Show the game UI
func show_game_ui():
	show()
	
	# Enable camera controls when game UI is shown
	if camera_controller:
		camera_controller.set_input_enabled(true)

# Update the country information display
func update_country_info():
	if $CountryPanel and $CountryPanel/CountryName:
		if selected_country.is_empty():
			$CountryPanel.hide()
		else:
			$CountryPanel.show()
			$CountryPanel/CountryName.text = selected_country

# Select a country
func select_country(country_name: String, position: Vector3):
	selected_country = country_name
	highlighted_position = position
	
	# Update UI
	update_country_info()
	
	# Update shader to highlight selected country
	if globe_controller:
		# Set to political mode for better visualization
		globe_controller.set_political_mode()
		
		# Optionally, focus camera on selected country
		if camera_controller:
			camera_controller.focus_on_position(highlighted_position)

# Clear country selection
func clear_selection():
	selected_country = ""
	update_country_info()
	
	# Return to normal mode
	if globe_controller:
		globe_controller.set_normal_mode()

# UI button handlers
func _on_return_button_pressed():
	hide()
	emit_signal("return_to_menu")
	
	# Disable camera controls when returning to menu
	if camera_controller:
		camera_controller.set_input_enabled(false)

func _on_normal_mode_pressed():
	if globe_controller:
		globe_controller.set_normal_mode()

func _on_political_mode_pressed():
	if globe_controller:
		globe_controller.set_political_mode() 
