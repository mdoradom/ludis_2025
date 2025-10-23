shader_type canvas_item;

// --- Toggles ---
uniform float shadow_amount : hint_range(0.0, 1.0) = 1.0;
uniform float outline_amount : hint_range(0.0, 1.0) = 1.0;

// --- General ---
uniform bool debug = false;
uniform float canvas_scale = 2.0; // General scale to make room for effects (was border_scale)

// --- Shadow Uniforms ---
uniform vec2 shadow_offset = vec2(-10.0, -10.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float shadow_blur : hint_range(0.0, 5.0) = 0.0;
uniform float shadow_scale = 1.5;
uniform bool shadow_disable_rotating = false;
uniform vec2 sprite_lift_offset = vec2(2.0, 2.0); // Lifts sprite when shadow is active

// --- Outline Uniforms ---
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0, 10) = 1.0;
uniform int outline_pattern : hint_range(0, 2) = 0; // 0:diamond, 1:circle, 2:square
uniform bool outline_inside = false;
uniform vec2 outline_sprite_sheet_size = vec2(1.0); // was number_of_images

varying flat vec4 modulate;
varying flat float sprite_rotation;

void vertex() {
	// We use the shadow's scaling method as the base for making room.
	// It scales the canvas to fit the largest effect (shadow or base scale).
	float final_scale = max(canvas_scale, canvas_scale * shadow_scale);
	VERTEX.xy *= vec2(final_scale);
	modulate = COLOR;
	sprite_rotation = atan(MODEL_MATRIX[0][1], MODEL_MATRIX[0][0]);
}

// --- Common Helper Functions ---

vec4 sample_texture_safe(sampler2D tex, vec2 uv) {
	// Samples texture, returning transparent black if UV is out of 0-1 range
	return (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
		? vec4(0.0)
		: texture(tex, uv);
}

vec2 rotate_point(vec2 point, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec2(
		point.x * c - point.y * s,
		point.x * s + point.y * c
	);
}

// --- Shadow Helper Functions ---

vec4 apply_gaussian_blur(sampler2D tex, vec2 uv, vec2 pixel_size) {
	if (shadow_blur <= 0.0) return sample_texture_safe(tex, uv);

	vec4 color_blur = vec4(0.0);
	float total_weight = 0.0;
	// Kernel size is proportional to blur amount
	int kernel_size = int(shadow_blur * 3.0);

	for (int x = -kernel_size; x <= kernel_size; x++) {
		for (int y = -kernel_size; y <= kernel_size; y++) {
			vec2 blur_offset = vec2(float(x), float(y)) * pixel_size;
			// Gaussian falloff
			float weight = exp(-0.5 * (float(x * x + y * y)) / (shadow_blur * shadow_blur));
			color_blur += sample_texture_safe(tex, uv + blur_offset) * weight;
			total_weight += weight;
		}
	}

	return total_weight > 0.0 ? color_blur / total_weight : vec4(0.0);
}

float calculate_fade(float coord, float scale) {
	// Fades the shadow near the edges of the scaled canvas
	if (coord < 0.0) {
		return 1.0 + (coord / (scale - 1.0));
	} else if (coord > 1.0) {
		return 1.0 - ((coord - 1.0) / (scale - 1.0));
	}
	return 1.0;
}

vec4 process_texture(vec2 uv, sampler2D tex, bool is_main, vec2 pixel_size) {
	if (is_main) {
		// Main texture is just sampled and modulated
		return sample_texture_safe(tex, uv) * modulate;
	}

	// Shadow texture is blurred
	vec4 blurred = apply_gaussian_blur(tex, uv, pixel_size);
	// Shadow texture is faded at the edges
	float fade_x = calculate_fade(uv.x, shadow_scale);
	float fade_y = calculate_fade(uv.y, shadow_scale);
	float fade = smoothstep(0.0, 1.0, min(fade_x, fade_y));

	// Shadow color is applied
	return vec4(shadow_color.rgb, (blurred.a * shadow_color.a) * modulate.a * fade);
}

// --- Outline Helper Functions ---

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
	// Checks neighbors for a pixel with contrary alpha (transparent vs. opaque)
	// This determines if the current pixel is an edge.
	for (float i = -ceil(outline_width); i <= ceil(outline_width); i++) {
		float x = abs(i) > outline_width ? outline_width * sign(i) : i;
		float offset;

		if (outline_pattern == 0) { // Diamond
			offset = outline_width - abs(x);
		} else if (outline_pattern == 1) { // Circle
			offset = floor(sqrt(pow(outline_width + 0.5, 2) - x * x));
		} else if (outline_pattern == 2) { // Square
			offset = outline_width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			// Check if neighbor is outside sprite sheet bounds OR is transparent
			// Compare this check (true/false) with the `outline_inside` flag
			if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0) == outline_inside) {
				return true;
			}
		}
	}

	return false;
}

