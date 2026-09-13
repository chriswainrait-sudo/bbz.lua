return {Exports={"MiscSection","CosmeticsSection","ballEspEnabled","ballEspHighlights","ballEspAddedConnection","ballEspRemovingConnection","isBallMeshPart","findBallFromDescendant","removeBallHighlight","addBallHighlight","clearBallEsp","setBallEspEnabled","MovementSection","Visual","TimeChangerThread","suicide","rejoinGame","serverHop","activeEmoteTrack","emoteAnimationsByName","stopSelectedEmote","collectEmoteAnimations","playSelectedEmote","emoteDropdown","emoteFolder","bindEmoteFolder","_emotesAssets","initialEmoteFolder"},Init=function()
MiscSection = Tabs.Misc:AddSection("Misc")
CosmeticsSection = Tabs.Misc:AddSection("Cosmetics")

cosmeticDropdown = Tabs.Misc:AddDropdown("CosmeticSelector", {
    Title = "Cosmetics",
    Values = CollectCosmeticNames(),
    Default = "None",
    HorizontalInset = 3,
    SelectorHeight = 30,
    ListMaxHeight = 270,
    OptionHeight = 30,
    Callback = function(value)
        EquipCosmetic(value, false)
    end,
})

Tabs.Misc:SetActiveSection(MiscSection)

ballEspEnabled = false
ballEspHighlights = {}
ballEspAddedConnection = nil
ballEspRemovingConnection = nil

function isBallMeshPart(object)
    return object and object:IsA("MeshPart") and object.Name == "Basketball"
end

function findBallFromDescendant(object)
    local current = object
    while current and current ~= Workspace do
        if current:IsA("MeshPart") and current.Name == "Basketball" then
            return current
        end
        current = current.Parent
    end
    return nil
end

function removeBallHighlight(object)
    local highlight = ballEspHighlights[object]
    ballEspHighlights[object] = nil
    if highlight then
        pcall(function()
            highlight:Destroy()
        end)
    end
end

function addBallHighlight(object)
    if not ballEspEnabled or not isBallMeshPart(object) then
        return
    end

    local trackedHighlight = ballEspHighlights[object]
    if trackedHighlight and trackedHighlight.Parent then
        return
    end
    ballEspHighlights[object] = nil

    local oldHighlight = object:FindFirstChild("NexusBallESP")
    if oldHighlight and oldHighlight:IsA("Highlight") then
        oldHighlight:Destroy()
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NexusBallESP"
    highlight.Adornee = object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 25, 25)
    highlight.FillTransparency = 0.15
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    ballEspHighlights[object] = highlight
end

function clearBallEsp()
    if ballEspAddedConnection then
        ballEspAddedConnection:Disconnect()
        ballEspAddedConnection = nil
    end
    if ballEspRemovingConnection then
        ballEspRemovingConnection:Disconnect()
        ballEspRemovingConnection = nil
    end

    for object, highlight in pairs(ballEspHighlights) do
        ballEspHighlights[object] = nil
        if highlight then
            pcall(function()
                highlight:Destroy()
            end)
        end
    end
end

function setBallEspEnabled(enabled)
    enabled = enabled == true
    if ballEspEnabled == enabled then
        return
    end

    ballEspEnabled = enabled
    clearBallEsp()
    if not enabled then
        return
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if isBallMeshPart(object) then
            addBallHighlight(object)
        end
    end

    ballEspAddedConnection = Workspace.DescendantAdded:Connect(function(object)
        if isBallMeshPart(object) then
            addBallHighlight(object)
        end
    end)

    ballEspRemovingConnection = Workspace.DescendantRemoving:Connect(function(object)
        if ballEspHighlights[object] then
            removeBallHighlight(object)
        elseif object:IsA("Highlight") and object.Name == "NexusBallESP" then
            local ball = findBallFromDescendant(object)
            if ball and ballEspHighlights[ball] == object then
                ballEspHighlights[ball] = nil
                task.defer(function()
                    if ballEspEnabled and ball:IsDescendantOf(Workspace) then
                        addBallHighlight(ball)
                    end
                end)
            end
        end
    end)
end

Tabs.Misc:AddToggle("BallESP", {
    Title = "ESP Basketball",
    Description = "Highlights every recreated Basketball MeshPart",
    Default = false,
    Callback = function(value)
        setBallEspEnabled(value)
    end,
})

