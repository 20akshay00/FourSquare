extends Node2D

@export var card_scene: PackedScene
var deck: Array[CardData] = []

func _generate_deck() -> void:
	deck = []
	for s in CardData.CardSuit.values():
		for v in range(1, 11):
			var atlas_coord = Vector2(v, s)
			var card = CardData.new(v, s, atlas_coord)
			deck.append(card)

func _ready() -> void:
	_generate_deck()
	deck.shuffle()
	print("hi")

func _generate_card(data: CardData) -> Card:
	var card := card_scene.instantiate()
	card.data = data
	return card

func _process(delta: float) -> void:
	print("hi")
	if Input.is_action_just_pressed("select"):
		print("hi")
		$Grid/Card.play_flip_animation()
