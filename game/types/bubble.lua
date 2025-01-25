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
    Threshold = 16,

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

function Bubble:Update(dt)
    
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

return Bubble