RegisterUnloadCallback(function()
    ballEspEnabled = false
    clearBallEsp()
end)

Tabs.Misc:AddToggle("ShotPowerModifier", {
    Title = "Shot Power Modifier",
    Description = "Modify shot power",
    Default = false,
    Callback = function(Value)
        ShotPowerEnabled = Value
        if Value then
            local lastShotTime = 0
            local SHOT_COOLDOWN = 0.5
            
        ShotPowerConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function()
                if not ShotPowerEnabled then return end
                local ball = GetCurrentBall()
                if not ball then return end
                
                local currentVel = ball.AssemblyLinearVelocity
                local currentTime = tick()
                
                if currentVel.Magnitude > 5 and (currentTime - lastShotTime) > SHOT_COOLDOWN then
                    lastShotTime = currentTime
                    ball.AssemblyLinearVelocity = currentVel * ShotPowerMultiplier
                end
            end))
        else
            if ShotPowerConnection then
                ShotPowerConnection:Disconnect()
                ShotPowerConnection = nil
            end
        end
    end
})

Tabs.Misc:AddSlider("ShotPowerAmount", {
    Title = "Shot Power Multiplier",
    Description = "Adjust shot power multiplier",
    Default = 1.5,
    Min = 0.5,
    Max = 3.0,
    Rounding = 1,
    Callback = function(Value)
        ShotPowerMultiplier = Value
    end
})


MovementSection = Tabs.Movement:AddSection("Movement")

-- Speed Boost + Jump Boost (old) removed; replaced by Courtside Speed / Jump
-- settings in the "Courtside Movement" section appended at the end of this file.

Tabs.Movement:AddToggle("AutoPickup", {
    Title = "Auto Pickup Ball",
    Description = "Automatically pickup the ball",
    Default = false,
    Callback = function(Value)
        AutoPickupEnabled = Value
        if Value then
            AutoPickupConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function()
                if not AutoPickupEnabled then return end
                local character = LocalPlayer.Character
                if not character then return end
                local root = character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local function hasCharacterBall(targetCharacter)
                    if not targetCharacter then return false end
                    for _, child in ipairs(targetCharacter:GetChildren()) do
                        if child.Name == "PlrBall" or child.Name == "Ball" or child.Name == "Basketball" then
                            return true
                        end
                    end
                    for _, descendant in ipairs(targetCharacter:GetDescendants()) do
                        if descendant:IsA("BasePart") and descendant.Name == "Basketball" then
                            return true
                        end
                    end
                    return false
                end

                if hasCharacterBall(character) then return end

                local ball = GetCurrentBall()
                if not ball then return end

                local collider = GetBallCollider()
                local targetPos = collider and collider.Position or ball.Position
                local distance = (targetPos - root.Position).Magnitude
                if distance <= PickupRange and distance > 2 and (tick() - AutoPickupLastTeleport) > 0.1 then
                    AutoPickupLastTeleport = tick()
                    local step = math.min(distance, 6)
                    local direction = (targetPos - root.Position).Unit
                    root.CFrame = CFrame.new(root.Position + direction * step, targetPos)
                    root.AssemblyLinearVelocity = Vector3.new()
                    root.AssemblyAngularVelocity = Vector3.new()
                end
            end))
        else
            if AutoPickupConnection then
                AutoPickupConnection:Disconnect()
                AutoPickupConnection = nil
            end
        end
    end
})

Tabs.Movement:AddSlider("PickupRange", {
    Title = "Pickup Range",
    Description = "Maximum distance to pickup ball",
    Default = 30,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        PickupRange = Value
    end
})

Tabs.Movement:AddSlider("maxzoom", {
    Title = "Max Zoom",
    Description = "Adjust maximum camera zoom distance",
    Default = 45,
    Min = 45,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        if LocalPlayer then 
            LocalPlayer.CameraMaxZoomDistance = Value 
        end
    end
})

-- Old Highlight-based PlayerESP removed; replaced by the Courtside player ESP
-- (boxes / names / health / distance / style / zone) on the ESP tab.

