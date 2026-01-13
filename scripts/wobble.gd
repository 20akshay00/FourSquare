@tool
extends RichTextEffect
class_name RichTextWobble

var bbcode = "wobble"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed = char_fx.env.get("speed", 5.0)
	var amp = char_fx.env.get("amp", 2.0)
	var time = char_fx.elapsed_time * speed + char_fx.relative_index
	
	char_fx.offset.x += sin(time) * amp
	char_fx.offset.y += cos(time * 1.2) * amp
	char_fx.transform = char_fx.transform.rotated(sin(time * 0.8) * 0.08)
	
	return true
