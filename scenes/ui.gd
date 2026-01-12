extends CanvasLayer

@onready var count_label := $CountLabel
@onready var game_over_label = $GameOverLabel
@onready var play_again_button = $PlayAgainButton
@onready var play_field = $PlayField

@export var stats_ui: Control

var game_over_tween: Tween

func _ready() -> void:
	EventManager.card_count_changed.connect(_on_card_count_changed)
	EventManager.game_over.connect(_on_game_over)

func _on_card_count_changed(val) -> void:
	set_count(val)
	if val < 10: count_label.position.x = 212.0

func set_count(val: int) -> void:
	count_label.text = str(val)

func _on_game_over() -> void:
	play_field.mouse_filter = Control.MOUSE_FILTER_STOP
	reveal_game_over_label()

func reveal_game_over_label() -> void:
	game_over_label.scale = Vector2.ZERO
	game_over_label.show()
	
	play_again_button.scale = Vector2.ZERO
	play_again_button.show()
	play_again_button.disabled = true
	
	var tween = create_tween()

	tween.tween_property(game_over_label, "scale", Vector2.ONE, 2.0)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(0.2)

	tween.tween_property(play_again_button, "scale", Vector2.ONE, 1.5)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_callback(
		func(): 
			play_again_button.disabled = false
			game_over_tween = create_tween().set_loops()
			game_over_tween.tween_property(play_again_button, "scale", Vector2(1.05, 1.05), 0.8)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN_OUT)
			
			game_over_tween.tween_property(play_again_button, "scale", Vector2.ONE, 0.8)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN_OUT)
	)
	
func _on_play_again_button_pressed() -> void:
	EventManager.turn_finished = true
	TransitionManager.reload_scene()

func _on_stats_button_pressed() -> void:
	stats_ui.open()

func _on_retry_button_pressed() -> void:
	EventManager.turn_finished = true
	TransitionManager.reload_scene()