Tabs.Misc:AddToggle("AntiSlip", {
    Title = "Anti Slip",
    Description = "Prevents slipping and falling",
    Default = false,
    Callback = function(Value)
        AntiSlipEnabled = Value
        if Value then
            local function ApplyAntiSlip()
                local Character = LocalPlayer.Character
                if not Character then return end
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if not Humanoid then return end
                local Root = Character:FindFirstChild("HumanoidRootPart")
                if not Root then return end
                pcall(function()
                    if Humanoid:GetState() == Enum.HumanoidStateType.FallingDown or 
                       Humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    if Root.AssemblyLinearVelocity.Y < -50 then
                        Root.AssemblyLinearVelocity = Vector3.new(
                            Root.AssemblyLinearVelocity.X,
                            0,
                            Root.AssemblyLinearVelocity.Z
                        )
                    end
                end)
            end
            AntiSlipConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function()
                if not AntiSlipEnabled then return end
                ApplyAntiSlip()
            end))
        else
            if AntiSlipConnection then
                AntiSlipConnection:Disconnect()
                AntiSlipConnection = nil
            end
        end
    end
})

Tabs.Misc:AddToggle("InfinitePumpFakes", {
    Title = "Infinite Pump Fakes",
    Description = "Unlimited pump fakes",
    Default = false,
    Callback = function(Value)
        InfinitePumpFakesEnabled = Value
        if Value then
            task.spawn(function()
                local function GetBallController()
                    if BallController then return BallController end
                    local Success, Controller = pcall(function()
                        local Knit = require(ReplicatedStorage.Packages.Knit)
                        return Knit.GetController("BallController")
                    end)
                    if Success and Controller then
                        BallController = Controller
                        if Controller.GetMaxPumpFakes and not OriginalGetMaxPumpFakes then
                            OriginalGetMaxPumpFakes = Controller.GetMaxPumpFakes
                            Controller.GetMaxPumpFakes = function(Self)
                                return 999
                            end
                        end
                    end
                    return BallController
                end
                task.wait(2)
                GetBallController()
            end)
        else
            if BallController and OriginalGetMaxPumpFakes then
                BallController.GetMaxPumpFakes = OriginalGetMaxPumpFakes
                OriginalGetMaxPumpFakes = nil
            end
            BallController = nil
        end
    end
})

Tabs.Visuals:AddSection("Visuals")

Tabs.Visuals:AddToggle("FOVChanger", {
    Title = "FOV Changer",
    Description = "Change field of view",
    Default = false,
    Callback = function(Value)
        FOVEnabled = Value
        if Value then
            local Camera = workspace.CurrentCamera
            FOVConnection = TrackScriptConnection(RunService.RenderStepped:Connect(function()
                if not FOVEnabled then return end
                if Camera.FieldOfView ~= FOVValue then
                    Camera.FieldOfView = FOVValue
                end
            end))
        else
            if FOVConnection then
                FOVConnection:Disconnect()
                FOVConnection = nil
            end
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = OriginalFieldOfView
            end
        end
    end
})

Tabs.Visuals:AddSlider("FOV Value", {
    Title = "FOV Value",
    Description = "Adjust field of view",
    Default = 90,
    Min = 70,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        FOVValue = Value
    end
})

Visual = {
    Effects = {
        noShadowEnabled = false,
        saturationEnabled = false,
        saturationLevel = 5,
        timeChangerEnabled = false,
        originalClockTime = nil,
        originalGlobalShadows = nil,
        originalLightShadows = {}
    }
}

function Visual.ToggleNoShadow(enabled)
    Visual.Effects.noShadowEnabled = enabled
    if enabled then
        local lighting = game:GetService("Lighting")
        if Visual.Effects.originalGlobalShadows == nil then
            Visual.Effects.originalGlobalShadows = lighting.GlobalShadows
            table.clear(Visual.Effects.originalLightShadows)
        end

        for _, light in ipairs(lighting:GetDescendants()) do
            if light:IsA("Light") then
                if Visual.Effects.originalLightShadows[light] == nil then
                    Visual.Effects.originalLightShadows[light] = light.Shadows
                end
                light.Shadows = false
            end
        end
        lighting.GlobalShadows = false
    else
        local lighting = game:GetService("Lighting")
        if Visual.Effects.originalGlobalShadows ~= nil then
            lighting.GlobalShadows = Visual.Effects.originalGlobalShadows
        end

        for light, originalShadows in pairs(Visual.Effects.originalLightShadows) do
            if light.Parent then
                light.Shadows = originalShadows
            end
        end

        Visual.Effects.originalGlobalShadows = nil
        table.clear(Visual.Effects.originalLightShadows)
    end
end

