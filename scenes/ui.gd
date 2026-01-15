extends CanvasLayer

@onready var count_label := $CountLabel
@onready var game_over_label = $GameOverLabel
@onready var game_won_label = $GameWonLabel

@onready var warning_label = $WarningLabel

@onready var play_again_button = $PlayAgainButton
@onready var play_field = $PlayField

@export var stats_ui: Control

var game_over_tween: Tween

var warnings := [
	"Cannot place more than 4 cards!",
	"Adjacent pile must be occupied!"
]

var _warning_tween: Tween

func _ready() -> void:
	EventManager.card_count_changed.connect(_on_card_count_changed)
	EventManager.game_over.connect(_on_game_over)
	EventManager.game_won.connect(_on_game_won)
	EventManager.invalid_move.connect(show_warning)

	game_over_label.scale = Vector2(0, 0)
	game_won_label.scale = Vector2(0, 0)

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
	
func _on_game_won() -> void:
	play_field.mouse_filter = Control.MOUSE_FILTER_STOP
	reveal_game_won_label()

func reveal_game_won_label() -> void:
	game_won_label.scale = Vector2.ZERO
	game_won_label.show()
	
	var tween = create_tween()
	tween.tween_property(game_won_label, "scale", Vector2.ONE, 2.0)\
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
			EventManager.open_leaderboard.emit()
	)

func _on_play_again_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	EventManager.turn_finished = true
	TransitionManager.reload_scene()

func _on_stats_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	stats_ui.open()

func _on_retry_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	EventManager.turn_finished = true
	TransitionManager.reload_scene()

func _on_audio_button_toggled(toggled_on: bool) -> void:
	if toggled_on: await AudioManager.play_effect(AudioManager.click_sfx).finished
	AudioServer.set_bus_mute( AudioServer.get_bus_index("SFX"), toggled_on)
	if !toggled_on: AudioManager.play_effect(AudioManager.click_sfx).finished

func show_warning(code: int) -> void:
	if code >= warnings.size(): return
	
	warning_label.text = warnings[code]
	
	if _warning_tween: _warning_tween.kill()
	_warning_tween = create_tween()
	
	# Reset and show
	warning_label.show()
	
	# Flash sequence
	_warning_tween.tween_property(warning_label, "modulate:a", 1.0, 0.2)
	_warning_tween.tween_interval(2.0)
	_warning_tween.tween_property(warning_label, "modulate:a", 0.0, 0.5)
	_warning_tween.tween_callback(warning_label.hide)
