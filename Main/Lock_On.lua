local scriptName = "LockOnSystem"
if _G[scriptName] then
    if _G[scriptName].Cleanup then
        _G[scriptName].Cleanup()
    end
    _G[scriptName] = nil
end

local LockOnSystem = {}
_G[scriptName] = LockOnSystem

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local LockedTarget = nil
local lockMode = 0

local CamSmooth = 0.85
local CharSmooth = 1
local CameraHeight = 0

local MAX_DISTANCE = 100000
local SEARCH_DISTANCE = 10000
local CAMERA_LEFT_OFFSET = -1.27

local FULL_NECK_DISTANCE = 22
local FULL_ROOT_DISTANCE = 7

local lastSearchTime = 0
local SEARCH_RATE = 0.25

local PRIMARY_COLOR = Color3.fromRGB(138, 43, 226)
local SECONDARY_COLOR = Color3.fromRGB(75, 0, 130)
local BG_COLOR = Color3.fromRGB(25, 25, 35)
local TEXT_COLOR = Color3.fromRGB(220, 200, 255)

local connections = {}
local screenGui
local toggleBtn
local billboard
local settingsBtn
local settingsMenuFrame = nil
local settingsMenuVisible = false
local isFirstTime = true

local pingFpsGui
local pingFpsLabel
local pingFpsContainer

