#pragma language glsl3
#define MAX_GRADIENTS 25

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2DArray MainTex;

extern vec4 gradientRects[MAX_GRADIENTS];  // (topleft_x, topleft_y, bottomright_x, bottomright_y)
extern vec4 gradientColor;                 // rgba color for the gradient
extern float gradientDirections[MAX_GRADIENTS]; // 0.0 = left, 1.0 = right
extern vec2 gradientLips[MAX_GRADIENTS];   // (top_lip, bottom_lip) - 1.0 = rounded corner, 0.0 = hard corner
extern int gradientCount;                  // number of active gradients

// Internal settings
const float outlineThickness = 1.0;        // thickness of outline in pixels (1.0 = 1 pixel, 2.0 = 2 pixels, etc.)
const float gradientSteps = 2.0;          // number of discrete gradient steps (e.g., 3.0 = 3 bands, higher = more bands)
const float gradientPower = 0.2;           // gradient intensity curve (higher = stronger gradient, sharper falloff at end; 1.0 = linear)
const float edgeSmoothness = 0.0;          // smoothness of band transitions (0.0 = sharp, 1.0 = very smooth)
const float edgeRoundingRadius = 0.015;     // radius for rounding top/bottom edges in screen space (0.02 = 2% of screen width)
const float minimumRoundingHeight = 0.02;  // minimum rect height in screen space to apply edge rounding (0.04 = 4% of screen height)

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
    bool gradientApplied = false;  // Track if any gradient affected this pixel
    
    // Pre-calculate edge detection once (expensive operation, so do it outside the gradient loop)
    if (isOpaque) {
        // Get texture dimensions for pixel offset calculation
        vec2 texelSize = 1.0 / love_ScreenSize.xy;
        
        // Directly sample cardinal and diagonal neighbors (much faster than looping over a square)
        // For outlineThickness <= 1.5, check 4 cardinal directions
        // For outlineThickness > 1.5, also check 4 diagonal directions
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
        int numChecks = outlineThickness > 1.5 ? 8 : 4;
        
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
        
        // Check if inside the rectangle bounds
        bool insideRect = (texture_coords.x >= topLeft.x && texture_coords.x <= bottomRight.x &&
                          texture_coords.y >= topLeft.y && texture_coords.y <= bottomRight.y);
        
        // Skip if outside the rectangle
        if (!insideRect) continue;
        
        // Skip this gradient if the pixel is already a white outline from a previous gradient
        if (isOutlinePixel) continue;
        
        // Mark that a gradient is affecting this pixel
        gradientApplied = true;
        
        // Check if pixel is originally fully black
        bool isBlackPixel = (baseColor.r < 0.01 && baseColor.g < 0.01 && baseColor.b < 0.01);
        
        // Draw solid white outline on edge pixels or originally black pixels
        if (isEdgePixel || isBlackPixel) {
            finalColor.rgb = vec3(1.0, 1.0, 1.0);
            isOutlinePixel = true;
        }
        
        // Apply gradient to all pixels (including white outline pixels from this gradient)
        // Calculate horizontal position within rectangle (0.0 = left, 1.0 = right)
        float rectWidth = bottomRight.x - topLeft.x;
        float rectHeight = bottomRight.y - topLeft.y;
        float normalizedX = clamp((texture_coords.x - topLeft.x) / rectWidth, 0.0, 1.0);
        float normalizedY = clamp((texture_coords.y - topLeft.y) / rectHeight, 0.0, 1.0);
        
        // Calculate blend factor based on direction
        float blendFactor;
        if (gradientDirections[i] < 0.5) {
            // Left gradient: left side is gradient color, right side is original
            blendFactor = normalizedX;
        } else {
            // Right gradient: right side is gradient color, left side is original
            blendFactor = 1.0 - normalizedX;
        }
        
        // Apply edge rounding only to the soft side of the gradient (controlled by lips)
        // Calculate corner rounding: reduce gradient intensity at corners on soft side only
        float cornerFactor = 1.0;
        if (edgeRoundingRadius > 0.0 && rectHeight >= minimumRoundingHeight) {
            // Get lip flags for this gradient
            vec2 lips = gradientLips[i];
            bool topLipEnabled = lips.x > 0.5;
            bool bottomLipEnabled = lips.y > 0.5;
            
            // Convert screen-space radius to normalized rect coordinates
            float radiusX = edgeRoundingRadius / rectWidth;
            float radiusY = edgeRoundingRadius / rectHeight;
            
            bool isLeftGradient = gradientDirections[i] < 0.5;
            
            // For left gradient: soft side is on the right (only round right corners)
            // For right gradient: soft side is on the left (only round left corners)
            bool shouldRoundLeft = !isLeftGradient;
            bool shouldRoundRight = isLeftGradient;
            
            // Check top corners (only if top lip is enabled)
            if (topLipEnabled && normalizedY < radiusY) {
                float distFromTop = normalizedY;
                // Check left side (only if it's the soft side)
                if (shouldRoundLeft && normalizedX < radiusX) {
                    float distFromLeft = normalizedX;
                    float cornerDist = length(vec2((radiusX - distFromLeft) * rectWidth, (radiusY - distFromTop) * rectHeight)) / edgeRoundingRadius;
                    if (cornerDist > 1.0) {
                        cornerFactor = 0.0;
                    } else {
                        cornerFactor = smoothstep(1.0, 0.7, cornerDist);
                    }
                }
                // Check right side (only if it's the soft side)
                else if (shouldRoundRight && normalizedX > (1.0 - radiusX)) {
                    float distFromRight = 1.0 - normalizedX;
                    float cornerDist = length(vec2((radiusX - distFromRight) * rectWidth, (radiusY - distFromTop) * rectHeight)) / edgeRoundingRadius;
                    if (cornerDist > 1.0) {
                        cornerFactor = 0.0;
                    } else {
                        cornerFactor = smoothstep(1.0, 0.7, cornerDist);
                    }
                }
            }
            // Check bottom corners (only if bottom lip is enabled)
            else if (bottomLipEnabled && normalizedY > (1.0 - radiusY)) {
                float distFromBottom = 1.0 - normalizedY;
                // Check left side (only if it's the soft side)
                if (shouldRoundLeft && normalizedX < radiusX) {
                    float distFromLeft = normalizedX;
                    float cornerDist = length(vec2((radiusX - distFromLeft) * rectWidth, (radiusY - distFromBottom) * rectHeight)) / edgeRoundingRadius;
                    if (cornerDist > 1.0) {
                        cornerFactor = 0.0;
                    } else {
                        cornerFactor = smoothstep(1.0, 0.7, cornerDist);
                    }
                }
                // Check right side (only if it's the soft side)
                else if (shouldRoundRight && normalizedX > (1.0 - radiusX)) {
                    float distFromRight = 1.0 - normalizedX;
                    float cornerDist = length(vec2((radiusX - distFromRight) * rectWidth, (radiusY - distFromBottom) * rectHeight)) / edgeRoundingRadius;
                    if (cornerDist > 1.0) {
                        cornerFactor = 0.0;
                    } else {
                        cornerFactor = smoothstep(1.0, 0.7, cornerDist);
                    }
                }
            }
        }
        
        // Apply corner rounding by pushing blend toward 1.0 (original color) at corners
        blendFactor = mix(1.0, blendFactor, cornerFactor);
        
        // Skip this gradient if pixel is outside the rounded corner
        if (cornerFactor < 0.01) {
            gradientApplied = false;
            continue;
        }
        
        // Apply power curve to strengthen gradient (stays strong, drops sharply at end)
        if (gradientPower != 1.0) {
            blendFactor = pow(blendFactor, 1.0 / gradientPower);
        }
        
        // Quantize blend factor into discrete steps with smooth edges
        // Higher values = more bands/finer gradient, lower values = fewer bands/coarser
        if (gradientSteps > 1.0) {
            float scaled = blendFactor * gradientSteps;
            float stepFloor = floor(scaled);
            float stepFrac = fract(scaled);
            
            // Smoothstep the transition between bands
            float smoothedFrac = smoothstep(0.5 - edgeSmoothness * 0.5, 0.5 + edgeSmoothness * 0.5, stepFrac);
            blendFactor = (stepFloor + smoothedFrac) / (gradientSteps - 1.0);
        }
        
        // Apply different blending for outline pixels vs normal pixels
        vec3 originalColor = finalColor.rgb;
        
        if (isOutlinePixel) {
            // This is a white outline pixel - blend from white to black
            // Invert the blend factor so white appears on the gradient color side
            vec3 blackColor = vec3(0.0, 0.0, 0.0);
            finalColor.rgb = mix(blackColor, finalColor.rgb, 1.0 - blendFactor);
        } else {
            // Normal gradient application for non-outline pixels
            // First blend based on the blendFactor (gradient direction)
            vec3 directionalBlend = mix(gradientColor.rgb, finalColor.rgb, blendFactor);
            // Then blend with original based on gradient alpha (transparency)
            finalColor.rgb = mix(finalColor.rgb, directionalBlend, gradientColor.a);
        }
        
        // Clamp to not be brighter than original (prevent brightening from falloff)
        float originalBrightness = dot(originalColor, vec3(0.299, 0.587, 0.114));
        float resultBrightness = dot(finalColor.rgb, vec3(0.299, 0.587, 0.114));
        if (resultBrightness > originalBrightness) {
            finalColor.rgb = originalColor * (resultBrightness / max(originalBrightness, 0.001));
            finalColor.rgb = min(finalColor.rgb, originalColor);
        }
    }
    
    // Ensure overlapping gradients don't exceed the darkness specified by gradient alpha
    // Only apply this clamping if a gradient was actually applied to this pixel
    if (gradientApplied) {
        // Calculate the darkest allowed color based on gradient alpha
        vec3 maxDarkness = mix(baseColor, gradientColor.rgb, gradientColor.a);
        
        // For each color channel, don't go darker than maxDarkness
        // (darker = lower value, so use max to prevent going below the threshold)
        finalColor.rgb = max(finalColor.rgb, maxDarkness);
    }
    
    // Output each layer to its corresponding canvas
    love_Canvases[0] = finalColor * VaryingColor;
    love_Canvases[1] = layer1 * layer0.a; // * VaryingColor.a;
    love_Canvases[2] = layer2 * layer0.a; // * VaryingColor.a;
}