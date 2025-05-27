local Water = {
    Name = "Water",
    
    _super = "Prop", _global = true
}


function Water.new()
    return Prop.new{
        Name = "Water",
        Position = Player.Position:Clone(),

        TopSurface = true,
        LeftSurface = false,
        RightSurface = false,
        BottomSurface = false,

        AnchorPoint = V{0.5,0.5},
        -- Size = V{1000,1000},
        Update = function (self, dt)
        --    if Chexcore._clock < 1 then
        --       self:MoveTo(player.Position)
        --    end
        end,
    
        Draw = function (self, tx, ty)
            if not self:GetLayer() then return end
            -- draw method with tx, ty offsets (draw at position minus tx, ty)
            local layer = self:GetLayer()
            local cam = layer:GetParent().Camera
            local tl, br = self:GetPoint(0,0), self:GetPoint(1,1)
            -- if isLightOnScreen(cam.Position, layer.Canvases[1]:GetSize(), cam.Zoom, self.Radius, tl, br) then
                local x1, y1 = (((tl or self:GetPoint(0,0)) - V{tx,ty}) / self:GetLayer().Canvases[1]:GetSize())()
                local x2, y2 = (((br or self:GetPoint(1,1)) - V{tx,ty}) / self:GetLayer().Canvases[1]:GetSize())()
        
        
                
                self:GetLayer():EnqueueShaderData("water", "waterRects", {x1, y1, x2, y2})
                self:GetLayer():EnqueueShaderData("water", "waterSides", {self.TopSurface and 1 or 0, self.BottomSurface and 1 or 0, self.LeftSurface and 1 or 0, self.RightSurface and 1 or 0})
                -- local l = self:GetLayer()
                -- print("L IS", tostring(l == nil))
                -- print("FUCKGHDGHDH", self, self:GetLayer():GetShaderData("lighting", "lightCount"))
                self:GetLayer():SetShaderData("water", "waterCount", (self:GetLayer():GetShaderData("water", "waterCount") or 0)+1)
                self:GetLayer():SetShaderData("water", "aspectRatio", {16,9})
                self:GetLayer():SetShaderData("water", "clock", Chexcore._clock)
                self:GetLayer():SetShaderData("water", "frontWaveSpeed", 1)
                self:GetLayer():SetShaderData("water", "backWaveSpeed", -1)
            -- end
                -- print(self:GetLayer():GetShaderData("water","waterCount"))
        end
    }
end

return Water