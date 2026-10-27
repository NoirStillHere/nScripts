if _G.LimbControllerGUI then
    pcall(function()
        _G.LimbControllerGUI:Destroy()
    end)
    _G.LimbControllerGUI = nil
end

if _G.LimbControllerActive then
    pcall(function()
        if _G.limbExtender then
            _G.limbExtender:Toggle(false)
        end
        if _G.limbExtenderCleanup then
            _G.limbExtenderCleanup()
        end
    end)
end

repeat wait() until game.Players.LocalPlayer and game:IsLoaded()

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

_G.LimbControllerActive = true

local LimbExtenderLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua"))()
local limbExtender = LimbExtenderLibrary({
    LISTEN_FOR_INPUT = false,
    USE_HIGHLIGHT = false,
})
_G.limbExtender = limbExtender

local isMinimized = false
local currentTab = "limbs"

local limbSize = limbExtender:Get("LIMB_SIZE")
local limbTransparency = limbExtender:Get("LIMB_TRANSPARENCY")
local targetLimb = limbExtender:Get("TARGET_LIMB")
local teamCheck = limbExtender:Get("TEAM_CHECK")
local forcefieldCheck = limbExtender:Get("FORCEFIELD_CHECK")
local limbCollisions = limbExtender:Get("LIMB_CAN_COLLIDE")

local visibilityStates = {
    ["Head"] = false,
    ["Torso"] = false,
    ["Right Arm"] = false,
    ["Left Arm"] = false,
    ["Right Leg"] = false,
    ["Left Leg"] = false,
}

local npcLimbSettings = { 
    Enabled = false, 
    HitboxSize = 5, 
    Transparency = 0.9, 
    SelectedPart = "HumanoidRootPart", 
    TeamCheck = false, 
    Collision = false 
}
local OldSizes = {}

local visualSettings = {
    PlayerESP = false,
    NPCESP = false,
    PlayerHighlight = false,
    NPCHighlight = false,
    TeamCheck = false
}
local espLabels = {}
local highlightObjects = {}

local btnWidth = 140
local btnHeight = 40
local col1 = 15
local col2 = 165
local row1 = 30
local row2 = 80
local row3 = 130
local row4 = 180

local limbsHeight = 260
local userHeight = 260

local dragging = false
local dragStart = nil
local startPos = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LimbControllerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui
_G.LimbControllerGUI = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, limbsHeight)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.5
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
header.BackgroundTransparency = 0.3
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
titleLabel.Text = " LIMB CONTROLLER "
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
tabButton.Text = "∈"
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

local limbsTab = Instance.new("ScrollingFrame")
limbsTab.Size = UDim2.new(1, 0, 1, 0)
limbsTab.BackgroundTransparency = 1
limbsTab.ScrollBarThickness = 6
limbsTab.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
limbsTab.ScrollBarImageTransparency = 0.3
limbsTab.CanvasSize = UDim2.new(0, 0, 0, 0)
limbsTab.Parent = contentContainer

local limbsContainer = Instance.new("Frame")
limbsContainer.Size = UDim2.new(1, 0, 0, 0)
limbsContainer.BackgroundTransparency = 1
limbsContainer.Parent = limbsTab

local userTab = Instance.new("ScrollingFrame")
userTab.Size = UDim2.new(1, 0, 1, 0)
userTab.BackgroundTransparency = 1
userTab.ScrollBarThickness = 6
userTab.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
userTab.ScrollBarImageTransparency = 0.3
userTab.Visible = false
userTab.CanvasSize = UDim2.new(0, 0, 0, 0)
userTab.Parent = contentContainer

local userContainer = Instance.new("Frame")
userContainer.Size = UDim2.new(1, 0, 0, 0)
userContainer.BackgroundTransparency = 1
userContainer.Parent = userTab

local function updateCanvasSize()
    local maxY = 0
    for _, child in ipairs(limbsContainer:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            local childBottom = child.Position.Y.Offset + child.AbsoluteSize.Y
            if childBottom > maxY then
                maxY = childBottom
            end
        end
    end
    local totalHeight = maxY + 30
    if totalHeight < limbsHeight then
        totalHeight = limbsHeight
    end
    limbsContainer.Size = UDim2.new(1, 0, 0, totalHeight)
    limbsTab.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

    local userMaxY = 0
    for _, child in ipairs(userContainer:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            local childBottom = child.Position.Y.Offset + child.AbsoluteSize.Y
            if childBottom > userMaxY then
                userMaxY = childBottom
            end
        end
    end
    local userTotalHeight = userMaxY + 30
    if userTotalHeight < userHeight then
        userTotalHeight = userHeight
    end
    userContainer.Size = UDim2.new(1, 0, 0, userTotalHeight)
    userTab.CanvasSize = UDim2.new(0, 0, 0, userTotalHeight)
end

local function createStyledButton(parent, posX, posY, text, color, width)
    local w = width or btnWidth
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, btnHeight)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.BackgroundTransparency = 0.5
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
    btnStroke.Transparency = 1
    btnStroke.Parent = btn

    return btn
end

local function createStyledInput(parent, posX, posY, placeholder, text, width)
    local w = width or btnWidth
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, w, 0, btnHeight)
    input.Position = UDim2.new(0, posX, 0, posY)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    input.BackgroundTransparency = 0.5
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
    inputStroke.Transparency = 1
    inputStroke.Parent = input

    return input
