local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local function MakeDraggable(frame, dragHandle)
    local dragHandleObject = dragHandle or frame
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandleObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandleObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local Config = {
    Scale = 0.8,
    PositionY = 0.7,
    Color = Color3.fromRGB(0, 0, 0),
    TextOnCape = "NOIR",
    ImageId = "",
    UseImageTexture = false,
    Enabled = true,
    ModHPBar = false
}

if _G.NoirCapeConfig then
    for k, v in pairs(_G.NoirCapeConfig) do
        Config[k] = v
    end
else
    _G.NoirCapeConfig = Config
end

local function SaveConfig()
    for k, v in pairs(Config) do
        _G.NoirCapeConfig[k] = v
    end
end

local function ParseImageId(input)
    if not input or input == "" then return "" end
    if string.match(input, "^rbxassetid://") then
        return input
    end
    if string.match(input, "^%d+$") then
        return "rbxassetid://" .. input
    end
    return input
end

local CapeInstance = nil
local HeartsModule = nil
local currentHearts = {}
local heartbeatConnection = nil
local shakeLoop = nil
local currentMotor = nil
local renderConnection = nil

local function ResetCapeReferences()
    if currentMotor then
        currentMotor = nil
    end
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    if CapeInstance then
        CapeInstance = nil
    end
end

local function AnimateIn(object, duration)
    object.Visible = true
    object.BackgroundTransparency = 0.15
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15
    })
    tween:Play()
    return tween
end

local function AnimateOut(object, duration, callback)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        object.Visible = false
        if callback then callback() end
    end)
    return tween
end

local function ShakeGUI(object, intensity, duration)
    local originalPos = object.Position
    local elapsed = 0
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed >= duration then
            object.Position = originalPos
            connection:Disconnect()
            return
        end
        local offsetX = math.random(-intensity, intensity)
        local offsetY = math.random(-intensity, intensity)
        object.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offsetX, originalPos.Y.Scale, originalPos.Y.Offset + offsetY)
    end)
end

local function FadeInText(object, duration)
    object.TextTransparency = 1
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    tween:Play()
    return tween
end

local MinecraftHearts = {
    currentHearts = {},
    heartbeatConnection = nil,
    shakeLoop = nil,
    pGui = nil,
    isActive = false
}

function MinecraftHearts:hideDefaultUI()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end

function MinecraftHearts:drawPixel(container, x, y, color)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundColor3 = color
    f.Position = UDim2.new(0, x * 2, 0, y * 2)
    f.Size = UDim2.new(0, 2, 0, 2)
    f.Parent = container
    return f
end

function MinecraftHearts:createMinecraftHeart(parent, xPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 28, 0, 26)
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, xPos, 0, 0)
    container.Parent = parent
    
    local RED = Color3.fromRGB(220, 40, 40)
    local DARK_RED = Color3.fromRGB(140, 20, 20)
    local LIGHT_RED = Color3.fromRGB(255, 80, 80)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local GRAY = Color3.fromRGB(90, 90, 90)
    local DARK_GRAY = Color3.fromRGB(55, 55, 55)
    
    local heartMatrix = {
        {0,0,0,0,1,2,1,0,0,0,0,0,0,0},
        {0,0,0,1,2,3,2,1,0,0,0,0,0,0},
        {0,0,1,2,3,4,3,2,1,0,0,0,0,0},
        {0,1,2,3,4,4,4,3,2,1,0,0,0,0},
        {1,2,3,4,4,4,4,4,3,2,1,0,0,0},
        {1,2,3,4,4,4,4,4,3,2,1,0,0,0},
        {0,1,2,3,4,4,4,3,2,1,0,0,0,0},
        {0,0,1,2,3,4,3,2,1,0,0,0,0,0},
        {0,0,0,1,2,3,2,1,0,0,0,0,0,0},
        {0,0,0,0,1,2,1,0,0,0,0,0,0,0},
        {0,0,0,0,0,1,0,0,0,0,0,0,0,0}
    }
    
    local redPixels = {}
    local grayPixels = {}
    local halfPixels = {}
    
    for y = 1, 11 do
        for x = 1, 14 do
            local val = heartMatrix[y][x]
            if val > 0 then
                local redColor = RED
                if val == 1 then redColor = WHITE
                elseif val == 2 then redColor = LIGHT_RED
                elseif val == 3 then redColor = RED
                elseif val == 4 then redColor = DARK_RED
                end
                
                local redPixel = self:drawPixel(container, x-1, y-1, redColor)
                table.insert(redPixels, redPixel)
                
                local grayColor = GRAY
                if val == 4 then grayColor = DARK_GRAY end
                
                local grayPixel = self:drawPixel(container, x-1, y-1, grayColor)
                grayPixel.Visible = false
                table.insert(grayPixels, grayPixel)
                
                if x <= 7 then
                    local halfPixel = self:drawPixel(container, x-1, y-1, redColor)
                    halfPixel.Visible = false
                    table.insert(halfPixels, halfPixel)
                end
            end
        end
    end
    
    return {
        container = container,
        redPixels = redPixels,
        grayPixels = grayPixels,
        halfPixels = halfPixels,
        baseX = xPos,
        baseY = 0,
        currentY = 0,
        shakeTimer = 0,
        shakeAmount = 0,
        isShaking = false
    }
