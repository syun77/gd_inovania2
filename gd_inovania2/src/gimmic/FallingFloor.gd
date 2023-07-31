extends CharacterBody2D
# =============================================
# 落下床.
# =============================================
class_name FallingFloor

const GRAVITY = 1.0
const MAX_SPEED = 5.0

enum eState {
	STAND_BY,
	FALLING,
}

var _state = eState.STAND_BY

## 更新.
func _process(delta: float) -> void:
	move_and_collide(velocity)
	if get_slide_collision_count() > 0:
		if _state == eState.STAND_BY:
			_state == eState.FALLING
	
	if _state == eState.FALLING:
		# 落下
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_SPEED:
			velocity.y = MAX_SPEED
		if Common.is_in_camera(position, Map.get_tile_size(), 2.0):
			velocity.y = 0
		
