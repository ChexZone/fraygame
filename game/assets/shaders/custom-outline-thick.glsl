#pragma language glsl3


uniform vec2 step; // 1.0 / texture width, height
uniform vec4 outlineColor;
uniform int thickness; // how many 1px passes to simulate (max ~4)
uniform sampler2DArray MainTex;

void effect() {
    vec2 texturePos = VaryingTexCoord.xy;
    vec4 col = VaryingColor;
    
    // Sample all 3 layers
    vec4 layer0 = Texel(MainTex, vec3(texturePos, 0.0));
    vec4 layer1 = Texel(MainTex, vec3(texturePos, 1.0));
    vec4 layer2 = Texel(MainTex, vec3(texturePos, 2.0));
    
    // Apply thick outline logic to layer 0
    if (layer0.a > 0.0) {
        love_Canvases[0] = layer0 * col;
    } else {
        float alpha = 0.0;
        
        // Sample all positions within Manhattan distance (diamond shape)
        for (int x = -thickness; x <= thickness; x++) {
            for (int y = -thickness; y <= thickness; y++) {
                if (x == 0 && y == 0) continue; // skip center pixel
                
                // Only sample if within Manhattan distance (creates diamond shape)
                if (abs(x) + abs(y) <= thickness) {
                    vec2 offset = step * vec2(float(x), float(y));
                    alpha += Texel(MainTex, vec3(texturePos + offset, 0.0)).a;
                }
            }
        }
        
        if (alpha > 0.0) {
            vec4 premult = vec4(outlineColor.rgb * outlineColor.a, outlineColor.a);
            love_Canvases[0] = premult * col;
        } else {
            love_Canvases[0] = layer0 * col;
        }
    }
    
    // Transfer layers 1 and 2 directly to their corresponding canvases
    love_Canvases[1] = layer1;
    love_Canvases[2] = layer2;
}