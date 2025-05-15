class_name PlayRandomSound
extends Node

"""
随机音效播放节点
功能：
- 自动收集所有子节点中的音频播放器（AudioStreamPlayer及其子类）
- 支持随机播放、停止播放和检查播放状态
- 可配置在节点就绪时自动播放

使用说明：
1. 将AudioStreamPlayer/AudioStreamPlayer2D/AudioStreamPlayer3D作为子节点添加
2. 通过play_on_ready控制是否在就绪时自动播放
"""

# 是否在节点就绪时自动播放音效（可在编辑器中配置）
@export var play_on_ready: bool = false

# 存储所有音频播放器子节点（仅包含AudioStreamPlayer及其子类）
var audio_players: Array = []


func _ready():
	_collect_audio_players()  # 收集所有音频播放器子节点
	if play_on_ready:
		play()  # 触发自动播放


func _collect_audio_players():
	"""
	私有方法：遍历子节点并收集所有AudioStreamPlayer及其子类
	会清空现有列表并重新填充
	"""
	audio_players.clear()
	for child in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D or child is AudioStreamPlayer3D:
			audio_players.append(child)
	
	# 空列表提示（辅助调试）
	if audio_players.is_empty():
		push_warning("PlayRandomSound节点下未找到任何音频播放器子节点！")


func play():
	"""
	随机播放一个音频播放器（若存在）
	播放前会自动检查列表有效性
	"""
	if audio_players.is_empty():
		return  # 空列表直接返回（已有警告，无需重复提示）
	
	# 生成随机索引（范围：0到列表长度-1）
	var random_index: int = randi_range(0, audio_players.size() - 1)
	audio_players[random_index].play()  # 调用播放接口


func stop():
	"""停止所有音频播放器的播放"""
	for player in audio_players:
		player.stop()


func is_playing():
	"""检查是否有任意音频播放器正在播放"""
	for player in audio_players:
		if player.playing:
			return true
	return false
