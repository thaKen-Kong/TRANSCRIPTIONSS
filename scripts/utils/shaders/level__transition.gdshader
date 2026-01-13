shader_type canvas_item;

uniform float progress : hint_range(0,1);
uniform float diamondPixelSize = 20.0;
uniform vec4 rectColor = vec4(1.0, 1.0, 1.0, 1.0); // default color

void fragment() {
    vec2 pos = FRAGCOORD.xy / diamondPixelSize;
    vec2 grid = floor(pos);
    vec2 f = fract(pos);
    float dist = abs(f.x - 0.5) + abs(f.y - 0.5);

    if (grid.x + grid.y + dist > progress * 50.0) {
        discard;
    }

    COLOR = rectColor;
}
