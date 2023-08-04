extends Area2D
# =============================================
# バネ床.
# =============================================

# ---------------------------------------------
# const.
# ---------------------------------------------
const POWER = 50.0 # バネが押し返す力.

# ---------------------------------------------
# var.
# ---------------------------------------------
var _player:Player = null

# ---------------------------------------------
# private functions.
# ---------------------------------------------
func _physics_process(delta: float) -> void:
	if is_instance_valid(_player) == false:
		return # プレイヤー領域内にいないので何もしない.
	
	# バネで押し返す.
	var d = position.y - _player.position.y
	var size = Map.get_tile_size()
	d -= size / 2
	if d <= 0:
		d = 0 # 最大の力.
	var damp_rate = 1 + 1.0 * (size - d) / size
	_player.velocity.y -= POWER * damp_rate

## プレイヤーが領域内に入った.
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return # プレイヤー以外は何もしない.
	
	_player = body as Player
	print("into Player", _player)

## プレイヤーが猟奇外に出た.
func _on_body_exited(body: Node2D) -> void:
	if not body is Player:
		return # プレイヤー以外は何もしない.
	
	# 参照を消しておく.
	_player = null
