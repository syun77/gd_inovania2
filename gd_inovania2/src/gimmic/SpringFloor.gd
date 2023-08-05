extends Area2D
# =============================================
# バネ床.
# =============================================

# ---------------------------------------------
# const.
# ---------------------------------------------
const POWER = 5000.0 # バネが押し返す力.

# ---------------------------------------------
# onready.
# ---------------------------------------------
@onready var _spr = $Sprite2D

# ---------------------------------------------
# var.
# ---------------------------------------------
var _player:Player = null

# ---------------------------------------------
# private functions.
# ---------------------------------------------
func _physics_process(delta: float) -> void:
	_spr.scale.y = 1.0
	if is_instance_valid(_player) == false:
		return # プレイヤー領域内にいないので何もしない.
	
	# バネで押し返す.
	var d = position.y - _player.position.y
	var size = Map.get_tile_size()
	d += size / 2.0
	if d <= 0:
		d = 0 # 最大の力.
		
	var damp_rate = 1.0 * (size - d) / size
	_spr.scale.y = 1 - damp_rate
	if _spr.scale.y < 0.2:
		_spr.scale.y = 0.2
	if damp_rate == 0.3 and _player.velocity.y > 0:
		_player.velocity.y *= 0.1
	damp_rate += 0.5
	if Input.is_action_pressed("action"):
		damp_rate *= 2.0 # バネジャンプ.
	
	# バネ速度を設定.
	var damp_velocity = Vector2.UP * (POWER * damp_rate * delta)
	_player.set_spring_velocity(damp_velocity)

## プレイヤーが領域内に入った.
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return # プレイヤー以外は何もしない.
	
	_player = body as Player
	_player.start_spring()

## プレイヤーが猟奇外に出た.
func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return # プレイヤー以外は何もしない.
	
	_player.end_spring()
	# 参照を消しておく.
	_player = null
