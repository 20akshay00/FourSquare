extends Node2D
class_name Stack

@onready var border := $Border
@onready var input_area := $Area2D
@onready var cards := $Cards

@export var BASE_COLOR: Color
@export var HOVER_COLOR: Color
@export var INVALID_COLOR: Color

@export var duration: float = 0.2

var _color_tween: Tween
var _is_cursor_inside: bool = false
var _is_valid: bool = true

func _ready() -> void:
	border.self_modulate = BASE_COLOR
	input_area.mouse_entered.connect(_on_mouse_entered)
	input_area.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if _is_valid:
		_animate_color(HOVER_COLOR)
	else:
		_animate_color(INVALID_COLOR)
	
	_is_cursor_inside = true
	
func _on_mouse_exited() -> void:
	_animate_color(BASE_COLOR)
	_is_cursor_inside = false

func _animate_color(target_color: Color) -> void:
	if _color_tween: _color_tween.kill()
	_color_tween = create_tween()
	_color_tween.tween_property(border, "self_modulate", target_color, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _flash_color(target_color: Color, play_sfx: bool = true) -> void:
	if play_sfx: AudioManager.play_effect(AudioManager.invalid_sfx)
	if _color_tween: _color_tween.kill()
	_color_tween = create_tween()
	_color_tween.tween_property(border, "self_modulate", target_color, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_color_tween.tween_property(border, "self_modulate", BASE_COLOR, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("select") and _is_cursor_inside:
		if EventManager.turn_finished:
			if _is_valid:
				EventManager.turn_finished = false
				EventManager.stack_selected.emit(self)
			else:
				EventManager.invalid_move.emit(int(get_num_cards() < 4))
				_flash_color(INVALID_COLOR)
		else:
			_flash_color(INVALID_COLOR)

func flip() -> Tween:
	var top_card := get_top_card()
	if top_card != null:
		return top_card.flip()
	return null

func get_top_card() -> Card:
	var child = cards.get_child(-1)
	if child is Card:
		return child
	else:
		return null

func set_validity(val: bool) -> void:
	_is_valid = val
	if _is_cursor_inside:
		_animate_color(HOVER_COLOR)
	else:
		_animate_color(BASE_COLOR)
	
func get_num_cards() -> int:
	return cards.get_child_count()
