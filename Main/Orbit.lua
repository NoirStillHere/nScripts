--[[ 
    Orbit Script v1.2 
    by Noir 
]] 

repeat wait() until game.Players.LocalPlayer and game:IsLoaded() 

local player = game.Players.LocalPlayer 
local runService = game:GetService("RunService") 
local tweenService = game:GetService("TweenService") 
local userInputService = game:GetService("UserInputService") 
local camera = workspace.CurrentCamera 

local orbiting = false 
local targetPlayer = nil 
local currentPosition = "Normal" 
local currentMethod = "CFrame" 
local lastPosition = nil 
local isMinimized = false 
local currentTab = "orbit" 
local orbitSpeed = 16 

local isSpectating = false 
local spectateTarget = nil 
local spectateIndex = 1 
local spectatePlayerList = {} 

local walkSpeed = 16 
local jumpPower = 50 
local infJump = false 
local noClip = false 
local espEnabled = false 
local noclipConnection = nil 
local infJumpConnection = nil 
local espConnections = {} 
local espCharacterConnections = {} 

local dragging = false 
local dragStart = nil 
local startPos = nil 

local btnWidth = 140 
local btnHeight = 40 
local col1 = 15 
local col2 = 165 
local row1 = 15 
local row2 = 65 
local row3 = 115 
local row4 = 165 
local row5 = 215 

local orbitHeight = 280  
local settingsHeight = 280 
local minHeight = 280 

local screenGui = Instance.new("ScreenGui") 
screenGui.Name = "OrbitGUI" 
screenGui.ResetOnSpawn = false 
screenGui.Parent = player.PlayerGui 
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 

local specGui = Instance.new("ScreenGui") 
specGui.Name = "NoirSpectate" 
specGui.ResetOnSpawn = false 
specGui.Enabled = false 
specGui.Parent = player.PlayerGui 

local specFrame = Instance.new("Frame") 
specFrame.Size = UDim2.new(0, 260, 0, 120) 
specFrame.Position = UDim2.new(1, -275, 0.3, 0) 
specFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) 
specFrame.BackgroundTransparency = 0.05 
specFrame.BorderSizePixel = 2 
specFrame.BorderColor3 = Color3.fromRGB(128, 0, 255) 
specFrame.Parent = specGui 

local specCorner = Instance.new("UICorner") 
specCorner.CornerRadius = UDim.new(0, 12) 
specCorner.Parent = specFrame 

local specStroke = Instance.new("UIStroke") 
specStroke.Color = Color3.fromRGB(128, 0, 255) 
specStroke.Thickness = 2 
specStroke.Transparency = 0.2 
specStroke.Parent = specFrame 

local specAvatar = Instance.new("ImageLabel") 
specAvatar.Size = UDim2.new(0, 50, 0, 50) 
specAvatar.Position = UDim2.new(0, 10, 0, 10) 
specAvatar.BackgroundTransparency = 1 
specAvatar.Parent = specFrame 

local specAvatarCorner = Instance.new("UICorner") 
specAvatarCorner.CornerRadius = UDim.new(1, 0) 
specAvatarCorner.Parent = specAvatar 

local specInfo = Instance.new("TextLabel") 
specInfo.Size = UDim2.new(1, -70, 1, -20) 
specInfo.Position = UDim2.new(0, 70, 0, 10) 
specInfo.BackgroundTransparency = 1 
specInfo.TextScaled = true 
specInfo.TextXAlignment = Enum.TextXAlignment.Left 
specInfo.TextColor3 = Color3.fromRGB(200, 200, 200) 
specInfo.Font = Enum.Font.Gotham 
specInfo.TextSize = 12 
specInfo.Parent = specFrame 

local btnLeft = Instance.new("TextButton") 
btnLeft.Size = UDim2.new(0, 25, 0, 25) 
btnLeft.Position = UDim2.new(0, 10, 1, -30) 
btnLeft.Text = "<" 
btnLeft.BackgroundColor3 = Color3.fromRGB(40, 40, 45) 
btnLeft.BorderSizePixel = 2 
btnLeft.BorderColor3 = Color3.fromRGB(128, 0, 255) 
btnLeft.TextColor3 = Color3.fromRGB(255, 255, 255) 
btnLeft.Font = Enum.Font.GothamBold 
btnLeft.TextSize = 16 
btnLeft.Parent = specFrame 

local btnLeftCorner = Instance.new("UICorner") 
btnLeftCorner.CornerRadius = UDim.new(1, 0) 
btnLeftCorner.Parent = btnLeft 

local btnRight = Instance.new("TextButton") 
btnRight.Size = UDim2.new(0, 25, 0, 25) 
btnRight.Position = UDim2.new(0, 40, 1, -30) 
btnRight.Text = ">" 
btnRight.BackgroundColor3 = Color3.fromRGB(40, 40, 45) 
btnRight.BorderSizePixel = 2 
btnRight.BorderColor3 = Color3.fromRGB(128, 0, 255) 
btnRight.TextColor3 = Color3.fromRGB(255, 255, 255) 
btnRight.Font = Enum.Font.GothamBold 
btnRight.TextSize = 16 
btnRight.Parent = specFrame 

local btnRightCorner = Instance.new("UICorner") 
btnRightCorner.CornerRadius = UDim.new(1, 0) 
btnRightCorner.Parent = btnRight 

local btnStopSpec = Instance.new("TextButton") 
btnStopSpec.Size = UDim2.new(0, 50, 0, 25) 
btnStopSpec.Position = UDim2.new(1, -60, 1, -30) 
btnStopSpec.Text = "✕" 
btnStopSpec.BackgroundColor3 = Color3.fromRGB(40, 40, 45) 
btnStopSpec.BorderSizePixel = 2 
btnStopSpec.BorderColor3 = Color3.fromRGB(255, 100, 100) 
btnStopSpec.TextColor3 = Color3.fromRGB(255, 100, 100) 
btnStopSpec.Font = Enum.Font.GothamBold 
btnStopSpec.TextSize = 14 
btnStopSpec.Parent = specFrame 

local btnStopCorner = Instance.new("UICorner") 
btnStopCorner.CornerRadius = UDim.new(0, 6) 
btnStopCorner.Parent = btnStopSpec 

local mainFrame = Instance.new("Frame") 
mainFrame.Size = UDim2.new(0, 320, 0, orbitHeight) 
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200) 
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) 
mainFrame.BackgroundTransparency = 0.05 
mainFrame.BorderSizePixel = 2 
mainFrame.BorderColor3 = Color3.fromRGB(128, 0, 255) 
mainFrame.Active = true 
mainFrame.Draggable = false 
mainFrame.Parent = screenGui 