function Visual.ToggleSaturation(enabled)
    Visual.Effects.saturationEnabled = enabled
    
    if enabled then
        Visual.UpdateSaturation()
    else
        local lighting = game:GetService("Lighting")
        
        local colorCorrection = lighting:FindFirstChild("SaturationEffect")
        if colorCorrection then
            colorCorrection:Destroy()
        end
    end
end

function Visual.UpdateSaturation()
    if not Visual.Effects.saturationEnabled then return end
    
    local lighting = game:GetService("Lighting")
    
    local colorCorrection = lighting:FindFirstChild("SaturationEffect")
    if not colorCorrection then
        colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "SaturationEffect"
        colorCorrection.Parent = lighting
    end
    
    local saturationValue = Visual.Effects.saturationLevel / 5
    colorCorrection.Saturation = saturationValue
end

function Visual.ToggleTimeChanger(enabled)
    Visual.Effects.timeChangerEnabled = enabled
    
    if enabled then
        if not Visual.Effects.originalClockTime then
            Visual.Effects.originalClockTime = game:GetService("Lighting").ClockTime
        end
        
        local currentTime = Options.TimeValue and Options.TimeValue.Value or 14
        game:GetService("Lighting").ClockTime = currentTime
    else
        if Visual.Effects.originalClockTime then
            game:GetService("Lighting").ClockTime = Visual.Effects.originalClockTime
        end
    end
end

function Visual.SetTime(time)
    game:GetService("Lighting").ClockTime = time
end

Tabs.Visuals:AddToggle("NoShadow", {
    Title = "No Shadow", 
    Description = "Remove shadows in the game", 
    Default = false,
    Callback = function(Value)
        Visual.ToggleNoShadow(Value)
    end
})

Tabs.Visuals:AddToggle("Saturation", {
    Title = "Saturation", 
    Description = "Increase color saturation", 
    Default = false,
    Callback = function(Value)
        Visual.ToggleSaturation(Value)
    end
})

Tabs.Visuals:AddSlider("SaturationLevel", {
    Title = "Saturation Level", 
    Description = "Adjust saturation intensity",
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(value)
        Visual.Effects.saturationLevel = value
        if Visual.Effects.saturationEnabled then
            Visual.UpdateSaturation()
        end
    end
})

Tabs.Visuals:AddToggle("TimeChanger", {
    Title = "Time Changer", 
    Description = "Change the time of day", 
    Default = false,
    Callback = function(Value)
        Visual.ToggleTimeChanger(Value)
    end
})

Tabs.Visuals:AddSlider("TimeValue", {
    Title = "Time of Day", 
    Description = "Change the time of day (24 hours)",
    Default = 14,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Callback = function(value)
        if Visual.Effects.timeChangerEnabled then
            Visual.SetTime(value)
        end
    end
})

TimeChangerThread = task.spawn(function()
    while not ScriptUnloaded do
        task.wait(1)
        if not ScriptUnloaded and Visual.Effects.timeChangerEnabled then
            local currentTime = Options.TimeValue and Options.TimeValue.Value or 14
            Visual.SetTime(currentTime)
        end
    end
end)

RegisterUnloadCallback(function()
    if TimeChangerThread then
        pcall(task.cancel, TimeChangerThread)
        TimeChangerThread = nil
    end
end)

function suicide()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
            NexusUI:Notify({
                Title = "Suicide",
                Content = "You have committed suicide",
                Duration = 3
            })
        end
    end
end

function rejoinGame()
    local ts = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local jobId = game.JobId
    _G.__NEXUS_TELEPORT_ALLOWED = true
    ts:TeleportToPlaceInstance(placeId, jobId, game:GetService("Players").LocalPlayer)
    task.delay(5, function() _G.__NEXUS_TELEPORT_ALLOWED = false end)
    NexusUI:Notify({
        Title = "Rejoin",
        Content = "Rejoining game...",
        Duration = 3
    })
end

