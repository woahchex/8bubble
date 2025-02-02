local Dirt = {
    -- properties
    Name = "Dirt",        -- Easy identifier
    Solid = true,

    -- internal properties
    _super = "Gui",      -- Supertype
    _global = true
}

function Dirt.new()
    local myObj = Dirt:SuperInstance()
    return Dirt:Connect(myObj)
end

function Dirt:Clean()
    self:Emancipate()
end


return Dirt