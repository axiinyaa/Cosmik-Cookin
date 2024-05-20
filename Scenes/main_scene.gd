extends Node2D
class_name GameState

@export var item_list: Array[Dictionary]
@onready var get_camera: Camera2D = $Camera2D
@onready var spawn_items := $MainGame/Kitchen/SpawnedObjects
@onready var recipe_book = $MainGame/RecipeBook

@onready var kitchen = $MainGame/Kitchen
@onready var counter = $MainGame/Counter

@onready var holding = $PlayerHolding

@onready var phone = $MainGame/Kitchen/Phone

@onready var andromeda_tutorial = $MainGame/Counter/AndromedaTutorial
@onready var andromeda = $MainGame/Counter/Andromeda
@onready var malin = $MainGame/Counter/Malin
@onready var mayall = $MainGame/Counter/Mayall

@onready var to_kitchen = $MainGame/Counter/GoToKitchen

@onready var fade = $MainGame/Fade/AnimationPlayer

@onready var music = $AudioStreamPlayer

@onready var timeskip_button = $MainGame/Counter/Timeskip

var has_talked_to_character = false

var current_dialog

func load_item(item: Dictionary):
	var i: ItemObject = load('res://Objects/draggable_object.tscn').instantiate()
	var n: ItemObject = i.duplicate()
	
	if item.name == 'Fresh Basil':
		pass
	
	n.set_variables(item.name, item.cost, item.can_buy, item.recipe, self, item.rare, item.excellent)
	return n

func create_item(item_name: String, can_purchase: bool, cost: int = 0, recipe: Array[String] = [], rare: bool = false, excellent: bool = false):
	item_list.append({'name':item_name, 'can_buy':can_purchase, 'cost':cost, 'recipe':recipe, 'rare':rare, 'excellent':excellent})

func create_items():
	create_item('Flour', true, 2) #0
	create_item('Salt', true, 2) #1
	create_item('Sugar', true, 3) #2
	create_item('Tomato', true, 3) #3
	create_item('Butter', true, 3) #4
	create_item('Meat', true, 4) #5
	create_item('Vegetables', true, 4) #6
	create_item('Cheese', true, 4) #7
	create_item('Yeast', true, 5) #8
	create_item('Cacao Beans', true, 6) #9
	create_item('Fresh Basil', true, 6, ['Not a recipe'], true) #10
	create_item('Starbit Sprinkles', true, 30, ['Not a recipe'], true) #11
	create_item('Dubious Food', false) #12
	
	# Recipes ------------------------------------------------------------------
	
	create_item('Dough', false, 0, ['Flour', 'Yeast', 'Salt'])
	create_item('Bagel Sandwich', false, 0, ['Dough', 'Meat'])
	create_item('Bagel Sandwich', false, 0, ['Dough', 'Meat', 'Cheese'], false, true)
	create_item('Tomato Purée', false, 0, ['Tomato', 'Tomato', 'Salt'])
	create_item('Tomato Soup', false, 0, ['Tomato Purée', 'Vegetables'])
	create_item('Tomato Soup', false, 0, ['Tomato Purée', 'Vegetables', 'Fresh Basil'], false, true)
	create_item('Chocolate', false, 0, ['Cacao Beans', 'Sugar'])
	create_item('Chocolate', false, 0, ['Cacao Beans', 'Sugar', 'Salt'], false, true)
	create_item('Cookies', false, 0, ['Chocolate', 'Flour', 'Butter'])
	create_item('Pizza', false, 0, ['Dough', 'Tomato Purée', 'Cheese', 'Meat'])
	create_item('Pizza', false, 0, ['Dough', 'Tomato Purée', 'Cheese', 'Meat', 'Vegetables'])
	create_item('Pizza', false, 0, ['Dough', 'Tomato Purée', 'Cheese', 'Meat', 'Fresh Basil'])
	create_item('Pizza', false, 0, ['Dough', 'Tomato Purée', 'Cheese', 'Meat', 'Vegetables', 'Fresh Basil'], false, true)

func _ready():
	create_items()
	to_kitchen.hide()
	Dialogic.signal_event.connect(_handle_dialogic_signals)
	
func _process(delta):
	if Input.is_key_pressed(KEY_2):
		phone.show()
	
