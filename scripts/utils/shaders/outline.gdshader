shader_type canvas_item;

uniform vec3 outline_color: source_color = vec3(1.0, 1.0, 0.0);
uniform float progress: hint_range(0.0, 1.0) = 1.0;
uniform float width: hint_range(0.0, 0.01) = 0.002;

void fragment() {
    float alpha_center = texture(TEXTURE, UV).a;

    // Sample neighboring pixels
    float alpha_up    = texture(TEXTURE, UV + vec2(0.0, -width)).a;
    float alpha_down  = texture(TEXTURE, UV + vec2(0.0, width)).a;
    float alpha_left  = texture(TEXTURE, UV + vec2(-width, 0.0)).a;
    float alpha_right = texture(TEXTURE, UV + vec2(width, 0.0)).a;

    // If the current pixel is transparent, but any neighbor is opaque, show outline
    float outline_alpha = step(0.01, max(max(alpha_up, alpha_down), max(alpha_left, alpha_right)) - alpha_center);

    // Apply outline color only outside
    vec4 outline = vec4(outline_color, outline_alpha);

    // Blend with original sprite
    COLOR = mix(texture(TEXTURE, UV), outline, outline_alpha * progress);
}