local function createPingFpsDisplay()
    if pingFpsGui then
        pingFpsGui:Destroy()
    end

    pingFpsGui = Instance.new("ScreenGui")
    pingFpsGui.Name = "LockOnPingFps"
    pingFpsGui.ResetOnSpawn = false
    pingFpsGui.Parent = game.CoreGui
    pingFpsGui.Enabled = true

    pingFpsContainer = Instance.new("Frame")
    pingFpsContainer.Size = UDim2.new(0, 200, 0, 30)
    pingFpsContainer.Position = UDim2.new(0.5, -100, 0.5, -200)
    pingFpsContainer.BackgroundColor3 = BG_COLOR
    pingFpsContainer.BackgroundTransparency = 0.5
    pingFpsContainer.BorderSizePixel = 0
    pingFpsContainer.Parent = pingFpsGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = pingFpsContainer

    local stroke = Instance.new("UIStroke")
    stroke.Color = PRIMARY_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = pingFpsContainer

    pingFpsLabel = Instance.new("TextLabel")
    pingFpsLabel.Size = UDim2.new(1, 0, 1, 0)
    pingFpsLabel.BackgroundTransparency = 1
    pingFpsLabel.Text = "Loading..."
    pingFpsLabel.TextColor3 = TEXT_COLOR
    pingFpsLabel.TextSize = 14
    pingFpsLabel.Font = Enum.Font.GothamBold
    pingFpsLabel.Parent = pingFpsContainer

    local dragging, dragStart, startPos

    pingFpsContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = pingFpsContainer.Position
        end
    end)

    pingFpsContainer.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            pingFpsContainer.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    pingFpsContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local fps = 0
    local last = tick()

    local renderConnection
    renderConnection = RunService.RenderStepped:Connect(function()
        if not pingFpsGui or not pingFpsGui.Parent then
            renderConnection:Disconnect()
            return
        end

        local now = tick()
        local delta = now - last
        if delta > 0 then
            fps = math.floor(1 / delta)
        end
        last = now

        local ping = 0
        local success, result = pcall(function()
            return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if success then
            ping = result
        end

        local pingColor
        if ping < 50 then
            pingColor = Color3.fromRGB(100, 255, 100)
        elseif ping < 100 then
            pingColor = Color3.fromRGB(255, 255, 100)
        elseif ping < 200 then
            pingColor = Color3.fromRGB(255, 150, 50)
        else
            pingColor = Color3.fromRGB(255, 80, 80)
        end

        local fpsColor
        if fps >= 60 then
            fpsColor = Color3.fromRGB(100, 255, 100)
        elseif fps >= 30 then
            fpsColor = Color3.fromRGB(255, 255, 100)
        else
            fpsColor = Color3.fromRGB(255, 80, 80)
        end

        pingFpsLabel.Text = string.format(
            '<font color="rgb(%d,%d,%d)">Ping: %d</font> | <font color="rgb(%d,%d,%d)">FPS: %d</font>',
            pingColor.R * 255, pingColor.G * 255, pingColor.B * 255, ping,
            fpsColor.R * 255, fpsColor.G * 255, fpsColor.B * 255, fps
        )
        pingFpsLabel.RichText = true
    end)

    table.insert(connections, renderConnection)
end

local function initScreenGui()
    if screenGui then
        screenGui:Destroy()
    end
    screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local isCameraMode = false
local isCharacterMode = false
local showBillboard = false

local function updateModeFlags()
    isCameraMode = (lockMode == 1 or lockMode == 2)
    isCharacterMode = (lockMode == 2 or lockMode == 3)
    showBillboard = (lockMode ~= 3)
end

local function getTargetPart(character)
    return character and character:FindFirstChild("Head")
end

local function getNeckPosition(head)
    if not head then return nil end
    local char = head.Parent
    if not char then return nil end

    local neckAtt = head:FindFirstChild("NeckAttachment")
    if not neckAtt then
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if torso then
            neckAtt = torso:FindFirstChild("NeckAttachment")
        end
    end

    if neckAtt and neckAtt:IsA("Attachment") then
        return neckAtt.WorldPosition
    end

    return (head.CFrame * CFrame.new(0, -0.5, 0)).Position
end

local function getCameraLockPosition(targetPart)
    if not targetPart or not isCameraMode then
        return getNeckPosition(targetPart)
    end

    local char = targetPart.Parent
    if not char then return getNeckPosition(targetPart) end

    local myChar = LocalPlayer.Character
    if not myChar then return getNeckPosition(targetPart) end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return getNeckPosition(targetPart) end

    local targetRoot = char:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return getNeckPosition(targetPart) end

    local neckPos = getNeckPosition(targetPart)
    local rootPos = targetRoot.Position
    local distance = (myRoot.Position - rootPos).Magnitude

    local basePos
    if distance >= FULL_NECK_DISTANCE then
        basePos = neckPos
    elseif distance <= FULL_ROOT_DISTANCE then
        basePos = rootPos
    else
        local t = (distance - FULL_ROOT_DISTANCE) / (FULL_NECK_DISTANCE - FULL_ROOT_DISTANCE)
        basePos = rootPos:Lerp(neckPos, t)
    end

    return basePos + Vector3.new(0, CameraHeight, 0)
end

local function getLockAdornee(targetChar)
    if not targetChar or not showBillboard then return nil end
    return targetChar:FindFirstChild("UpperTorso")
        or targetChar:FindFirstChild("Torso")
        or targetChar:FindFirstChild("HumanoidRootPart")
end

local function setupDeathHandler(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local deathConnection
        deathConnection = humanoid.Died:Connect(function()
            Enabled = false
            LockedTarget = nil
            if isCameraMode then
                forceInstantReset()
            end
            if toggleBtn then
                toggleBtn.Image = "rbxassetid://110432273832755"
            end
        end)
        table.insert(connections, deathConnection)
    end
end

local function findClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, minDist = nil, math.huge

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = { LocalPlayer.Character }
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local nearbyParts = Workspace:GetPartBoundsInRadius(myRoot.Position, SEARCH_DISTANCE, overlapParams)

    local checkedModels = {}

    for _, part in ipairs(nearbyParts) do
        local char = part:FindFirstAncestorWhichIsA("Model")
        if char and not checkedModels[char] and char ~= LocalPlayer.Character then
            checkedModels[char] = true

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPart = getTargetPart(char)
                if targetPart then
                    local neckPos = getNeckPosition(targetPart)
                    if neckPos then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(neckPos)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closest = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function isValidTarget(targetPart)
    if not targetPart then return false end
    local char = targetPart.Parent
    if not char or not char:IsA("Model") then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if char == LocalPlayer.Character then return false end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        local neckPos = getNeckPosition(targetPart)
        if neckPos and (neckPos - myRoot.Position).Magnitude > MAX_DISTANCE then
            return false
        end
    end
    return true
end

local function forceInstantReset()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        Camera.CameraType = Enum.CameraType.Fixed
        Camera.CameraSubject = char.Humanoid
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function createMiniSlider(parent, name, minValue, maxValue, defaultValue, xPosition, yPosition, width, callback)
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, width, 0, 18)
    sliderLabel.Position = UDim2.new(0, xPosition, 0, yPosition)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. string.format("%.2f", defaultValue)
    sliderLabel.TextColor3 = TEXT_COLOR
    sliderLabel.TextSize = 12
    sliderLabel.Font = Enum.Font.GothamSemibold
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = parent

    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0, width, 0, 22)
    sliderContainer.Position = UDim2.new(0, xPosition, 0, yPosition + 20)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -45, 0, 5)
    sliderBg.Position = UDim2.new(0, 0, 0.5, -2)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    sliderBg.Parent = sliderContainer
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 3)
    bgCorner.Parent = sliderBg

    local fillBar = Instance.new("Frame")
    local fillPercent = (defaultValue - minValue) / (maxValue - minValue)
    fillBar.Size = UDim2.new(fillPercent, 0, 1, 0)
    fillBar.BackgroundColor3 = PRIMARY_COLOR
    fillBar.Parent = sliderBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fillBar

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 22, 0, 22)
    sliderBtn.Position = UDim2.new(fillPercent, -11, 0.5, -11)
    sliderBtn.BackgroundColor3 = PRIMARY_COLOR
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = sliderBtn

    local valueInput = Instance.new("TextBox")
    valueInput.Size = UDim2.new(0, 40, 0, 20)
    valueInput.Position = UDim2.new(1, -40, 0.5, -10)
    valueInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    valueInput.TextColor3 = TEXT_COLOR
    valueInput.Text = string.format("%.2f", defaultValue)
    valueInput.TextSize = 11
    valueInput.Font = Enum.Font.GothamSemibold
    valueInput.Parent = sliderContainer
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = valueInput

    local currentValue = defaultValue
    local dragging = false

    local function updateValue(newValue)
        currentValue = math.clamp(newValue, minValue, maxValue)
        local percent = (currentValue - minValue) / (maxValue - minValue)

        sliderLabel.Text = name .. ": " .. string.format("%.2f", currentValue)
        valueInput.Text = string.format("%.2f", currentValue)
        fillBar.Size = UDim2.new(percent, 0, 1, 0)
        sliderBtn.Position = UDim2.new(percent, -11, 0.5, -11)

        if callback then
            callback(currentValue)
        end
    end

    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    sliderBtn.MouseButton1Up:Connect(function()
        dragging = false
    end)

    sliderBtn.MouseLeave:Connect(function()
        dragging = false
    end)

    sliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    sliderContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    sliderContainer.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local sliderAbsPos = sliderBg.AbsolutePosition.X
            local sliderWidth = sliderBg.AbsoluteSize.X
            local relativeX = (mousePos - sliderAbsPos) / sliderWidth
            local newValue = minValue + (relativeX * (maxValue - minValue))
            updateValue(newValue)
        end
    end)

    valueInput.FocusLost:Connect(function(enterPressed)
        local num = tonumber(valueInput.Text)
        if num then
            updateValue(num)
        else
            valueInput.Text = string.format("%.2f", currentValue)
        end
    end)

    return updateValue, currentValue