local mainCorner = Instance.new("UICorner") 
mainCorner.CornerRadius = UDim.new(0, 12) 
mainCorner.Parent = mainFrame 

local mainStroke = Instance.new("UIStroke") 
mainStroke.Color = Color3.fromRGB(128, 0, 255) 
mainStroke.Thickness = 2 
mainStroke.Transparency = 0.2 
mainStroke.Parent = mainFrame 

local header = Instance.new("Frame") 
header.Size = UDim2.new(1, 0, 0, 35) 
header.Position = UDim2.new(0, 0, 0, 0) 
header.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
header.BackgroundTransparency = 0.1 
header.BorderSizePixel = 2 
header.BorderColor3 = Color3.fromRGB(128, 0, 255) 
header.Parent = mainFrame 

local headerCorner = Instance.new("UICorner") 
headerCorner.CornerRadius = UDim.new(0, 12) 
headerCorner.Parent = header 

local headerStroke = Instance.new("UIStroke") 
headerStroke.Color = Color3.fromRGB(128, 0, 255) 
headerStroke.Thickness = 1.5 
headerStroke.Transparency = 0.3 
headerStroke.Parent = header 

header.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = true 
        dragStart = input.Position 
        startPos = mainFrame.Position 
        input.Changed:Connect(function() 
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end 
        end) 
    end 
end) 

userInputService.InputChanged:Connect(function(input) 
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
        local delta = input.Position - dragStart 
        if startPos then 
            mainFrame.Position = UDim2.new( 
                startPos.X.Scale,  
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y 
            ) 
        end 
    end 
end) 

userInputService.InputEnded:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = false 
    end 
end) 

local titleLabel = Instance.new("TextLabel") 
titleLabel.Size = UDim2.new(1, -120, 1, 0) 
titleLabel.Position = UDim2.new(0, 15, 0, 0) 
titleLabel.BackgroundTransparency = 1 
titleLabel.Text = "⚡ ORBIT CONTROLLER ⚡" 
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 255) 
titleLabel.Font = Enum.Font.GothamBold 
titleLabel.TextSize = 14 
titleLabel.TextXAlignment = Enum.TextXAlignment.Left 
titleLabel.TextYAlignment = Enum.TextYAlignment.Center 
titleLabel.Parent = header 

local tabButton = Instance.new("TextButton") 
tabButton.Size = UDim2.new(0, 30, 1, 0) 
tabButton.Position = UDim2.new(1, -100, 0, 0) 
tabButton.BackgroundTransparency = 1 
tabButton.Text = "⋯" 
tabButton.TextColor3 = Color3.fromRGB(200, 200, 200) 
tabButton.Font = Enum.Font.GothamBold 
tabButton.TextSize = 18 
tabButton.Parent = header 

local minimizeButton = Instance.new("TextButton") 
minimizeButton.Size = UDim2.new(0, 30, 1, 0) 
minimizeButton.Position = UDim2.new(1, -65, 0, 0) 
minimizeButton.BackgroundTransparency = 1 
minimizeButton.Text = "–" 
minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200) 
minimizeButton.Font = Enum.Font.GothamBold 
minimizeButton.TextSize = 20 
minimizeButton.Parent = header 

local closeButton = Instance.new("TextButton") 
closeButton.Size = UDim2.new(0, 30, 1, 0) 
closeButton.Position = UDim2.new(1, -35, 0, 0) 
closeButton.BackgroundTransparency = 1 
closeButton.Text = "×" 
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100) 
closeButton.Font = Enum.Font.GothamBold 
closeButton.TextSize = 18 
closeButton.Parent = header 

local contentContainer = Instance.new("Frame") 
contentContainer.Size = UDim2.new(1, 0, 1, -35) 
contentContainer.Position = UDim2.new(0, 0, 0, 35) 
contentContainer.BackgroundTransparency = 1 
contentContainer.Parent = mainFrame 

local orbitTab = Instance.new("ScrollingFrame") 
orbitTab.Size = UDim2.new(1, 0, 1, 0) 
orbitTab.BackgroundTransparency = 1 
orbitTab.ScrollBarThickness = 4 
orbitTab.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255) 
orbitTab.CanvasSize = UDim2.new(0, 0, 0, orbitHeight - 10) 
orbitTab.Parent = contentContainer 

local orbitContainer = Instance.new("Frame") 
orbitContainer.Size = UDim2.new(1, 0, 0, orbitHeight - 10) 
orbitContainer.BackgroundTransparency = 1 
orbitContainer.Parent = orbitTab 

local settingsTab = Instance.new("ScrollingFrame") 
settingsTab.Size = UDim2.new(1, 0, 1, 0) 
settingsTab.BackgroundTransparency = 1 
settingsTab.ScrollBarThickness = 4 
settingsTab.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255) 
settingsTab.Visible = false 
settingsTab.CanvasSize = UDim2.new(0, 0, 0, settingsHeight - 10) 
settingsTab.Parent = contentContainer 

local settingsContainer = Instance.new("Frame") 
settingsContainer.Size = UDim2.new(1, 0, 0, settingsHeight - 10) 
settingsContainer.BackgroundTransparency = 1 
settingsContainer.Parent = settingsTab 

