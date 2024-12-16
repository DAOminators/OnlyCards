extends Button

var texture_rect_node
var dynamic_texture : ImageTexture

var card_name = "SUBHROJYOTI SEN"
var tagline = "OPEN SOURCE CONTRIBUTOR"
var description = "SUBHROJYOTI IS A CUTE LITTLE CONCPROG\nHE LOVES TO PLAY WITH AI MODELS."
var scores = {
	"TOUCHNG GRASS": 0,
	"INTELLEGENCE": 100,
	"FEMALE INTERACTION": 1,
	"KAALA JAADHU": 100,
	"TEAM PLAYER": 100
}

func _ready():
	texture_rect_node = get_node("..")
	dynamic_texture = ImageTexture.new()
	generate_card_texture()

func generate_card_texture():
	# Create a blank image
	var img = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	
	# Load font
	var font_file = load("res://assets/Fonts/HomeVideo-BLG6G.ttf")
	if not font_file:
		print("Font file not found!")
		return
	
	var font = FontVariation.new()
	font.base_font = font_file
	
	# Prepare canvas 
	var canvas = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))  # Transparent
	
	# Drawing parameters
	var draw_color = Color.BLACK
	var y_pos = 50
	var x_pos = 20
	var font_size = 24
	
	# Draw card name
	canvas.draw_string(font, Vector2(x_pos, y_pos), card_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, draw_color)
	y_pos += 50
	
	# Draw tagline
	canvas.draw_string(font, Vector2(x_pos, y_pos), tagline, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.GRAY)
	y_pos += 50
	
	# Draw description
	canvas.draw_string(font, Vector2(x_pos, y_pos), description, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, draw_color)
	y_pos += 50
	
	# Draw scores
	for key in scores.keys():
		var score_text = key + ": " + str(scores[key])
		canvas.draw_string(font, Vector2(x_pos, y_pos), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, draw_color)
		y_pos += 30
	
	# Create texture
	dynamic_texture.create_from_image(canvas)
	texture_rect_node.texture = dynamic_texture

func _pressed():
	generate_card_texture()