end

local function createVerticalSlider(parent, name, minValue, maxValue, defaultValue, xPosition, yPosition, height, callback)
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 20, 0, height)
    sliderLabel.Position = UDim2.new(0, xPosition, 0, yPosition)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name
    sliderLabel.TextColor3 = TEXT_COLOR
    sliderLabel.TextSize = 13
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Center
    sliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    sliderLabel.Rotation = -90
    sliderLabel.Parent = parent

    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0, 30, 0, height)
    sliderContainer.Position = UDim2.new(0, xPosition + 25, 0, yPosition)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0, 5, 1, -25)
    sliderBg.Position = UDim2.new(0.5, -2, 0, 12)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    sliderBg.Parent = sliderContainer
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 3)
    bgCorner.Parent = sliderBg

    local fillBar = Instance.new("Frame")
    local fillPercent = (defaultValue - minValue) / (maxValue - minValue)
    fillBar.Size = UDim2.new(1, 0, fillPercent, 0)
    fillBar.Position = UDim2.new(0, 0, 1 - fillPercent, 0)
    fillBar.BackgroundColor3 = PRIMARY_COLOR
    fillBar.Parent = sliderBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fillBar

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 22, 0, 22)
    sliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderBtn.Position = UDim2.new(0.5, 0, 1 - fillPercent, 0)
    sliderBtn.BackgroundColor3 = PRIMARY_COLOR
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = sliderBtn

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 55, 0, 20)
    valueLabel.Position = UDim2.new(0, xPosition + 12, 0, yPosition + height + 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.1f", defaultValue)
    valueLabel.TextColor3 = PRIMARY_COLOR
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = parent

    local currentValue = defaultValue
    local dragging = false

    local function updateValue(newValue)
        currentValue = math.clamp(newValue, minValue, maxValue)
        local percent = (currentValue - minValue) / (maxValue - minValue)

        valueLabel.Text = string.format("%.1f", currentValue)
        fillBar.Size = UDim2.new(1, 0, percent, 0)
        fillBar.Position = UDim2.new(0, 0, 1 - percent, 0)
        sliderBtn.Position = UDim2.new(0.5, 0, 1 - percent, 0)

        if callback then
            callback(currentValue)
        end
    end

    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    sliderBtn.MouseButton1Up:Connect(function()
        dragging = false
    end)

    sliderBtn.MouseLeave:Connect(function()
        dragging = false
    end)

    sliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    sliderContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    sliderContainer.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.Y
            local sliderAbsPos = sliderBg.AbsolutePosition.Y
            local sliderHeight = sliderBg.AbsoluteSize.Y
            local relativeY = (mousePos - sliderAbsPos) / sliderHeight
            local newValue = maxValue - (relativeY * (maxValue - minValue))
            updateValue(newValue)
        end
    end)

    return updateValue, currentValue
