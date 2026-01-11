extends Sprite2D
class_name Card

@export var data: CardData
@onready var sprite := $Sprite

@export var duration: float = 0.2
@export var peak_scale_y: float = 1.1 
	
var _flip_tween: Tween
var _is_face_up: bool = true

func _ready() -> void:
	texture.region = data.atlas_rects[0]

func play_flip_animation():
	if _flip_tween: _flip_tween.kill()
	
	_is_face_up = !_is_face_up
	var target_rect = data.atlas_rects[0] if _is_face_up else data.atlas_rects[1]
	
	_flip_tween = create_tween()
	
	_flip_tween.tween_property(sprite, "scale:x", 0.0, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_flip_tween.parallel().tween_property(sprite, "scale:y", peak_scale_y, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	_flip_tween.tween_callback(func(): sprite.region_rect = target_rect)
	
	_flip_tween.tween_property(sprite, "scale:x", 1.0, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_flip_tween.parallel().tween_property(sprite, "scale:y", 1.0, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