local function createSidePanel(name, title, width, height) 
    local panel = Instance.new("Frame") 
    panel.Size = UDim2.new(0, width, 0, height) 
    panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20) 
    panel.BackgroundTransparency = 0.05 
    panel.BorderSizePixel = 2 
    panel.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    panel.Visible = false 
    panel.Parent = screenGui 
    panel.ClipsDescendants = true 

    local corner = Instance.new("UICorner") 
    corner.CornerRadius = UDim.new(0, 12) 
    corner.Parent = panel 

    local stroke = Instance.new("UIStroke") 
    stroke.Color = Color3.fromRGB(128, 0, 255) 
    stroke.Thickness = 2 
    stroke.Transparency = 0.2 
    stroke.Parent = panel 

    local headerPanel = Instance.new("Frame") 
    headerPanel.Size = UDim2.new(1, 0, 0, 35) 
    headerPanel.Position = UDim2.new(0, 0, 0, 0) 
    headerPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    headerPanel.BackgroundTransparency = 0.1 
    headerPanel.BorderSizePixel = 2 
    headerPanel.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    headerPanel.Parent = panel 

    local headerCorner = Instance.new("UICorner") 
    headerCorner.CornerRadius = UDim.new(0, 12) 
    headerCorner.Parent = headerPanel 

    local titleLabel = Instance.new("TextLabel") 
    titleLabel.Size = UDim2.new(1, -20, 1, 0) 
    titleLabel.Position = UDim2.new(0, 10, 0, 0) 
    titleLabel.BackgroundTransparency = 1 
    titleLabel.Text = title 
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200) 
    titleLabel.Font = Enum.Font.GothamBold 
    titleLabel.TextSize = 13 
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left 
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center 
    titleLabel.Parent = headerPanel 

    local closeBtn = Instance.new("TextButton") 
    closeBtn.Size = UDim2.new(0, 30, 1, 0) 
    closeBtn.Position = UDim2.new(1, -35, 0, 0) 
    closeBtn.BackgroundTransparency = 1 
    closeBtn.Text = "×" 
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100) 
    closeBtn.Font = Enum.Font.GothamBold 
    closeBtn.TextSize = 16 
    closeBtn.Parent = headerPanel 

    local scroll = Instance.new("ScrollingFrame") 
    scroll.Size = UDim2.new(1, 0, 1, -35) 
    scroll.Position = UDim2.new(0, 0, 0, 35) 
    scroll.BackgroundTransparency = 1 
    scroll.ScrollBarThickness = 6 
    scroll.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255) 
    scroll.Parent = panel 

    local layout = Instance.new("UIListLayout") 
    layout.Padding = UDim.new(0, 6) 
    layout.SortOrder = Enum.SortOrder.Name 
    layout.Parent = scroll 

    return panel, scroll, layout, closeBtn 
end 

local playerListFrame, playerListScrolling, playerListLayout, closePlayerBtn = createSidePanel("PlayerList", "📋 DANH SÁCH NGƯỜI CHƠI", 320, 280) 
local positionListFrame, positionListScrolling, positionListLayout, closePositionBtn = createSidePanel("PositionList", "📍 CHỌN VỊ TRÍ", 250, 280) 
local methodListFrame, methodListScrolling, methodListLayout, closeMethodBtn = createSidePanel("MethodList", "⚙️ CHỌN CHẾ ĐỘ ORBIT", 250, 200) 
local spectateListFrame, spectateListScrolling, spectateListLayout, closeSpectateBtn = createSidePanel("SpectateList", "👁️ CHỌN NGƯỜI CHƠI ĐỂ SPECTATE", 320, 280) 

local function createStyledButton(parent, posX, posY, text, color) 
    local btn = Instance.new("TextButton") 
    btn.Size = UDim2.new(0, btnWidth, 0, btnHeight) 
    btn.Position = UDim2.new(0, posX, 0, posY) 
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45) 
    btn.BackgroundTransparency = 0.2 
    btn.BorderSizePixel = 2 
    btn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    btn.Text = text 
    btn.TextColor3 = color or Color3.fromRGB(255, 255, 255) 
    btn.Font = Enum.Font.GothamBold 
    btn.TextSize = 11 
    btn.Parent = parent 

    local btnCorner = Instance.new("UICorner") 
    btnCorner.CornerRadius = UDim.new(0, 8) 
    btnCorner.Parent = btn 

    local btnStroke = Instance.new("UIStroke") 
    btnStroke.Color = Color3.fromRGB(128, 0, 255) 
    btnStroke.Thickness = 1.5 
    btnStroke.Transparency = 0.4 
    btnStroke.Parent = btn 

    return btn 
end 

local function createStyledInput(parent, posX, posY, placeholder, text) 
    local input = Instance.new("TextBox") 
    input.Size = UDim2.new(0, btnWidth, 0, btnHeight) 
    input.Position = UDim2.new(0, posX, 0, posY) 
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 40) 
    input.BackgroundTransparency = 0.2 
    input.BorderSizePixel = 2 
    input.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    input.PlaceholderText = placeholder 
    input.Text = text or "" 
    input.TextColor3 = Color3.fromRGB(255, 255, 255) 
    input.Font = Enum.Font.Gotham 
    input.TextSize = 12 
    input.Parent = parent 

    local inputCorner = Instance.new("UICorner") 
    inputCorner.CornerRadius = UDim.new(0, 8) 
    inputCorner.Parent = input 

    local inputStroke = Instance.new("UIStroke") 
    inputStroke.Color = Color3.fromRGB(128, 0, 255) 
    inputStroke.Thickness = 1.5 
    inputStroke.Transparency = 0.4 
    inputStroke.Parent = input 

    return input 
end 

local playerListButton = createStyledButton(orbitContainer, col1, row1, "👥 DANH SÁCH") 
local positionButton = createStyledButton(orbitContainer, col2, row1, "📍 VỊ TRÍ: Normal") 
local distanceBox = createStyledInput(orbitContainer, col1, row2, "Khoảng cách", "3") 
local orbitButton = createStyledButton(orbitContainer, col2, row2, "🔴 ORBIT OFF", Color3.fromRGB(255, 100, 100)) 
local methodButton = createStyledButton(orbitContainer, col1, row3, "⚙️ CHẾ ĐỘ: CFrame") 
local spectateButton = createStyledButton(orbitContainer, col2, row3, "👁️ SPECTATE", Color3.fromRGB(100, 100, 255)) 
local speedBox = createStyledInput(orbitContainer, col1, row4, "Speed Orbit", "16") 
speedBox.Visible = false 

local playerStatusLabel = Instance.new("TextLabel") 
playerStatusLabel.Size = UDim2.new(0, 290, 0, 32) 
playerStatusLabel.Position = UDim2.new(0, 15, 0, row5 + 5) 
playerStatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40) 
playerStatusLabel.BackgroundTransparency = 0.2 
playerStatusLabel.BorderSizePixel = 2 
playerStatusLabel.BorderColor3 = Color3.fromRGB(128, 0, 255) 
playerStatusLabel.Text = "👤 Chưa chọn người chơi" 
playerStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200) 
playerStatusLabel.Font = Enum.Font.Gotham 
playerStatusLabel.TextSize = 11 
playerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left 
playerStatusLabel.Parent = orbitContainer 

local playerStatusCorner = Instance.new("UICorner") 
playerStatusCorner.CornerRadius = UDim.new(0, 8) 
playerStatusCorner.Parent = playerStatusLabel 

