uniform vec2 step;
uniform vec4 outlineColor;
uniform sampler2DArray MainTex;

void effect() {
    vec2 texturePos = VaryingTexCoord.xy;
    vec4 col = VaryingColor;
    
    // Calculate alpha for outline detection using layer 0
    float alpha = Texel(MainTex, vec3(texturePos + vec2(step.x, 0.0), 0.0)).a +
                  Texel(MainTex, vec3(texturePos + vec2(-step.x, 0.0), 0.0)).a +
                  Texel(MainTex, vec3(texturePos + vec2(0.0, step.y), 0.0)).a +
                  Texel(MainTex, vec3(texturePos + vec2(0.0, -step.y), 0.0)).a;

    // Sample all 3 layers
    vec4 layer0 = Texel(MainTex, vec3(texturePos, 0.0));
    vec4 layer1 = Texel(MainTex, vec3(texturePos, 1.0));
    vec4 layer2 = Texel(MainTex, vec3(texturePos, 2.0));

    // Apply custom outline logic to layer 0
    if (alpha > 0.0 && layer0.a == 0.0) {
        vec4 premult = vec4(outlineColor.rgb * outlineColor.a, outlineColor.a);
        love_Canvases[0] = premult * col;
    } else {
        love_Canvases[0] = layer0 * col;
    }
    
    // Transfer layers 1 and 2 directly to their corresponding canvases
    love_Canvases[1] = layer1 * col;
    love_Canvases[2] = layer2 * col;
}