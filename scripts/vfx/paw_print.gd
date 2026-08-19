extends Node2D

## Dinamik Pati İzi (Paw Print Decal)
## Kedi koşarken zeminde hafifçe belirir ve 1.4 saniyede kaybolur.

var side: int = 1 # 1: Sağ pati, -1: Sol pati

func _ready() -> void:
	z_index = -1 # Zemin üzerinde, karakterlerin altında
	modulate.a = 0.55
	
	var tween = create_tween()
	tween.tween_interval(0.6)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)

func _draw() -> void:
	var col = Color(0.03, 0.04, 0.08, 0.5)
	var offset_x = float(side) * 5.0
	
	# Ana Pati Yastığı
	draw_circle(Vector2(offset_x, 0), 2.8, col)
	
	# 3 Minik Parmak İzi
	draw_circle(Vector2(offset_x - 2.2, -3.2), 1.2, col)
	draw_circle(Vector2(offset_x, -4.2), 1.3, col)
	draw_circle(Vector2(offset_x + 2.2, -3.2), 1.2, col)
