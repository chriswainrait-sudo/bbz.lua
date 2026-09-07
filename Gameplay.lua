return {Exports={"Options","PerfectShotEnabled","PerfectShotConnection","NoCooldownEnabled","NoCooldownConnection","NoStunEnabled","NoStunConnection","NoRagdollEnabled","NoRagdollConnection","AutoBlockEnabled","AutoBlockConnection","AutoDribbleEnabled","AutoDribbleConnection","SpeedBoostEnabled","SpeedBoostConnection","SpeedBoostValue","JumpBoostEnabled","JumpBoostConnection","JumpBoostValue","AutoPickupEnabled","AutoPickupConnection","PickupRange","AutoPickupLastTeleport","ShotPowerEnabled","ShotPowerConnection","ShotPowerMultiplier","InfinitePumpFakesEnabled","InfinitePumpFakesThread","BallController","OriginalGetMaxPumpFakes","FOVEnabled","FOVConnection","FOVValue","AntiSlipEnabled","AntiSlipConnection","OriginalCameraMaxZoomDistance","OriginalFieldOfView","MainSection","playerCard","playerViewport","mobileEspBounds","AddEspCorner","playerWorldModel","playerCamera","playerInfo","makePlayerInfoLabel","playerNameLabel","playerUserLabel","playerIdLabel","playerClonePivot","playerSpinAngle","RefreshPlayerViewport","UpdateMobilePlayerEspBounds","PerfectShotLastCorrectionTime","GetCurrentBall","GetTargetHoop","NoCooldownControllerInstance","FindNoCooldownController","executorName","noCooldownUnsupportedExecutor","noCooldownFreemiumThread","noCooldownInputBlocker","noCooldownLastPhase","formatNoCooldownTime","getNoCooldownFreemiumPhase","setNoCooldownInputBlocked","lockNoAbilityCooldown","unlockNoAbilityCooldown","refreshNoCooldownFreemiumState","CosmeticAssets","ActiveCosmeticContainer","ActiveCosmeticTrove","SelectedCosmeticName","CosmeticWeld","SetCosmeticVfxEnabled","NewCosmeticTrove","setupRankedBadge","setupMascot","attachPartsByName","attachHandleToHead","CosmeticHandlers","CollectCosmeticNames","DestroyActiveCosmetic","AttachFallbackCosmetic","EquipCosmetic","cosmeticDropdown","cosmeticRefreshQueued","QueueCosmeticRefresh","AutoStealEnabled","AutoStealConnection","BallDistanceEnabled","BallDistanceGui","BallDistanceLabel","BallDistanceConnection","GetBallColliderPosition","BallTeleportEnabled","BallTeleportConnection","BallTeleportLastTime","GetBallCollider"},Init=function()
Options = NexusUI.Options

PerfectShotEnabled = false
PerfectShotConnection = nil
NoCooldownEnabled = false
NoCooldownConnection = nil
NoStunEnabled = false
NoStunConnection = nil
NoRagdollEnabled = false
NoRagdollConnection = nil
AutoBlockEnabled = false
AutoBlockConnection = nil
AutoDribbleEnabled = false
AutoDribbleConnection = nil
SpeedBoostEnabled = false
SpeedBoostConnection = nil
SpeedBoostValue = 15
JumpBoostEnabled = false
JumpBoostConnection = nil
JumpBoostValue = 80
AutoPickupEnabled = false
AutoPickupConnection = nil
PickupRange = 30
AutoPickupLastTeleport = 0
ShotPowerEnabled = false
ShotPowerConnection = nil
ShotPowerMultiplier = 1.5
InfinitePumpFakesEnabled = false
InfinitePumpFakesThread = nil
BallController = nil
OriginalGetMaxPumpFakes = nil
FOVEnabled = false
FOVConnection = nil
FOVValue = 90
AntiSlipEnabled = false
AntiSlipConnection = nil
OriginalCameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance
OriginalFieldOfView = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70

RegisterUnloadCallback(function()
    waitingForKey = false
    LocalPlayer.CameraMaxZoomDistance = OriginalCameraMaxZoomDistance

    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = OriginalFieldOfView
    end

    for _, child in ipairs(GuiParent:GetChildren()) do
        if child.Name == "NexusNotify" then
            child:Destroy()
        end
    end
end)

MainSection = Tabs.Main:AddSection("Main")

playerCard = Instance.new("Frame")
playerCard.Size = UDim2.new(0.5, -4, 1, 0)
playerCard.Position = UDim2.new(0.5, 4, 0, 0)
playerCard.BackgroundTransparency = 1
playerCard.BorderSizePixel = 0
playerCard.Parent = Tabs.Main.Page

playerViewport = Instance.new("ViewportFrame")
-- Phone: keep the player preview compact and lower so it does not dominate the Main tab.
playerViewport.Size = IS_MOBILE and UDim2.fromOffset(64, 68) or UDim2.new(0, 175, 1, -70)
playerViewport.Position = IS_MOBILE and UDim2.new(0.5, 0, 0, 42) or UDim2.new(0.5, 0, 0, -40)
playerViewport.AnchorPoint = Vector2.new(0.5, 0)
playerViewport.BackgroundTransparency = 1
playerViewport.BorderSizePixel = 0
playerViewport.ClipsDescendants = true
playerViewport.Parent = playerCard

-- On mobile the ESP corners are placed inside a dynamic bounds frame which follows
-- the projected 3D bounding box of the character. Desktop keeps the original layout.
mobileEspBounds = nil
if IS_MOBILE then
    mobileEspBounds = Instance.new("Frame")
    mobileEspBounds.Name = "MobilePlayerEspBounds"
    mobileEspBounds.BackgroundTransparency = 1
    mobileEspBounds.BorderSizePixel = 0
    mobileEspBounds.Visible = false
    mobileEspBounds.ZIndex = 20
    mobileEspBounds.Parent = playerViewport
end

function AddEspCorner(anchorX, anchorY)
    local parent = IS_MOBILE and mobileEspBounds or playerViewport
    local yOffset = (not IS_MOBILE and anchorY == 0) and 52 or 0

    local hBar = Instance.new("Frame")
    hBar.Size = IS_MOBILE and UDim2.fromOffset(6, 1) or UDim2.new(0, 10, 0, 2)
    hBar.AnchorPoint = Vector2.new(anchorX, anchorY)
    hBar.Position = UDim2.new(anchorX, 0, anchorY, yOffset)
    hBar.BackgroundColor3 = ACCENT
    hBar.BorderSizePixel = 0
    hBar.ZIndex = 21
    hBar.Parent = parent

    local vBar = Instance.new("Frame")
    vBar.Size = IS_MOBILE and UDim2.fromOffset(1, 6) or UDim2.new(0, 2, 0, 10)
    vBar.AnchorPoint = Vector2.new(anchorX, anchorY)
    vBar.Position = UDim2.new(anchorX, 0, anchorY, yOffset)
    vBar.BackgroundColor3 = ACCENT
    vBar.BorderSizePixel = 0
    vBar.ZIndex = 21
    vBar.Parent = parent
end

AddEspCorner(0, 0)
AddEspCorner(1, 0)
AddEspCorner(0, 1)
AddEspCorner(1, 1)

playerWorldModel = Instance.new("WorldModel")
playerWorldModel.Parent = playerViewport

playerCamera = Instance.new("Camera")
playerCamera.Parent = playerViewport
playerViewport.CurrentCamera = playerCamera

playerInfo = Instance.new("Frame")
playerInfo.Size = UDim2.new(1, 0, 0, 48)
playerInfo.Position = UDim2.new(0, 0, 1, -54)
playerInfo.BackgroundTransparency = 1
playerInfo.Parent = playerCard

function makePlayerInfoLabel(text, size, color, yPos, fontWeight)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, size + 4)
    lbl.Position = UDim2.new(0, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", fontWeight, Enum.FontStyle.Normal)
    lbl.TextSize = size
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = playerInfo
    return lbl
end

playerNameLabel = makePlayerInfoLabel(LocalPlayer.DisplayName, 14, COLOR_TEXT, 0, Enum.FontWeight.Bold)
playerUserLabel = makePlayerInfoLabel("User", 11, Color3.fromRGB(60, 220, 100), 16, Enum.FontWeight.Medium)
playerIdLabel = makePlayerInfoLabel("ID: " .. tostring(LocalPlayer.UserId), 11, COLOR_TEXT_DIM, 31, Enum.FontWeight.Medium)

playerClonePivot = nil
playerSpinAngle = 0

function RefreshPlayerViewport()
    for _, child in ipairs(playerWorldModel:GetChildren()) do
        child:Destroy()
    end
    playerClonePivot = nil

    local character = LocalPlayer.Character
    if not character then return end

    local wasArchivable = character.Archivable
    character.Archivable = true
    local ok, clone = pcall(function()
        return character:Clone()
    end)
    character.Archivable = wasArchivable
    if not ok or not clone then return end

    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            descendant:Destroy()
        end
    end

    local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
    if cloneHumanoid then
        cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end

    clone.Parent = playerWorldModel

    local pivotOk, boundingCF, boundingSize = pcall(function()
        return clone:GetBoundingBox()
    end)
    if not pivotOk or not boundingCF then return end

    playerClonePivot = CFrame.new(boundingCF.Position)
    playerSpinAngle = 0

    local maxDim = math.max(boundingSize.X, boundingSize.Y, boundingSize.Z)
    local cameraDistance = IS_MOBILE and 1.65 or 1.15
    playerCamera.CFrame = CFrame.new(
        boundingCF.Position + (boundingCF.LookVector * maxDim * cameraDistance) + Vector3.new(0, boundingSize.Y * 0.02, 0),
        boundingCF.Position + Vector3.new(0, -boundingSize.Y * 0.05, 0)
    )
end

function UpdateMobilePlayerEspBounds(clone)
    if not IS_MOBILE or not mobileEspBounds then
        return
    end
    if not clone or not clone.Parent then
        mobileEspBounds.Visible = false
        return
    end

    local viewportSize = playerViewport.AbsoluteSize
    if viewportSize.X <= 1 or viewportSize.Y <= 1 then
        mobileEspBounds.Visible = false
        return
    end

    local ok, boundingCF, boundingSize = pcall(function()
        return clone:GetBoundingBox()
    end)
    if not ok or not boundingCF or not boundingSize then
        mobileEspBounds.Visible = false
        return
    end

    local half = boundingSize * 0.5
    local focalLength = (viewportSize.Y * 0.5) / math.tan(math.rad(playerCamera.FieldOfView) * 0.5)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local projected = 0

    for ix = -1, 1, 2 do
        for iy = -1, 1, 2 do
            for iz = -1, 1, 2 do
                local worldPoint = boundingCF:PointToWorldSpace(Vector3.new(
                    half.X * ix,
                    half.Y * iy,
                    half.Z * iz
                ))
                local cameraPoint = playerCamera.CFrame:PointToObjectSpace(worldPoint)
                local depth = -cameraPoint.Z

                if depth > 0.01 then
                    local screenX = viewportSize.X * 0.5 + (cameraPoint.X / depth) * focalLength
                    local screenY = viewportSize.Y * 0.5 - (cameraPoint.Y / depth) * focalLength
                    minX = math.min(minX, screenX)
                    minY = math.min(minY, screenY)
                    maxX = math.max(maxX, screenX)
                    maxY = math.max(maxY, screenY)
                    projected = projected + 1
                end
            end
        end
    end

    if projected == 0 then
        mobileEspBounds.Visible = false
        return
    end

    local padding = 1
    minX = math.clamp(minX - padding, 1, viewportSize.X - 2)
    minY = math.clamp(minY - padding, 1, viewportSize.Y - 2)
    maxX = math.clamp(maxX + padding, minX + 2, viewportSize.X - 1)
    maxY = math.clamp(maxY + padding, minY + 2, viewportSize.Y - 1)

    mobileEspBounds.Position = UDim2.fromOffset(math.floor(minX + 0.5), math.floor(minY + 0.5))
    mobileEspBounds.Size = UDim2.fromOffset(
        math.max(3, math.floor((maxX - minX) + 0.5)),
        math.max(3, math.floor((maxY - minY) + 0.5))
    )
    mobileEspBounds.Visible = true
end

TrackScriptConnection(RunService.RenderStepped:Connect(function(dt)
    if not playerClonePivot then
        if mobileEspBounds then
            mobileEspBounds.Visible = false
        end
        return
    end
    local clone = playerWorldModel:FindFirstChildOfClass("Model")
    if not clone then
        playerClonePivot = nil
        if mobileEspBounds then
            mobileEspBounds.Visible = false
        end
        return
    end
    playerSpinAngle = (playerSpinAngle + dt * 0.9) % (math.pi * 2)
    clone:PivotTo(playerClonePivot * CFrame.Angles(0, playerSpinAngle, 0))
    UpdateMobilePlayerEspBounds(clone)
end))

TrackScriptConnection(LocalPlayer.CharacterAdded:Connect(function()
    playerNameLabel.Text = LocalPlayer.DisplayName
    task.delay(1, RefreshPlayerViewport)
end))

task.delay(1, RefreshPlayerViewport)

PerfectShotLastCorrectionTime = 0

function GetCurrentBall()
    local reference = ReplicatedStorage:FindFirstChild("Basketball")
    if not reference or not reference:IsA("ObjectValue") then
        return nil
    end

    local ball = reference.Value
    if ball and ball:IsA("BasePart") and ball:IsDescendantOf(Workspace) then
        return ball
    end
    return nil
end

function GetTargetHoop()
    local team = LocalPlayer.Team
    local hoops = Workspace:FindFirstChild("Hoops")
    local teamHoops = team and hoops and hoops:FindFirstChild(team.Name)
    local hoop = teamHoops and teamHoops:FindFirstChild("Hoop")
    if hoop and hoop:IsA("BasePart") then
        return hoop
    end
    return nil
end

do
    -- Keep this controller separate from the Infinite Pump Fakes feature.
    local shotController = nil
    local shotGeneration = 0

    local function CorrectPerfectShot(expectedBall)
        if ScriptUnloaded or not PerfectShotEnabled
            or LocalPlayer:GetAttribute("DesyncPlr") then
            return false
        end

        local ball = GetCurrentBall()
        local hoop = GetTargetHoop()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not ball or ball ~= expectedBall or not hoop
            or not root or not root:IsA("BasePart") or ball.Anchored then
            return false
        end

        if not shotController:LocalPlayerIsBallNetworkOwner()
            or shotController:GetLastPlayerToPossessBall() ~= LocalPlayer
            or shotController:GetPlayerPossessingBall() ~= nil then
            return false
        end

        local displacement = hoop.Position - ball.Position
        local closeShot = (root.Position - hoop.Position).Magnitude <= 30
        local base = closeShot and 1.35 or 0.75
        local scale = closeShot and 0.0455 or 0.045
        local flightTime = math.log(base + displacement.Magnitude * scale)
        if flightTime ~= flightTime or flightTime <= 0.05
            or flightTime == math.huge then
            return false
        end

        local velocity = displacement / flightTime
            + Vector3.new(0, Workspace.Gravity * flightTime * 0.5, 0)
        if velocity.X ~= velocity.X or velocity.Y ~= velocity.Y
            or velocity.Z ~= velocity.Z or velocity.Magnitude == math.huge then
            return false
        end

        ball.AssemblyLinearVelocity = velocity
        PerfectShotLastCorrectionTime = tick()
        return true
    end

    local function BindPerfectShot()
        if PerfectShotConnection then
            return true
        end

        local ok, result = pcall(function()
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            local knitModule = packages and packages:FindFirstChild("Knit")
            if not knitModule then
                error("Knit is not available yet")
            end

            local knit = require(knitModule)
            local controller = knit.GetController("BallController")
            local service = knit.GetService("BallService")
            for _, method in ipairs({
                "LocalPlayerIsBallNetworkOwner",
                "GetLastPlayerToPossessBall",
                "GetPlayerPossessingBall",
            }) do
                if type(controller[method]) ~= "function" then
                    error("BallController is missing " .. method)
                end
            end

            shotController = controller
            return service.Throw:Connect(function()
                if ScriptUnloaded or not PerfectShotEnabled then
                    return
                end

                shotGeneration = shotGeneration + 1
                local generation = shotGeneration
                local ball = GetCurrentBall()
                if not ball then
                    return
                end

                task.defer(function()
                    -- Run after the event handlers, before the next physics step.
                    RunService.PreSimulation:Wait()
                    if ScriptUnloaded or not PerfectShotEnabled
                        or generation ~= shotGeneration then
                        return
                    end

                    local corrected, reason = pcall(CorrectPerfectShot, ball)
                    if not corrected then
                        warn("[Perfect Shot] Correction failed: " .. tostring(reason))
                    end
                end)
            end)
        end)

        if not ok then
            shotController = nil
            warn("[Perfect Shot] Initialization failed; toggle off/on to retry: "
                .. tostring(result))
            return false
        end

        PerfectShotConnection = TrackScriptConnection(result)
        return true
    end

    Tabs.Main:AddToggle("PerfectShot", {
        Title = "Perfect Shot",
        Description = "Corrects your shots when your client controls the ball",
        Default = false,
        Callback = function(Value)
            shotGeneration = shotGeneration + 1
            PerfectShotLastCorrectionTime = 0
            PerfectShotEnabled = Value and not ScriptUnloaded
            if PerfectShotEnabled and not BindPerfectShot() then
                PerfectShotEnabled = false
            end
        end
    })

    RegisterUnloadCallback(function()
        PerfectShotEnabled = false
        shotGeneration = shotGeneration + 1
        PerfectShotLastCorrectionTime = 0
        if PerfectShotConnection then
            PerfectShotConnection:Disconnect()
            PerfectShotConnection = nil
        end
        shotController = nil
    end)
end

NoCooldownControllerInstance = nil

function FindNoCooldownController()
    if NoCooldownControllerInstance then return NoCooldownControllerInstance end
    pcall(function()
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" then
                if rawget(obj, "CDS") and rawget(obj, "Name") == "AbilityController" then
                    NoCooldownControllerInstance = obj
                    return
                end
            end
        end
    end)
    return NoCooldownControllerInstance
end

Tabs.Main:AddToggle("NoAbilityCooldown", {
    Title = "No Ability Cooldown",
    Description = IS_PREMIUM_USER and "Remove cooldowns from abilities" or "Remove cooldowns from abilities (Freemium: 1 hour access)",
    Default = false,
    Callback = function(Value)
        NoCooldownEnabled = Value
        if Value then
            if NoCooldownConnection then
                NoCooldownConnection:Disconnect()
                NoCooldownConnection = nil
            end
            NoCooldownConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function()
                if not NoCooldownEnabled then return end
                local instance = FindNoCooldownController()
                if instance and instance.CDS then
                    for i = 1, 4 do
                        if instance.CDS[i] then
                            instance.CDS[i] = 0
                        end
                    end
                end
            end))
        else
            if NoCooldownConnection then
                NoCooldownConnection:Disconnect()
                NoCooldownConnection = nil
            end
        end
    end
})

