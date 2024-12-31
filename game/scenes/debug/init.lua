local scene = GameScene.new{
    FrameLimit = 60,
    DeathHeight = 3000,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        self.Player = self:GetDescendant("Player")
        -- self.Camera.Position = self.Camera.Position:Lerp((self.Player:GetPoint(0.5,0.5)), 1000*dt)
        -- self.Camera.Zoom = 1 --+ (math.sin(Chexcore._clock)+1)/2
    end
}
Chexcore:AddType("game.objects.wheel")
Chexcore:AddType("game.objects.cameraZone")

local bgLayer = Prop.new{Size = V{640, 360},
    Update = function (self)
        self.Color = HSV{(scene.Camera.Position.Y/2000)%1,1,0.2}
    end
, Texture = Texture.new("chexcore/assets/images/square.png")}:Into(scene:AddLayer(Layer.new("BG", 640, 360, true):Properties{TranslationInfluence = 0}))
local mainLayer = scene:GetLayer("Gameplay")

scene:SwapChildOrder(bgLayer, mainLayer)

local tilemap = Tilemap.import("game.scenes.debug.tilemap", "game/scenes/debug/tilemap.png", {Scale = 1 }):Nest(mainLayer):Properties{
    LockPlayerVelocity = true,
    Update = function (self,dt)
        
        -- self.Position = self.Position + V{1,0}
        -- self.LayerColors[3].H = (self.LayerColors[2].H + dt/2)%1 
        -- self.LayerColors[1].S = math.sin(Chexcore._clock)/2 + 0.5 
    end
}


local layer = scene:AddLayer(Layer.new("Test", 640, 360)):Properties{
    TranslationInfluence = V{0,0}
}

