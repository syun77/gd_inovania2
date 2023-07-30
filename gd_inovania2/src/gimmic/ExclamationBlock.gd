extends StaticBody2D
# =============================================================
# びっくりブロック.
# =============================================================
class_name ExclamationBlock

# -------------------------------------------------------------
# const.
# -------------------------------------------------------------
const WALL_OBJ = preload("res://src/gimmic/Wall.tscn")

# -------------------------------------------------------------
# var.
# -------------------------------------------------------------
## 出現する座標のリスト.
## @note add_child() するのでこのブロックからのオフセットとなる.
var _pos_list = []

# -------------------------------------------------------------
# public functions.
# -------------------------------------------------------------
## セットアップ.
func setup(pos_list:Array) -> void:
	_pos_list = pos_list
	_create_blocks()

# -------------------------------------------------------------
# private functions.
# -------------------------------------------------------------
## ブロックを生成する.
func _create_blocks() -> void:
	var base = Vector2i.ZERO
	var idx = 1
	for grid_pos in _pos_list:
		var wall = WALL_OBJ.instantiate()
		var p_list = [base]
		for i in range(idx):
			p_list.append(_pos_list[i])
		wall.setup_moving(p_list)
		add_child(wall)
		
		idx += 1

