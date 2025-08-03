shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

uniform sampler2D minimal_hatch;
uniform sampler2D single_hatch;
uniform sampler2D covering_hatch;
uniform sampler2D cross_hatch;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 hatch_size = vec2(textureSize(single_hatch, 0)) / vec2(2, 2);
	vec2 hatch_uv = vec2(mod(FRAGCOORD.x, hatch_size.x) / hatch_size.x, mod(FRAGCOORD.y, hatch_size.y) / hatch_size.y);
	
	vec3 col = texture(screen_texture, SCREEN_UV).xyz;
	
	float lum = (col.r * 0.299) + (col.g * 0.587) + (col.b * 0.114);
	
	if (lum < .3) {
		COLOR.xyz = (texture(cross_hatch, hatch_uv).xyz + vec3(1,1,1)) * col / vec3(2,2,2);
	} else if (lum < .45) {
		COLOR.xyz = (texture(single_hatch, hatch_uv).xyz  + vec3(1,1,1)) * col / vec3(2,2,2);
	} else {
		COLOR.xyz = col;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
