uniform vec2 step;
    vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
    {
        float alpha = Texel( texture, texturePos + vec2( step.x, 0.0f ) ).a +
        Texel( texture, texturePos + vec2( -step.x, 0.0f ) ).a +
        Texel( texture, texturePos + vec2( 0.0f, step.y ) ).a +
        Texel( texture, texturePos + vec2( 0.0f, -step.y ) ).a;

        // the commented bit is required if rendering directly from the spritesheet !

        //if(mod(texturePos.y, (1.0f/12.0f)) <= 0.005f) {
        //    return Texel(texture, texturePos) * col;
        //} else 
        if(alpha > 0.0f && Texel(texture,texturePos).a == 0.0f) {
            return vec4( 0.0f,0.0f,0.0f, 1.0f );
        } else if(Texel(texture,texturePos).a == 0.0f) {
            // return vec4(1.0f,1.0f,1.0f,1.0f) * col;
            return Texel(texture, texturePos) * col;
        } else {
            return Texel(texture, texturePos) * col;
        }

    }