end

function MinecraftHearts:createHeartsUI()
    local old = self.pGui:FindFirstChild("Minecraft_Hearts_Logic_V21")
    if old then old:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Minecraft_Hearts_Logic_V21"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self.pGui
    
    local heartFrame = Instance.new("Frame")
    heartFrame.Name = "HeartFrame"
    heartFrame.Size = UDim2.new(0, 310, 0, 35)
    heartFrame.Position = UDim2.new(0.65, 0, 0.03, 0)
    heartFrame.BackgroundTransparency = 1
    heartFrame.Parent = screenGui
    
    local hearts = {}
    for i = 1, 10 do
        hearts[i] = self:createMinecraftHeart(heartFrame, (i - 1) * 28)
    end
    
    return hearts
end

function MinecraftHearts:updateColors(hp, max)
    local healthPercent = hp / max
    
    for i = 1, 10 do
        local heart = self.currentHearts[i]
        if heart then
            local heartPercent = i / 10
            local isFull = healthPercent >= heartPercent
            local isHalf = healthPercent >= (heartPercent - 0.05)
            
            if isFull then
                for _, p in pairs(heart.redPixels) do p.Visible = true end
                for _, p in pairs(heart.grayPixels) do p.Visible = false end
                for _, p in pairs(heart.halfPixels) do p.Visible = false end
            elseif isHalf then
                for _, p in pairs(heart.redPixels) do p.Visible = false end
                for _, p in pairs(heart.grayPixels) do p.Visible = true end
                for _, p in pairs(heart.halfPixels) do p.Visible = true end
            else
                for _, p in pairs(heart.redPixels) do p.Visible = false end
                for _, p in pairs(heart.grayPixels) do p.Visible = true end
                for _, p in pairs(heart.halfPixels) do p.Visible = false end
            end
        end
    end
end

function MinecraftHearts:startHeartShake(heart, isLowHealthMode)
    if not heart or heart.isShaking then return end
    
    local duration = math.random(900, 1800)
    local intensity = isLowHealthMode and math.random(3, 6) or math.random(1, 3)
    
    heart.shakeTimer = duration
    heart.shakeAmount = intensity
    heart.currentY = 0
    heart.isShaking = true
end

function MinecraftHearts:updateShakes()
    for _, heart in pairs(self.currentHearts) do
        if heart.isShaking then
            heart.shakeTimer = heart.shakeTimer - 1
            
            if heart.shakeTimer <= 0 then
                heart.container.Position = UDim2.new(0, heart.baseX, 0, heart.baseY)
                heart.isShaking = false
                heart.currentY = 0
            else
                local t = tick() * 10
                local offset = math.sin(t) * (heart.shakeAmount / 1.5)
                heart.currentY = offset
                heart.container.Position = UDim2.new(0, heart.baseX, 0, heart.baseY + offset)
            end
        end
    end
end

