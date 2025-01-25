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
    local scene = Scene.new()
    local gameLayer = scene:AddLayer(Layer.new("Gameplay", 640, 360))

    -- scene.Camera.Zoom = 2




    return GameScene:Connect(scene)
end
------------------------------------------------

------------------ Methods ---------------------
function GameScene:Meow()
    print("meow!")
end
----------------------------------------

return GameScene