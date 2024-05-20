extends Control
class_name Phone

@export var game: GameState

@onready var box_container: VBoxContainer = $Panel/Control/VBoxContainer
@onready var first_row: HBoxContainer = $Panel/Control/VBoxContainer/FirstRow
@onready var second_row: HBoxContainer = $Panel/Control/VBoxContainer/SecondRow
@onready var third_row: HBoxContainer = $Panel/Control/VBoxContainer/ThirdRow

@onready var phone_toggle: Button = $Panel/PhoneToggle
@onready var animation: AnimationPlayer =  $AnimationPlayer

var phone_open: bool = false

var i = 0

func _ready():
	await Player.wait_for(1)
	
	for item in game.item_list:
		
		if not item.can_buy:
			continue
		
		var item_button = load("res://UI/item_button.tscn").instantiate()
		
		var get_item: ItemObject = game.load_item(item)
		
		item_button.game = game
		item_button.create_button(get_item.sprite.texture, get_item.item_name, get_item.item_cost, i, get_item.stock_amount)
		
		i += 1
		
		if len(first_row.get_children()) < 4:
			first_row.add_child(item_button)
			continue
			
		if len(second_row.get_children()) < 4:
			second_row.add_child(item_button)
			continue
			
		if len(third_row.get_children()) < 4:
			third_row.add_child(item_button)
			continue

@onready var open_sfx: AudioStream = preload("res://Audio/phone open.mp3")
@onready var close_sfx: AudioStream = preload("res://Audio/phone close.mp3")

@onready var sfx := $PhoneSFX 

func _on_phone_toggle_pressed():
	if phone_open:
		sfx.stream = close_sfx
		animation.play('pull_up')
		phone_toggle.text = 'Press to Pull Up'
		phone_open = false
	else:
		sfx.stream = open_sfx
		animation.play('pull_down')
		phone_toggle.text = 'Press to Pull Down'
		phone_open = true
	
	sfx.play()