function MinecraftHearts:randomShake()
    for _, heart in pairs(self.currentHearts) do
        if not heart.isShaking and math.random(1, 200) == 1 then
            self:startHeartShake(heart, false)
        end
    end
end

function MinecraftHearts:lowHealthShake(healthPercent)
    if healthPercent < 0.4 then
        for _, heart in pairs(self.currentHearts) do
            if not heart.isShaking and math.random(1, 50) == 1 then
                self:startHeartShake(heart, true)
            end
        end
    end
end

function MinecraftHearts:initialize()
    self:hideDefaultUI()
    self.currentHearts = self:createHeartsUI()
    if not self.currentHearts then return end
    
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    local maxHealth = hum.MaxHealth
    self:updateColors(hum.Health, maxHealth)
    
    if self.heartbeatConnection then
        self.heartbeatConnection:Disconnect()
    end
    
    self.heartbeatConnection = hum.HealthChanged:Connect(function(newHealth)
        local max = hum.MaxHealth
        self:updateColors(newHealth, max)
    end)
end

function MinecraftHearts:startMainLoop()
    if self.shakeLoop then self.shakeLoop:Disconnect() end
    self.shakeLoop = RunService.Heartbeat:Connect(function()
        if self.currentHearts and #self.currentHearts > 0 then
            self:updateShakes()
            self:randomShake()
            
            local char = Player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    local healthPercent = hum.Health / hum.MaxHealth
                    self:lowHealthShake(healthPercent)
                end
            end
        end
    end)
end

function MinecraftHearts:enable()
    if self.isActive then return end
    self.pGui = Player:WaitForChild("PlayerGui")
    self:initialize()
    self:startMainLoop()
    self.isActive = true
end

function MinecraftHearts:disable()
    if not self.isActive then return end
    if self.heartbeatConnection then
        self.heartbeatConnection:Disconnect()
        self.heartbeatConnection = nil
    end
    if self.shakeLoop then
        self.shakeLoop:Disconnect()
        self.shakeLoop = nil
    end
    local old = self.pGui and self.pGui:FindFirstChild("Minecraft_Hearts_Logic_V21")
    if old then old:Destroy() end
    self.currentHearts = {}
    self.isActive = false
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
end

