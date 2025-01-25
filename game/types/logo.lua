local logoLayer = Prop.new()

local logo8 = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-8.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        
    end
})

local logoBubble = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-bubble.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 2*math.sin(Chexcore._clock) + self._parent.Position.Y/6
        self.Position.X = 2*math.cos(Chexcore._clock/2) + self._parent.Position.X/6
    end
})
local rate = 1.2
local logoE = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-e.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 8*math.sin(Chexcore._clock)
    end
})
local logoL = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-l.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 8*math.sin(Chexcore._clock+rate)
    end
})
local logoB3 = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-b3.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 8*math.sin(Chexcore._clock+rate*2)
    end
})
local logoB2 = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-b2.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 8*math.sin(Chexcore._clock+rate*3)
    end
})
local logoU = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-u.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 8*math.sin(Chexcore._clock+rate*4)
    end
})
local logoB1 = logoLayer:Adopt(Prop.new{
    Texture=Texture.new("game/scenes/title/logo-b1.png"),
    Size = V{200,200},
    AnchorPoint = V{0.5, 0.5},
    Update = function (self)
        self.Position.Y = 8*math.sin(Chexcore._clock+rate*5)
    end
})

local function shuffleList(inputList)
    local shuffled = {}
    for i = 1, #inputList do
        table.insert(shuffled, table.remove(inputList, math.random(#inputList)))
    end
    return shuffled
end


local V_200_200 = V{200,200}
logoLayer:Properties{
    DrawChildren = function() end,
    Texture = Canvas.new(400,400),
    Shader = Shader.new("game/assets/shaders/4px-black-outline.glsl"):Send("step", V{1,1}/400),
    Shader2 = Shader.new("game/assets/shaders/1px-black-outline.glsl"):Send("step", V{1,1}/200),
    Size = V{400,400},
    AnchorPoint = V{0.5,0.5},
    Draw = function (self,tx,ty)
        
        self.Texture:Activate()
        love.graphics.clear()
        love.graphics.setColor(1,1,1)
        
        if self.Shader2 then self.Shader2:Activate() end
        for _, child in ipairs(self:GetChildren()) do
            child.Texture:DrawToScreen(
                math.floor(child.Position[1]) + 200,
                math.floor(child.Position[2]) + 200,
                child.Rotation,
                child.Size[1],
                child.Size[2],
                child.AnchorPoint[1],
                child.AnchorPoint[2]
            )
            child.Size = child.Size:Lerp(V_200_200, 0.1)
        end
        if self.Shader2 then self.Shader2:Deactivate() end
        self.Texture:Deactivate()
        
        self.Position = self.Position + V{20,-50}
        Prop.Draw(self,tx,ty)
        self.Position = self.Position - V{20,-50}
    end,

    Update = function (self)
        self.Position = self.Position:Lerp(-Input.GetMousePosition()*V{1,0.5}*50, 0.1)
        
        if not Input:IsDown("m_1") then
            self.Size = self.Size:Lerp(V{400,400}, 0.1)
        elseif Input:JustPressed("m_1") then
            self.Size = V{450,450}
            for i, child in ipairs({self:GetChild(1),self:GetChild(8),self:GetChild(7),self:GetChild(6),self:GetChild(5),self:GetChild(4),self:GetChild(3)}) do
                Timer.Schedule(i/20, function ()
                    child.Size = child.Size * 1.15
                end)
            end
            
        else
            self.Size = self.Size:Lerp(V{425,425}, 0.05)
        end
    end
}




return logoLayer