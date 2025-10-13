#pragma language glsl3
#define MAX_GRADIENTS 25

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2DArray MainTex;

extern vec4 gradientRects[MAX_GRADIENTS];  // (topleft_x, topleft_y, bottomright_x, bottomright_y)
extern vec4 gradientColor;                 // rgba color for the gradient
extern float gradientDirections[MAX_GRADIENTS]; // 0.0 = left, 1.0 = right
extern int gradientCount;                  // number of active gradients
extern float time;                         // time in seconds for animating the dash pattern
extern vec2 dashOffset;                    // manual offset for dash pattern position (in pixels)

// Internal settings
const float dashLength = 8.0;              // length of each dash in pixels
const float gapLength = 0;               // length of gap between dashes in pixels
const float dashSpeed = 20.0;              // speed of dash animation in pixels per second
const float dashThickness = 2.0;           // thickness of dashed outline in pixels (1.0 = 1 pixel, 2.0 = 2 pixels, etc.)
const float gradientSteps = 3.0;          // number of discrete gradient steps (e.g., 3.0 = 3 bands, higher = more bands)
const float gradientFalloff = 0.05;        // falloff distance outside rectangle bounds (in texture space, 0.05 = 5% of screen)
const float gradientPower = 0.05;           // gradient intensity curve (higher = stronger gradient, sharper falloff at end; 1.0 = linear)

