-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()

local gameLayer = scene:GetLayer("Gameplay")

local decelSpeed = 0.01

local balls = gameLayer:Adopt(Prop.new{
    Visible = false
})

local cueStick
local cueBubble = balls:Adopt(Bubble.new():Properties{
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
    end,

    OnSelectStart = function(self)
        cueStick.Visible = not cueStick.Visible
        cueStick.Active = not cueStick.Active
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
    end,

    OnSelectStart = function(self)
        if self.Active then
            cueBubble.Velocity = self.Power
            cueBubble.Direction = (cueBubble.Position - cueStick.Position):Normalize()

            self.Visible = false
            self.Active = false
        end
    end
})

local bubble = balls:Adopt(Gui.new{
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5},
    Position = V{40, 60},
    Direction = V{0, 0},
    Velocity = 0,

    Update = function(self)
        local bubbles = self:GetParent():GetChildren()

        if self.Velocity <= 0 then
            local magnitudes = {}

            for i, ball in ipairs(bubbles) do
                local vector = ball.Position - self.Position

                if vector:Magnitude() < Bubble.Distance then
                    magnitudes[#magnitudes + 1] = vector:Magnitude()
                end
            end
        end
    end
})

return scene