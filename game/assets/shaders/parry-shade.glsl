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

// Ripple effect settings
// rippleAmplitude is now per-gradient (see gradientRippleAmplitudes array)
const float rippleFrequency = 150.0;        // number of ripple waves
const float rippleSpeed = 5.0;             // speed of ripple animation
const float rippleFrequencyFalloff = 0.00005; // how much frequency increases with distance (0.0 = constant frequency, higher = tighter waves farther out)

// Pivot pinch settings
const float pivotPinchRange = 0.1;         // how far from pivot the pinch extends (0.0-0.5, normalized to gradient height)

// Struct to cache gradient data for a pixel
struct GradientData {
    float rippleIntensity;
    float rippleDirection;
    float rippleAmplitude;
    float ripplePivot;
    float pivotIntensityMultiplier;
    float timeOffset;
    float pivotPinchStrength;
    vec4 activeRect;
};

// Calculate gradient data for a pixel position
GradientData calculateGradientData(vec2 coords) {
    GradientData data;
    data.rippleIntensity = 0.0;
    data.rippleDirection = 0.0;
    data.rippleAmplitude = 0.0;
    data.ripplePivot = 0.5;
    data.pivotIntensityMultiplier = 1.0;
    data.timeOffset = 0.0;
    data.pivotPinchStrength = 0.0;
    data.activeRect = vec4(0.0);
    
    for (int i = 0; i < gradientCount; i++) {
        vec4 rect = gradientRects[i];
        vec2 topLeft = rect.xy;
        vec2 bottomRight = rect.zw;
        
        // Check if inside the rectangle bounds
        if (coords.x >= topLeft.x && coords.x <= bottomRight.x &&
            coords.y >= topLeft.y && coords.y <= bottomRight.y) {
            
            float rectWidth = bottomRight.x - topLeft.x;
            float normalizedX = clamp((coords.x - topLeft.x) / rectWidth, 0.0, 1.0);
            
            float intensity;
            if (gradientDirections[i] < 0.5) {
                intensity = 1.0 - normalizedX;
                if (intensity > data.rippleIntensity) {
                    data.rippleDirection = -1.0;
                    data.rippleAmplitude = gradientRippleAmplitudes[i];
                    data.ripplePivot = gradientRipplePivots[i];
                    data.pivotIntensityMultiplier = gradientPivotIntensities[i];
                    data.timeOffset = gradientTimeOffsets[i];
                    data.pivotPinchStrength = gradientPivotPinchStrengths[i];
                    data.activeRect = rect;
                }
            } else {
                intensity = normalizedX;
                if (intensity > data.rippleIntensity) {
                    data.rippleDirection = 1.0;
                    data.rippleAmplitude = gradientRippleAmplitudes[i];
                    data.ripplePivot = gradientRipplePivots[i];
                    data.pivotIntensityMultiplier = gradientPivotIntensities[i];
                    data.timeOffset = gradientTimeOffsets[i];
                    data.pivotPinchStrength = gradientPivotPinchStrengths[i];
                    data.activeRect = rect;
                }
            }
            
            intensity = pow(intensity, 1.0 / gradientPower);
            data.rippleIntensity = max(data.rippleIntensity, intensity);
        }
    }
    
    return data;
}

