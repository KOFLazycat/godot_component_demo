class_name FadeTransition
extends ColorRect

## Emitted when the FadeTransition has completed covering the screen
signal cover_done

## Emitted when the FadeTransition has completed uncovering the screen
signal uncover_done

## The default number of seconds used to cover the screen, if none is passed to cover()
@export var default_cover_duration: float = 0.3

## The default number of seconds used to uncover the screen, if none is passed to uncover()
@export var default_uncover_duration: float = 0.2

## If the FadeTransition should cover the screen in _ready()
@export var initially_covering: bool = false

## The TransitionType to use when tweening the FadeTransition covering the screen
@export var cover_transition: Tween.TransitionType = Tween.TRANS_EXPO

## The EaseType to use when tweening the FadeTransition covering the screen
@export var cover_ease: Tween.EaseType = Tween.EASE_OUT

## The TransitionType to use when tweening the FadeTransition uncovering the screen
@export var uncover_transition: Tween.TransitionType = Tween.TRANS_EXPO

## The TransitionType to use when tweening the FadeTransition uncovering the screen
@export var uncover_ease: Tween.EaseType = Tween.EASE_OUT

var _current_tween: Tween = null

func _ready():
	if initially_covering:
		set_covered()


func cover(duration = default_cover_duration) -> void:
	if is_running():
		return
	show()
	var _current_tween = create_tween().set_trans(cover_transition).set_ease(cover_ease)
	_current_tween.tween_property(self, "modulate:a", 1.0, duration)
	await _current_tween.finished


func uncover(duration = default_uncover_duration) -> void:
	if is_running():
		return
	_current_tween = create_tween().set_trans(uncover_transition).set_ease(uncover_ease)
	_current_tween.tween_property(self, "modulate:a", 0.0, duration)
	await _current_tween.finished
	hide()


func set_covered() -> void:
	show()
	modulate.a = 1.0


func is_running() -> bool:
	return false if _current_tween == null else _current_tween.is_running()
