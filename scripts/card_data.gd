extends Resource
class_name CardData

enum CardSuit {DIAMOND, HEART, CLUB, SPADE}

const CARD_WIDTH: int = 100
const CARD_HEIGHT: int = 144

@export var value: int = 1
@export var suit: CardSuit = CardSuit.CLUB
@export var atlas_rects: Array[Rect2] = [Rect2(0, 0, 100, 144), Rect2(0, 0, 100, 144)]

func _init(p_value: int = 1, p_suit: CardSuit = CardSuit.CLUB, atlas_coord: Vector2 = Vector2.ZERO):
	value = p_value
	suit = p_suit
	atlas_rects[0] = Rect2(atlas_coord[0] * CardData.CARD_WIDTH, atlas_coord[1] * CardData.CARD_HEIGHT, CardData.CARD_WIDTH, CardData.CARD_HEIGHT)
	atlas_rects[1] = Rect2(CARD_WIDTH * 14, CARD_HEIGHT * 2, CARD_WIDTH, CARD_HEIGHT)
	if suit in [CardSuit.DIAMOND, CardSuit.HEART]:
		atlas_rects[1] = Rect2(CARD_WIDTH * 14, CARD_HEIGHT * 3, CARD_WIDTH, CARD_HEIGHT)
