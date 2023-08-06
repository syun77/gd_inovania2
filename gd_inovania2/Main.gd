extends Node2D
# ===========================================
# メインシーン.
# ===========================================

# -------------------------------------------
# const.
# -------------------------------------------

# -------------------------------------------
# objects.
# -------------------------------------------
const BLOCK_OBJ = preload("res://src/gimmic/Block.tscn")
const LADDER_OBJ = preload("res://src/gimmic/Ladder.tscn")
const ONEWAY_FLOOR_OBJ = preload("res://src/gimmic/OnewayFloor.tscn")
const ONEWAY_WALL_OBJ = preload("res://src/gimmic/OneWayWall.tscn")
const EXCLAMATION_BLOCK_OBJ = preload("res://src/gimmic/ExclamationBlock.tscn")
const FALLING_FLOOR_OBJ = preload("res://src/gimmic/FallingFloor.tscn")
const VORTEX_OBJ = preload("res://src/gimmic/Vortex.tscn")
const SPRING_FLOOR_OBJ = preload("res://src/gimmic/SpringFloor.tscn")

# -------------------------------------------
# onready.
# -------------------------------------------
@onready var _map = $BgLayer/TileMap
@onready var _player = $MainLayer/Player
@onready var _camera = $Camera2D

@onready var _bg_layer = $BgLayer
@onready var _main_layer = $MainLayer
@onready var _particle_layer = $ParticleLayer
@onready var _ui_layer = $UILayer

## デバッグ用.
@onready var _dbg_label = $UILayer/DbgLabel

# -------------------------------------------
# var.
# -------------------------------------------
var _cnt:int = 0

# -------------------------------------------
# private functions.
# -------------------------------------------
## 開始.
func _ready() -> void:
	var layers = {
		"bg": _bg_layer,
		"main": _main_layer,
		"particle": _particle_layer,
		"ui": _ui_layer,
	}
	Common.setup(layers, _player, _camera)
	
	# マップのセットアップ.
	Map.setup(_map)
	
	# タイルマップからオブジェクトを作る.
	_create_obj_from_tile()
	
	# プレイヤー移動開始.
	_player.start()
	#_player.position.x += 4000

## 更新.
func _physics_process(delta: float) -> void:
	_cnt += 1
	# 共通の更新.
	Common.update(delta)
	
	if Common.is_hit_stop() == false:
		# プレイヤーの更新.
		_player.update(delta)
	
	# カメラの更新.
	_update_camera(delta)
	
	# デバッグ用更新.
	_update_debug()

## タイルからオブジェクトを作る.
func _create_obj_from_tile() -> void:
	for j in range(Map.height):
		# ハシゴにフタをするため下から処理する.
		j = Map.height - (j + 1)
		for i in range(Map.width):
			var pos = Map.grid_to_world(Vector2(i, j))
			var type = Map.get_floor_type_from_world(pos)
			if type == Map.eType.NONE:
				continue
			
			#print(type, ":", pos)
			
			# 以下タイルマップの機能では対応できないタイルの処理.
			match type:
				Map.eType.BLOCK:
					# 壊せる壁.
					var obj = BLOCK_OBJ.instantiate()
					obj.position = pos
					_bg_layer.add_child(obj)
					Map.erase_cell_from_world(pos)
					
				Map.eType.LADDER:
					# ハシゴ.
					var obj = LADDER_OBJ.instantiate()
					obj.position = pos
					#obj.z_index = -1
					_bg_layer.add_child(obj)
					Map.erase_cell_from_world(pos)
					
					# 上を調べてコリジョンがなければ一方通行床を置く.
					_check_put_oneway(i, j)

				Map.eType.CLIMBBING_WALL:
					# 登り壁はそのままでも良さそう...
					#Map.erase_cell_from_world(pos)
					pass
					
				Map.eType.ONEWAY_WALL_L:
					# 一方通行カベ(左).
					var obj = ONEWAY_WALL_OBJ.instantiate()
					obj.position = pos
					_bg_layer.add_child(obj)
					obj.setup(true)
					Map.erase_cell_from_world(pos)
					
				Map.eType.ONEWAY_WALL_R:
					# 一方通行カベ(右).
					var obj = ONEWAY_WALL_OBJ.instantiate()
					obj.position = pos
					_bg_layer.add_child(obj)
					obj.setup(false) # 右向き.
					Map.erase_cell_from_world(pos)
					
				Map.eType.EXCLAMATION_SWITCH:
					# びっくりスイッチ.
					_create_exclamation_block(i, j)
					Map.erase_cell_from_world(pos)
					
				Map.eType.FALLING_FLOOR:
					# 落下床.
					var obj = FALLING_FLOOR_OBJ.instantiate()
					obj.position = pos
					_bg_layer.add_child(obj)
					Map.erase_cell_from_world(pos)
					
				Map.eType.VORTEX_WARP:
					# ワープ渦巻き.
					# 終端判定があるので先に消しておく.
					Map.erase_cell_from_world(pos)
					_create_vortex_warp(i, j)
					
				Map.eType.SPRING_FLOOR:
					# バネ床.
					var obj = SPRING_FLOOR_OBJ.instantiate()
					obj.position = pos
					_bg_layer.add_child(obj)
					Map.erase_cell_from_world(pos)