local function CreateNoirCape()
    if not Config.Enabled then
        if CapeInstance then CapeInstance:Destroy() end
        CapeInstance = nil
        if renderConnection then renderConnection:Disconnect() end
        renderConnection = nil
        return
    end
    
    local Character = Player.Character
    if not Character or not Character.Parent then return end
    
    local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
    local Root = Character:FindFirstChild("HumanoidRootPart")
    
    if not Torso or not Root then return end
    
    local oldCape = Character:FindFirstChild("NoirCape_V1")
    if oldCape then oldCape:Destroy() end
    
    if renderConnection then renderConnection:Disconnect() end

    local Cape = Instance.new("Part")
    Cape.Name = "NoirCape_V1"
    Cape.Parent = Character
    Cape.Size = Vector3.new(1.6 * Config.Scale, 2.6 * Config.Scale, 0.05) 
    Cape.CanCollide = false
    Cape.Massless = true
    Cape.Material = Enum.Material.SmoothPlastic
    Cape.Color = Config.Color

    local Mesh = Instance.new("SpecialMesh", Cape)
    Mesh.MeshType = Enum.MeshType.Wedge 
    Mesh.Scale = Vector3.new(1, 1, 0.1)
    
    for _, decal in pairs(Cape:GetChildren()) do
        if decal:IsA("Decal") then decal:Destroy() end
    end
    
    if Config.UseImageTexture and Config.ImageId and Config.ImageId ~= "" then
        local parsedId = ParseImageId(Config.ImageId)
        local decal = Instance.new("Decal", Cape)
        decal.Face = Enum.NormalId.Back
        decal.Texture = parsedId
        
        local decalFront = Instance.new("Decal", Cape)
        decalFront.Face = Enum.NormalId.Front
        decalFront.Texture = parsedId
        
        local decalRight = Instance.new("Decal", Cape)
        decalRight.Face = Enum.NormalId.Right
        decalRight.Texture = parsedId
        
        local decalLeft = Instance.new("Decal", Cape)
        decalLeft.Face = Enum.NormalId.Left
        decalLeft.Texture = parsedId
        
        Cape.Color = Color3.fromRGB(255, 255, 255)
    end

    local oldGui = Cape:FindFirstChildOfClass("SurfaceGui")
    if oldGui then oldGui:Destroy() end
    
    local Gui = Instance.new("SurfaceGui", Cape)
    Gui.Face = Enum.NormalId.Back
    Gui.CanvasSize = Vector2.new(400, 600)
    Gui.PixelsPerStud = 50
    Gui.Adornee = Cape
    
    local Text = Instance.new("TextLabel", Gui)
    Text.Name = "TextLabel"
    Text.Size = UDim2.new(0.9, 0, 0.5, 0)
    Text.Position = UDim2.new(0.05, 0, 0.25, 0)
    Text.BackgroundTransparency = 1
    Text.Text = Config.TextOnCape
    Text.TextColor3 = Color3.fromRGB(255, 255, 255)
    Text.Font = Enum.Font.GothamBold
    Text.TextScaled = true
    Text.TextWrapped = true
    Text.Visible = not Config.UseImageTexture

    local Motor = Instance.new("Motor6D", Cape)
    Motor.Part0 = Torso
    Motor.Part1 = Cape
    currentMotor = Motor
    
    local offsetY = (Character:FindFirstChild("UpperTorso") and Config.PositionY) or (Config.PositionY + 0.5)
    local offsetZ = 0.5
    Motor.C0 = CFrame.new(0, offsetY, offsetZ)
    Motor.C1 = CFrame.new(0, 1.2 * Config.Scale, 0)

    CapeInstance = Cape
    
    renderConnection = RunService.RenderStepped:Connect(function()
        if not Cape or not Cape.Parent or not Character or not Character.Parent then return end
        local hum = Character:FindFirstChild("Humanoid")
        if not hum then return end
        
        if not Config.UseImageTexture and Cape then
            Cape.Color = Config.Color
        end
        
        local moveSpeed = Root.Velocity.Magnitude
        local timeTick = tick()
        local currentOffsetY = (Character:FindFirstChild("UpperTorso") and Config.PositionY) or (Config.PositionY + 0.5)
        
        if moveSpeed > 2 then
            local wave = math.sin(timeTick * 16) * 3
            Motor.C0 = Motor.C0:Lerp(CFrame.new(0, currentOffsetY, offsetZ) * CFrame.Angles(math.rad(-60 + wave), 0, 0), 0.15)
        else
            local idleSway = math.sin(timeTick * 2) * 5
            Motor.C0 = Motor.C0:Lerp(CFrame.new(0, currentOffsetY, offsetZ) * CFrame.Angles(math.rad(-10 + idleSway), 0, 0), 0.05)
        end
    end)
end

local function MakeNumberInput(parent, yPos, labelText, minVal, maxVal, increment, initial, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    FadeInText(label, 0.3)
    
    local decBtn = Instance.new("TextButton", frame)
    decBtn.Size = UDim2.new(0, 30, 0, 28)
    decBtn.Position = UDim2.new(0.55, 0, 0.5, -14)
    decBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    decBtn.Text = "-"
    decBtn.TextColor3 = Color3.new(1,1,1)
    decBtn.Font = Enum.Font.GothamBold
    decBtn.TextSize = 16
    Instance.new("UICorner", decBtn).CornerRadius = UDim.new(0, 6)
    
    local valueBox = Instance.new("TextBox", frame)
    valueBox.Size = UDim2.new(0, 50, 0, 28)
    valueBox.Position = UDim2.new(0.65, 0, 0.5, -14)
    valueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    valueBox.Text = tostring(initial)
    valueBox.TextColor3 = Color3.new(1,1,1)
    valueBox.Font = Enum.Font.Gotham
    valueBox.TextSize = 13
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)
    
    local incBtn = Instance.new("TextButton", frame)
    incBtn.Size = UDim2.new(0, 30, 0, 28)
    incBtn.Position = UDim2.new(0.85, 0, 0.5, -14)
    incBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    incBtn.Text = "+"
    incBtn.TextColor3 = Color3.new(1,1,1)
    incBtn.Font = Enum.Font.GothamBold
    incBtn.TextSize = 16
    Instance.new("UICorner", incBtn).CornerRadius = UDim.new(0, 6)
    
    local currentValue = initial
    
    local function setValue(newVal)
        newVal = math.round((math.clamp(newVal, minVal, maxVal)) / increment) * increment
        currentValue = newVal
        valueBox.Text = string.format("%.2f", newVal)
        callback(newVal)
        SaveConfig()
    end
    
    decBtn.MouseButton1Click:Connect(function() setValue(currentValue - increment) end)
    incBtn.MouseButton1Click:Connect(function() setValue(currentValue + increment) end)
    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if num then setValue(num) end
    end)
    
    return frame
