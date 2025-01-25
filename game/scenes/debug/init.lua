-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()

local gameLayer = scene:GetLayer("Gameplay")

local decelSpeed = 0.01

local balls = gameLayer:Adopt(Prop.new{
    Visible = false
})

local cueStick
local cueBubble = balls:Adopt(Bubble.new():Properties{
    Name = "Cue",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{0, 0},
    Direction = V{0, 0},
    Velocity = 0,

    Update = function(self)
        if self.Velocity > 0 then
            self.Position = self.Position + (self.Direction * self.Velocity)
            self.Velocity = self.Velocity - decelSpeed
        end

        -- updating framevalues
        self.FramesSinceHit = self.FramesSinceHit + 1
    end,

    OnSelectStart = function(self)
        if self.Velocity <= 0 then
            cueStick.Visible = not cueStick.Visible
            cueStick.Active = not cueStick.Active
        end
    end,

    OnSelectEnd = function(self)
        if cueStick.Active and (gameLayer:GetMousePosition() - self.Position):Magnitude() >= 30 then
            self.Velocity = cueStick.Power
            self.Direction = (self.Position - cueStick.Position):Normalize()
            self.FramesSinceHit = 0
        end

        cueStick.Visible = false
        cueStick.Active = false
    end
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
    end
})

local bubble1 = balls:Adopt(Gui.new{
    Name = "Test",
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{40, 0},
    Direction = V{0, 0},
    Velocity = 0,

    Update = function(self)
        local bubbles = self:GetParent():GetChildren()

        if self.Velocity <= 0 then
            local collisions = {}
            
            for i, ball in ipairs(bubbles) do
                if ball.Name ~= self.Name and (ball.Position - self.Position):Magnitude() < Bubble.Threshold then
                    collisions[#collisions + 1] = ball
                end
            end

            if #collisions > 0 then
                local bubble = collisions[1]
                local vector = self.Position - bubble.Position

                self.Direction = vector:Normalize()
                self.Velocity = bubble.Velocity * 0.8
            end
        end

        if self.Velocity > 0 then
            self.Position = self.Position + (self.Direction * self.Velocity)
            self.Velocity = self.Velocity - decelSpeed
        end
    end
})

return scene