-- Movement GUI Loader with PC detection, minimize, and auto-close on PC
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local CG = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Create GUI
local gui = Instance.new("ScreenGui", CG)
gui.Name = "MovementGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Frame ngoài (viền gradient)
local BorderFrame = Instance.new("Frame", gui)
BorderFrame.Size = UDim2.new(0, 224, 0, 104)
BorderFrame.Position = UDim2.new(0.5, -112, 0.5, -52)
BorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BorderFrame.BorderSizePixel = 0
BorderFrame.Active = true
BorderFrame.Draggable = true
BorderFrame.ZIndex = 3
local BorderCorner = Instance.new("UICorner", BorderFrame)
BorderCorner.CornerRadius = UDim.new(0, 12)

-- Gradient cho viền
local StrokeGradient = Instance.new("UIGradient", BorderFrame)
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),  -- Tím
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 220)), -- Xanh mint
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 200))  -- Tím
})
StrokeGradient.Rotation = 45

-- Hiệu ứng xoay gradient
local rotation = 0
local gradientConnection
gradientConnection = RunService.RenderStepped:Connect(function(dt)
    if BorderFrame and BorderFrame.Parent then
        rotation = (rotation + dt * 60) % 360
        StrokeGradient.Rotation = rotation
    end
end)

-- Frame bên trong (màu đen)
local MainFrame = Instance.new("Frame", BorderFrame)
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0, 2, 0, 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 4
local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Title với hiệu ứng sáng
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "Movement GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.ZIndex = 5

-- Gradient sáng cho chữ
local TitleGradient = Instance.new("UIGradient", Title)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 100, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 200))
})
TitleGradient.Rotation = 30

-- Hiệu ứng chạy sáng cho chữ
task.spawn(function()
    while Title and Title.Parent do
        TitleGradient.Offset = Vector2.new(-1.5, 0)
        local tween = TweenService:Create(TitleGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Offset = Vector2.new(1.5, 0)})
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.3)
    end
end)

-- Header buttons
local closeBtn = Instance.new("TextButton", MainFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 5)
closeBtn.Text = "×"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 5
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
end)

local minimizeBtn = Instance.new("TextButton", MainFrame)
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -56, 0, 5)
minimizeBtn.Text = "–"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 5
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

-- Movement button
local moveBtn = Instance.new("TextButton", MainFrame)
moveBtn.Size = UDim2.new(0, 180, 0, 40)
moveBtn.Position = UDim2.new(0.5, -90, 0, 45)
moveBtn.Text = "Movement"
moveBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
moveBtn.TextColor3 = Color3.new(1, 1, 1)
moveBtn.Font = Enum.Font.SourceSansBold
moveBtn.TextSize = 18
moveBtn.BorderSizePixel = 0
moveBtn.ZIndex = 5
Instance.new("UICorner", moveBtn).CornerRadius = UDim.new(0, 8)
moveBtn.MouseButton1Click:Connect(function()
    moveBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    task.wait(0.1)
    moveBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
end)

-- Remove phím button (ẩn ban đầu)
local removeBtn = Instance.new("TextButton", MainFrame)
removeBtn.Size = UDim2.new(0, 180, 0, 30)
removeBtn.Position = UDim2.new(0.5, -90, 0, 95)
removeBtn.Text = "Xóa phím"
removeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
removeBtn.TextColor3 = Color3.new(1, 1, 1)
removeBtn.Font = Enum.Font.SourceSansBold
removeBtn.TextSize = 14
removeBtn.BorderSizePixel = 0
removeBtn.Visible = false
removeBtn.ZIndex = 5
Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 8)

-- Circle button khi minimize
local circleBtn = Instance.new("TextButton", gui)
circleBtn.Size = UDim2.new(0, 40, 0, 40)
circleBtn.Position = UDim2.new(0.5, -20, 0.5, -20)
circleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
circleBtn.Text = "+"
circleBtn.TextColor3 = Color3.new(1, 1, 1)
circleBtn.Font = Enum.Font.SourceSansBold
circleBtn.TextSize = 24
circleBtn.Visible = false
circleBtn.Draggable = true
circleBtn.Active = true
circleBtn.BorderSizePixel = 0
circleBtn.ZIndex = 5
Instance.new("UICorner", circleBtn).CornerRadius = UDim.new(1, 0)

-- Thêm gradient stroke cho circle
local circleStroke = Instance.new("UIStroke", circleBtn)
circleStroke.Thickness = 2
local circleGradient = Instance.new("UIGradient", circleStroke)
circleGradient.Color = StrokeGradient.Color

-- Minimize logic
minimizeBtn.MouseButton1Click:Connect(function()
        BorderFrame.Visible = false
        circleBtn.Position = UDim2.new(0, BorderFrame.AbsolutePosition.X, 0, BorderFrame.AbsolutePosition.Y)
        circleBtn.Visible = true
end)

circleBtn.MouseButton1Click:Connect(function()
        BorderFrame.Position = UDim2.new(0, circleBtn.AbsolutePosition.X, 0, circleBtn.AbsolutePosition.Y)
        BorderFrame.Visible = true
        circleBtn.Visible = false
end)

