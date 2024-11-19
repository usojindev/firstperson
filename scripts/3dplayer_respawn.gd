extends Area3D


# respawn character if in area3D below stage.
func _on_Area3D_body_entered(body):
	if "player" in body.name:
			body.respawn()



