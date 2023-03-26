extends CharacterBody3D

@onready var pivot = $Pivot
@onready var mesh = $Pivot/MeshInstance3D

var cube_size = 1.0
var speed = 4.0
var rolling = false
	
func _physics_process(delta):
	var forward = Vector3.FORWARD
	if Input.is_action_pressed("ui_up"):
		roll(forward)
	if Input.is_action_pressed("ui_down"):
		roll(-forward)
	if Input.is_action_pressed("ui_right"):
		roll(forward.cross(Vector3.UP))
	if Input.is_action_pressed("ui_left"):
		roll(-forward.cross(Vector3.UP))
		
func roll(dir):
	# Do nothing if we're currently rolling.
	if rolling:
		return

	# Cast a ray to check for obstacles
	var space = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(mesh.global_transform.origin,
			mesh.global_transform.origin + dir * cube_size, collision_mask, [self])
	var collision = space.intersect_ray(ray)
	if collision:
		return

	rolling = true
	# Step 1: Offset the pivot.
	pivot.translate(dir * cube_size / 2)
	mesh.global_translate(-dir * cube_size / 2)
	
	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	var tween = create_tween()
	tween.tween_property(pivot, "transform",
			pivot.transform.rotated_local(axis, PI/2), 1 / speed)
	await tween.finished

	# Step 3: Finalize the movement and reset the offset.
	transform.origin += dir * cube_size
	var b = mesh.global_transform.basis
	pivot.transform = Transform3D.IDENTITY
	mesh.transform.origin = Vector3(0, cube_size / 2, 0)
	mesh.global_transform.basis = b
	rolling = false
