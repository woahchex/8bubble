local Spinner = {
    -- properties
    Name = "Spinner",   -- Easy identifier
    Idle = true,

    Size = V{0, 0},
    Position = V{0, 0},
    AnchorPoint = V{0.5, 0.5},
    GoalSize = V{0, 0},
    LerpSpeed = 0.05,
    RotationSpeed = 0,
    Texture = Texture.new("game/scenes/title/septagon.png"),
    
    -- internal properties
    _super = "Gui",     -- Supertype
    _global = true
}

function Spinner.new()
    local myObj = Spinner:SuperInstance()
    myObj.Size = Spinner.Size
    myObj.Position = Spinner.Position
    myObj.AnchorPoint = Spinner.AnchorPoint

    return Spinner:Connect(myObj)
end

function Spinner:Update(dt)
    if not self.Idle then
        self.Size = self.Size:Lerp(self.GoalSize, self.LerpSpeed)
        self.Rotation = Chexcore._clock * self.RotationSpeed

        if (self.Size - self.GoalSize):Magnitude() < 1 then
            self.Idle = true
        end
    end
end

function Spinner:Start(goalSize, rotSpeed, lerpSpeed)
    self.GoalSize = goalSize
    self.RotationSpeed = rotSpeed
    self.LerpSpeed = lerpSpeed

    self.Idle = false
end

return Spinner