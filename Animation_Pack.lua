local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

local PACKS = {
        ["Adidas Sports"] = {
                WalkAnim = 18537392113,
                RunAnim  = 18537384940,
                JumpAnim = 18537380791,
                FallAnim = 18537367238,
                SwimIdle = 18537387180,
                Swim     = 18537389531,
                Animation1 = 18537376492,
                Animation2 = 18537371272,
                ClimbAnim = 18537363391,
        },
        ["Adidas Community"] = {
                WalkAnim = 122150855457006,
                RunAnim  = 82598234841035,
                JumpAnim = 75290611992385,
                FallAnim = 98600215928904,
                SwimIdle = 109346520324160,
                Swim     = 133308483266208,
                Animation1 = 122257458498464,
                Animation2 = 102357151005774,
                ClimbAnim = 88763136693023,
        },
        ["Adidas Aura"] = {
                WalkAnim = 83842218823011,
                RunAnim  = 118320322718866,
                JumpAnim = 109996626521204,
                FallAnim = 95603166884636,
                SwimIdle = 94922130551805,
                Swim     = 134530128383903,
                Animation1 = 110211186840347,
                Animation2 = 114191137265065,
                ClimbAnim = 97824616490448,
        },
        ["Wicked Popular"] = {
                WalkAnim = 92072849924640,
                RunAnim = 72301599441680,
                JumpAnim = 104325245285198,
                FallAnim = 121152442762481,
                Animation1 = 118832222982049,
                ClimbAnim = 131326830509784,
                SwimIdle = 113199415118199,
                Swim = 99384245425157,
                Animation2 = 76049494037641,
        },
        Elder = {
                WalkAnim = 10921111375,
                RunAnim  = 10921104374,
                JumpAnim = 10921107367,
                FallAnim = 10921105765,
                SwimIdle = 10921110146,
                Swim     = 10921108971,
                ClimbAnim = 10921100400,
                Animation1 = 10921101664,
                Animation2 = 10921102574,
        },
        Zombie = {
                WalkAnim = 10921355261,
                RunAnim  = 616163682,
                JumpAnim = 10921351278,
                FallAnim = 10921350320,
                SwimIdle = 10921353442,
                Swim     = 10921352344,
                Animation1 = 10921344533,
                Animation2 = 10921345304,
                ClimbAnim = 10921343576,
        },
        Mage = {
                WalkAnim = 10921152678,
                RunAnim  = 10921148209,
                JumpAnim = 10921149743,
                FallAnim = 10921148939,
                SwimIdle = 10921151661,
                Swim     = 10921150788,
                ClimbAnim = 10921143404,
                Animation1 = 10921144709,
                Animation2 = 10921145797,
        },
        ["Catwalk Glam"] = {
                WalkAnim = 109168724482748,
                RunAnim  = 81024476153754,
                JumpAnim = 116936326516985,
                FallAnim = 92294537340807,
                SwimIdle = 98854111361360,
                Swim     = 134591743181628,
                ClimbAnim = 119377220967554,
                Animation1 = 133806214992291,
                Animation2 = 94970088341563,
        },
        Astronaut = {
                WalkAnim = 10921046031,
                RunAnim  = 10921039308,
                JumpAnim = 10921042494,
                FallAnim = 10921040576,
                SwimIdle = 10921045006,
                Swim     = 10921044000,
                ClimbAnim = 10921032124,
                Animation1 = 10921034824,
                Animation2 = 10921036806,
        },
        ['Wicked "Dancing Through Life"'] = {
                WalkAnim = 73718308412641,
                RunAnim  = 135515454877967,
                JumpAnim = 78508480717326,
                FallAnim = 78147885297412,
                SwimIdle = 129183123083281,
                Swim     = 110657013921774,
                ClimbAnim = 129447497744818,
                Animation1 = 92849173543269,
                Animation2 = 132238900951109,
        },
        Werewolf = {
                WalkAnim = 10921342074,
                RunAnim  = 10921336997,
                JumpAnim = nil,
                FallAnim = 10921337907,
                SwimIdle = 10921341319,
                Swim     = 10921340419,
                ClimbAnim = 10921329322,
                Animation1 = 10921330408,
                Animation2 = 10921333667,
        },
        Superhero = {
                WalkAnim = 10921298616,
                RunAnim  = 10921291831,
                JumpAnim = 10921294559,
                FallAnim = 10921293373,
                SwimIdle = 10921297391,
                Swim     = 10921295495,
                ClimbAnim = 10921286911,
                Animation1 = 10921288909,
                Animation2 = 10921290167,
        },
        Toy = {
                WalkAnim = 10921312010,
                RunAnim  = 10921306285,
                JumpAnim = 10921308158,
                FallAnim = 10921307241,
                SwimIdle = 10921310341,
                Swim     = 10921309319,
                ClimbAnim = 10921300839,
                Animation1 = 10921301576,
                Animation2 = nil,
        },
        ["No Boundaries"] = {
                WalkAnim = 18747074203,
                RunAnim  = 18747070484,
                JumpAnim = 18747069148,
                FallAnim = 18747062535,
                SwimIdle = 18747071682,
                Swim     = 18747073181,
                ClimbAnim = 18747060903,
                Animation1 = 18747067405,
                Animation2 = 18747063918,
        },
        NFL = {
                WalkAnim = 110358958299415,
                RunAnim  = 117333533048078,
                JumpAnim = 119846112151352,
                FallAnim = 129773241321032,
                SwimIdle = 79090109939093,
                Swim     = 132697394189921,
                ClimbAnim = 134630013742019,
                Animation1 = 92080889861410,
                Animation2 = 74451233229259,
        },
        ["Amazon Unboxed"] = {
                WalkAnim = 90478085024465,
                RunAnim  = 134824450619865,
                JumpAnim = 121454505477205,
                FallAnim = 94788218468396,
                SwimIdle = 129126268464847,
                Swim     = 105962919001086,
                ClimbAnim = 121145883950231,
                Animation1 = 98281136301627,
                Animation2 = nil,
        },
        Vampire = {
                WalkAnim = 10921326949,
                RunAnim  = 10921320299,
                JumpAnim = 10921322186,
                FallAnim = 10921321317,
                SwimIdle = 10921325443,
                Swim     = 10921324408,
                ClimbAnim = 10921314188,
                Animation1 = 10921315373,
                Animation2 = nil,
        },
        ["Ninja"] = {
                Run=656118852, Walk=656121766, Jump=656117878, Fall=656115606,
                Swim=656119721, SwimIdle=656121397, Climb=656114359,
                Idle={656117400,656118341,886742569}
        },
        ["Robot"] = {
                Run=616091570, Walk=616095330, Jump=616090535, Fall=616087089,
                Swim=616092998, SwimIdle=616094091, Climb=616086039,
                Idle={616088211,616089559,885531463}
        },
        ["Levitation"] = {
                Run=616010382, Walk=616013216, Jump=616008936, Fall=616005863,
                Swim=616011509, SwimIdle=616012453, Climb=616003713,
                Idle={616006778,616008087,886862142}
        },
        ["Stylish"] = {
                Run=616140816, Walk=616146177, Jump=616139451, Fall=616134815,
                Swim=616143378, SwimIdle=616144772, Climb=616133594,
                Idle={616136790,616138447,886888594}
        },
        ["Bubbly"] = {
                Run=910025107, Walk=910034870, Jump=910016857, Fall=910001910,
                Swim=910028158, SwimIdle=910030921, Climb=909997997,
                Idle={910004836,910009958,1018536639}
        },
        ["Cartoon"] = {
                Run=742638842, Walk=742640026, Jump=742637942, Fall=742637151,
                Swim=742639220, SwimIdle=742639812, Climb=742636889,
                Idle={742637544,742638445,885477856}
        },
}

