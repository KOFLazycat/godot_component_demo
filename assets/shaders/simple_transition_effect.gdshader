shader_type canvas_item;
uniform float Speed = 1.0; // movement speed

uniform float Intensity = 2.0; // higher numbers add a second color
uniform float Hardness = 500.0; // circle sizes
uniform vec2 Scale = vec2(1.0,1.0); // scale
uniform float RotationSpeed = 1.0; // rotation speed
uniform vec3 Color = vec3(1.0,1.0,1.0); //attempt at color changing, doesn't really work, only barely noticeable when hardness is at 1f

// one thing that may happen is that the second color may match your theme for some reason, but it should go back to being black when running the game.

void fragment()
{
	float coolEffect = pow(sin((sin(UV.x*(100.0)*Scale.x)*cos(UV.y*(100.f*Scale.y)))+(sin(UV.x+TIME*RotationSpeed)+cos(UV.y+TIME*RotationSpeed))+TIME*Speed)*Intensity,Hardness);

	vec4 offsetColor = vec4(coolEffect+Color.r,coolEffect+Color.g,coolEffect+Color.b,coolEffect);
	COLOR = offsetColor;
}