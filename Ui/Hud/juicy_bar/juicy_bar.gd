class_name JucyBar extends HudBase

@export var top_layer_bar: ProgressBar
@export var bottom_layer_bar: ProgressBar

@export var min_value: float
@export var max_value: float
@export var current_value: float
@export var top_layer_bar_time: float = 0.2
@export var top_layer_bar_delay: float = 0.0
@export var bottom_layer_bar_time: float = 0.2
@export var bottom_layer_bar_delay: float = 0.0

@onready var test_button: Button = $TestButton


func _ready() -> void:
	current_value = max_value
	set_progress_bar_default_values(top_layer_bar)
	set_progress_bar_default_values(bottom_layer_bar)
	test_button.pressed.connect(on_test_button_pressed)


func set_progress_bar_default_values(bar: ProgressBar) -> void:
	bar.min_value = min_value
	bar.max_value = max_value
	bar.value = current_value


func change_current_value(value: float) -> void:
	current_value = clamp(value, min_value, max_value)
	run_juicy_tween(top_layer_bar, current_value, top_layer_bar_time, top_layer_bar_delay)
	run_juicy_tween(bottom_layer_bar, current_value, bottom_layer_bar_time, bottom_layer_bar_delay)


func run_juicy_tween(bar: ProgressBar, value: float, length: float, delay: float) -> void:
	var tween = create_tween()
	tween.tween_property(bar, "value", value, length).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)


func on_test_button_pressed() -> void:
	change_current_value(current_value - 10)
