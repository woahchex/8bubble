local CANVAS_SIZE = V{32,32}
local Bubble = {
    -- properties
    Name = "Bubble",        -- Easy identifier
    Test = true,
    DrawScale = V{1,1},

    Health = 5,             -- how much health the ball has left
    FramesSinceHit = 0,     -- how many frames since the bubble was hit

    TexFill = Texture.new("game/assets/images/bubble-fill.png"),
    TexGreen = Texture.new("game/assets/images/bubble-green.png"),
    TexPink = Texture.new("game/assets/images/bubble-pink.png"),
    Numbers = {
        [0] = Texture.new("game/assets/images/0.png"),
        [1] = Texture.new("game/assets/images/1.png"),
        [2] = Texture.new("game/assets/images/2.png"),
        [3] = Texture.new("game/assets/images/3.png"),
        [4] = Texture.new("game/assets/images/4.png"),
        [5] = Texture.new("game/assets/images/5.png"),
        [6] = Texture.new("game/assets/images/6.png"),
        [7] = Texture.new("game/assets/images/7.png"),
        [8] = Texture.new("game/assets/images/8.png"),
    },
    
    Size = V{16, 16},
    Position = V{0, 0},
    Rotation = 0,
    Direction = V{0, 0},
    Velocity = 0,
    Threshold = 16,
    DecelSpeed = 0.015,

    -- internal properties
    _super = "Gui",      -- Supertype
    _global = true
}


function Bubble.new()
    local myObj = Bubble:SuperInstance()
    myObj.Shader = Shader.new("game/assets/shaders/1px-white-outline.glsl"):Send("step", V{1,1}/CANVAS_SIZE)
    myObj.Texture = Canvas.new(CANVAS_SIZE())
    myObj.Tex2 = Canvas.new(CANVAS_SIZE())
    myObj.DrawScale = V{1,1}
    return Bubble:Connect(myObj)
end
    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    local MAX_Y_DIST = 1
    local MAX_X_DIST = 1
    