executorName = ""
pcall(function()
    if type(identifyexecutor) == "function" then
        executorName = string.lower(tostring(identifyexecutor()))
    end
end)

noCooldownUnsupportedExecutor = executorName:find("xeno") or executorName:find("solara")
noCooldownFreemiumThread = nil
noCooldownInputBlocker = nil
noCooldownLastPhase = nil

function formatNoCooldownTime(seconds)
    seconds = math.max(0, math.ceil(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function getNoCooldownFreemiumPhase()
    if IS_PREMIUM_USER or not NoCooldownFreemiumCycleStart then
        return "premium", math.huge
    end

    local now = os.time()
    local elapsed = math.max(0, now - NoCooldownFreemiumCycleStart)
    local offset = elapsed % NO_COOLDOWN_FREEMIUM_CYCLE_DURATION

    if offset < NO_COOLDOWN_FREEMIUM_ACCESS_DURATION then
        return "access", NO_COOLDOWN_FREEMIUM_ACCESS_DURATION - offset
    end

    return "locked", NO_COOLDOWN_FREEMIUM_CYCLE_DURATION - offset
end

function setNoCooldownInputBlocked(blocked)
    local noCdOption = NexusUI.Options["NoAbilityCooldown"]
    if not noCdOption or not noCdOption.Frame then
        return
    end

    if blocked then
        noCdOption.Frame.Active = false
        noCdOption.Frame.Selectable = false

        if not noCooldownInputBlocker or not noCooldownInputBlocker.Parent then
            noCooldownInputBlocker = Instance.new("TextButton")
            noCooldownInputBlocker.Name = "FreemiumInputBlocker"
            noCooldownInputBlocker.Size = UDim2.fromScale(1, 1)
            noCooldownInputBlocker.Position = UDim2.fromScale(0, 0)
            noCooldownInputBlocker.BackgroundTransparency = 1
            noCooldownInputBlocker.BorderSizePixel = 0
            noCooldownInputBlocker.Text = ""
            noCooldownInputBlocker.AutoButtonColor = false
            noCooldownInputBlocker.Active = true
            noCooldownInputBlocker.Selectable = false
            noCooldownInputBlocker.ZIndex = 100
            noCooldownInputBlocker.Parent = noCdOption.Frame
        end
    else
        noCdOption.Frame.Active = true
        noCdOption.Frame.Selectable = true

        if noCooldownInputBlocker then
            pcall(function()
                noCooldownInputBlocker:Destroy()
            end)
            noCooldownInputBlocker = nil
        end
    end
end

function lockNoAbilityCooldown(reason, useBanner)
    local noCdOption = NexusUI.Options["NoAbilityCooldown"]
    if not noCdOption then
        return
    end

    if NoCooldownConnection then
        NoCooldownConnection:Disconnect()
        NoCooldownConnection = nil
    end
    NoCooldownEnabled = false

    if useBanner then
        noCdOption:SetLockedText(reason or "Locked")
    else
        -- Keep the normal title visible so the 10-hour unlock countdown
        -- can be displayed directly in the function name.
        noCdOption:SetLockedText("")
    end

    noCdOption:SetLocked(true)
    setNoCooldownInputBlocked(true)
end

function unlockNoAbilityCooldown()
    local noCdOption = NexusUI.Options["NoAbilityCooldown"]
    if not noCdOption then
        return
    end

    noCdOption:SetLockedText("")
    noCdOption:SetLocked(false)
    setNoCooldownInputBlocked(false)
end

function refreshNoCooldownFreemiumState(sendTransitionNotification)
    if IS_PREMIUM_USER or noCooldownUnsupportedExecutor or ScriptUnloaded then
        return
    end

    local noCdOption = NexusUI.Options["NoAbilityCooldown"]
    if not noCdOption then
        return
    end

    local phase, remaining = getNoCooldownFreemiumPhase()

    if phase == "access" then
        if noCdOption:IsLocked() then
            unlockNoAbilityCooldown()
        end

        noCdOption:SetTitle(
            "No Ability Cooldown [" .. formatNoCooldownTime(remaining) .. "]"
        )

        if sendTransitionNotification and noCooldownLastPhase == "locked" then
            NexusUI:Notify({
                Title = "PRIME",
                Content = "No Ability Cooldown unlocked for 1 hour.",
                Duration = 5
            })
        end
    else
        if not noCdOption:IsLocked() then
            lockNoAbilityCooldown(nil, false)
        else
            setNoCooldownInputBlocked(true)
        end

        noCdOption:SetTitle(
            "No Ability Cooldown [LOCK " .. formatNoCooldownTime(remaining) .. "]"
        )

        if sendTransitionNotification and noCooldownLastPhase == "access" then
            NexusUI:Notify({
                Title = "PRIME",
                Content = "No Ability Cooldown locked for 4 hours.",
                Duration = 5
            })
        end
    end

    noCooldownLastPhase = phase
end

if noCooldownUnsupportedExecutor then
    local unsupportedName = executorName:find("xeno") and "Xeno" or "Solara"
    lockNoAbilityCooldown("Not supported on " .. unsupportedName, true)
    NexusUI:Notify({
        Title = "PRIME",
        Content = "No Ability Cooldown is not supported on your executor",
        Duration = 5
    })
elseif not IS_PREMIUM_USER then
    -- First render immediately, then update the title every second.
    refreshNoCooldownFreemiumState(false)

    noCooldownFreemiumThread = task.spawn(function()
        while not ScriptUnloaded do
            task.wait(1)
            refreshNoCooldownFreemiumState(true)
        end
    end)
else
    local noCdOption = NexusUI.Options["NoAbilityCooldown"]
    if noCdOption then
        noCdOption:SetTitle("No Ability Cooldown")
    end
end

RegisterUnloadCallback(function()
    if noCooldownFreemiumThread then
        pcall(task.cancel, noCooldownFreemiumThread)
        noCooldownFreemiumThread = nil
    end

    if noCooldownInputBlocker then
        pcall(function()
            noCooldownInputBlocker:Destroy()
        end)
        noCooldownInputBlocker = nil
    end
end)

Tabs.Main:AddToggle("NoStun", {
    Title = "No Stun",
    Description = "Prevents stun effects",
    Default = false,
    Callback = function(Value)
        NoStunEnabled = Value
        if Value then
            local function RemoveStunEffects()
                if not NoStunEnabled then return end
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v.Name:lower():find("stun") or v.Name:lower():find("impact") or v.Name:lower():find("dizzy") then
                            pcall(function() v:Destroy() end)
                        end
                    end
                    if LocalPlayer.Character:GetAttribute("Stunned") then
                        LocalPlayer.Character:SetAttribute("Stunned", false)
                    end
                    if LocalPlayer.Character:GetAttribute("StunTime") then
                        LocalPlayer.Character:SetAttribute("StunTime", 0)
                    end
                end
            end
            NoStunConnection = TrackScriptConnection(RunService.Heartbeat:Connect(RemoveStunEffects))
        else
            if NoStunConnection then
                NoStunConnection:Disconnect()
                NoStunConnection = nil
            end
        end
    end
})

Tabs.Main:AddToggle("NoRagdoll", {
    Title = "No Ragdoll",
    Description = "Prevents ragdoll effects",
    Default = false,
    Callback = function(Value)
        NoRagdollEnabled = Value
        if Value then
            local function RemoveRagdoll()
                if not NoRagdollEnabled then return end
                if not LocalPlayer.Character then return end
                local isRagdoll = LocalPlayer.Character:FindFirstChild("IsRagdoll")
                if isRagdoll and isRagdoll:IsA("BoolValue") then
                    if isRagdoll.Value == true then
                        isRagdoll.Value = false
                    end
                end
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Anchored then
                    hrp.Anchored = false
                end
                if hrp and hrp.AssemblyLinearVelocity.Magnitude > 100 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if humanoid.PlatformStand then
                        humanoid.PlatformStand = false
                    end
                    if humanoid.Sit then
                        humanoid.Sit = false
                    end
                end
            end
            NoRagdollConnection = TrackScriptConnection(RunService.Heartbeat:Connect(RemoveRagdoll))
        else
            if NoRagdollConnection then
                NoRagdollConnection:Disconnect()
                NoRagdollConnection = nil
            end
        end
    end
})


Tabs.Main:AddToggle("AutoBlock", {
    Title = "Auto Block",
    Description = "auto ball block",
    Default = false,
    Callback = function(Value)
        AutoBlockEnabled = Value
        if Value then
            local AUTO_BLOCK_RANGE = 15.5
            local COOLDOWN = 0.1
            local lastBlockTime = 0
            local isBlocking = false
            local blockedAnimationIds = {

                "rbxassetid://111975541117141",
                "rbxassetid://76228113424835",
                "rbxassetid://77325057015467",
                "rbxassetid://81077726192701",
                "rbxassetid://97212719145496",
                "rbxassetid://93637049934243",
                "rbxassetid://86845329217363",
                "rbxassetid://85237775854620",
                "rbxassetid://76799100204102",
                "rbxassetid://140044737112890",
                "rbxassetid://75206041339842",
                "rbxassetid://93426416285702",
                "rbxassetid://92462901193976",
                "rbxassetid://97638974924509",
                "rbxassetid://103324749935306",
                "rbxassetid://80419239450998",
                "rbxassetid://83196870153629",
                "rbxassetid://82883842626848",
                "rbxassetid://135837817164001",
                "rbxassetid://134971996964091",
                "rbxassetid://139790361616736",
                "rbxassetid://98718932626065",
                "rbxassetid://90905743250824",
                "rbxassetid://112630239907251",    
                "rbxassetid://125858081984425",
                "rbxassetid://89731716334782",
                "rbxassetid://93824649798557",
                "rbxassetid://115245242244708",
                "rbxassetid://87091601850111",
                "rbxassetid://86466269548335",
                "rbxassetid://85842414472420",
                "rbxassetid://122154195183566",
                "rbxassetid://101759701167020",
                "rbxassetid://91149657331993",
                "rbxassetid://131932666588221",
                "rbxassetid://100842460034279",
                "rbxassetid://94452665372956",
                "rbxassetid://83037726599973",
                "rbxassetid://131498997481190",
                "rbxassetid://115763852918123",
                "rbxassetid://139765328348537"

            }

            
            local function Jump()
                local char = LocalPlayer.Character
                if not char then return false end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not humanoid then return false end
                if not isBlocking and humanoid.FloorMaterial ~= Enum.Material.Air and tick() - lastBlockTime > COOLDOWN then
                    isBlocking = true
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    lastBlockTime = tick()
                    task.delay(0.2, function() isBlocking = false end)
                    return true
                end
            end

            local function HasBlockingAnimation(player)
                local char = player and player.Character
                if not char then return false end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not humanoid then return false end
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if not animator then return false end

                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track and track.Animation then
                        local animationId = track.Animation.AnimationId
                        for _, blockedId in ipairs(blockedAnimationIds) do
                            if animationId == blockedId then
                                return true
                            end
                        end
                    end
                end

                return false
            end
            
            AutoBlockConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function()
                if not AutoBlockEnabled then return end
                local ball = GetCurrentBall()
                if not ball then return end
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist <= AUTO_BLOCK_RANGE and HasBlockingAnimation(p) then
                            Jump()
                            return
                        end
                    end
                end
            end))
        else
            if AutoBlockConnection then
                AutoBlockConnection:Disconnect()
                AutoBlockConnection = nil
            end
        end
    end
})

