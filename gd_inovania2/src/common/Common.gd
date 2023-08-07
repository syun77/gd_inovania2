extends Node
# ========================================
# 共通モジュール.
# ========================================

# ----------------------------------------
# consts
# ----------------------------------------
## 同時再生可能なサウンドの数.
const MAX_SOUND = 8

## 1フレームあたりの経過時間.
const FPS_RATE = 1.0 / 60.0

## コリジョンレイヤー.
enum eCollisionLayer {
	PLAYER = 1, # プレイヤー.
	WALL = 2, # 壁・床.
	LADDER = 3, # ハシゴ.
	WALL2 = 4, # 登れる壁.
	SHIELD = 5, # シールド.
	BLOCK = 6, # 壊せる壁.
	ONEWAY = 7, # 一方通行床.
}

# ----------------------------------------
# var.
# ----------------------------------------
## 初期化済みかどうか.
var _initialized = false

## 共有オブジェクト.
var _layers = []
var _camera:Camera2D = null
var _player:Player = null
var _bgm:AudioStreamPlayer = null
### BGMテーブル.
var _bgm_tbl = {
	"ino1": "res://assets/sound/ino1.ogg",
	"ino2": "res://assets/sound/ino2.ogg",
}
var _snds:Array = []
### SEテーブル.
var _snd_tbl = {
	"block": "res://assets/sound/block.wav",
	"broken": "res://assets/sound/broken.wav",
	"climb": "res://assets/sound/climb.wav",
	"dash": "res://assets/sound/dash.wav",
	"itemget2": "res://assets/sound/itemget2.wav",
	"itemget": "res://assets/sound/itemget.wav",
	"jump": "res://assets/sound/jump.wav",
	"power_up": "res://assets/sound/powerup.wav",
	"switch": "res://assets/sound/switch.wav",
	"spring": "res://assets/sound/spring.wav",
	"warp": "res://assets/sound/warp.wav",
}

var _slow_timer = 0.0 # スロータイマー (未実装).
var _slow_rate = 1.0 # スロー時の経過時間倍率.
var _hit_stop_timer = 0.0 # ヒットストップタイマー.

## 画面揺れ.
var _shake_timer = 0.0 # 揺れタイマー.
var _shake_max_timer = 1.0 # 揺れタイマーの最大.
var _shake_intensity = 0.0 # 揺れ倍率.

# ----------------------------------------
# public functions.
# ----------------------------------------
func get_collision_bit(bit:eCollisionLayer) -> int:
	return int(pow(2, bit-1))

## 初期化.
func init() -> void:
	if _initialized == false:
		# 未初期化なので初期化する.
		# 常駐することでシーンの切り替わりでもBGMが途切れない.
		## BGM.
		if _bgm == null:
			_bgm = AudioStreamPlayer.new()
			add_child(_bgm)
			_bgm.bus = "BGM"
		
		# 初期化した.
		_initialized = true
	
	init_vars()

## 各種変数の初期化.
func init_vars() -> void:
	_snds.clear()

	# タイマーの初期化.
	_slow_timer = 0.0
	_hit_stop_timer = 0.0

## セットアップ.
func setup(layers, player:Player, camera:Camera2D) -> void:
	init_vars()
	
	_layers = layers
	_player = player
	_camera = camera
	# AudioStreamPlayerをあらかじめ作っておく.
	## SE.
	for i in range(MAX_SOUND):
		var snd = AudioStreamPlayer.new()
		#snd.volume_db = -4
		add_child(snd)
		_snds.append(snd)

## 更新.
func update(delta:float) -> void:
	# 各種タイマー更新.
	if _slow_timer > 0.0:
		_slow_timer -= delta # スロー再生 (未実装)
	if _hit_stop_timer > 0.0:
		_hit_stop_timer -= delta
	if _shake_timer > 0.0:
		_shake_timer -= delta

## CanvasLayerを取得する.
func get_layer(layer_name:String) -> CanvasLayer:
	return _layers[layer_name]

## プレイヤーを取得する.
func get_player() -> Player:
	return _player
	
## カメラを取得する.
func get_camera() -> Camera2D:
	return _camera

## カメラの視野を取得する.
func get_camera_rect() -> Rect2:
	return _camera.get_viewport_rect()

## カメラの中に入っているかどうか.
func is_in_camera(pos:Vector2, size:float, expand_ratio:float=1.0) -> bool:
	var rect1 = get_camera_rect()
	rect1.position += _camera.position
	rect1.position -= rect1.size/2 # 中央揃え.
	var rect2 = Rect2(pos, Vector2(size, size))
	rect1.size *= expand_ratio # カメラの範囲を拡張する.
	rect1.size += rect2.size * 2
	if rect1.intersects(rect2):
		return true
	return false
	
## スロー開始 (TODO:未実装)
func start_slow(time:float, rate:float) -> void:
	_slow_timer = time
	_slow_rate = rate

## スロー再生係数 (TODO:未実装)
func get_slow_rate() -> float:
	if _slow_timer > 0:
		return _slow_rate
	return 1.0
	
## ヒットストップ開始.
## @param 停止するフレーム数 (※秒数ではない)
func start_hit_stop(frame:int=3) -> void:
	_hit_stop_timer = FPS_RATE * frame

## ヒットストップ中かどうか.
func is_hit_stop() -> bool:
	return _hit_stop_timer > 0.0
	
## 揺れ開始.
## @param intensity 揺れの強さ.
## @param time 揺れが収まるまでの時間 (秒).
func start_camera_shake(intensity:float=1.0, time:float=1.0) -> void:
	_shake_intensity = intensity
	_shake_timer = time
	if time > 0.0:
		_shake_max_timer = time

## 揺れの割合を取得する.
func get_camera_shake_rate() -> float:
	if _shake_timer <= 0.0:
		return 0.0
	
	return _shake_timer / _shake_max_timer
## 揺れの強さを取得する.
func get_camera_shake_intensity() -> float:
	return _shake_intensity

## BGMの再生.
## @note _bgm_tblに事前登録が必要.
## @param 再生するBGMの名前
func play_bgm(key:String) -> void:
	if not key in _bgm_tbl:
		push_error("存在しないサウンド %s"%key)
		return
	_bgm.stream = load(_bgm_tbl[key])
	_bgm.play()

## BGMの停止.
func stop_bgm() -> void:
	_bgm.stop()

## SEの再生.
## @note _sndsに事前登録が必要.
## @param 再生するSEの名前
func play_se(key:String, id:int=0) -> void:
	if id < 0 or MAX_SOUND <= id:
		push_error("不正なサウンドID %d"%id)
		return
	
	if not key in _snd_tbl:
		push_error("存在しないサウンド %s"%key)
		return
	
	var snd = _snds[id]
	snd.stream = load(_snd_tbl[key])
	snd.play()
	
# ----------------------------------------
# private functions.
# ----------------------------------------
