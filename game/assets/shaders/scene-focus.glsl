#define MAX_LIGHTS 15

extern vec4 lightRects[MAX_LIGHTS];  // (topleft_x, topleft_y, bottomright_x, bottomright_y)
extern float radii[MAX_LIGHTS];        // inset radius (for degenerate rectangle -> circle)
extern float sharpnesses[MAX_LIGHTS];  // per-light sharpness (0.0 = no gradient, >0 = gradient)
extern vec4 lightChannels[MAX_LIGHTS]; // vec4: rgb = color, a = brightness (0 = none, 1 = full)
extern float blendRange;               // global blend range multiplier
extern int lightCount;                 // number of active lights
extern vec2 aspectRatio;               // e.g. {16, 9}
extern vec3 baseShadowColor;           // base dark color when no light is applied
extern float darkenFactor;             // controls how dark the darkest shade is (0.0 = pure base, 1.0 = no darkening)

// Signed distance function for an axis–aligned box.
float sdfBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texColor = Texel(texture, texture_coords);
    
    // Determine the base minimum color.
    vec3 minColor = mix(baseShadowColor, texColor.rgb, darkenFactor);
    
    float totalIntensity = 0.0;
    vec3 weightedColor = vec3(0.0);
    
    // Adjust coordinates for aspect ratio.
    vec2 aspectCorrectedCoords = texture_coords * aspectRatio;
    
    for (int i = 0; i < lightCount; i++) {
        // Convert the rectangle's corners to aspect–corrected space.
        vec2 tl = lightRects[i].xy * aspectRatio;
        vec2 br = lightRects[i].zw * aspectRatio;
        
        // Compute center and half–size.
        vec2 center = (tl + br) * 0.5;
        vec2 halfSize = abs(br - tl) * 0.5;
        
        // Compute signed distance from current fragment to the rectangle's edge.
        float d = sdfBox(aspectCorrectedCoords - center, halfSize) - radii[i];
        
        float baseContribution;
        if (sharpnesses[i] == 1.0) {
            // Hard edge with no gradient: full contribution if inside, none if outside.
            baseContribution = (d <= 0.0) ? 1.0 : 0.0;
        } else {
            // Calculate fade width based on blendRange and sharpness.
            float fadeWidth = blendRange * mix(0.2, 0.01, sharpnesses[i]);
            baseContribution = 1.0 - smoothstep(0.0, fadeWidth, d);
        }
        
        // Scale contribution by brightness.
        float brightness = lightChannels[i].a;
        float c = brightness * baseContribution;
        
        totalIntensity += c;
        weightedColor += c * lightChannels[i].rgb;
    }
    
    // Clamp overall light intensity and compute composite tint.
    float intensity = clamp(totalIntensity, 0.0, 1.0);
    vec3 compositeTint = (totalIntensity > 0.0) ? (weightedColor / totalIntensity) : vec3(1.0);
    
    // Blend final color from dark base to tinted texture.
    vec3 finalColor = mix(minColor, texColor.rgb * compositeTint, intensity);
    
    return vec4(finalColor, texColor.a);
}
