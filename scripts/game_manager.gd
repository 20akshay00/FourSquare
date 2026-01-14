extends Node2D

@export var deck: Deck
@export var grid: Node2D

@export var FLIP_DURATION: float = 0.5

var tween: Tween
var _start_time: float = 0.0

func _ready() -> void:
	deck.generate()
	deck.shuffle()
	deck.spawn_card()
	
	_start_time = Time.get_ticks_msec()
	
	EventManager.stack_selected.connect(_on_stack_selected)
	EventManager.turn_completed.connect(_on_turn_started)

func _process(delta: float) -> void:
	pass

func get_same_row_indices(index: int, width: int = 4) -> Array[int]:
	var row = index / width
	var result: Array[int] = []
	for i in range(row * width, (row + 1) * width):
		if i != index:
			result.append(i)
	return result

func get_same_column_indices(index: int, width: int = 4, height: int = 3) -> Array[int]:
	var col = index % width
	var result: Array[int] = []
	for i in range(height):
		var target = (i * width) + col
		if target != index:
			result.append(target)
	return result
	
func _on_stack_selected(stack: Stack):	
	var card := deck.get_active_card()
	tween = card.move_to_stack(stack)
	if tween: await tween.finished
	
	var row_stacks = get_same_row_indices(stack.get_index()).map(grid.get_child)
	var row_values = row_stacks.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null) \
		.filter(func(c): return c.is_revealed) \
		.map(func(c): return c.get_value())
	
	var tweens: Array[Tween] = []
	if row_values.is_empty() or ((card.get_value() > row_values.max()) or (card.get_value() < row_values.min())):
		for s in row_stacks: 
			tween = s.flip()
			if tween: tweens.append(tween)

	for tween in tweens: if tween.is_valid(): await tween.finished
	if !tweens.is_empty(): await get_tree().create_timer(FLIP_DURATION).timeout

	var col_stacks = get_same_column_indices(stack.get_index()).map(grid.get_child)
	var col_values = col_stacks.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null) \
		.filter(func(c): return c.is_revealed) \
		.map(func(c): return c.get_value())
	
	if col_values.is_empty() or ((card.get_value() > col_values.max()) or (card.get_value() < col_values.min())):
		for s in col_stacks: 
			tween = s.flip()
			if tween: tweens.append(tween)

	for tween in tweens: if tween.is_valid(): await tween.finished
	if !tweens.is_empty(): await get_tree().create_timer(FLIP_DURATION).timeout

	_validate_board()

func _on_turn_started() -> void:
	deck.spawn_card()

func _validate_board() -> void:
	var face_down_count = grid.get_children() \
		.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null and !c.is_revealed) \
		.size()
		
	var face_up_count = grid.get_children() \
		.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null and c.is_revealed) \
		.size()
	
	if face_down_count > 3:
		_submit_session(false)
		AudioManager.play_effect(AudioManager.game_over_sfx, -10)
		EventManager.game_over.emit()
	elif face_up_count == 12:
		_submit_session(true)
		AudioManager.play_effect(AudioManager.game_won_sfx, -10)
		EventManager.game_won.emit()
	else:
		EventManager.turn_finished = true
		EventManager.turn_completed.emit()

func _submit_session(is_win) -> void:
	var end_time = Time.get_ticks_msec()
	var duration = (end_time - _start_time) / 1000.0
	StatsManager.add_session(deck.cards.size(), is_win, duration)
