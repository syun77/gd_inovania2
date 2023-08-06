extends StaticBody2D
# =============================================================
# びっくりブロック.
# =============================================================
class_name ExclamationBlock

# -------------------------------------------------------------
# preload.
# -------------------------------------------------------------
const WALL_OBJ = preload("res://src/gimmic/Wall.tscn")

# -------------------------------------------------------------
# const.
# -------------------------------------------------------------
const TIMER_COUNT_DOWN = 4.0 # ブロック消滅までの時間.

enum eState {
	NOT_PRESS, # 押していない.
	PRESS, # 押している.
	PRESS_TO_RELEASE, # 押して一定時間経過中.
}

# -------------------------------------------------------------
# onready.
# -------------------------------------------------------------
## 生成するカベの管理.
@onready var _walls = $Walls
## カウントダウン文字.
@onready var _label_number = $LabelNumber
## ブロック画像.
@onready var _spr = $Sprite
## スイッチ画像.
@onready var _spr_switch = $ExclamationSwitch/Sprite

# -------------------------------------------------------------
# var.
# -------------------------------------------------------------
## 出現する座標のリスト.
## @note add_child() するのでこのブロックからのオフセットとなる.
var _pos_list = []
## プレイヤーの参照.
var _player:Player = null
## スイッチの状態.
var _state = eState.NOT_PRESS
## カウントダウン数字.
var _count_timer = 0.0

# -------------------------------------------------------------
# public functions.
# -------------------------------------------------------------
## セットアップ.
func setup(pos_list:Array) -> void:
	_pos_list = pos_list

# -------------------------------------------------------------
# private functions.
# -------------------------------------------------------------
## 更新.
func _process(delta: float) -> void:
	var pressed = _is_pressed_switch()
	
	match _state:
		eState.NOT_PRESS:
			if pressed:
				# スイッチを踏んだ.
				Common.play_se("switch")
				_create_blocks()
		eState.PRESS:
			if pressed == false:
				# スイッチから離れたら時間経過.
				_state = eState.PRESS_TO_RELEASE
				_count_timer = TIMER_COUNT_DOWN
		eState.PRESS_TO_RELEASE:
			if pressed:
				# 再び押したらカウントやり直し.
				if _count_timer != TIMER_COUNT_DOWN:
					Common.play_se("switch", 4)
				_count_timer = TIMER_COUNT_DOWN
			else:
				_count_timer -= delta
			
			if _count_timer <= 0:
				# 時間切れ.
				_erase_blocks()
	
	# アニメ更新.
	_update_anim()
	
## アニメ更新.
func _update_anim() -> void:
	_label_number.visible = false
	if _state == eState.NOT_PRESS:
		_spr.frame = 0
		_spr_switch.frame = 0
	else:
		_spr.frame = 1
		_spr_switch.frame = 1
		if _state == eState.PRESS_TO_RELEASE:
			var count = int(_count_timer) + 1
			_label_number.text = "%d"%count
			if _is_pressed_switch() == false:
				# 踏んでいなければ数字を表示する.
				_label_number.visible = true
				for wall in _walls.get_children():
					wall.set_number(count)
				
	
## スイッチを踏んでいるかどうか.
func _is_pressed_switch() -> bool:
	if is_instance_valid(_player) == false:
		# プレイヤーが離れていたら踏んでいないことにする.
		return false
	
	if _player.is_landing():
		return true # 着地していたら踏んでいるものとする.
	
	return false

## ブロックを生成する.
func _create_blocks() -> void:
	if _state == eState.PRESS:
		return # すでに押していたら何もしない.
	if _state == eState.PRESS_TO_RELEASE:
		return # すでに押していたら何もしない.
	
	var base = Vector2i.ZERO
	var idx = 1
	for grid_pos in _pos_list:
		var wall = WALL_OBJ.instantiate()
		var p_list = [base]
		for i in range(idx):
			p_list.append(_pos_list[i])
		_walls.add_child(wall)
		wall.setup_moving(p_list)
		
		idx += 1
	
	_state = eState.PRESS

## ブロックを消す.
func _erase_blocks() -> void:
	if _state == eState.NOT_PRESS:
		return # すでに消されていたら何もしない.
	
	for block in _walls.get_children():
		block.vanish()
	_state = eState.NOT_PRESS

## プレイヤーが衝突.
func _on_exclamation_switch_body_entered(body: Node2D) -> void:
	if not body is Player:
		return # Player以外は除外.
	_player = body

## プレイヤーが離れた.
func _on_exclamation_switch_body_exited(body: Node2D) -> void:
	if not body is Player:
		return # Player以外は除外.
	_player = null