local DEFAULT_ANIMS = {
        WalkAnim = 8913843362,
        RunAnim = 8913846406,
        JumpAnim = 8913844767,
        FallAnim = 8913843030,
        SwimIdle = 8913848098,
        Swim = 8913847316,
        Animation1 = 8913837058,
        Animation2 = 8913838814,
        ClimbAnim = 8913834912,
}

local basicFlySpeed = 50
local isBasicFlying = false
local basicFlyVelocityHandler, basicFlyOrientationHandler, basicFlyAttachment, basicFlyConnection
local walkTrack, runTrack, idleTrack, jumpTrack, basicFlyIdleTrack, basicFlyMoveTrack

local function stopBasicFlying(humanoid)
    isBasicFlying = false
    if basicFlyIdleTrack and basicFlyIdleTrack.IsPlaying then basicFlyIdleTrack:Stop() end
    if basicFlyMoveTrack and basicFlyMoveTrack.IsPlaying then basicFlyMoveTrack:Stop() end

    if basicFlyVelocityHandler then basicFlyVelocityHandler:Destroy(); basicFlyVelocityHandler = nil end
    if basicFlyOrientationHandler then basicFlyOrientationHandler:Destroy(); basicFlyOrientationHandler = nil end
    if basicFlyAttachment then basicFlyAttachment:Destroy(); basicFlyAttachment = nil end
    if basicFlyConnection then basicFlyConnection:Disconnect(); basicFlyConnection = nil end

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true 
    end
end

local function startBasicFlying(character, humanoid)
    local rootPart = character:WaitForChild("HumanoidRootPart")
    isBasicFlying = true

    if walkTrack and walkTrack.IsPlaying then walkTrack:Stop() end
    if runTrack and runTrack.IsPlaying then runTrack:Stop() end
    if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
    if jumpTrack and jumpTrack.IsPlaying then jumpTrack:Stop() end
    if basicFlyIdleTrack then basicFlyIdleTrack:Play() end

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false 

    basicFlyAttachment = Instance.new("Attachment")
    basicFlyAttachment.Name = "FlyAttachment"
    basicFlyAttachment.Parent = rootPart

    basicFlyVelocityHandler = Instance.new("LinearVelocity")
    basicFlyVelocityHandler.Name = "FlyVelocity"
    basicFlyVelocityHandler.Attachment0 = basicFlyAttachment
    basicFlyVelocityHandler.MaxForce = 100000 
    basicFlyVelocityHandler.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    basicFlyVelocityHandler.VectorVelocity = Vector3.new(0, 0, 0)
    basicFlyVelocityHandler.Parent = rootPart

    basicFlyOrientationHandler = Instance.new("AlignOrientation")
    basicFlyOrientationHandler.Name = "FlyOrientation"
    basicFlyOrientationHandler.Attachment0 = basicFlyAttachment
    basicFlyOrientationHandler.Mode = Enum.OrientationAlignmentMode.OneAttachment
    basicFlyOrientationHandler.MaxTorque = 100000
    basicFlyOrientationHandler.Responsiveness = 200 
    basicFlyOrientationHandler.CFrame = rootPart.CFrame
    basicFlyOrientationHandler.Parent = rootPart

    basicFlyConnection = RunService.RenderStepped:Connect(function()
        if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then
            stopBasicFlying(humanoid)
            return
        end

        local camera = workspace.CurrentCamera
        local moveVector = controls:GetMoveVector() 

        if moveVector.Magnitude > 0 then
            if basicFlyIdleTrack and basicFlyIdleTrack.IsPlaying then basicFlyIdleTrack:Stop() end
            if basicFlyMoveTrack then basicFlyMoveTrack:Play() end

            local camCFrame = camera.CFrame
            local flyDir = (camCFrame * CFrame.new(moveVector)).Position - camCFrame.Position
            basicFlyVelocityHandler.VectorVelocity = flyDir.Unit * basicFlySpeed
            basicFlyOrientationHandler.CFrame = camCFrame 
        else
            if basicFlyMoveTrack and basicFlyMoveTrack.IsPlaying then basicFlyMoveTrack:Stop() end
            if basicFlyIdleTrack then basicFlyIdleTrack:Play() end

            basicFlyVelocityHandler.VectorVelocity = Vector3.new(0, 0, 0)
            basicFlyOrientationHandler.CFrame = camera.CFrame
        end
    end)
end

local advFlySpeed = 50
local isAdvFlying = false
local advForwardHold = 0
local advInputFlags = { forward = false, back = false, left = false, right = false, up = false, down = false }

local advBodyVelocity, advBodyGyro
local advTracks = {}
local advAnimations = {}

local function newAdvAnim(id)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    return anim
end

local function initAdvAnimations()
    advAnimations = {
        forward = newAdvAnim(90872539),
        up = newAdvAnim(90872539),
        right1 = newAdvAnim(136801964),
        right2 = newAdvAnim(142495255),
        left1 = newAdvAnim(136801964),
        left2 = newAdvAnim(142495255),
        flyLow1 = newAdvAnim(97169019),
        flyLow2 = newAdvAnim(282574440),
        flyFast = newAdvAnim(282574440),
        back1 = newAdvAnim(136801964),
        back2 = newAdvAnim(106772613),
        back3 = newAdvAnim(42070810),
        back4 = newAdvAnim(214744412),
        down = newAdvAnim(233322916),
        idle1 = newAdvAnim(97171309)
    }
end
initAdvAnimations()

local function loadAdvTracks(humanoid)
    advTracks = {}
    for name, anim in pairs(advAnimations) do
        advTracks[name] = humanoid:LoadAnimation(anim)
    end
end

local function stopAdvAll()
    for _, track in pairs(advTracks) do
        if track and track.IsPlaying then track:Stop() end
    end
end

local function stopAdvFlying()
    isAdvFlying = false
    if advBodyVelocity then advBodyVelocity.Parent = nil end
    if advBodyGyro then advBodyGyro.Parent = nil end
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    stopAdvAll()
    for k in pairs(advInputFlags) do advInputFlags[k] = false end
    advForwardHold = 0
end

