#define MAX_WATER_BOXES 15

extern vec4 waterRects[MAX_WATER_BOXES];
extern int waterCount;
extern vec2 aspectRatio;
extern float clock;

// NEW externs:
extern float frontWaveSpeed;
extern float backWaveSpeed;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords)
{
    vec2 coord = uv * aspectRatio;

    float inWater = 0.0;
    float onSurface = 0.0;
    float inBackWater = 0.0;
    float onBackSurface = 0.0;

    float distanceToFront = -1e6;
    float distanceToBack = -1e6;

    // Precompute constants
    float invAspectY = 1.0 / aspectRatio.y;
    float waveFrequency = 150.0;
    float waveAmplitude = 0.4;
    float waveCenterOffset = 8.0;
    float lowerFrontOffset = 0.25;
    float bobbingAmplitude = 0.6;
    float bobbingSpeed = 2.0;

    float bobbingFront = sin(clock * bobbingSpeed) * bobbingAmplitude;
    float bobbingBack  = sin(clock * bobbingSpeed + 1.0) * bobbingAmplitude;

    for (int i = 0; i < waterCount; i++) {
        vec2 tl = waterRects[i].xy * aspectRatio;
        vec2 br = waterRects[i].zw * aspectRatio;

        float isInside = step(tl.x, coord.x) * step(coord.x, br.x) * step(tl.y, coord.y) * step(coord.y, br.y);

        if (isInside > 0.0) {
            // --- Front wave ---
            float waveFront = sin(coord.x * waveFrequency / aspectRatio.x + clock * frontWaveSpeed) * waveAmplitude;
            float surfaceFrontY = tl.y 
                                + waveCenterOffset * invAspectY
                                + waveFront * invAspectY
                                + bobbingFront * invAspectY
                                + lowerFrontOffset * invAspectY;

            distanceToFront = coord.y - surfaceFrontY;

            onSurface = step(abs(distanceToFront), 0.25 * invAspectY);
            inWater = step(0.0, distanceToFront);

            // --- Back wave ---
            float waveBack = sin(coord.x * waveFrequency / aspectRatio.x + clock * backWaveSpeed) * waveAmplitude;
            float surfaceBackY = tl.y
                                + waveCenterOffset * invAspectY
                                + waveBack * invAspectY
                                + bobbingBack * invAspectY;

            distanceToBack = coord.y - surfaceBackY;

            onBackSurface = step(abs(distanceToBack), 0.25 * invAspectY);
            inBackWater = step(0.0, distanceToBack);

            break; // found our box, no need to check more
        }
    }

    // Ripple UVs
    vec2 rippleUV = uv;
    if (inWater > 0.0 || inBackWater > 0.0) {
        float rippleSpeed = 2.0;
        float rippleStrength = 0.0025;
        float rippleFrequency = 50.0;
        rippleUV.x += sin(rippleUV.y * rippleFrequency + clock * rippleSpeed) * rippleStrength;
    }

    vec4 texel = Texel(tex, rippleUV);

    // Colors
    vec4 waterOpaque      = vec4(139.0/255.0, 0.0, 1.0, 1.0);      // #8b00ff
    vec4 waterTransparent = vec4(62.0/255.0, 115.0/255.0, 1.0, 1.0); // #3e73ff
    vec4 backWaterFill    = vec4(15.0/255.0, 211.0/255.0, 1.0, 1.0); // #0fd3ff
    vec4 surfaceColor     = vec4(108.0/255.0, 1.0, 1.0, 1.0);        // #6cffff

    // Mix water colors depending on transparency
    float isTexClear = step(texel.a, 0.01);
    vec4 waterColor = mix(waterOpaque, waterTransparent, isTexClear);
    vec4 finalWaterCol = mix(texel, waterColor, 1.0);

    // Compose final color
    vec4 finalColor = texel;
    finalColor = mix(finalColor, backWaterFill, inBackWater);
    finalColor = mix(finalColor, finalWaterCol, inWater);

    // Fill gap between back and front wave
    float belowFront = step(0.0, distanceToFront);
    float aboveBack  = step(0.0, -distanceToBack);
    float bandRegion = belowFront * aboveBack;
    finalColor = mix(finalColor, waterOpaque, bandRegion);

    // Draw surface crests
    finalColor = mix(finalColor, surfaceColor, onSurface);

    float backCrestVisible = onBackSurface * (1.0 - inWater);
    finalColor = mix(finalColor, surfaceColor, backCrestVisible);

    return finalColor;
}
