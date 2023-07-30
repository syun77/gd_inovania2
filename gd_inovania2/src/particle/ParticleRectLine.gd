extends Particle

# ============================================
# 広がる線の矩形.
# ============================================
var _base_scale = Vector2()

## 開始.
func _start() -> void:
	gravity = 0.0 # 重力なし.
	rotate_speed = 0.0 # 回転しない.
	_base_scale = scale

## 更新.
func _update(delta:float) -> void:
	move(delta)
	modulate = color

	var rate = get_time_rate()
	var sc = Ease.expo_out(rate)
	scale = _base_scale * sc
	modulate.a = (1 - rate)