-- fractal: black fill 
layer:Adopt(Prop.new{
    Size = V{640,360},
    AnchorPoint = V{0.5,0.5},
    -- Visible = false,
    Shader = Shader.new([[
extern float time;       // Pass from Lua
extern Image channel0;   // Pass texture
extern vec2 offset;      // Pass offset from Lua
extern float zoom;       // Pass zoom from Lua

const int iters = 150;
const float brightnessThreshold = 0.05;  // Threshold for brightness to switch to a saturated color

int fractal(vec2 p, vec2 point) {
    vec2 so = (-1.0 + 2.0 * point) * 0.4;
    vec2 seed = vec2(0.098386255 + so.x, 0.6387662 + so.y);

    for (int i = 0; i < iters; i++) {
        if (length(p) > 2.0) {
            return i;
        }
        vec2 r = p;
        p = vec2(p.x * p.x - p.y * p.y, 2.0 * p.x * p.y);
        p = vec2(p.x * r.x - p.y * r.y + seed.x, r.x * p.y + p.x * r.y + seed.y);
    }
    return 0;    
}

vec3 getColor(int i) { 
    float f = float(i) / float(iters) * 2.0;
    f = f * f * 2.0;
    return vec3(sin(f * 2.0), sin(f * 3.0), abs(sin(f * 7.0)));
}

float sampleMusicA(vec2 uv) {
    return 0.5 * (
        Texel(channel0, vec2(0.15, 0.25)).x + 
        Texel(channel0, vec2(0.30, 0.25)).x);
}

float calculateBrightness(vec3 color) {
    // Simple brightness calculation using the luminance formula
    return dot(color, vec3(0.299, 0.587, 0.114));  // Luminance (weighted average of RGB)
}

// Function to convert hue to RGB
vec3 hsvToRgb(float h) {
    float r, g, b;
    h = mod(h, 1.0);  // Ensure hue is within [0, 1] range
    float p = 0.0;
    float q = 1.0 - p;
    float t = (1.0 - abs(mod(h * 6.0, 2.0) - 1.0));
    
    // For each section of the hue circle (RGB)
    if (h < 1.0 / 6.0) {
        r = 1.0;
        g = t;
        b = p;
    } else if (h < 2.0 / 6.0) {
        r = q;
        g = 1.0;
        b = p;
    } else if (h < 3.0 / 6.0) {
        r = p;
        g = 1.0;
        b = t;
    } else if (h < 4.0 / 6.0) {
        r = p;
        g = q;
        b = 1.0;
    } else if (h < 5.0 / 6.0) {
        r = t;
        g = p;
        b = 1.0;
    } else {
        r = 1.0;
        g = p;
        b = q;
    }

    return vec3(r, g, b);  // Return the RGB color
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 iResolution = vec2(love_ScreenSize);
    vec2 fragCoord = screen_coords;

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 position = (fragCoord.xy / iResolution.xy - 0.5) * 2.0 * zoom + offset;  // Apply dynamic zoom and offset
    position.x *= iResolution.x / iResolution.y;

    vec2 iFC = vec2(iResolution.x - fragCoord.x, iResolution.y - fragCoord.y);
    vec2 pos2 = (iFC.xy / iResolution.xy - 0.5) * 2.0 * zoom + offset;
    pos2.x *= iResolution.x / iResolution.y;

    vec4 t3 = Texel(channel0, vec2(length(position) / 2.0, 0.1));
    float pulse = 0.5 + sampleMusicA(uv) * 1.8;

    // Dynamically generate the "mouse" effect using time
    vec2 dynamic_point = vec2(
        0.5 + sin(time / 3.0) / 2.0,
        0.9 + 0.4 * cos(time / 4.0)
    );

    // Get fractal colors and brightness
    int inside = fractal(position, dynamic_point); // Determine fractal iterations
    vec3 c = getColor(inside);

    // Initialize final color and alpha
    vec4 salida = vec4(0.0, 0.0, 0.0, 0.0);  // Transparent by default

    // If inside the fractal, set the color to black
    if (inside == 0) {
        salida.rgb = vec3(0.0, 0.0, 0.0);  // Black inside the fractal
        salida.a = 1.0;  // Opaque inside
        
    } else {
        // For points on the boundary, give a bright outline
        salida.rgb *= color.rgb;  // Multiply by the color passed from Love2D
        float brightness = calculateBrightness(c);  // Calculate brightness of the color
        if (brightness > brightnessThreshold) {
            salida.rgb = c;  // Bright color for the boundary (outside the fractal)
            salida.a = 1.0;  // Opaque for the outline
        } else {
            salida.a = 0.0;  // Transparent outside the fractal
        }
    }

    // Multiply the final color by the passed color from love.graphics.setColor
    

    return salida;
}
    ]]),

    Update = function (self)
        self.Shader:Send("time", (math.sin(Chexcore._clock/4))*(1)+11 )
        self.Shader:Send("offset", {(scene.Camera.Position/7000)()})
        self.Shader:Send("zoom", 1)
        self.Color = HSV{(math.sin(Chexcore._clock)+1)/8,1,1}:AddAxis(0.25)
    end,
    
})