Tabs.Main:AddToggle("AutoDribble", {
    Title = "Auto Dribble",
    Description = "Auto triggers Dribble when enemy dribbles nearby",
    Default = false,
    Callback = function(Value)
        AutoDribbleEnabled = Value

        local targetAnimations = {
            "rbxassetid://132607768946898",
            "rbxassetid://106268822474526",
            "rbxassetid://101683719313060",
        }
        local lastFire = 0
        local COOLDOWN = 0.01
        local DRIBBLE_RANGE = 100
        local dribbleConnections = {}

        local function isEnemy(targetPlayer)
            return targetPlayer.Team ~= LocalPlayer.Team
        end

        local function findDribbleBtn()
            local ok, btn = pcall(function()
                return LocalPlayer.PlayerGui.Mobile.Ball.Dribble
            end)
            if ok and btn and btn:IsA("GuiButton") then
                return btn
            end
            pcall(function()
                for _, v in ipairs(PlayerGui:GetDescendants()) do
                    if v:IsA("GuiButton") and v.Name:lower() == "dribble" then
                        return v
                    end
                end
            end)
            return nil
        end

        local function activateDribble(btn)
            if not btn then return false end
            if typeof(getconnections) == "function" then
                pcall(function()
                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                        pcall(function() conn.Function() end)
                    end
                end)
                return true
            end
            return false
        end

        local function trackPlayerConn(targetPlayer, conn)
            if not dribbleConnections[targetPlayer] then
                dribbleConnections[targetPlayer] = {}
            end
            table.insert(dribbleConnections[targetPlayer], conn)
        end

        local function disconnectPlayer(targetPlayer)
            if dribbleConnections[targetPlayer] then
                for _, conn in ipairs(dribbleConnections[targetPlayer]) do
                    pcall(function() conn:Disconnect() end)
                end
                dribbleConnections[targetPlayer] = nil
            end
        end

        local function disconnectAllPlayers()
            for p, _ in pairs(dribbleConnections) do
                if typeof(p) ~= "number" then
                    disconnectPlayer(p)
                end
            end
            for _, conn in ipairs(dribbleConnections) do
                pcall(function() conn:Disconnect() end)
            end
            dribbleConnections = {}
        end

        local function connectCharacter(targetPlayer, character)
            disconnectPlayer(targetPlayer)
            if targetPlayer == LocalPlayer then return end
            dribbleConnections[targetPlayer] = {}

            local function onAnimPlayed(animTrack)
                if not AutoDribbleEnabled then return end
                if not isEnemy(targetPlayer) then return end
                local animId = animTrack.Animation and animTrack.Animation.AnimationId
                if not animId then return end
                for _, targetId in ipairs(targetAnimations) do
                    if animId == targetId then
                        local localChar = LocalPlayer.Character
                        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                        local targetRoot = character:FindFirstChild("HumanoidRootPart")
                        if localRoot and targetRoot then
                            local distance = (localRoot.Position - targetRoot.Position).Magnitude
                            if distance <= DRIBBLE_RANGE then
                                local now = tick()
                                if now - lastFire < COOLDOWN then return end
                                lastFire = now
                                local btn = findDribbleBtn()
                                if btn then
                                    activateDribble(btn)
                                end
                            end
                        end
                        break
                    end
                end
            end

            local function tryConnect()
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if not animator then
                    local waitConn
                    waitConn = humanoid.ChildAdded:Connect(function(child)
                        if child:IsA("Animator") then
                            waitConn:Disconnect()
                            trackPlayerConn(targetPlayer, child.AnimationPlayed:Connect(onAnimPlayed))
                        end
                    end)
                    trackPlayerConn(targetPlayer, waitConn)
                    return
                end
                trackPlayerConn(targetPlayer, animator.AnimationPlayed:Connect(onAnimPlayed))
            end

            tryConnect()
        end

        local function connectAllPlayers()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    if p.Character then
                        connectCharacter(p, p.Character)
                    end
                    trackPlayerConn(p, p.CharacterAdded:Connect(function(char)
                        connectCharacter(p, char)
                    end))
                end
            end
            table.insert(dribbleConnections, Players.PlayerAdded:Connect(function(p)
                trackPlayerConn(p, p.CharacterAdded:Connect(function(char)
                    connectCharacter(p, char)
                end))
            end))
        end

        if Value then
            connectAllPlayers()

            RegisterUnloadCallback(disconnectAllPlayers)
        else
            disconnectAllPlayers()
        end
    end
})

