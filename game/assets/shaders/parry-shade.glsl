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
extern float gradientRippleAmplitudes[MAX_GRADIENTS]; // ripple strength per gradient
extern float gradientRipplePivots[MAX_GRADIENTS]; // normalized 0-1 pivot point for wave origin
extern float gradientPivotIntensities[MAX_GRADIENTS]; // pivot intensity multiplier per gradient
extern float gradientTimeOffsets[MAX_GRADIENTS]; // time offset per gradient for wave phase
extern float gradientPivotPinchStrengths[MAX_GRADIENTS]; // strength of inward pinch at pivot per gradient
extern int gradientCount;                  // number of active gradients
extern float time;                         // time for animated ripple effect
extern vec2 cameraPos;                     // camera position for world-space ripples

// Internal settings
const float outlineThickness = 1.0;        // thickness of outline in pixels (1.0 = 1 pixel, 2.0 = 2 pixels, etc.)
const float gradientSteps = 3.0;          // number of discrete gradient steps (e.g., 3.0 = 3 bands, higher = more bands)
const float gradientPower = 0.2;           // gradient intensity curve (higher = stronger gradient, sharper falloff at end; 1.0 = linear)
const float edgeSmoothness = 0.0;          // smoothness of band transitions (0.0 = sharp, 1.0 = very smooth)
const float edgeRoundingRadius = 0.015;     // radius for rounding top/bottom edges in screen space (0.02 = 2% of screen width)
const float minimumRoundingHeight = 0.02;  // minimum rect height in screen space to apply edge rounding (0.04 = 4% of screen height)

// Ripple effect settings
// rippleAmplitude is now per-gradient (see gradientRippleAmplitudes array)
const float rippleFrequency = 150.0;        // number of ripple waves
const float rippleSpeed = 5.0;             // speed of ripple animation

// Pivot pinch settings
const float pivotPinchRange = 0.1;         // how far from pivot the pinch extends (0.0-0.5, normalized to gradient height)

