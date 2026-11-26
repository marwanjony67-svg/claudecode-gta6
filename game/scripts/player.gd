extends CharacterBody3D

@export var move_speed: float = 6.0
@export var acceleration: float = 18.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera_rig: Node3D = $CameraRig

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_rig.rotate_y(-event.relative.x * mouse_sensitivity)
        camera_rig.rotation.x = clampf(camera_rig.rotation.x - event.relative.y * mouse_sensitivity, -0.8, 0.55)
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (camera_rig.global_basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
    direction.y = 0.0
    direction = direction.normalized()

    var target := direction * move_speed
    velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
    move_and_slide()
