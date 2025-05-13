class_name DropShadow
extends Node2D
## 动态投影系统，支持多种节点类型，可配置全局/本地阴影模式
## 注意：使用全局模式时需要确保GlobalShadowManager场景已正确配置

# 全局阴影管理器单例引用
static var global_manager: GlobalShadowManager
# 全局管理器场景路径（需在编辑器中正确设置）
const GLOBAL_MANAGER_PATH: PackedScene = preload("res://vfx/drop_shadows/global_shadow_manager.tscn")

## 是否静态阴影（静态阴影不需要每帧更新）
@export var is_static: bool = true
## 是否使用全局阴影管理器
@export var is_global: bool = true
## 本地模式下的z_index相对值（仅当is_global=false时生效）
@export var custom_z_index: int = -1
## 是否在节点就绪时自动创建阴影
@export var create_on_ready: bool = true
## 阴影投射距离
@export var shadow_distance: float = 25.0
## 阴影投射方向（角度制）
@export var shadow_angle: float = 30.0

@onready var _shadow_offset: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(shadow_angle)) * shadow_distance

var _shadow_node: Node2D  # 阴影节点实例
var _delete_on_exit: bool = true  # 退出时自动删除阴影


func _ready() -> void:
	# 初始化全局管理器单例
	if not is_instance_valid(global_manager):
		global_manager = _get_or_create_global_manager()
	
	if create_on_ready:
		prints(get_parent())
		create_shadow()


## 创建阴影实例（支持多种父节点类型）
func create_shadow() -> void:
	var parent = get_parent()
	if not parent is Node2D:
		push_error("父节点必须继承自Node2D")
		return
	# 信号绑定
	_setup_signal_connections()
	
	# 根据父节点类型创建对应阴影
	_shadow_node = _create_shadow_node(parent)
	if not _shadow_node:
		push_warning("不支持的父节点类型：%s" % parent.get_class())
		set_process(false)
		return
	
	if is_static:
		set_process(false)
	
	update_transform()
	
	# 配置通用阴影属性
	_configure_shadow_appearance()
	
	update_visibility()


## 每帧更新阴影位置（仅动态阴影）
func _process(_delta: float) -> void:
	update_transform()


## 更新阴影可见性
func update_visibility() -> void:
	if is_instance_valid(_shadow_node):
		_shadow_node.visible = is_visible_in_tree()


## 退出场景树时清理阴影
func on_tree_exit() -> void:
	if _delete_on_exit and is_instance_valid(_shadow_node):
		_shadow_node.queue_free()
		set_process(false)


## 更新阴影位置变换
func update_transform() -> void:
	if not is_instance_valid(_shadow_node):
		return
	
	if is_global:
		_shadow_node.global_transform = global_transform
		_shadow_node.global_position = global_position + _shadow_offset
	else:
		_shadow_node.position = _shadow_offset


# 内部方法 -----------------------------------------------------------

# 获取或创建全局管理器实例
func _get_or_create_global_manager() -> GlobalShadowManager:
	# 先在场景中查找现有管理器
	var manager = get_tree().get_first_node_in_group("global_drop_shadow_manager")
	if is_instance_valid(manager):
		return manager
	
	# 创建新实例并配置
	manager = GLOBAL_MANAGER_PATH.instantiate()
	manager.add_to_group("global_drop_shadow_manager")
	get_tree().root.add_child.bind(manager).call_deferred()
	return manager


# 根据父节点类型创建对应阴影节点
func _create_shadow_node(parent: Node2D) -> Node2D:
	if parent is Sprite2D:
		return _create_sprite_shadow(parent)
	elif parent is AnimatedSprite2D:
		return _create_animated_sprite_shadow(parent)
	elif parent is Polygon2D:
		return _create_polygon_shadow(parent)
	elif parent is TileMap:
		return _create_tilemap_shadow(parent)
	return null


# 创建精灵类型阴影
func _create_sprite_shadow(parent: Sprite2D) -> Sprite2D:
	var shadow = Sprite2D.new()
	shadow.texture = parent.texture
	shadow.region_enabled = parent.region_enabled
	shadow.flip_h = parent.flip_h
	shadow.flip_v = parent.flip_v
	shadow.hframes = parent.hframes
	shadow.vframes = parent.vframes
	shadow.frame = parent.frame
	shadow.region_rect = parent.region_rect
	shadow.offset = parent.offset
	return shadow


# 创建动画精灵类型阴影
func _create_animated_sprite_shadow(parent: AnimatedSprite2D) -> AnimatedSprite2D:
	var shadow : AnimatedSprite2D = parent.duplicate(8)
	# 移除子节点中的DropShadow组件
	for child in shadow.get_children():
		if child is DropShadow:
			child.free()
	return shadow


# 创建多边形类型阴影
func _create_polygon_shadow(parent: Polygon2D) -> Polygon2D:
	var shadow = Polygon2D.new()
	shadow.polygon = parent.polygon
	return shadow


# 创建瓦片地图类型阴影
func _create_tilemap_shadow(parent: TileMap) -> TileMap:
	var shadow = parent.duplicate()
	shadow.z_index = 0
	# 清理可能存在的子节点
	for child in shadow.get_children():
		child.queue_free()
	return shadow


# 配置阴影视觉表现
func _configure_shadow_appearance() -> void:
	_shadow_node.modulate = Color.BLACK
	if is_global:
		_shadow_node.z_as_relative = true
		_shadow_node.z_index = 0
		global_manager.add_global_shadow_node(_shadow_node)
	else:
		add_child(_shadow_node)
		_shadow_node.z_index = custom_z_index
		show_behind_parent = true
		_shadow_node.show_behind_parent = true
		_shadow_node.modulate = global_manager.shadow_color
		update_transform()


# 设置信号连接
func _setup_signal_connections() -> void:
	visibility_changed.connect(update_visibility)
	tree_exited.connect(on_tree_exit)


## 设置阴影投射距离（支持运行时动态调整）
func set_shadow_offset(distance: float) -> void:
	shadow_distance = distance
	_shadow_offset = Vector2.RIGHT.rotated(deg_to_rad(shadow_angle)) * shadow_distance
