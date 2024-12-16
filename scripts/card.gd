extends Button

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0

@export_category("Oscillator")
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

@export var front_texture: Texture
@export var back_texture: Texture

var Name: String = "Card"
var Tag: String = "Card Tag"
var Photo: String = "https://via.placeholder.com/512"
var Description: String = "Card Description"
var Properties: Dictionary = {
	"a": 1,
	"b": 2,
	"c": 3,
	"d": 4,
	"e": 5
}

var is_front: bool = true

var displacement: float = 0.0
var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2

@onready var front = $Front
@onready var back = $Back

@onready var card_texture: SubViewportContainer = $SubViewportContainer
@onready var shadow = $Shadow
@onready var collision_shape = $DestroyArea/CollisionShape2D


func _ready() -> void:
	# Convert to radians because lerp_angle uses radians
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	collision_shape.set_deferred("disabled", true)
	
	# Nodes
	update_card_text()
	
	# Fetch image
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	var error = http_request.request(Photo)
	if error != OK:
		push_error("HTTP request failed.")

# Handle image download
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Failed to download image.")
		return
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load image.")
		return
	var texture = ImageTexture.create_from_image(image)
	$Front/Photo2.texture = texture

func update_card_text() -> void:
	$Front/Name.text = Name
	$Front/Tag.text = Tag
	$Back/Description.text = Description
	$Back/Name2.text = Name
	$Back/Tag2.text = Tag
	
	var keys = Properties.keys()
	for i in range(5):
		var property_node = $Back.get_node("PROPERTY%d" % (i + 1))
		var score_node = $Back.get_node("SCORE%d" % (i + 1))
		
		if property_node and score_node and property_node is Label and score_node is Label:
			property_node.text = keys[i]
			score_node.text = str(Properties[keys[i]])
		else:
			push_error("PROPERTY%d or SCORE%d not found or invalid." % [i + 1, i + 1])


func _process(delta: float) -> void:
	rotate_velocity(delta)
	follow_mouse(delta)
	handle_shadow(delta)

func destroy() -> void:
	card_texture.use_parent_material = true
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()
	tween_destroy = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.tween_property(material, "shader_parameter/dissolve_value", 0.0, 2.0).from(1.0)
	tween_destroy.parallel().tween_property(shadow, "self_modulate:a", 0.0, 1.0)

func rotate_velocity(delta: float) -> void:
	if not following_mouse:
		return
	var center_pos: Vector2 = global_position - (size / 2.0)
	velocity = (position - last_pos) / delta
	last_pos = position
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	rotation = displacement

func handle_shadow(delta: float) -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / center.x))

func follow_mouse(delta: float) -> void:
	if not following_mouse:
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size / 2.0)

func flip_card() -> void:
	is_front = !is_front
	front.visible = is_front
	back.visible = not is_front

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.is_pressed():
		following_mouse = true
	else:
		following_mouse = false
		collision_shape.set_deferred("disabled", false)
		if tween_handle and tween_handle.is_running():
			tween_handle.kill()
		tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_handle.tween_property(self, "rotation", 0.0, 0.3)
		flip_card()

func _on_gui_input(event: InputEvent) -> void:
	handle_mouse_click(event)
	if following_mouse or not event is InputEventMouseMotion:
		return
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)

func _on_mouse_entered() -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)

func _on_mouse_exited() -> void:
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
