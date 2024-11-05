extends CharacterBody2D

@onready var hurt_box: Area2D = $HurtBox


func _ready() -> void:
	hurt_box.area_entered.connect(on_hurt_box_area_entered)


func on_hurt_box_area_entered(area: Area2D) -> void:
	area.owner.queue_free()
