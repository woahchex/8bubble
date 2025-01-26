local Refill = {
    -- properties
    Name = "Refill",        -- Easy identifier
    Solid = true,
    Texture = Animation.new("game/assets/images/health-refill.png", 1, 11):Properties{
        Duration = 2,
    },

    -- internal properties
    _super = "Gui",      -- Supertype
    _global = true
}


function Refill.new()
    local refill = Refill:SuperInstance()
    refill.Size = V{16,16}

    return Refill:Connect(refill)
end

function Refill:Update(dt)
    
end

return Refill