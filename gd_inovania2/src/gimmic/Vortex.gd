extends Area2D

# ================================================
# ワープ渦巻き.
# ================================================
class_name Vortex

@onready var _spr = $Sprite2D

var _timer = 0.0

func _process(delta: float) -> void:
	_timer += delta * 4
	
	_spr.rotation = _timer