void effect()
{
    vec2 texture_coords = VaryingTexCoord.xy;
    
    // Calculate ripple distortion based on gradient presence
    vec2 distortedCoords = texture_coords;
    float maxRippleIntensity = 0.0;
    float rippleDirection = 0.0;  // Track the direction of the strongest ripple
    float rippleAmplitude = 0.0;  // Track the amplitude of the strongest ripple
    float ripplePivot = 0.5;      // Track the pivot point of the strongest ripple
    float pivotIntensityMultiplier = 1.0; // Track the pivot intensity multiplier of the strongest ripple
    float timeOffset = 0.0;       // Track the time offset of the strongest ripple
    float pivotPinchStrength = 0.0; // Track the pivot pinch strength of the strongest ripple
    vec4 activeRect = vec4(0.0);  // Track the active gradient rect
    
    // Check all gradients to find the maximum ripple intensity for this pixel
    for (int i = 0; i < gradientCount; i++) {
        vec4 rect = gradientRects[i];
        vec2 topLeft = rect.xy;
        vec2 bottomRight = rect.zw;
        
        // Check if inside the rectangle bounds
        bool insideRect = (texture_coords.x >= topLeft.x && texture_coords.x <= bottomRight.x &&
                          texture_coords.y >= topLeft.y && texture_coords.y <= bottomRight.y);
        
        if (insideRect) {
            // Calculate position within rectangle
            float rectWidth = bottomRight.x - topLeft.x;
            float normalizedX = clamp((texture_coords.x - topLeft.x) / rectWidth, 0.0, 1.0);
            
            // Calculate ripple intensity (strongest where gradient is visible)
            float rippleIntensity;
            if (gradientDirections[i] < 0.5) {
                // Left gradient: ripple on left side
                rippleIntensity = 1.0 - normalizedX;
                // Store direction, amplitude, pivot for left gradients
                if (rippleIntensity > maxRippleIntensity) {
                    rippleDirection = -1.0;
                    rippleAmplitude = gradientRippleAmplitudes[i];
                    ripplePivot = gradientRipplePivots[i];
                    pivotIntensityMultiplier = gradientPivotIntensities[i];
                    timeOffset = gradientTimeOffsets[i];
                    pivotPinchStrength = gradientPivotPinchStrengths[i];
                    activeRect = rect;
                }
            } else {
                // Right gradient: ripple on right side
                rippleIntensity = normalizedX;
                // Store direction, amplitude, pivot for right gradients
                if (rippleIntensity > maxRippleIntensity) {
                    rippleDirection = 1.0;
                    rippleAmplitude = gradientRippleAmplitudes[i];
                    ripplePivot = gradientRipplePivots[i];
                    pivotIntensityMultiplier = gradientPivotIntensities[i];
                    timeOffset = gradientTimeOffsets[i];
                    pivotPinchStrength = gradientPivotPinchStrengths[i];
                    activeRect = rect;
                }
            }
            
            // Apply power curve to concentrate ripple where gradient is strongest
            rippleIntensity = pow(rippleIntensity, 1.0 / gradientPower);
            maxRippleIntensity = max(maxRippleIntensity, rippleIntensity);
        }
    }
    
    // Apply ripple distortion if intensity is sufficient
    if (maxRippleIntensity > 0.01) {
        // Calculate normalized Y position within the gradient rect (0 = top, 1 = bottom)
        vec2 topLeft = activeRect.xy;
        vec2 bottomRight = activeRect.zw;
        float rectHeight = bottomRight.y - topLeft.y;
        float normalizedY = clamp((texture_coords.y - topLeft.y) / rectHeight, 0.0, 1.0);
        
        // Calculate pivot position in world space
        float pivotWorldY = (topLeft.y + ripplePivot * rectHeight) * love_ScreenSize.y + cameraPos.y;
        
        // Convert screen space to world space for wave calculation
        vec2 worldPos = texture_coords * love_ScreenSize.xy + cameraPos;
        
        // Calculate SIGNED distance from pivot (negative above, positive below)
        float distanceFromPivot = worldPos.y - pivotWorldY;
        
        // Calculate wave with opposite propagation above/below pivot
        // Use abs() for spatial component to create the split at pivot
        // Since abs(distance) increases away from pivot in both directions,
        // using the same time offset makes waves move toward pivot on both sides
        // Above pivot: waves move downward (toward pivot)
        // Below pivot: waves move upward (toward pivot)
        float wave = sin(abs(distanceFromPivot) * rippleFrequency + (time + timeOffset) * rippleSpeed);
        
        // Add tapering at top and bottom edges
        // Calculate distance from nearest edge (0.0 at edges, 0.5 at center)
        float distFromEdge = 0.5 - abs(normalizedY - 0.5);
        // Apply smooth tapering (adjust multiplier to control taper strength)
        float taper = smoothstep(0.0, 0.15, distFromEdge);
        
        // Intensify effect near the pivot
        // Calculate normalized distance from pivot (0.0 at pivot, 0.5 at edges)
        float distFromPivotNorm = abs(normalizedY - ripplePivot);
        // Create intensity that's strongest at pivot and fades toward edges
        // Use narrower smoothstep range (0.0 to 0.3) for more concentrated effect
        float pivotIntensity = 1.0 - smoothstep(0.0, 0.3, distFromPivotNorm);
        // Apply per-gradient intensity multiplier (default would be 1.0 for no extra boost)
        pivotIntensity = pow(pivotIntensity, 0.3) * pivotIntensityMultiplier + (1.0 - pivotIntensity);
        
        // Apply distortion with direction, intensity, taper, and pivot boost
        // Pull pixels FROM inside to make edges jut OUT (subtract to sample from opposite direction)
        float distortion = wave * maxRippleIntensity * rippleAmplitude * taper * pivotIntensity;
        
        // Apply horizontal distortion in the gradient direction
        distortedCoords.x -= distortion * rippleDirection;
        
        // Apply pivot pinch effect - pulls pixels inward at the pivot
        if (pivotPinchStrength > 0.0) {
            // Calculate distance from pivot (0.0 at pivot, increases away from it)
            float distFromPivotNorm = abs(normalizedY - ripplePivot);
            
            // Create pinch intensity that's strongest at pivot and fades away
            // Use pivotPinchRange to control how far the effect extends
            float pinchIntensity = 1.0 - smoothstep(0.0, pivotPinchRange, distFromPivotNorm);
            pinchIntensity = pow(pinchIntensity, 0.4); // Sharpen the falloff
            
            // Apply pinch distortion - pull inward (opposite to gradient direction)
            // Multiply by maxRippleIntensity to respect the gradient's horizontal intensity
            float pinchDistortion = pinchIntensity * pivotPinchStrength * maxRippleIntensity;
            distortedCoords.x += pinchDistortion * rippleDirection; // opposite sign from wave distortion
        }
    }
    
    // Sample the 3 layers from the texture array (using distorted coordinates)
    vec4 layer0 = Texel(MainTex, vec3(distortedCoords, 0.0));
    vec4 layer1 = Texel(MainTex, vec3(distortedCoords, 1.0));
    vec4 layer2 = Texel(MainTex, vec3(distortedCoords, 2.0));
    
    // Also sample undistorted for black pixel detection
    vec4 layer0_undistorted = Texel(MainTex, vec3(texture_coords, 0.0));
    
    // Start with the base texture color
    vec4 finalColor = layer0;
    vec3 baseColor = layer0.rgb;  // Store original color to clamp darkness later
    
    // Check if current pixel is opaque
    bool isOpaque = (layer0.a > 0.5);
    bool isOutlinePixel = false;  // Track if this is an outline pixel
    bool isEdgePixel = false;  // Track if this pixel has transparent neighbors
    bool gradientApplied = false;  // Track if any gradient affected this pixel
    
    // Pre-calculate edge detection once (expensive operation, so do it outside the gradient loop)
    // Check edges in screen space to maintain consistent outline
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
            // Sample neighbors in screen space to get consistent edge detection
            vec2 neighborScreenCoords = texture_coords + offsets[i] * texelSize;
            
            // Calculate the same ripple distortion for the neighbor
            float neighborRippleIntensity = 0.0;
            float neighborRippleDirection = 0.0;
            float neighborRippleAmplitude = 0.0;
            float neighborRipplePivot = 0.5;
            float neighborPivotIntensityMultiplier = 1.0;
            float neighborTimeOffset = 0.0;
            float neighborPivotPinchStrength = 0.0;
            vec4 neighborActiveRect = vec4(0.0);
            
            // Check gradients for neighbor position
            for (int j = 0; j < gradientCount; j++) {
                vec4 rect = gradientRects[j];
                vec2 topLeft = rect.xy;
                vec2 bottomRight = rect.zw;
                
                bool insideRect = (neighborScreenCoords.x >= topLeft.x && neighborScreenCoords.x <= bottomRight.x &&
                                  neighborScreenCoords.y >= topLeft.y && neighborScreenCoords.y <= bottomRight.y);
                
                if (insideRect) {
                    float rectWidth = bottomRight.x - topLeft.x;
                    float normalizedX = clamp((neighborScreenCoords.x - topLeft.x) / rectWidth, 0.0, 1.0);
                    
                    float intensity;
                    if (gradientDirections[j] < 0.5) {
                        intensity = 1.0 - normalizedX;
                        if (intensity > neighborRippleIntensity) {
                            neighborRippleDirection = -1.0;
                            neighborRippleAmplitude = gradientRippleAmplitudes[j];
                            neighborRipplePivot = gradientRipplePivots[j];
                            neighborPivotIntensityMultiplier = gradientPivotIntensities[j];
                            neighborTimeOffset = gradientTimeOffsets[j];
                            neighborPivotPinchStrength = gradientPivotPinchStrengths[j];
                            neighborActiveRect = rect;
                        }
                    } else {
                        intensity = normalizedX;
                        if (intensity > neighborRippleIntensity) {
                            neighborRippleDirection = 1.0;
                            neighborRippleAmplitude = gradientRippleAmplitudes[j];
                            neighborRipplePivot = gradientRipplePivots[j];
                            neighborPivotIntensityMultiplier = gradientPivotIntensities[j];
                            neighborTimeOffset = gradientTimeOffsets[j];
                            neighborPivotPinchStrength = gradientPivotPinchStrengths[j];
                            neighborActiveRect = rect;
                        }
                    }
                    
                    intensity = pow(intensity, 1.0 / gradientPower);
                    neighborRippleIntensity = max(neighborRippleIntensity, intensity);
                }
            }
            
            // Apply neighbor's ripple distortion
            vec2 neighborDistortedCoords = neighborScreenCoords;
            if (neighborRippleIntensity > 0.01) {
                // Calculate normalized Y position within neighbor's gradient rect
                vec2 neighborTopLeft = neighborActiveRect.xy;
                vec2 neighborBottomRight = neighborActiveRect.zw;
                float neighborRectHeight = neighborBottomRight.y - neighborTopLeft.y;
                float neighborNormalizedY = clamp((neighborScreenCoords.y - neighborTopLeft.y) / neighborRectHeight, 0.0, 1.0);
                
                // Calculate pivot position in world space
                float neighborPivotWorldY = (neighborTopLeft.y + neighborRipplePivot * neighborRectHeight) * love_ScreenSize.y + cameraPos.y;
                
                // Convert neighbor screen space to world space
                vec2 neighborWorldPos = neighborScreenCoords * love_ScreenSize.xy + cameraPos;
                
                // Calculate SIGNED distance from pivot
                float neighborDistanceFromPivot = neighborWorldPos.y - neighborPivotWorldY;
                
                // Calculate wave with opposite propagation above/below pivot
                float wave = sin(abs(neighborDistanceFromPivot) * rippleFrequency + (time + neighborTimeOffset) * rippleSpeed);
                
                // Add tapering at top and bottom edges for neighbor
                float neighborDistFromEdge = 0.5 - abs(neighborNormalizedY - 0.5);
                float neighborTaper = smoothstep(0.0, 0.15, neighborDistFromEdge);
                
                // Intensify effect near the pivot for neighbor
                float neighborDistFromPivotNorm = abs(neighborNormalizedY - neighborRipplePivot);
                float neighborPivotIntensity = 1.0 - smoothstep(0.0, 0.3, neighborDistFromPivotNorm);
                neighborPivotIntensity = pow(neighborPivotIntensity, 0.3) * neighborPivotIntensityMultiplier + (1.0 - neighborPivotIntensity);
                
                float distortion = wave * neighborRippleIntensity * neighborRippleAmplitude * neighborTaper * neighborPivotIntensity;
                neighborDistortedCoords.x -= distortion * neighborRippleDirection;
                
                // Apply pivot pinch effect for neighbor
                if (neighborPivotPinchStrength > 0.0) {
                    float neighborDistFromPivotNorm = abs(neighborNormalizedY - neighborRipplePivot);
                    float neighborPinchIntensity = 1.0 - smoothstep(0.0, pivotPinchRange, neighborDistFromPivotNorm);
                    neighborPinchIntensity = pow(neighborPinchIntensity, 0.4);
                    float neighborPinchDistortion = neighborPinchIntensity * neighborPivotPinchStrength * neighborRippleIntensity;
                    neighborDistortedCoords.x += neighborPinchDistortion * neighborRippleDirection;
                }
            }
            
            // Sample with distorted coordinates
            vec4 neighborColor = Texel(MainTex, vec3(neighborDistortedCoords, 0.0));
            
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
        
        // Check if pixel is originally fully black (use undistorted sample)
        bool isBlackPixel = (layer0_undistorted.r < 0.01 && layer0_undistorted.g < 0.01 && layer0_undistorted.b < 0.01);
        
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