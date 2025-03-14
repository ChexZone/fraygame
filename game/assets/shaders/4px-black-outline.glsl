uniform vec2 step;

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
    float alpha = Texel(texture, texturePos + vec2(2.0 * step.x, 0.0)).a +
                  Texel(texture, texturePos + vec2(-2.0 * step.x, 0.0)).a +
                  Texel(texture, texturePos + vec2(0.0, 2.0 * step.y)).a +
                  Texel(texture, texturePos + vec2(0.0, -2.0 * step.y)).a;

    // Uncomment if rendering directly from the spritesheet
    // if (mod(texturePos.y, 1.0 / 12.0) <= 0.005) {
    //     return Texel(texture, texturePos) * col;
    // } else 

    if (alpha > 0.0 && Texel(texture, texturePos).a == 0.0) {
        return vec4(0.0, 0.0, 0.0, 1.0);
    } else if (Texel(texture, texturePos).a == 0.0) {
        // return vec4(1.0, 1.0, 1.0, 1.0) * col;
        return Texel(texture, texturePos) * col;
    } else {
        return Texel(texture, texturePos) * col;
    }
}