-- require("chexcore.code.libs.nest").init({console = "3ds", scale=1})
-- love._console = "3ds"
require "chexcore"
-- love.mouse.setVisible(false)
-- some of the constructors are still somewhat manual but they'll get cleaned up !


-- Scenes contain all the components of the game
function love.load()
    Chexcore:AddType("game.types.gamescene")
    Chexcore:AddType("game.types.bubble")
    Chexcore:AddType("game.types.dirt")
    Chexcore:AddType("game.types.refill")

    local scene = require("game.scenes.title.init")
    Chexcore.MountScene(scene)


    -- print(player:ToString(true))
    -- You can unmount (or deactivate) a scene by using Chexcore.UnmountScene(scene)
end