local modeStatusLabel = Instance.new("TextLabel") 
modeStatusLabel.Size = UDim2.new(0, 290, 0, 32) 
modeStatusLabel.Position = UDim2.new(0, 15, 0, row5 + 42) 
modeStatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40) 
modeStatusLabel.BackgroundTransparency = 0.2 
modeStatusLabel.BorderSizePixel = 2 
modeStatusLabel.BorderColor3 = Color3.fromRGB(128, 0, 255) 
modeStatusLabel.Text = "⚙️ CFrame | 📍 Normal" 
modeStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200) 
modeStatusLabel.Font = Enum.Font.Gotham 
modeStatusLabel.TextSize = 11 
modeStatusLabel.TextXAlignment = Enum.TextXAlignment.Left 
modeStatusLabel.Parent = orbitContainer 

local modeStatusCorner = Instance.new("UICorner") 
modeStatusCorner.CornerRadius = UDim.new(0, 8) 
modeStatusCorner.Parent = modeStatusLabel 

local speedInput = createStyledInput(settingsContainer, col1, row1, "Tốc độ 16-200", "16") 
speedInput.Text = tostring(walkSpeed) 
local speedBtn = createStyledButton(settingsContainer, col2, row1, "SET SPEED") 

local jumpInput = createStyledInput(settingsContainer, col1, row2, "Sức nhảy 50-300", "50") 
jumpInput.Text = tostring(jumpPower) 
local jumpBtn = createStyledButton(settingsContainer, col2, row2, "SET JUMP") 

local infJumpBtn = createStyledButton(settingsContainer, col1, row3, "🔁 INF JUMP OFF", Color3.fromRGB(255, 100, 100)) 
local noClipBtn = createStyledButton(settingsContainer, col2, row3, "🌊 NO CLIP OFF", Color3.fromRGB(255, 100, 100)) 

local espBtn = createStyledButton(settingsContainer, col1, row4, "👁️ ESP OFF", Color3.fromRGB(255, 100, 100)) 
local resetBtn = createStyledButton(settingsContainer, col2, row4, "💀 FORCE RESET", Color3.fromRGB(255, 100, 100)) 

local flyBtn = createStyledButton(settingsContainer, col1, row5, "🕊️ LOAD FLY", Color3.fromRGB(100, 255, 100)) 
flyBtn.Size = UDim2.new(0, 290, 0, btnHeight) 

local function loadFly() 
    local flyScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirGui/refs/heads/main/Noir_Fly")) 
    if flyScript then 
        flyScript() 
        game:GetService("StarterGui"):SetCore("SendNotification", { 
            Title = "FLY V3"; 
            Text = "Đã tải script Fly!"; 
            Duration = 2; 
        }) 
    end 
end 

flyBtn.MouseButton1Click:Connect(loadFly) 

local function updateSpectateList() 
    for _, child in ipairs(spectateListScrolling:GetChildren()) do 
        if child:IsA("TextButton") then child:Destroy() end 
    end 

    spectatePlayerList = {} 
    for _, plr in ipairs(game.Players:GetPlayers()) do 
        if plr ~= player then 
            table.insert(spectatePlayerList, plr) 
            local btn = Instance.new("TextButton") 
            btn.Size = UDim2.new(1, -12, 0, 40) 
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
            btn.BackgroundTransparency = 0.1 
            btn.BorderSizePixel = 2 
            btn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
            btn.Text = plr.Name 
            btn.TextColor3 = Color3.fromRGB(255, 255, 255) 
            btn.Font = Enum.Font.Gotham 
            btn.TextSize = 12 
            btn.Parent = spectateListScrolling 

            local btnCorner = Instance.new("UICorner") 
            btnCorner.CornerRadius = UDim.new(0, 8) 
            btnCorner.Parent = btn 

            local btnStroke = Instance.new("UIStroke") 
            btnStroke.Color = Color3.fromRGB(128, 0, 255) 
            btnStroke.Thickness = 1 
            btnStroke.Transparency = 0.5 
            btnStroke.Parent = btn 

            btn.MouseButton1Click:Connect(function() 
                spectateTarget = plr 
                spectateListFrame.Visible = false 

                if not isSpectating then 
                    isSpectating = true 
                    specGui.Enabled = true 
                    if player.Character and player.Character:FindFirstChild("Humanoid") then 
                        camera.CameraSubject = player.Character.Humanoid 
                    end 
                end 
            end) 
        end 
    end 

    if #spectatePlayerList == 0 then 
        local emptyLabel = Instance.new("TextLabel") 
        emptyLabel.Size = UDim2.new(1, -12, 0, 40) 
        emptyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
        emptyLabel.BackgroundTransparency = 0.1 
        emptyLabel.BorderSizePixel = 2 
        emptyLabel.BorderColor3 = Color3.fromRGB(128, 0, 255) 
        emptyLabel.Text = "Không có người chơi khác" 
        emptyLabel.TextColor3 = Color3.fromRGB(200, 200, 200) 
        emptyLabel.Font = Enum.Font.Gotham 
        emptyLabel.TextSize = 12 
        emptyLabel.Parent = spectateListScrolling 
    end 

    spectateListScrolling.CanvasSize = UDim2.new(0, 0, 0, spectateListLayout.AbsoluteContentSize.Y + 10) 
end 

local function stopSpectate() 
    isSpectating = false 
    specGui.Enabled = false 
    spectateTarget = nil 
    if player.Character and player.Character:FindFirstChild("Humanoid") then 
        camera.CameraSubject = player.Character.Humanoid 
    end 
end 

local function nextSpectate() 
    if #spectatePlayerList == 0 then return end 
    local currentIndex = 1 
    for i, plr in ipairs(spectatePlayerList) do 
        if plr == spectateTarget then 
            currentIndex = i 
            break 
        end 
    end 
    local nextIndex = currentIndex % #spectatePlayerList + 1 
    spectateTarget = spectatePlayerList[nextIndex] 
end 