end

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "NoirSettings"
ScreenGui.ResetOnSpawn = false

ScreenGui.Enabled = false
task.wait(0.05)
ScreenGui.Enabled = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 340)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(128, 0, 255)
Stroke.Thickness = 2

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BackgroundTransparency = 0.3
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NOIR CAPE"
Title.TextColor3 = Color3.fromRGB(128, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1
FadeInText(Title, 0.5)

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

MakeDraggable(MainFrame, Header)

local ScrollContainer = Instance.new("ScrollingFrame", MainFrame)
ScrollContainer.Size = UDim2.new(1, -16, 1, -50)
ScrollContainer.Position = UDim2.new(0, 8, 0, 45)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 310)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)

local Content = Instance.new("Frame", ScrollContainer)
Content.Size = UDim2.new(1, 0, 0, 310)
Content.BackgroundTransparency = 1

local toggleFrame = Instance.new("Frame", Content)
toggleFrame.Size = UDim2.new(1, 0, 0, 38)
toggleFrame.Position = UDim2.new(0, 0, 0, 0)
toggleFrame.BackgroundTransparency = 1

local toggleLabel = Instance.new("TextLabel", toggleFrame)
toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Bật/Tắt Áo Choàng"
toggleLabel.TextColor3 = Color3.new(1,1,1)
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.TextSize = 13
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", toggleFrame)
toggleBtn.Size = UDim2.new(0, 50, 0, 28)
toggleBtn.Position = UDim2.new(1, -60, 0.5, -14)
toggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(60, 60, 60)
toggleBtn.Text = Config.Enabled and "ON" or "OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    ShakeGUI(toggleBtn, 2, 0.1)
    Config.Enabled = not Config.Enabled
    toggleBtn.Text = Config.Enabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(60, 60, 60)
    SaveConfig()
    CreateNoirCape()
end)

local hpFrame = Instance.new("Frame", Content)
hpFrame.Size = UDim2.new(1, 0, 0, 38)
hpFrame.Position = UDim2.new(0, 0, 0, 42)
hpFrame.BackgroundTransparency = 1

