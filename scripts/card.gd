extends Node2D
class_name Card

@export var data: CardData
@onready var sprite := $Sprite
@onready var input_area := $Area2D

@export var FLIP_DURATION: float = 0.2
@export var FLIP_SCALE_Y: float = 1.1
@export var MOVE_DURATION: float = 0.4
@export var MOVE_SCALE: Vector2 = Vector2(1.1, 1.1)
@export var MOVE_SCALE_DURATION: float = 0.2

var is_revealed: bool = false # game logic state
var _is_showing_face: bool = false # visual state
var _flip_tween: Tween
var _move_tween: Tween

func _ready() -> void:
	_is_showing_face = is_revealed
	sprite.region_rect = data.atlas_rects[0 if _is_showing_face else 1]

	flip()
	input_area.mouse_entered.connect(_on_mouse_entered)
	input_area.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	animate_to_face(true)

func _on_mouse_exited():
	if not is_revealed:
		animate_to_face(false)

func flip(val = null) -> void:
	if val != null:
		is_revealed = val
		animate_to_face(val)
	
	is_revealed = !is_revealed
	animate_to_face(is_revealed)

func animate_to_face(target_face_up: bool) -> void:
	if _is_showing_face == target_face_up: 
		return
	
	_is_showing_face = target_face_up
	if _flip_tween: _flip_tween.kill()
	
	var target_rect = data.atlas_rects[0 if _is_showing_face else 1]
	_flip_tween = create_tween()
	
	_flip_tween.tween_property(sprite, "scale:x", 0.0, FLIP_DURATION / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_flip_tween.parallel().tween_property(sprite, "scale:y", FLIP_SCALE_Y, FLIP_DURATION / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	_flip_tween.tween_callback(func(): sprite.region_rect = target_rect)
	
	_flip_tween.tween_property(sprite, "scale:x", 1.0, FLIP_DURATION / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_flip_tween.parallel().tween_property(sprite, "scale:y", 1.0, FLIP_DURATION / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func move_to_stack(target_stack: Node2D):
	if _move_tween: _move_tween.kill()	
	_move_tween = create_tween()
	
	_move_tween.tween_property(self, "global_position", target_stack.global_position, MOVE_DURATION)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
	
	_move_tween.parallel().tween_property(sprite, "scale", MOVE_SCALE, MOVE_SCALE_DURATION)
	_move_tween.tween_property(sprite, "scale", Vector2.ONE, MOVE_SCALE_DURATION)
	
	_move_tween.tween_callback(func():
		reparent(target_stack)
		position = Vector2.ZERO 
	)

func get_value() -> int:
	return data.value
