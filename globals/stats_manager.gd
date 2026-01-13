extends Node

# raw data
var sessions: Array = []

# computed for UI
var high_score: int = 0
var games_played: int = 0
var games_won: int = 0
var average_playtime: float = 0.0

const SAVE_PATH = "user://save_data_v1.json"

func _ready() -> void:
	load_data()

func add_session(score: int, won: bool, duration: float) -> void:
	var session_data = {
		"score": score,
		"won": won,
		"duration": duration,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	sessions.append(session_data)
	_compute_stats()
	_save_data()
	EventManager.stats_updated.emit()

func _compute_stats() -> void:
	games_played = sessions.size()
	if games_played == 0: return

	var total_score = 0
	var total_time = 0.0
	games_won = 0
	high_score = 0

	for s in sessions:
		if s.won and (s.score > high_score): high_score = s.score
		if s.won: games_won += 1
		total_score += s.score
		total_time += s.duration
	
	average_playtime = total_time / games_played

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK:
		sessions = json.data.get("sessions", [])
		_compute_stats()

func _save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data_to_save = { "sessions": sessions }
	file.store_line(JSON.stringify(data_to_save))

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_data()

func clear_all_data() -> void:
	sessions = []
	high_score = 0
	games_played = 0
	games_won = 0
	average_playtime = 0.0
	
	_save_data()
	EventManager.stats_updated.emit()
