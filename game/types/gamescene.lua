local GameScene = {
    -- properties
    Name = "GameScene",        -- Easy identifier
    ScreenShake = 0,

    -- internal properties
    _super = "Scene",      -- Supertype
    _global = true
}

---------------- Constructor -------------------
function GameScene.new()
    local scene = Scene.new()

    local bgLayer = scene:AddLayer(Layer.new("BG", 640, 360))
    local tilemapLayer = scene:AddLayer(Layer.new("TilemapLayer", 640, 360))
    local gameLayer = scene:AddLayer(Layer.new("Gameplay", 640, 360))
    local scoreLayer = scene:AddLayer(Layer.new("Score", 640, 360))
    
    tilemapLayer.Canvases[1].Shader = Shader.new("game/assets/shaders/1px-black-outline.glsl"):Send("step",V{1,1}/V{640,360}/2)

    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-0.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},

    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-1.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Update = function (self)
            self.Position = V{0,0} + (V{Chexcore._clock/24,0}%1)*640
        end
    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-1.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Update = function (self)
            self.Position = V{-640,0} + (V{Chexcore._clock/24,0}%1)*640
        end
    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-2.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Update = function (self)
            self.Position = V{0,0} + (V{Chexcore._clock/60,0}%1)*640
        end
    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-2.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Update = function (self)
            self.Position = V{-640,0} + (V{Chexcore._clock/60,0}%1)*640
        end,
        
    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-3.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Update = function (self)
            self.Position = V{0,0} - (V{Chexcore._clock/100,0}%1)*640
        end
    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-3.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Update = function (self)
            self.Position = V{640,0} - (V{Chexcore._clock/100,0}%1)*640
        end
    })
    
    bgLayer:Adopt(Prop.new{
        Texture = Texture.new("game/assets/images/water-0.png"),
        AnchorPoint = V{0.5,0.5},
        Size = V{640,360},
        Color = V{1,1,1,0.8}
    })
    
    -- scene.Camera.Zoom = 2
    
    return GameScene:Connect(scene)
end
------------------------------------------------

------------------ Methods ---------------------
function GameScene:Meow()
    print("meow!")
end

function GameScene:Update(dt)
    self.ScreenShake = math.lerp(self.ScreenShake, 0, 0.1, 0.2)
    self.Camera.Position = Vector.FromAngle(math.random(1000000))*self.ScreenShake

    return Scene.Update(self,dt)
end

local function reload(module_name)
    -- Remove the module from the package.loaded table
    package.loaded[module_name] = nil
    -- Require the module again, forcing a fresh load
    return require(module_name)
end

function GameScene:Reload()
    Chexcore.UnmountScene(self)
    local scene = reload("game.scenes."..self.Name..".init")
    
    Chexcore.MountScene(scene)
end
----------------------------------------

return GameScene