function Bubble:Update(dt)
    local bubbles = self:GetParent():GetChildren()
    
    if self.Health == 0 then
        for i, ball in ipairs(bubbles) do
            local vector = ball.Position - self.Position
            
            if vector:Magnitude() < 32 then
                local vector1 = vector:Normalize() * (32 / vector:Magnitude())
                local vector2 = ball.Direction * ball.Velocity
                local n = vector:Normalize()
    
                local a1 = 0 + (vector1 * n)
                local a2 = 0 + (vector2 * n)
                local p = (2.0 * (a1 - a2))

                local newVector = vector2 + (n * p)
                ball.Direction = newVector:Normalize()
                ball.Velocity = newVector:Magnitude()
            end
        end

        self:Emancipate()
        
    elseif self.Velocity > 0 then
        local subdivisions = 1
        if math.abs(self.Velocity) > MAX_X_DIST then
            subdivisions = math.floor(1+math.abs(self.Velocity)/MAX_X_DIST)
        end
    
        if math.abs(self.Velocity) > MAX_Y_DIST then
            subdivisions = math.max(subdivisions, math.floor(1+math.abs(self.Velocity)/MAX_Y_DIST))
        end
        local posDelta = (self.Direction * self.Velocity)
        
        self.Velocity = self.Velocity - self.DecelSpeed
        
        local collisions = {}
        for _ = 1, subdivisions do
            self.Position = self.Position + posDelta/subdivisions
            for i, ball in ipairs(bubbles) do
                if ball ~= self and (ball.Position - self.Position):Magnitude() < Bubble.Threshold then
                    collisions[#collisions + 1] = ball
                end
            end
    
            if #collisions > 0 then
                local bubble = collisions[1]
                
                local vector1 = self.Direction * self.Velocity
                local vector2 = bubble.Direction * bubble.Velocity
                local n = (self.Position - bubble.Position):Normalize()
    
                local a1 = 0 + (vector1 * n)
                local a2 = 0 + (vector2 * n)
                local p = (2.0 * (a1 - a2))
    
                local newVector1 = vector1 - (n * p)
                local newVector2 = vector2 + (n * p)
    
                self.Direction = newVector1:Normalize()
                bubble.Direction = newVector2:Normalize()
    
                self.Velocity = newVector1:Magnitude() * 0.5
                bubble.Velocity = newVector2:Magnitude() * 0.5
    
                self.Position = bubble.Position + (n * 16)
    
                self.Health = math.clamp(self.Health - 1, 0, 8)
                bubble.Health = math.clamp(bubble.Health - 1, 0, 8)
    
                self.FramesSinceHit = 0
                bubble.FramesSinceHit = 0
    
               
                break
            end
            local collided = self:BallToWallCollision()
            if collided then break end
        end
        

    end

    -- updating framevalues
    self.FramesSinceHit = self.FramesSinceHit + 1
end

local lg, floor = love.graphics, math.floor
function Bubble:Draw(tx, ty)
    local oldshader
    -- self.DrawScale = V{1+math.sin(Chexcore._clock)/4,1}
    -- self.Rotation = self.Rotation + 0.01
    local dv = self.Direction or V{0,0}
    self.Rotation = V{-dv.X, dv.Y}:ToAngle()
    
    if self.FramesSinceHit == 1 then
        self.DrawScale = V{1,1-self.Velocity/10}
    end
    self.DrawScale = self.DrawScale:Lerp(V{1,1},0.05)

    if self.DrawOverChildren and self:HasChildren() then
        self:DrawChildren(tx, ty)
    end
    
    local sx = CANVAS_SIZE.X * (self.DrawScale[1]-1)
    local sy = CANVAS_SIZE.Y * (self.DrawScale[2]-1)

    self.Numbers[self.Health]:DrawToScreen(
        floor(self.Position[1] - tx),
        floor(self.Position[2] - ty) ,
        0,
        self.Size[1] + sx,
        self.Size[2] + sy,
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )

    self.Texture:Activate()
    lg.clear()
    lg.setColor(1,1,1)
    local bubbleOfs = V{0+0, math.cos(Chexcore._clock*2)*1}


    self.TexGreen:DrawToScreen(
        CANVAS_SIZE.X/2 + bubbleOfs.X,
        CANVAS_SIZE.Y/2 + bubbleOfs.Y,
        0,
        self.Size[1] + sx,
        self.Size[2] + sy,
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )

    self.TexFill:DrawToScreen(
        CANVAS_SIZE.X/2 + bubbleOfs.X,
        CANVAS_SIZE.Y/2 + bubbleOfs.Y,
        0,
        self.Size[1] + sx,
        self.Size[2] + sy,
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )
    self.TexPink:DrawToScreen(
        CANVAS_SIZE.X/2 + bubbleOfs.X,
        CANVAS_SIZE.Y/2 + bubbleOfs.Y,
        0,
        self.Size[1] + sx,
        self.Size[2] + sy,
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )


    self.Texture:Deactivate()

    if self.Shader then
        self.Shader:Activate()
    end
    self.Tex2:Activate()
        lg.clear()
        self.Texture:DrawToScreen(
            CANVAS_SIZE.X/2,CANVAS_SIZE.Y/2,
            0,
            CANVAS_SIZE.X,
            CANVAS_SIZE.Y,
            0.5,0.5
        )

    self.Tex2:Deactivate()
    if self.Shader then
        self.Shader:Deactivate()
    end
    lg.setColor(self.Color)
    self.Tex2:DrawToScreen(
        floor(self.Position[1] - tx),
        floor(self.Position[2] - ty),
        self.Rotation,
        CANVAS_SIZE.X + sx,
        CANVAS_SIZE.Y + sy,
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )
    local r = self.Rotation
    self.Rotation = 0
    local point = self:GetPoint(0.7,0.25)
    self.Rotation = r
    love.graphics.circle("fill",point.X-tx+bubbleOfs.X, point.Y-ty, 2.5)
    love.graphics.circle("fill",point.X-tx+2+bubbleOfs.Y, point.Y-ty+4, 1)
    -- love.graphics.circle("fill",self.Position[2]+4+bubbleOfs.X+sx/4-ty, CANVAS_SIZE.Y/2+0+bubbleOfs.Y, 1)

    if not self.DrawOverChildren and self:HasChildren() then
        self:DrawChildren(tx, ty)
    end

    -- return Prop.Draw(self, tx, ty)
end

function Bubble:BallToWallCollision()
    self.Tilemap = self.Tilemap or self:GetParent():GetParent():GetChild("Tilemap")
    
    for _, hDist, vDist, tileID, tileNo, tileLayer in self:CollisionPass(self.Tilemap, true, false, true) do
        
        local surfaceInfo = self.Tilemap:GetSurfaceInfo(tileID)
        local face = Prop.GetHitFace(hDist,vDist)
        -- hDist is # pixels horizontally inside the tile the bubble is (pos=wall on left, neg=wall on right)
        -- vDist is # pixels vertically inside the tile the bubble is (pos=wall on top, neg=wall on bottom)
        -- face is Chexcore's best estimate of which face you hit ("top"|"bottom"|"left"|"right")
        -- ask chex about surfaceinfo when different wall types come into play
        if face == "left" or face == "right" then
            print("Collision wall", self.Position.X)
            self.Direction.X = -self.Direction.X
            self:SetEdge(face, self.Tilemap:GetEdge(face=="left" and "right" or "left", tileNo))
            self.Position.X = self.Position.X + (face=="left" and 1 or -1)
        elseif face == "top" or face == "bottom" then
            self.Direction.Y = -self.Direction.Y
            self:SetEdge(face, self.Tilemap:GetEdge(face=="top" and "bottom" or "top", tileNo))
            self.Position.Y = self.Position.Y + (face=="top" and 1 or -1)
        end
        self.Velocity = self.Velocity * 0.8
        self.Health = math.clamp(self.Health - 1, 0, 8)
        self.FramesSinceHit = 0
        return true
        -- self.Position = self.Position - V{hDist, vDist}
    end
end

return Bubble