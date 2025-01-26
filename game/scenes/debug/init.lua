
local levelNum = 1

-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()
scene.Name = "debug"
scene.Score = 0

-- background
local gameLayer = scene:GetLayer("Gameplay")
local tilemapLayer = scene:GetLayer("TilemapLayer")
local scoreLayer = scene:GetLayer("Score")

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

local cueStick
local scoreboard
local transition

local balls = gameLayer:Adopt(Prop.new{
    Name = "Balls",
    Visible = false,
    BallsMoving = 0,
    CheckEnd = false,
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

        if self.CheckEnd and self.BallsMoving == 0 then
            self.CheckEnd = false
            self.LevelEnd = true

            cueStick:Disable()
            scoreboard:Display()
        end
    end,

    EndLevel = function(self)
        self.CheckEnd = true
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

local cueGuide
local visibleCueStick
cueStick = gameLayer:Adopt(Gui.new{
    Name = "Cue Stick",
    Size = V{10, 40},
    AnchorPoint = V{0.5, 0},
    Position = V{0, 30},
    Visible = false,
    Active = false,
    Enabled = false,
    Division = (math.pi / 12),
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
            -- self.Visible = true
            visibleCueStick.GoalColor = V{1,1,1,1}
            self.Enabled = false
        end
    end,

    Enable = function(self)
        self.Active = true
        self.Enabled = true
    end,

    Disable = function(self)
        -- self.Visible = false
        visibleCueStick.GoalColor = V{1,1,1,0}
        self.Active = false
        self.Enabled = false
    end
})

visibleCueStick = gameLayer:Adopt(Gui.new{
    Name = "VisibleCue",
    Texture = Texture.new("game/scenes/title/cue-stick.png"),
    Size = V{12,50},
    GoalColor = V{1,1,1,1},
    AnchorPoint = V{0.5,0},
    Update = function (self)
        
        self.Position = self.Position:Lerp(cueStick.Position, 0.2)
        self.Color = self.Color:Lerp(self.GoalColor, 0.2)
        self.Rotation = math.lerp(self.Rotation, cueStick.Rotation, 1)
    end
})

cueGuide = scene:GetLayer("BG"):Adopt(Gui.new{
    Name = "CueGuide",
    Texture = Animation.new("game/scenes/title/cue-guide.png",1,8),
    Size = V{2,512},
    GoalColor = V{1,1,1,1},
    AnchorPoint = V{0.5,1},
    Color = V{1,1,1,1},
    Update = function (self)
        self.Position = visibleCueStick.Position
        self.Rotation = visibleCueStick.Rotation
        self.Color[4] = visibleCueStick.Color[4]/2
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
        if not balls.LevelEnd then
            cueStick:Enable()
        end
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
            visibleCueStick.Position = cueBubble.Position
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

local dirt1 = dirt:Adopt(Dirt.new():Properties{
    Position = V{-16 * 13, 0},
    Size = V{16, 16 * 4},
    Color = Vector.Hex"59a4ff",
    DrawInForeground = true
})


-- interactables
local refill1 = interactables:Adopt(Refill.new():Properties{

})


-- level end screen
local shape4

scoreboard = scoreLayer:Adopt(Gui.new{
    Name = "Scoreboard",
    Size = V{280, 150},
    Position = V{0, 350},
    AnchorPoint = V{0.5, 0.5},
    Texture = Texture.new("game/assets/images/scoreboard.png"),
    Idle = false,
    Visible = true,
    Active = false,
    
    Update = function(self)
        if self.Idle then
            self.Position = self.Position:Lerp(V{0, 0 + (math.sin(Chexcore._clock) * 2)}, 0.1) -- y: math.sin(Chexcore._clock) * 2
        else
            self.Position = self.Position:Lerp(V{0, 350}, 0.1)

            if (V{0, 350} - self.Position):Magnitude() < 0.1 then
                self.Visible = false
                self.Active = false
            end
        end
    end,

    Display = function(self)
        self.Idle = true

        self.Visible = true
        self.Active = true

        local elements = self:GetParent():GetChildren()
        for i, element in ipairs(elements) do
            if element ~= self and element.Name ~= "Transition" then
                element:Display()
                print(element.Name)
            end
        end
    end,

    Undisplay = function(self)
        self.Idle = false

        local elements = self:GetParent():GetChildren()
        for i, element in ipairs(elements) do
            print(element.Name)
            if element ~= self and element.Name ~= "Shape" and element.Name ~= "Transition" then
                element:Undisplay()
            end
        end
    end
        
})

local scoreText = scoreLayer:Adopt(Text.new{
    Name = "Score",
    Text = "HIGH SCORE: ",
    FontSize = 24,
    TextColor = V{1,1,1},
    Size = V{300,100},
    Position = V{0, 0},
    AnchorPoint = V{0.5, 0.5},
    AlignMode = "center",
    Font = Font.new("chexcore/assets/fonts/futura.ttf", 24, "mono"),
    DrawInForeground = true,

    Update = function (self)
        if self.Idle then
            self.Position = self.Position:Lerp(V{0, 0 + (math.sin(Chexcore._clock) * 2)}, 0.1) -- y: math.sin(Chexcore._clock) * 2
        else
            self.Position = self.Position:Lerp(V{0, 350}, 0.1)

            if (V{0, 350} - self.Position):Magnitude() < 0.1 then
                self.Visible = false
                self.Active = false
            end
        end
    end,

    Display = function(self)
        if (scene.Score > _G.highScores[levelNum]) then
            _G.highScores[levelNum] = scene.Score
        end

        self.Text = "HIGH SCORE:\n"..tostring(_G.highScores[levelNum])
        self.Idle = true

        self.Visible = true
        self.Active = true
    end,

    Undisplay = function(self)
        self.Idle = false
    end
})

local playButton = scoreLayer:Adopt(Gui.new{
    Name = "Button",
    Size = V{24, 24},
    Position = V{60, 400},
    AnchorPoint = V{0.5, 0.5},
    Texture = Texture.new("game/scenes/title/play-button.png"),
    Idle = false,
    Visible = false,
    Active = false,
    
    Update = function(self)
        if self.Idle then
            self.Position = self.Position:Lerp(V{60, 50 + (math.sin(Chexcore._clock) * 2)}, 0.1) -- y: 
        else
            self.Position = self.Position:Lerp(V{60, 400}, 0.1)

            if (V{60, 400} - self.Position):Magnitude() < 0.1 then
                self.Visible = false
                self.Active = false
            end
        end
    end,

    Display = function(self)
        self.Idle = true

        self.Visible = true
        self.Active = true
    end,

    Undisplay = function(self)
        self.Idle = false
    end,

    OnSelectStart = function(self)
        transition:StartTransition()
        scoreboard:Undisplay()

        Timer.Schedule(2.5, function()
            -- Insert code to load new level
        end)
    end
})

local redoButton = scoreLayer:Adopt(Gui.new{
    Name = "Button",
    Size = V{24, 24},
    Position = V{-60, 400},
    AnchorPoint = V{0.5, 0.5},
    Texture = Texture.new("game/scenes/title/redo-button.png"),
    Idle = false,
    Visible = false,
    Active = false,
    
    Update = function(self)
        if self.Idle then
            self.Position = self.Position:Lerp(V{-60, 50 + (math.sin(Chexcore._clock) * 2)}, 0.1) -- y: 
        else
            self.Position = self.Position:Lerp(V{-60, 400}, 0.1)

            if (V{-60, 400} - self.Position):Magnitude() < 0.1 then
                self.Visible = false
                self.Active = false
            end
        end
    end,

    Display = function(self)
        self.Idle = true

        self.Visible = true
        self.Active = true
    end,

    Undisplay = function(self)
        self.Idle = false
    end,

    OnSelectStart = function(self)
        transition:StartTransition()
        scoreboard:Undisplay()

        Timer.Schedule(3.5, function()
            self:GetLayer():GetParent():Reload()
        end)
    end
})

transition = scoreLayer:Adopt(Prop.new{
    Name = "Transition",
    Visible = false,

    StartTransition = function(self)
        local shapes = self:GetChildren()

        local delay = 0.2

        for i, shape in ipairs(shapes)do
            Timer.Schedule(i * delay, function()
                local goalSize = V{1, 1} * ((3 / i) * 285)
                local rotSpeed = ((math.random(0, 1) * 2) -1) * (math.random() + 2)

                shape:Start(goalSize, rotSpeed)
            end)

            if i == 3 then
                delay = 0.4
            end
        end
    end
})

local shape1 = transition:Adopt(Gui.new{
    Name = "Shape",
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Color = Vector.Hex"5f82f8",
    Size = V{0, 0},
    GoalSize = V{0, 0},
    LerpSpeed = 0,
    Position = V{0, 0},
    AnchorPoint = V{0.5, 0.5},
    RotationSpeed = 0,
    DrawInForeground = true,
    Idle = true,

    Update = function(self)
        if not self.Idle then
            self.Size = self.Size:Lerp(self.GoalSize, self.LerpSpeed)
            self.Rotation = Chexcore._clock * self.RotationSpeed
        end
    end,

    Start = function(self, goalSize, rotSpeed)
        self.GoalSize = goalSize
        self.RotationSpeed = rotSpeed
        self.LerpSpeed = 0.05

        self.Idle = false
    end,
})

local shape2 = transition:Adopt(Gui.new{
    Name = "Shape",
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Color = Vector.Hex"59a4ff",
    Size = V{0, 0},
    GoalSize = V{0, 0},
    LerpSpeed = 0,
    Position = V{0, 0},
    AnchorPoint = V{0.5, 0.5},
    RotationSpeed = 0,
    DrawInForeground = true,
    Idle = true,

    Update = function(self)
        if not self.Idle then
            self.Size = self.Size:Lerp(self.GoalSize, self.LerpSpeed)
            self.Rotation = Chexcore._clock * self.RotationSpeed
        end
    end,

    Start = function(self, goalSize, rotSpeed)
        self.GoalSize = goalSize
        self.RotationSpeed = rotSpeed
        self.LerpSpeed = 0.05

        self.Idle = false
    end,
})

local shape3 = transition:Adopt(Gui.new{
    Name = "Shape",
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Color = Vector.Hex"fffba6",
    Size = V{0, 0},
    GoalSize = V{0, 0},
    LerpSpeed = 0,
    Position = V{0, 0},
    AnchorPoint = V{0.5, 0.5},
    RotationSpeed = 0,
    DrawInForeground = true,
    Idle = true,

    Update = function(self)
        if not self.Idle then
            self.Size = self.Size:Lerp(self.GoalSize, self.LerpSpeed)
            self.Rotation = Chexcore._clock * self.RotationSpeed
        end
    end,

    Start = function(self, goalSize, rotSpeed)
        self.GoalSize = goalSize
        self.RotationSpeed = rotSpeed
        self.LerpSpeed = 0.05

        self.Idle = false
    end,
})

shape4 = transition:Adopt(Gui.new{
    Name = "Shape",
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Color = Vector.Hex"000000",
    Size = V{1, 1} * 860,
    GoalSize = V{0, 0},
    LerpSpeed = 0.08,
    Position = V{0, 0},
    AnchorPoint = V{0.5, 0.5},
    RotationSpeed = 2,
    DrawInForeground = true,
    State = "Shrink",

    Update = function(self)
        if self.State ~= "Idle" then
            self.Size = self.Size:Lerp(self.GoalSize, self.LerpSpeed)
            self.Rotation = Chexcore._clock * self.RotationSpeed

            if self.State == "Shrink" and (self.GoalSize - self.Size):Magnitude() < 0.5 then
                self:Stop()
            end
        end
    end,

    Start = function(self, goalSize, rotSpeed)
        self.State = "Grow"

        self.GoalSize = V{1, 1} * 860
        self.LerpSpeed = 0.04
        self.Function = toCall
    end,

    Stop = function(self)
        self.State = "Idle"
    end
})

return scene