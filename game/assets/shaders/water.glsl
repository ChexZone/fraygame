#define MAX_WATER_BOXES 15

// mask: x=top, y=bottom, z=left, w=right
extern vec4 waterSides[MAX_WATER_BOXES];
extern vec4 waterRects[MAX_WATER_BOXES];
extern int  waterCount;
extern vec2 aspectRatio;
extern float clock;

extern float frontWaveSpeed;
extern float backWaveSpeed;

// NEW: external offset for wave sine phase (x, y)
extern vec2 waveOffset;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords) {
    // base coordinate for water box calculations (without waveOffset)
    vec2 baseCoord = uv * aspectRatio;

    float isInFrontWater   = 0.0;
    float isInBackWater    = 0.0;
    float isOnFrontSurface = 0.0;
    float isOnBackSurface  = 0.0;
    float bandAccum        = 0.0;

    float closestFrontDist = 1e6;
    float closestBackDist  = 1e6;

    // --- NEW: count how many front-water rects cover this pixel ---
    float frontCount = 0.0;

    // precompute
    float invA_Y    = 1.0 / aspectRatio.y;
    float invA_X    = 1.0 / aspectRatio.x;
    float freq      = 250.0;
    float amp       = 0.3;
    float bobAmp    = 0.5;
    float bobSpeed  = 1.0;

    float thickY = 0.25 * invA_Y;
    float thickX = 0.25 * invA_X;

    float maxOffY = (amp + bobAmp) * invA_Y;
    float maxOffX = (amp + bobAmp) * invA_X;

    float waveOverflow = 12.0 * invA_Y;
    float surfMarginY  = maxOffY + thickY - 0.08;
    float surfMarginX  = maxOffX + thickX - 0.06;

    float bobF = sin(clock * bobSpeed)      * bobAmp;
    float bobB = sin(clock * bobSpeed + 1.) * bobAmp;

    for (int i = 0; i < waterCount; i++) {
        vec4 sides = waterSides[i];
        vec2 tl    = waterRects[i].xy * aspectRatio;
        vec2 br    = waterRects[i].zw * aspectRatio;

        // expanded region for sine‐existence using baseCoord
        vec2 eTL = tl - vec2(waveOverflow);
        vec2 eBR = br + vec2(waveOverflow);
        float insideExp = step(eTL.x, baseCoord.x) * step(baseCoord.x, eBR.x)
                        * step(eTL.y, baseCoord.y) * step(baseCoord.y, eBR.y);
        if (insideExp > 0.0) {
            // --- compute per-side sine offsets using (baseCoord + waveOffset) ---
            float wFX = sin((baseCoord.x + waveOffset.x) * freq * invA_X + (clock+1.)*frontWaveSpeed) * amp;
            float wBX = sin((baseCoord.x + waveOffset.x) * freq * invA_X + clock*backWaveSpeed ) * amp;
            float wFY = sin((baseCoord.y + waveOffset.y) * freq * invA_X + (clock+2.)*frontWaveSpeed) * amp;
            float wBY = sin((baseCoord.y + waveOffset.y) * freq * invA_X + (clock+1.)*backWaveSpeed ) * amp;

            // boundary positions
            float sFT = tl.y + (wFX + bobF) * invA_Y;
            float sFB = br.y + (wFX + bobF) * invA_Y;
            float sBT = tl.y + (wBX + bobB) * invA_Y;
            float sBB = br.y + (wBX + bobB) * invA_Y;

            float sFL = tl.x + (wFY + bobF) * invA_X;
            float sFR = br.x + (wFY + bobF) * invA_X;
            float sBL = tl.x + (wBY + bobB) * invA_X;
            float sBR = br.x + (wBY + bobB) * invA_X;

            // mix flat vs wavy per‐side
            float bFT = mix(tl.y, sFT, sides.x);
            float bFB = mix(br.y, sFB, sides.y);
            float bFL = mix(tl.x, sFL, sides.z);
            float bFR = mix(br.x, sFR, sides.w);

            float bBT = mix(tl.y, sBT, sides.x);
            float bBB = mix(br.y, sBB, sides.y);
            float bBL = mix(tl.x, sBL, sides.z);
            float bBR = mix(br.x, sBR, sides.w);

            // distances using baseCoord
            float dFT = baseCoord.y - bFT;
            float dFB = bFB - baseCoord.y;
            float dFL = baseCoord.x - bFL;
            float dFR = bFR - baseCoord.x;

            float dBT = baseCoord.y - bBT;
            float dBB = bBB - baseCoord.y;
            float dBL = baseCoord.x - bBL;
            float dBR = bBR - baseCoord.x;

            // underwater detection
            float inF = step(0.,dFT)*step(0.,dFB)*step(0.,dFL)*step(0.,dFR);
            float inB = step(0.,dBT)*step(0.,dBB)*step(0.,dBL)*step(0.,dBR);

            // --- accumulate front-water coverage count ---
            frontCount += inF;
            isInFrontWater = max(isInFrontWater, inF);
            isInBackWater  = max(isInBackWater,  inB);

            closestFrontDist = min(closestFrontDist, min(dFT,dFL));
            closestBackDist  = min(closestBackDist,  min(dBT,dBL));

            // surface‐line clamp
            float inSurfX = step(tl.x - surfMarginX, baseCoord.x)
                          * step(baseCoord.x, br.x + surfMarginX);
            float inSurfY = step(tl.y - surfMarginY, baseCoord.y)
                          * step(baseCoord.y, br.y + surfMarginY);

            float fT = step(abs(dFT), thickY)*inSurfX*sides.x;
            float fB = step(abs(dFB), thickY)*inSurfX*sides.y;
            float fL = step(abs(dFL), thickX)*inSurfY*sides.z;
            float fR = step(abs(dFR), thickX)*inSurfY*sides.w;
            float surfF = (fT+fB+fL+fR)*(1.0 - isInFrontWater);

            float bT = step(abs(dBT), thickY)*inSurfX*sides.x;
            float bB = step(abs(dBB), thickY)*inSurfX*sides.y;
            float bL = step(abs(dBL), thickX)*inSurfY*sides.z;
            float bR = step(abs(dBR), thickX)*inSurfY*sides.w;
            float surfB = (bT+bB+bL+bR)*(1.0 - isInFrontWater);

            isOnFrontSurface = max(isOnFrontSurface, surfF);
            isOnBackSurface  = max(isOnBackSurface,  surfB);

            // purple‐shadow per‐side
            float insideBand = inSurfX * inSurfY;
            float bandT = step(0.,dFT)*step(0.,-dBT)*sides.x;
            float bandB = step(0.,dFB)*step(0.,-dBB)*sides.y;
            float bandL = step(0.,dFL)*step(0.,-dBL)*sides.z;
            float bandR = step(0.,dFR)*step(0.,-dBR)*sides.w;
            float bandHere = max(max(bandT,bandB), max(bandL,bandR)) * insideBand;
            bandAccum = max(bandAccum, bandHere);
        }
    }

    // --- NEW: if more than one front-water covers pixel, disable its surface & shadow ---
    float single = step(frontCount, 1.0);
    isOnFrontSurface *= single;
    bandAccum        *= single;

    // ripple & texture use base uv without offset
    vec2 ruv = uv;
    if (isInFrontWater>0.0 || isInBackWater>0.0)
        ruv.x += sin(ruv.y*150.+clock*4.)*0.001;
    vec4 tx = Texel(tex, ruv);

    // colors
    vec4 colO = vec4(139./255.,0.,1.,1.),    // purple shadow
         colT = vec4(62./255.,115./255.,1.,0.95),
         colB = vec4(15./255.,211./255.,1.,1.),  // blue fill
         colS = vec4(108./255.,1.,1.,1.);    // surface highlight
    float clr = step(tx.a,0.01);
    vec4 wm = mix(colO,colT,clr),
         uw = mix(tx,wm,1.0);

    vec4 outC = tx;
    outC = mix(outC, colB,      isInBackWater);
    outC = mix(outC, uw,        isInFrontWater);
    outC = mix(outC, colO, bandAccum);
    outC = mix(outC, colS, isOnFrontSurface);
    outC = mix(outC, colS, isOnBackSurface*clr);

    return outC;
}