local function prevSpectate() 
    if #spectatePlayerList == 0 then return end 
    local currentIndex = 1 
    for i, plr in ipairs(spectatePlayerList) do 
        if plr == spectateTarget then 
            currentIndex = i 
            break 
        end 
    end 
    local prevIndex = (currentIndex - 2 + #spectatePlayerList) % #spectatePlayerList + 1 
    spectateTarget = spectatePlayerList[prevIndex] 
end 

local angle = 0 

local function updatePositionList() 
    for _, child in ipairs(positionListScrolling:GetChildren()) do 
        if child:IsA("TextButton") then child:Destroy() end 
    end 

    local positions = {"Sau lưng", "Trước mặt", "Trên đầu", "Dưới chân", "Normal"} 
    for _, pos in ipairs(positions) do 
        local btn = Instance.new("TextButton") 
        btn.Size = UDim2.new(1, -12, 0, 45) 
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
        btn.BackgroundTransparency = 0.1 
        btn.BorderSizePixel = 2 
        btn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
        btn.Text = pos 
        btn.TextColor3 = Color3.fromRGB(255, 255, 255) 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 13 
        btn.Parent = positionListScrolling 

        local btnCorner = Instance.new("UICorner") 
        btnCorner.CornerRadius = UDim.new(0, 8) 
        btnCorner.Parent = btn 

        local btnStroke = Instance.new("UIStroke") 
        btnStroke.Color = Color3.fromRGB(128, 0, 255) 
        btnStroke.Thickness = 1 
        btnStroke.Transparency = 0.5 
        btnStroke.Parent = btn 

        btn.MouseButton1Click:Connect(function() 
            currentPosition = pos 
            positionButton.Text = "📍 VỊ TRÍ: " .. pos 
            positionListFrame.Visible = false 

            if pos == "Normal" then 
                speedBox.Visible = true 
            else 
                speedBox.Visible = false 
            end 
            modeStatusLabel.Text = string.format("⚙️ %s | 📍 %s", currentMethod, currentPosition) 
        end) 
    end 

    positionListScrolling.CanvasSize = UDim2.new(0, 0, 0, positionListLayout.AbsoluteContentSize.Y + 10) 
end 

local function updateMethodList() 
    for _, child in ipairs(methodListScrolling:GetChildren()) do 
        if child:IsA("TextButton") then child:Destroy() end 
    end 

    local methods = {"CFrame", "Lerp", "BodyVelocity"} 
    for _, method in ipairs(methods) do 
        local btn = Instance.new("TextButton") 
        btn.Size = UDim2.new(1, -12, 0, 45) 
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
        btn.BackgroundTransparency = 0.1 
        btn.BorderSizePixel = 2 
        btn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
        btn.Text = method 
        btn.TextColor3 = Color3.fromRGB(255, 255, 255) 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 13 
        btn.Parent = methodListScrolling 

        local btnCorner = Instance.new("UICorner") 
        btnCorner.CornerRadius = UDim.new(0, 8) 
        btnCorner.Parent = btn 

        local btnStroke = Instance.new("UIStroke") 
        btnStroke.Color = Color3.fromRGB(128, 0, 255) 
        btnStroke.Thickness = 1 
        btnStroke.Transparency = 0.5 
        btnStroke.Parent = btn 

        btn.MouseButton1Click:Connect(function() 
            currentMethod = method 
            methodButton.Text = "⚙️ CHẾ ĐỘ: " .. method 
            methodListFrame.Visible = false 
            modeStatusLabel.Text = string.format("⚙️ %s | 📍 %s", currentMethod, currentPosition) 
        end) 
    end 

    methodListScrolling.CanvasSize = UDim2.new(0, 0, 0, methodListLayout.AbsoluteContentSize.Y + 10) 
end 

local function updatePlayerList() 
    for _, child in ipairs(playerListScrolling:GetChildren()) do 
        if child:IsA("TextButton") then child:Destroy() end 
    end 

    local hasPlayers = false 
    for _, plr in ipairs(game.Players:GetPlayers()) do 
        if plr ~= player then 
            hasPlayers = true 
            local btn = Instance.new("TextButton") 
            btn.Size = UDim2.new(1, -12, 0, 40) 
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
            btn.BackgroundTransparency = 0.1 
            btn.BorderSizePixel = 2 
            btn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
            btn.Text = plr.Name 
            btn.TextColor3 = Color3.fromRGB(255, 255, 255) 
            btn.Font = Enum.Font.Gotham 
            btn.TextSize = 12 
            btn.Parent = playerListScrolling 

            local btnCorner = Instance.new("UICorner") 
            btnCorner.CornerRadius = UDim.new(0, 8) 
            btnCorner.Parent = btn 

            local btnStroke = Instance.new("UIStroke") 
            btnStroke.Color = Color3.fromRGB(128, 0, 255) 
            btnStroke.Thickness = 1 
            btnStroke.Transparency = 0.5 
            btnStroke.Parent = btn 

            btn.MouseButton1Click:Connect(function() 
                targetPlayer = plr 
                playerStatusLabel.Text = "👤 " .. plr.Name 
                playerListFrame.Visible = false 
                updateStatusLabel() 
            end) 
        end 
    end 

    if not hasPlayers then 
        local emptyLabel = Instance.new("TextLabel") 
        emptyLabel.Size = UDim2.new(1, -12, 0, 40) 
        emptyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55) 
        emptyLabel.BackgroundTransparency = 0.1 
        emptyLabel.BorderSizePixel = 2 
        emptyLabel.BorderColor3 = Color3.fromRGB(128, 0, 255) 
        emptyLabel.Text = "Không có người chơi khác" 
        emptyLabel.TextColor3 = Color3.fromRGB(200, 200, 200) 
        emptyLabel.Font = Enum.Font.Gotham 
        emptyLabel.TextSize = 12 
        emptyLabel.Parent = playerListScrolling 
    end 

    playerListScrolling.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10) 
end 

local function updateHealthESP(plr, humanoid) 
    if not espConnections[plr] or not espConnections[plr].hpLabel then return end 
    local hp = humanoid.Health 
    local maxHp = humanoid.MaxHealth 
    local percent = math.floor((hp / maxHp) * 100) 
    local color = percent > 50 and Color3.fromRGB(100, 255, 100) or (percent > 25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 0, 0)) 
    espConnections[plr].hpLabel.Text = "❤️ " .. percent .. "%" 
    espConnections[plr].hpLabel.TextColor3 = color 
end 

