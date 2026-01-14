extends Control

@export_group("Leaderboard References")
@export var leaderboard_box: Container
@export var name_input: LineEdit
@export var submit_btn: TextureButton
@export var delete_btn: TextureButton

@onready var frost_bg := $FrostBG
@onready var labels := [$Container/HighScoreLabel, $Container/GamesPlayedLabel, $Container/AvgTimeLabel, $Container/WinRateLabel]
@onready var stats_title := $Container/StatsLabel
@onready var leaderboard_title := $LeaderboardContainer/LeaderboardLabel
@onready var leaderboard_table := $LeaderboardContainer/Leaderboard
@onready var input_fields := $LeaderboardContainer/InputFields
@onready var bottom_buttons := $UIButtons
@onready var close_btn := $UIButtons/CloseButton

var _origin := {} 
var _tween: Tween
var _regex := RegEx.new()

func _ready() -> void:
	await get_tree().process_frame
	
	for node in labels + [stats_title, leaderboard_title, leaderboard_table, input_fields]:
		_origin[node] = node.position
	
	for r in leaderboard_box.get_children(): 
		_origin[r] = r.position

	_regex.compile("^[a-zA-Z0-9]*$")
	name_input.text_changed.connect(_on_name_changed)
	EventManager.open_leaderboard.connect(open_on_win)
	hide()

# --- Public API ---

func open() -> void:
	_prepare_ui(false)
	_run_animation(true)

func open_on_win() -> void:
	_prepare_ui(true)
	_run_animation(true)

func close() -> void:
	_run_animation(false)

# --- Logic ---

func _prepare_ui(is_win: bool) -> void:
	_setup_stats()
	_refresh_leaderboard()
	
	input_fields.visible = is_win
	input_fields.modulate.a = 1.0
	bottom_buttons.visible = !is_win
	bottom_buttons.modulate.a = 1.0
	close_btn.disabled = is_win
	
	if is_win:
		name_input.text = StatsManager.player_name
		if submit_btn.pressed.is_connected(_on_submit_pressed):
			submit_btn.pressed.disconnect(_on_submit_pressed)
		submit_btn.pressed.connect(_on_submit_pressed.bind(StatsManager.score))
		submit_btn.disabled = false
		submit_btn.show()
		delete_btn.show()

func _setup_stats() -> void:
	var played = StatsManager.games_played
	var win_rate = (float(StatsManager.games_won) / max(1, played)) * 100
	labels[0].text = "Best score - %d" % StatsManager.high_score
	labels[1].text = "Games played - %d" % played
	labels[2].text = "Average playtime - " + _format_time(StatsManager.average_playtime)
	labels[3].text = "Win rate - %d%%" % win_rate

func _format_time(seconds: float) -> String:
	return "%02dm %02ds" % [int(seconds) / 60, int(seconds) % 60]

# --- Animations ---

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
	var ease = Tween.EASE_OUT if opening else Tween.EASE_IN

	_tween.tween_property(self, "modulate:a", alpha, 0.4).set_ease(ease)
	_tween.tween_property(frost_bg.material, "shader_parameter/blur_amount", blur, 0.6).set_ease(ease)

	# Stats Column
	var st_delay = 0.0 if opening else 0.5
	_tween.tween_property(stats_title, "modulate:a", alpha, 0.3).set_delay(st_delay)

	for i in labels.size():
		var l = labels[i]
		var delay = (0.1 + (i * 0.08)) if opening else (0.4 - (i * 0.05))
		if opening:
			l.modulate.a = 0
			l.position.y = _origin[l].y + 15
		_tween.tween_property(l, "modulate:a", alpha, 0.3).set_delay(delay)
		_tween.tween_property(l, "position:y", _origin[l].y if opening else _origin[l].y + 15, 0.4)\
			.set_trans(Tween.TRANS_BACK if opening else Tween.TRANS_SINE).set_ease(ease).set_delay(delay)

	# Leaderboard Title
	var lb_title_delay = 0.5 if opening else 0.3
	var lb_y = _origin[leaderboard_title].y
	if opening:
		leaderboard_title.modulate.a = 0
		leaderboard_title.position.y = lb_y + 15
	_tween.tween_property(leaderboard_title, "modulate:a", alpha, 0.3).set_delay(lb_title_delay)
	_tween.tween_property(leaderboard_title, "position:y", lb_y if opening else lb_y + 15, 0.4).set_delay(lb_title_delay)

	# Rows
	var rows = leaderboard_box.get_children()
	var row_start = 0.6 if opening else 0.1
	for i in rows.size():
		var r = rows[i]
		var delay = (row_start + (i * 0.05)) if opening else (0.25 - (i * 0.03))
		if opening:
			r.modulate.a = 0
			r.position.x = _origin[r].x + 15
		_tween.tween_property(r, "modulate:a", alpha, 0.2).set_delay(delay)
		_tween.tween_property(r, "position:x", _origin[r].x if opening else _origin[r].x + 15, 0.3).set_delay(delay)

	# Input / Buttons
	var in_delay = 1.1 if opening else 0.05
	var btn_delay = 1.2 if opening else 0.0
	
	for node in [input_fields, bottom_buttons]:
		if opening: node.modulate.a = 0
		var delay = in_delay if node == input_fields else btn_delay
		_tween.tween_property(node, "modulate:a", alpha, 0.3).set_delay(delay)