function serverHop()
    local ts = game:GetService("TeleportService")
    local http = game:GetService("HttpService")
    
    NexusUI:Notify({
        Title = "Server Hop",
        Content = "Finding new server...",
        Duration = 3
    })
    
    local servers = {}
    local req = http:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
    local data = http:JSONDecode(req)
    
    for _, server in ipairs(data.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(servers, server.id)
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        _G.__NEXUS_TELEPORT_ALLOWED = true
        ts:TeleportToPlaceInstance(game.PlaceId, randomServer)
        task.delay(5, function() _G.__NEXUS_TELEPORT_ALLOWED = false end)
    else
        NexusUI:Notify({
            Title = "Server Hop Error",
            Content = "No available servers found!",
            Duration = 3
        })
    end
end

Window:SelectTab(1)

Tabs.Other:AddSection("Other")

activeEmoteTrack = nil
emoteAnimationsByName = {}

function stopSelectedEmote()
    local track = activeEmoteTrack
    activeEmoteTrack = nil
    if track then
        pcall(function()
            track:Stop(0.15)
        end)
    end
end

function collectEmoteAnimations()
    local names = {}
    local usedNames = {}
    table.clear(emoteAnimationsByName)

    local _assetsRef = ReplicatedStorage:FindFirstChild("Assets")
    local folder = _assetsRef and _assetsRef:FindFirstChild("EmoteAnimations")
    if not folder then
        return names
    end

    local animations = {}
    for _, object in ipairs(folder:GetDescendants()) do
        if object:IsA("Animation") then
            table.insert(animations, object)
        end
    end

    table.sort(animations, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)

    for _, animation in ipairs(animations) do
        local baseName = animation.Name ~= "" and animation.Name or "Animation"
        local duplicateIndex = (usedNames[baseName] or 0) + 1
        usedNames[baseName] = duplicateIndex
        local displayName = duplicateIndex == 1 and baseName or (baseName .. " (" .. duplicateIndex .. ")")
        emoteAnimationsByName[displayName] = animation
        table.insert(names, displayName)
    end

    return names
end

function playSelectedEmote(displayName)
    local animation = emoteAnimationsByName[displayName]
    if not animation or not animation.Parent then
        NexusUI:Notify({
            Title = "Animation",
            Content = "Animation is no longer available.",
            Duration = 2,
        })
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        NexusUI:Notify({
            Title = "Animation",
            Content = "Character is not ready.",
            Duration = 2,
        })
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopSelectedEmote()
    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    if not success or not track then
        NexusUI:Notify({
            Title = "Animation",
            Content = "Failed to load animation.",
            Duration = 2,
        })
        return
    end

    activeEmoteTrack = track
    track.Priority = Enum.AnimationPriority.Action
    track:Play(0.15, 1, 1)
end

emoteDropdown = Tabs.Other:AddDropdown("EmoteAnimation", {
    Title = "Emote Animation",
    Values = collectEmoteAnimations(),
    Callback = function(value)
        playSelectedEmote(value)
    end,
})

Tabs.Other:AddButton({
    Title = "Stop anim",
    Description = "Stops the animation selected in Emote Animation",
    Callback = function()
        stopSelectedEmote()
    end,
})

RegisterUnloadCallback(stopSelectedEmote)
TrackScriptConnection(LocalPlayer.CharacterAdded:Connect(function()
    stopSelectedEmote()
end))

emoteFolder = nil
function bindEmoteFolder(folder)
    if emoteFolder == folder then return end
    emoteFolder = folder
    local refreshQueued = false
    local function queueEmoteRefresh()
        if refreshQueued then return end
        refreshQueued = true
        task.defer(function()
            refreshQueued = false
            if not ScriptUnloaded and emoteDropdown then
                emoteDropdown:SetValues(collectEmoteAnimations())
            end
        end)
    end
    TrackScriptConnection(folder.DescendantAdded:Connect(queueEmoteRefresh))
    TrackScriptConnection(folder.DescendantRemoving:Connect(queueEmoteRefresh))
    queueEmoteRefresh()
end

_emotesAssets = ReplicatedStorage:FindFirstChild("Assets")
initialEmoteFolder = _emotesAssets and _emotesAssets:FindFirstChild("EmoteAnimations")
if initialEmoteFolder then
    bindEmoteFolder(initialEmoteFolder)
else
    TrackScriptConnection(ReplicatedStorage.DescendantAdded:Connect(function(child)
        if child.Name == "EmoteAnimations" and child:IsA("Folder") then
            bindEmoteFolder(child)
        end
    end))
end

Tabs.Other:AddButton({
    Title = "Suicide",
    Description = "Kill your character",
    Callback = function()
        suicide()
    end
})

Tabs.Other:AddButton({
    Title = "Rejoin Game",
    Description = "Rejoins the current game server",
    Callback = function()
        rejoinGame()
    end
})

Tabs.Other:AddButton({
    Title = "Server Hop",
    Description = "Joins a new random server",
    Callback = function()
        serverHop()
    end
})

end}
