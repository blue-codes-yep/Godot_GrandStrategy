extends Control

signal start_game

# Called when the node enters the scene tree for the first time
func _ready():
	# Show cursor when in menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Connect UI elements if they exist
	if $StartButton:
		$StartButton.pressed.connect(_on_start_button_pressed)
	
	if $OptionsButton:
		$OptionsButton.pressed.connect(_on_options_button_pressed)
	
	if $QuitButton:
		$QuitButton.pressed.connect(_on_quit_button_pressed)

# Start game button handler
func _on_start_button_pressed():
	# Hide menu and show game UI
	hide()
	emit_signal("start_game")

# Options button handler
func _on_options_button_pressed():
	if $OptionsPanel:
		$OptionsPanel.visible = !$OptionsPanel.visible

# Quit button handler
func _on_quit_button_pressed():
	get_tree().quit()

# Function to show the menu again (e.g., when pausing or returning from game)
func show_menu():
	# Show cursor when in menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show() 