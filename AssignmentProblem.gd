extends Control


func _on_hungarian_algorithm_pressed():
	get_tree().change_scene_to_file("res://HungarianAlgorithm/HungarianAlgorithm.tscn")


func _on_branch_bound_method_pressed():
	get_tree().change_scene_to_file("res://Branch&BoundMethod/Branch&BoundMethod.tscn")


func _on_exit_pressed():
	get_tree().quit()