Tabs.Main:AddSection("Additional").Frame.Parent = MainSection.Frame.Parent

-- Cosmetic selector (Additional)
CosmeticAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Cosmetics")
ActiveCosmeticContainer = nil
ActiveCosmeticTrove = nil
SelectedCosmeticName = "None"

function CosmeticWeld(part0, part1)
    if not part0 or not part1 then
        return nil
    end
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.Parent = part1
    return weld
end

function SetCosmeticVfxEnabled(root, enabled)
    if not root then return end
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("ParticleEmitter")
            or descendant:IsA("Trail")
            or descendant:IsA("Beam")
            or descendant:IsA("Fire")
            or descendant:IsA("Smoke")
            or descendant:IsA("Sparkles")
            or descendant:IsA("PointLight")
            or descendant:IsA("SpotLight")
            or descendant:IsA("SurfaceLight") then
            descendant.Enabled = enabled
        end
    end
end

function NewCosmeticTrove()
    local trove = {Items = {}}

    function trove:Add(item)
        if item ~= nil then
            table.insert(self.Items, item)
        end
        return item
    end

    function trove:Clean()
        for index = #self.Items, 1, -1 do
            local item = self.Items[index]
            local itemType = typeof(item)

            if itemType == "function" then
                pcall(item)
            elseif itemType == "RBXScriptConnection" then
                pcall(function()
                    if item.Connected then
                        item:Disconnect()
                    end
                end)
            elseif itemType == "Instance" then
                pcall(function()
                    item:Destroy()
                end)
            elseif itemType == "thread" then
                pcall(task.cancel, item)
            elseif type(item) == "table" then
                if type(item.Destroy) == "function" then
                    pcall(function() item:Destroy() end)
                elseif type(item.Clean) == "function" then
                    pcall(function() item:Clean() end)
                elseif type(item.Disconnect) == "function" then
                    pcall(function() item:Disconnect() end)
                end
            end

            self.Items[index] = nil
        end
    end

    return trove
