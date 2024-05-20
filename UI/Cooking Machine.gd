extends StaticBody2D

@export var game: GameState

@onready var spawn_item := $Cooker/SpawnItem
@onready var cooking_slots := $Cooker/CookingSlots
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var drop_sfx: AudioStream = preload("res://Audio/stop-13692.mp3")
@onready var click: AudioStream = preload("res://Audio/button-124476.mp3")

@onready var button_cook = $Cooker/CookerCook
@onready var button_eject = $Cooker/CookerDiscard

var inputted_ingredients: Array[Dictionary]

var can_interact: bool = true

func add_to_slot(texture: Texture2D):
	for slot in cooking_slots.get_children():
		if not slot.has_ingredient:
			slot.has_ingredient = true
			slot.texture_rect.texture = texture
			slot.material.set('shader_parameter/is_on', true)
			return
			
func clear_slots():
	for slot in cooking_slots.get_children():
		slot.has_ingredient = false
		slot.texture_rect.texture = null
		slot.material.set('shader_parameter/is_on', false)
		inputted_ingredients.clear()
		
func _ready():
	clear_slots()

func cooking_machine_selected():
	
	if Player.is_in_dialogue:
		return
	
	if not Player.holding_item == null:
		
		if not can_interact:
			return
		
		var i: ItemObject = Player.holding_item
		
		var add_item = {'name':i.item_name, 'can_buy':i.can_purchase, 'cost':i.item_cost, 'recipe':i.recipe, 'rare':false, 'excellent':i.excellent}
		
		inputted_ingredients.append(add_item)
		
		add_to_slot(Player.holding_item.sprite.texture)
		
		Player.holding_item.queue_free()
		
		audio.stream = drop_sfx
		audio.play()

func cancel():
	
	if not can_interact:
		return
		
	audio.stream = click
	audio.volume_db = 3
	audio.play()
		
	can_interact = false
	
	button_eject.material.set('shader_parameter/is_on_red', true)
	
	animation.play("door_close")
	await animation.animation_finished
	
	for ingredient in inputted_ingredients:
		spawn_item.add_child(game.load_item(ingredient))
		
	button_eject.material.set('shader_parameter/is_on_red', false)
	
	clear_slots()
	
	can_interact = true
	
	animation.play("door_open")
	await animation.animation_finished

func cook():

	if not can_interact:
		return
		
	audio.stream = click
	audio.volume_db = 3
	audio.play()
	
	can_interact = false
	
	button_cook.material.set('shader_parameter/is_on_green', true)
	
	animation.play("door_close")
	await animation.animation_finished
	
	var item_recipe: Array[String] = []
	
	var excellent: bool = false
	
	for ingredient in inputted_ingredients:
		if ingredient.name == 'Starbit Sprinkles':
			excellent = true
			continue
			
		if ingredient.excellent:
			excellent = true
			
		item_recipe.append(ingredient.name)
	
	var item_to_spawn: Dictionary = {}
	
	for item in game.item_list:
		if item_recipe == item.recipe:
			item_to_spawn = item
			
			game.add_recipe(item.name, item.recipe)
			
			if item.excellent:
				excellent = true
			break
		else:
			item_to_spawn = game.item_list[12]
			
	if len(inputted_ingredients) == 0:
		item_to_spawn = game.item_list[12]

	item_to_spawn.excellent = excellent
	
	var get_item = game.load_item(item_to_spawn)
	
	spawn_item.add_child(get_item)
		
	clear_slots()
	
	audio.volume_db = 0
	
	animation.play("cooking")
	await animation.animation_finished
	
	button_cook.material.set('shader_parameter/is_on_green', false)
	
	can_interact = true
	
	animation.play("door_open")
	await animation.animation_finished
	
	if get_item != null:
		if get_item.item_name == 'Pizza' and get_item.excellent:
			Player.start_dialogue("res://Dialogue/Timeline/Mayall/pizza.dtl")
