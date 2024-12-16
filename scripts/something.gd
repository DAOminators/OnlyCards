extends Node2D  # Parent Node that contains the cards

# Path to the Card scene
const CARD_SCENE_PATH = "res://scenes/card_new.tscn"

# Number of cards to create
var n := 2 

func _ready():
	var card_scene = load(CARD_SCENE_PATH)  # Load the card scene
	
	for i in range(n):
		var card_instance = card_scene.instantiate()  # Instantiate the card scene
		add_child(card_instance)  # Add the instance to the current scene
		
		# Optionally configure card_instance (e.g., position)
		card_instance.position = Vector2(100 + i * 120, 300)  # Example horizontal spacing

		# If the card script has custom variables, set them here
		if card_instance.has_method("set_card_data"):
			card_instance.set_card_data("Card %d" % i)
