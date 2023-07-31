extends CharacterBody2D
# =============================================
# 落下床.
# =============================================
class_name FallingFloor

# ---------------------------------------------
# const.
# ---------------------------------------------
## 重力.
const GRAVITY = 20.0
## 最大落下速度.
const MAX_SPEED = 500.0

## 状態.
enum eState {
	STAND_BY,
	FALLING,
}

# ---------------------------------------------
# var.
# ---------------------------------------------
var _state = eState.STAND_BY

# ---------------------------------------------
# public functions.
# ---------------------------------------------
## 上に何か乗ったときに開始する処理.
func stepped_on(body:CharacterBody2D) -> void:
	if _state == eState.STAND_BY:
		# 落下開始.
		_state = eState.FALLING
	
# ---------------------------------------------
# private functions.
# ---------------------------------------------
## 更新.
func _physics_process(delta: float) -> void:
	if _state == eState.FALLING:
		# 落下
		velocity.y += GRAVITY
		if velocity.y > MAX_SPEED:
			velocity.y = MAX_SPEED
		move_and_collide(velocity * delta)
		if Common.is_in_camera(position, Map.get_tile_size(), 2.0) == false:
			# 画面外で消える.
			queue_free()
		
