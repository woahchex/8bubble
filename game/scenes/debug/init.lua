
local levelNum = _G.CurLevel

-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()
scene.Name = "debug"
scene.Score = 0

-- background
local tilemapLayer = scene:GetLayer("TilemapLayer")
local gameLayer = scene:GetLayer("Gameplay")
local scoreLayer = scene:GetLayer("Score")
local transitionLayer = scene:GetLayer("Transition")

local timeText
local cuePosition
local cueStick
local cueGuide
local scoreboard
local transition
local screenCover

--- level layout
tilemapLayer:Adopt(Tilemap.import(_G.tilemap,"game/assets/images/tilemap.png")):Properties{
    AnchorPoint = V{0.5, 0.5}
}

--- particles
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

local balls = gameLayer:Adopt(Prop.new{
    Name = "Balls",
    Visible = false,
    BallsMoving = 0,
    WaitForEnd = false,
    LevelEnd = false,

    Update = function(self)
        local numBalls = 0
        for i, ball in ipairs(self:GetChildren()) do
            if ball.Speed > 0 or ball.Health == 0 then
                numBalls = numBalls + 1
            end
        end

        self.BallsMoving = numBalls

        if self.WaitForEnd and self.BallsMoving == 0 then
            self.WaitForEnd = false
            self.LevelEnd = true

            cuePosition:Disable()
            scoreboard:Display()
            timeText:Stop()
        end
    end,

    CheckEnd = function(self)
        if not self:GetChild("Cue Bubble") or not self:GetChild("Bubble") then
            self.WaitForEnd = true
        end
    end,
})

local dirt = gameLayer:Adopt(Prop.new{
    Name = "Dirt",
    Visible = false
})

local interactables = gameLayer:Adopt(Prop.new{
    Name = "Interactables",
    Visible = false
})

local cueBubble = balls:Adopt(Bubble.new():Properties{
    Name = "Cue Bubble",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{-20, 30},
    Direction = V{0, 0},
    Speed = 0,
    Shader = Shader.new("game/assets/shaders/1px-black-outline.glsl"):Send("step", V{1, 1} / V{32, 32} * 2),

    HitBubble = function(self)
        self:PlaySFX("Serve")
        timeText:Start()
        
        self.Health = self.Health - 1
        self.Speed = cuePosition.Power
        self.Direction = (self.Position - cuePosition.Position):Normalize()
        self.FramesSinceHit = 0
    end,
})

local ballSpawns = tilemapLayer:GetChildren()[1]:GetChildren()[1]:GetChildren()
for _, spawn in ipairs(ballSpawns) do
    if spawn.Name == "Refill" then
        interactables:Adopt(Refill.new():Properties{
            Position = spawn.Position - V{390, 235},
        })
    elseif spawn.Name ~= "CueBubble" then
        balls:Adopt(Bubble.new():Properties{
            Name = "Bubble",
            Size = V{16, 16},
            AnchorPoint = V{0.5, 0.5},
            Position = spawn.Position - V{390, 235},
            Health = spawn.Health
        })
    else
        cueBubble.Position = spawn.Position - V{390, 235}
        cueBubble.Health = spawn.Health
    end
end

cuePosition = gameLayer:Adopt(Gui.new{
    Name = "Cue Position",
    Position = cueBubble.Position,
    Power = 0,
    AngleStep = math.pi / 32,
    PowerStep = 20,
    Visible = false,
    Active = false,
    Enabled = false,
    
    Update = function(self)
        local angle = gameLayer:GetMousePosition() - cueBubble.Position
        local cueAngle = math.round(-angle:ToAngle() / self.AngleStep) * self.AngleStep
        local cueDistance = math.max(self.PowerStep, math.min(angle:Magnitude(), self.PowerStep * 4))

        self.Power = math.floor(cueDistance / self.PowerStep)
        self.Rotation = cueAngle
        self.Position = cueBubble.Position + Vector.FromAngle(cueAngle + (math.pi / 2)) * (self.Power * self.PowerStep)
        
        if self.Enabled and balls.BallsMoving == 0 then
            cueStick.GoalColor = V{1, 1, 1, 1}
            cueStick.Position = cueBubble.Position
            self.Enabled = false
        end
    end,

    Enable = function(self)
        self.Active = true
        self.Enabled = true
    end,

    Disable = function(self)
        self.Active = false
        self.Enabled = false
        self.Position = cueBubble.Position
        cueStick.GoalColor = V{1, 1, 1, 0}
    end,
})