end

local function createMenuUI(parent, isSettingsMenu)
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = isSettingsMenu and "SettingsMenu" or "SpawnMenu"
    menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    menuFrame.BackgroundColor3 = BG_COLOR
    menuFrame.BackgroundTransparency = 1
    menuFrame.BorderSizePixel = 0
    menuFrame.Size = UDim2.new(0, 0, 0, 0)
    menuFrame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = menuFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = PRIMARY_COLOR
    stroke.Thickness = 2
    stroke.Transparency = 1
    stroke.Parent = menuFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Text = isSettingsMenu and "Cài đặt Lock On" or "Chọn chế độ Lock On"
    title.TextColor3 = TEXT_COLOR
    title.TextTransparency = 1
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = menuFrame

    local leftPanelWidth = 65
    local rightPanelX = leftPanelWidth + 5
    local rightPanelWidth = 245

    local function createMiniButton(parent, text, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, rightPanelWidth, 0, 35)
        btn.Position = UDim2.new(0, rightPanelX, 0, yPos)
        btn.BackgroundColor3 = SECONDARY_COLOR
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = TEXT_COLOR
        btn.TextTransparency = 1
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = parent
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        return btn
    end

    local btn1 = createMiniButton(menuFrame, "Chế độ 1 - Chỉ Camera", 45)
    local btn2 = createMiniButton(menuFrame, "Chế độ 2 - Camera + Nhân vật", 85)
    local btn3 = createMiniButton(menuFrame, "Chế độ 3 - Chỉ Nhân vật", 125)

    local function highlightCurrentMode()
        for _, btn in ipairs({btn1, btn2, btn3}) do
            btn.BackgroundColor3 = SECONDARY_COLOR
        end
        if lockMode == 1 then
            btn1.BackgroundColor3 = PRIMARY_COLOR
        elseif lockMode == 2 then
            btn2.BackgroundColor3 = PRIMARY_COLOR
        elseif lockMode == 3 then
            btn3.BackgroundColor3 = PRIMARY_COLOR
        end
    end
    highlightCurrentMode()

    local tempCamSmooth = CamSmooth
    local tempCharSmooth = CharSmooth
    local tempCameraHeight = CameraHeight

    createMiniSlider(menuFrame, "Độ mượt Camera", 0.1, 3.0, CamSmooth, rightPanelX, 175, rightPanelWidth,
        function(value)
            tempCamSmooth = value
        end
    )

    createMiniSlider(menuFrame, "Độ mượt Xoay người", 0.1, 3.0, CharSmooth, rightPanelX, 225, rightPanelWidth,
        function(value)
            tempCharSmooth = value
        end
    )

    local updateHeightSlider
    updateHeightSlider, _ = createVerticalSlider(menuFrame, "Đ ộ   c a o   C a m e r a", -10, 10, CameraHeight, 5, 50, 210,
        function(value)
            tempCameraHeight = value
            CameraHeight = value
        end
    )

    local menuWidth = leftPanelWidth + rightPanelWidth + 20
    local menuHeight = 300

    local tweenInSize = TweenService:Create(menuFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, menuWidth, 0, menuHeight) })

    local tweenInBg = TweenService:Create(menuFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundTransparency = 0 })

    local tweenInStroke = TweenService:Create(stroke,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Transparency = 0 })

    local tweenInTitle = TweenService:Create(title,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { TextTransparency = 0 })

    local function animateButtonsIn()
        for _, btn in ipairs({ btn1, btn2, btn3 }) do
            TweenService:Create(btn,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = 0 }):Play()
            TweenService:Create(btn,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { TextTransparency = 0 }):Play()
        end
    end

    tweenInSize:Play()
    tweenInBg:Play()
    tweenInStroke:Play()
    tweenInTitle:Play()

    delay(0.15, animateButtonsIn)

    return menuFrame, btn1, btn2, btn3, function()
        CamSmooth = tempCamSmooth
        CharSmooth = tempCharSmooth
        CameraHeight = tempCameraHeight
    end, updateHeightSlider
