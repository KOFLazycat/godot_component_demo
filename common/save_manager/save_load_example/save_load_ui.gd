extends Node2D

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var save_custom_button: Button = %SaveCustomButton
@onready var load_custom_button: Button = %LoadCustomButton
@onready var save_file_name: LineEdit = %SaveFileName

func _ready():
	save_button.button_up.connect(SaveManager.quicksave)
	load_button.button_up.connect(SaveManager.load_quicksave)
	save_custom_button.button_up.connect(save_custom)
	load_custom_button.button_up.connect(load_custom)
	

func save_custom():
	SaveManager.save_game_with_filename(save_file_name.text)

func load_custom():
	SaveManager.load_game_with_filename(save_file_name.text)