local function startAdvFlying(character, humanoid)
    local HRP = character:WaitForChild("HumanoidRootPart")
    isAdvFlying = true
    advForwardHold = 0
    advFlySpeed = 50

    advBodyVelocity = Instance.new("BodyVelocity")
    advBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    advBodyVelocity.Parent = HRP

    advBodyGyro = Instance.new("BodyGyro")
    advBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    advBodyGyro.Parent = HRP

    humanoid.PlatformStand = true

    if not advTracks.forward then
        loadAdvTracks(humanoid)
    end

    stopAdvAll()
    if advTracks.idle1 then
        advTracks.idle1:Play()
        advTracks.idle1:AdjustSpeed(0)
    end
end

local function updateAdvFly(dt)
    if not isAdvFlying then return end

    local char = player.Character
    if not char then 
        stopAdvFlying()
        return 
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        stopAdvFlying()
        return
    end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local Camera = workspace.CurrentCamera

    advInputFlags.forward = UserInputService:IsKeyDown(Enum.KeyCode.W)
    advInputFlags.back = UserInputService:IsKeyDown(Enum.KeyCode.S)
    advInputFlags.left = UserInputService:IsKeyDown(Enum.KeyCode.A)
    advInputFlags.right = UserInputService:IsKeyDown(Enum.KeyCode.D)
    advInputFlags.up = UserInputService:IsKeyDown(Enum.KeyCode.E)
    advInputFlags.down = UserInputService:IsKeyDown(Enum.KeyCode.Q)

    if not advInputFlags.forward then advForwardHold = 0 end

    local dir = Vector3.zero
    local camCF = Camera.CFrame

    if advInputFlags.forward then dir += camCF.LookVector end
    if advInputFlags.back then dir -= camCF.LookVector end
    if advInputFlags.left then dir -= camCF.RightVector end
    if advInputFlags.right then dir += camCF.RightVector end
    if advInputFlags.up then dir += Vector3.yAxis end
    if advInputFlags.down then dir -= Vector3.yAxis end

    if dir.Magnitude > 0 then dir = dir.Unit end

    advBodyVelocity.Velocity = dir * advFlySpeed
    advBodyGyro.CFrame = camCF

    if advInputFlags.up then
        if not advTracks.up.IsPlaying then stopAdvAll(); advTracks.up:Play() end
    elseif advInputFlags.down then
        if not advTracks.down.IsPlaying then stopAdvAll(); advTracks.down:Play() end
    elseif advInputFlags.left then
        if not advTracks.left1.IsPlaying then
            stopAdvAll()
            advTracks.left1:Play(); advTracks.left1.TimePosition = 2.0; advTracks.left1:AdjustSpeed(0)
            advTracks.left2:Play(); advTracks.left2.TimePosition = 0.5; advTracks.left2:AdjustSpeed(0)
        end
    elseif advInputFlags.right then
        if not advTracks.right1.IsPlaying then
            stopAdvAll()
            advTracks.right1:Play(); advTracks.right1.TimePosition = 1.1; advTracks.right1:AdjustSpeed(0)
            advTracks.right2:Play(); advTracks.right2.TimePosition = 0.5; advTracks.right2:AdjustSpeed(0)
        end
    elseif advInputFlags.back then
        if not advTracks.back1.IsPlaying then
            stopAdvAll()
            advTracks.back1:Play(); advTracks.back1.TimePosition = 5.3; advTracks.back1:AdjustSpeed(0)
            advTracks.back2:Play(); advTracks.back2:AdjustSpeed(0)
            advTracks.back3:Play(); advTracks.back3.TimePosition = 0.8; advTracks.back3:AdjustSpeed(0)
            advTracks.back4:Play(); advTracks.back4.TimePosition = 1; advTracks.back4:AdjustSpeed(0)
        end
    elseif advInputFlags.forward then
        advForwardHold = advForwardHold + dt
        if advForwardHold >= 3 then
            if not advTracks.flyFast.IsPlaying then
                stopAdvAll()
                advFlySpeed = 50 * 1.3
                advTracks.flyFast:Play(); advTracks.flyFast:AdjustSpeed(0.05)
            end
        else
            if not advTracks.flyLow1.IsPlaying then
                stopAdvAll()
                advFlySpeed = 50
                advTracks.flyLow1:Play()
                advTracks.flyLow2:Play()
            end
        end
    else
        if not advTracks.idle1.IsPlaying then
            stopAdvAll()
            advTracks.idle1:Play(); advTracks.idle1:AdjustSpeed(0)
        end
    end
end

local function initBasicFlyTracks()
        local char = player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then return end

        local function loadFlyTrack(id, priority)
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. id
                local track = animator:LoadAnimation(anim)
                track.Looped = true
                track.Priority = priority
                return track
        end

        basicFlyIdleTrack = loadFlyTrack("91106826233224", Enum.AnimationPriority.Action4)
        basicFlyMoveTrack = loadFlyTrack("114833664438028", Enum.AnimationPriority.Action4)
end

local function waitForAnimate(char)
        for _ = 1, 40 do
                local a = char:FindFirstChild("Animate")
                if a and a:FindFirstChild("idle") and a:FindFirstChild("run") and a:FindFirstChild("walk") then
                        return a
                end
                task.wait(0.1)
        end
        return nil
end

local function setAnim(animObj, id)
        if animObj and id then
                animObj.AnimationId = "rbxassetid://" .. tostring(id)
        end
end

local function stopAllTracks(hum)
        if not hum then return end
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
        end
end

local function ensureAnim(folder, name)
        if not folder then return nil end
        local a = folder:FindFirstChild(name)
        if not a then
                a = Instance.new("Animation")
                a.Name = name
                a.Parent = folder
        end
        return a
end

local function ensureIdleSlots(idleFolder, n)
        if not idleFolder then return end
        n = n or 2
        for i=1,n do
                ensureAnim(idleFolder, "Animation" .. i)
        end
end

local function pick(pack, ...)
        for i = 1, select("#", ...) do
                local k = select(i, ...)
                local v = pack[k]
                if v ~= nil then return v end
        end
        return nil
end

local ATTR_LAST = "AnimPack_Last"
local applying = false
local currentPackName = nil
local currentAnimValues = {}

