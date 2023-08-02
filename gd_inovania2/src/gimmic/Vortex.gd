extends Area2D

# ================================================
# ワープ渦巻き.
# ================================================
class_name Vortex

@onready var _spr = $Sprite2D

## グリッド座標系の座標.
var _grid_pos = Vector2i()
## 移動座標リスト.
var _pos_list = []
var _timer = 0.0
var _passage_offset = Vector2.ONE

## セットアップ.
func setup(grid_pos:Vector2i, pos_list:Array, offset:float) -> void:
	_grid_pos = grid_pos
	_pos_list = pos_list
	_passage_offset *= offset
	
	position = Map.grid_to_world(_grid_pos)

func _process(delta: float) -> void:
	_timer += delta * 4
	
	_spr.rotation = _timer
	
	queue_redraw()
	
func _draw() -> void:
	# まずは通路の線を引く.
	_draw_passage()
	
	# 線の上を移動する円の描画.
	var p_list = _pos_list.duplicate()
	p_list.push_front(Vector2i.ZERO)
	var t = _timer
	var mod = p_list.size() - 1
	var idx = int(t) % mod
	var p1 = Vector2(p_list[idx])
	var p2 = Vector2(p_list[idx+1])
	# 小数部だけ欲しい
	var rate = t - int(t)
	p1 = p1.lerp(p2, rate)
	var v = Map.grid_to_world(p1, false)
	v += _passage_offset
	draw_circle(v, 4, Color.AQUA)
	
func _draw_passage() -> void:
	var p1 = Vector2i.ZERO
	for p2 in _pos_list:
		var v1 = Map.grid_to_world(p1, false)
		var v2 = Map.grid_to_world(p2, false)
		v1 += _passage_offset
		v2 += _passage_offset
		draw_line(v1, v2, Color.WHITE)
		p1 = p2
	
