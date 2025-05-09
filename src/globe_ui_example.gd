extends Control

# Reference to the globe controller node
@export var globe_controller: Node

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect UI button signals if needed
	if $NormalModeButton:
		$NormalModeButton.pressed.connect(_on_normal_mode_pressed)
	
	if $PoliticalModeButton:
		$PoliticalModeButton.pressed.connect(_on_political_mode_pressed)
	
	if $DebugModeButton:
		$DebugModeButton.pressed.connect(_on_debug_mode_pressed)
	
	if $BorderIntensitySlider:
		$BorderIntensitySlider.value_changed.connect(_on_border_intensity_changed)

# UI button handlers
func _on_normal_mode_pressed():
	if globe_controller:
		globe_controller.set_normal_mode()

func _on_political_mode_pressed():
	if globe_controller:
		globe_controller.set_political_mode()

func _on_debug_mode_pressed():
	if globe_controller:
		# Use channel 0 (red) for debug visualization
		globe_controller.set_debug_mode(0)

func _on_border_intensity_changed(value):
	if globe_controller:
		globe_controller.set_border_intensity(value)

# Example of keyboard shortcuts to switch modes
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# Normal mode
				if globe_controller:
					globe_controller.set_normal_mode()
			KEY_2:
				# Political mode
				if globe_controller:
					globe_controller.set_political_mode()
			KEY_3:
				# Debug mode
				if globe_controller:
					globe_controller.set_debug_mode(0)
			KEY_4:
				# Increase border intensity
				if globe_controller:
					var new_intensity = globe_controller.border_intensity + 0.1
					globe_controller.set_border_intensity(new_intensity)
			KEY_5:
				# Decrease border intensity
				if globe_controller:
					var new_intensity = globe_controller.border_intensity - 0.1
					globe_controller.set_border_intensity(new_intensity) 
