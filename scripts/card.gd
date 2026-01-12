extends Node2D
class_name Card

@export var data: CardData
@onready var sprite := $Sprite
@onready var input_area := $ReferenceRect

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

func flip(val = null) -> Tween:
	if val != null:
		is_revealed = val
		return animate_to_face(val)
	
	is_revealed = !is_revealed
	return animate_to_face(is_revealed)

func animate_to_face(target_face_up: bool) -> Tween:
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
	
	return _flip_tween

func move_to_stack(target_stack: Node2D) -> Tween:
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
	
	return _move_tween

func get_value() -> int:
	return data.value

func _on_reference_rect_mouse_entered() -> void:
	animate_to_face(true)

func _on_reference_rect_mouse_exited() -> void:
	if not is_revealed: animate_to_face(false)