-- fractal: saturated outline
layer:Adopt(Prop.new{
    Size = V{640,360},
    AnchorPoint = V{0.5,0.5},
    -- Visible = false,
    Shader = Shader.new([[
extern float time;       // Pass from Lua
extern Image channel0;   // Pass texture
extern vec2 offset;      // Pass offset from Lua
extern float zoom;       // Pass zoom from Lua

const int iters = 150;
const float brightnessThreshold = 0.09;  // Threshold for brightness to switch to a saturated color

int fractal(vec2 p, vec2 point) {
    vec2 so = (-1.0 + 2.0 * point) * 0.4;
    vec2 seed = vec2(0.098386255 + so.x, 0.6387662 + so.y);

    for (int i = 0; i < iters; i++) {
        if (length(p) > 2.0) {
            return i;
        }
        vec2 r = p;
        p = vec2(p.x * p.x - p.y * p.y, 2.0 * p.x * p.y);
        p = vec2(p.x * r.x - p.y * r.y + seed.x, r.x * p.y + p.x * r.y + seed.y);
    }
    return 0;    
}

vec3 getColor(int i) { 
    float f = float(i) / float(iters) * 2.0;
    f = f * f * 2.0;
    return vec3(sin(f * 2.0), sin(f * 3.0), abs(sin(f * 7.0)));
}

float sampleMusicA(vec2 uv) {
    return 0.5 * (
        Texel(channel0, vec2(0.15, 0.25)).x + 
        Texel(channel0, vec2(0.30, 0.25)).x);
}

float calculateBrightness(vec3 color) {
    // Simple brightness calculation using the luminance formula
    return dot(color, vec3(0.299, 0.587, 0.114));  // Luminance (weighted average of RGB)
}

// Function to convert hue to RGB
vec3 hsvToRgb(float h) {
    float r, g, b;
    h = mod(h, 1.0);  // Ensure hue is within [0, 1] range
    float p = 0.0;
    float q = 1.0 - p;
    float t = (1.0 - abs(mod(h * 6.0, 2.0) - 1.0));
    
    // For each section of the hue circle (RGB)
    if (h < 1.0 / 6.0) {
        r = 1.0;
        g = t;
        b = p;
    } else if (h < 2.0 / 6.0) {
        r = q;
        g = 1.0;
        b = p;
    } else if (h < 3.0 / 6.0) {
        r = p;
        g = 1.0;
        b = t;
    } else if (h < 4.0 / 6.0) {
        r = p;
        g = q;
        b = 1.0;
    } else if (h < 5.0 / 6.0) {
        r = t;
        g = p;
        b = 1.0;
    } else {
        r = 1.0;
        g = p;
        b = q;
    }

    return vec3(r, g, b);  // Return the RGB color
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 iResolution = vec2(love_ScreenSize);
    vec2 fragCoord = screen_coords;

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 position = (fragCoord.xy / iResolution.xy - 0.5) * 2.0 * zoom + offset;  // Apply dynamic zoom and offset
    position.x *= iResolution.x / iResolution.y;

    vec2 iFC = vec2(iResolution.x - fragCoord.x, iResolution.y - fragCoord.y);
    vec2 pos2 = (iFC.xy / iResolution.xy - 0.5) * 2.0 * zoom + offset;
    pos2.x *= iResolution.x / iResolution.y;

    vec4 t3 = Texel(channel0, vec2(length(position) / 2.0, 0.1));
    float pulse = 0.5 + sampleMusicA(uv) * 1.8;

    // Dynamically generate the "mouse" effect using time
    vec2 dynamic_point = vec2(
        0.5 + sin(time / 3.0) / 2.0,
        0.9 + 0.4 * cos(time / 4.0)
    );

    vec3 invFract = getColor(fractal(pos2, vec2(0.55 + sin(time / 3.0 + 0.5) / 2.0, pulse * 0.9)));
    vec3 fract4 = getColor(fractal(position / 1.6, vec2(0.6 + cos(time / 2.0 + 0.5) / 2.0, pulse * 0.8)));
    vec3 c = getColor(fractal(position, dynamic_point));

    t3 = abs(vec4(0.5, 0.1, 0.5, 1.0) - t3) * 2.0;

    vec4 fract01 = vec4(c, 1.0);
    vec4 salida = fract01 / t3 + fract01 * t3 + vec4(invFract, 0.6) + vec4(fract4, 0.3);

    // Calculate brightness
    float brightness = calculateBrightness(salida.rgb);

    // Set the color based on brightness
    if (brightness > brightnessThreshold) {
        // Choose a random hue (based on time or another variable)
        float hue = mod(time / 10.0, 1.0);  // Time-based hue (adjust timing for variation)
        salida.rgb = hsvToRgb(hue);  // Convert the hue to RGB and use it as the color
        salida.a = 1.0;  // Keep it fully opaque inside the fractal
    } else {
        // Outside the fractal, make it transparent
        salida.rgb = vec3(0.0, 0.0, 0.0);
        salida.a = 0.0;  // Make it transparent outside
    }

    // Multiply the final color by the passed color from love.graphics.setColor
    salida.rgb *= color.rgb;  // Multiply by the color passed from Love2D

    // Final transparency control: make sure areas outside the fractal are transparent
    if (brightness <= brightnessThreshold) {
        salida.a = 0.0;  // Outside the fractal, set alpha to 0 for transparency
    } else {
        salida.a = 1.0;  // Inside the fractal, keep alpha at 1 (fully opaque)
    }

    return salida;
}
    ]]),

    Update = function (self)
        self.Shader:Send("time", (math.sin(Chexcore._clock/4))*(1)+11 )
        self.Shader:Send("offset", {(scene.Camera.Position/7000)()})
        self.Shader:Send("zoom", 1)
        self.Color = HSV{(math.sin(Chexcore._clock)+1)/8,1,1}:AddAxis(0.25)
    end,
    
})

