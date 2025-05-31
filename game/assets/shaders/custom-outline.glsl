uniform vec2 step;
uniform vec4 outlineColor; // this is your new customizable outline color

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
    float alpha = Texel(texture, texturePos + vec2(step.x, 0.0)).a +
                  Texel(texture, texturePos + vec2(-step.x, 0.0)).a +
                  Texel(texture, texturePos + vec2(0.0, step.y)).a +
                  Texel(texture, texturePos + vec2(0.0, -step.y)).a;

    vec4 texColor = Texel(texture, texturePos);

    if (alpha > 0.0 && texColor.a == 0.0) {
        return outlineColor * col; // use the passed-in color for outline
    } else {
        return texColor * col;
    }
}