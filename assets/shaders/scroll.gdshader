shader_type canvas_item;
uniform float speed = 0.8;
void fragment() {
	COLOR = texture(TEXTURE, UV + vec2(TIME * speed, 0.0));
}
