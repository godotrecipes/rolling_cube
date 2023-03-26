extends Node3D

var cam_offset = Vector3(0, 4, 4)
var cam_speed = 3.0

func _process(delta):
	$Camera3D.position = lerp($Camera3D.position, $Cube.position + cam_offset, cam_speed * delta)