## 上を調べてコリジョンがなければ一方通行床を置く.
## @note ハシゴの後ろに隠れている一方通行床がチラチラ見える不具合がある.
func _check_put_oneway(i:int, j:int) -> void:
	#if i == 31 and j == 11:
	#	return # ※[DEBUG]特定のタイルを強制的に除外.
	
	var pos = Map.grid_to_world(Vector2i(i, j))
	var pos2 = Map.grid_to_world(Vector2(i, j-1))
	var col_cnt = Map.get_tile_collision_polygons_count(Vector2(i, j-1), Map.eTileLayer.GROUND)
	if col_cnt > 0:
		return # コリジョンがあるので何もしない.
	
	var type = Map.get_floor_type(pos2)
	if type == Map.eType.LADDER:
		return # 上がハシゴなので何もしない.
	
	# 重ねるのはハシゴの上 (一方通行床で置き換える).
	Map.replace_cell_from_world(pos, Vector2i(4, 0))

## びっくりスイッチを作る.
func _create_exclamation_block(i:int, j:int) -> void:
	var type = Map.eType.EXCLAMATION_BLOCK # びっくりブロックを探す処理.
	var p = Vector2i(i, j)
	# まずは下を調べる.
	p.y += 1
	if Map.get_floor_type(p) != type:
		return # 下がびっくりブロックでなければ何もしない.
	# 見つかったのタイルを消しておく.
	Map.erase_cell(p)
	
	# びっくりブロックを生成.
	var block = EXCLAMATION_BLOCK_OBJ.instantiate()
	block.position = Map.grid_to_world(p)
	
	# 座標リスト.
	var pos_list = _create_passage_list(p, Map.eType.EXCLAMATION_BLOCK)
	_bg_layer.add_child(block)
	block.setup(pos_list)

## 経路リストを作る.
## @param base 開始位置.
## @param search_type 経路とみなすタイル.
## @param end_point_type 終端とするタイル.
func _create_passage_list(base:Vector2i, search_type:int, end_point_type:int=-1) -> Array:
	var ret = []
	
	var p = base # 基準座標をコピーして使う.
	for idx in range(64): # 最大64としておく.
		# 見つかったかどうか.
		var found = false
		var is_end = false # 終了. 
		# 上下左右を探す.
		for dir in [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]:
			var p2 = p + dir
			var type = Map.get_floor_type(p2)
			if type == end_point_type:
				# 終端タイル.
				is_end = true
				# 終端座標を結果に含めたいのでbreakしない.
				# break
			elif type != search_type:
				continue # 検索対象のタイルでない.
				
			# 見つかったタイルを消しておく.
			Map.erase_cell(p2)
			ret.append(p2 - base) # 基準からの相対座標.
			found = true
			# 次の座標から調べる.
			p = p2
			# 1方向だけ見つかれば良いのでbreak.
			break
			
		if is_end:
			# おしまい.
			break
		if found == false:
			# おしまい.
			break
	
	return ret
	
## ワープ渦巻きの経路を作る.
func _create_vortex_warp(i:int, j:int) -> void:
	var search_type = Map.eType.VORTEX_PASSAGE # 渦巻き通路を探す処理.
	var end_type = Map.eType.VORTEX_WARP # ワープ渦巻きがゴール.
	var p = Vector2i(i, j)
	
	# ワープ渦巻きを生成.
	var vortex1 = VORTEX_OBJ.instantiate()
	
	# 座標リスト.
	var pos_list = _create_passage_list(p, search_type, end_type)
	pos_list.push_front(Vector2i.ZERO) # 開始地点を入れておく.
	#print(pos_list)
	_bg_layer.add_child(vortex1)
	vortex1.setup(p, pos_list, -8)
	
	# 終端用のワープ渦巻きを作っておく.
	var pos_list2 = pos_list.duplicate() # 複製.
	# 終端を取得.
	var end_pos = pos_list2.pop_back()
	# 終端が開始.
	var p2 = p + end_pos
	var vortex2 = VORTEX_OBJ.instantiate()
	# 逆順にする.
	pos_list2.reverse()
	pos_list2 = pos_list2.map(func(a): return a-end_pos) # end_pos基準に変換.
	#print(pos_list2)
	_bg_layer.add_child(vortex2)
	vortex2.setup(p2, pos_list2, 8)

## カメラの更新.
func _update_camera(delta:float, is_warp:bool=false) -> void:
	# カメラの注視点
	var target = _player.position
	target.y += -Map.get_tile_size() # 1タイルずらす
	target.x += _player.velocity.x * 0.7 # 移動先を見る.
	
	if is_warp:
		# カメラワープが有効.
		_camera.position = target
	else:
		# 通常はスムージングを行う.
		_camera.position += (target - _camera.position) * 0.05	
	
	# 揺れ更新.
	_update_camera_shake(delta)

## カメラの揺れ更新.
func _update_camera_shake(_delta:float) -> void:
	var rate = Common.get_camera_shake_rate()
	if rate <= 0.0:
		_camera.offset = Vector2.ZERO
	var dx = 1
	if _cnt%4 < 2:
		dx = -1
	
	var intensity = Common.get_camera_shake_intensity()
	_camera.offset.x = 32.0 * dx * rate * intensity
	_camera.offset.y = 24.0 * randf_range(-rate, rate) * intensity

## デバッグ用更新.
func _update_debug() -> void:
	if Input.is_action_just_pressed("reset"):
		# リセット.
		get_tree().change_scene_to_file("res://Main.tscn")
	
	#_dbg_label.visible = true
	#var cnt = 0
	#for obj in _bg_layer.get_children():
	#	# 落下床をカウントする.
	#	if not obj is FallingFloor:
	#		continue
	#	cnt += 1
	#_dbg_label.text = "FallingFloor:%d"%cnt