end

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(0.9, 0, 0, 25)
playerTitle.Position = UDim2.new(0.05, 0, 0, 5)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "🎮 PLAYER SETTINGS"
playerTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextSize = 12
playerTitle.Parent = limbsContainer

local limbsToggle = createStyledButton(limbsContainer, col1, row1, " PHÓNG TO OFF", Color3.fromRGB(255, 100, 100))

local targetLimbDropdown = Instance.new("TextButton")
targetLimbDropdown.Size = UDim2.new(0, btnWidth, 0, btnHeight)
targetLimbDropdown.Position = UDim2.new(0, col2, 0, row1)
targetLimbDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
targetLimbDropdown.BackgroundTransparency = 0.5
targetLimbDropdown.BorderSizePixel = 2
targetLimbDropdown.BorderColor3 = Color3.fromRGB(128, 0, 255)
targetLimbDropdown.Text = " BỘ PHẬN: " .. targetLimb
targetLimbDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLimbDropdown.Font = Enum.Font.GothamBold
targetLimbDropdown.TextSize = 10
targetLimbDropdown.Parent = limbsContainer

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 8)
dropdownCorner.Parent = targetLimbDropdown

local sizeInput = createStyledInput(limbsContainer, col1, row2, "Kích thước (5-500)", tostring(limbSize), 80)
local sizeApply = createStyledButton(limbsContainer, col1 + 85, row2, "APPLY", Color3.fromRGB(100, 255, 100), 55)

local transInput = createStyledInput(limbsContainer, col2, row2, "Độ mờ (0-1)", tostring(limbTransparency), 80)
local transApply = createStyledButton(limbsContainer, col2 + 85, row2, "APPLY", Color3.fromRGB(100, 255, 100), 55)

local teamCheckToggle = createStyledButton(limbsContainer, col1, row3, " TEAM CHECK OFF", Color3.fromRGB(255, 100, 100))
local forcefieldToggle = createStyledButton(limbsContainer, col2, row3, " FORCEFIELD OFF", Color3.fromRGB(255, 100, 100))
local collisionToggle = createStyledButton(limbsContainer, col1, row4, " COLLISION OFF", Color3.fromRGB(255, 100, 100))

local npcTitle = Instance.new("TextLabel")
npcTitle.Size = UDim2.new(0.9, 0, 0, 25)
npcTitle.Position = UDim2.new(0.05, 0, 0, row4 + btnHeight + 15)
npcTitle.BackgroundTransparency = 1
npcTitle.Text = "⚔️ NPC SETTINGS"
npcTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
npcTitle.Font = Enum.Font.GothamBold
npcTitle.TextSize = 12
npcTitle.Parent = limbsContainer

local npcEnableToggle = createStyledButton(limbsContainer, col1, row4 + btnHeight + 50, " NPC HITBOX OFF", Color3.fromRGB(255, 100, 100))

local npcSizeInput = createStyledInput(limbsContainer, col1, row4 + btnHeight + 100, "Kích thước (5-500)", tostring(npcLimbSettings.HitboxSize), 80)
local npcSizeApply = createStyledButton(limbsContainer, col1 + 85, row4 + btnHeight + 100, "APPLY", Color3.fromRGB(100, 255, 100), 55)

local npcTransInput = createStyledInput(limbsContainer, col2, row4 + btnHeight + 100, "Độ mờ (0-1)", tostring(npcLimbSettings.Transparency), 80)
local npcTransApply = createStyledButton(limbsContainer, col2 + 85, row4 + btnHeight + 100, "APPLY", Color3.fromRGB(100, 255, 100), 55)

local npcTeamCheckToggle = createStyledButton(limbsContainer, col1, row4 + btnHeight + 150, " NPC TEAM CHECK OFF", Color3.fromRGB(255, 100, 100))
local npcCollisionToggle = createStyledButton(limbsContainer, col2, row4 + btnHeight + 150, " NPC COLLISION OFF", Color3.fromRGB(255, 100, 100))

local npcPartDropdown = Instance.new("TextButton")
npcPartDropdown.Size = UDim2.new(0, btnWidth, 0, btnHeight)
npcPartDropdown.Position = UDim2.new(0, col1, 0, row4 + btnHeight + 200)
npcPartDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
npcPartDropdown.BackgroundTransparency = 0.5
npcPartDropdown.BorderSizePixel = 2
npcPartDropdown.BorderColor3 = Color3.fromRGB(128, 0, 255)
npcPartDropdown.Text = " BỘ PHẬN: " .. npcLimbSettings.SelectedPart
npcPartDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
npcPartDropdown.Font = Enum.Font.GothamBold
npcPartDropdown.TextSize = 10
npcPartDropdown.Parent = limbsContainer

local npcPartDropdownCorner = Instance.new("UICorner")
npcPartDropdownCorner.CornerRadius = UDim.new(0, 8)
npcPartDropdownCorner.Parent = npcPartDropdown

local visualTitle = Instance.new("TextLabel")
visualTitle.Size = UDim2.new(0.9, 0, 0, 25)
visualTitle.Position = UDim2.new(0.05, 0, 0, row4 + btnHeight + 255)
visualTitle.BackgroundTransparency = 1
visualTitle.Text = "👁️ VISUAL SETTINGS"
visualTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
visualTitle.Font = Enum.Font.GothamBold
visualTitle.TextSize = 12
visualTitle.Parent = limbsContainer

