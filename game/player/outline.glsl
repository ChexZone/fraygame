uniform vec2 step;
    float rand(vec2 co){
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }
    vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
    {
        float alpha = Texel( texture, texturePos + vec2( step.x, 0.0f ) ).a +
        Texel( texture, texturePos + vec2( -step.x, 0.0f ) ).a +
        Texel( texture, texturePos + vec2( 0.0f, step.y ) ).a +
        Texel( texture, texturePos + vec2( 0.0f, -step.y ) ).a;

        if(
            alpha > 0.0f && Texel(texture,texturePos).a == 0.0f
        ) {
            return vec4( 0.0f,0.0f,0.0f, 1.0f );
        } else {
            return Texel(texture, texturePos) * col;
        }

    }