local hpLabel = Instance.new("TextLabel", hpFrame)
hpLabel.Size = UDim2.new(0.6, 0, 1, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "Mod Pixel HP Bar"
hpLabel.TextColor3 = Color3.new(1,1,1)
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 13
hpLabel.TextXAlignment = Enum.TextXAlignment.Left

local hpBtn = Instance.new("TextButton", hpFrame)
hpBtn.Size = UDim2.new(0, 50, 0, 28)
hpBtn.Position = UDim2.new(1, -60, 0.5, -14)
hpBtn.BackgroundColor3 = Config.ModHPBar and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(60, 60, 60)
hpBtn.Text = Config.ModHPBar and "ON" or "OFF"
hpBtn.TextColor3 = Color3.new(1,1,1)
hpBtn.Font = Enum.Font.GothamBold
hpBtn.TextSize = 12
Instance.new("UICorner", hpBtn).CornerRadius = UDim.new(0, 6)

hpBtn.MouseButton1Click:Connect(function()
    ShakeGUI(hpBtn, 2, 0.1)
    Config.ModHPBar = not Config.ModHPBar
    hpBtn.Text = Config.ModHPBar and "ON" or "OFF"
    hpBtn.BackgroundColor3 = Config.ModHPBar and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(60, 60, 60)
    SaveConfig()
    
    if Config.ModHPBar then
        MinecraftHearts:enable()
    else
        MinecraftHearts:disable()
    end
end)

MakeNumberInput(Content, 82, "Độ Cao Áo", 0, 1.2, 0.05, Config.PositionY, function(val)
    Config.PositionY = val
    SaveConfig()
    if Config.Enabled then CreateNoirCape() end
end)

MakeNumberInput(Content, 125, "Kích Thước", 0.3, 1.2, 0.05, Config.Scale, function(val)
    Config.Scale = val
    SaveConfig()
    if Config.Enabled then CreateNoirCape() end
end)

local colorFrame = Instance.new("Frame", Content)
colorFrame.Size = UDim2.new(1, 0, 0, 38)
colorFrame.Position = UDim2.new(0, 0, 0, 168)
colorFrame.BackgroundTransparency = 1

local colorLabel = Instance.new("TextLabel", colorFrame)
colorLabel.Size = UDim2.new(0.4, 0, 1, 0)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Màu Áo"
colorLabel.TextColor3 = Color3.new(1,1,1)
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextSize = 13
colorLabel.TextXAlignment = Enum.TextXAlignment.Left

local colorPreview = Instance.new("Frame", colorFrame)
colorPreview.Size = UDim2.new(0, 40, 0, 28)
colorPreview.Position = UDim2.new(0.4, 0, 0.5, -14)
colorPreview.BackgroundColor3 = Config.Color
Instance.new("UICorner", colorPreview).CornerRadius = UDim.new(0, 6)

local colorPickerBtn = Instance.new("TextButton", colorFrame)
colorPickerBtn.Size = UDim2.new(0, 90, 0, 28)
colorPickerBtn.Position = UDim2.new(0.6, 0, 0.5, -14)
colorPickerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
colorPickerBtn.Text = "Chọn Màu"
colorPickerBtn.TextColor3 = Color3.new(1,1,1)
colorPickerBtn.Font = Enum.Font.Gotham
colorPickerBtn.TextSize = 11
Instance.new("UICorner", colorPickerBtn).CornerRadius = UDim.new(0, 6)

colorPickerBtn.MouseButton1Click:Connect(function()
    ShakeGUI(colorPickerBtn, 2, 0.1)
    local colorSettings = Instance.new("Frame", ScreenGui)
    colorSettings.Size = UDim2.new(0, 220, 0, 200)
    colorSettings.Position = UDim2.new(0.5, -110, 0.5, -100)
    colorSettings.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    colorSettings.BackgroundTransparency = 1
    Instance.new("UICorner", colorSettings).CornerRadius = UDim.new(0, 10)
    AnimateIn(colorSettings, 0.3)
    
    local rBox, gBox, bBox
    local function updateColor()
        local newColor = Color3.fromRGB(
            tonumber(rBox.Text) or 0,
            tonumber(gBox.Text) or 0,
            tonumber(bBox.Text) or 0
        )
        colorPreview.BackgroundColor3 = newColor
        Config.Color = newColor
        SaveConfig()
        if Config.Enabled and not Config.UseImageTexture then CreateNoirCape() end
    end
    
    local function makeRow(y, name)
        local frame = Instance.new("Frame", colorSettings)
        frame.Size = UDim2.new(0.9, 0, 0, 35)
        frame.Position = UDim2.new(0.05, 0, 0, y)
        frame.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.15, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamBold
        
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.25, 0, 0.7, 0)
        box.Position = UDim2.new(0.2, 0, 0.15, 0)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        box.Text = "128"
        box.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        
        local dec = Instance.new("TextButton", frame)
        dec.Size = UDim2.new(0.12, 0, 0.7, 0)
        dec.Position = UDim2.new(0.5, 0, 0.15, 0)
        dec.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dec.Text = "-"
        dec.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", dec).CornerRadius = UDim.new(0, 4)
        
        local inc = Instance.new("TextButton", frame)
        inc.Size = UDim2.new(0.12, 0, 0.7, 0)
        inc.Position = UDim2.new(0.65, 0, 0.15, 0)
        inc.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        inc.Text = "+"
        inc.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", inc).CornerRadius = UDim.new(0, 4)
        
        local function setValue(v)
            v = math.clamp(v, 0, 255)
            box.Text = tostring(v)
            updateColor()
        end
        
        box.FocusLost:Connect(function()
            local num = tonumber(box.Text)
            if num then setValue(num) end
        end)
        dec.MouseButton1Click:Connect(function()
            setValue((tonumber(box.Text) or 128) - 5)
        end)
        inc.MouseButton1Click:Connect(function()
            setValue((tonumber(box.Text) or 128) + 5)
        end)
        
        return box
    end
    
    rBox = makeRow(10, "R")
    gBox = makeRow(55, "G")
    bBox = makeRow(100, "B")
    
    rBox.Text = tostring(math.floor(Config.Color.R * 255))
    gBox.Text = tostring(math.floor(Config.Color.G * 255))
    bBox.Text = tostring(math.floor(Config.Color.B * 255))
    
    local close = Instance.new("TextButton", colorSettings)
    close.Size = UDim2.new(0.5, 0, 0, 35)
    close.Position = UDim2.new(0.25, 0, 0, 150)
    close.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    close.Text = "OK"
    close.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
    close.MouseButton1Click:Connect(function()
        AnimateOut(colorSettings, 0.2, function() colorSettings:Destroy() end)
    end)
end)