end

function setupRankedBadge(_, cosmeticModel, _)
	local badgeVisuals = ReplicatedStorage.Assets.Misc.RankedBadgeVisuals:Clone()
	badgeVisuals.Parent = cosmeticModel
	badgeVisuals.Enabled = true
end

function setupMascot(character, mascotModel, trove)
	for _, accessory in character:GetChildren() do
		if accessory:IsA("Accessory") then
			local originalTransparency = accessory.Handle.Transparency
			accessory.Handle.Transparency = 1

			trove:Add(function()
				accessory.Handle.Transparency = originalTransparency
			end)
		end
	end

	for _, bodyModel in mascotModel:GetChildren() do
		for _, part in bodyModel:GetChildren() do
			if part ~= bodyModel.Main then
				local internalWeld = trove:Add(Instance.new("WeldConstraint"))
				internalWeld.Parent = part
				internalWeld.Part0 = bodyModel.Main
				internalWeld.Part1 = part
			end
		end

		bodyModel.Main.CFrame = character:FindFirstChild(bodyModel.Name).CFrame

		local bodyWeld = trove:Add(Instance.new("WeldConstraint"))
		bodyWeld.Parent = bodyModel.Main
		bodyWeld.Part0 = character:FindFirstChild(bodyModel.Name)
		bodyWeld.Part1 = bodyModel.Main
	end

	local player = Players:GetPlayerFromCharacter(character)

	if player ~= nil then
		for _, descendant in mascotModel:GetDescendants() do
			if descendant:IsA("SurfaceAppearance") and descendant.Parent.Name == "Jersey" then
				descendant.Color = player.Team:GetAttribute("Color")
			end
		end

		trove:Add(player:GetPropertyChangedSignal("Team"):Connect(function()
			for _, descendant in mascotModel:GetDescendants() do
				if descendant:IsA("SurfaceAppearance") and descendant.Parent.Name == "Jersey" then
					descendant.Color = player.Team:GetAttribute("Color")
				end
			end
		end))
	end
end

function attachPartsByName(character, cosmeticModel, _)
	for _, cosmeticPart in cosmeticModel:GetChildren() do
		local characterPart = character:FindFirstChild(cosmeticPart.Name)

		if characterPart then
			cosmeticPart.CFrame = characterPart.CFrame
			cosmeticPart.WeldConstraint.Part1 = characterPart
		end
	end
end

function attachHandleToHead(character, cosmetic, trove)
	cosmetic.Handle:PivotTo(character.Head.CFrame)
	trove:Add(CosmeticWeld(character.Head, cosmetic.Handle))
end

