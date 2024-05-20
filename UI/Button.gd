extends Control
class_name ItemButton

var game: GameState

var button: Button
var item_texture: TextureRect
var item_name: Label
var item_cost: Label
var item_amount: Label
var item_index: int

var current_amount_of_items: int
var current_item_cost: int

func create_button(_texture: Texture2D, _item_name: String, _item_cost: int, _item_index: int, amount: int):
	
	button = $Panel
	item_texture = $Panel/TextureRect
	item_name = $Panel/ItemName
	item_amount = $Panel/Amount
	
	current_amount_of_items = amount
	current_item_cost = _item_cost
	
	item_texture.texture = _texture
	item_name.text = str(_item_cost) + ' Bolts'
	item_index = _item_index
	
	$ToolTip.create_tooltip_text(_item_name)

func _process(_delta):
	
	button.disabled = false
	
	if Player.money.amount < current_item_cost:
		button.disabled = true
		
	if current_amount_of_items <= 0:
		button.disabled = true
		
	item_amount.text = str(current_amount_of_items)

func on_button_pressed():
	
	if Player.is_in_dialogue:
		return
	
	$CashRegisterSFX.play()
	
	Player.money.amount -= current_item_cost
	current_amount_of_items -= 1
	
	var new_item = game.item_list[item_index]
	var item = game.load_item(new_item)
	game.spawn_items.add_child(item)


func _on_panel_mouse_entered():
	$ToolTip.show()

func _on_panel_mouse_exited():
	$ToolTip.hide()
