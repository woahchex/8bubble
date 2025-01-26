-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()

-- background


local gameLayer = scene:GetLayer("Gameplay")

local tilemapLayer = scene:GetLayer("TilemapLayer")

local balls = gameLayer:Adopt(Prop.new{
    Name = "Balls",
    Visible = false
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
    Name = "Cue",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{-20, 30},
    Direction = V{0, 0},
    Velocity = 0,
    Shader = Shader.new("game/assets/shaders/1px-black-outline.glsl"):Send("step", V{1,1}/V{32,32}*2),

    OnSelectStart = function(self)
        if self.Velocity <= 0 then
            cueStick.Visible = not cueStick.Visible
            cueStick.Active = not cueStick.Active
        end
    end,

    OnSelectEnd = function(self)
        if cueStick.Active and (gameLayer:GetMousePosition() - self.Position):Magnitude() >= 30 then
            self:PlaySFX("Serve")
            
            self.Velocity = cueStick.Power
            self.Direction = (self.Position - cueStick.Position):Normalize()
            self.FramesSinceHit = 0
        end

        cueStick.Visible = false
        cueStick.Active = false
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

cueStick = gameLayer:Adopt(Gui.new{
    Name = "Cue Stick",
    Size = V{10, 40},
    AnchorPoint = V{0.5, 0},
    Position = V{0, 30},
    Visible = false,
    Active = false,
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
    end,

    OnSelectStart = function(self)
        if self.Active then
            
            cueBubble.Velocity = self.Power
            cueBubble.Direction = (cueBubble.Position - cueStick.Position):Normalize()
            cueBubble.FramesSinceHit = 0

            self.Visible = false
            self.Active = false
            
        end
    end
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