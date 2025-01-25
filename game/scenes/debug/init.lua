-- local RESOLUTION = V{160, 90}
local scene = GameScene.new()

local gameLayer = scene:GetLayer("Gameplay")

gameLayer:Adopt(Bubble.new():Properties{
    Size = V{16,16},
    AnchorPoint = V{0.5,0.5}
})


return scene