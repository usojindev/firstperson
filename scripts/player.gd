extends CharacterBody3D

# Player nodes

@onready var head = $head
@onready var standing_collision = $standing_collision
@onready var crouching_collision = $crouching_collision
@onready var ray_cast_3d = $RayCast3D
@onready var flashlight = $head/flashlight
@onready var headtilt = $head/headtilt
@onready var camera = $head/headtilt/Camera3d
# Speed variables

var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0

# Movement variables

var crouching_depth = -0.5 
var lerp_speed = 10.0
const jump_velocity = 4.5

# Bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#footstep variables
var can_play: bool = true
signal step

# Input variables

const mouse_sensitivity = 0.125
var direction = Vector3.ZERO


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func respawn():
	get_tree().reload_current_scene()

# Lock mouse input to game window on game load
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
# Get motion input from mouse for camera/player movement. 
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
	
	if event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
# Deprecated code, that may be useful at some point?
	if Input.is_action_pressed("click"):
		if Input.get_mouse_mode() ==Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
func _physics_process(delta):
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# Handle movement states.

	# Crouching
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.8 + crouching_depth,delta*lerp_speed)
		
		standing_collision.disabled = true
		crouching_collision.disabled = false
	
	elif !ray_cast_3d.is_colliding():
		
	# Standing
	
		standing_collision.disabled = false
		crouching_collision.disabled = true
		
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		
		if Input.is_action_pressed("sprint"):
	# Sprinting 
			current_speed = sprinting_speed
		else: 
	# Walking
			current_speed = walking_speed
	
	# flashlight toggle
	if Input.is_action_just_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
		$head/flashlight/AudioStreamPlayer3D.play()
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		

				
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration, using lerp functions
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	var low_pos = BOB_AMP - 0.05
	# Check if we have reached a high point so we restart can_play
	if pos.y > -low_pos:
		can_play = true
	
	#check if the head position has reached a low point then turn off can play to avoid
	# multiple spam of the emit signal
	if pos.y < -low_pos and can_play:
		can_play = false
		step.emit()
		
	return pos