local function createESP(plr) 
    if not espEnabled then return end 
    if plr == player then return end 
    if espConnections[plr] then return end 

    local function setupESPForCharacter() 
        local char = plr.Character 
        if not char then return end 

        local head = char:FindFirstChild("Head") 
        if not head then return end 

        local billboard = Instance.new("BillboardGui") 
        billboard.Name = "ESP_" .. plr.Name 
        billboard.Adornee = head 
        billboard.Size = UDim2.new(0, 150, 0, 40) 
        billboard.StudsOffset = Vector3.new(0, 2.5, 0) 
        billboard.AlwaysOnTop = true 
        billboard.Parent = screenGui 

        local frame = Instance.new("Frame") 
        frame.Size = UDim2.new(1, 0, 1, 0) 
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        frame.BackgroundTransparency = 0.4 
        frame.BorderSizePixel = 2 
        frame.BorderColor3 = Color3.fromRGB(128, 0, 255) 
        frame.Parent = billboard 

        local frameCorner = Instance.new("UICorner") 
        frameCorner.CornerRadius = UDim.new(0, 6) 
        frameCorner.Parent = frame 

        local nameLabel = Instance.new("TextLabel") 
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0) 
        nameLabel.Position = UDim2.new(0, 0, 0, 0) 
        nameLabel.BackgroundTransparency = 1 
        nameLabel.Text = plr.Name 
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
        nameLabel.Font = Enum.Font.GothamBold 
        nameLabel.TextSize = 12 
        nameLabel.TextScaled = true 
        nameLabel.Parent = frame 

        local hpLabel = Instance.new("TextLabel") 
        hpLabel.Size = UDim2.new(1, 0, 0.5, 0) 
        hpLabel.Position = UDim2.new(0, 0, 0.5, 0) 
        hpLabel.BackgroundTransparency = 1 
        hpLabel.Text = "❤️ 100%" 
        hpLabel.TextColor3 = Color3.fromRGB(100, 255, 100) 
        hpLabel.Font = Enum.Font.Gotham 
        hpLabel.TextSize = 10 
        hpLabel.TextScaled = true 
        hpLabel.Parent = frame 

        espConnections[plr] = { 
            billboard = billboard, 
            hpLabel = hpLabel, 
            nameLabel = nameLabel 
        } 

        local humanoid = char:FindFirstChild("Humanoid") 
        if humanoid then 
            local healthConnection 
            healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function() 
                if not espConnections[plr] then 
                    healthConnection:Disconnect() 
                    return 
                end 
                updateHealthESP(plr, humanoid) 
            end) 
            updateHealthESP(plr, humanoid) 

            if not espCharacterConnections[plr] then 
                espCharacterConnections[plr] = {} 
            end 
            table.insert(espCharacterConnections[plr], healthConnection) 
        end 
    end 

    if plr.Character and plr.Character:FindFirstChild("Head") then 
        setupESPForCharacter() 
    end 

    local charAddedConnection 
    charAddedConnection = plr.CharacterAdded:Connect(function(char) 
        if espConnections[plr] then 
            espConnections[plr].billboard:Destroy() 
            espConnections[plr] = nil 
        end 
        if espCharacterConnections[plr] then 
            for _, conn in ipairs(espCharacterConnections[plr]) do 
                conn:Disconnect() 
            end 
            espCharacterConnections[plr] = {} 
        end 
        wait(0.1) 
        setupESPForCharacter() 
    end) 

    if not espCharacterConnections[plr] then 
        espCharacterConnections[plr] = {} 
    end 
    table.insert(espCharacterConnections[plr], charAddedConnection) 
end 

local function removeESP(plr) 
    if espConnections[plr] then 
        espConnections[plr].billboard:Destroy() 
        espConnections[plr] = nil 
    end 

    if espCharacterConnections[plr] then 
        for _, conn in ipairs(espCharacterConnections[plr]) do 
            conn:Disconnect() 
        end 
        espCharacterConnections[plr] = nil 
    end 
end 

local function toggleESP() 
    espEnabled = not espEnabled 

    if espEnabled then 
        for _, plr in ipairs(game.Players:GetPlayers()) do 
            if plr ~= player then 
                createESP(plr) 
            end 
        end 
        espBtn.Text = "👁️ ESP ON" 
        espBtn.TextColor3 = Color3.fromRGB(100, 255, 100) 
        espBtn.BorderColor3 = Color3.fromRGB(0, 255, 0) 
    else 
        for _, plr in ipairs(game.Players:GetPlayers()) do 
            removeESP(plr) 
        end 
        espBtn.Text = "👁️ ESP OFF" 
        espBtn.TextColor3 = Color3.fromRGB(255, 100, 100) 
        espBtn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    end 
end 

local function updateStatusLabel() 
    if not targetPlayer then 
        playerStatusLabel.Text = "👤 Chưa chọn người chơi" 
        return 
    end 

    local char = targetPlayer.Character 
    if not char then 
        playerStatusLabel.Text = "👤 " .. targetPlayer.Name .. " (không trong game)" 
        return 
    end 

    local humanoid = char:FindFirstChild("Humanoid") 
    if not humanoid then 
        playerStatusLabel.Text = "👤 " .. targetPlayer.Name 
        return 
    end 

    local hp = math.floor(humanoid.Health) 
    local maxHp = humanoid.MaxHealth 
    local hpPercent = math.floor((hp / maxHp) * 100) 

    local myChar = player.Character 
    local distance = "???" 
    if myChar and myChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then 
        local dist = (myChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude 
        distance = math.floor(dist) .. "s" 
    end 

    local healthIcon = hpPercent > 50 and "❤️" or (hpPercent > 25 and "🧡" or "💔") 
    playerStatusLabel.Text = string.format("👤 %s | %s %d/%d (%d%%) | 📏 %s",  
        targetPlayer.Name, healthIcon, hp, maxHp, hpPercent, distance) 
end 

local function toggleNoClip() 
    noClip = not noClip 

    if noClip then 
        if noclipConnection then noclipConnection:Disconnect() end 
        noclipConnection = runService.Stepped:Connect(function() 
            local char = player.Character 
            if char then 
                for _, part in ipairs(char:GetChildren()) do 
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end 
                end 
            end 
        end) 
        noClipBtn.Text = "🌊 NO CLIP ON" 
        noClipBtn.TextColor3 = Color3.fromRGB(100, 255, 100) 
        noClipBtn.BorderColor3 = Color3.fromRGB(0, 255, 0) 
    else 
        if noclipConnection then noclipConnection:Disconnect() end 
        local char = player.Character 
        if char then 
            for _, part in ipairs(char:GetChildren()) do 
                if part:IsA("BasePart") then 
                    part.CanCollide = true 
                end 
            end 
        end 
        noClipBtn.Text = "🌊 NO CLIP OFF" 
        noClipBtn.TextColor3 = Color3.fromRGB(255, 100, 100) 
        noClipBtn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    end 
end 

local function toggleInfJump() 
    infJump = not infJump 

    if infJump then 
        if infJumpConnection then infJumpConnection:Disconnect() end 
        infJumpConnection = userInputService.JumpRequest:Connect(function() 
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then 
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end) 
        infJumpBtn.Text = "🔁 INF JUMP ON" 
        infJumpBtn.TextColor3 = Color3.fromRGB(100, 255, 100) 
        infJumpBtn.BorderColor3 = Color3.fromRGB(0, 255, 0) 
    else 
        if infJumpConnection then infJumpConnection:Disconnect() end 
        infJumpBtn.Text = "🔁 INF JUMP OFF" 
        infJumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100) 
        infJumpBtn.BorderColor3 = Color3.fromRGB(128, 0, 255) 
    end 