local playerESPToggle = createStyledButton(limbsContainer, col1, row4 + btnHeight + 290, " PLAYER ESP OFF", Color3.fromRGB(255, 100, 100))
local npcESPToggle = createStyledButton(limbsContainer, col2, row4 + btnHeight + 290, " NPC ESP OFF", Color3.fromRGB(255, 100, 100))

local playerHighlightToggle = createStyledButton(limbsContainer, col1, row4 + btnHeight + 340, " HIGHLIGHT PLAYER OFF", Color3.fromRGB(255, 100, 100))
local npcHighlightToggle = createStyledButton(limbsContainer, col2, row4 + btnHeight + 340, " HIGHLIGHT NPC OFF", Color3.fromRGB(255, 100, 100))

local visualTeamCheckToggle = createStyledButton(limbsContainer, col1, row4 + btnHeight + 390, " VISUAL TEAM CHECK OFF", Color3.fromRGB(255, 100, 100))

local userTitle = Instance.new("TextLabel")
userTitle.Size = UDim2.new(0.9, 0, 0, 25)
userTitle.Position = UDim2.new(0.05, 0, 0, 5)
userTitle.BackgroundTransparency = 1
userTitle.Text = "👤 USER SETTINGS"
userTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
userTitle.Font = Enum.Font.GothamBold
userTitle.TextSize = 12
userTitle.Parent = userContainer

local bodyTitle = Instance.new("TextLabel")
bodyTitle.Size = UDim2.new(0.9, 0, 0, 20)
bodyTitle.Position = UDim2.new(0.05, 0, 0, 35)
bodyTitle.BackgroundTransparency = 1
bodyTitle.Text = "Ẩn/Hiện bộ phận cơ thể"
bodyTitle.TextColor3 = Color3.fromRGB(150, 150, 200)
bodyTitle.Font = Enum.Font.GothamBold
bodyTitle.TextSize = 11
bodyTitle.TextXAlignment = Enum.TextXAlignment.Center
bodyTitle.Parent = userContainer

local headToggle = createStyledButton(userContainer, col1, 60, " HEAD", Color3.fromRGB(200, 200, 200))
local torsoToggle = createStyledButton(userContainer, col2, 60, " BODY", Color3.fromRGB(200, 200, 200))
local rightArmToggle = createStyledButton(userContainer, col1, 110, " RIGHT ARM", Color3.fromRGB(200, 200, 200))
local leftArmToggle = createStyledButton(userContainer, col2, 110, " LEFT ARM", Color3.fromRGB(200, 200, 200))
local rightLegToggle = createStyledButton(userContainer, col1, 160, " RIGHT LEG", Color3.fromRGB(200, 200, 200))
local leftLegToggle = createStyledButton(userContainer, col2, 160, " LEFT LEG", Color3.fromRGB(200, 200, 200))

local resetBodyButton = createStyledButton(userContainer, col1, 210, " RESET ALL", Color3.fromRGB(255, 165, 0), btnWidth + 20)

local dropdownPanel = Instance.new("Frame")
dropdownPanel.Size = UDim2.new(0, 200, 0, 200)
dropdownPanel.Position = UDim2.new(0, 0, 0, 0)
dropdownPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
dropdownPanel.BackgroundTransparency = 0.3
dropdownPanel.BorderSizePixel = 2
dropdownPanel.BorderColor3 = Color3.fromRGB(128, 0, 255)
dropdownPanel.Visible = false
dropdownPanel.Parent = screenGui

local dropdownCornerPanel = Instance.new("UICorner")
dropdownCornerPanel.CornerRadius = UDim.new(0, 12)
dropdownCornerPanel.Parent = dropdownPanel

local dropdownScrolling = Instance.new("ScrollingFrame")
dropdownScrolling.Size = UDim2.new(1, -10, 1, -10)
dropdownScrolling.Position = UDim2.new(0, 5, 0, 5)
dropdownScrolling.BackgroundTransparency = 1
dropdownScrolling.ScrollBarThickness = 4
dropdownScrolling.Parent = dropdownPanel

local dropdownLayout = Instance.new("UIListLayout")
dropdownLayout.Padding = UDim.new(0, 4)
dropdownLayout.SortOrder = Enum.SortOrder.Name
dropdownLayout.Parent = dropdownScrolling

local npcPartPanel = Instance.new("Frame")
npcPartPanel.Size = UDim2.new(0, 200, 0, 200)
npcPartPanel.Position = UDim2.new(0, 0, 0, 0)
npcPartPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
npcPartPanel.BackgroundTransparency = 0.3
npcPartPanel.BorderSizePixel = 2
npcPartPanel.BorderColor3 = Color3.fromRGB(128, 0, 255)
npcPartPanel.Visible = false
npcPartPanel.Parent = screenGui

local npcPartPanelCorner = Instance.new("UICorner")
npcPartPanelCorner.CornerRadius = UDim.new(0, 12)
npcPartPanelCorner.Parent = npcPartPanel

local npcPartScrolling = Instance.new("ScrollingFrame")
npcPartScrolling.Size = UDim2.new(1, -10, 1, -10)
npcPartScrolling.Position = UDim2.new(0, 5, 0, 5)
npcPartScrolling.BackgroundTransparency = 1
npcPartScrolling.ScrollBarThickness = 4
npcPartScrolling.Parent = npcPartPanel

