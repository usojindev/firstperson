extends Interactable

@onready var audioplayer = $AudioStreamPlayer3D

func _on_interacted(_body):
	audioplayer.play()
	audioplayer.pitch_scale = randf_range(0.8,1.2)