end 

local function forceReset() 
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
    if humanoid then 
        humanoid.Health = 0 
    end 
end 

local function getPositionOffset() 
    local distance = tonumber(distanceBox.Text) or 3 

    if currentPosition == "Sau lưng" then 
        return Vector3.new(0, 0, distance) 
    elseif currentPosition == "Trước mặt" then 
        return Vector3.new(0, 0, -distance) 
    elseif currentPosition == "Trên đầu" then 
        return Vector3.new(0, distance, 0) 
    elseif currentPosition == "Dưới chân" then 
        return Vector3.new(0, -distance, 0) 
    else 
        local speed = tonumber(speedBox.Text) or 16 
        angle = angle + (speed / 100) 
        local radius = distance 
        local x = math.cos(angle) * radius 
        local z = math.sin(angle) * radius 
        return Vector3.new(x, 0, z) 
    end 
end 

local function orbitWithCFrame() 
    if not orbiting or not targetPlayer then return end 
    if not targetPlayer.Character then return end 

    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") 
    if not targetRoot then return end 

    local myChar = player.Character 
    if not myChar then return end 

    local myRoot = myChar:FindFirstChild("HumanoidRootPart") 
    if not myRoot then return end 

    local humanoid = myChar:FindFirstChild("Humanoid") 
    if humanoid then 
        humanoid.AutoRotate = false 
    end 

    local offset = getPositionOffset() 
    local targetPos = targetRoot.Position + (targetRoot.CFrame:VectorToWorldSpace(offset)) 
    local newCFrame = CFrame.new(targetPos, targetRoot.Position) 
    myRoot.CFrame = newCFrame 
end 

local function orbitWithLerp() 
    if not orbiting or not targetPlayer then return end 
    if not targetPlayer.Character then return end 

    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") 
    if not targetRoot then return end 

    local myChar = player.Character 
    if not myChar then return end 

    local myRoot = myChar:FindFirstChild("HumanoidRootPart") 
    if not myRoot then return end 

    local humanoid = myChar:FindFirstChild("Humanoid") 
    if humanoid then 
        humanoid.AutoRotate = false 
    end 

    local offset = getPositionOffset() 
    local targetPos = targetRoot.Position + (targetRoot.CFrame:VectorToWorldSpace(offset)) 
    local newCFrame = CFrame.new(targetPos, targetRoot.Position) 

    local currentCF = myRoot.CFrame 
    myRoot.CFrame = currentCF:Lerp(newCFrame, 0.3) 
end 

local function orbitWithBodyVelocity() 
    if not orbiting or not targetPlayer then return end 
    if not targetPlayer.Character then return end 

    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") 
    if not targetRoot then return end 

    local myChar = player.Character 
    if not myChar then return end 

    local myRoot = myChar:FindFirstChild("HumanoidRootPart") 
    if not myRoot then return end 

    local humanoid = myChar:FindFirstChild("Humanoid") 
    if humanoid then 
        humanoid.AutoRotate = false 
    end 

    local offset = getPositionOffset() 
    local targetPos = targetRoot.Position + (targetRoot.CFrame:VectorToWorldSpace(offset)) 

    local bodyVelocity = myRoot:FindFirstChild("OrbitBodyVelocity") 
    if not bodyVelocity then 
        bodyVelocity = Instance.new("BodyVelocity") 
        bodyVelocity.Name = "OrbitBodyVelocity" 
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9) 
        bodyVelocity.P = 100000 
        bodyVelocity.Parent = myRoot 
    end 

    bodyVelocity.Velocity = (targetPos - myRoot.Position) * 10 

    local lookCFrame = CFrame.new(myRoot.Position, targetRoot.Position) 
    myRoot.CFrame = lookCFrame 
end 

local function stopBodyVelocity() 
    local myChar = player.Character 
    if myChar then 
        local myRoot = myChar:FindFirstChild("HumanoidRootPart") 
        if myRoot then 
            local bodyVelocity = myRoot:FindFirstChild("OrbitBodyVelocity") 
            if bodyVelocity then 
                bodyVelocity:Destroy() 
            end 
        end 
    end 
end 

local function orbitCharacter() 
    if not orbiting then return end 
    if not targetPlayer then return end 

    if currentMethod == "CFrame" then 
        orbitWithCFrame() 
    elseif currentMethod == "Lerp" then 
        orbitWithLerp() 
    elseif currentMethod == "BodyVelocity" then 
        orbitWithBodyVelocity() 
    end 
end 

local function resizeUIForTab() 
    local targetHeight 
    if currentTab == "orbit" then 
        targetHeight = orbitHeight 
    else 
        targetHeight = settingsHeight 
    end 
    mainFrame:TweenSize(UDim2.new(0, 320, 0, targetHeight), "Out", "Quad", 0.15) 
end 

tabButton.MouseButton1Click:Connect(function() 
    if currentTab == "orbit" then 
        currentTab = "settings" 
        orbitTab.Visible = false 
        settingsTab.Visible = true 
        titleLabel.Text = "🛠️ UTILITIES 🛠️" 
        tabButton.Text = "◀" 
    else 
        currentTab = "orbit" 
        orbitTab.Visible = true 
        settingsTab.Visible = false 
        titleLabel.Text = "⚡ ORBIT CONTROLLER ⚡" 
        tabButton.Text = "⋯" 
    end 
    resizeUIForTab() 
end) 

playerListButton.MouseButton1Click:Connect(function() 
    updatePlayerList() 
    playerListFrame.Visible = true 
    playerListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 15, 0, mainFrame.AbsolutePosition.Y) 
end) 

closePlayerBtn.MouseButton1Click:Connect(function() 
    playerListFrame.Visible = false 
end) 

positionButton.MouseButton1Click:Connect(function() 
    updatePositionList() 
    positionListFrame.Visible = true 
    positionListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X - 265, 0, mainFrame.AbsolutePosition.Y) 
end) 

closePositionBtn.MouseButton1Click:Connect(function() 
    positionListFrame.Visible = false 
end) 