end

local function createToggleAndUI()
    updateModeFlags()

    if toggleBtn then
        toggleBtn:Destroy()
    end

    toggleBtn = Instance.new("ImageButton")
    toggleBtn.Size = UDim2.new(0, 85, 0, 85)
    toggleBtn.Position = UDim2.new(1, -95, 0, 10)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Image = "rbxassetid://110432273832755"
    toggleBtn.ScaleType = Enum.ScaleType.Fit
    toggleBtn.Visible = true
    toggleBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBtn

    billboard = Instance.new("BillboardGui")
    billboard.Name = "LockOnIndicator"
    billboard.StudsOffset = Vector3.new(0, 0, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Enabled = false
    billboard.Parent = screenGui

    local indImage = Instance.new("ImageLabel")
    indImage.Size = UDim2.new(1, 0, 1, 0)
    indImage.BackgroundTransparency = 1
    indImage.Image = "rbxassetid://100230908593841"
    indImage.ImageTransparency = 0.1
    indImage.ImageColor3 = PRIMARY_COLOR
    indImage.Parent = billboard

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indImage

    local dragging, dragStart, startPos

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = toggleBtn.Position
        end
    end)

    toggleBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local function toggleEnabled()
        if lockMode == 0 then
            StarterGui:SetCore("SendNotification", {
                Title = "Chưa chọn chế độ",
                Text = "Vui lòng chọn chế độ Lock On trước khi sử dụng",
                Icon = "rbxassetid://124076134701198",
                Duration = 3
            })
            return
        end

        Enabled = not Enabled
        if Enabled then
            LockedTarget = findClosestTarget()
        else
            LockedTarget = nil
            if isCameraMode then
                forceInstantReset()
            end
            if billboard then
                billboard.Enabled = false
            end
        end
        toggleBtn.Image = Enabled and "rbxassetid://139332620449694" or "rbxassetid://110432273832755"
    end

    toggleBtn.MouseButton1Click:Connect(toggleEnabled)

    local keyConnection
    keyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.L then
            toggleEnabled()
        end
    end)
    table.insert(connections, keyConnection)