local function applyPack(packName)
        if applying then return false end
        applying = true

        local pack = PACKS[packName]
        if not pack then
                applying = false
                return false
        end

        local char = player.Character or player.CharacterAdded:Wait()
        local animate = waitForAnimate(char)
        if not animate then
                applying = false
                return false
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        stopAllTracks(hum)

        local runObj   = ensureAnim(animate:FindFirstChild("run"),   "RunAnim")
        local walkObj  = ensureAnim(animate:FindFirstChild("walk"),  "WalkAnim")
        local jumpObj  = ensureAnim(animate:FindFirstChild("jump"),  "JumpAnim")
        local fallObj  = ensureAnim(animate:FindFirstChild("fall"),  "FallAnim")
        local climbObj = ensureAnim(animate:FindFirstChild("climb"), "ClimbAnim")
        local swimObj  = ensureAnim(animate:FindFirstChild("swim"),     "Swim")
        local swimIdleObj = ensureAnim(animate:FindFirstChild("swimidle"), "SwimIdle")
        local idleFolder = animate:FindFirstChild("idle")

        setAnim(walkObj,  pick(pack, "WalkAnim", "Walk"))
        setAnim(runObj,   pick(pack, "RunAnim", "Run"))
        setAnim(jumpObj,  pick(pack, "JumpAnim", "Jump"))
        setAnim(fallObj,  pick(pack, "FallAnim", "Fall"))
        setAnim(climbObj, pick(pack, "ClimbAnim", "Climb"))
        setAnim(swimObj,      pick(pack, "Swim"))
        setAnim(swimIdleObj,  pick(pack, "SwimIdle") or pick(pack, "Swim"))

        currentAnimValues = {}
        for _, key in ipairs({"WalkAnim", "RunAnim", "JumpAnim", "FallAnim", "SwimIdle", "Swim", "ClimbAnim"}) do
                currentAnimValues[key] = pick(pack, key)
        end

        if idleFolder then
                local a1 = pick(pack, "Animation1")
                local a2 = pick(pack, "Animation2")
                if a1 or a2 then
                        ensureIdleSlots(idleFolder, 2)
                        local id1 = a1 or a2
                        local id2 = a2 or a1 or id1
                        setAnim(idleFolder:FindFirstChild("Animation1"), id1)
                        setAnim(idleFolder:FindFirstChild("Animation2"), id2)
                        currentAnimValues["Animation1"] = id1
                        currentAnimValues["Animation2"] = id2
                elseif pack.Idle and #pack.Idle > 0 then
                        ensureIdleSlots(idleFolder, math.max(2, #pack.Idle))
                        setAnim(idleFolder:FindFirstChild("Animation1"), pack.Idle[1])
                        setAnim(idleFolder:FindFirstChild("Animation2"), pack.Idle[2] or pack.Idle[1])
                        currentAnimValues["Animation1"] = pack.Idle[1]
                        currentAnimValues["Animation2"] = pack.Idle[2] or pack.Idle[1]
                        for i = 3, #pack.Idle do
                                local a = idleFolder:FindFirstChild("Animation" .. i)
                                if a then setAnim(a, pack.Idle[i]) end
                        end
                end
        end

        animate.Disabled = true
        task.wait(0.06)
        animate.Disabled = false

        if hum then
                pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Landed)
                        task.wait(0.03)
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
        end

        pcall(function() player:SetAttribute(ATTR_LAST, packName) end)
        currentPackName = packName
        applying = false
        return true
end

local function resetAnimation(animKey)
        local char = player.Character
        if not char then return end
        local animate = waitForAnimate(char)
        if not animate then return end

        local defaultId = DEFAULT_ANIMS[animKey]
        if not defaultId then return end

        if animKey == "Animation1" or animKey == "Animation2" then
                local idleFolder = animate:FindFirstChild("idle")
                if idleFolder then
                        local animObj = ensureAnim(idleFolder, animKey)
                        setAnim(animObj, defaultId)
                end
        else
                local folderName = animKey:gsub("Anim$", ""):lower()
                local folder = animate:FindFirstChild(folderName)
                if folder then
                        local animObj = ensureAnim(folder, animKey)
                        setAnim(animObj, defaultId)
                end
        end

        currentAnimValues[animKey] = defaultId

        animate.Disabled = true
        task.wait(0.06)
        animate.Disabled = false
end

player.CharacterAdded:Connect(function()
        task.wait(0.6)
        local saved = player:GetAttribute(ATTR_LAST)
        if type(saved) == "string" and saved ~= "" and PACKS[saved] then
                applyPack(saved)
        end
        task.wait(0.5)
        initBasicFlyTracks()
        local char = player.Character
        if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                        loadAdvTracks(humanoid)
                end
        end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimPackGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = player.PlayerGui

local BorderFrame = Instance.new("Frame")
BorderFrame.Size = UDim2.new(0, 360, 0, 450)
BorderFrame.Position = UDim2.new(0.5, -180, 0.5, -225)
BorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BorderFrame.BorderSizePixel = 0
BorderFrame.Active = true
BorderFrame.Draggable = true
BorderFrame.ZIndex = 3
BorderFrame.Parent = screenGui

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 12)
BorderCorner.Parent = BorderFrame

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 200))
})
StrokeGradient.Rotation = 45
StrokeGradient.Parent = BorderFrame

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, -4, 1, -4)
mainFrame.Position = UDim2.new(0, 2, 0, 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 4
mainFrame.Parent = BorderFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
header.BackgroundTransparency = 0.5
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -135, 1, 0)
titleLabel.Position = UDim2.new(0, 50, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = " ANIMATION PACKS "
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.ZIndex = 6
titleLabel.Parent = header

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 100, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 200))
})
TitleGradient.Rotation = 30
TitleGradient.Parent = titleLabel

task.spawn(function()
    while titleLabel and titleLabel.Parent do        TitleGradient.Offset = Vector2.new(-1.5, 0)
        local tween = TweenService:Create(TitleGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Offset = Vector2.new(1.5, 0)})
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.3)
    end
end)

local tabBtn = Instance.new("TextButton")
tabBtn.Size = UDim2.new(0, 35, 1, 0)
tabBtn.Position = UDim2.new(0, 10, 0, 0)
tabBtn.BackgroundTransparency = 1
tabBtn.Text = "🔰"
tabBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
tabBtn.Font = Enum.Font.GothamBold
tabBtn.TextSize = 18
tabBtn.ZIndex = 6
tabBtn.Parent = header

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 35, 1, 0)
minimizeButton.Position = UDim2.new(1, -65, 0, 0)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "–"
minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 20
minimizeButton.ZIndex = 6
minimizeButton.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 1, 0)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.ZIndex = 6
closeButton.Parent = header

local dragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = BorderFrame.Position
                input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                        end
                end)
        end
end)

UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if startPos then
                        BorderFrame.Position = UDim2.new(
                                startPos.X.Scale, 
                                startPos.X.Offset + delta.X,
                                startPos.Y.Scale,
                                startPos.Y.Offset + delta.Y
                        )
                end
        end
end)

UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
        end
end)

local rotation = 0
local gradientConnection
gradientConnection = RunService.RenderStepped:Connect(function(dt)
    if BorderFrame and BorderFrame.Parent then
        rotation = (rotation + dt * 60) % 360
        StrokeGradient.Rotation = rotation
    end
end)

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -35)
contentContainer.Position = UDim2.new(0, 0, 0, 35)
contentContainer.BackgroundTransparency = 1
contentContainer.ZIndex = 4
contentContainer.Parent = mainFrame

local tab1Content = Instance.new("ScrollingFrame")
tab1Content.Size = UDim2.new(1, 0, 1, 0)
tab1Content.BackgroundTransparency = 1
tab1Content.ScrollBarThickness = 6
tab1Content.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
tab1Content.ScrollBarImageTransparency = 0.3
tab1Content.CanvasSize = UDim2.new(0, 0, 0, 0)
tab1Content.ZIndex = 4
tab1Content.Parent = contentContainer

local container1 = Instance.new("Frame")
container1.Size = UDim2.new(1, 0, 0, 0)
container1.BackgroundTransparency = 1
container1.ZIndex = 4
container1.Parent = tab1Content