cueStick = gameLayer:Adopt(Gui.new{
    Name = "Cue Stick",
    Size = V{12, 50},
    Position = cueBubble.Position,
    AnchorPoint = V{0.5, 0},
    Color = V{1, 1, 1, 0},
    GoalColor = V{1, 1, 1, 0},
    Texture = Texture.new("game/scenes/title/cue-stick.png"),
    Retreat = false,
    RetreatPos = V{0, 0},
    
    Update = function (self)
        local targetPos = self.Retreat and self.RetreatPos or cuePosition.Position
        
        self.Position = self.Position:Lerp(targetPos, 0.2)
        self.Rotation = math.lerp(self.Rotation, cuePosition.Rotation, 1)
        self.Color = self.Color:Lerp(self.GoalColor, 0.2)
    end,
})

cueGuide = scene:GetLayer("BG"):Adopt(Gui.new{
    Name = "CueGuide",
    Size = V{2, 512},
    AnchorPoint = V{0.5, 1},
    Color = V{1, 1, 1, 1},
    GoalColor = V{1, 1, 1, 1},
    Texture = Animation.new("game/scenes/title/cue-guide.png", 1, 8),
    
    Update = function (self)
        self.Position = cueStick.Position
        self.Rotation = cueStick.Rotation
        self.Color[4] = cueStick.Color[4]/2
    end
})

local cueStickRadius = gameLayer:Adopt(Gui.new{
    Name = "Cue Stick Radius",
    Size = V{1, 1} * ((cuePosition.PowerStep * 10) + 60),
    Position = cueBubble.Position,
    AnchorPoint = V{0.5, 0.5},
    Visible = false,

    Update = function(self)
        self.Position = cueBubble.Position
    end,

    OnSelectStart = function(self)
        if not balls.LevelEnd and balls.BallsMoving == 0 then
            cueBubble:HitBubble()
            cuePosition:Disable()
            
            cueStick.RetreatPos = cueStick.Position
            cueStick.Position = cueBubble.Position
            cueStick.Retreat = true

            self.Size = V{0, 0}
        end
    end,

    OnHoverStart = function(self)
        if not (cuePosition.Active or balls.LevelEnd) then
            cuePosition:Enable()

            cueStick.Position = cueBubble.Position
            cueStick.Retreat = false
        end
    end,

    OnHoverEnd = function(self)
        cuePosition:Disable()
        
        self.Size = V{1, 1} * ((cuePosition.PowerStep * 10) + 60)
    end
})

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    local millis = math.floor((seconds % 1) * 1000)
    
    return string.format("%02d:%02d.%.03d", minutes, secs, millis)
end

local scoreText = scene:GetLayer("TilemapLayer"):Adopt(Text.new{
    Name = "Score",
    Text = "SCORE: 0",
    FontSize = 10,
    TextColor = V{1,1,1},
    Size = V{1000,100},
    Position = V{-185,-107},
    Font = Font.new("chexcore/assets/fonts/futura.ttf", 10, "mono"),
    Update = function (self)
        local new = "SCORE: "..tostring(scene.Score)
        if new ~= self.Text then
            self.FontSize = 12
        end
        self.Text = new
        
        self.FontSize = math.lerp(self.FontSize, 10, 0.2)
    end
})

timeText = scene:GetLayer("TilemapLayer"):Adopt(Text.new{
    Name = "Time",
    Size = V{1000,100},
    Position = V{-185,-97},
    Text = "TIME: 00:00:00",
    Font = Font.new("chexcore/assets/fonts/futura.ttf", 10, "mono"),
    FontSize = 10,
    TextColor = V{1,1,1},

    Update = function(self)
        self.Text = "TIME: "..tostring(formatTime((self.EndTime or Chexcore._clock) - (self.StartTime or Chexcore._clock))):sub(1, 8)
        self.FontSize = math.lerp(self.FontSize, 10, 0.2)
    end,

    Start = function(self)
        self.StartTime = self.StartTime or Chexcore._clock
    end,

    Stop = function(self)
        self.EndTime = Chexcore._clock
        self.FontSize = 12
    end
})

