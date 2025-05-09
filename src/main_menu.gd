extends Control

signal start_game

# Called when the node enters the scene tree for the first time
func _ready():
	# Show cursor when in menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Connect UI elements if they exist
	if $ButtonsContainer/StartButton:
		$ButtonsContainer/StartButton.pressed.connect(_on_start_button_pressed)
		print("Start button connected")
	else:
		push_error("Start button not found!")
	
	if $ButtonsContainer/OptionsButton:
		$ButtonsContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
		print("Options button connected")
	else:
		push_error("Options button not found!")
	
	if $ButtonsContainer/QuitButton:
		$ButtonsContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
		print("Quit button connected")
	else:
		push_error("Quit button not found!")

# Start game button handler
func _on_start_button_pressed():
	# Hide menu and show game UI
	hide()
	emit_signal("start_game")

# Options button handler
func _on_options_button_pressed():
	if $OptionsPanel:
		$OptionsPanel.visible = !$OptionsPanel.visible
		print("Options panel visibility toggled")
	else:
		push_error("Options panel not found!")

# Quit button handler
func _on_quit_button_pressed():
	get_tree().quit()

# Function to show the menu again (e.g., when pausing or returning from game)
func show_menu():
	# Show cursor when in menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show() 