local tab2Content = Instance.new("ScrollingFrame")
tab2Content.Size = UDim2.new(1, 0, 1, 0)
tab2Content.BackgroundTransparency = 1
tab2Content.ScrollBarThickness = 6
tab2Content.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
tab2Content.ScrollBarImageTransparency = 0.3
tab2Content.CanvasSize = UDim2.new(0, 0, 0, 0)
tab2Content.Visible = false
tab2Content.ZIndex = 4
tab2Content.Parent = contentContainer

local container2 = Instance.new("Frame")
container2.Size = UDim2.new(1, 0, 0, 0)
container2.BackgroundTransparency = 1
container2.ZIndex = 4
container2.Parent = tab2Content

local function createLabel(parent, x, y, text, color, size)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 320, 0, size or 20)
        lbl.Position = UDim2.new(0, x or 10, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(200, 200, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 5
        lbl.Parent = parent
        return lbl
end

local function createSmallLabel(parent, x, y, text, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 75, 0, 32)
        lbl.Position = UDim2.new(0, x, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(200, 200, 220)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 5
        lbl.Parent = parent
        return lbl
end

local function createButton(parent, x, y, text, color, w, h)
        local w = w or 80
        local h = h or 32
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, w, 0, h)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(128, 0, 255)
        btn.Text = text
        btn.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.ZIndex = 5
        btn.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        return btn
end

local function createDropdown(parent, x, y, label, w)
        local w = w or 145
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, w, 0, 32)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(128, 0, 255)
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.ZIndex = 5
        btn.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        return btn
end

local function createInput(parent, x, y, placeholder, text, w)
        local w = w or 140
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0, w, 0, 32)
        input.Position = UDim2.new(0, x, 0, y)
        input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        input.BackgroundTransparency = 0.5
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Font = Enum.Font.Gotham
        input.TextSize = 12
        input.PlaceholderText = placeholder
        input.Text = text or ""
        input.ClearTextOnFocus = false
        input.BorderSizePixel = 1
        input.BorderColor3 = Color3.fromRGB(128, 0, 255)
        input.ZIndex = 5
        input.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = input
        return input
end

local dropdownPanel = Instance.new("Frame")
dropdownPanel.Size = UDim2.new(0, 220, 0, 200)
dropdownPanel.Position = UDim2.new(0, 0, 0, 0)
dropdownPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dropdownPanel.BorderSizePixel = 0
dropdownPanel.Visible = false
dropdownPanel.ZIndex = 10
dropdownPanel.Parent = screenGui

local dropGradient = Instance.new("UIGradient")
dropGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 200))
})
dropGradient.Rotation = 45
dropGradient.Parent = dropdownPanel

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 12)
dropCorner.Parent = dropdownPanel

local dropInner = Instance.new("Frame")
dropInner.Size = UDim2.new(1, -4, 1, -4)
dropInner.Position = UDim2.new(0, 2, 0, 2)
dropInner.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
dropInner.BackgroundTransparency = 0.3
dropInner.BorderSizePixel = 0
dropInner.ZIndex = 11
dropInner.Parent = dropdownPanel

local dropInnerCorner = Instance.new("UICorner")
dropInnerCorner.CornerRadius = UDim.new(0, 10)
dropInnerCorner.Parent = dropInner

local dropScroll = Instance.new("ScrollingFrame")
dropScroll.Size = UDim2.new(1, -10, 1, -10)
dropScroll.Position = UDim2.new(0, 5, 0, 5)
dropScroll.BackgroundTransparency = 1
dropScroll.ScrollBarThickness = 4
dropScroll.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
dropScroll.ZIndex = 12
dropScroll.Parent = dropInner

local dropLayout = Instance.new("UIListLayout")
dropLayout.Padding = UDim.new(0, 4)
dropLayout.SortOrder = Enum.SortOrder.Name
dropLayout.Parent = dropScroll

dropdownPanel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local panelPos = dropdownPanel.AbsolutePosition
                local panelSize = dropdownPanel.AbsoluteSize
                if not (mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X and
                                mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y) then
                        dropdownPanel.Visible = false
                end
        end
end)

local y1 = 10

local label1 = createLabel(container1, 10, y1, "📦 PACK SELECTOR", Color3.fromRGB(200, 200, 255), 22)
y1 = y1 + 28

local packDropdown = createDropdown(container1, 10, y1, "CHỌN PACK...", 180)
local packApply = createButton(container1, 200, y1, "APPLY", Color3.fromRGB(100, 255, 100), 130, 32)

y1 = y1 + 42

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 320, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 0, y1)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Current: (none)"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 5
statusLabel.Parent = container1

local function updateStatus()
        local saved = player:GetAttribute(ATTR_LAST)
        if saved and PACKS[saved] then
                statusLabel.Text = "Current: " .. saved
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
                statusLabel.Text = "Current: (none)"
                statusLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
        end
end
updateStatus()

y1 = y1 + 25

local label2 = createLabel(container1, 10, y1, "⚙️ CUSTOM ANIMATION", Color3.fromRGB(200, 200, 255), 22)
y1 = y1 + 28

local animKeys = {"WalkAnim", "RunAnim", "JumpAnim", "FallAnim", "SwimIdle", "Swim", "Animation1", "Animation2", "ClimbAnim"}
local animDisplayNames = {
        WalkAnim = "🚶 Walk",
        RunAnim = "🏃 Run",
        JumpAnim = "⬆ Jump",
        FallAnim = "⬇ Fall",
        SwimIdle = "🏊 Swim Idle",
        Swim = "🏊 Swim",
        Animation1 = "🎭 Idle 1",
        Animation2 = "🎭 Idle 2",
        ClimbAnim = "🧗 Climb"
}

local animDropdowns = {}