func move_to_kitchen():
	
	await fade_in()
	
	to_kitchen.show()
	recipe_book.show()
	
	for child in spawn_items.get_children():
		child.queue_free()
	
	counter.hide()
	
	var items_to_spawn = [item_list[0], item_list[1], item_list[5], item_list[8]]
	
	for items in items_to_spawn:
		var new_item = load_item(items)
		spawn_items.add_child(new_item)
	
	kitchen.show()
	
	await Player.wait_for(0.5)
	
	await fade_out()
	
	Player.start_dialogue('tutorial')

func _dialog_ended():
	pass

func _handle_dialogic_signals(function : String):
	
	if 'add_recipe' in function:
		var recipe_data = function.split('|')
		add_recipe(recipe_data[1], recipe_data[2].split('>'))
	
	if function == 'andromeda_tip_jar':
		Player.add_bolts(20)
	if function == 'tip_jar_liked':
		Player.add_bolts(10)
	if function == 'tip_jar_loved':
		Player.add_bolts(15)
		
	if function == 'next_scene':
		next_scene()
	
	if function == 'hated_food':
		unhappiness += 1
	
	if function == 'move_to_kitchen':
		move_to_kitchen()
	if function == 'malin_section':
		malin_section()
	if function == 'mayall_section':
		check_malin_happiness()
	if function == 'mayall_section_two':
		Dialogic.VAR.current_section = 'mayall 2'
		next_scene()
	if function == 'finished':
		check_mayall_happiness()
		
	if function == 'give_cacao_bean':
		var new_item = load_item(item_list[9])
		spawn_items.add_child(new_item)
		
	if function == 'andromeda_basil':
		var new_item = load_item(item_list[10])
		spawn_items.add_child(new_item)
		new_item = load_item(item_list[10])
		spawn_items.add_child(new_item)
		new_item = load_item(item_list[10])
		spawn_items.add_child(new_item)
		
	if function == 'fade_in':
		fade_in()
		
	if function == 'restart':
		get_tree().reload_current_scene()
		
	if function == 'show_timeskip':
		timeskip_button.show()
		
func add_recipe(recipe_name, recipe_data):
	recipe_book.add_recipe(recipe_name, recipe_data)
		
var made_malin_happy: bool = false
var made_mayall_happy: bool = false

var happiness: int = 1
var unhappiness: int = 0

func check_malin_happiness():
	if made_malin_happy:
		next_scene()
		return
	
	made_malin_happy = true
	happiness += 1
	Dialogic.VAR.current_section = 'mayall'
	next_scene()
	
func check_mayall_happiness():
	if made_mayall_happy:
		next_scene()
		return
	
	made_mayall_happy = true
	happiness += 1
	next_scene()

var scene: int = 0
func next_scene(fade: bool = true):
	if fade:
		await fade_in()
		await get_tree().create_timer(1).timeout
		counter.hide()
		kitchen.show()
	
	scene += 1
	
	if scene > 2:
		scene = 0
		
	print(scene)
		
	if scene == 0:
		andromeda.show_character()
	if scene == 1:
		malin.show_character()
	if scene == 2:
		mayall.show_character()
	
	await fade_out()
	
	if happiness > 2:
		Player.start_dialogue("res://Dialogue/Timeline/win.dtl")
		
	if unhappiness > 2:
		Player.start_dialogue("res://Dialogue/Timeline/lose.dtl")
	
func malin_section():
	phone.show()
	timeskip_button.show()
	Dialogic.VAR.current_section = 'malin'
	await next_scene()
	to_kitchen.show()

func fade_in():
	fade.play("fade_in")
	await fade.animation_finished
		
func fade_out():
	fade.play("fade_out")
	await fade.animation_finished

func back_to_kitchen():

	if Player.is_in_dialogue:
		return

	if Player.holding_item != null:
		Player.holding_item.can_drop = true
	
	await fade_in()
	counter.hide()
	kitchen.show()
	await fade_out()

func back_to_counter():
		
	if Player.is_in_dialogue:
		return

	if Player.holding_item != null:
		Player.holding_item.can_drop = false
	
	await fade_in()
	kitchen.hide()
	counter.show()
	await fade_out()

func timeskip():
	
	if Player.is_in_dialogue:
		return
	
	await fade_in()
	
	andromeda.hide()
	malin.hide()
	mayall.hide()
	
	next_scene(false)