end

local function createSpawnMenu()
    local menuFrame, btn1, btn2, btn3, applySettings, updateHeightSlider = createMenuUI(screenGui, false)

    if updateHeightSlider then
        updateHeightSlider(CameraHeight)
    end

    local function closeSpawnMenu()
        local stroke = menuFrame:FindFirstChildWhichIsA("UIStroke")
        local title = menuFrame:FindFirstChildWhichIsA("TextLabel")

        local tweenOutSize = TweenService:Create(menuFrame,
            TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { Size = UDim2.new(0, 0, 0, 0) })

        local tweenOutBg = TweenService:Create(menuFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 })

        if stroke then
            TweenService:Create(stroke,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Transparency = 1 }):Play()
        end

        if title then
            TweenService:Create(title,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { TextTransparency = 1 }):Play()
        end

        for _, child in ipairs(menuFrame:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }):Play()
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }):Play()
            elseif child:IsA("TextLabel") and child ~= title then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }):Play()
            elseif child:IsA("Frame") then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }):Play()
            end
        end

        tweenOutSize.Completed:Connect(function()
            menuFrame:Destroy()
            isFirstTime = false
        end)

        tweenOutSize:Play()
        tweenOutBg:Play()
    end

    local function escolherModo(modo)
        applySettings()
        lockMode = modo
        updateModeFlags()

        createToggleAndUI()

        StarterGui:SetCore("SendNotification", {
            Title = "Lock On đã khởi tạo",
            Text = "Chế độ " .. modo .. " | Cam: " .. string.format("%.2f", CamSmooth) .. " | Xoay: " .. string.format("%.2f", CharSmooth) .. " | Độ cao: " .. string.format("%.1f", CameraHeight) .. "\nNhấn phím L để bật/tắt",
            Icon = "rbxassetid://124076134701198",
            Duration = 5
        })

        closeSpawnMenu()
    end

    btn1.MouseButton1Click:Connect(function() escolherModo(1) end)
    btn2.MouseButton1Click:Connect(function() escolherModo(2) end)
    btn3.MouseButton1Click:Connect(function() escolherModo(3) end)
end

