extends MeshInstance3D

var delegator : Player

func _on_area_3d_body_entered(body):
	if body.is_in_group("enemy"):
		print("damage from enemy: ",Time.get_ticks_msec())
		#body.whoami()
		if delegator and is_instance_valid(delegator):
			delegator.whoami()