CosmeticHandlers = {
	["Tentacles"] = function(character, cosmeticModel, trove)
		local torso = character:FindFirstChild("Torso")

		for index = 1, 4 do
			local tentacle = cosmeticModel:FindFirstChild(("tentacle%s"):format(index))
			tentacle.Cylinder.CFrame =
				torso.CFrame
				* CFrame.new(0, -3, 0)
				* CFrame.Angles(0, math.pi, 0)

			trove:Add(CosmeticWeld(torso, tentacle.Cylinder))
			trove:Add(
				tentacle.AnimationController.Animator:LoadAnimation(
					cosmeticModel.Anims:FindFirstChild(tostring(index))
				)
			):Play(0)
		end
	end,

	["Clouds"] = function(character, cosmeticModel, trove)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			local characterPart = character:FindFirstChild(cosmeticPart.Name)
			cosmeticPart.CFrame = characterPart.CFrame
			trove:Add(CosmeticWeld(characterPart, cosmeticPart))
		end
	end,

	["Psychic Jacket"] = function(character, cosmeticModel, trove)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			local characterPart = character:FindFirstChild(cosmeticPart.Name)
			cosmeticPart.CFrame = characterPart.CFrame
			trove:Add(CosmeticWeld(characterPart, cosmeticPart))
		end
	end,

	["Cyber Jacket"] = function(character, cosmeticModel, trove)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			local characterPart = character:FindFirstChild(cosmeticPart.Name)
			cosmeticPart.CFrame = characterPart.CFrame
			trove:Add(CosmeticWeld(characterPart, cosmeticPart))
		end
	end,

	["Brother Duo"] = function(character, companionCharacter, trove)
		local player = Players:GetPlayerFromCharacter(character)
		local fallbackUserId = nil
		local friendUserId

		if player == nil then
			friendUserId = fallbackUserId
		else
			local success
			success, friendUserId = pcall(function()
				local friends = Players:GetFriendsAsync(player.UserId):GetCurrentPage()
				return friends[Random.new():NextInteger(1, #friends)].Id
			end)

			if success ~= true then
				friendUserId = fallbackUserId
			end
		end

		local description = trove:Add(Players:GetHumanoidDescriptionFromUserId(friendUserId))
		companionCharacter.Humanoid:ApplyDescriptionReset(description)
		companionCharacter:ScaleTo(0.66)

		companionCharacter.HumanoidRootPart.CFrame =
			character.HumanoidRootPart.CFrame * CFrame.new(0.2, 0.47, 0.35)

		trove:Add(CosmeticWeld(character.HumanoidRootPart, companionCharacter.HumanoidRootPart))

		companionCharacter.Humanoid.Animator
			:LoadAnimation(ReplicatedStorage.Assets.EmoteAnimations.TodoReceiver)
			:Play(0)
	end,

	["S1 Bronze Badge"] = setupRankedBadge,
	["S1 Silver Badge"] = setupRankedBadge,
	["S1 Gold Badge"] = setupRankedBadge,
	["S1 Iron Badge"] = setupRankedBadge,
	["S1 Diamond Badge"] = setupRankedBadge,
	["S1 Platinum Badge"] = setupRankedBadge,
	["S1 Champion Badge"] = setupRankedBadge,

	["S2 Bronze Badge"] = setupRankedBadge,
	["S2 Silver Badge"] = setupRankedBadge,
	["S2 Gold Badge"] = setupRankedBadge,
	["S2 Iron Badge"] = setupRankedBadge,
	["S2 Diamond Badge"] = setupRankedBadge,
	["S2 Platinum Badge"] = setupRankedBadge,
	["S2 Champion Badge"] = setupRankedBadge,

	["Sun Man"] = setupMascot,
	["Dog Mascot"] = setupMascot,
	["Chrollo Mascot"] = setupMascot,
	["Hawk Mascot"] = setupMascot,
	["Duck Mascot"] = setupMascot,
	["BlueBee Mascot"] = setupMascot,
	["Bull Mascot"] = setupMascot,
	["Teddy Mascot"] = setupMascot,
	["Jofu Mascot"] = setupMascot,
	["Tatlis Mascot"] = setupMascot,

	["Straw Hat"] = function(character, cosmetic, trove)
		cosmetic.Handle:PivotTo(character.Head.CFrame)
		trove:Add(CosmeticWeld(character.Head, cosmetic.Handle))
	end,

	["Pineapple Head"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.5, 0)
					* CFrame.Angles(math.pi / 2, 0, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Current Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, 0, 0)
					* CFrame.Angles(0, math.pi, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Phoenix Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.5, 0)
					* CFrame.Angles(math.pi / 2, 0, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Golden Backpack"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.new(0, 0.114, 0.03)
					* CFrame.Angles(0, math.pi, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Demon Dog"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Meteor Aura"] = function(character, cosmeticModel, _)
		cosmeticModel.Root.Value = character.HumanoidRootPart
	end,

	["Skateboard"] = function(character, cosmetic, _)
		cosmetic.Handle.CFrame =
			character.Torso.CFrame
				* CFrame.new(0, 0, 0.5)
				* cosmetic.Handle.BodyBackAttachment.CFrame:Inverse()

		CosmeticWeld(cosmetic.Handle, character.Torso)
	end,

	["Cat!"] = function(character, cosmeticModel, trove)
		local animationTrack =
			cosmeticModel.AnimationController.Animator:LoadAnimation(cosmeticModel.Animation)

		animationTrack:Play()

		cosmeticModel.Cat.CFrame =
			character.Torso.CFrame
				* CFrame.new(0, 0.2, 0.55)
				* CFrame.fromEulerAngles(0, math.pi, 0)

		CosmeticWeld(cosmeticModel.Cat, character.Torso)

		trove:Add(function()
			animationTrack:Destroy()
		end)
	end,

	["Unlimited"] = function(character, cosmeticModel, trove)
		local animationTrack =
			cosmeticModel.AnimationController.Animator:LoadAnimation(cosmeticModel.Animation)

		animationTrack:Play()

		cosmeticModel.Icosphere.CFrame =
			character.Torso.CFrame * CFrame.new(0, 0, 1)

		CosmeticWeld(cosmeticModel.Icosphere, character.Torso)
		SetCosmeticVfxEnabled(cosmeticModel, true)

		trove:Add(function()
			animationTrack:Destroy()
		end)
	end,

	["Winner"] = function(character, cosmeticPart, trove)
		cosmeticPart.Parent = ActiveCosmeticContainer or workspace

		cosmeticPart.CFrame =
			character["Right Arm"].CFrame
				* CFrame.new(0.35, 0, 0)
				* CFrame.fromEulerAnglesXYZ(0, -math.pi / 2, 0)

		CosmeticWeld(cosmeticPart, character["Right Arm"])

		trove:Add(task.spawn(function()
			local hueDegrees = 0

			while task.wait(1) do
				hueDegrees = (hueDegrees + 20) % 360

				local color = Color3.fromHSV(hueDegrees / 360, 0.7, 0.7)
				local red = color.R * 20
				local green = color.G * 20
				local blue = color.B * 20

				TweenService:Create(
					cosmeticPart.Mesh,
					TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						VertexColor = Vector3.new(red, green, blue),
					}
				):Play()
			end
		end))
	end,

	["Oni's Wrath"] = function(character, cosmeticModel, _)
		cosmeticModel.WeldLeftArm.Weld.Part0 = character["Left Arm"]
		cosmeticModel.WeldRightArm.Weld.Part0 = character["Right Arm"]
		cosmeticModel.WeldTorso.Weld.Part0 = character.Torso
	end,

	["Vampire Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.5, 0)
					* CFrame.Angles(math.pi / 2, 0, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Emperor Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.7, 0.65)
					* CFrame.Angles(math.pi / 2, 0, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Cherry Blossom Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.5, 0)
					* CFrame.Angles(math.pi / 2, 0, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Gold Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.6, 1.15)
					* CFrame.fromEulerAnglesYXZ(math.pi / 2, math.pi, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Model"] = function(character, cosmeticPart, _)
		cosmeticPart.CFrame = character.HumanoidRootPart.CFrame
		CosmeticWeld(cosmeticPart, character.HumanoidRootPart)
	end,

	["Perfect Wings"] = function(character, cosmeticModel, trove)
		local animationTrack =
			cosmeticModel.AnimationController.Animator:LoadAnimation(cosmeticModel.Animation)

		animationTrack:Play()

		cosmeticModel:PivotTo(
			character.Torso.BodyBackAttachment.WorldCFrame
				* CFrame.Angles(0, math.pi, 0)
		)

		CosmeticWeld(cosmeticModel["Plane.001"], character.Torso)

		trove:Add(function()
			animationTrack:Destroy()
		end)
	end,

	["Rulebook Backpack"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.new(-0.375, -0.05, 0)
					* CFrame.Angles(0, -math.pi / 2, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Referee Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.6, 0.5)
					* CFrame.Angles(0, -math.pi / 2, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Referee Hat"] = attachHandleToHead,

	["Old Radio"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, math.pi / 2, 0)
					* CFrame.new(-0.55, 1, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Duck Hat"] = attachHandleToHead,

	["Heart Balloon"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, -math.pi / 2, 0)
					* CFrame.new(0.75, 0.25, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Joker Cape"] = function(character, cosmetic, trove)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.CFrame
					* CFrame.new(0, -0.477, 0.897)
					* CFrame.Angles(0, math.pi / 2, -math.pi / 12)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		else
			for _, torso in { character.Torso } do
				torso:SetAttribute("ColliderKey", "Cape")
				torso:SetAttribute("ColliderShape", "Box")
				torso:AddTag("SmartCollider")

				trove:Add(function()
					torso:SetAttribute("ColliderKey", nil)
					torso:SetAttribute("ColliderShape", nil)
					torso:RemoveTag("SmartCollider")
				end)
			end
		end
	end,

	["Wazzup! Mask"] = attachHandleToHead,
	["Ghost Mask"] = attachHandleToHead,
	["Cyber Glasses"] = attachHandleToHead,
	["Cyber Helmet"] = attachHandleToHead,

	["Cyber Wings"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, -math.pi / 2, 0)
					* CFrame.new(1.05, 0.3, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Dino Backpack"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, -math.pi / 2, 0)
					* CFrame.new(0.34, 0.25, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Popstar Keytar"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, math.pi / 2, math.pi / 4)
					* CFrame.new(-0.125, -1, 0.25)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Popstar Guitar"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, math.pi / 2, math.pi / 4)
					* CFrame.new(-0.3, -1.4, 0.1)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Popstar Backpack"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(character.Torso.CFrame)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Hanging Shoes"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.new(0, 0.1, 0.175)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["King's Crown"] = attachHandleToHead,

	["Air's Trophy"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyFrontAttachment.WorldCFrame
					* CFrame.Angles(0, 0, math.pi / 6)
					* CFrame.new(0, 0.5, 0.5)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Samurai Hat"] = attachHandleToHead,

	["Dual Katanas"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(character.Torso.CFrame)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Dragon Wrap"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyFrontAttachment.WorldCFrame
					* CFrame.Angles(0, math.pi, 0)
					* CFrame.new(-0.3, -0.45, 0.85)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Viki"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, math.pi / 2, 0)
					* CFrame.new(-0.058, -0.067, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Ace Backpack"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, -math.pi / 2, 0)
					* CFrame.new(-0.28, 0.062, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Crystal Arms"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Arm Wraps"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Witch Hat"] = attachHandleToHead,

	["Arm Band"] = function(character, cosmeticPart, _)
		cosmeticPart.Weld.Part0 = character:FindFirstChild("Left Arm")
	end,

	["Demon Wings"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.Angles(0, -math.pi / 2, 0)
					* CFrame.new(1.09, 1.4, 0)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Ancient Vines"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Watcher Eye"] = attachHandleToHead,
	["Giant Tongue"] = attachHandleToHead,
	["0 IQ"] = attachHandleToHead,
	["Obsessed Octopus"] = attachHandleToHead,

	["Magma Arms"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Glitchy"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Mech"] = function(character, cosmeticModel, trove)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			local characterPart = character:FindFirstChild(cosmeticPart.Name)

			if characterPart then
				cosmeticPart.Weld.Part0 = characterPart
				characterPart.Transparency = 1

				trove:Add(function()
					characterPart.Transparency = 0
				end)
			end
		end
	end,

	["Love Chain"] = function(character, cosmetic, _)
		if true then
			local handle = cosmetic.Handle
			handle.Parent = ActiveCosmeticContainer or character
			cosmetic:Destroy()

			handle:PivotTo(
				character.Torso.BodyBackAttachment.WorldCFrame
					* CFrame.new(0, 0.565, -0.588)
			)

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = character.Torso
			weld.Part1 = handle
			weld.Parent = handle
		end
	end,

	["Cursed Energy"] = function(character, cosmeticModel, _)
		for _, cosmeticPart in cosmeticModel:GetChildren() do
			cosmeticPart.Weld.Part0 = character:FindFirstChild(cosmeticPart.Name)
		end
	end,

	["Black Shock Aura"] = attachPartsByName,
	["Chrollo Aura"] = attachPartsByName,

	["Black Eye Aura"] = attachHandleToHead,
	["Gold Eye Aura"] = attachHandleToHead,
	["Skarp Eye Aura"] = attachHandleToHead,
}


function CollectCosmeticNames()
    local names = {"None"}
    for _, cosmetic in ipairs(CosmeticAssets:GetChildren()) do
        table.insert(names, cosmetic.Name)
    end
    table.sort(names, function(a, b)
        if a == "None" then return true end
        if b == "None" then return false end
        return a:lower() < b:lower()
    end)
    return names
end

function DestroyActiveCosmetic()
    if ActiveCosmeticTrove then
        ActiveCosmeticTrove:Clean()
        ActiveCosmeticTrove = nil
    end

    if ActiveCosmeticContainer then
        pcall(function()
            ActiveCosmeticContainer:Destroy()
        end)
        ActiveCosmeticContainer = nil
    end
end

function AttachFallbackCosmetic(character, cosmetic, trove)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")

    if cosmetic:IsA("Accessory") and humanoid then
        local ok = pcall(function()
            humanoid:AddAccessory(cosmetic)
        end)
        if ok then
            trove:Add(cosmetic)
            return true
        end
    end

    local attached = false
    local descendants = cosmetic:GetDescendants()
    for _, part in ipairs(descendants) do
        if part:IsA("BasePart") then
            local characterPart = character:FindFirstChild(part.Name)
            if characterPart and characterPart:IsA("BasePart") then
                part.CFrame = characterPart.CFrame
                trove:Add(CosmeticWeld(characterPart, part))
                attached = true
            else
                local weld = part:FindFirstChildWhichIsA("Weld") or part:FindFirstChildWhichIsA("WeldConstraint")
                if weld and weld.Part0 == nil then
                    local target = character:FindFirstChild(part.Name)
                    if target and target:IsA("BasePart") then
                        weld.Part0 = target
                        attached = true
                    end
                end
            end
        end
    end

    if attached then
        return true
    end

    local handle = cosmetic:FindFirstChild("Handle", true)
    if handle and handle:IsA("BasePart") and head then
        handle:PivotTo(head.CFrame)
        trove:Add(CosmeticWeld(head, handle))
        return true
    end

    local mainPart = nil
    if cosmetic:IsA("BasePart") then
        mainPart = cosmetic
    elseif cosmetic:IsA("Model") then
        mainPart = cosmetic.PrimaryPart or cosmetic:FindFirstChildWhichIsA("BasePart", true)
    else
        mainPart = cosmetic:FindFirstChildWhichIsA("BasePart", true)
    end

    if mainPart and root then
        if cosmetic:IsA("Model") then
            cosmetic:PivotTo(root.CFrame)
        else
            mainPart.CFrame = root.CFrame
        end
        trove:Add(CosmeticWeld(root, mainPart))
        return true
    end

    return false
end

function EquipCosmetic(cosmeticName, silent)
    DestroyActiveCosmetic()
    SelectedCosmeticName = cosmeticName or "None"

    if SelectedCosmeticName == "None" then
        return true
    end

    local source = CosmeticAssets:FindFirstChild(SelectedCosmeticName)
    if not source then
        if not silent then
            NexusUI:Notify({
                Title = "Cosmetics",
                Content = "Cosmetic not found: " .. tostring(SelectedCosmeticName),
                Duration = 2,
            })
        end
        return false
    end

    local character = LocalPlayer.Character
    if not character or not character.Parent then
        if not silent then
            NexusUI:Notify({
                Title = "Cosmetics",
                Content = "Character is not ready.",
                Duration = 2,
            })
        end
        return false
    end

    local container = Instance.new("Folder")
    container.Name = "Nexus_SelectedCosmetic"
    container.Parent = character

    local trove = NewCosmeticTrove()
    ActiveCosmeticContainer = container
    ActiveCosmeticTrove = trove

    local cosmetic = source:Clone()
    cosmetic.Name = "NexusCosmetic_" .. source.Name
    cosmetic.Parent = container
    trove:Add(cosmetic)

    local handler = CosmeticHandlers[source.Name]
    local success, result
    if handler then
        success, result = pcall(handler, character, cosmetic, trove)
    else
        success, result = pcall(AttachFallbackCosmetic, character, cosmetic, trove)
        if success and result ~= true then
            success = false
            result = "No compatible attachment point was found"
        end
    end

    if not success then
        DestroyActiveCosmetic()
        if not silent then
            NexusUI:Notify({
                Title = "Cosmetics",
                Content = "Failed to attach " .. source.Name .. ": " .. tostring(result),
                Duration = 3,
            })
        end
        return false
    end

    return true
end

cosmeticDropdown = nil

cosmeticRefreshQueued = false
function QueueCosmeticRefresh()
    if cosmeticRefreshQueued then return end
    cosmeticRefreshQueued = true
    task.defer(function()
        cosmeticRefreshQueued = false
        if ScriptUnloaded or not cosmeticDropdown then return end

        cosmeticDropdown:SetValues(CollectCosmeticNames())
        if SelectedCosmeticName ~= "None" and not CosmeticAssets:FindFirstChild(SelectedCosmeticName) then
            SelectedCosmeticName = "None"
            DestroyActiveCosmetic()
            cosmeticDropdown:SetValue("None")
        end
    end)
end

TrackScriptConnection(CosmeticAssets.ChildAdded:Connect(QueueCosmeticRefresh))
TrackScriptConnection(CosmeticAssets.ChildRemoved:Connect(QueueCosmeticRefresh))
TrackScriptConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    DestroyActiveCosmetic()
    if SelectedCosmeticName == "None" then return end

    task.defer(function()
        character:WaitForChild("HumanoidRootPart", 10)
        if not ScriptUnloaded and LocalPlayer.Character == character and SelectedCosmeticName ~= "None" then
            EquipCosmetic(SelectedCosmeticName, true)
        end
    end)
end))

RegisterUnloadCallback(function()
    SelectedCosmeticName = "None"
    DestroyActiveCosmetic()
end)


AutoStealEnabled = false
AutoStealConnection = nil

Tabs.Main:AddToggle("AutoSteal", {
    Title = "Auto Steal",
    Description = "Auto presses Steal near defenseless enemies",
    Default = false,
    Callback = function(Value)
        AutoStealEnabled = Value
        if Value then
            local STEAL_RANGE = 15
            local STEAL_COOLDOWN = 0.25
            local lastStealTime = 0
            local stealAnimations = {
                ["rbxassetid://123869422944350"] = true,
                ["rbxassetid://137719070884059"] = true,
                ["rbxassetid://77675226914078"] = true,
                ["rbxassetid://84679732852707"] = true,
                ["rbxassetid://114495158898257"] = true,
                ["rbxassetid://86983191995587"] = true,
                ["rbxassetid://90705265355566"] = true,
                ["rbxassetid://89134187056016"] = true,
                ["rbxassetid://75460749198444"] = true,
            }

            local function findStealBtn()
                local ok, btn = pcall(function()
                    return LocalPlayer.PlayerGui.Mobile.Ball.Steal
                end)
                if ok and btn and btn:IsA("GuiButton") then
                    return btn
                end
                local found = nil
                pcall(function()
                    for _, v in ipairs(PlayerGui:GetDescendants()) do
                        if v:IsA("GuiButton") and v.Name:lower() == "steal" then
                            found = v
                            break
                        end
                    end
                end)
                return found
            end

            local function activateSteal(btn)
                if not btn then return false end
                if typeof(getconnections) == "function" then
                    pcall(function()
                        for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                            pcall(function() conn.Function() end)
                        end
                    end)
                    return true
                end
                return false
            end

            local function isPlayingStealAnim(targetCharacter)
                local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                if not humanoid then return false end
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if not animator then return false end
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    local animId = track and track.Animation and track.Animation.AnimationId
                    if animId and stealAnimations[animId] then
                        return true
                    end
                end
                return false
            end

            AutoStealConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function()
                if not AutoStealEnabled then return end
                local now = tick()
                if now - lastStealTime < STEAL_COOLDOWN then return end
                local localChar = LocalPlayer.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if not localRoot then return end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character then
                        local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot and (localRoot.Position - targetRoot.Position).Magnitude <= STEAL_RANGE then
                            if isPlayingStealAnim(p.Character) then
                                local btn = findStealBtn()
                                if btn and activateSteal(btn) then
                                    lastStealTime = now
                                end
                                return
                            end
                        end
                    end
                end
            end))
        else
            if AutoStealConnection then
                AutoStealConnection:Disconnect()
                AutoStealConnection = nil
            end
        end
    end
})

RegisterUnloadCallback(function()
    AutoStealEnabled = false
    if AutoStealConnection then
        AutoStealConnection:Disconnect()
        AutoStealConnection = nil
    end
end)

BallDistanceEnabled = false
BallDistanceGui = nil
BallDistanceLabel = nil
BallDistanceConnection = nil

function GetBallColliderPosition()
    local ball = Workspace:FindFirstChild("Basketball")
    if not ball then return nil end
    local collider = ball:FindFirstChild("Collider")
    if not collider then return nil end
    local attrPos = collider:GetAttribute("Position")
    if typeof(attrPos) == "Vector3" then
        return attrPos
    end
    if collider:IsA("BasePart") then
        return collider.Position
    end
    if collider:IsA("Model") then
        local ok, pivot = pcall(function()
            return collider:GetPivot()
        end)
        if ok and pivot then
            return pivot.Position
        end
    end
    return nil
end

Tabs.Main:AddToggle("BallDistance", {
    Title = "Ball Distance",
    Description = "Shows distance to the ball on screen",
    Default = false,
    Callback = function(Value)
        BallDistanceEnabled = Value
        if Value then
            if not BallDistanceGui then
                BallDistanceGui = Instance.new("ScreenGui")
                BallDistanceGui.Name = "NexusBallDistance"
                BallDistanceGui.ResetOnSpawn = false
                BallDistanceGui.Parent = GuiParent

                BallDistanceLabel = Instance.new("TextLabel")
                BallDistanceLabel.Size = UDim2.new(0, 220, 0, 22)
                BallDistanceLabel.Position = UDim2.new(0, 10, 0.5, -11)
                BallDistanceLabel.BackgroundTransparency = 1
                BallDistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                BallDistanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                BallDistanceLabel.TextStrokeTransparency = 0.4
                BallDistanceLabel.Font = Enum.Font.GothamSemibold
                BallDistanceLabel.TextSize = 14
                BallDistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
                BallDistanceLabel.Text = ""
                BallDistanceLabel.Parent = BallDistanceGui
            end
            BallDistanceGui.Enabled = true
            BallDistanceConnection = TrackScriptConnection(RunService.RenderStepped:Connect(function()
                if not BallDistanceEnabled then return end
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local ballPos = GetBallColliderPosition()
                if root and ballPos then
                    BallDistanceLabel.Text = string.format("Ball: %.1f studs", (ballPos - root.Position).Magnitude)
                else
                    BallDistanceLabel.Text = "Ball: --"
                end
            end))
        else
            if BallDistanceConnection then
                BallDistanceConnection:Disconnect()
                BallDistanceConnection = nil
            end
            if BallDistanceGui then
                BallDistanceGui.Enabled = false
            end
        end
    end
})

RegisterUnloadCallback(function()
    BallDistanceEnabled = false
    if BallDistanceConnection then
        BallDistanceConnection:Disconnect()
        BallDistanceConnection = nil
    end
    if BallDistanceGui then
        BallDistanceGui:Destroy()
        BallDistanceGui = nil
        BallDistanceLabel = nil
    end
end)

BallTeleportEnabled = false
BallTeleportConnection = nil
BallTeleportLastTime = 0

function GetBallCollider()
    local ball = Workspace:FindFirstChild("Basketball")
    if not ball then return nil end
    local collider = ball:FindFirstChild("Collider")
    if collider and collider:IsA("BasePart") then
        return collider
    end
    return nil
end

Tabs.Main:AddToggle("BallTeleport", {
    Title = "Teleport to Ball",
    Description = "Smoothly teleports to the ball collider (anti-cheat bypass)",
    Default = false,
    Callback = function(Value)
        BallTeleportEnabled = Value
        if Value then
            BallTeleportConnection = TrackScriptConnection(RunService.Heartbeat:Connect(function(dt)
                if not BallTeleportEnabled then return end
                local now = tick()
                if now - BallTeleportLastTime < 0.1 then return end
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local collider = GetBallCollider()
                if not collider then return end

                local dist = (collider.Position - root.Position).Magnitude
                if dist <= 3 then return end

                BallTeleportLastTime = now
                local step = math.min(dist, math.max(60 * (dt or 0.016), 4))
                local direction = (collider.Position - root.Position).Unit
                local targetPos = root.Position + direction * step
                root.CFrame = CFrame.new(targetPos, collider.Position)
                root.AssemblyLinearVelocity = Vector3.new()
                root.AssemblyAngularVelocity = Vector3.new()
            end))
        else
            if BallTeleportConnection then
                BallTeleportConnection:Disconnect()
                BallTeleportConnection = nil
            end
        end
    end
})

RegisterUnloadCallback(function()
    BallTeleportEnabled = false
    if BallTeleportConnection then
        BallTeleportConnection:Disconnect()
        BallTeleportConnection = nil
    end
end)

end}
