extends Control
class_name ToolTip

func create_tooltip_text(text: String):
	hide()
	$TooltipBackground/Label.text = text
