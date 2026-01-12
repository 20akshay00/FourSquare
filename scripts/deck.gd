extends Node2D
class_name Deck

@export var card_scene: PackedScene

var cards: Array[CardData] = []
var active_card: Card 

func _ready() -> void:
	EventManager.game_won.connect(_on_game_won)

func generate() -> void:
	cards = []
	for s in CardData.CardSuit.values():
		for v in range(0, 10):
			var atlas_coord = Vector2(v, s)
			var card = CardData.new(v+1, s, atlas_coord)
			cards.append(card)

func shuffle() -> void:
	randomize()
	cards.shuffle()

func spawn_card() -> void:
	if len(cards) == 1:
		$Base.hide()
	elif len(cards) == 0: 
		EventManager.game_over.emit()
		return

	active_card = card_scene.instantiate()
	active_card.data = cards.pop_front()
	add_child(active_card)
	active_card.global_position = global_position
	
func get_active_card() -> Card:
	EventManager.card_count_changed.emit(len(cards))
	return active_card

func _on_game_won() -> void:
	StatsManager.update_stats(len(cards))
