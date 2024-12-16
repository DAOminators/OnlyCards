extends Area2D

var deck = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area):
	if area.is_in_group("cards"):
		var parent_node = area.get_parent()
		print("Card's parent node:", parent_node)
		if parent_node.global_position != position:
			parent_node.global_position = global_position + len(deck) * Vector2(100,0)