for i, key in ipairs(animKeys) do
        local rowY = y1 + (i - 1) * 38
        local displayName = animDisplayNames[key] or key

        local lbl = createSmallLabel(container1, 10, rowY, displayName, Color3.fromRGB(200, 200, 220))

        local dropdown = createDropdown(container1, 90, rowY, "ID: (none)", 145)
        animDropdowns[key] = dropdown

        local applyBtn = createButton(container1, 245, rowY, "APPLY", Color3.fromRGB(100, 255, 100), 80, 32)

        local function buildAnimDropdown(dropdownBtn, animKey)
                for _, child in ipairs(dropScroll:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                end

                local customBtn = Instance.new("TextButton")
                customBtn.Size = UDim2.new(1, -10, 0, 32)
                customBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
                customBtn.BackgroundTransparency = 0.3
                customBtn.BorderSizePixel = 1
                customBtn.BorderColor3 = Color3.fromRGB(255, 128, 0)
                customBtn.Text = "✏️ Custom ID..."
                customBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
                customBtn.Font = Enum.Font.Gotham
                customBtn.TextSize = 11
                customBtn.ZIndex = 13
                customBtn.Parent = dropScroll

                local customCorner = Instance.new("UICorner")
                customCorner.CornerRadius = UDim.new(0, 8)
                customCorner.Parent = customBtn

                customBtn.MouseButton1Click:Connect(function()
                        dropdownPanel.Visible = false
                        local inputBox = Instance.new("TextBox")
                        inputBox.Size = UDim2.new(0, 180, 0, 40)
                        inputBox.Position = UDim2.new(0.5, -90, 0.5, -20)
                        inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                        inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                        inputBox.PlaceholderText = "Enter Animation ID..."
                        inputBox.Font = Enum.Font.Gotham
                        inputBox.TextSize = 14
                        inputBox.BorderSizePixel = 1
                        inputBox.BorderColor3 = Color3.fromRGB(128, 0, 255)
                        inputBox.ZIndex = 20
                        inputBox.Parent = screenGui

                        local inputCorner = Instance.new("UICorner")
                        inputCorner.CornerRadius = UDim.new(0, 10)
                        inputCorner.Parent = inputBox

                        inputBox.FocusLost:Connect(function(enterPressed)
                                if enterPressed then
                                        local id = tonumber(inputBox.Text)
                                        if id and id > 0 then
                                                currentAnimValues[animKey] = id
                                                dropdownBtn.Text = "ID: " .. id
                                        end
                                end
                                inputBox:Destroy()
                        end)
                        inputBox:CaptureFocus()
                end)

                local defaultBtn = Instance.new("TextButton")
                defaultBtn.Size = UDim2.new(1, -10, 0, 32)
                defaultBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                defaultBtn.BackgroundTransparency = 0.3
                defaultBtn.BorderSizePixel = 1
                defaultBtn.BorderColor3 = Color3.fromRGB(0, 255, 100)
                defaultBtn.Text = "🔹 Default (" .. (DEFAULT_ANIMS[animKey] or "none") .. ")"
                defaultBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                defaultBtn.Font = Enum.Font.Gotham
                defaultBtn.TextSize = 10
                defaultBtn.ZIndex = 13
                defaultBtn.Parent = dropScroll

                local defaultCorner = Instance.new("UICorner")
                defaultCorner.CornerRadius = UDim.new(0, 8)
                defaultCorner.Parent = defaultBtn

                defaultBtn.MouseButton1Click:Connect(function()
                        local defaultId = DEFAULT_ANIMS[animKey]
                        if defaultId then
                                currentAnimValues[animKey] = defaultId
                                dropdownBtn.Text = "ID: " .. defaultId .. " (default)"
                                dropdownPanel.Visible = false
                                resetAnimation(animKey)
                        end
                end)

                local packNames = {}
                for name in pairs(PACKS) do table.insert(packNames, name) end
                table.sort(packNames)

                for _, packName in ipairs(packNames) do
                        local pack = PACKS[packName]
                        local animId = pack[animKey]
                        if animId then
                                local btn = Instance.new("TextButton")
                                btn.Size = UDim2.new(1, -10, 0, 32)
                                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                                btn.BackgroundTransparency = 0.3
                                btn.BorderSizePixel = 1
                                btn.BorderColor3 = Color3.fromRGB(128, 0, 255)
                                btn.Text = packName .. " (" .. animId .. ")"
                                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                btn.Font = Enum.Font.Gotham
                                btn.TextSize = 10
                                btn.ZIndex = 13
                                btn.Parent = dropScroll

                                local btnCorner = Instance.new("UICorner")
                                btnCorner.CornerRadius = UDim.new(0, 8)
                                btnCorner.Parent = btn

                                btn.MouseButton1Click:Connect(function()
                                        currentAnimValues[animKey] = animId
                                        dropdownBtn.Text = "ID: " .. animId .. " (" .. packName .. ")"
                                        dropdownPanel.Visible = false
                                end)
                        end
                end

                dropScroll.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y + 10)
        end

        dropdown.MouseButton1Click:Connect(function()
                buildAnimDropdown(dropdown, key)
                dropdownPanel.Visible = true
                local btnPos = dropdown.AbsolutePosition
                local xPos = btnPos.X - 220
                if xPos < 0 then
                        xPos = btnPos.X + dropdown.AbsoluteSize.X
                end
                dropdownPanel.Position = UDim2.new(0, xPos, 0, btnPos.Y + 32)
        end)

        applyBtn.MouseButton1Click:Connect(function()
                local id = currentAnimValues[key]
                if not id then return end

                local char = player.Character
                if not char then return end
                local animate = waitForAnimate(char)
                if not animate then return end

                if key == "Animation1" or key == "Animation2" then
                        local idleFolder = animate:FindFirstChild("idle")
                        if idleFolder then
                                local animObj = ensureAnim(idleFolder, key)
                                setAnim(animObj, id)
                        end
                else
                        local folderName = key:gsub("Anim$", ""):lower()
                        local folder = animate:FindFirstChild(folderName)
                        if folder then
                                local animObj = ensureAnim(folder, key)
                                setAnim(animObj, id)
                        end
                end

                animate.Disabled = true
                task.wait(0.06)
                animate.Disabled = false

                statusLabel.Text = "Applied: " .. key .. " → " .. id
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end)
end

local y2 = 10

local labelFly = createLabel(container2, 10, y2, "✈️ FLY BASIC", Color3.fromRGB(200, 200, 255), 22)
y2 = y2 + 28

local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0, 330, 0, 40)
flyFrame.Position = UDim2.new(0, 10, 0, y2)
flyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
flyFrame.BackgroundTransparency = 0.5
flyFrame.BorderSizePixel = 1
flyFrame.BorderColor3 = Color3.fromRGB(128, 0, 255)
flyFrame.ZIndex = 5
flyFrame.Parent = container2

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyFrame

local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(1, -100, 1, 0)
flyLabel.Position = UDim2.new(0, 15, 0, 0)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "✈️ BASIC: OFF"
flyLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
flyLabel.Font = Enum.Font.GothamBold
flyLabel.TextSize = 13
flyLabel.TextXAlignment = Enum.TextXAlignment.Left
flyLabel.TextYAlignment = Enum.TextYAlignment.Center
flyLabel.ZIndex = 6
flyLabel.Parent = flyFrame

local flyToggle = createButton(flyFrame, 240, 4, "TOGGLE", Color3.fromRGB(255, 165, 0), 80, 32)

flyToggle.MouseButton1Click:Connect(function()
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end

        if isBasicFlying then
                stopBasicFlying(humanoid)
                flyLabel.Text = "✈️ BASIC: OFF"
                flyLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
                startBasicFlying(character, humanoid)
                flyLabel.Text = "✈️ BASIC: ON"
                flyLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
end)

y2 = y2 + 50

local idleLabel = createSmallLabel(container2, 10, y2, "Idle:", Color3.fromRGB(200, 200, 220))
local idleInput = createInput(container2, 85, y2, "ID...", "91106826233224", 140)
local idleApply = createButton(container2, 235, y2, "APPLY", Color3.fromRGB(100, 255, 100), 80, 32)

