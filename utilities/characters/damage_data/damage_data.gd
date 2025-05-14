## 伤害数据容器，用于传递伤害相关参数
class_name DamageData 
extends Node
## 供HealthManager使用的参数
var damage_amount: int = 0            # 伤害数值

## 供BloodSpawner使用的参数
var spawn_blood: bool = true          # 是否生成基础血液
var spawn_extra_blood: bool = false   # 是否生成额外血液
var spawn_blood_cloud: bool = false   # 是否生成血雾
var play_sound: bool = true           # 是否播放音效
var damage_direction: Vector2 = Vector2.RIGHT  # 伤害来源方向
var damage_position: Vector2          # 命中点的全局坐标
var hit_normal: Vector2 = Vector2.RIGHT        # 受击表面的法线方向

## 其他参数
var source_of_damage: Node2D          # 伤害来源对象
var stun_time: float = -1.0           # 眩晕时间（-1表示不造成眩晕）
var knockback_modifier: float = 1.0   # 击退效果系数
