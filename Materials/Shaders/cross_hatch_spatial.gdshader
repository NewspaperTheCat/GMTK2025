shader_type spatial;

uniform sampler2D cross_hatch_texture: filter_linear_mipmap_anisotropic;

void light() {
	float diffuse_value = dot(LIGHT, NORMAL) * ATTENUATION;
	
	float light_value = 1.0;
	vec2 hatch_size = vec2(textureSize(cross_hatch_texture, 0));
	vec2 hatch_uv = vec2(mod(UV.x, hatch_size.x), mod(UV.y, hatch_size.y)) * 13.0;
	//vec2 hatch_uv = UV * 13.0;
	
	light_value -= smoothstep(0.9, 0.7,
		diffuse_value) * texture(cross_hatch_texture, hatch_uv).r;
	
	light_value -= smoothstep(0.6, 0.4,
		diffuse_value) * texture(cross_hatch_texture, hatch_uv).g;
	
	light_value -= smoothstep(0.3, 0.1,
		diffuse_value) * texture(cross_hatch_texture, hatch_uv).b;
	
	light_value = clamp(light_value, 0.0, 1.0);
	
	DIFFUSE_LIGHT += light_value;
}