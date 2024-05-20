extends Control
class_name TipJar

@export var empty: Texture2D
@export var low: Texture2D
@export var half: Texture2D
@export var full: Texture2D

@onready var jar := $Container/Jar
@onready var amount_jar := $Container/Label
@onready var animation := $AnimationPlayer
@onready var sfx := $AudioStreamPlayer

var amount: int = 0

func add_money():
	sfx.volume_db = 0
	sfx.play()
	amount += Player.held_money
	Player.held_money = 0

func _process(delta):
	if amount > 50:
		amount = 50
		
	if amount < 0:
		amount = 0
	
	if amount == 0:
		jar.texture = empty
	
	if amount > 0:
		jar.texture = low
	if amount >= 25:
		jar.texture = half
	if amount >= 50:
		jar.texture = full
	
	amount_jar.text = '%s Bolt(s)' % amount