local dirt1 = dirt:Adopt(Dirt.new():Properties{
    Position = V{-16 * 13, 0},
    Size = V{16,48},
    Color = V{1,1,1},--Vector.Hex"59a4ff",
    Texture = Texture.new("game/scenes/title/dirt-right1.png"),
})

-- level end screen

scoreboard = scoreLayer:Adopt(Gui.new{
    Name = "Scoreboard",
    Size = V{280, 150},
    Position = V{0, 350},
    AnchorPoint = V{0.5, 0.5},
    Texture = Texture.new("game/assets/images/scoreboard.png"),
    Active = false,
    
    Update = function(self)
        self.Position = self.Position:Lerp(V{0, 0 + (math.sin(Chexcore._clock) * 2)}, 0.1)
    end,

    Display = function(self)
        self.Active = true

        local elements = self:GetChildren()
        for _, element in ipairs(elements) do
            element:Display()
        end
    end,
})

local finalScore = scoreboard:Adopt(Text.new{
    Name = "High Score",
    Size = V{1000, 100},
    Position = V{0, 350},
    AnchorPoint = V{0.5, 0.5},
    TextColor = V{1, 1, 1},
    Font = Font.new("chexcore/assets/fonts/futura.ttf", 24, "mono"),
    FontSize = 24,
    AlignMode = "center",
    Active = false,

    Update = function(self)
        self.Position = self.Position:Lerp(V{0, 0 + (math.sin(Chexcore._clock) * 2)}, 0.1)
    end,

    Display = function(self)
        if (scene.Score > (_G.highScores[levelNum] or 0)) then
            _G.highScores[levelNum] = scene.Score
        end

        self.Text = "HIGH SCORE: "..tostring(_G.highScores[levelNum])
        self.Active = true
    end
})

local nextButton = scoreboard:Adopt(ScoreButton.new():Properties{
    Name = "Next",
    Position = V{30, 400},
    Texture = Texture.new("game/scenes/title/play-button.png"),

    OnSelectStart = function(self)
        self.Size = V{20, 20}
        transition:StartTransition()

        Timer.Schedule(2.5, function()
            _G.CurLevel = _G.CurLevel+1
            _G.tilemap = "game.assets.tilemaps.".._G.LEVELS[_G.CurLevel]

            self:GetLayer():GetParent():Reload()
        end)
    end,

    Display = function(self)
        local win = true
        local bubbles = balls:GetChildren()

        for _, ball in ipairs(bubbles) do
            if ball.Name ~= "Cue Bubble" then
                win = false
            end
        end

        self.Active = win
    end
})

local redoButton = scoreboard:Adopt(ScoreButton.new():Properties{
    Name = "Redo",
    Position = V{-30, 400},
    Texture = Texture.new("game/scenes/title/redo-button.png"),

    OnSelectStart = function(self)
        self.Size = V{20, 20}
        transition:StartTransition()

        Timer.Schedule(2.5, function()
            self:GetLayer():GetParent():Reload()
        end)
    end,

    Display = function(self)
        self.Active = true
    end
})

local colors = {"5f82f8", "59a4ff", "fffba6"}
transition = transitionLayer:Adopt(Prop.new{
    Name = "Transition",
    Visible = false,

    StartTransition = function(self)
        local delay = 0.2
        for i, color in ipairs(colors) do
            Timer.Schedule(i * delay, function()
                local goalSize = V{1, 1} * ((3 / i) * 285)
                local rotSpeed = ((math.random(0, 1) * 2) -1) * (math.random() + 2)

                transition:Adopt(Spinner.new():Properties{
                    Color = Vector.Hex(color)
                }):Start(goalSize, rotSpeed, 0.05)
            end)
        end

        Timer.Schedule(1.5, function()
            screenCover:Start(V{860, 860}, 2, 0.04)
        end)
    end
})

screenCover = transition:Adopt(Spinner.new():Properties{
    Color = Vector.Hex"000000",
    Size = V{860, 860},
    LerpSpeed = 0.08,
    RotationSpeed = 4,
    Idle = false,
    DrawInForeground = true
})

return scene