idleApply.MouseButton1Click:Connect(function()
        local id = tonumber(idleInput.Text)
        if id and id > 0 then
                if basicFlyIdleTrack then
                        basicFlyIdleTrack.Animation.AnimationId = "rbxassetid://" .. id
                        if isBasicFlying and basicFlyIdleTrack.IsPlaying then
                                basicFlyIdleTrack:Stop()
                                basicFlyIdleTrack:Play()
                        end
                end
                statusLabel.Text = "Basic Idle: " .. id
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
end)

y2 = y2 + 42

local moveLabel = createSmallLabel(container2, 10, y2, "Move:", Color3.fromRGB(200, 200, 220))
local moveInput = createInput(container2, 85, y2, "ID...", "114833664438028", 140)
local moveApply = createButton(container2, 235, y2, "APPLY", Color3.fromRGB(100, 255, 100), 80, 32)

moveApply.MouseButton1Click:Connect(function()
        local id = tonumber(moveInput.Text)
        if id and id > 0 then
                if basicFlyMoveTrack then
                        basicFlyMoveTrack.Animation.AnimationId = "rbxassetid://" .. id
                        if isBasicFlying and basicFlyMoveTrack.IsPlaying then
                                basicFlyMoveTrack:Stop()
                                basicFlyMoveTrack:Play()
                        end
                end
                statusLabel.Text = "Basic Move: " .. id
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
end)

y2 = y2 + 42

local speedLabel = createSmallLabel(container2, 10, y2, "Speed:", Color3.fromRGB(200, 200, 220))
local speedInput = createInput(container2, 85, y2, "Speed (default: 50)", "50", 140)
local speedApply = createButton(container2, 235, y2, "APPLY", Color3.fromRGB(100, 255, 100), 80, 32)

speedApply.MouseButton1Click:Connect(function()
        local speed = tonumber(speedInput.Text)
        if speed and speed > 0 then
                basicFlySpeed = speed
                statusLabel.Text = "Basic Speed: " .. speed
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
end)

y2 = y2 + 55

local labelAdv = createLabel(container2, 10, y2, "🎯 FLY ADVANCED", Color3.fromRGB(200, 200, 255), 22)
y2 = y2 + 28

local advFrame = Instance.new("Frame")
advFrame.Size = UDim2.new(0, 330, 0, 40)
advFrame.Position = UDim2.new(0, 10, 0, y2)
advFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
advFrame.BackgroundTransparency = 0.5
advFrame.BorderSizePixel = 1
advFrame.BorderColor3 = Color3.fromRGB(128, 0, 255)
advFrame.ZIndex = 5
advFrame.Parent = container2

local advCorner = Instance.new("UICorner")
advCorner.CornerRadius = UDim.new(0, 8)
advCorner.Parent = advFrame

local advLabel = Instance.new("TextLabel")
advLabel.Size = UDim2.new(1, -100, 1, 0)
advLabel.Position = UDim2.new(0, 15, 0, 0)
advLabel.BackgroundTransparency = 1
advLabel.Text = "🎯 ADVANCED: OFF"
advLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
advLabel.Font = Enum.Font.GothamBold
advLabel.TextSize = 13
advLabel.TextXAlignment = Enum.TextXAlignment.Left
advLabel.TextYAlignment = Enum.TextYAlignment.Center
advLabel.ZIndex = 6
advLabel.Parent = advFrame

local advToggle = createButton(advFrame, 240, 4, "TOGGLE", Color3.fromRGB(255, 165, 0), 80, 32)

advToggle.MouseButton1Click:Connect(function()
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end

        if isAdvFlying then
                stopAdvFlying()
                advLabel.Text = "🎯 ADVANCED: OFF"
                advLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
                startAdvFlying(character, humanoid)
                advLabel.Text = "🎯 ADVANCED: ON"
                advLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
end)

y2 = y2 + 50

local advSpeedLabel = createSmallLabel(container2, 10, y2, "Speed:", Color3.fromRGB(200, 200, 220))
local advSpeedInput = createInput(container2, 85, y2, "Speed (default: 50)", "50", 140)
local advSpeedApply = createButton(container2, 235, y2, "APPLY", Color3.fromRGB(100, 255, 100), 80, 32)

advSpeedApply.MouseButton1Click:Connect(function()
        local speed = tonumber(advSpeedInput.Text)
        if speed and speed > 0 then
                advFlySpeed = speed
                statusLabel.Text = "Adv Speed: " .. speed
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
end)

y2 = y2 + 55

local labelMove = createLabel(container2, 10, y2, "⌨️ MOVEMENT", Color3.fromRGB(200, 200, 255), 22)
y2 = y2 + 28

local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0, 330, 0, 40)
moveFrame.Position = UDim2.new(0, 10, 0, y2)
moveFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
moveFrame.BackgroundTransparency = 0.5
moveFrame.BorderSizePixel = 1
moveFrame.BorderColor3 = Color3.fromRGB(128, 0, 255)
moveFrame.ZIndex = 5
moveFrame.Parent = container2

local moveCorner = Instance.new("UICorner")
moveCorner.CornerRadius = UDim.new(0, 8)
moveCorner.Parent = moveFrame

local moveLabel = Instance.new("TextLabel")
moveLabel.Size = UDim2.new(1, -100, 1, 0)
moveLabel.Position = UDim2.new(0, 15, 0, 0)
moveLabel.BackgroundTransparency = 1
moveLabel.Text = "⌨️ MOVEMENT"
moveLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
moveLabel.Font = Enum.Font.GothamBold
moveLabel.TextSize = 13
moveLabel.TextXAlignment = Enum.TextXAlignment.Left
moveLabel.TextYAlignment = Enum.TextYAlignment.Center
moveLabel.ZIndex = 6
moveLabel.Parent = moveFrame

local moveLoadBtn = createButton(moveFrame, 240, 4, "LOAD", Color3.fromRGB(100, 200, 255), 80, 32)

moveLoadBtn.MouseButton1Click:Connect(function()
        statusLabel.Text = "Loading movement..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        task.spawn(function()
                local success, err = pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirNotFun/NUniversal/refs/heads/main/Keyboards/Key.lua"))()
                end)
                if success then
                        statusLabel.Text = "Movement loaded successfully!"
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                        statusLabel.Text = "Failed to load movement!"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                        warn("Movement load error:", err)
                end
        end)
end)

y2 = y2 + 55

local labelCustom = createLabel(container2, 10, y2, "🎬 CUSTOM ANIMATIONS", Color3.fromRGB(200, 200, 255), 22)
y2 = y2 + 28

local advAnimList = {
        {key = "forward", label = "Forward:", default = "90872539"},
        {key = "up", label = "Up:", default = "90872539"},
        {key = "down", label = "Down:", default = "233322916"},
        {key = "left1", label = "Left 1:", default = "136801964"},
        {key = "left2", label = "Left 2:", default = "142495255"},
        {key = "right1", label = "Right 1:", default = "136801964"},
        {key = "right2", label = "Right 2:", default = "142495255"},
        {key = "back1", label = "Back 1:", default = "136801964"},
        {key = "back2", label = "Back 2:", default = "106772613"},
        {key = "back3", label = "Back 3:", default = "42070810"},
        {key = "back4", label = "Back 4:", default = "214744412"},
        {key = "flyLow1", label = "Fly Low 1:", default = "97169019"},
        {key = "flyLow2", label = "Fly Low 2:", default = "282574440"},
        {key = "flyFast", label = "Fly Fast:", default = "282574440"},
        {key = "idle1", label = "Idle:", default = "97171309"},
}

