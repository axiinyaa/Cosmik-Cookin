extends RigidBody2D
class_name ItemObject

var item_name: String
var item_cost: int
var can_purchase: bool
var recipe: Array[String]

var excellent: bool = false
var can_drop: bool = true

var stock_amount: int = 10

@onready var collect_sfx: AudioStream = preload("res://Audio/pop-39222.mp3")
@onready var drop_sfx: AudioStream = preload("res://Audio/stop-13692.mp3")

var game: GameState
var sprite: Sprite2D
var audio: AudioStreamPlayer

func set_variables(_name, _cost, _purchasable, _recipe, _game, _rare, _excellent):
	item_name = _name
	item_cost = _cost
	can_purchase = _purchasable
	recipe = _recipe
	game = _game
	
	if _rare:
		stock_amount = 3
	
	excellent = _excellent
	sprite = $Sprite
	get_tooltip = $ToolTip
	audio = $AudioStreamPlayer
	
	if excellent:
		get_tooltip.create_tooltip_text('[color=light_blue][wave]Excellent ' + item_name)
	else:
		get_tooltip.create_tooltip_text(item_name)
		
	if item_name == 'Dubious Food':
		get_tooltip.create_tooltip_text('[color=light_gray][shake]' + item_name)
		
	get_tooltip.hide()
	
	if excellent:
		sprite.texture = load('res://Textures/Food/Excellent Food/%s.png' % item_name)
		
		if not sprite.texture:
			sprite.texture = load('res://Textures/Food/%s.png' % item_name)
	else:
		sprite.texture = load('res://Textures/Food/%s.png' % item_name)

var dragging: bool = false
var get_tooltip: ToolTip

func _process(delta):
	if dragging:
		freeze = true
		global_position = game.get_camera.get_global_mouse_position()
	else:
		freeze = false

func _on_draggable_region_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and Player.holding_item == null:
			audio.stream = collect_sfx
			audio.play()
			dragging = true
			Player.holding_item = self
			set_collision_layer_value(1, false)
			reparent(game.holding)
		elif event.pressed and Player.holding_item == self and can_drop:
			dragging = false
			Player.holding_item = null
			set_collision_layer_value(1, true)
			reparent(game.spawn_items)

func _on_draggable_region_mouse_entered():
	get_tooltip.show()

func _on_draggable_region_mouse_exited():
	get_tooltip.hide()
