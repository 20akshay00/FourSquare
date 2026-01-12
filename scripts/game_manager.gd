extends Node2D

@export var deck: Deck
@export var grid: Node2D

func _ready() -> void:
	deck.generate()
	deck.shuffle()
	deck.spawn_card()
	
	EventManager.stack_selected.connect(_on_stack_selected)

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
	card.move_to_stack(stack)
	
	var row_stacks = get_same_row_indices(stack.get_index()).map(grid.get_child)
	var row_values = row_stacks.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null) \
		.filter(func(c): return c.is_revealed) \
		.map(func(c): return c.get_value())
	
	if !row_values.is_empty() and ((card.get_value() > row_values.max()) or (card.get_value() < row_values.min())):
		for s in row_stacks: s.flip()
	
	var col_stacks = get_same_column_indices(stack.get_index()).map(grid.get_child)
	var col_values = col_stacks.map(func(s): return s.get_top_card()) \
		.filter(func(c): return c != null) \
		.filter(func(c): return c.is_revealed) \
		.map(func(c): return c.get_value())
	
	if !col_values.is_empty() and ((card.get_value() > col_values.max()) or (card.get_value() < col_values.min())):
		for s in col_stacks: s.flip()

	EventManager.turn_finished = true
	deck.spawn_card()
