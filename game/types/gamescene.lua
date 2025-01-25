local GameScene = {
    -- properties
    Name = "GameScene",        -- Easy identifier
    Test = true,

    -- internal properties
    _super = "Scene",      -- Supertype
    _global = true
}

---------------- Constructor -------------------
function GameScene.new()
    local myObj = Scene.new()
    myObj:AddLayer(Layer.new("Gameplay"), 640, 360)

    return GameScene:Connect(myObj)
end
------------------------------------------------

------------------ Methods ---------------------
function GameScene:Meow()
    print("meow!")
end
----------------------------------------

return GameScene