local Bubble = {
    -- properties
    Name = "Bubble",        -- Easy identifier
    Test = true,
    Threshold = 16,

    -- internal properties
    _super = "Gui",      -- Supertype
    _global = true
}

function Bubble.new()
    local myObj = Bubble:SuperInstance()

    return Bubble:Connect(myObj)
end

function Bubble:Update(dt)
    
end

function Bubble:Draw(tx, ty)
    return Prop.Draw(self, tx, ty)
end

return Bubble