local rotatingDecoration = layer:Adopt(Prop.new{
    Size = V{640,640},
    Texture = Texture.new("game/scenes/debug/bg_circle.png"),
    Position = V{200,100},
    AnchorPoint = V{0.5,0.5},
    Update = function(self)
        -- self.Position = scene:GetLayer("Gameplay"):GetChild("Player").Position
        self.Rotation = Chexcore._clock/50
        self.Color = HSV{Chexcore._clock/50%1,1,1}
    end,

})

local rot2 = rotatingDecoration:Clone(true):Properties{
    Position = V{-198,0},
    Update = function(self)
        -- self.Position = scene:GetLayer("Gameplay"):GetChild("Player").Position
        self.Rotation = Chexcore._clock/50 + 0.35
        self.Color = HSV{(Chexcore._clock/50+ 0.25)%1,1,1}
    end,    
}

bgLayer:Adopt(rot2)

layer:Adopt(Prop.new{
    -- Texture = Texture.new("game/scenes/debug/angular white bg.png"),
    Size = V{640,200},
    Color = V{1,1,1},
    AnchorPoint = V{0.5,0},
    Update = function (self, dt)
        self.Position.Y = -scene.Camera.Position.Y/10 + 250
        -- self.Rotation = math.sin(Chexcore._clock/4)/20
    end
})


