#define MAX_LIGHTS 25

extern vec4 lightRects[MAX_LIGHTS];  // (topleft_x, topleft_y, bottomright_x, bottomright_y)
extern float radii[MAX_LIGHTS];        // inset radius (for degenerate rectangle -> circle)
extern float sharpnesses[MAX_LIGHTS];  // per-light sharpness (0.0 = no gradient, >0 = gradient)
extern vec4 lightChannels[MAX_LIGHTS]; // vec4: rgb = color, a = brightness (0 = none, 1 = full)
extern float blendRange;               // global blend range multiplier
extern int lightCount;                 // number of active lights
extern vec2 aspectRatio;               // e.g. {16, 9}
extern vec3 baseShadowColor;           // base dark color when no light is applied
extern float darkenFactor;             // controls how dark the darkest shade is (0.0 = pure base, 1.0 = no darkening)
extern float normalStrength;           // multiplier for normal map effect (0.0 = disabled)
extern float specularPower;            // specular highlight power/shininess
extern vec3 viewDirection;             // normalized view direction for specular calculation

uniform sampler2DArray MainTex;

// Signed distance function for an axis–aligned box.
float sdfBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
}

// Reconstruct normal from RG channels (assuming Z is calculated)
vec3 reconstructNormal(vec2 normalRG) {
    vec2 normal2D = normalRG * 2.0 - 1.0; // Convert from [0,1] to [-1,1]
    normal2D *= normalStrength;
    float normalZ = sqrt(max(0.0, 1.0 - dot(normal2D, normal2D)));
    return normalize(vec3(normal2D, normalZ));
}

void effect()
{
    vec4 color = VaryingColor;
    vec2 texture_coords = VaryingTexCoord.xy;
    vec2 screen_coords = love_PixelCoord.xy;
    
    // Sample all 3 layers
    vec4 layer0 = Texel(MainTex, vec3(texture_coords, 0.0));
    vec4 layer1 = Texel(MainTex, vec3(texture_coords, 1.0));
    vec4 layer2 = Texel(MainTex, vec3(texture_coords, 2.0));
    
    // Apply lighting effect to layer 0
    vec4 texColor = layer0;
    
    // Extract material properties from layer1 (was previously materialMap)
    vec4 materialSample = layer1;
    vec3 normal = (normalStrength > 0.0) ? reconstructNormal(materialSample.rg) : vec3(0.0, 0.0, 1.0);
    float emissive = materialSample.b;
    float specular = materialSample.a;
    
    // Determine the base minimum color.
    vec3 minColor = mix(baseShadowColor, texColor.rgb, darkenFactor);
    
    float totalIntensity = 0.0;
    vec3 weightedColor = vec3(0.0);
    vec3 totalSpecular = vec3(0.0);
    
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
        
        // Calculate normal mapping and specular only if enabled (normalStrength > 0)
        float normalContribution = baseContribution;
        float specularContribution = 0.0;
        
        if (normalStrength > 0.0) {
            // Calculate light direction (from fragment to light source)
            vec2 lightPos2D = center / aspectRatio; // Convert back to texture space
            vec2 lightOffset = lightPos2D - texture_coords;
            lightOffset.y = -lightOffset.y; // Flip Y to match lighting coordinate system
            vec3 lightDir = normalize(vec3(lightOffset, 0.1)); // Small Z offset for 2.5D effect
            
            // Check if this pixel has material data (alpha > 0 means it has material properties)
            float materialMask = step(0.001, materialSample.a + materialSample.b); // Has specular OR emissive data
            
            if (materialMask > 0.0) {
                // Use normal mapping for surfaces with material data
                float normalDot = max(0.0, dot(normal, lightDir));
                normalContribution = baseContribution * normalDot;
                
                // Specular calculation
                vec3 halfVector = normalize(lightDir + viewDirection);
                float specularDot = max(0.0, dot(normal, halfVector));
                specularContribution = baseContribution * pow(specularDot, specularPower) * specular;
            }
            // else: normalContribution remains as baseContribution (original lighting)
        }
        
        // Scale contribution by brightness.
        float brightness = lightChannels[i].a;
        float c = brightness * normalContribution;
        
        totalIntensity += c;
        weightedColor += c * lightChannels[i].rgb;
        totalSpecular += brightness * specularContribution * lightChannels[i].rgb;
    }
    
    // Clamp overall light intensity and compute composite tint.
    float intensity = clamp(totalIntensity, 0.0, 1.0);
    vec3 compositeTint = (totalIntensity > 0.0) ? (weightedColor / totalIntensity) : vec3(1.0);
    
    // Blend final color from dark base to tinted texture.
    vec3 finalColor = mix(minColor, texColor.rgb * compositeTint, intensity);
    
    // Add emissive contribution (self-illuminating areas)
    finalColor += texColor.rgb * emissive;
    
    // Add specular highlights
    finalColor += totalSpecular;
    
    // Output lighting effect to canvas 0, and pass through layers 1 and 2
    love_Canvases[0] = vec4(finalColor, texColor.a);
    love_Canvases[1] = layer1 * color;
    love_Canvases[2] = layer2 * color;
}
