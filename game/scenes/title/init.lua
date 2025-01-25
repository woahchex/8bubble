local RESOLUTION = V{640, 360}
local scene = Scene.new()


local bgLayer = scene:AddLayer(Layer.new("BG", RESOLUTION.X, RESOLUTION.Y))

local bg = bgLayer:Adopt(Prop.new{Size = V{1000,1000},AnchorPoint=V{0.5,0.5}, Color=Vector.Hex"6b7bea"})

local spinny2 = bgLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Size = V{1100, 1100},
    AnchorPoint = V{0.5,0.5},
    Position = V{300,-300},
    Color = Vector.Hex"5f82f8",
    Update = function (self)
        self.Rotation = Chexcore._clock/8
    end
})

local spinny1 = bgLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Size = V{800, 800},
    AnchorPoint = V{0.5,0.5},
    Position = V{300,-300},
    Color = Vector.Hex"59a4ff",
    Update = function (self)
        self.Rotation = Chexcore._clock/4
    end
})

local spinny4 = bgLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Size = V{400, 400},
    AnchorPoint = V{0.5,0.5},
    Position = V{300,-300},
    Color = Vector.Hex"fffba6":AddAxis(0.25),
    Update = function (self)
        self.Rotation = Chexcore._clock/12
        self.Size = V{400,400}*(1+(math.sin(Chexcore._clock)+1)/8)
    end
})

local spinny3 = bgLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/septagon.png"),
    Size = V{400, 400},
    AnchorPoint = V{0.5,0.5},
    Position = V{300,-300},
    Color = Vector.Hex"fffba6",
    Update = function (self)
        self.Rotation = Chexcore._clock/12
        self.Size = V{400,400}*(1+(math.sin(Chexcore._clock/2)+1)/20)
    end
})

local logoLayer = scene:AddLayer(Layer.new("Logo", RESOLUTION.X, RESOLUTION.Y))

logoLayer:Adopt(require"game.types.logo")



local playBubble
local playButton = logoLayer:Adopt(Gui.new{
    Position = V{0,95},
    AnchorPoint = V{0.5,0.5},
    Size = V{64,64},
    GoalSize = V{64,64},
    Texture = Texture.new("game/scenes/title/play-button.png"),
    Hovered = false,
    Update = function (self)
        if not self.Hovered then
            self.Rotation = math.lerp(self.Rotation, math.sin(Chexcore._clock)/10, 0.2)
        else
            self.Rotation = math.lerp(self.Rotation, 0, 0.2)
        end
        self.Size = self.Size:Lerp(self.GoalSize, 0.2)
    end,
    OnHoverStart = function (self)
        self.GoalSize = V{70, 70}
        playBubble.GoalSize = V{160,160}
        self.Hovered = true
    end,
    OnHoverEnd = function (self)
        self.GoalSize = V{64,64}
        playBubble.GoalSize = V{128,128}
        self.Hovered = false
    end,
    OnSelectStart = function (self)
        self.Size = V{50,50}
        playBubble.GoalSize = V{180,180}
        self.GoalSize = V{60,60}
    end,
    OnSelectEnd = function (self)
        if self.Hovered then
            playBubble.Size2 = V{120,120}
            self.GoalSize = V{70,70}
        end
    end
})


local water1 = logoLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/water.png"),
    Size = V{256,256},
    Color = V{1,1,1,0.9},
    Update = function (self)
        self.Position = V{0,100} + (V{Chexcore._clock/6,0}%1)*256
    end
})
local water2 = logoLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/water.png"),
    Size = V{256,256},
    Color = V{1,1,1,0.9},
    Update = function (self)
        self.Position = V{-256,100} + (V{Chexcore._clock/6,0}%1)*256
    end
})
local water3 = logoLayer:Adopt(Prop.new{
    Texture = Texture.new("game/scenes/title/water.png"),
    Size = V{256,256},
    Color = V{1,1,1,0.9},
    Update = function (self)
        self.Position = V{-512,100} + (V{Chexcore._clock/6,0}%1)*256
    end
})

playBubble = logoLayer:Adopt(Prop.new{
    Position = V{0,100},
    AnchorPoint = V{0.5,0.5},
    Size = V{128,128},
    Color = V{1,1,1,0.9},
    Texture = Canvas.new(128,128),
    Tint = Texture.new("game/scenes/title/menu-bubble-tint.png"),
    White = Texture.new("game/scenes/title/menu-bubble-white.png"),
    Pink = Texture.new("game/scenes/title/menu-bubble-pink.png"),
    Green = Texture.new("game/scenes/title/menu-bubble-green.png"),
    GoalSize = V{128,128},
    Hovered = false,
    Update = function (self)
        self.Size2 = (self.Size2 or self.Size):Lerp(self.GoalSize,0.025)
        self.Size = self.Size2 + V{20,20} + V{10,10}*V{math.sin(Chexcore._clock), math.cos(Chexcore._clock/2)}
    end,
    Draw = function(self,tx,ty)
    
        self.Texture:Activate()
        love.graphics.clear()
        love.graphics.setColor(1,1,1)
        


            self.Green:DrawToScreen(
                64,
                64,
                self.Rotation + math.sin(Chexcore._clock/2),
                96,
                96,
                0.5,
                0.5
            )

            self.Pink:DrawToScreen(
                64,
                64,
                self.Rotation + math.cos(Chexcore._clock/3)/8,
                96,
                96,
                0.5,
                0.5
            )

            self.White:DrawToScreen(
                64,
                64,
                self.Rotation + math.sin(Chexcore._clock/6)/4,
                96,
                96,
                0.5,
                0.5
            )
            -- child.Size = child.Size:Lerp(V_200_200, 0.1)

        self.Texture:Deactivate()
        
        Prop.Draw(self,tx,ty)
    end
})



local pillarOffsetL = V{-16,32}
local pillarOffsetR = V{16,32}
local pillar1 = logoLayer:Adopt(Prop.new{
    Position = V{-RESOLUTION.X/2, RESOLUTION.Y/2} + pillarOffsetL,
    AnchorPoint = V{0,1},
    Size = V{193,161},
    Texture = Texture.new("game/scenes/title/left-pillar.png")
})
local pillar2 = logoLayer:Adopt(Prop.new{
    Position = V{RESOLUTION.X/2, RESOLUTION.Y/2} + pillarOffsetR,
    AnchorPoint = V{1,1},
    Size = V{193,161},
    Texture = Texture.new("game/scenes/title/right-pillar.png")
})

logoLayer:Adopt(Gui.new{
    Texture = Texture.new("game/scenes/title/nitrochex.png"),
    Size = V{240, 24}/1.5,
    GoalSize = V{240, 24}/1.5,
    AnchorPoint = V{1,1},
    Position = V{320,180}-V{4,4},
    OnHoverStart = function (self)
        self.GoalSize = V{240, 24}
    end,
    OnHoverEnd = function (self)
        self.GoalSize = V{240, 24}/1.5
    end,
    Update = function (self)
        self.Size = self.Size:Lerp(self.GoalSize, 0.2)
    end
})
return scene