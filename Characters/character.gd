extends Node2D
class_name CharacterBehavior

@onready var tooltip: ToolTip = $ToolTip
@onready var animation: AnimationPlayer = $AnimationPlayer

var should_introduce: bool = true

@export var character_name: String
@export var likes: Array[String]
@export var loves: Array[String]

@export_category('Dialogue')
@export var introduction: Resource
@export var loved_food: Resource
@export var liked_food: Resource
@export var hated_food: Resource
@export var normal_dialogue: Resource

@export var do_introduction: bool = true

enum StoryEvent { first_talk, can_present_food, is_satisfied }

var current_story_events: Array[StoryEvent] = [StoryEvent.first_talk]

signal was_talked_to

func _ready():
	tooltip.create_tooltip_text('Talk to %s' % character_name)
	Dialogic.signal_event.connect(_handle_dialogic_signals)
	
func hovering_character():
	tooltip.show()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func not_hovering_character():
	tooltip.hide()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func hide_character():
	animation.play('fade_in')
	await animation.animation_finished
	
	hide()
	
func show_character():
	show()
	animation.play('fade_out')

func talked_to(viewport, event, shape_idx):
	
	if not event is InputEventMouseButton:
		return
		
	if Player.is_in_dialogue:
		return
	
	if event.pressed:
		hide_character()
		
		if should_introduce and do_introduction:
			should_introduce = false
			Player.start_dialogue(introduction.resource_path)
			return
		
		if Player.holding_item == null:
			Player.start_dialogue(normal_dialogue.resource_path)
			return
			
		if character_name == 'Andromeda':
			if Player.holding_item.item_name == 'Chocolate' or Player.holding_item.item_name == 'Cookies':
				if not Player.holding_item.excellent:
					Player.start_dialogue("res://Dialogue/Timeline/AndromedaNormal/chocolate.dtl")
					return
		
		Player.holding_item.queue_free()
		
		if character_name == 'Mayall':
			if Player.holding_item.item_name == 'Chocolate':
				Player.start_dialogue("res://Dialogue/Timeline/Mayall/chocolate.dtl")
				return
			
			if Player.holding_item.item_name == 'Cookies':
				Player.start_dialogue("res://Dialogue/Timeline/Mayall/cookies.dtl")
				return
		
		var can_love: bool = false
		
		if Player.holding_item.excellent:
			can_love = true
		
		# Makes it so that no matter what, Dubious Food can never be loved. I feel kind of bad for it.
		if Player.holding_item.item_name == 'Dubious Food':
			can_love = false
			
		if can_love:
			Player.start_dialogue(loved_food.resource_path)
			return
		
		if Player.holding_item.item_name in loves:
			Player.start_dialogue(loved_food.resource_path)
			return
			
		if Player.holding_item.item_name in likes:
			Player.start_dialogue(liked_food.resource_path)
			return
		
		Player.start_dialogue(hated_food.resource_path)

func _handle_dialogic_signals(function : String):
	if function == '%s_show_character' % character_name:
		show_character()
	if function == 'hide_character':
		hide_character()
