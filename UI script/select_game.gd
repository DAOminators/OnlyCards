extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_createGame_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://UI/AiQues.tscn")
	


func _on_category_text_changed(new_text: String) -> void:
	#pass # Replace with function body.
	Gobal.category=new_text
