extends Area2D

# ================================================
# ワープ渦巻き.
# ================================================
class_name Vortex

# ------------------------------------------------
# onready.
# ------------------------------------------------
@onready var _spr = $Sprite2D

# ------------------------------------------------
# var.
# ------------------------------------------------
## グリッド座標系の座標.
var _grid_pos = Vector2i()
## 移動座標リスト.
var _pos_list = []
var _timer = 0.0
var _passage_offset = Vector2.ONE

# ------------------------------------------------
# public functions.
# ------------------------------------------------
## セットアップ.
func setup(grid_pos:Vector2i, pos_list:Array, offset:float) -> void:
	_grid_pos = grid_pos
	_pos_list = pos_list
	_passage_offset *= offset
	
	position = Map.grid_to_world(_grid_pos)

# ------------------------------------------------
# private functions.
# ------------------------------------------------
## 更新.
func _process(delta: float) -> void:
	_timer += delta * 4
	
	_spr.rotation = _timer
	
	queue_redraw()

## 描画.
func _draw() -> void:
	# まずは通路の線を引く.
	_draw_passage()
	
	# 線の上を移動する円の描画.
	_draw_dot()

## 通路の線の描画.
func _draw_passage() -> void:
	var p1 = Vector2i.ZERO
	for p2 in _pos_list:
		var v1 = Map.grid_to_world(p1, false)
		var v2 = Map.grid_to_world(p2, false)
		v1 += _passage_offset
		v2 += _passage_offset
		draw_line(v1, v2, Color.SKY_BLUE)
		p1 = p2

## 線の上を動く点の描画.
func _draw_dot() -> void:
	var t = _timer
	var mod = _pos_list.size() - 1
	var idx = int(t) % mod
	# 2点を補間して動く.
	var p1 = Vector2(_pos_list[idx])
	var p2 = Vector2(_pos_list[idx+1])
	# 小数部だけ欲しい
	var rate = t - int(t)
	p1 = p1.lerp(p2, rate)
	var v = Map.grid_to_world(p1, false)
	v += _passage_offset
	draw_circle(v, 4, Color.AQUA)

# ------------------------------------------------
# signals.
# ------------------------------------------------
## プレイヤーとの衝突判定.
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return # プレイヤー以外は何もしない.
	
	var player = body as Player
	# 渦巻きからの相対なので絶対座標に置き換える.
	var p_list = _pos_list.map(func(a): return a + _grid_pos)
	# 末尾に飛び出す先を指定する.
	#var b = p_list.pop_back()
	#var a = p_list.pop_back()
	#var c = b + (b - a)
	#p_list.append_array([a, b, c])
	player.start_warp(p_list)
