class_name PlayRandomSound
extends Node
## 随机音频播放控制器，支持从子音频节点中随机播放

## 是否在场景就绪时自动播放（导出属性）
@export var play_on_ready: bool = false

## 音频播放器节点池（自动初始化）
var audio_players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	# 初始化时收集所有子音频播放器节点
	_initialize_audio_players()
	
	# 根据设置自动播放
	if play_on_ready:
		play()


## 初始化音频播放器集合
func _initialize_audio_players() -> void:
	for child in get_children():
		# 统一识别所有类型的音频播放器（包括2D/3D变体）
		if child is AudioStreamPlayer2D:
			audio_players.append(child)
	
	# 可选：打乱数组实现更均匀的随机分布
	audio_players.shuffle()


## 随机播放一个音频（自动跳过无效实例）
func play() -> void:
	var player: AudioStreamPlayer2D = _get_valid_random_player()
	if player != null:
		player.play()


## 停止所有音频播放
func stop() -> void:
	for player: AudioStreamPlayer2D in audio_players:
		if is_instance_valid(player) and player.playing:
			player.stop()


## 检查是否有正在播放的音频
func is_playing() -> bool:
	for player: AudioStreamPlayer2D in audio_players:
		if is_instance_valid(player) and player.playing:
			return true
	return false


## 获取一个有效的随机播放器（核心逻辑）
func _get_valid_random_player() -> AudioStreamPlayer2D:
	# 安全防护：空数组直接返回
	if audio_players.is_empty():
		push_warning("No valid audio players available")
		return null
	
	# 筛选有效播放器
	var valid_players:Array[AudioStreamPlayer2D] = audio_players.filter(func(p): return is_instance_valid(p))
	if valid_players.is_empty():
		return null
	
	# 生成随机索引（避免size-1的手动计算）
	var random_index: int = randi() % valid_players.size()
	return valid_players[random_index]
