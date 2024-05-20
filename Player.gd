extends Node

var holding_item: ItemObject = null

var held_money: int = 0
@onready var money: TipJar = get_tree().get_first_node_in_group('tip_jar')

var is_in_dialogue: bool = false

func _ready():
	Dialogic.timeline_ended.connect(dialogue_ended)

func add_bolts(amount: int):
	held_money = amount
	money.animation.play('tip_jar_shake')

func wait_for(seconds: float):
	await get_tree().create_timer(seconds).timeout

func start_dialogue(dialogue: String):
	
	is_in_dialogue = true
	
	var current_dialog = Dialogic.start(dialogue)
	add_child(current_dialog)
	
func dialogue_ended():
	is_in_dialogue = false

func check_story_events(character: CharacterBehavior) -> bool:
	if character.character_name == 'Andromeda':
		if not character.StoryEvent.first_talk in character.current_story_events:
			return true
		
		character.current_story_events.erase(character.StoryEvent.first_talk)
		character.current_story_events.append(character.StoryEvent.can_present_food)
		
		character.hide()
		start_dialogue('introduction')
		return false
	
	return true
