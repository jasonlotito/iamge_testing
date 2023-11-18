shader_type canvas_item;

// Default desc
uniform vec3 luminsence = vec3(.299,.587,.144);
uniform vec3 swap_colors[256];
uniform bool do_swap_colors = false;
uniform bool do_overlay = true;
uniform vec3 over_color : source_color = vec3(1.0);
uniform float over_amount : hint_range(0,1) = 0.0;
uniform int size = 8;
uniform vec3 colors[256];

vec3 color_swap(int idx) 
{
	return swap_colors[idx];
}

vec4 quant_color(vec3 color) 
{
	vec3 min_color = vec3(0);
	float min_diff = 9999.0;
	int id = 0;
	for (int i = 0; i < size; i++) {
		float cur_dist = distance(colors[i], color);
		if (cur_dist < min_diff) {
			min_diff = cur_dist;
			min_color = colors[i];
			id = i;
		}
	}
	return vec4(min_color.x, min_color.y, min_color.z, float(id));
}

float vec3_avg(vec3 color) {
	return (color.r + color.g + color.b) / 3.0;
}

vec3 overlay(vec3 color) {
	return mix(color.rgb, over_color.rgb, over_amount);
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec3 color = vec3(COLOR.r, COLOR.g, COLOR.b);
	vec4 quant_color_idx = quant_color(color);
	vec3 c = vec3(quant_color_idx.xyz);
	float idx = quant_color_idx.w;
	
	if (do_swap_colors) {
		c = color_swap(int(idx));
	}
	
	COLOR = vec4(c, 1.0);
	
	if (do_overlay) {
		COLOR.rgb = overlay(COLOR.rgb);
	}
}
