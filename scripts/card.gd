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
var following_mouse: bool = false
var displacement: float = 0.0
var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var last_mouse_pos: Vector2
var last_pos: Vector2
var velocity: Vector2

signal card_over_node(node_name)

@onready var front = $Front
@onready var back = $Back
@onready var card_texture: SubViewportContainer = $SubViewportContainer
@onready var shadow = $Shadow
@onready var collision_shape = $DestroyArea/CollisionShape2D

func _ready() -> void:
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	collision_shape.set_deferred("disabled", true)
	initialize_card("Card", "Card Tag", "https://via.placeholder.com/512", "Card Description", {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5})

func _process(delta: float) -> void:
	_state_drag(delta)
	_state_shadow(delta)
	_state_rotation(delta)
	_look_down()

# -----------------------------------------------
# High-Level State Functions
# -----------------------------------------------

func _state_hovered(is_entered: bool) -> void:
	if is_entered:
		_tween_hover(Vector2(1.2, 1.2), 0.5)
	else:
		_tween_hover(Vector2.ONE, 0.55)
		_reset_rotation_tween()

func _state_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.double_click:
		_reset_rotation_tween()
		flip_card()
		return
	following_mouse = event.is_pressed()
	if not following_mouse:
		_reset_rotation_tween()

func _state_drag(delta: float) -> void:
	if following_mouse:
		var mouse_pos: Vector2 = get_global_mouse_position()
		global_position = mouse_pos - (size / 2.0)

func _state_shadow(delta: float) -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / center.x))

func _state_rotation(delta: float) -> void:
	if not following_mouse:
		return
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	rotation = displacement

# -----------------------------------------------
# Initialization Function
# -----------------------------------------------

func initialize_card(new_name: String, new_tag: String, new_photo: String, new_description: String, new_properties: Dictionary) -> void:
	Name = new_name
	Tag = new_tag
	Photo = new_photo
	Description = new_description
	Properties = new_properties
	update_card_text()
	fetch_image()

# -----------------------------------------------
# Utility Functions
# -----------------------------------------------

func fetch_image() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	if http_request.request(Photo) != OK:
		push_error("HTTP request failed.")

func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Failed to download image.")
		return
	var image = Image.new()
	if image.load_png_from_buffer(body) != OK:
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
		if property_node and score_node:
			property_node.text = keys[i]
			score_node.text = str(Properties[keys[i]])

func flip_card() -> void:
	is_front = !is_front
	front.visible = is_front
	back.visible = not is_front

# -----------------------------------------------
# Tween Functions
# -----------------------------------------------

func _tween_hover(target_scale: Vector2, duration: float) -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", target_scale, duration)

func _reset_rotation_tween() -> void:
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)

# -----------------------------------------------
# Input Handlers
# -----------------------------------------------

func _on_gui_input(event: InputEvent) -> void:
	_state_click(event)
	if following_mouse or not event is InputEventMouseMotion:
		return
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	card_texture.material.set_shader_parameter("x_rot", rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y)))
	card_texture.material.set_shader_parameter("y_rot", rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x)))

func _on_mouse_entered() -> void:
	_state_hovered(true)

func _on_mouse_exited() -> void:
	_state_hovered(false)

func _look_down() -> void:
	var space_state = get_world_2d().direct_space_state
	var ip := PhysicsPointQueryParameters2D.new()
	ip.position = position
	var result = space_state.intersect_point(ip, 32)
	for hit in result:
		if hit.collider:
			emit_signal("card_over_node", hit.collider.name)
			print(hit.collider.name)
			break
