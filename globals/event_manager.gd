extends Node

signal stack_selected(stack:Stack)
signal card_count_changed(val: int)

signal invalid_move(code: int)

signal turn_completed
signal turn_started

signal game_won
signal game_over

signal open_leaderboard

signal stats_updated
var turn_finished: bool = true
