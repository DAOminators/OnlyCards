extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_label_focus_entered() -> void:
	#pass # Replace with function body.
	$Label.text = "Categor: " + str(Gobal.category)


func _on_done_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://UI/PlayScreen.tscn")
