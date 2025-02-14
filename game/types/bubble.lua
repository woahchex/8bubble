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
        [9] = Texture.new("game/assets/images/9.png"),
    },
    
    Size = V{16, 16},
    Position = V{0, 0},
    Rotation = 0,
    Direction = V{0, 0},
    Speed = 0,
    Threshold = 16,
    DecelSpeed = 0.015,

    -- internal properties
    _super = "Gui",      -- Supertype
    _global = true
}

function Bubble.new()
    local myObj = Bubble:SuperInstance()
    myObj.Shader = Shader.new("game/assets/shaders/1px-white-outline.glsl"):Send("step", V{1,1}/CANVAS_SIZE*2)
    myObj.Texture = Canvas.new(CANVAS_SIZE())
    myObj.Tex2 = Canvas.new(CANVAS_SIZE())
    myObj.DrawScale = V{1,1}

    myObj.SFX = {
        Clink = {
            Sound.new("game/assets/sounds/ball-clink1.wav", "static"):Set("Volume", 1.0),
            Sound.new("game/assets/sounds/ball-clink2.wav", "static"):Set("Volume", 1.0),
            Sound.new("game/assets/sounds/ball-clink3.wav", "static"):Set("Volume", 1.0)
        },
        LightClink = {
            Sound.new("game/assets/sounds/ball-clink-light1.wav", "static"):Set("Volume", 1.0),
            Sound.new("game/assets/sounds/ball-clink-light2.wav", "static"):Set("Volume", 1.0),
            Sound.new("game/assets/sounds/ball-clink-light3.wav", "static"):Set("Volume", 1.0)
        },
        Sink = {
            Sound.new("game/assets/sounds/ball-sink.wav", "static"):Set("Volume", 1.0),
        },
        Explode = {
            Sound.new("game/assets/sounds/ball-explode.wav", "static"):Set("Volume", 0.15),
        },
        Refill = {
            Sound.new("game/assets/sounds/health-refill.wav", "static"):Set("Volume", 0.5),
        },
        Pop = {
            Sound.new("game/assets/sounds/bubble-pop.wav", "static"):Set("Volume", 0.5),
        },
        Serve = {
            Sound.new("game/assets/sounds/ball-serve.wav", "static"):Set("Volume", 1.0),
            Sound.new("game/assets/sounds/ball-serve2.wav", "static"):Set("Volume", 1.0),
        },
        Bump = {
            Sound.new("game/assets/sounds/ball-bump.wav", "static"):Set("Volume", 0.15),
        },
        Uke = {
            Sound.new("game/assets/sounds/uke-01.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/uke-02.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/uke-03.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/uke-04.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/uke-05.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/uke-06.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/uke-07.wav", "static"):Set("Volume", 0.3),
        }
    }

    return Bubble:Connect(myObj)
end

-- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
local MAX_Y_DIST = 1
local MAX_X_DIST = 1
    
