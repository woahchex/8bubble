local ScoreButton = {
    -- properties
    Name = "ScoreButton",   -- Easy identifier
    Size = V{24, 24},
    GoalSize = V{24, 24},
    AnchorPoint = V{0.5, 0.5},
    Active = false,
    
    -- internal properties
    _super = "Gui",     -- Supertype
    _global = true
}

function ScoreButton.new()
    local myObj = ScoreButton:SuperInstance()
    myObj.Size = ScoreButton.Size
    myObj.AnchorPoint = ScoreButton.AnchorPoint
    myObj.Active = ScoreButton.Active

    return ScoreButton:Connect(myObj)
end

function ScoreButton:Update(dt)
    self.Position = self.Position:Lerp(V{self.Position.X, 50 + (math.sin(Chexcore._clock) * 2)}, 0.1)
    self.Size = self.Size:Lerp(self.GoalSize, 0.1)
end

function ScoreButton:OnHoverStart()
    self.GoalSize = V{30, 30}
end

function ScoreButton:OnHoverEnd()
    self.GoalSize = V{24, 24}
end

return ScoreButton