local function createSettingsMenu()
    if settingsMenuFrame then
        settingsMenuFrame:Destroy()
        settingsMenuFrame = nil
    end

    local menuFrame, btn1, btn2, btn3, applySettings, updateHeightSlider = createMenuUI(screenGui, true)
    settingsMenuFrame = menuFrame
    settingsMenuVisible = true

    if updateHeightSlider then
        updateHeightSlider(CameraHeight)
    end

    local function closeSettingsMenu()
        local stroke = menuFrame:FindFirstChildWhichIsA("UIStroke")
        local title = menuFrame:FindFirstChildWhichIsA("TextLabel")

        local tweenOutSize = TweenService:Create(menuFrame,
            TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { Size = UDim2.new(0, 0, 0, 0) })

        local tweenOutBg = TweenService:Create(menuFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 })

        if stroke then
            TweenService:Create(stroke,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Transparency = 1 }):Play()
        end

        if title then
            TweenService:Create(title,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { TextTransparency = 1 }):Play()
        end

        for _, child in ipairs(menuFrame:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }):Play()
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }):Play()
            elseif child:IsA("TextLabel") and child ~= title then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }):Play()
            elseif child:IsA("Frame") then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }):Play()
            end
        end

        tweenOutSize.Completed:Connect(function()
            if settingsMenuFrame then
                settingsMenuFrame:Destroy()
                settingsMenuFrame = nil
                settingsMenuVisible = false
            end
        end)

        tweenOutSize:Play()
        tweenOutBg:Play()
        settingsMenuVisible = false
    end

    local function escolherModo(modo)
        applySettings()
        lockMode = modo
        updateModeFlags()

        if not toggleBtn or not toggleBtn.Parent then
            createToggleAndUI()
        end

        StarterGui:SetCore("SendNotification", {
            Title = "Lock On đã cập nhật",
            Text = "Chế độ " .. modo .. " | Cam: " .. string.format("%.2f", CamSmooth) .. " | Xoay: " .. string.format("%.2f", CharSmooth) .. " | Độ cao: " .. string.format("%.1f", CameraHeight) .. "\nNhấn phím L để bật/tắt",
            Icon = "rbxassetid://124076134701198",
            Duration = 5
        })

        closeSettingsMenu()
    end

    btn1.MouseButton1Click:Connect(function() escolherModo(1) end)
    btn2.MouseButton1Click:Connect(function() escolherModo(2) end)
    btn3.MouseButton1Click:Connect(function() escolherModo(3) end)
end

local function toggleSettingsMenu()
    if settingsMenuVisible and settingsMenuFrame then
        local stroke = settingsMenuFrame:FindFirstChildWhichIsA("UIStroke")
        local title = settingsMenuFrame:FindFirstChildWhichIsA("TextLabel")

        local tweenOutSize = TweenService:Create(settingsMenuFrame,
            TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { Size = UDim2.new(0, 0, 0, 0) })

        local tweenOutBg = TweenService:Create(settingsMenuFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 })

        if stroke then
            TweenService:Create(stroke,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Transparency = 1 }):Play()
        end

        if title then
            TweenService:Create(title,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { TextTransparency = 1 }):Play()
        end

        for _, child in ipairs(settingsMenuFrame:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }):Play()
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }):Play()
            elseif child:IsA("TextLabel") and child ~= title then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }):Play()
            elseif child:IsA("Frame") then
                TweenService:Create(child,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }):Play()
            end
        end

        tweenOutSize.Completed:Connect(function()
            if settingsMenuFrame then
                settingsMenuFrame:Destroy()
                settingsMenuFrame = nil
                settingsMenuVisible = false
            end
        end)

        tweenOutSize:Play()
        tweenOutBg:Play()
        settingsMenuVisible = false
    else
        createSettingsMenu()
    end
end

local function createSettingsButton()
    if settingsBtn then
        settingsBtn:Destroy()
    end

    local isDragging = false
    local dragStartPos = nil
    local startBtnPos = nil

    settingsBtn = Instance.new("ImageButton")
    settingsBtn.Name = "SettingsButton"
    settingsBtn.Size = UDim2.new(0, 40, 0, 40)
    settingsBtn.Position = UDim2.new(0, 10, 0, 10)
    settingsBtn.BackgroundTransparency = 1
    settingsBtn.Image = "rbxassetid://139332620449694"
    settingsBtn.ScaleType = Enum.ScaleType.Fit
    settingsBtn.ImageColor3 = PRIMARY_COLOR
    settingsBtn.Visible = true
    settingsBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = settingsBtn

    settingsBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = input.Position
            startBtnPos = settingsBtn.Position
        end
    end)

    settingsBtn.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            settingsBtn.Position = UDim2.new(
                startBtnPos.X.Scale, 
                startBtnPos.X.Offset + delta.X, 
                startBtnPos.Y.Scale, 
                startBtnPos.Y.Offset + delta.Y
            )
        end
    end)

    settingsBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDragging and dragStartPos and startBtnPos then
                local delta = input.Position - dragStartPos
                local totalDelta = math.abs(delta.X) + math.abs(delta.Y)
                if totalDelta < 5 then
                    toggleSettingsMenu()
                end
            end
            isDragging = false
            dragStartPos = nil
            startBtnPos = nil
        end
    end)
