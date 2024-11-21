extends Sprite2D

@export var modulate_config : Vector4 = Vector4(0, 0, 0, 0.6)
@onready var animation_player = $AnimationPlayer
var shadows : Array[Sprite2D] = []


func _ready():
	var image = texture.get_image()
	var image_texture = ImageTexture.create_from_image(image)
	
	var total_frames = int(texture.get_width() / 74.0)
	for frame_index in range(total_frames):
		var shadow = Sprite2D.new()
		shadow.texture = image_texture
		shadow.region_enabled = true
		shadow.region_rect = Rect2(frame_index * 74, 0, 74, 83)
		shadow.flip_h = flip_h
		shadow.flip_v = true
		shadow.position.y = 59
		shadow.position.x = -36
			
		shadow.modulate.r=modulate_config[0]
		shadow.modulate.g=modulate_config[1]
		shadow.modulate.b=modulate_config[2]
		shadow.modulate.a=modulate_config[3]
		shadow.skew = 1
		shadows.append(shadow)

func _process(_delta):
	var animation_frame : int = 0
	if animation_player.is_playing():
		var anim : Animation = animation_player.get_animation(animation_player.current_animation)
		var track_idx = anim.find_track(".:frame", Animation.TYPE_VALUE)
		if track_idx != -1:
			var current_time = animation_player.current_animation_position
			var key_count = anim.track_get_key_count(track_idx)

			for i in range(key_count):
				if i == key_count - 1 or anim.track_get_key_time(track_idx, i + 1) > current_time:
					animation_frame = anim.track_get_key_value(track_idx, i)
					break
					
	for i in range(shadows.size()):
		if shadows[i].get_parent():
			remove_child(shadows[i])
	add_child(shadows[animation_frame])
