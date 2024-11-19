extends Area3D
var scene =  preload("res://scenes/a city.tscn").instantiate()

# Respawn player upon entering this area, used for respawning player when falling. 
	
func _on_AREA3D_body_entered(body):
	if "player" in body.name(Area3D):
		body.respawn()
	
