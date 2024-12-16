extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_cards()

@onready var bottom_container = $Panel2/HBoxContainer

var card_scene = preload("res://scenes/card.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_Deck_pressed() -> void:
	#pass # Replace with function body.
	get_tree().change_scene_to_file("res://scenes/UI/DeckScreen.tscn")
	
func spawn_cards():
	for i in range(2):
		var card = card_scene.instantiate()
		bottom_container.add_child(card)