local npcPartLayout = Instance.new("UIListLayout")
npcPartLayout.Padding = UDim.new(0, 4)
npcPartLayout.SortOrder = Enum.SortOrder.Name
npcPartLayout.Parent = npcPartScrolling

local function updateLimbDropdown()
    for _, child in ipairs(dropdownScrolling:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local limbsList = {}
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(limbsList, part.Name)
            end
        end
    end

    table.sort(limbsList)

    for _, limbName in ipairs(limbsList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 2
        btn.BorderColor3 = Color3.fromRGB(128, 0, 255)
        btn.Text = limbName
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = dropdownScrolling

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            targetLimb = limbName
            limbExtender:Set("TARGET_LIMB", targetLimb)
            targetLimbDropdown.Text = " BỘ PHẬN: " .. targetLimb
            dropdownPanel.Visible = false
            if limbsToggle and limbsToggle.Text:find("ON") then
                limbExtender:Toggle(true)
            end
        end)
    end

    dropdownScrolling.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y + 10)
end

local function updateNPCPartDropdown()
    for _, child in ipairs(npcPartScrolling:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local partList = {"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

    for _, partName in ipairs(partList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 2
        btn.BorderColor3 = Color3.fromRGB(128, 0, 255)
        btn.Text = partName
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = npcPartScrolling

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            npcLimbSettings.SelectedPart = partName
            npcPartDropdown.Text = " BỘ PHẬN: " .. npcLimbSettings.SelectedPart
            npcPartPanel.Visible = false
        end)
    end

    npcPartScrolling.CanvasSize = UDim2.new(0, 0, 0, npcPartLayout.AbsoluteContentSize.Y + 10)
end

local function syncBodyVisibility()
    if not _G.LimbControllerActive then return end
    local char = player.Character
    if not char then return end

    local mapping = {
        ["Head"] = {"Head"},
        ["Torso"] = {"Torso", "UpperTorso", "LowerTorso"},
        ["Right Arm"] = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
        ["Left Arm"] = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
        ["Right Leg"] = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"},
        ["Left Leg"] = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
    }

    for partName, isHidden in pairs(visibilityStates) do
        local targetParts = mapping[partName]
        if targetParts then
            for _, targetPartName in ipairs(targetParts) do
                local part = char:FindFirstChild(targetPartName)
                if part and part:IsA("BasePart") then
                    local targetTrans = isHidden and 1 or 0
                    if part.Transparency ~= targetTrans then
                        part.Transparency = targetTrans
                    end
                    for _, child in pairs(part:GetChildren()) do
                        if child:IsA("Decal") then
                            child.Transparency = targetTrans
                        end
                    end
                end
            end
        end
    end
end

local function resetBodyVisibility()
    local char = player.Character
    if not char then return end

    local mapping = {
        ["Head"] = {"Head"},
        ["Torso"] = {"Torso", "UpperTorso", "LowerTorso"},
        ["Right Arm"] = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
        ["Left Arm"] = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
        ["Right Leg"] = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"},
        ["Left Leg"] = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
    }

    for _, targetParts in pairs(mapping) do
        for _, targetPartName in ipairs(targetParts) do
            local part = char:FindFirstChild(targetPartName)
            if part and part:IsA("BasePart") then
                part.Transparency = 0
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Decal") then
                        child.Transparency = 0
                    end
                end
            end
        end
    end
end

local function createESPLabel(character, isNPC, playerName)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0.4, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.6, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "❤️100"
    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    infoLabel.TextStrokeTransparency = 0.3
    infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.TextSize = 10
    infoLabel.TextScaled = true
    infoLabel.Parent = billboard

    return {billboard = billboard, nameLabel = nameLabel, infoLabel = infoLabel, character = character, isNPC = isNPC}
end

local function updateESP()
    for char, espData in pairs(espLabels) do
        pcall(function()
            espData.billboard:Destroy()
        end)
    end
    espLabels = {}

    if not visualSettings.PlayerESP and not visualSettings.NPCESP then
        return
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local isPlayer = game.Players:GetPlayerFromCharacter(obj)
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")

            if rootPart and humanoid then
                if isPlayer and visualSettings.PlayerESP then
                    local playerData = game.Players:GetPlayerFromCharacter(obj)
                    if playerData and playerData ~= player then
                        local esp = createESPLabel(obj, false, playerData.DisplayName)
                        espLabels[obj] = esp
                    end
                elseif not isPlayer and visualSettings.NPCESP then
                    local npcName = obj.Name or "NPC"
                    local esp = createESPLabel(obj, true, npcName)
                    espLabels[obj] = esp
                end
            end
        end
    end
end

local function updateESPInfo()
    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    for character, espData in pairs(espLabels) do
        pcall(function()
            if not character or not character.Parent then
                if espData.billboard then espData.billboard:Destroy() end
                espLabels[character] = nil
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")

            if rootPart and humanoid then
                local distance = localRoot and (rootPart.Position - localRoot.Position).Magnitude or 0

                local nameText = espData.nameLabel.Text
                if not espData.isNPC then
                    local playerData = game.Players:GetPlayerFromCharacter(character)
                    if playerData then
                        nameText = playerData.DisplayName
                    end
                end
                espData.nameLabel.Text = nameText .. " | " .. string.format("%.0fm", distance)

                local healthPercent = humanoid.Health / humanoid.MaxHealth
                espData.infoLabel.Text = string.format("❤️%.0f", humanoid.Health)

                if healthPercent > 0.6 then
                    espData.infoLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.3 then
                    espData.infoLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                else
                    espData.infoLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end

                if not espData.isNPC and visualSettings.TeamCheck and player.Team then
                    local characterTeam = nil
                    if character:FindFirstChild("TeamColor") then
                        characterTeam = character.TeamColor
                    elseif character:FindFirstChild("Team") then
                        characterTeam = character.Team.TeamColor
                    end
                    if characterTeam and characterTeam == player.TeamColor then
                        espData.nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    else
                        espData.nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                elseif not espData.isNPC then
                    espData.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                elseif espData.isNPC and visualSettings.TeamCheck and player.Team then
                    local npcTeam = character:FindFirstChild("TeamColor")
                    if npcTeam and npcTeam == player.TeamColor then
                        espData.nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    else
                        espData.nameLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                    end
                elseif espData.isNPC then
                    espData.nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                end

                espData.billboard.StudsOffset = Vector3.new(0, (humanoid.HipHeight or 3) + 1, 0)
            end
        end)
    end
end

local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    return highlight
end

local function updateAllHighlights()
    for character, highlight in pairs(highlightObjects) do
        local isPlayer = game.Players:GetPlayerFromCharacter(character)
        if isPlayer then
            if not visualSettings.PlayerHighlight then
                highlight:Destroy()
                highlightObjects[character] = nil
            else
                if not visualSettings.TeamCheck then
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif player.Team then
                    local characterTeam = nil
                    if character:FindFirstChild("TeamColor") then
                        characterTeam = character.TeamColor
                    elseif character:FindFirstChild("Team") then
                        characterTeam = character.Team.TeamColor
                    end
                    if characterTeam and characterTeam == player.TeamColor then
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    else
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    end
                else
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        else
            if not visualSettings.NPCHighlight then
                highlight:Destroy()
                highlightObjects[character] = nil
            else
                if not visualSettings.TeamCheck then
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                elseif player.Team then
                    local npcTeam = character:FindFirstChild("TeamColor")
                    if npcTeam and npcTeam == player.TeamColor then
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                    else
                        highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
                    end
                else
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                end
            end
        end
    end
end

local function updateHighlights()
    for char, highlight in pairs(highlightObjects) do
        pcall(function()
            highlight:Destroy()
        end)
    end
    highlightObjects = {}

    if not visualSettings.PlayerHighlight and not visualSettings.NPCHighlight then
        return
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local isPlayer = game.Players:GetPlayerFromCharacter(obj)

            if isPlayer and visualSettings.PlayerHighlight then
                local playerData = game.Players:GetPlayerFromCharacter(obj)
                if playerData and playerData ~= player then
                    local highlight = createHighlight(obj)
                    highlightObjects[obj] = highlight
                end
            elseif not isPlayer and visualSettings.NPCHighlight then
                local highlight = createHighlight(obj)
                highlightObjects[obj] = highlight
            end
        end
    end
    updateAllHighlights()
end

limbsToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    if limbsToggle.Text:find("OFF") then
        limbExtender:Toggle(true)
        limbsToggle.Text = " PHÓNG TO ON"
        limbsToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        limbsToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        limbExtender:Toggle(false)
        limbsToggle.Text = " PHÓNG TO OFF"
        limbsToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        limbsToggle.BorderColor3 = Color3.fromRGB(128, 0, 255)
    end
end)

sizeApply.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    local newSize = tonumber(sizeInput.Text)
    if newSize and newSize >= 5 and newSize <= 500 then
        limbSize = newSize
        limbExtender:Set("LIMB_SIZE", limbSize)
        if limbsToggle and limbsToggle.Text:find("ON") then
            limbExtender:Toggle(true)
        end
    else
        sizeInput.Text = tostring(limbSize)
    end
end)