methodButton.MouseButton1Click:Connect(function() 
    updateMethodList() 
    methodListFrame.Visible = true 
    methodListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 15, 0, mainFrame.AbsolutePosition.Y) 
end) 

closeMethodBtn.MouseButton1Click:Connect(function() 
    methodListFrame.Visible = false 
end) 

spectateButton.MouseButton1Click:Connect(function() 
    updateSpectateList() 
    spectateListFrame.Visible = true 
    spectateListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X - 265, 0, mainFrame.AbsolutePosition.Y) 
end) 

closeSpectateBtn.MouseButton1Click:Connect(function() 
    spectateListFrame.Visible = false 
end) 

orbitButton.MouseButton1Click:Connect(function() 
    orbiting = not orbiting 

    if orbiting then 
        orbitButton.Text = "🟢 ORBIT ON" 
        orbitButton.BorderColor3 = Color3.fromRGB(0, 255, 0) 
        orbitButton.TextColor3 = Color3.fromRGB(100, 255, 100) 

        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
        if humanoid then 
            humanoid.AutoRotate = false 
        end 
    else 
        orbitButton.Text = "🔴 ORBIT OFF" 
        orbitButton.BorderColor3 = Color3.fromRGB(128, 0, 255) 
        orbitButton.TextColor3 = Color3.fromRGB(255, 100, 100) 

        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
        if humanoid then 
            humanoid.AutoRotate = true 
        end 
        stopBodyVelocity() 
        lastPosition = nil 
    end 
end) 

btnLeft.MouseButton1Click:Connect(prevSpectate) 
btnRight.MouseButton1Click:Connect(nextSpectate) 
btnStopSpec.MouseButton1Click:Connect(stopSpectate) 

speedBtn.MouseButton1Click:Connect(function() 
    local newSpeed = tonumber(speedInput.Text) 
    if newSpeed and newSpeed >= 16 and newSpeed <= 200 then 
        walkSpeed = newSpeed 
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
        if humanoid then 
            humanoid.WalkSpeed = walkSpeed 
        end 
    end 
end) 

jumpBtn.MouseButton1Click:Connect(function() 
    local newJump = tonumber(jumpInput.Text) 
    if newJump and newJump >= 50 and newJump <= 300 then 
        jumpPower = newJump 
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
        if humanoid then 
            humanoid.JumpPower = jumpPower 
        end 
    end 
end) 

infJumpBtn.MouseButton1Click:Connect(toggleInfJump) 
noClipBtn.MouseButton1Click:Connect(toggleNoClip) 
espBtn.MouseButton1Click:Connect(toggleESP) 
resetBtn.MouseButton1Click:Connect(forceReset) 

minimizeButton.MouseButton1Click:Connect(function() 
    isMinimized = not isMinimized 
    if isMinimized then 
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 35), "Out", "Quad", 0.2) 
        contentContainer.Visible = false 
        minimizeButton.Text = "+" 
    else 
        local targetHeight = currentTab == "orbit" and orbitHeight or settingsHeight 
        mainFrame:TweenSize(UDim2.new(0, 320, 0, targetHeight), "Out", "Quad", 0.2) 
        contentContainer.Visible = true 
        minimizeButton.Text = "–" 
    end 
end) 

closeButton.MouseButton1Click:Connect(function() 
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") 
    if humanoid then 
        humanoid.AutoRotate = true 
    end 
    if noclipConnection then noclipConnection:Disconnect() end 
    if infJumpConnection then infJumpConnection:Disconnect() end 
    stopBodyVelocity() 
    stopSpectate() 
    for _, data in pairs(espConnections) do 
        if data.billboard then data.billboard:Destroy() end 
    end 
    for _, connections in pairs(espCharacterConnections) do 
        for _, conn in ipairs(connections) do 
            conn:Disconnect() 
        end 
    end 
    screenGui:Destroy() 
    specGui:Destroy() 
end) 

runService.RenderStepped:Connect(function() 
    if orbiting then 
        orbitCharacter() 
    end 

    if playerListFrame.Visible then 
        playerListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 15, 0, mainFrame.AbsolutePosition.Y) 
    end 
    if positionListFrame.Visible then 
        positionListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X - 265, 0, mainFrame.AbsolutePosition.Y) 
    end 
    if methodListFrame.Visible then 
        methodListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 15, 0, mainFrame.AbsolutePosition.Y) 
    end 
    if spectateListFrame.Visible then 
        spectateListFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X - 265, 0, mainFrame.AbsolutePosition.Y) 
    end 

    updateStatusLabel() 

    if isSpectating and spectateTarget then 
        local targetChar = spectateTarget.Character 
        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart") 
        local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid") 

        if targetHRP and targetHumanoid then 
            camera.CameraSubject = targetHumanoid 

            local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart") 
            local dist = myHRP and math.floor((myHRP.Position - targetHRP.Position).Magnitude) or 0 
            local vel = targetHRP.Velocity 
            local spd = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude) 
            local state = targetHumanoid:GetState() == Enum.HumanoidStateType.Jumping and "Jumping" or "Ground" 

            local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="..spectateTarget.UserId.."&width=150&height=150&format=png" 
            specAvatar.Image = avatarUrl 
            specInfo.Text = spectateTarget.DisplayName.." [@"..spectateTarget.Name.."]\nDist: "..dist.."m\nSpeed: "..spd.."\nState: "..state 
        end 
    elseif specGui.Enabled then 
        specInfo.Text = "" 
        specAvatar.Image = "" 
    end 
end) 

game.Players.PlayerAdded:Connect(function(plr) 
    if espEnabled and plr ~= player then 
        createESP(plr) 
    end 
    if spectateListFrame.Visible then 
        updateSpectateList() 
    end 
    updatePlayerList() 
end) 

game.Players.PlayerRemoving:Connect(function(plr) 
    removeESP(plr) 
    if spectateTarget == plr then 
        stopSpectate() 
    end 
    if spectateListFrame.Visible then 
        updateSpectateList() 
    end 
    updatePlayerList() 
end) 

player.CharacterAdded:Connect(function(char) 
    wait(0.5) 
    if orbiting then 
        local humanoid = char:FindFirstChild("Humanoid") 
        if humanoid then 
            humanoid.AutoRotate = false 
        end 
    end 
    local humanoid = char:FindFirstChild("Humanoid") 
    if humanoid then 
        humanoid.WalkSpeed = walkSpeed 
        humanoid.JumpPower = jumpPower 
    end 
end) 
