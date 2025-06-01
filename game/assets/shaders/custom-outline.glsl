uniform vec2 step;
uniform vec4 outlineColor;

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
    float alpha = Texel(texture, texturePos + vec2(step.x, 0.0)).a +
                  Texel(texture, texturePos + vec2(-step.x, 0.0)).a +
                  Texel(texture, texturePos + vec2(0.0, step.y)).a +
                  Texel(texture, texturePos + vec2(0.0, -step.y)).a;

    vec4 texColor = Texel(texture, texturePos);

    if (alpha > 0.0 && texColor.a == 0.0) {
        vec4 premult = vec4(outlineColor.rgb * outlineColor.a, outlineColor.a);
        return premult * col;
    } else {
        return texColor * col;
    }
}