transApply.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    local newTrans = tonumber(transInput.Text)
    if newTrans and newTrans >= 0 and newTrans <= 1 then
        limbTransparency = newTrans
        limbExtender:Set("LIMB_TRANSPARENCY", limbTransparency)
        if limbsToggle and limbsToggle.Text:find("ON") then
            limbExtender:Toggle(true)
        end
    else
        transInput.Text = tostring(limbTransparency)
    end
end)

targetLimbDropdown.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    updateLimbDropdown()
    dropdownPanel.Visible = true
    dropdownPanel.Position = UDim2.new(0, targetLimbDropdown.AbsolutePosition.X, 0, targetLimbDropdown.AbsolutePosition.Y + btnHeight)
end)

dropdownPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = userInputService:GetMouseLocation()
        local panelPos = dropdownPanel.AbsolutePosition
        local panelSize = dropdownPanel.AbsoluteSize
        if not (mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X and
                mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y) then
            dropdownPanel.Visible = false
        end
    end
end)

teamCheckToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    teamCheck = not teamCheck
    limbExtender:Set("TEAM_CHECK", teamCheck)
    if teamCheck then
        teamCheckToggle.Text = " TEAM CHECK ON"
        teamCheckToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        teamCheckToggle.Text = " TEAM CHECK OFF"
        teamCheckToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    if limbsToggle and limbsToggle.Text:find("ON") then
        limbExtender:Toggle(true)
    end
end)

forcefieldToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    forcefieldCheck = not forcefieldCheck
    limbExtender:Set("FORCEFIELD_CHECK", forcefieldCheck)
    if forcefieldCheck then
        forcefieldToggle.Text = " FORCEFIELD ON"
        forcefieldToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        forcefieldToggle.Text = " FORCEFIELD OFF"
        forcefieldToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    if limbsToggle and limbsToggle.Text:find("ON") then
        limbExtender:Toggle(true)
    end
end)

collisionToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    limbCollisions = not limbCollisions
    limbExtender:Set("LIMB_CAN_COLLIDE", limbCollisions)
    if limbCollisions then
        collisionToggle.Text = " COLLISION ON"
        collisionToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        collisionToggle.Text = " COLLISION OFF"
        collisionToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    if limbsToggle and limbsToggle.Text:find("ON") then
        limbExtender:Toggle(true)
    end
end)

npcEnableToggle.MouseButton1Click:Connect(function()
    npcLimbSettings.Enabled = not npcLimbSettings.Enabled
    if npcLimbSettings.Enabled then
        npcEnableToggle.Text = " NPC HITBOX ON"
        npcEnableToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        npcEnableToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        npcEnableToggle.Text = " NPC HITBOX OFF"
        npcEnableToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        npcEnableToggle.BorderColor3 = Color3.fromRGB(128, 0, 255)
        for part, data in pairs(OldSizes) do
            if part and part.Parent then
                part.Size = data.Size
                part.Transparency = data.Transparency
                part.CanCollide = data.CanCollide
            end
        end
        OldSizes = {}
    end
end)

npcSizeApply.MouseButton1Click:Connect(function()
    local newSize = tonumber(npcSizeInput.Text)
    if newSize and newSize >= 5 and newSize <= 500 then
        npcLimbSettings.HitboxSize = newSize
        npcSizeInput.Text = tostring(newSize)
    else
        npcSizeInput.Text = tostring(npcLimbSettings.HitboxSize)
    end
end)

npcTransApply.MouseButton1Click:Connect(function()
    local newTrans = tonumber(npcTransInput.Text)
    if newTrans and newTrans >= 0 and newTrans <= 1 then
        npcLimbSettings.Transparency = newTrans
        npcTransInput.Text = tostring(newTrans)
    else
        npcTransInput.Text = tostring(npcLimbSettings.Transparency)
    end
end)

npcTeamCheckToggle.MouseButton1Click:Connect(function()
    npcLimbSettings.TeamCheck = not npcLimbSettings.TeamCheck
    if npcLimbSettings.TeamCheck then
        npcTeamCheckToggle.Text = " NPC TEAM CHECK ON"
        npcTeamCheckToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        npcTeamCheckToggle.Text = " NPC TEAM CHECK OFF"
        npcTeamCheckToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

npcCollisionToggle.MouseButton1Click:Connect(function()
    npcLimbSettings.Collision = not npcLimbSettings.Collision
    if npcLimbSettings.Collision then
        npcCollisionToggle.Text = " NPC COLLISION ON"
        npcCollisionToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        npcCollisionToggle.Text = " NPC COLLISION OFF"
        npcCollisionToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

npcPartDropdown.MouseButton1Click:Connect(function()
    updateNPCPartDropdown()
    npcPartPanel.Visible = true
    npcPartPanel.Position = UDim2.new(0, npcPartDropdown.AbsolutePosition.X, 0, npcPartDropdown.AbsolutePosition.Y + btnHeight)
end)

playerESPToggle.MouseButton1Click:Connect(function()
    visualSettings.PlayerESP = not visualSettings.PlayerESP
    if visualSettings.PlayerESP then
        playerESPToggle.Text = " PLAYER ESP ON"
        playerESPToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        playerESPToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        playerESPToggle.Text = " PLAYER ESP OFF"
        playerESPToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        playerESPToggle.BorderColor3 = Color3.fromRGB(128, 0, 255)
    end
    updateESP()
end)

npcESPToggle.MouseButton1Click:Connect(function()
    visualSettings.NPCESP = not visualSettings.NPCESP
    if visualSettings.NPCESP then
        npcESPToggle.Text = " NPC ESP ON"
        npcESPToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        npcESPToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        npcESPToggle.Text = " NPC ESP OFF"
        npcESPToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        npcESPToggle.BorderColor3 = Color3.fromRGB(128, 0, 255)
    end
    updateESP()
end)

playerHighlightToggle.MouseButton1Click:Connect(function()
    visualSettings.PlayerHighlight = not visualSettings.PlayerHighlight
    if visualSettings.PlayerHighlight then
        playerHighlightToggle.Text = " HIGHLIGHT PLAYER ON"
        playerHighlightToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        playerHighlightToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        playerHighlightToggle.Text = " HIGHLIGHT PLAYER OFF"
        playerHighlightToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        playerHighlightToggle.BorderColor3 = Color3.fromRGB(128, 0, 255)
    end
    updateHighlights()
end)

npcHighlightToggle.MouseButton1Click:Connect(function()
    visualSettings.NPCHighlight = not visualSettings.NPCHighlight
    if visualSettings.NPCHighlight then
        npcHighlightToggle.Text = " HIGHLIGHT NPC ON"
        npcHighlightToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        npcHighlightToggle.BorderColor3 = Color3.fromRGB(0, 255, 0)
    else
        npcHighlightToggle.Text = " HIGHLIGHT NPC OFF"
        npcHighlightToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        npcHighlightToggle.BorderColor3 = Color3.fromRGB(128, 0, 255)
    end
    updateHighlights()
end)

visualTeamCheckToggle.MouseButton1Click:Connect(function()
    visualSettings.TeamCheck = not visualSettings.TeamCheck
    if visualSettings.TeamCheck then
        visualTeamCheckToggle.Text = " VISUAL TEAM CHECK ON"
        visualTeamCheckToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        visualTeamCheckToggle.Text = " VISUAL TEAM CHECK OFF"
        visualTeamCheckToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    updateESP()
    updateAllHighlights()
end)

headToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    visibilityStates["Head"] = not visibilityStates["Head"]
    if visibilityStates["Head"] then
        headToggle.Text = " HEAD (đã ẩn)"
        headToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        headToggle.Text = " HEAD"
        headToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    syncBodyVisibility()
end)

torsoToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    visibilityStates["Torso"] = not visibilityStates["Torso"]
    if visibilityStates["Torso"] then
        torsoToggle.Text = " BODY (đã ẩn)"
        torsoToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        torsoToggle.Text = " BODY"
        torsoToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    syncBodyVisibility()
end)

rightArmToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    visibilityStates["Right Arm"] = not visibilityStates["Right Arm"]
    if visibilityStates["Right Arm"] then
        rightArmToggle.Text = " RIGHT ARM (đã ẩn)"
        rightArmToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        rightArmToggle.Text = " RIGHT ARM"
        rightArmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    syncBodyVisibility()
end)

leftArmToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    visibilityStates["Left Arm"] = not visibilityStates["Left Arm"]
    if visibilityStates["Left Arm"] then
        leftArmToggle.Text = " LEFT ARM (đã ẩn)"
        leftArmToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        leftArmToggle.Text = " LEFT ARM"
        leftArmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    syncBodyVisibility()
end)

rightLegToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    visibilityStates["Right Leg"] = not visibilityStates["Right Leg"]
    if visibilityStates["Right Leg"] then
        rightLegToggle.Text = " RIGHT LEG (đã ẩn)"
        rightLegToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        rightLegToggle.Text = " RIGHT LEG"
        rightLegToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    syncBodyVisibility()
end)

leftLegToggle.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    visibilityStates["Left Leg"] = not visibilityStates["Left Leg"]
    if visibilityStates["Left Leg"] then
        leftLegToggle.Text = " LEFT LEG (đã ẩn)"
        leftLegToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        leftLegToggle.Text = " LEFT LEG"
        leftLegToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    syncBodyVisibility()
end)

resetBodyButton.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    for k, v in pairs(visibilityStates) do
        visibilityStates[k] = false
    end
    headToggle.Text = " HEAD"
    headToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    torsoToggle.Text = " BODY"
    torsoToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    rightArmToggle.Text = " RIGHT ARM"
    rightArmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    leftArmToggle.Text = " LEFT ARM"
    leftArmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    rightLegToggle.Text = " RIGHT LEG"
    rightLegToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    leftLegToggle.Text = " LEFT LEG"
    leftLegToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    syncBodyVisibility()
end)

game.Players.PlayerAdded:Connect(function(newPlayer)
    if not _G.LimbControllerActive then return end
    newPlayer.CharacterAdded:Connect(function(character)
        wait(0.5)
        if visualSettings.PlayerESP or visualSettings.NPCESP then updateESP() end
        if visualSettings.PlayerHighlight or visualSettings.NPCHighlight then updateHighlights() end
    end)
    if visualSettings.PlayerESP or visualSettings.NPCESP then wait(0.5) updateESP() end
    if visualSettings.PlayerHighlight or visualSettings.NPCHighlight then wait(0.5) updateHighlights() end
end)

game.Players.PlayerRemoving:Connect(function()
    if visualSettings.PlayerESP or visualSettings.NPCESP then updateESP() end
    if visualSettings.PlayerHighlight or visualSettings.NPCHighlight then updateHighlights() end
end)

workspace.ChildAdded:Connect(function(parent)
    if not _G.LimbControllerActive then return end
    if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
        local isPlayer = game.Players:GetPlayerFromCharacter(parent)
        if (isPlayer and visualSettings.PlayerESP) or (not isPlayer and visualSettings.NPCESP) then
            wait(0.3) updateESP()
        end
        if (isPlayer and visualSettings.PlayerHighlight) or (not isPlayer and visualSettings.NPCHighlight) then
            wait(0.3) updateHighlights()
        end
    end
end)

workspace.DescendantAdded:Connect(function(descendant)
    if not _G.LimbControllerActive then return end
    if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
        local isPlayer = game.Players:GetPlayerFromCharacter(descendant)
        if not isPlayer and visualSettings.NPCESP then wait(0.3) updateESP() end
        if not isPlayer and visualSettings.NPCHighlight then wait(0.3) updateHighlights() end
    end
end)

for _, plr in pairs(game.Players:GetPlayers()) do
    if plr ~= player then
        plr.CharacterAdded:Connect(function(character)
            wait(0.5)
            if visualSettings.PlayerESP then updateESP() end
            if visualSettings.PlayerHighlight then updateHighlights() end
        end)
    end
end