-- Load Movement Script (mobile only)
local function loadMovementScript()
        if UIS.KeyboardEnabled and not UIS.TouchEnabled then
                StarterGui:SetCore("SendNotification", {
                        Title = "No need.";
                        Text = "You're already on PC!";
                        Duration = 4;
                })
                gui:Destroy()
        else
                -- Mở rộng frame
                BorderFrame.Size = UDim2.new(0, 224, 0, 144)
                MainFrame.Size = UDim2.new(1, -4, 1, -4)
                removeBtn.Visible = true

                -- Drag Utility Function
                local function makeDraggable(dragFrame)
                        local dragging, dragStart, startPos

                        dragFrame.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                        dragging = true
                                        dragStart = input.Position
                                        startPos = dragFrame.Position

                                        input.Changed:Connect(function()
                                                if input.UserInputState == Enum.UserInputState.End then
                                                        dragging = false
                                                end
                                        end)
                                end
                        end)

                        game:GetService("UserInputService").InputChanged:Connect(function(input)
                                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                        local delta = input.Position - dragStart
                                        dragFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                                end
                        end)
                end

                -- Key Button Creator
                local function createKeyButton(parent, keyText, keyCode, position, size)
                        local button = Instance.new("TextButton")
                        button.Size = size or UDim2.new(0, 55, 0, 55)
                        button.Position = position
                        button.Text = keyText
                        button.Font = Enum.Font.SourceSansBold
                        button.TextSize = 26
                        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        button.TextColor3 = Color3.new(1, 1, 1)
                        button.BorderSizePixel = 0
                        button.Parent = parent
                        button.ZIndex = 5
                        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)

                        -- Thêm stroke nhẹ cho nút
                        local btnStroke = Instance.new("UIStroke", button)
                        btnStroke.Color = Color3.fromRGB(80, 80, 80)
                        btnStroke.Thickness = 1

                        button.MouseButton1Down:Connect(function()
                                pcall(function() keypress(keyCode) end)
                                button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                        end)
                        button.MouseButton1Up:Connect(function()
                                pcall(function() keyrelease(keyCode) end)
                                button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        end)
                end

                -- GUI setup
                local keyGui = Instance.new("ScreenGui", game.CoreGui)
                keyGui.Name = "WASDQESpaceGui"
                keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

                -- === WASD Panel ===
                local wasdFrame = Instance.new("Frame")
                wasdFrame.Size = UDim2.new(0, 200, 0, 200)
                wasdFrame.Position = UDim2.new(0, 10, 1, -210)
                wasdFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                wasdFrame.BackgroundTransparency = 1
                wasdFrame.BorderSizePixel = 0
                wasdFrame.Active = true
                wasdFrame.Draggable = false
                wasdFrame.Parent = keyGui
                wasdFrame.ZIndex = 3
                makeDraggable(wasdFrame)

                local wasdContent = Instance.new("Frame", wasdFrame)
                wasdContent.Position = UDim2.new(0, 0, 0, 10)
                wasdContent.Size = UDim2.new(1, 0, 1, -10)
                wasdContent.BackgroundTransparency = 1
                wasdContent.ZIndex = 4

                -- WASD layout
                createKeyButton(wasdContent, "W", 0x57, UDim2.new(0.33, 0, 0, 0))
                createKeyButton(wasdContent, "A", 0x41, UDim2.new(0, 0, 0, 65))
                createKeyButton(wasdContent, "S", 0x53, UDim2.new(0.33, 0, 0, 65))
                createKeyButton(wasdContent, "D", 0x44, UDim2.new(0.66, 0, 0, 65))

                -- === QE Panel ===
                local qeFrame = Instance.new("Frame")
                qeFrame.Size = UDim2.new(0, 100, 0, 250)
                qeFrame.Position = UDim2.new(1, -110, 1, -260)
                qeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                qeFrame.BackgroundTransparency = 1
                qeFrame.BorderSizePixel = 0
                qeFrame.Active = true
                qeFrame.Draggable = false
                qeFrame.Parent = keyGui
                qeFrame.ZIndex = 3
                makeDraggable(qeFrame)

                local qeContent = Instance.new("Frame", qeFrame)
                qeContent.Position = UDim2.new(0, 0, 0, 10)
                qeContent.Size = UDim2.new(1, 0, 1, -10)
                qeContent.BackgroundTransparency = 1
                qeContent.ZIndex = 4

                -- E, Q, Space layout
                createKeyButton(qeContent, "E", 0x45, UDim2.new(0.2, 0, 0, 0))
                createKeyButton(qeContent, "Q", 0x51, UDim2.new(0.2, 0, 0, 65))
                createKeyButton(qeContent, "Space", 0x20, UDim2.new(0, 10, 0, 135), UDim2.new(0, 80, 0, 50))

                -- Nút Xóa phím
                removeBtn.MouseButton1Click:Connect(function()
                        keyGui:Destroy()
                        removeBtn.Visible = false
                        BorderFrame.Size = UDim2.new(0, 224, 0, 104)
                        MainFrame.Size = UDim2.new(1, -4, 1, -4)
                end)
        end
end

-- Movement button
moveBtn.MouseButton1Click:Connect(loadMovementScript)

-- Force notification + auto-close via /e pctest
LocalPlayer.Chatted:Connect(function(msg)
        if msg:lower() == "/e pctest" then
                StarterGui:SetCore("SendNotification", {
                        Title = "No need.";
                        Text = "You're already on PC!";
                        Duration = 4;
                })
                gui:Destroy()
        end
end)

-- Optional: Auto-close immediately if on PC
if UIS.KeyboardEnabled and not UIS.TouchEnabled then
        StarterGui:SetCore("SendNotification", {
                Title = "No need.";
                Text = "You're already on PC!";
                Duration = 4;
        })
        gui:Destroy()
end

-- Cleanup
gui.Destroying:Connect(function()
    if gradientConnection then
        gradientConnection:Disconnect()
    end
end)