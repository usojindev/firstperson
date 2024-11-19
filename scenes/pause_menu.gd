extends Control

var _is_paused:bool = false:
	set = set_paused
	
@onready var pixelation = $"../head/headtilt/Camera3d/pixel shader"

	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused
	
	
	
func set_paused(value:bool) -> void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused




func _on_resume_pressed() -> void:
	_is_paused = false
	

func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()


func _on_quit_to_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_pixelation_toggle_toggled(_toggled_on):
	pixelation.visible = !pixelation.visible


func _on_fullscreen_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(3,0)
	else:
		DisplayServer.window_set_mode(0,0)