// --- Fragment ---

void fragment() {
	float final_scale = max(canvas_scale, canvas_scale * shadow_scale);
	// Calculate the base UV based on the scaled vertex
	vec2 base_scaled_uv = UV * final_scale - (0.5 * (final_scale - 1.0));

	// --- Calculate Sprite Lift ---
	// 1. Determine lift direction, respecting rotation
	vec2 adjusted_lift_offset = shadow_disable_rotating ? sprite_lift_offset : rotate_point(sprite_lift_offset, -sprite_rotation);
	// 2. Scale lift by shadow_amount and pixel size
	// We subtract the offset from the UV to move the sprite "up" and "right" (positive offset)
	vec2 lift_uv_offset = adjusted_lift_offset * shadow_amount * TEXTURE_PIXEL_SIZE;
	// 3. Apply lift to main texture UV
	vec2 main_uv = base_scaled_uv - lift_uv_offset;

	// 1. Get the main texture color (using the lifted UV)
	vec4 main_texture = process_texture(main_uv, TEXTURE, true, TEXTURE_PIXEL_SIZE);

	// 2. Calculate Shadow
	vec4 shadow = vec4(0.0);
	if (shadow_amount > 0.0) {
		vec2 adjusted_shadow_offset = shadow_disable_rotating ? shadow_offset : rotate_point(shadow_offset, -sprite_rotation);
		// Shadow UV is based on the *original* position
		vec2 shadow_uv = base_scaled_uv + adjusted_shadow_offset * TEXTURE_PIXEL_SIZE;
		shadow = process_texture(shadow_uv, TEXTURE, false, TEXTURE_PIXEL_SIZE);
		shadow.a *= shadow_amount; // Apply the amount to the shadow's alpha
	}

	// 3. Calculate Outline
	vec4 final_main_color = main_texture;
	if (outline_amount > 0.0) {
		// Calculate sprite sheet boundaries for the current UV (using the lifted UV)
		vec2 image_top_left = floor(main_uv * outline_sprite_sheet_size) / outline_sprite_sheet_size;
		vec2 image_bottom_right = image_top_left + vec2(1.0) / outline_sprite_sheet_size;

		// Check if the current pixel is an edge (using the lifted UV)
		if ((main_texture.a > 0.0) == outline_inside && hasContraryNeighbour(main_uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
			// If it's an edge, calculate the full outline color
			vec4 outlined_color = main_texture;
			outlined_color.rgb = outline_inside ? mix(main_texture.rgb, outline_color.rgb, outline_color.a) : outline_color.rgb;
			outlined_color.a += (1.0 - main_texture.a) * outline_color.a;

			// Mix between the original texture and the outlined color by outline_amount
			final_main_color = mix(main_texture, outlined_color, outline_amount);
		}
	}

	// 4. Combine Shadow and Main (with Outline)
	// Use premultiplied alpha blending
	vec4 main_pm = vec4(final_main_color.rgb * final_main_color.a, final_main_color.a);
	vec4 shadow_pm = vec4(shadow.rgb * shadow.a, shadow.a);

	// Shadow is drawn "under" the main texture
	vec4 out_pm = shadow_pm * (1.0 - main_pm.a) + main_pm;

	// Convert back from premultiplied alpha
	vec4 res = vec4(
		out_pm.rgb / max(out_pm.a, 0.0001), // Avoid division by zero
		out_pm.a
	);

	// 5. Apply Debug and Final Color
	vec4 debug_layer = vec4(1.0, 0.0, 0.0, 0.3); // Red overlay for debugging
	// Use mix to handle debug or final result, ensuring transparency is respected
	COLOR = mix(debug ? debug_layer : res, res, res.a);
}
