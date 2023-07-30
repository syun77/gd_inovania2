extends StaticBody2D

@onready var _spr = $Sprite2D
@onready var _collision = $CollisionShape2D

var _timer = 0.0

## セットアップ.
func setup(is_left:bool) -> void:
	if is_left:
		# 左向き一方通行.
		_collision.rotation_degrees = -90
	else:
		# 右向き一方通行.
		_collision.rotation_degrees = 90
		_spr.flip_h = true # スプライトを左右反転
		# 中心がずれているので補正.
		_spr.offset.x = -4
	
## 更新.
func _process(delta: float) -> void:
	_timer += delta
	_spr.frame = int(_timer * 4)%4