function Bubble:PlaySFX(name, pitch, variance, volume)
    pitch = pitch or 1
    variance = variance or 1
    local no = math.random(1, #self.SFX[name])
    self.LastSFX_ID = self.LastSFX_ID or {}
    
    if no == self.LastSFX_ID[name] then
        no = no+1
        if no > #self.SFX[name] then
            no = 1
        end
    end
    self.LastSFX_ID[name] = no
    
    local soundToPlay = self.SFX[name][no]

    soundToPlay:Stop()
    
    soundToPlay:SetPitch(pitch + math.random(-5,5)/45 * variance)

    if volume or soundToPlay.BaseVolume then
        soundToPlay.BaseVolume = soundToPlay.BaseVolume or soundToPlay.Volume
        soundToPlay:SetVolume(soundToPlay.BaseVolume * (volume or 1))
    end

    soundToPlay:Play()
end

function Bubble:Update(dt)
    local bubbles = self:GetParent():GetChildren()
    local velocity = self.Direction * self.Speed
    local subdivisions = math.floor(math.max(math.abs(velocity.X), math.abs(velocity.Y)) + 1)

    if self.Health < 0 or (self.Speed <= 0 and self.Health == 0) then
        self:Pop()
        
    elseif self.Speed > 0 then
        if self.Speed > 1.5 or
            self.Speed > 1 and math.random(3) == 2 or
            self.Speed > 0.5 and math.random(8) == 4 then
            self:GetLayer():GetChild("BubbleParticle"):Emit{
                Position = self.Position + V{0, 1} + V{math.random(-3, 3), math.random(-3, 3)},
                Size = V{1, 1} * math.random(1, 3),
                SizeVelocity = V{-1, -1},
                Velocity = V{0, 0},
                Acceleration = V{0, 0},
                RotVelocity = 1,
                Rotation = math.random(-1, 1) / 8,
                AnchorPoint = V{0.5, 0.5},
                Duration = 0.6
            }
        end
        
        self:BallToInteractableCollision()        
        
        local collisions = {}
        for _ = 1, subdivisions do
            self.Position = self.Position + velocity/subdivisions
            for i, ball in ipairs(bubbles) do
                if ball ~= self and (ball.Position - self.Position):Magnitude() < Bubble.Threshold then
                    collisions[#collisions + 1] = ball
                end
            end
    
            if #collisions > 0 then
                local other = collisions[1]

                self.Health = self.Health - 1
                other.Health = other.Health - 1

                if self.Health < 0 then
                    self:Pop()
                    break
                end

                if other.Health < 0 then
                    other:Pop()
                    break
                end

                local otherVelocity = other.Direction * other.Speed

                local selfToOther = other.Position - self.Position
                local selfToOtherVel = otherVelocity - velocity
                local otherToSelf = self.Position - other.Position
                local otherToSelfVel = velocity - otherVelocity

                local selfDP = 0 + (otherToSelfVel * otherToSelf)
                local otherDP = 0 + (selfToOtherVel * selfToOther)

                local selfDP2 = (((0 + (velocity:Normalize() * otherToSelf:Normalize())) + 1) / 2) + 0.5
    
                local newSelfVelocity = (velocity * selfDP2) - (otherToSelf * (selfDP / (otherToSelf:Magnitude() * otherToSelf:Magnitude())))
                local newOtherVelocity = otherVelocity - (selfToOther * (otherDP / (selfToOther:Magnitude() * selfToOther:Magnitude())))
    
                self.Direction = newSelfVelocity:Normalize()
                self.Speed = newSelfVelocity:Magnitude() * 0.8
                self.FramesSinceHit = 0

                other.Direction = newOtherVelocity:Normalize()
                other.Speed = newOtherVelocity:Magnitude() * 0.8
                other.FramesSinceHit = 0

                self.Position = other.Position + (otherToSelf:Normalize() * 16)

                self:PlaySFX("Bump")
                self:GetLayer():GetParent().Score = self:GetLayer():GetParent().Score + 10
                self:GetLayer():GetParent().ScreenShake = self:GetLayer():GetParent().ScreenShake + 0.2 * self.Speed

                local sfx = self.Speed <= 1.2 and "LightClink" or "Clink"
                self:PlaySFX(sfx)
                
                break
            end
            
            local collided = self:BallToWallCollision()
            if collided then break end
        end

        self.Speed = self.Speed - self.DecelSpeed
    end

    -- updating framevalues
    self.FramesSinceHit = self.FramesSinceHit + 1
end

function Bubble:Pop()
    self:PlaySFX("Sink")
    self:PlaySFX("Pop", 0.5)
    self:PlaySFX("Uke", 1, 0)
    self:PlaySFX("Explode", 3, 4)

    self:GetLayer():GetParent().ScreenShake = self:GetLayer():GetParent().ScreenShake + 4
    self:GetLayer():GetParent().Score = self:GetLayer():GetParent().Score + 100*(self.Health+1)
    
    for i = 0, 330, 30 do
        self:GetLayer():GetChild("BubbleParticle"):Emit{
            Position = self.Position,
            Size = V{1, 1} * math.random(2, 4),
            SizeVelocity = V{-2, -2},
            Velocity = Vector.FromAngle(math.rad(i)) * 10,
            Acceleration = V{0, 0},
            RotVelocity = 1,
            Rotation = math.random(-1, 1) / 8,
            AnchorPoint = V{0.5, 0.5},
            Duration = 0.6
        }

        self:GetLayer():GetChild("BubbleParticle"):Emit{
            Position = self.Position,
            Size = V{1,1} * math.random(2,4),
            SizeVelocity = V{-2,-2},
            Velocity = Vector.FromAngle(math.rad(i))*30,
            Acceleration = V{0,0},
            RotVelocity = 1,
            Rotation = math.random(-1,1)/8,
            AnchorPoint = V{0.5,0.5},
            Duration = 2
        }
    end
    
    local bubbles = self:GetParent():GetChildren()
    for i, other in ipairs(bubbles) do
        local popToOther = other.Position - self.Position

        if popToOther:Magnitude() < 64 then
            local popVelocity = popToOther:Normalize() * (80 / math.max(16, popToOther:Magnitude()))
            local otherVelocity = other.Direction * other.Speed

            local popToOther = other.Position - self.Position
            local popToOtherVel = otherVelocity - popVelocity

            local otherDP = 0 + (popToOtherVel * popToOther)
            local newOtherVelocity = otherVelocity - (popToOther * (otherDP / (popToOther:Magnitude() * popToOther:Magnitude())))

            other.Direction = newOtherVelocity:Normalize()
            other.Speed = newOtherVelocity:Magnitude() * 0.8
        end
    end
    
    self.Size = self.Size * 3
    self:BallToDirtCollision()

    local pop = self:GetParent():GetParent():Adopt(Prop.new{
        Position = self.Position,
        Texture = Animation.new("game/assets/images/bubble-pop.png", 1, 4):Properties{
            Loop = false,
            Duration = 0.3
        },
        AnchorPoint = V{0.5,0.5},
        Size=V{40,40},
    })

    Timer.Schedule(0.3, function()
        pop:Emancipate()
    end)
    
    local parent = self:GetParent()
    self:Emancipate()
    parent:CheckEnd()
end

local lg, floor = love.graphics, math.floor
function Bubble:Draw(tx, ty)
    local oldshader
    -- self.DrawScale = V{1+math.sin(Chexcore._clock)/4,1}
    -- self.Rotation = self.Rotation + 0.01
    local dv = self.Direction or V{0,0}
    
    
    if self.FramesSinceHit == 1 then
        self.DrawScale = V{1,1-self.Speed/10}
        self.Rotation = V{-dv.X, dv.Y}:ToAngle()
    else
        self.Rotation = math.lerp(self.Rotation, 0, 0.045, 0.02)
    end
    self.DrawScale = self.DrawScale:Lerp(V{1,1},0.05)

    if self.DrawOverChildren and self:HasChildren() then
        self:DrawChildren(tx, ty)
    end
    
    local sx = CANVAS_SIZE.X * (self.DrawScale[1]-1)
    local sy = CANVAS_SIZE.Y * (self.DrawScale[2]-1)

    if self.Numbers[self.Health] then
        self.Numbers[self.Health]:DrawToScreen(
            floor(self.Position[1] - tx),
            floor(self.Position[2] - ty) ,
            0,
            self.Size[1] + sx,
            self.Size[2] + sy,
            self.AnchorPoint[1],
            self.AnchorPoint[2]
        )
    end


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
    self.Tilemap = self.Tilemap or self:GetParent():GetParent():GetParent():GetChild("TilemapLayer"):GetChild("Tilemap")
    
    for _, hDist, vDist, tileID, tileNo, tileLayer in self:CollisionPass(self.Tilemap, true, false, true) do
        -- print(_)
        local surfaceInfo = self.Tilemap:GetSurfaceInfo(tileID)
        local face = Prop.GetHitFace(hDist,vDist)

        -- hDist is # pixels horizontally inside the tile the bubble is (pos=wall on left, neg=wall on right)
        -- vDist is # pixels vertically inside the tile the bubble is (pos=wall on top, neg=wall on bottom)
        -- face is Chexcore's best estimate of which face you hit ("top"|"bottom"|"left"|"right")
        -- ask chex about surfaceinfo when different wall types come into play
        if face == "left" or face == "right" then
            self.Direction.X = -self.Direction.X
            self:SetEdge(face, self.Tilemap:GetEdge(face=="left" and "right" or "left", tileNo))
            self.Position.X = self.Position.X + (face=="left" and 1 or -1)
        elseif face == "top" or face == "bottom" then
            self.Direction.Y = -self.Direction.Y
            self:SetEdge(face, self.Tilemap:GetEdge(face=="top" and "bottom" or "top", tileNo))
            self.Position.Y = self.Position.Y + (face=="top" and 1 or -1)
        end
        self.Speed = self.Speed * 0.8
        self.Health = self.Health - 1
        self.FramesSinceHit = 0
        if self.Speed <= 1.2 then
            self:PlaySFX("LightClink")
        else
            self:PlaySFX("Clink")
        end

        if (surfaceInfo["Bottom"] or {}).Spikes or (surfaceInfo["Right"] or {}).Spikes or (surfaceInfo["Top"] or {}).Spikes or (surfaceInfo["Left"] or {}).Spikes then
            self:Pop()
        end
        
        return true
        -- self.Position = self.Position - V{hDist, vDist}
    end
end

function Bubble:BallToDirtCollision()
    local dirt = self:GetParent():GetParent():GetChild("Dirt"):GetChildren()
    
    for stain, hDist, vDist, tileID in self:CollisionPass(dirt) do
        self:GetLayer():GetParent().Score = self:GetLayer():GetParent().Score + 100 * (self.Health+1)
        stain:Emancipate()
    end
end

function Bubble:BallToInteractableCollision()
    local interactables = self:GetParent():GetParent():GetChild("Interactables"):GetChildren()
    
    for interactable, hDist, vDist, tileID in self:CollisionPass(interactables) do
        if interactable:IsA("Refill") then
            interactable:Emancipate()
            self:PlaySFX("Refill", 1, 3)
            self.Health = math.min(self.Health + 1, 9)
            self.DrawScale = V{1.2,1.2}
            
            self:GetLayer():GetChild("PlusOne"):Emit{
                Position = self.Position + V{8, -8},
                Size = V{12, 12},
                SizeVelocity = V{20, 20},
                SizeAcceleration = V{-100, -100},
                Velocity = V{0, -20, 0},
                Acceleration = V{0, 60, 0},
                ColorVelocity = V{0, 0, 0, -1},
                RotVelocity = 1,
                Rotation = math.random(-1, 1) / 8,
                AnchorPoint = V{0.5, 0.5},
                Duration = 0.5
            }
        end
    end
end

return Bubble