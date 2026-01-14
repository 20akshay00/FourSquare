extends AudioStreamPlayer

var flip_sfx = load("res://assets/audio/CardFlip.wav")
var slide_sfx = load("res://assets/audio/CardSlide.wav")
var invalid_sfx = load("res://assets/audio/InvalidAction.wav")
var click_sfx = load("res://assets/audio/ClickAction.wav")
var game_over_sfx = load("res://assets/audio/GameOver.wav")
var game_won_sfx = load("res://assets/audio/GameWon.wav")

func _play_music(music: AudioStream, volume = -7):
	if stream == music:
		return

	stream = music
	volume_db = volume
	play()

func play_music_level():
	pass

func play_effect(aud_stream: AudioStream, volume = 0.0, bus="SFX"):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = aud_stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	fx_player.bus = bus
	add_child(fx_player)
	fx_player.play()
	fx_player.finished.connect(fx_player.queue_free)

	return fx_player
	
func play_spatial_effect(aud_stream: AudioStream, position=Vector2.ZERO, volume = 0.0, bus="Misc"):
	var fx_player = AudioStreamPlayer2D.new()
	fx_player.global_position = position
	fx_player.stream = aud_stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	add_child(fx_player)
	fx_player.play()
	fx_player.finished.connect(fx_player.queue_free)

	return fx_player