end

function LockOnSystem.Cleanup()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}

    if screenGui then
        screenGui:Destroy()
    end
    if pingFpsGui then
        pingFpsGui:Destroy()
    end

    forceInstantReset()

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = true
        end
    end
end

initScreenGui()
createPingFpsDisplay()
createSettingsButton()
createSpawnMenu()

if LocalPlayer.Character then
    setupDeathHandler(LocalPlayer.Character)
end
local charAddConnection
charAddConnection = LocalPlayer.CharacterAdded:Connect(setupDeathHandler)
table.insert(connections, charAddConnection)

local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local isLocking = LockedTarget and LockedTarget.Parent

            if isCharacterMode then
                if isLocking then
                    humanoid.AutoRotate = false
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local neckPos = getNeckPosition(LockedTarget)
                        if neckPos then
                            local direction = neckPos - rootPart.Position
                            local horizontalDir = Vector3.new(direction.X, 0, direction.Z)
                            local mag = horizontalDir.Magnitude
                            if mag > 0.1 then
                                horizontalDir = horizontalDir / mag
                                local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + horizontalDir)
                                rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, CharSmooth)
                            end
                        end
                    end
                else
                    humanoid.AutoRotate = true
                end
            else
                humanoid.AutoRotate = true
            end
        end
    end

    if not Enabled then
        if billboard then
            billboard.Enabled = false
        end
        return
    end

    local now = tick()
    if now - lastSearchTime > SEARCH_RATE then
        if not isValidTarget(LockedTarget) then
            LockedTarget = findClosestTarget()
        end
        lastSearchTime = now
    end

    if LockedTarget and LockedTarget.Parent and isCameraMode then
        forceInstantReset()

        local lockPos = getCameraLockPosition(LockedTarget)
        if lockPos then
            local rightVec = Camera.CFrame.RightVector
            local targetPos = lockPos - (rightVec * CAMERA_LEFT_OFFSET)
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, CamSmooth)
        end
    end

    if LockedTarget and LockedTarget.Parent and showBillboard then
        local characterTarget = LockedTarget.Parent
        local adorneePart = getLockAdornee(characterTarget)

        if adorneePart then
            billboard.Adornee = adorneePart
            billboard.Enabled = true

            local scaleFactor = 5.0
            local humanoid = characterTarget:FindFirstChildOfClass("Humanoid")
            local headPart = LockedTarget

            if humanoid and headPart and characterTarget:FindFirstChild("HumanoidRootPart") then
                local rootPart = characterTarget:FindFirstChild("HumanoidRootPart")
                local feetY = rootPart.Position.Y - humanoid.HipHeight
                local headTopY = headPart.Position.Y + (headPart.Size.Y / 2)
                scaleFactor = headTopY - feetY
            elseif adorneePart then
                scaleFactor = adorneePart.Size.Y * 2.5
            end
            scaleFactor = math.clamp(scaleFactor, 3.0, 10.0)

            local distance = (Camera.CFrame.Position - adorneePart.Position).Magnitude
            local distanceMultiplier = 1400 / (distance + 8)
            local finalSize = distanceMultiplier * scaleFactor

            billboard.Size = UDim2.new(0, finalSize, 0, finalSize)
        else
            billboard.Enabled = false
        end
    else
        if billboard then
            billboard.Enabled = false
        end
    end
end)
table.insert(connections, renderConnection)