// Apply ripple distortion to coordinates based on gradient data
vec2 applyRippleDistortion(vec2 coords, GradientData data) {
    if (data.rippleIntensity <= 0.01) {
        return coords;
    }
    
    vec2 topLeft = data.activeRect.xy;
    vec2 bottomRight = data.activeRect.zw;
    float rectHeight = bottomRight.y - topLeft.y;
    float normalizedY = clamp((coords.y - topLeft.y) / rectHeight, 0.0, 1.0);
    
    float pivotWorldY = (topLeft.y + data.ripplePivot * rectHeight) * love_ScreenSize.y + cameraPos.y;
    vec2 worldPos = coords * love_ScreenSize.xy + cameraPos;
    float distanceFromPivot = worldPos.y - pivotWorldY;
    
    float absDistance = abs(distanceFromPivot);
    float effectiveFrequency = rippleFrequency * (1.0 + absDistance * rippleFrequencyFalloff);
    float wave = sin(absDistance * effectiveFrequency + (time + data.timeOffset) * rippleSpeed);
    
    float distFromEdge = 0.5 - abs(normalizedY - 0.5);
    float taper = smoothstep(0.0, 0.15, distFromEdge);
    
    float distFromPivotNorm = abs(normalizedY - data.ripplePivot);
    float pivotIntensity = 1.0 - smoothstep(0.0, 0.3, distFromPivotNorm);
    pivotIntensity = pow(pivotIntensity, 0.3) * data.pivotIntensityMultiplier + (1.0 - pivotIntensity);
    
    float distortion = wave * data.rippleIntensity * data.rippleAmplitude * taper * pivotIntensity;
    vec2 distortedCoords = coords;
    distortedCoords.x -= distortion * data.rippleDirection;
    
    // Apply pivot pinch effect
    if (data.pivotPinchStrength > 0.0) {
        float pinchIntensity = 1.0 - smoothstep(0.0, pivotPinchRange, distFromPivotNorm);
        pinchIntensity = pow(pinchIntensity, 0.4);
        float pinchDistortion = pinchIntensity * data.pivotPinchStrength * data.rippleIntensity;
        distortedCoords.x += pinchDistortion * data.rippleDirection;
    }
    
    return distortedCoords;
}

