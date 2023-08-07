extends StaticBody2D
# =============================================================
# 通常カベ.
# @note 動作モードによって挙動が変わる.
# - eMode.NORMAL: 通常カベ.
# - eMode.EXCLAMATION: 所定位置まで _pos_list の経路で動くカベ.
# =============================================================
class_name Wall

# -------------------------------------------------------------
# const.
# -------------------------------------------------------------
## 移動タイマー.
const MOVING_TIMER = 0.01666 * 3 # 3F
## 消滅タイマー.
const VANISH_TIMER = 0.3

## 動作モード.
enum eMode {
	NORMAL = 0, # 通常.
	EXCLAMATION = 1, # びっくりブロック.	
}

## 状態.
enum eState {
	MAIN, # メイン.
	VANISH, # 消える.
}

# -------------------------------------------------------------
# onready.
# -------------------------------------------------------------
@onready var _spr = $Sprite2D
@onready var _collision = $CollisionShape2D
@onready var _label = $Label

# -------------------------------------------------------------
# var.
# -------------------------------------------------------------
## 動作モード.
var _mode = eMode.NORMAL

## 状態.
var _state = eState.MAIN

## 汎用タイマー.
var _timer = 0.0

## 移動タイマー.
var _moving_timer = 0.0
## 移動リスト.
var _pos_list = []
## 表示する数字.
var _number:int = 0

# -------------------------------------------------------------
# public functions.
# -------------------------------------------------------------
## 移動のセットアップ.
func setup_moving(pos_list:Array) -> void:
	_mode = eMode.EXCLAMATION
	_pos_list = pos_list
	position = Map.grid_to_world(_pos_list[0], false)
	_spr.frame = _mode
	
## 数字を設定する.
func set_number(n:int) -> void:
	if _state == eState.MAIN:
		_number = n

## 消滅.
func vanish() -> void:
	if _state == eState.VANISH:
		return
	_state = eState.VANISH
	_timer = VANISH_TIMER
	
	# コリジョンを無効にする.
	_collision.disabled = true

# -------------------------------------------------------------
# private functions.
# -------------------------------------------------------------
## 更新.
func _process(delta: float) -> void:
	if _pos_list.is_empty() == false:
		_update_moving(delta)
	
	match _state:
		eState.MAIN:
			_update_main(delta)
		eState.VANISH:
			_update_vanish(delta)

## 更新 > メイン.
func _update_main(_delta:float) -> void:
	if _number > 0:
		# 数字を表示する.
		_label.visible = true
		_label.text = "%d"%_number
		_number = 0
	else:
		_label.visible = false

## 更新 > 消滅.
func _update_vanish(delta:float) -> void:
	_label.visible = false
	_timer -= delta
	if _timer < 0.0:
		queue_free()
		return
	
	var rate = _timer / VANISH_TIMER
	_spr.scale = Vector2(rate, rate)

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
			Common.play_se("block")
			position = Map.grid_to_world(_pos_list[0], false)
			_pos_list.clear()
			var p =ParticleUtil.add(global_position, ParticleUtil.eType.RECTLINE, 0, 0, 1.0, 0.5)
			p.color = Color.CHOCOLATE
			return
	
	var a = Vector2(_pos_list[0])
	var b  = Vector2(_pos_list[1])
	a = a.lerp(b, rate)
	position = Map.grid_to_world(a, false)