void effect()
{
    vec2 texture_coords = VaryingTexCoord.xy;
    
    // Sample the 3 layers from the texture array
    vec4 layer0 = Texel(MainTex, vec3(texture_coords, 0.0));
    vec4 layer1 = Texel(MainTex, vec3(texture_coords, 1.0));
    vec4 layer2 = Texel(MainTex, vec3(texture_coords, 2.0));
    
    // Start with the base texture color
    vec4 finalColor = layer0;
    vec3 baseColor = layer0.rgb;  // Store original color to clamp darkness later
    
    // Check if current pixel is opaque
    bool isOpaque = (layer0.a > 0.5);
    bool isOutlinePixel = false;  // Track if this is an outline pixel
    bool isEdgePixel = false;  // Track if this pixel has transparent neighbors
    
    // Pre-calculate edge detection once (expensive operation, so do it outside the gradient loop)
    if (isOpaque) {
        // Get texture dimensions for pixel offset calculation
        vec2 texelSize = 1.0 / love_ScreenSize.xy;
        
        // Directly sample cardinal and diagonal neighbors (much faster than looping over a square)
        // For dashThickness <= 1.5, check 4 cardinal directions
        // For dashThickness > 1.5, also check 4 diagonal directions
        vec2 offsets[8];
        offsets[0] = vec2( 0.0,  1.0);  // N
        offsets[1] = vec2( 1.0,  0.0);  // E
        offsets[2] = vec2( 0.0, -1.0);  // S
        offsets[3] = vec2(-1.0,  0.0);  // W
        offsets[4] = vec2( 1.0,  1.0);  // NE
        offsets[5] = vec2( 1.0, -1.0);  // SE
        offsets[6] = vec2(-1.0, -1.0);  // SW
        offsets[7] = vec2(-1.0,  1.0);  // NW
        
        // Check how many neighbors to sample based on thickness
        int numChecks = dashThickness > 1.5 ? 8 : 4;
        
        for (int i = 0; i < numChecks; i++) {
            vec2 neighborCoords = texture_coords + offsets[i] * texelSize;
            vec4 neighborColor = Texel(MainTex, vec3(neighborCoords, 0.0));
            
            // Check if neighbor is transparent
            if (neighborColor.a < 0.5) {
                isEdgePixel = true;
                break;
            }
        }
    }
    
    // Apply gradients
    for (int i = 0; i < gradientCount; i++) {
        vec4 rect = gradientRects[i];
        vec2 topLeft = rect.xy;
        vec2 bottomRight = rect.zw;
        
        // Calculate distance from rectangle edges with circular falloff
        // For pixels outside the rectangle, calculate distance to nearest edge/corner
        float distX = max(topLeft.x - texture_coords.x, texture_coords.x - bottomRight.x);
        float distY = max(topLeft.y - texture_coords.y, texture_coords.y - bottomRight.y);
        
        // Use circular distance for corners (creates rounded falloff)
        vec2 outsideDist = vec2(max(distX, 0.0), max(distY, 0.0));
        float distFromRect = length(outsideDist);
        
        // Calculate falloff multiplier (1.0 inside, smoothly fades to 0.0 outside)
        float falloffMultiplier = 1.0 - smoothstep(0.0, gradientFalloff, distFromRect);
        
        // Apply power curve to strengthen falloff (stays strong, drops sharply at end)
        if (gradientPower != 1.0 && falloffMultiplier < 1.0) {
            falloffMultiplier = pow(falloffMultiplier, 1.0 / gradientPower);
        }
        
        // Quantize falloff to match gradient steps
        if (gradientSteps > 1.0 && falloffMultiplier < 1.0) {
            falloffMultiplier = floor(falloffMultiplier * gradientSteps) / (gradientSteps - 1.0);
        }
        
        // Skip if completely outside falloff range
        if (falloffMultiplier <= 0.0) continue;
        
        bool insideRect = (texture_coords.x >= topLeft.x && texture_coords.x <= bottomRight.x &&
                          texture_coords.y >= topLeft.y && texture_coords.y <= bottomRight.y);
        
        // Check for outline on edge pixels (only inside rectangle)
        if (isEdgePixel && insideRect) {
            // Calculate position along the perimeter for dashing pattern
            // Use screen coordinates for consistent dash sizing
            vec2 screenPos = texture_coords * love_ScreenSize.xy;
            
            // Create dash pattern based on diagonal distance (creates a flowing pattern)
            // Add time-based offset and manual offset for animation/control
            float timeOffset = time * dashSpeed;
            float manualOffset = dashOffset.x + dashOffset.y;
            float dashPattern = screenPos.x + screenPos.y - timeOffset - manualOffset;
            float dashCycle = dashLength + gapLength;
            float posInCycle = mod(dashPattern, dashCycle);
            
            // If we're in the dash portion of the cycle, make it white
            if (posInCycle < dashLength) {
                finalColor.rgb = vec3(1.0, 1.0, 1.0);
                isOutlinePixel = true;
            }
        }
        
        // Apply gradient to all pixels (including white outline pixels)
        // Calculate horizontal position within rectangle (0.0 = left, 1.0 = right)
        float rectWidth = bottomRight.x - topLeft.x;
        float normalizedX = clamp((texture_coords.x - topLeft.x) / rectWidth, 0.0, 1.0);
        
        // Calculate blend factor based on direction
        float blendFactor;
        if (gradientDirections[i] < 0.5) {
            // Left gradient: left side is gradient color, right side is original
            blendFactor = normalizedX;
        } else {
            // Right gradient: right side is gradient color, left side is original
            blendFactor = 1.0 - normalizedX;
        }
        
        // Apply power curve to strengthen gradient (stays strong, drops sharply at end)
        if (gradientPower != 1.0) {
            blendFactor = pow(blendFactor, 1.0 / gradientPower);
        }
        
        // Quantize blend factor into discrete steps based on gradientSteps
        // Higher values = more bands/finer gradient, lower values = fewer bands/coarser
        if (gradientSteps > 1.0) {
            blendFactor = floor(blendFactor * gradientSteps) / (gradientSteps - 1.0);
        }
        
        // Apply different blending for outline pixels vs normal pixels
        vec3 gradientResult;
        vec3 originalColor = finalColor.rgb;
        
        if (isOutlinePixel) {
            // This is a white outline pixel - blend from white to black
            // Invert the blend factor so white appears on the gradient color side
            vec3 blackColor = vec3(0.0, 0.0, 0.0);
            gradientResult = mix(blackColor, finalColor.rgb, 1.0 - blendFactor);
        } else {
            // Normal gradient application for non-outline pixels
            // First blend based on the blendFactor (gradient direction)
            vec3 directionalBlend = mix(gradientColor.rgb, finalColor.rgb, blendFactor);
            // Then blend with original based on gradient alpha (transparency)
            gradientResult = mix(finalColor.rgb, directionalBlend, gradientColor.a);
        }
        
        // Apply falloff to blend between original and gradient result
        finalColor.rgb = mix(finalColor.rgb, gradientResult, falloffMultiplier);
        
        // Clamp to not be brighter than original (prevent brightening from falloff)
        float originalBrightness = dot(originalColor, vec3(0.299, 0.587, 0.114));
        float resultBrightness = dot(finalColor.rgb, vec3(0.299, 0.587, 0.114));
        if (resultBrightness > originalBrightness) {
            finalColor.rgb = originalColor * (resultBrightness / max(originalBrightness, 0.001));
            finalColor.rgb = min(finalColor.rgb, originalColor);
        }
    }
    
    // Ensure overlapping gradients don't exceed the darkness specified by gradient alpha
    // Calculate the darkest allowed color based on gradient alpha
    vec3 maxDarkness = mix(baseColor, gradientColor.rgb, gradientColor.a);
    
    // For each color channel, don't go darker than maxDarkness
    // (darker = lower value, so use max to prevent going below the threshold)
    finalColor.rgb = max(finalColor.rgb, maxDarkness);
    
    // Output each layer to its corresponding canvas
    love_Canvases[0] = finalColor * VaryingColor;
    love_Canvases[1] = layer1 * layer0.a; // * VaryingColor.a;
    love_Canvases[2] = layer2 * layer0.a; // * VaryingColor.a;
}