void effect()
{
    vec2 texture_coords = VaryingTexCoord.xy;
    
    // Early exit optimization: skip all gradient work if no gradients active
    if (gradientCount == 0) {
        vec4 layer0 = Texel(MainTex, vec3(texture_coords, 0.0));
        vec4 layer1 = Texel(MainTex, vec3(texture_coords, 1.0));
        vec4 layer2 = Texel(MainTex, vec3(texture_coords, 2.0));
        love_Canvases[0] = layer0 * VaryingColor;
        love_Canvases[1] = layer1 * layer0.a;
        love_Canvases[2] = layer2 * layer0.a;
        return;
    }
    
    // Combined check: find if near gradient AND calculate gradient data in one pass
    bool nearGradient = false;
    vec2 texelSize = 1.0 / love_ScreenSize.xy;
    GradientData gradData;
    gradData.rippleIntensity = 0.0;
    gradData.rippleDirection = 0.0;
    gradData.rippleAmplitude = 0.0;
    gradData.ripplePivot = 0.5;
    gradData.pivotIntensityMultiplier = 1.0;
    gradData.timeOffset = 0.0;
    gradData.pivotPinchStrength = 0.0;
    gradData.activeRect = vec4(0.0);
    
    for (int i = 0; i < gradientCount; i++) {
        vec4 rect = gradientRects[i];
        vec2 topLeft = rect.xy;
        vec2 bottomRight = rect.zw;
        
        // Check expanded bounds for near check
        vec2 expandedTopLeft = topLeft - texelSize;
        vec2 expandedBottomRight = bottomRight + texelSize;
        
        if (texture_coords.x >= expandedTopLeft.x && texture_coords.x <= expandedBottomRight.x &&
            texture_coords.y >= expandedTopLeft.y && texture_coords.y <= expandedBottomRight.y) {
            nearGradient = true;
            
            // Also calculate gradient data if inside actual bounds
            if (texture_coords.x >= topLeft.x && texture_coords.x <= bottomRight.x &&
                texture_coords.y >= topLeft.y && texture_coords.y <= bottomRight.y) {
                
                float rectWidth = bottomRight.x - topLeft.x;
                float normalizedX = clamp((texture_coords.x - topLeft.x) / rectWidth, 0.0, 1.0);
                
                float intensity = (gradientDirections[i] < 0.5) ? (1.0 - normalizedX) : normalizedX;
                
                if (intensity > gradData.rippleIntensity) {
                    gradData.rippleDirection = (gradientDirections[i] < 0.5) ? -1.0 : 1.0;
                    gradData.rippleAmplitude = gradientRippleAmplitudes[i];
                    gradData.ripplePivot = gradientRipplePivots[i];
                    gradData.pivotIntensityMultiplier = gradientPivotIntensities[i];
                    gradData.timeOffset = gradientTimeOffsets[i];
                    gradData.pivotPinchStrength = gradientPivotPinchStrengths[i];
                    gradData.activeRect = rect;
                }
                
                intensity = pow(intensity, 1.0 / gradientPower);
                gradData.rippleIntensity = max(gradData.rippleIntensity, intensity);
            }
        }
    }
    
    // Apply ripple distortion
    vec2 distortedCoords = nearGradient ? applyRippleDistortion(texture_coords, gradData) : texture_coords;
    
    // Sample the 3 layers from the texture array (using distorted coordinates if near gradient)
    vec4 layer0 = Texel(MainTex, vec3(distortedCoords, 0.0));
    vec4 layer1 = Texel(MainTex, vec3(distortedCoords, 1.0));
    vec4 layer2 = Texel(MainTex, vec3(distortedCoords, 2.0));
    
    // Also sample undistorted for black pixel detection (only if near gradient)
    vec4 layer0_undistorted = nearGradient ? Texel(MainTex, vec3(texture_coords, 0.0)) : layer0;
    
    // Start with the base texture color
    vec4 finalColor = layer0;
    vec3 baseColor = layer0.rgb;  // Store original color to clamp darkness later
    
    // Check if current pixel is opaque
    bool isOpaque = (layer0.a > 0.5);
    bool isOutlinePixel = false;  // Track if this is an outline pixel
    bool isEdgePixel = false;  // Track if this pixel has transparent neighbors
    bool gradientApplied = false;  // Track if any gradient affected this pixel
    
    // Only do expensive edge detection if pixel is opaque AND near a gradient
    if (isOpaque && nearGradient) {
        // Cardinal and diagonal directions
        vec2 offsets[8];
        offsets[0] = vec2( 0.0,  1.0);  offsets[1] = vec2( 1.0,  0.0);
        offsets[2] = vec2( 0.0, -1.0);  offsets[3] = vec2(-1.0,  0.0);
        offsets[4] = vec2( 1.0,  1.0);  offsets[5] = vec2( 1.0, -1.0);
        offsets[6] = vec2(-1.0, -1.0);  offsets[7] = vec2(-1.0,  1.0);
        
        int numChecks = outlineThickness > 1.5 ? 8 : 4;
        
        for (int i = 0; i < numChecks; i++) {
            vec2 neighborScreenCoords = texture_coords + offsets[i] * texelSize;
            
            // Calculate accurate gradient data for this neighbor's position
            GradientData neighborGradData = calculateGradientData(neighborScreenCoords);
            
            // Apply neighbor's own ripple distortion
            vec2 neighborDistortedCoords = applyRippleDistortion(neighborScreenCoords, neighborGradData);
            
            // Sample with distorted coordinates
            vec4 neighborColor = Texel(MainTex, vec3(neighborDistortedCoords, 0.0));
            
            if (neighborColor.a < 0.5) {
                isEdgePixel = true;
                break;
            }
        }
    }
    
    // Apply gradients (only if pixel is near any gradient)
    if (nearGradient) {
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
        // IMPORTANT: Calculate this BEFORE applying outline, so outline respects rounded corners
        float cornerFactor = 1.0;
        if (edgeRoundingRadius > 0.0) {
            vec2 lips = gradientLips[i];
            float radiusX = edgeRoundingRadius / rectWidth;
            float radiusY = edgeRoundingRadius / rectHeight;
            bool isLeftGradient = gradientDirections[i] < 0.5;
            
            // Determine which side to round based on gradient direction
            float softSideX = isLeftGradient ? (1.0 - normalizedX) : normalizedX;
            
            // Calculate corner distance for both top and bottom
            bool inTopCorner = (lips.x > 0.5) && (normalizedY < radiusY) && (softSideX < radiusX);
            bool inBottomCorner = (lips.y > 0.5) && (normalizedY > (1.0 - radiusY)) && (softSideX < radiusX);
            
            if (inTopCorner || inBottomCorner) {
                float distFromY = inTopCorner ? normalizedY : (1.0 - normalizedY);
                vec2 cornerVec = vec2((radiusX - softSideX) * rectWidth, (radiusY - distFromY) * rectHeight);
                float cornerDist = length(cornerVec) / edgeRoundingRadius;
                cornerFactor = (cornerDist > 1.0) ? 0.0 : smoothstep(1.0, 0.7, cornerDist);
            }
        }
        
        // Apply corner rounding by pushing blend toward 1.0 (original color) at corners
        blendFactor = mix(1.0, blendFactor, cornerFactor);
        
        // Skip this gradient if pixel is outside the rounded corner
        if (cornerFactor < 0.01) {
            continue;
        }
        
        // Mark that a gradient is affecting this pixel (only after corner check)
        gradientApplied = true;
        
        // Check if pixel is originally fully black (use undistorted sample)
        bool isBlackPixel = (layer0_undistorted.r < 0.01 && layer0_undistorted.g < 0.01 && layer0_undistorted.b < 0.01);
        
        // Draw solid white outline on edge pixels or originally black pixels
        // This now respects the rounded corners since we checked cornerFactor above
        if (isEdgePixel || isBlackPixel) {
            finalColor.rgb = vec3(1.0, 1.0, 1.0);
            isOutlinePixel = true;
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
            // This is a white outline pixel - keep it pure white across entire gradient (no tapering)
            finalColor.rgb = vec3(1.0, 1.0, 1.0);
        } else {
            // Normal gradient application for non-outline pixels
            // First blend based on the blendFactor (gradient direction)
            vec3 directionalBlend = mix(gradientColor.rgb, finalColor.rgb, blendFactor);
            // Then blend with original based on gradient alpha (transparency)
            finalColor.rgb = mix(finalColor.rgb, directionalBlend, gradientColor.a);
        }
        
        // Clamp to not be brighter than original (prevent brightening from falloff)
        // Skip clamping for outline pixels to keep them pure white
        if (!isOutlinePixel) {
            float originalBrightness = dot(originalColor, vec3(0.299, 0.587, 0.114));
            float resultBrightness = dot(finalColor.rgb, vec3(0.299, 0.587, 0.114));
            if (resultBrightness > originalBrightness) {
                finalColor.rgb = originalColor * (resultBrightness / max(originalBrightness, 0.001));
                finalColor.rgb = min(finalColor.rgb, originalColor);
            }
        }
        }
        
        // Ensure overlapping gradients don't exceed the darkness specified by gradient alpha
        // Only apply this clamping if a gradient was actually applied to this pixel
        // Skip for outline pixels to keep them pure white
        if (gradientApplied && !isOutlinePixel) {
            // Calculate the darkest allowed color based on gradient alpha
            vec3 maxDarkness = mix(baseColor, gradientColor.rgb, gradientColor.a);
            
            // For each color channel, don't go darker than maxDarkness
            // (darker = lower value, so use max to prevent going below the threshold)
            finalColor.rgb = max(finalColor.rgb, maxDarkness);
        }
    }
    
    // Output each layer to its corresponding canvas
    love_Canvases[0] = finalColor * VaryingColor;
    love_Canvases[1] = layer1 * layer0.a; // * VaryingColor.a;
    love_Canvases[2] = layer2 * layer0.a; // * VaryingColor.a;
}