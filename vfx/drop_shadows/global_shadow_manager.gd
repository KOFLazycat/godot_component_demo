class_name GlobalShadowManager
extends Node2D
## 全局阴影管理器，用于统一管理和渲染所有全局阴影节点
## 通过设置z_index控制阴影渲染层级，通过shadow_color控制阴影颜色和透明度

@onready var canvas_group: CanvasGroup = $CanvasGroup
## 导出变量：阴影颜色（包含透明度），修改此属性会影响所有全局阴影
@export var shadow_color := Color.BLACK:
	set(value):
		shadow_color = value
		# 颜色变化时实时更新CanvasGroup颜色
		if is_instance_valid(canvas_group):
			canvas_group.self_modulate = shadow_color

func _ready() -> void:
	assert(canvas_group != null, "必须存在名为CanvasGroup的直系子节点")
	canvas_group.self_modulate = shadow_color


## 添加全局阴影节点到管理器中
func add_global_shadow_node(shadow_obj: Node2D) -> void:
	if not is_instance_valid(canvas_group):
		canvas_group = $CanvasGroup
	shadow_obj.modulate = Color.WHITE  # 使用CanvasGroup的颜色混合
	canvas_group.add_child(shadow_obj)
	#canvas_group.add_child.call_deferred(shadow_obj)
	shadow_obj.add_to_group("instanced")
