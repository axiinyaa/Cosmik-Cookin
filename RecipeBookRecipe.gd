extends Control
class_name RecipeBookRecipe

@export var l_title: Label
@export var l_recipe: Label

var _recipe_data: Array

# Called when the node enters the scene tree for the first time.
func update_data(recipe_name: String, recipe_data: Array):
	
	_recipe_data = recipe_data
	
	l_title.set_text(recipe_name)
	
	var recipe = ''
	
	for item in recipe_data:
		if item == '?':
			recipe += '____ > '
			continue
			
		if item == '*':
			recipe += '⭐ > '
			continue
			
		recipe += item + ' > '
			
	recipe = recipe.rstrip(' > ')
	
	l_recipe.text = recipe

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