func _transition_post_submit() -> void:
	var t = create_tween().set_parallel(true)
	# Fade out input bar
	t.tween_property(input_fields, "modulate:a", 0.0, 0.3)
	# Fade in bottom buttons
	bottom_buttons.modulate.a = 0.0
	bottom_buttons.show()
	t.tween_property(bottom_buttons, "modulate:a", 1.0, 0.3).set_delay(0.2)
	
	t.chain().tween_callback(func():
		input_fields.hide()
		close_btn.disabled = false
	)

# --- Signal Callbacks ---

func _on_submit_pressed(score: int) -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	submit_btn.disabled = true
	var username = name_input.text.strip_edges()
	if username.is_empty(): username = "Guest"
	
	StatsManager.save_name(username)
	_update_ui_with_prediction(username, score)
	
	await Talo.players.identify("username", username)
	await Talo.leaderboards.add_entry("highscores", score)
	
	_transition_post_submit()

func _update_ui_with_prediction(new_name: String, new_score: int) -> void:
	var rows = leaderboard_box.get_children()
	var entries = []
	
	for row in rows:
		var n = row.get_node("Name").text
		var s = int(row.get_node("Score").text)
		if n != "???": # Only track actual player data
			entries.append({"name": n, "score": s})
	
	# check if the player already exists in the list
	var existing_entry = null
	for entry in entries:
		if entry.name == new_name:
			existing_entry = entry
			break
			
	if existing_entry:
		# update only if the new score is strictly better
		if new_score > existing_entry.score:
			existing_entry.score = new_score
	else:
		# player is not on the board yet, add them
		entries.append({"name": new_name, "score": new_score})
	
	entries.sort_custom(func(a, b): return a.score > b.score)
	
	# update the visual rows (up to 10)
	for i in rows.size():
		var name_l = rows[i].get_node("Name")
		var score_l = rows[i].get_node("Score")
		
		if i < entries.size():
			name_l.text = entries[i].name
			score_l.text = str(entries[i].score)
		else:
			name_l.text = "???"
			score_l.text = "0"

func _refresh_leaderboard() -> void:
	var options = Talo.leaderboards.GetEntriesOptions.new()
	var page = await Talo.leaderboards.get_entries("highscores", options)
	var entries = page.entries if page else []
	var rows = leaderboard_box.get_children()
	
	for i in rows.size():
		var row = rows[i]
		var entry = entries[i] if i < entries.size() else null
		
		row.get_node("Rank").text = "%d." % (i + 1)
		if entry:
			var id_val = entry.player_alias.get("identifier") if entry.player_alias else null
			row.get_node("Name").text = str(id_val) if id_val != null else "???"
			row.get_node("Score").text = str(int(entry.score))
		else:
			row.get_node("Name").text = "???"
			row.get_node("Score").text = "0"

func _on_name_changed(new_text: String) -> void:
	if not _regex.search(new_text):
		var old_caret = name_input.caret_column
		name_input.text = "".join(Array(new_text.split("")).filter(func(c): return _regex.search(c)))
		name_input.caret_column = old_caret

func _on_close_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	close()

func _on_clear_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	StatsManager.clear_all_data()
	_setup_stats()	

func _on_delete_button_pressed() -> void:
	AudioManager.play_effect(AudioManager.click_sfx)
	delete_btn.disabled = true
	_transition_post_submit()