local textFrame = Instance.new("Frame", Content)
textFrame.Size = UDim2.new(1, 0, 0, 45)
textFrame.Position = UDim2.new(0, 0, 0, 210)
textFrame.BackgroundTransparency = 1

local textLabel = Instance.new("TextLabel", textFrame)
textLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Chữ trên áo"
textLabel.TextColor3 = Color3.new(1,1,1)
textLabel.Font = Enum.Font.Gotham
textLabel.TextSize = 13
textLabel.TextXAlignment = Enum.TextXAlignment.Left

local textInput = Instance.new("TextBox", textFrame)
textInput.Size = UDim2.new(0.55, 0, 0.5, 0)
textInput.Position = UDim2.new(0.4, 0, 0.25, 0)
textInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textInput.Text = Config.TextOnCape
textInput.TextColor3 = Color3.new(1,1,1)
textInput.PlaceholderText = "Nhập chữ..."
Instance.new("UICorner", textInput).CornerRadius = UDim.new(0, 6)

textInput.FocusLost:Connect(function()
    Config.TextOnCape = textInput.Text
    SaveConfig()
    if Config.Enabled then CreateNoirCape() end
end)

local texFrame = Instance.new("Frame", Content)
texFrame.Size = UDim2.new(1, 0, 0, 38)
texFrame.Position = UDim2.new(0, 0, 0, 258)
texFrame.BackgroundTransparency = 1

local texLabel = Instance.new("TextLabel", texFrame)
texLabel.Size = UDim2.new(0.6, 0, 1, 0)
texLabel.BackgroundTransparency = 1
texLabel.Text = "Chế độ Ảnh nền"
texLabel.TextColor3 = Color3.new(1,1,1)
texLabel.Font = Enum.Font.Gotham
texLabel.TextSize = 13
texLabel.TextXAlignment = Enum.TextXAlignment.Left

local texBtn = Instance.new("TextButton", texFrame)
texBtn.Size = UDim2.new(0, 50, 0, 28)
texBtn.Position = UDim2.new(1, -60, 0.5, -14)
texBtn.BackgroundColor3 = Config.UseImageTexture and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(60, 60, 60)
texBtn.Text = Config.UseImageTexture and "ON" or "OFF"
texBtn.TextColor3 = Color3.new(1,1,1)
texBtn.Font = Enum.Font.GothamBold
texBtn.TextSize = 12
Instance.new("UICorner", texBtn).CornerRadius = UDim.new(0, 6)

texBtn.MouseButton1Click:Connect(function()
    ShakeGUI(texBtn, 2, 0.1)
    Config.UseImageTexture = not Config.UseImageTexture
    texBtn.Text = Config.UseImageTexture and "ON" or "OFF"
    texBtn.BackgroundColor3 = Config.UseImageTexture and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(60, 60, 60)
    SaveConfig()
    if Config.Enabled then CreateNoirCape() end
end)

