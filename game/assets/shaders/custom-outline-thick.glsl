uniform vec2 step; // 1.0 / texture width, height
uniform vec4 outlineColor;
uniform int thickness; // how many 1px passes to simulate (max ~4)

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
    vec4 texColor = Texel(texture, texturePos);
    
    if (texColor.a > 0.0) {
        return texColor * col;
    }
    
    float alpha = 0.0;
    
    // Sample all positions within Manhattan distance (diamond shape)
    for (int x = -thickness; x <= thickness; x++) {
        for (int y = -thickness; y <= thickness; y++) {
            if (x == 0 && y == 0) continue; // skip center pixel
            
            // Only sample if within Manhattan distance (creates diamond shape)
            if (abs(x) + abs(y) <= thickness) {
                vec2 offset = step * vec2(float(x), float(y));
                alpha += Texel(texture, texturePos + offset).a;
            }
        }
    }
    
    if (alpha > 0.0) {
        vec4 premult = vec4(outlineColor.rgb * outlineColor.a, outlineColor.a);
        return premult * col;
    }
    
    return texColor * col;
}