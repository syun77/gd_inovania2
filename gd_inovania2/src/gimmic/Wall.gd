extends StaticBody2D
# =============================================================
# 通常カベ.
# =============================================================
class_name Wall

# -------------------------------------------------------------
# const.
# -------------------------------------------------------------
const MOVING_TIMER = 0.01666 * 12 # 12F

# -------------------------------------------------------------
# var.
# -------------------------------------------------------------
## 移動タイマー.
var _moving_timer = 0.0
## 移動リスト.
var _pos_list = []

# -------------------------------------------------------------
# public functions.
# -------------------------------------------------------------
func setup_moving(pos_list:Array) -> void:
	_pos_list = pos_list
	position = Map.grid_to_world(_pos_list[0])

# -------------------------------------------------------------
# private functions.
# -------------------------------------------------------------
## 更新.
func _process(delta: float) -> void:
	if _pos_list.is_empty() == false:
		_update_moving(delta)

## 移動の更新.
func _update_moving(delta:float) -> void:
	_moving_timer += delta
	
	var rate = _moving_timer / MOVING_TIMER
	rate = Ease.cube_out(rate)
	if rate >= 1.0:
		_moving_timer = 0.0
		rate = 0.0
		_pos_list.pop_front()
		if _pos_list.size() == 1:
			# ゴールした.
			position = Map.grid_to_world(_pos_list[0], false)
			_pos_list.clear()
			return
	
	var a = Vector2(_pos_list[0])
	var b  = Vector2(_pos_list[1])
	a = a.lerp(b, rate)
	position = Map.grid_to_world(a, false)
