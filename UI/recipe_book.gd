extends Control

@onready var recipes = $Book/RecipeList/Recipes
@onready var recipe_notification = $RecipeNotification

const RECIPE = preload("res://UI/recipe_book_recipe.tscn")

func set_recipe_notification(recipe_name, update = false):
	if update:
		recipe_notification.text = "'" + recipe_name + "' updated in recipe book!"
	else:
		recipe_notification.text = "'" + recipe_name + "' added to recipe book!"
	
	await get_tree().create_timer(5).timeout
	
	recipe_notification.text = ''

func add_recipe(recipe_name: String, recipe_data: Array):
	for child in recipes.get_children():
		var item: RecipeBookRecipe = child
		
		if recipe_name == item.name:
			
			if recipe_data == item._recipe_data:
				return
			
			item.update_data(recipe_name, recipe_data)
			set_recipe_notification(recipe_name, true)
			return
			
	var item: RecipeBookRecipe = RECIPE.instantiate()
	
	item.name = recipe_name
	item.update_data(recipe_name, recipe_data)
	
	recipes.add_child(item)
	set_recipe_notification(recipe_name, false)

func on_button_toggle(toggled_on):
	
	if Player.is_in_dialogue:
		$Toggle.button_pressed = false
		return
	
	$Book.visible = toggled_on
