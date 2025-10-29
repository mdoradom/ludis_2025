shader_type canvas_item;

uniform float scroll_speed = 0.08;
uniform vec2 scroll_direction = vec2(1.0, 0.0);

void fragment()
{
    vec2 uv = UV;
    
    // Apply scrolling with proper wrapping
    vec2 scroll_offset = scroll_direction * scroll_speed * TIME;
    
    // Use fract() to ensure proper tiling/wrapping
    uv = fract(uv + scroll_offset);
    
    COLOR = texture(TEXTURE, uv);
}