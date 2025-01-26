-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()

-- background


local gameLayer = scene:GetLayer("Gameplay")

local tilemapLayer = scene:GetLayer("TilemapLayer")
Particles.new{
    Name = "BubbleParticle",
    AnchorPoint = V{0.5, 0.5},
    ParticleAnchorPoint = V{0.5, 1},
    Visible = true,
    Texture = Texture.new("chexcore/assets/images/empty.png"),
    RelativePosition = false,
    Color = V{0,0,0,0},
    Size = V{1, 1},

    ParticleSize = V{12, 12},
    ParticleColor = V{1,1,1,1},
    ParticleTexture = Texture.new("game/scenes/title/sphere.png"),
}:Nest(gameLayer)

local score = gameLayer:Adopt(Gui.new{
    
})

local balls = gameLayer:Adopt(Prop.new{
    Name = "Balls",
    Visible = false,
    BallsMoving = 0,
    LevelEnd = false,

    Update = function(self)
        local bubbles = self:GetChildren()

        local numBalls = 0
        for i, ball in ipairs(bubbles) do
            if ball.Velocity > 0 then
                numBalls = numBalls + 1
            end
        end

        self.BallsMoving = numBalls

        if self.LevelEnd and self.BallsMoving == 0 then
            self:DisplayScores()
        end
    end,

    EndLevel = function(self)
        self.LevelEnd = true
    end,

    DisplayScores = function(self)
        self.LevelEnd = false

        print("Level Done")
    end
})

local dirt = gameLayer:Adopt(Prop.new{
    Name = "Dirt",
    Visible = false
})

local interactables = gameLayer:Adopt(Prop.new{
    Name = "Interactables",
    Visible = false
})

Particles.new{
    Name = "PlusOne",
    AnchorPoint = V{0.5, 0.5},
    ParticleAnchorPoint = V{0.5, 1},
    Visible = true,
    Texture = Texture.new("chexcore/assets/images/empty.png"),
    RelativePosition = false,
    Color = V{0,0,0,0},
    Size = V{1, 1},

    ParticleSize = V{12, 12},
    ParticleColor = V{1,1,1,1},
    ParticleTexture = Texture.new("game/assets/images/plusone.png"),
}:Nest(gameLayer)

local cueStick
local cueBubble = balls:Adopt(Bubble.new():Properties{
    Name = "Cue Ball",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{-20, 30},
    Direction = V{0, 0},
    Velocity = 0,
    Shader = Shader.new("game/assets/shaders/1px-black-outline.glsl"):Send("step", V{1,1}/V{32,32}*2),

    HitBubble = function(self)
        self:PlaySFX("Serve")

        self.Velocity = cueStick.Power
        self.Direction = (self.Position - cueStick.Position):Normalize()
        self.FramesSinceHit = 0
    end,
})

cueStick = gameLayer:Adopt(Gui.new{
    Name = "Cue Stick",
    Size = V{10, 40},
    AnchorPoint = V{0.5, 0},
    Position = V{0, 30},
    Visible = false,
    Active = false,
    Enabled = false,
    Division = (math.pi / 8),
    Power = 0,
    Increment = 30,
    
    Update = function(self)
        local mouseAngle = (gameLayer:GetMousePosition() - cueBubble.Position)
        local mouseDistance = math.max(self.Increment, math.min(mouseAngle:Magnitude(), self.Increment * 3))

        local angle = math.round(-mouseAngle:ToAngle() / self.Division) * self.Division
        self.Power = math.floor(mouseDistance / self.Increment)

        self.Rotation = angle
        self.Position = cueBubble.Position + Vector.FromAngle(angle + (math.pi / 2)) * (self.Power * self.Increment)

        if self.Enabled and balls.BallsMoving == 0 then
            self.Visible = true
            self.Enabled = false
        end
    end,

    Enable = function(self)
        self.Active = true
        self.Enabled = true
    end,

    Disable = function(self)
        self.Visible = false
        self.Active = false
        self.Enabled = false
    end
})

local cueBallEnterRadius = gameLayer:Adopt(Gui.new{
    Name = "Enter Radius",
    Size = V{1, 1} * ((cueStick.Increment * 2) + 40),
    AnchorPoint = V{0.5, 0.5},
    Position = cueBubble.Position,
    Visible = false,

    Update = function(self)
        self.Position = cueBubble.Position
    end,

    OnHoverStart = function(self)
        cueStick:Enable()
    end
})

local cueBallExitRadius = gameLayer:Adopt(Gui.new{
    Name = "Exit Radius",
    Size = V{1, 1} * ((cueStick.Increment * 6) + 80),
    AnchorPoint = V{0.5, 0.5},
    Position = cueBubble.Position,
    Visible = false,
    BallsMoving = false,

    Update = function(self)
        self.Position = cueBubble.Position
    end,

    OnSelectStart = function(self)
        if cueStick.Active then
            cueBubble:HitBubble()
            cueStick:Disable()
        end
    end,

    OnHoverEnd = function(self)
        cueStick:Disable()
    end
})

local bubble1 = balls:Adopt(Bubble.new():Properties{
    Name = "Test",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{60, 30},
})

local bubble2 = balls:Adopt(Bubble.new():Properties{
    Name = "Test1",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{60, 10},
})

local bubble3 = balls:Adopt(Bubble.new():Properties{
    Name = "Test2",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{20, 30},
})

local bubble4 = balls:Adopt(Bubble.new():Properties{
    Name = "Test3",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{40, 30},
})

local bubble5 = balls:Adopt(Bubble.new():Properties{
    Name = "Test4",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{0, 30},
})

tilemapLayer:Adopt(Tilemap.import("game.assets.tilemaps.debug","game/assets/images/tilemap.png")):Properties{
    AnchorPoint = V{0.5,0.5}
}

local dirt1 = dirt:Adopt(Dirt.new():Properties{
    Position = V{-16 * 13, 0},
    Size = V{16, 16 * 4},
    Color = Vector.Hex"59a4ff",
    DrawInForeground = true
})


-- interactables
local refill1 = interactables:Adopt(Refill.new():Properties{

})











return scene