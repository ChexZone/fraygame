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
extern float lightingBands;            // number of discrete lighting bands for cel-shading (e.g., 3.0 for 3 bands)
extern float ambientWrap;              // ambient wrap lighting (0.0 = no wrap, 1.0 = full ambient, 0.5 = half-lambert)

uniform sampler2DArray MainTex;

// Signed distance function for an axis–aligned box.
float sdfBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
}

// Reconstruct normal from RG channels with optional rotation
vec3 reconstructNormal(vec2 normalRG, float rotation) {
    vec2 normal2D = normalRG * 2.0 - 1.0; // Convert from [0,1] to [-1,1]
    
    // Apply rotation for spinning objects (2D game viewed dead-on)
    float cosR = cos(rotation);
    float sinR = sin(rotation);
    normal2D = vec2(
        normal2D.x * cosR - normal2D.y * sinR,
        normal2D.x * sinR + normal2D.y * cosR
    );
    
    float normalZ = sqrt(max(0.0, 1.0 - dot(normal2D, normal2D)));
    vec3 normal = normalize(vec3(normal2D, normalZ));
    
    // Blend between flat normal and texture normal based on strength
    return normalize(mix(vec3(0.0, 0.0, 1.0), normal, normalStrength));
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
    
    // Extract material properties from layer1 and layer2
    vec4 materialSample1 = layer1; // RG = normal, B = specular, A = 1.0
    vec4 materialSample2 = layer2; // R = emission/occlusion, G = height, B = unused, A = 1.0
    
    // Extract properties from new layout
    float specular = (materialSample2.b > 0.0) ? materialSample2.b : 0.0; // Specular from layer2.b
    float shadowEmission = materialSample2.r; // Emission/occlusion from layer2.r
    float height = (materialSample2.g > 0.0) ? materialSample2.g : 0.0; // Height from layer2.g
    
    // Check if normal mapping data exists (both RG channels must be > 0)
    bool hasNormalData = (materialSample1.r > 0.0 || materialSample1.g > 0.0);
    
    // Reconstruct normal (no rotation, height can be used elsewhere if needed)
    vec3 normal = (normalStrength > 0.0 && hasNormalData) ? reconstructNormal(materialSample1.rg, 0.0) : vec3(0.0, 0.0, 1.0);
    
    // Determine emission strength (values > 0.5 are emissive)
    float emissionStrength = (shadowEmission > 0.5) ? (shadowEmission - 0.5) * 2.0 : 0.0; // Map 0.5-1.0 to 0.0-1.0
    bool isEmissive = emissionStrength > 0.0;
    
    // Determine the base minimum color.
    vec3 minColor = mix(baseShadowColor, texColor.rgb, darkenFactor);
    
    float totalIntensity = 0.0;
    vec3 weightedColor = vec3(0.0);
    vec3 totalSpecular = vec3(0.0);
    
    // Adjust coordinates for aspect ratio.
    vec2 aspectCorrectedCoords = texture_coords * aspectRatio;
    
    for (int i = 0; i < lightCount; i++) {
        // Skip lighting calculations for emissive pixels
        if (isEmissive) {
            continue;
        }
        
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
        
        if (normalStrength > 0.0 && hasNormalData) {
            // Calculate light direction (from fragment to light source)
            vec2 lightPos2D = center / aspectRatio; // Convert back to texture space
            vec2 lightOffset = lightPos2D - texture_coords;
            lightOffset.y = -lightOffset.y; // Flip Y to match lighting coordinate system
            vec3 lightDir = normalize(vec3(lightOffset, 0.1)); // Small Z offset for 2.5D effect
            
            // Apply normal mapping to lighting calculation with hard edges
            float normalDot = max(0.0, dot(normal, lightDir));
            
            // Apply ambient wrap lighting to make surfaces brighter
            // This remaps the dot product so glancing angles receive more light
            float wrappedDot = (normalDot + ambientWrap) / (1.0 + ambientWrap);
            wrappedDot = clamp(wrappedDot, 0.0, 1.0);
            
            // Create discrete lighting bands (cel-shading)
            // Quantize the normal dot product into discrete bands based on lightingBands parameter
            float sharpenedDot;
            if (lightingBands > 1.0) {
                // Multiple bands: quantize into discrete steps
                sharpenedDot = floor(wrappedDot * lightingBands) / lightingBands;
            } else {
                // Single band or less: just use normalized value
                sharpenedDot = wrappedDot;
            }
            
            normalContribution = baseContribution * sharpenedDot;
            
            // Specular calculation (only if specular data exists)
            if (specular > 0.001) {
                vec3 halfVector = normalize(lightDir + viewDirection);
                float specularDot = max(0.0, dot(normal, halfVector));
                specularContribution = baseContribution * pow(specularDot, specularPower) * specular;
            }
        }
        
        // Calculate shadow/emission effect
        float shadowMask = 1.0; // Default: normal lighting
        if (shadowEmission > 0.0) {
            if (shadowEmission < 0.5) {
                // Shadow mode (0-0.5): block lights, will use ambient
                shadowMask = 0.0;
            } else if (shadowEmission > 0.5) {
                // Emission mode (0.5-1): normal lighting + emission
                shadowMask = 1.0;
            } else {
                // Exactly 0.5: neutral, normal lighting
                shadowMask = 1.0;
            }
        }
        
        // Apply shadow effect - reduce contribution for shadow areas
        normalContribution *= shadowMask;
        specularContribution *= shadowMask;
        
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
    
    vec3 finalColor;
    
    if (isEmissive) {
        // Emissive pixels ignore lighting and emit their own light
        // Blend between lit color (for low emission) and full bright original color (for high emission)
        vec3 litColor = mix(minColor, texColor.rgb * compositeTint, intensity);
        finalColor = mix(litColor, texColor.rgb, emissionStrength);
    } else {
        // Check if this pixel is in shadow mode and needs ambient fallback
        float isShadowMode = (shadowEmission > 0.0) ? step(0.0, 0.5 - shadowEmission) : 0.0; // 1.0 if shadow mode
        
        // For shadow areas, provide minimum ambient lighting
        float ambientIntensity = mix(intensity, 0.3, isShadowMode); // 30% ambient for shadow areas
        vec3 ambientTint = mix(compositeTint, vec3(1.0), isShadowMode); // Neutral tint for ambient
        
        // Blend final color from dark base to tinted texture.
        finalColor = mix(minColor, texColor.rgb * ambientTint, ambientIntensity);
    }
    

    // Add specular highlights (not added to emissive surfaces)
    if (!isEmissive) {
        finalColor += totalSpecular;
    }
    // finalColor = vec3(layer1.rgb);
    
    // Output lighting effect to canvas 0, and pass through layers 1 and 2
    love_Canvases[0] = vec4(finalColor, texColor.a);
    love_Canvases[1] = layer1;
    love_Canvases[2] = layer2;
}
