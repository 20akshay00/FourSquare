extends Node2D

@export var deck: Deck
@export var grid: Node2D

@export var FLIP_DURATION: float = 0.2
@export var FLIP_DELAY: float = 0.25

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

func get_same_column_indices(index: int, width: int = 4, height: int = 4) -> Array[int]:
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
	
	var row_tweens: Array[Tween] = []
	if row_values.is_empty() or ((card.get_value() > row_values.max()) or (card.get_value() < row_values.min())):
		for s in row_stacks: 
			tween = s.flip()
			if tween: row_tweens.append(tween)

	#for tween in row_tweens: if tween.is_valid(): await tween.finished
	if !row_tweens.is_empty(): await get_tree().create_timer(FLIP_DURATION).timeout
	await get_tree().create_timer(FLIP_DURATION).timeout

	var col_stacks = get_same_column_indices(stack.get_index()).map(grid.get_child)
	var col_values = col_stacks.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null) \
		.filter(func(c): return c.is_revealed) \
		.map(func(c): return c.get_value())
	
	var col_tweens: Array[Tween] = []
	if col_values.is_empty() or ((card.get_value() > col_values.max()) or (card.get_value() < col_values.min())):
		for s in col_stacks: 
			tween = s.flip()
			if tween: col_tweens.append(tween)

	#for tween in col_tweens: if tween.is_valid(): await tween.finished
	if !col_tweens.is_empty(): await get_tree().create_timer(FLIP_DURATION).timeout
	await get_tree().create_timer(FLIP_DURATION).timeout
	_validate_board()

func _on_turn_started() -> void:
	deck.spawn_card()

func _validate_board() -> void:
	var stacks = grid.get_children()
	
	for i in 16:
		var n = [i-4, i+4, i-1 if i%4 != 0 else -1, i+1 if i%4 != 3 else -1]
		var has_own_card = stacks[i].get_top_card() != null
		var has_neighbor = n.any(func(idx): return idx >= 0 and idx < 16 and stacks[idx].get_top_card() != null)
		var can_place = stacks[i].get_num_cards() < 4
		stacks[i].set_validity((has_own_card or has_neighbor) and can_place)

	var face_down_count = stacks \
		.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null and !c.is_revealed) \
		.size()
		
	var face_up_count = stacks \
		.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null and c.is_revealed) \
		.size()
	
	if face_down_count > 4:
		_submit_session(false)
		AudioManager.play_effect(AudioManager.game_over_sfx, -10)
		EventManager.game_over.emit()
	elif face_up_count == 16:
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