for _, animData in ipairs(advAnimList) do
        local lbl = createSmallLabel(container2, 10, y2, animData.label, Color3.fromRGB(200, 200, 220))
        local input = createInput(container2, 85, y2, "ID...", animData.default, 140)
        local applyBtn = createButton(container2, 235, y2, "APPLY", Color3.fromRGB(100, 255, 100), 80, 32)

        applyBtn.MouseButton1Click:Connect(function()
                local id = tonumber(input.Text)
                if id and id > 0 then
                        advAnimations[animData.key].AnimationId = "rbxassetid://" .. id
                        if isAdvFlying and advTracks[animData.key] then
                                local wasPlaying = advTracks[animData.key].IsPlaying
                                advTracks[animData.key]:Stop()
                                local newAnim = Instance.new("Animation")
                                newAnim.AnimationId = "rbxassetid://" .. id
                                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                if hum then
                                        local animator = hum:FindFirstChildOfClass("Animator")
                                        if animator then
                                                local newTrack = animator:LoadAnimation(newAnim)
                                                newTrack.Looped = true
                                                advTracks[animData.key] = newTrack
                                                if wasPlaying then
                                                        newTrack:Play()
                                                end
                                        end
                                end
                        end
                        statusLabel.Text = "Applied: " .. animData.key .. " → " .. id
                        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                end
        end)

        y2 = y2 + 42
end

local function updateCanvas1()
        local maxY = 0
        for _, child in ipairs(container1:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                        local childBottom = child.Position.Y.Offset + child.AbsoluteSize.Y
                        if childBottom > maxY then
                                maxY = childBottom
                        end
                end
        end
        local totalHeight = maxY + 20
        if totalHeight < 400 then
                totalHeight = 400
        end
        container1.Size = UDim2.new(1, 0, 0, totalHeight)
        tab1Content.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local function updateCanvas2()
        local maxY = 0
        for _, child in ipairs(container2:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                        local childBottom = child.Position.Y.Offset + child.AbsoluteSize.Y
                        if childBottom > maxY then
                                maxY = childBottom
                        end
                end
        end
        local totalHeight = maxY + 20
        if totalHeight < 500 then
                totalHeight = 500
        end
        container2.Size = UDim2.new(1, 0, 0, totalHeight)
        tab2Content.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local currentTab = 1
local tab1Height = 375
local tab2Height = 375

local function switchTab(tab)
        currentTab = tab
        local targetHeight = tab == 1 and tab1Height or tab2Height

        if tab == 1 then
                tab1Content.Visible = true
                tab2Content.Visible = false
                tabBtn.Text = "🔰"
                titleLabel.Text = " ANIMATION PACKS "
        else
                tab1Content.Visible = false
                tab2Content.Visible = true
                tabBtn.Text = "🎮"
                titleLabel.Text = " CUSTOM FLY "
        end

        BorderFrame:TweenSize(UDim2.new(0, 360, 0, targetHeight), "Out", "Quad", 0.15)
        task.wait(0.2)
        updateCanvas1()
        updateCanvas2()
end

tabBtn.MouseButton1Click:Connect(function()
        if currentTab == 1 then
                switchTab(2)
        else
                switchTab(1)
        end
end)

local isMinimized = false

minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
                BorderFrame:TweenSize(UDim2.new(0, 360, 0, 35), "Out", "Quad", 0.2)
                contentContainer.Visible = false
                minimizeButton.Text = "+"
        else
                local targetHeight = currentTab == 1 and tab1Height or tab2Height
                BorderFrame:TweenSize(UDim2.new(0, 360, 0, targetHeight), "Out", "Quad", 0.2)
                contentContainer.Visible = true
                minimizeButton.Text = "–"
        end
end)

closeButton.MouseButton1Click:Connect(function()
        if isBasicFlying then
                local char = player.Character
                if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid then stopBasicFlying(humanoid) end
                end
        end
        if isAdvFlying then
                stopAdvFlying()
        end
        if gradientConnection then gradientConnection:Disconnect() end
        screenGui:Destroy()
end)

local function buildPackDropdown()
        for _, child in ipairs(dropScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
        end

        local sortedNames = {}
        for name in pairs(PACKS) do table.insert(sortedNames, name) end
        table.sort(sortedNames)

        for _, name in ipairs(sortedNames) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 32)
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                btn.BackgroundTransparency = 0.3
                btn.BorderSizePixel = 1
                btn.BorderColor3 = Color3.fromRGB(128, 0, 255)
                btn.Text = name
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.ZIndex = 13
                btn.Parent = dropScroll

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = btn

                btn.MouseButton1Click:Connect(function()
                        packDropdown.Text = name
                        dropdownPanel.Visible = false
                end)
        end

        dropScroll.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y + 10)
end

packDropdown.MouseButton1Click:Connect(function()
        buildPackDropdown()
        dropdownPanel.Visible = true
        local btnPos = packDropdown.AbsolutePosition
        local xPos = btnPos.X - 220
        if xPos < 0 then
                xPos = btnPos.X + packDropdown.AbsoluteSize.X
        end
        dropdownPanel.Position = UDim2.new(0, xPos, 0, btnPos.Y + 32)
end)

packApply.MouseButton1Click:Connect(function()
        local selected = packDropdown.Text
        if selected ~= "CHỌN PACK..." and PACKS[selected] then
                local ok = applyPack(selected)
                if ok then
                        statusLabel.Text = "Current: " .. selected
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        packDropdown.Text = selected
                        for key, dropdown in pairs(animDropdowns) do
                                local val = currentAnimValues[key]
                                if val then
                                        dropdown.Text = "ID: " .. val
                                end
                        end
                end
        end
end)

task.spawn(function()
        while screenGui and screenGui.Parent do
                task.wait(0.1)
                updateCanvas1()
                updateCanvas2()
        end
end)

task.spawn(function()
        while screenGui and screenGui.Parent do
                task.wait()
                if isAdvFlying then
                        updateAdvFly(task.wait())
                end
        end
end)

task.defer(function()
        local saved = player:GetAttribute(ATTR_LAST)
        if type(saved) == "string" and saved ~= "" and PACKS[saved] then
                packDropdown.Text = saved
                statusLabel.Text = "Current: " .. saved
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(0.3)
                applyPack(saved)
                for key, dropdown in pairs(animDropdowns) do
                        local val = currentAnimValues[key]
                        if val then
                                dropdown.Text = "ID: " .. val
                        end
                end
        end
        task.wait(0.5)
        initBasicFlyTracks()
        local char = player.Character
        if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                        loadAdvTracks(humanoid)
                end
        end
end)

updateCanvas1()
updateCanvas2()