local imageFrame = Instance.new("Frame", Content)
imageFrame.Size = UDim2.new(1, 0, 0, 45)
imageFrame.Position = UDim2.new(0, 0, 0, 298)
imageFrame.BackgroundTransparency = 1

local imageLabel = Instance.new("TextLabel", imageFrame)
imageLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Text = "ID Ảnh (Texture)"
imageLabel.TextColor3 = Color3.new(1,1,1)
imageLabel.Font = Enum.Font.Gotham
imageLabel.TextSize = 12
imageLabel.TextXAlignment = Enum.TextXAlignment.Left

local imageInput = Instance.new("TextBox", imageFrame)
imageInput.Size = UDim2.new(0.55, 0, 0.5, 0)
imageInput.Position = UDim2.new(0.4, 0, 0.25, 0)
imageInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local displayId = Config.ImageId
if string.match(displayId, "^rbxassetid://(%d+)$") then
    displayId = string.match(displayId, "^rbxassetid://(%d+)$")
end
imageInput.Text = displayId
imageInput.TextColor3 = Color3.new(1,1,1)
imageInput.PlaceholderText = "Nhập ID ảnh (VD: 14751309243)"
Instance.new("UICorner", imageInput).CornerRadius = UDim.new(0, 6)

imageInput.FocusLost:Connect(function()
    local rawInput = imageInput.Text
    local parsedId = ParseImageId(rawInput)
    Config.ImageId = parsedId
    SaveConfig()
    if string.match(parsedId, "^rbxassetid://(%d+)$") then
        imageInput.Text = string.match(parsedId, "^rbxassetid://(%d+)$")
    else
        imageInput.Text = parsedId
    end
    if Config.Enabled and Config.UseImageTexture then CreateNoirCape() end
end)

Content.Size = UDim2.new(1, 0, 0, 350)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 350)

local minimized = false
local isClosing = false

MinimizeBtn.MouseButton1Click:Connect(function()
    ShakeGUI(MinimizeBtn, 3, 0.1)
    minimized = not minimized
    if minimized then
        TweenService:Create(ScrollContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, -16, 0, 0)
        }):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 300, 0, 40)
        }):Play()
    else
        ScrollContainer.Visible = true
        TweenService:Create(ScrollContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -16, 1, -50)
        }):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 340)
        }):Play()
    end
    MinimizeBtn.Text = minimized and "+" or "–"
end)

CloseBtn.MouseButton1Click:Connect(function()
    if isClosing then return end
    isClosing = true
    ShakeGUI(CloseBtn, 5, 0.15)
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1
    }):Play()
    
    task.wait(0.3)
    ScreenGui:Destroy()
    if CapeInstance then CapeInstance:Destroy() end
    if renderConnection then renderConnection:Disconnect() end
    MinecraftHearts:disable()
end)

MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(0, 280, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 300, 0, 340)
}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.15
}):Play()

Player.CharacterAdded:Connect(function(character)
    ResetCapeReferences()
    
    task.wait(0.5)
    if Config.Enabled then
        CreateNoirCape()
    end
    if Config.ModHPBar then
        if MinecraftHearts.isActive then
            MinecraftHearts:disable()
            task.wait(0.3)
        end
        MinecraftHearts:enable()
    end
end)

task.spawn(CreateNoirCape)

if Config.ModHPBar then
    task.wait(0.5)
    MinecraftHearts:enable()
end

local notif = Instance.new("Frame", ScreenGui)
notif.Size = UDim2.new(0, 200, 0, 40)
notif.Position = UDim2.new(0.8, -100, 0.8, 0)
notif.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
notif.BackgroundTransparency = 0.3
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

local notifText = Instance.new("TextLabel", notif)
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "NOIR CAPE LOADED"
notifText.TextColor3 = Color3.new(1,1,1)
notifText.Font = Enum.Font.GothamBold
notifText.TextSize = 14

TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -100, 0.75, 0)
}):Play()
task.wait(1.5)
TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    Position = UDim2.new(0.5, -100, 0.85, 0)
}):Play()
task.wait(0.3)
notif:Destroy()
