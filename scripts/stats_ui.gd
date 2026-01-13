extends Control

@onready var frost_bg := $FrostBG
@onready var labels := [$Container/HighScoreLabel, $Container/GamesPlayedLabel, $Container/AvgTimeLabel, $Container/WinRateLabel]

var _start_y: Array[float] = []
var _tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	for l in labels: _start_y.append(l.position.y)
	hide()

func open() -> void:
	_setup_stats()
	_run_animation(true)

func close() -> void:
	_run_animation(false)

func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02dm %02ds" % [mins, secs]
	
func _setup_stats() -> void:
	var played = StatsManager.games_played
	var win_rate = (float(StatsManager.games_won) / max(1, played)) * 100
	labels[0].text = "Best score - %d" % StatsManager.high_score
	labels[1].text = "Games played - %d" % played
	labels[2].text = "Average playtime - " + _format_time(StatsManager.average_playtime)
	labels[3].text = "Win rate - %d%%" % win_rate

func _run_animation(opening: bool) -> void:
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel(true)
	
	if opening:
		show()
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tween.finished.connect(hide)

	var alpha = 1.0 if opening else 0.0
	var blur = 5.0 if opening else 0.0
	var trans = Tween.TRANS_SINE
	var ease = Tween.EASE_OUT if opening else Tween.EASE_IN

	_tween.tween_property(self, "modulate:a", alpha, 0.4).set_trans(trans).set_ease(ease)
	_tween.tween_property(frost_bg.material, "shader_parameter/blur_amount", blur, 0.6).set_trans(trans).set_ease(ease)

	for i in labels.size():
		var l = labels[i]
		var delay = (i * 0.1) if opening else ((labels.size() - 1 - i) * 0.05)
		var l_alpha = 1.0 if opening else 0.0
		var l_y = _start_y[i] if opening else _start_y[i] + 20
		
		if opening and i == 0:
			for j in labels.size(): 
				labels[j].modulate.a = 0
				labels[j].position.y = _start_y[j] + 20

		_tween.tween_property(l, "modulate:a", l_alpha, 0.3).set_delay(delay)
		_tween.tween_property(l, "position:y", l_y, 0.5 if opening else 0.3)\
			.set_trans(Tween.TRANS_BACK if opening else trans)\
			.set_ease(ease)\
			.set_delay(delay)

func _on_close_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	close()

func _on_clear_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	StatsManager.clear_all_data()
	_setup_stats()	
