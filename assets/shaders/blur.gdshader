shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 2.0;
uniform int samples : hint_range(1, 32) = 16;

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 blur_offset = blur_amount / screen_size;
    
    vec4 color = vec4(0.0);
    float total_weight = 0.0;
    
    // Gaussian blur using multiple samples
    for (int i = -samples/2; i <= samples/2; i++) {
        for (int j = -samples/2; j <= samples/2; j++) {
            vec2 offset = vec2(float(i), float(j)) * blur_offset;
            float weight = exp(-0.5 * (float(i*i + j*j)) / float(samples/4));
            
            color += texture(SCREEN_TEXTURE, SCREEN_UV + offset) * weight;
            total_weight += weight;
        }
    }
    
    COLOR = color / total_weight;
}