scene:SwapChildOrder(#scene:GetChildren()-1,#scene:GetChildren())



-- temp: holdable item
local holdable = scene:GetLayer("Gameplay"):Adopt(Prop.new{
    Name = "Holdable",
    Texture = Texture.new("game/assets/images/lineless-basketball.png"),
    LinelessTexture = Texture.new("game/assets/images/lineless-basketball.png"),
    Size = V{14, 14},
    CollisionSize = V{24,24},
    -- Color = V{1, 0, 0},
    AnchorPoint = V{0.5,0.5},
    Position = V{2200, 1800},
    Solid = true, Passthrough = true,


    -- will be properties of holdables
    IsHoldable = true,
    Owner = nil, -- will be a Player object

    COYOTE_FRAMES_AFTER_DROP = 6,
    COYOTE_FRAMES_AFTER_THROW = 12,
    COYOTE_FRAMES_AFTER_VERTICAL_BOUNCE = 5,
    X_BOUNCE_DELAY = 7,
    Y_BOUNCE_DELAY = 7,
    DebounceX = 0,
    DebounceY = 0,
    CoyoteFrames = 0,
    Velocity = V{0, 0},
    Gravity = 0.15,
    TerminalVelocity = V{3.5, 3.5},
    PickupDebounce = 0,
    FRAMES_BETWEEN_DROP_AND_REGRAB = 10,
    X_DECELERATION_GROUND = 0.035,
    X_DECELERATION_AIR = 0.01,
    Y_BOUNCE_HEIGHT_LOSS = 1.5,
    Y_MIN_BOUNCE_HEIGHT = 0.75,
    ExtendsHitbox = true,
    CanBeOverhang = false,
    SquashWithPlayer = true,
    VerticalOffset = -12,
    RotVelocity = 0,
    Collider = tilemap,
    Floor = nil,

    SFX = {
        Bounce = Sound.new("game/assets/sounds/basketball_1.wav", "static"):Set("Volume", 0.1)
    },

    Draw = function (self, tx, ty, isForeground)
        if (not self.Owner) or self.Owner.FramesSinceHoldingItem < 1 then
            return Prop.Draw(self, tx, ty-1, isForeground)
        end
    end,

    Update = function(self, dt)
        if not self.Owner then
            
            if self.PickupDebounce > 0 then
                self.PickupDebounce = self.PickupDebounce - 1
            end

            if self.DebounceX > 0 then
                self.DebounceX = self.DebounceX - 1
            end
            if self.DebounceY > 0 then
                self.DebounceY = self.DebounceY - 1
            end

            -- physics

            local MAX_Y_DIST = 1
            local MAX_X_DIST = 1
            local subdivisions = 1
            local posDelta = self.Velocity:Clone()*60*dt

            if math.abs(posDelta.X) > MAX_X_DIST then
                subdivisions = math.floor(1+math.abs(posDelta.X)/MAX_X_DIST)
            end
        
            if math.abs(posDelta.Y) > MAX_Y_DIST then
                subdivisions = math.max(subdivisions, math.floor(1+math.abs(posDelta.Y)/MAX_Y_DIST))
            end
            
            local interval = subdivisions == 1 and posDelta or posDelta / subdivisions

            

            for i = 1, subdivisions do
                self.Position = self.Position + interval
                self:RunCollision(false, dt)
            end

            

            if self.CoyoteFrames == 0 then
                if not self.Floor then
                    self.Velocity.Y = self.Velocity.Y + self.Gravity
                end
            else
                self.CoyoteFrames = self.CoyoteFrames - 1

                -- still apply upward velocity if it's there
                if self.Velocity.Y < 0 then
                    self.Velocity.Y = self.Velocity.Y + self.Gravity
                end
            end

            if self.Floor then -- apply ground deceleration
                self.Velocity.X = sign(self.Velocity.X) * math.max(math.abs(self.Velocity.X) - self.X_DECELERATION_GROUND*60*dt, 0)
            else -- apply air deceleration
                self.Velocity.X = sign(self.Velocity.X) * math.max(math.abs(self.Velocity.X) - self.X_DECELERATION_AIR*60*dt, 0)
            end
            -- max velocity
            self.Velocity.X = math.min(math.abs(self.Velocity.X), self.TerminalVelocity.X) * sign(self.Velocity.X)
            self.Velocity.Y = math.min(math.abs(self.Velocity.Y), self.TerminalVelocity.Y) * sign(self.Velocity.Y)

            
            self.RotVelocity = math.lerp(self.RotVelocity, 0, 0.03*60*dt)
            self.Rotation = self.Rotation + self.RotVelocity
        else
            self.RotVelocity = 0
            self.Rotation = 0
        end
        
        self.DrawScale = self.DrawScale:Lerp(V{1,1}, 0.15*60*dt)
    end,

    PutDown = function(self, ownerWasGrounded, ownerYVelocity) -- for when it's placed down gently with crouch
        self.Owner = nil
        self.Velocity = V{0,math.min(0, (ownerYVelocity and ownerYVelocity/2) or 0)}
        self.PickupDebounce = self.FRAMES_BETWEEN_DROP_AND_REGRAB
        if not ownerWasGrounded then
            self.CoyoteFrames = self.COYOTE_FRAMES_AFTER_DROP
        end
    end,

    Throw = function (self, dt)
        self.CoyoteFrames = self.COYOTE_FRAMES_AFTER_THROW
    end,

    RunCollision = function (self, expensive, dt)
        -- normal collision pass
        local pushX, pushY = 0, 0
        local movedAlready
        local ignoreSound
        -- normal collision pass
        if self.Floor and self.Velocity.X == 0 then
            self:ValidateFloor(expensive)
        else
            self:ValidateFloor(expensive)
            local iterator = (expensive or not self.Collider)
                                      and self:CollisionPass(self._parent, true)
                                       or self:CollisionPass(self.Collider, true, false, true)
            
            for solid, hDist, vDist, tileID in iterator do
                if not solid.Passthrough then
                    local surfaceInfo = solid:GetSurfaceInfo(tileID)
                    local face = Prop.GetHitFace(hDist,vDist)
                    
                    if solid._parent ~= self.Owner then
                        pushY = math.abs(pushY) > math.abs(vDist or 0) and pushY or (vDist or 0)
                        pushX = math.abs(pushX) > math.abs(hDist or 0) and pushX or (hDist or 0)
                    end
                    
                    if math.abs(pushX) > 4 then pushX = 0 end
                    if math.abs(pushY) > 4 then pushY = 0 end
                    -- if face == "bottom" and pushY ~= 0 then
                    --     self.Position.Y = self.Position.Y + pushY + 0.5
                    --     self.Floor = solid
                    --     self.Velocity.Y = 0
                    --     movedAlready = true
                    --     break -- return pushX, pushY -- Exit early for floor resolution
                    -- end

                    if pushX ~= 0 and math.abs(pushX) < 4 and (pushY == 0 or math.abs(pushY) > 4) and self.DebounceX == 0 then
                        print("X CASE", pushX, pushY)
                        self.DrawScale.X = math.clamp(1 - math.abs(self.Velocity.X)/4, 0.3, 1)
                        self.DebounceX = self.X_BOUNCE_DELAY
                        self.Position.X = self.Position.X + pushX + (1 * sign(pushX))
                        self.Velocity.X = -self.Velocity.X
                        self.RotVelocity = self.RotVelocity - sign(self.Velocity.Y)/20
                        self.CoyoteFrames = self.CoyoteFrames + self.COYOTE_FRAMES_AFTER_VERTICAL_BOUNCE
                        movedAlready = true
                    end
                    if pushY ~= 0 and math.abs(pushY) <= 4 and (pushX == 0 or math.abs(pushX) > 4) and self.DebounceY == 0 then
                        
                        self.DebounceY = self.Y_BOUNCE_DELAY
                        self.Position.Y = self.Position.Y + pushY + (1 * sign(pushY))
                        self.RotVelocity = self.RotVelocity + sign(self.Velocity.X)/20
                        movedAlready = true
                        if self.Velocity.Y > 0 and self.Velocity.Y < self.Y_MIN_BOUNCE_HEIGHT then
                            print("Y CASE 1", pushX, pushY, dt)
                            self.Velocity.Y = 0
                            ignoreSound = true
                        elseif not self.Floor then
                            print("Y CASE 2", pushX, pushY, dt)
                            self.Velocity.Y = math.min(
                                -(sign(self.Velocity.Y) * (math.abs(self.Velocity.Y) - self.Y_BOUNCE_HEIGHT_LOSS)),
                                0
                            )
                        end
                        self.DrawScale.Y = math.clamp(1 - math.abs(self.Velocity.Y)/4, 0.3, 1)
                        
                        if face == "bottom" then
                            self.Floor = solid
                        end
                    end
                end
            end

        end
        
        -- just give up if corner clipping, tbh
        if math.abs(pushX) > 2 and math.abs(pushY) > 2 and not movedAlready then
            print("whatever", self.Velocity)
            
            self.Position = self.Position - (self.Velocity or V{0,0})*60*dt
            self.Velocity = -self.Velocity
            -- if self.DebounceX == 0 then
            --     self.DebounceX = self.X_BOUNCE_DELAY
            --     self.Velocity.X = -self.Velocity.X
            --     movedAlready = true
            -- end
            -- if self.DebounceY == 0 then
            --     self.DebounceY = self.Y_BOUNCE_DELAY
            --     self.Velocity.Y = -self.Velocity.Y
            --     movedAlready = true
            -- end
            movedAlready = true
            
        end

        if movedAlready and not ignoreSound then
            self.SFX.Bounce:SetVolume(math.clamp(self.Velocity:Magnitude()/8, 0.1, 0.3)/10)
            self.SFX.Bounce:Stop()
            self.SFX.Bounce:SetPitch(1 + math.random(-5,5)/45 * 0.5)
            self.SFX.Bounce:Play()
        end

        print(pushX, pushY, self.Velocity)
        return pushX, pushY
    end,

    ValidateFloor = function (self, expensive)
        self.Position.Y = self.Position.Y + 2
        local foundFloor

        local iterator = expensive and self:CollisionPass(self._parent, true)
                                    or self:CollisionPass(self.Floor, true, false, true)
        
        for solid, hDist, vDist, tileID in iterator do
            local surfaceInfo = solid:GetSurfaceInfo(tileID)
            local face = Prop.GetHitFace(hDist,vDist)

            if solid == self.Floor and face == "bottom" then
                foundFloor = true
            end
        end
        if foundFloor then
            
        else
            
            self.Floor = nil
        end
        self.Position.Y = self.Position.Y - 2
    end
})


return scene