workspace.ChildRemoved:Connect(function(parent)
    if parent:IsA("Model") then
        if espLabels[parent] then
            pcall(function() espLabels[parent].billboard:Destroy() end)
            espLabels[parent] = nil
        end
        if highlightObjects[parent] then
            pcall(function() highlightObjects[parent]:Destroy() end)
            highlightObjects[parent] = nil
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    if not _G.LimbControllerActive then return end
    wait(0.5)
    syncBodyVisibility()
    if limbsToggle and limbsToggle.Text:find("ON") then
        limbExtender:Toggle(true)
    end
    wait(0.5)
    updateESP()
    updateHighlights()
end)

task.spawn(function()
    while _G.LimbControllerActive and task.wait(0.5) do
        if npcLimbSettings.Enabled then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local isPlayer = game.Players:GetPlayerFromCharacter(obj)
                    if hum and not isPlayer then
                        local isShop = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Shop")
                        local isEnemy = true
                        if npcLimbSettings.TeamCheck then
                            if obj:FindFirstChild("TeamColor") and obj.TeamColor == player.TeamColor then 
                                isEnemy = false 
                            end
                        end
                        if not isShop and isEnemy then
                            local target = obj:FindFirstChild(npcLimbSettings.SelectedPart) or obj:FindFirstChild("HumanoidRootPart")
                            if target and target:IsA("BasePart") then
                                if not OldSizes[target] then
                                    OldSizes[target] = { Size = target.Size, Transparency = target.Transparency, CanCollide = target.CanCollide }
                                end
                                target.Size = Vector3.new(npcLimbSettings.HitboxSize, npcLimbSettings.HitboxSize, npcLimbSettings.HitboxSize)
                                target.Transparency = npcLimbSettings.Transparency
                                target.CanCollide = npcLimbSettings.Collision
                                target.Color = Color3.fromRGB(0, 255, 255)
                            end
                        end
                    end
                end
            end
            for part in pairs(OldSizes) do 
                if not part or not part.Parent then 
                    OldSizes[part] = nil 
                end
            end
        end
    end
end)

task.spawn(function()
    while _G.LimbControllerActive and task.wait(0.1) do
        if visualSettings.PlayerESP or visualSettings.NPCESP then
            updateESPInfo()
        end
    end
end)

task.spawn(function()
    while _G.LimbControllerActive and task.wait(5) do
        for character, espData in pairs(espLabels) do
            if not character or not character.Parent or not character:FindFirstChildOfClass("Humanoid") then
                pcall(function() espData.billboard:Destroy() end)
                espLabels[character] = nil
            end
        end
        for character, highlight in pairs(highlightObjects) do
            if not character or not character.Parent or not character:FindFirstChildOfClass("Humanoid") then
                pcall(function() highlight:Destroy() end)
                highlightObjects[character] = nil
            end
        end
    end
end)

local function resizeUIForTab()
    if not _G.LimbControllerActive then return end
    local targetHeight = currentTab == "limbs" and limbsHeight or userHeight
    mainFrame:TweenSize(UDim2.new(0, 320, 0, targetHeight), "Out", "Quad", 0.15)
end

tabButton.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    if currentTab == "limbs" then
        currentTab = "user"
        limbsTab.Visible = false
        userTab.Visible = true
        titleLabel.Text = " USER "
        tabButton.Text = "∋"
    else
        currentTab = "limbs"
        limbsTab.Visible = true
        userTab.Visible = false
        titleLabel.Text = " PLAYER "
        tabButton.Text = "∈"
    end
    resizeUIForTab()
end)

minimizeButton.MouseButton1Click:Connect(function()
    if not _G.LimbControllerActive then return end
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 35), "Out", "Quad", 0.2)
        contentContainer.Visible = false
        minimizeButton.Text = "+"
    else
        local targetHeight = currentTab == "limbs" and limbsHeight or userHeight
        mainFrame:TweenSize(UDim2.new(0, 320, 0, targetHeight), "Out", "Quad", 0.2)
        contentContainer.Visible = true
        minimizeButton.Text = "–"
    end
end)

local function fullCleanup()
    _G.LimbControllerActive = false

    pcall(function() limbExtender:Toggle(false) end)
    pcall(function() resetBodyVisibility() end)

    for _, espData in pairs(espLabels) do
        pcall(function() espData.billboard:Destroy() end)
    end
    for _, highlight in pairs(highlightObjects) do
        pcall(function() highlight:Destroy() end)
    end
    pcall(function() screenGui:Destroy() end)

    _G.LimbControllerGUI = nil
    _G.limbExtender = nil
end

closeButton.MouseButton1Click:Connect(function()
    fullCleanup()
end)

local renderSteppedConnection
renderSteppedConnection = runService.RenderStepped:Connect(function()
    if not _G.LimbControllerActive then
        renderSteppedConnection:Disconnect()
        return
    end
    syncBodyVisibility()
    updateCanvasSize()

    if dropdownPanel and dropdownPanel.Visible then
        dropdownPanel.Position = UDim2.new(0, targetLimbDropdown.AbsolutePosition.X, 0, targetLimbDropdown.AbsolutePosition.Y + btnHeight)
    end

    if npcPartPanel and npcPartPanel.Visible then
        npcPartPanel.Position = UDim2.new(0, npcPartDropdown.AbsolutePosition.X, 0, npcPartDropdown.AbsolutePosition.Y + btnHeight)
    end
end)

_G.limbExtenderCleanup = fullCleanup

wait(1)
updateLimbDropdown()
updateNPCPartDropdown()
syncBodyVisibility()
updateCanvasSize() 