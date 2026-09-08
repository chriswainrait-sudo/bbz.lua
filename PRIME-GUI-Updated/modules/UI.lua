return {Exports={"userInputService","TweenService","Players","RunService","ReplicatedStorage","Workspace","StarterGui","GuiService","LocalPlayer","PlayerGui","GetGuiParent","GuiParent","IsMobileDevice","IS_MOBILE","SHOW_RESTORE_BUTTON","NexusUI","ScriptUnloaded","ScriptConnections","UnloadCallbacks","GuiConnections","TrackGuiConnection","TrackScriptConnection","RegisterUnloadCallback","PRIME_TIER","IS_PREMIUM_USER","NO_COOLDOWN_FREEMIUM_ACCESS_DURATION","NO_COOLDOWN_FREEMIUM_LOCK_DURATION","NO_COOLDOWN_FREEMIUM_CYCLE_DURATION","NoCooldownFreemiumCycleStart","Clamp","MAIN_WINDOW_TRANSPARENCY","GUI_BUTTON_TRANSPARENCY","GUI_PANEL_TRANSPARENCY","GUI_OVERLAY_TRANSPARENCY","GUI_DISABLED_TRANSPARENCY","ACCENT","COLOR_WINDOW","COLOR_TOPBAR","COLOR_GROUP","COLOR_CONTROL","COLOR_BORDER","COLOR_TEXT","COLOR_TEXT_DIM","COLOR_ON_ACCENT","ApplyButtonStyle","CreateClickButton","ConnectClick","windowSize","Window","Tabs","currentCloseKey","waitingForKey","SettingsSection","keybindRow","keybindRowCorner","keybindTitle","keybindHint","keybindBadge","keybindBadgeCorner","keybindBadgeStroke","keybindBadgeLabel","UpdateKeybindBadge","SetGUIKey","BeginKeyBinding"},Init=function()


userInputService = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
Players = game:GetService("Players")
RunService = game:GetService("RunService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
StarterGui = game:GetService("StarterGui")
GuiService = game:GetService("GuiService")
LocalPlayer = Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

function GetGuiParent()
    local ok, hui = pcall(function()
        return gethui()
    end)
    if ok and typeof(hui) == "Instance" then
        return hui
    end
    local okCore, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if okCore and coreGui then
        return coreGui
    end
    return PlayerGui
end

GuiParent = GetGuiParent()

function IsMobileDevice()
    local success, platform = pcall(function()
        return userInputService:GetPlatform()
    end)

    if success then
        return platform == Enum.Platform.Android or platform == Enum.Platform.IOS
    end

    return userInputService.TouchEnabled and not userInputService.KeyboardEnabled
end

IS_MOBILE = IsMobileDevice()
SHOW_RESTORE_BUTTON = IS_MOBILE

NexusUI = {
    Options = {},
    State = {},
    Toggles = {}
}

ScriptUnloaded = false
ScriptConnections = {}
UnloadCallbacks = {}
GuiConnections = {}

function TrackGuiConnection(connection)
    if connection then
        table.insert(GuiConnections, connection)
    end
    return connection
end

function TrackScriptConnection(connection)
    if connection then
        table.insert(ScriptConnections, connection)
    end
    return connection
end

function RegisterUnloadCallback(callback)
    if callback then
        table.insert(UnloadCallbacks, callback)
    end
end

function NexusUI:UnloadFeatures()
    if ScriptUnloaded then
        return
    end
    ScriptUnloaded = true

    for _, toggle in pairs(self.Toggles) do
        if toggle.Value then
            pcall(function()
                toggle:SetValue(false)
            end)
        end
    end

    for index = #UnloadCallbacks, 1, -1 do
        pcall(UnloadCallbacks[index])
    end
    table.clear(UnloadCallbacks)

    for _, connection in ipairs(ScriptConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(ScriptConnections)
    table.clear(self.Toggles)
    table.clear(self.Options)
    table.clear(self.State)
end

PRIME_TIER = type(_G.PRIME_TIER) == "string" and _G.PRIME_TIER or "Freemium"
IS_PREMIUM_USER = string.lower(PRIME_TIER) == "premium"

-- Freemium cycle for No Ability Cooldown:
-- 1 hour available -> 4 hours locked -> repeat.
NO_COOLDOWN_FREEMIUM_ACCESS_DURATION = 60 * 60
NO_COOLDOWN_FREEMIUM_LOCK_DURATION = 4 * 60 * 60
NO_COOLDOWN_FREEMIUM_CYCLE_DURATION =
    NO_COOLDOWN_FREEMIUM_ACCESS_DURATION + NO_COOLDOWN_FREEMIUM_LOCK_DURATION

NoCooldownFreemiumCycleStart = nil

if not IS_PREMIUM_USER then
    local env = getgenv and getgenv() or _G
    local existingCycleStart = tonumber(env.PRIME_NO_COOLDOWN_FREEMIUM_CYCLE_START)

    -- Compatibility with the previous 1-hour-only version:
    -- preserve the already-started access window when possible.
    if not existingCycleStart then
        local oldExpiry = tonumber(env.PRIME_NO_COOLDOWN_FREEMIUM_EXPIRES_AT)
        if oldExpiry then
            existingCycleStart = oldExpiry - NO_COOLDOWN_FREEMIUM_ACCESS_DURATION
        else
            existingCycleStart = os.time()
        end
        env.PRIME_NO_COOLDOWN_FREEMIUM_CYCLE_START = existingCycleStart
    end

    env.PRIME_NO_COOLDOWN_FREEMIUM_EXPIRES_AT = nil
    _G.PRIME_NO_COOLDOWN_FREEMIUM_EXPIRES_AT = nil
    _G.PRIME_NO_COOLDOWN_FREEMIUM_CYCLE_START = existingCycleStart
    NoCooldownFreemiumCycleStart = existingCycleStart
end

function Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

MAIN_WINDOW_TRANSPARENCY = 0.02
GUI_BUTTON_TRANSPARENCY = 0
GUI_PANEL_TRANSPARENCY = 0.04
GUI_OVERLAY_TRANSPARENCY = 0.02
GUI_DISABLED_TRANSPARENCY = 0.72

local themes = {
    Purple = {{159,122,255},{15,13,24},{22,18,34},{29,25,43},{39,33,56},{76,65,99},{245,241,255},{177,166,199},{20,13,34}},
    Light = {{104,66,204},{241,243,249},{255,255,255},{255,255,255},{230,233,242},{173,180,198},{29,34,49},{87,96,119},{255,255,255}},
    Blue = {{92,190,255},{10,19,30},{13,26,41},{18,34,51},{26,46,67},{57,89,118},{235,247,255},{151,183,208},{7,23,36}},
    Mint = {{89,220,177},{10,23,21},{14,31,28},{20,39,34},{28,52,45},{57,94,80},{232,252,243},{153,192,177},{8,28,21}},
    Rose = {{255,135,176},{26,14,22},{36,19,30},{45,26,38},{60,35,50},{103,63,84},{255,239,247},{205,164,185},{38,12,25}},
    Midnight = {{155,174,255},{10,13,21},{15,19,30},{22,27,40},{31,38,54},{65,76,101},{239,244,255},{159,172,199},{15,20,38}}
}
local bindings = setmetatable({}, {__mode = "k"})
local colorRoles = {}
NexusUI.ThemeName = "Purple"
NexusUI.ThemeRefresh = {}
local function setPalette(name)
    local t = themes[name]
    local colors = {}
    for i,v in ipairs(t) do colors[i] = Color3.fromRGB(v[1],v[2],v[3]) end
    ACCENT,COLOR_WINDOW,COLOR_TOPBAR,COLOR_GROUP,COLOR_CONTROL,COLOR_BORDER,COLOR_TEXT,COLOR_TEXT_DIM,COLOR_ON_ACCENT = unpack(colors)
    NexusUI.Palette = colors
    table.clear(colorRoles)
    for i,v in ipairs(colors) do if not colorRoles[v] then colorRoles[v] = i end end
end
setPalette("Purple")
function NexusUI:ResolveColor(v)
    return self.Palette[colorRoles[v]] or v
end
function NexusUI:BindColor(o,k,f)
    local b = bindings[o]
    if not b then
        b = {}
        bindings[o] = b
        TrackGuiConnection(o.Destroying:Connect(function() bindings[o] = nil end))
    end
    b[k] = f
    o[k] = f()
end
function NexusUI:SetTheme(name)
    if not themes[name] then return false end
    self.ThemeName = name
    setPalette(name)
    for o,b in pairs(bindings) do
        for k,f in pairs(b) do o[k] = f() end
    end
    for _,f in ipairs(self.ThemeRefresh) do f() end
    return true
end
RegisterUnloadCallback(function()
    table.clear(bindings)
    table.clear(NexusUI.ThemeRefresh)
end)

function ApplyButtonStyle(button)
    if not button then return end
    if button:IsA("TextButton") then
        button.AutoButtonColor = false
        button.SelectionImageObject = nil
    end
    if button:IsA("GuiObject") then
        button.Active = true
    end
end


function CreateClickButton(parent, text, size, position, bgColor, textColor, font, textSize, disableHover)
    local bgRole = colorRoles[bgColor] or 5
    local textRole = colorRoles[textColor] or 7
    local button = Instance.new("Frame")
    button.Size = size
    button.Position = position
    NexusUI:BindColor(button, "BackgroundColor3", function() return NexusUI.Palette[bgRole] end)
    button.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
    button.BorderSizePixel = 0
    button.Active = true
    button.ClipsDescendants = true
    button.ZIndex = 10
    button.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    NexusUI:BindColor(label, "TextColor3", function() return NexusUI.Palette[textRole] end)
    if typeof(font) == "EnumItem" then
        label.Font = font
    else
        label.Font = Enum.Font.GothamSemibold
    end
    label.TextSize = textSize or 14
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 11
    label.Parent = button

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    local defaultBackground = button.BackgroundColor3
    local hoverBackground = defaultBackground:Lerp(ACCENT, 0.12)
    local pressedBackground = defaultBackground:Lerp(ACCENT, 0.22)
    table.insert(NexusUI.ThemeRefresh, function()
        if not button.Parent then return end
        defaultBackground = NexusUI.Palette[bgRole]
        hoverBackground = defaultBackground:Lerp(ACCENT, 0.12)
        pressedBackground = defaultBackground:Lerp(ACCENT, 0.22)
    end)
    local hovered = false
    local pressed = false

    local function tweenBackground(color)
        if button and button.Parent then
            TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = color}):Play()
        end
    end

    if not disableHover then
        TrackGuiConnection(button.MouseEnter:Connect(function()
            hovered = true
            if not pressed then
                tweenBackground(hoverBackground)
            end
        end))

        TrackGuiConnection(button.MouseLeave:Connect(function()
            hovered = false
            if not pressed then
                tweenBackground(defaultBackground)
            end
        end))

        TrackGuiConnection(button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                pressed = true
                tweenBackground(pressedBackground)
            end
        end))

        TrackGuiConnection(button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                pressed = false
                tweenBackground(hovered and hoverBackground or defaultBackground)
            end
        end))
    end

    return button, label
end

function ConnectClick(button, callback)
    if not button then return end
    local pressed = false

    local function isClickInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    local beganConn = button.InputBegan:Connect(function(input)
        if isClickInput(input) then
            pressed = true
        end
    end)

    local endedConn = button.InputEnded:Connect(function(input)
        if isClickInput(input) and pressed then
            pressed = false
            if callback then
                callback()
            end
        end
    end)

    if beganConn then
        table.insert(GuiConnections, beganConn)
    end
    if endedConn then
        table.insert(GuiConnections, endedConn)
    end
end

function NexusUI:CreateWindow(options)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusBasketballZeroUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = GuiParent

    local isVisibleByDefault = options == nil or options.visible ~= false
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = options and options.Size or UDim2.fromOffset(620, 370)
    mainFrame.Position = options and options.Position or UDim2.fromOffset(40, 40)
    mainFrame.Visible = isVisibleByDefault
    NexusUI:BindColor(mainFrame, "BackgroundColor3", function() return COLOR_WINDOW end)
    mainFrame.BackgroundTransparency = MAIN_WINDOW_TRANSPARENCY
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui
    local fit = Instance.new("UIScale")
    fit.Name = "NexusWindowScale"
    local targetScale = 1
    fit.Parent = mainFrame
    local cameraConnection
    local function fitWindow()
        local c = Workspace.CurrentCamera
        if not c then return end
        local v = c.ViewportSize
        mainFrame.Size = v.X < 600 and UDim2.fromOffset(math.min(410, v.X - 24), math.min(540, v.Y - 64)) or (options and options.Size or UDim2.fromOffset(720, 460))
        targetScale = math.min(1, math.max(0.1, (v.X - 24) / mainFrame.Size.X.Offset), math.max(0.1, (v.Y - 64) / mainFrame.Size.Y.Offset))
        fit.Scale = targetScale
        local pos = mainFrame.Position
        mainFrame.Position = UDim2.fromOffset(math.clamp(pos.X.Offset, 8, math.max(8, v.X - mainFrame.Size.X.Offset * fit.Scale - 8)), math.clamp(pos.Y.Offset, 8, math.max(8, v.Y - mainFrame.Size.Y.Offset * fit.Scale - 48)))
    end
    local function bindCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        if Workspace.CurrentCamera then cameraConnection = TrackGuiConnection(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitWindow)) end
        fitWindow()
    end
    TrackGuiConnection(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))
    bindCamera()


    local mainCorner = Instance.new("UICorner")
    mainCorner.Name = "NexusMainCorner"
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Name = "NexusMainStroke"
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    NexusUI:BindColor(mainStroke, "Color", function() return COLOR_BORDER end)
    mainStroke.Transparency = 0.15
    mainStroke.Thickness = 1
    mainStroke.LineJoinMode = Enum.LineJoinMode.Round
    mainStroke.Parent = mainFrame

    local innerClip = Instance.new("Frame")
    innerClip.Name = "InnerClip"
    innerClip.Size = UDim2.new(1, 0, 1, 0)
    NexusUI:BindColor(innerClip, "BackgroundColor3", function() return COLOR_WINDOW end)
    innerClip.BackgroundTransparency = MAIN_WINDOW_TRANSPARENCY
    innerClip.BorderSizePixel = 0
    innerClip.ClipsDescendants = true
    innerClip.Parent = mainFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 14)
    innerCorner.Parent = innerClip

    local animationDuration = 0.18
    local function animateWindowIn()
        if not mainFrame or not mainFrame.Parent then return end
        if not mainFrame:FindFirstChild("NexusWindowScale") then
            local windowScale = Instance.new("UIScale")
            windowScale.Name = "NexusWindowScale"
            windowScale.Scale = 0.96 * targetScale
            windowScale.Parent = mainFrame
        end

        local windowScale = mainFrame:FindFirstChild("NexusWindowScale")
        if windowScale then
            windowScale.Scale = 0.96 * targetScale
            TweenService:Create(windowScale, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
        end
        TweenService:Create(mainFrame, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = MAIN_WINDOW_TRANSPARENCY}):Play()
    end

    local function animateWindowOut(callback)
        if not mainFrame or not mainFrame.Parent then
            if callback then callback() end
            return
        end
        if not mainFrame:FindFirstChild("NexusWindowScale") then
            local windowScale = Instance.new("UIScale")
            windowScale.Name = "NexusWindowScale"
            windowScale.Scale = targetScale
            windowScale.Parent = mainFrame
        end

        local windowScale = mainFrame:FindFirstChild("NexusWindowScale")
        if windowScale then
            TweenService:Create(windowScale, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.96 * targetScale}):Play()
        end
        TweenService:Create(mainFrame, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = MAIN_WINDOW_TRANSPARENCY}):Play()
        task.delay(animationDuration, function()
            if callback then callback() end
        end)
    end

    local topBarHeight = 36
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, topBarHeight)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    NexusUI:BindColor(topBar, "BackgroundColor3", function() return COLOR_TOPBAR end)
    topBar.BackgroundTransparency = GUI_OVERLAY_TRANSPARENCY
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 2
    topBar.Active = true
    topBar.Parent = innerClip

    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 14)
    topBarCorner.Parent = topBar

    local topBarPatch = Instance.new("Frame")
    topBarPatch.Size = UDim2.new(1, 0, 0, 14)
    topBarPatch.Position = UDim2.new(0, 0, 1, -14)
    NexusUI:BindColor(topBarPatch, "BackgroundColor3", function() return COLOR_TOPBAR end)
    topBarPatch.BackgroundTransparency = GUI_OVERLAY_TRANSPARENCY
    topBarPatch.BorderSizePixel = 0
    topBarPatch.ZIndex = 2
    topBarPatch.Parent = topBar

    local topBarDivider = Instance.new("Frame")
    topBarDivider.Size = UDim2.new(1, 0, 0, 1)
    topBarDivider.Position = UDim2.new(0, 0, 1, -1)
    NexusUI:BindColor(topBarDivider, "BackgroundColor3", function() return COLOR_BORDER end)
    topBarDivider.BackgroundTransparency = 0.4
    topBarDivider.BorderSizePixel = 0
    topBarDivider.ZIndex = 3
    topBarDivider.Parent = topBar

    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(0, 0, 1, 0)
    logoContainer.AutomaticSize = Enum.AutomaticSize.X
    logoContainer.Position = UDim2.new(0, 14, 0, 0)
    logoContainer.BackgroundTransparency = 1
    logoContainer.ZIndex = 3
    logoContainer.Parent = topBar

    local logoLayout = Instance.new("UIListLayout")
    logoLayout.FillDirection = Enum.FillDirection.Horizontal
    logoLayout.Padding = UDim.new(0, 8)
    logoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    logoLayout.Parent = logoContainer

    local logoLabel = Instance.new("TextLabel")
    logoLabel.Name = "PrimeLogo"
    logoLabel.Size = UDim2.new(0, 0, 0, 20)
    logoLabel.AutomaticSize = Enum.AutomaticSize.X
    logoLabel.LayoutOrder = 1
    logoLabel.BackgroundTransparency = 1
    logoLabel.Text = (options and options.Title or "PRIME")
    NexusUI:BindColor(logoLabel, "TextColor3", function() return COLOR_TEXT end)
    logoLabel.TextXAlignment = Enum.TextXAlignment.Left
    logoLabel.TextYAlignment = Enum.TextYAlignment.Center
    logoLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    logoLabel.TextSize = 16
    logoLabel.ZIndex = 3
    logoLabel.Parent = logoContainer

    local logoGradient = Instance.new("UIGradient")
    logoGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
    logoGradient.Rotation = 0
    logoGradient.Offset = Vector2.new(-1, 0)
    logoGradient.Parent = logoLabel

    task.spawn(function()
        while logoGradient and logoGradient.Parent and not ScriptUnloaded do
            logoGradient.Offset = Vector2.new(-1, 0)
            local tween = TweenService:Create(
                logoGradient,
                TweenInfo.new(2.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                {Offset = Vector2.new(1, 0)}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end)

    local logoSubtitle = Instance.new("TextLabel")
    logoSubtitle.Name = "PrimeSubtitle"
    logoSubtitle.Size = UDim2.new(0, 0, 0, 18)
    logoSubtitle.AutomaticSize = Enum.AutomaticSize.X
    logoSubtitle.LayoutOrder = 2
    logoSubtitle.BackgroundTransparency = 1

    local isPremiumUser = IS_PREMIUM_USER

    logoSubtitle.Text = isPremiumUser and "Premium" or "Freemium"
    NexusUI:BindColor(logoSubtitle, "TextColor3", function() return COLOR_TEXT end)
    logoSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    logoSubtitle.TextYAlignment = Enum.TextYAlignment.Center

    logoSubtitle.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", isPremiumUser and Enum.FontWeight.Bold or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    logoSubtitle.TextSize = 15
    logoSubtitle.ZIndex = 3
    logoSubtitle.Parent = logoContainer

    local subtitleGradient = Instance.new("UIGradient")
    if isPremiumUser then
        subtitleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 90)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(190, 145, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 240, 150)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(190, 145, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 90)),
        })
    else
        subtitleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 150, 75)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(8, 55, 22)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45, 150, 75)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(8, 55, 22)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 150, 75)),
        })
    end
    subtitleGradient.Rotation = 0
    subtitleGradient.Offset = Vector2.new(-1, 0)
    subtitleGradient.Enabled = false
    subtitleGradient.Parent = logoSubtitle

    task.spawn(function()
        local sweepDuration = isPremiumUser and 2.2 or 3.8
        local sweepStyle = isPremiumUser and Enum.EasingStyle.Linear or Enum.EasingStyle.Sine
        while subtitleGradient and subtitleGradient.Parent and not ScriptUnloaded do
            subtitleGradient.Offset = Vector2.new(-1, 0)
            local tween = TweenService:Create(
                subtitleGradient,
                TweenInfo.new(sweepDuration, sweepStyle, Enum.EasingDirection.InOut),
                {Offset = Vector2.new(1, 0)}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end)

    local tabStrip = Instance.new("ScrollingFrame")
    tabStrip.Name = "TabStrip"
    tabStrip.Size = UDim2.new(1, -100, 1, 0)
    tabStrip.Position = UDim2.new(0, 90, 0, 0)
    tabStrip.BackgroundTransparency = 1
    tabStrip.ClipsDescendants = true
    tabStrip.ZIndex = 3
    tabStrip.Active = true
    tabStrip.Parent = topBar

    do
        tabStrip.BorderSizePixel = 0
        tabStrip.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabStrip.AutomaticCanvasSize = Enum.AutomaticSize.X
        tabStrip.ScrollingDirection = Enum.ScrollingDirection.X
        tabStrip.ScrollingEnabled = true
        tabStrip.ScrollBarThickness = 2
        NexusUI:BindColor(tabStrip, "ScrollBarImageColor3", function() return COLOR_BORDER end)
        tabStrip.ScrollBarImageTransparency = 0.2
        tabStrip.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable

        local function updateMobileTabStripBounds()
            if not tabStrip or not tabStrip.Parent then return end
            local measuredLogoWidth = math.floor(logoContainer.AbsoluteSize.X / math.max(fit.Scale, 0.1) + 0.5)
            local leftInset = math.max(138, measuredLogoWidth + 26)
            local rightInset = 8
            tabStrip.Position = UDim2.new(0, leftInset, 0, 0)
            tabStrip.Size = UDim2.new(1, -(leftInset + rightInset), 1, 0)
        end

        TrackGuiConnection(logoContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateMobileTabStripBounds))
        task.defer(updateMobileTabStripBounds)
    end

    local tabStripLayout = Instance.new("UIListLayout")
    tabStripLayout.FillDirection = Enum.FillDirection.Horizontal
    tabStripLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabStripLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabStripLayout.Padding = UDim.new(0, 2)
    tabStripLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabStripLayout.Parent = tabStrip

    local mobileTabHintHeight = IS_MOBILE and 14 or 0
    if IS_MOBILE then
        local tabSwipeHint = Instance.new("TextLabel")
        tabSwipeHint.Name = "TabSwipeHint"
        tabSwipeHint.Size = UDim2.new(1, -16, 0, mobileTabHintHeight)
        tabSwipeHint.Position = UDim2.new(0, 8, 0, topBarHeight)
        tabSwipeHint.BackgroundTransparency = 1
        tabSwipeHint.Text = "Swipe tabs left / right  ↔"
        NexusUI:BindColor(tabSwipeHint, "TextColor3", function() return COLOR_TEXT_DIM end)
        tabSwipeHint.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        tabSwipeHint.TextSize = 9
        tabSwipeHint.TextXAlignment = Enum.TextXAlignment.Right
        tabSwipeHint.TextYAlignment = Enum.TextYAlignment.Center
        tabSwipeHint.ZIndex = 4
        tabSwipeHint.Parent = innerClip
    end

    local window = {}
    local restoreGui
    local connections = {}
    local function track(conn)
        if conn then
            table.insert(connections, conn)
        end
        return conn
    end

    local function createRestoreGui()
        if not SHOW_RESTORE_BUTTON then
            return nil
        end

        if restoreGui then
            return restoreGui
        end

        restoreGui = Instance.new("ScreenGui")
        restoreGui.Name = "NexusBasketballZeroUI_Restore"
        restoreGui.ResetOnSpawn = false
        restoreGui.IgnoreGuiInset = true
        restoreGui.Enabled = false
        restoreGui.Parent = GuiParent

        local restoreFrame = Instance.new("Frame")
        restoreFrame.Size = UDim2.fromOffset(40, 40)
        restoreFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        restoreFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        NexusUI:BindColor(restoreFrame, "BackgroundColor3", function() return COLOR_WINDOW end)
        restoreFrame.BorderSizePixel = 0
        restoreFrame.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
        restoreFrame.Parent = restoreGui
        restoreFrame.Active = true

        local restoreButton, restoreLabel = CreateClickButton(
            restoreFrame,
            "N",
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            COLOR_WINDOW,
            ACCENT,
            Enum.Font.GothamBold,
            20
        )
        restoreButton.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
        NexusUI:BindColor(restoreLabel, "TextColor3", function() return ACCENT end)
        ApplyButtonStyle(restoreButton)
        local restoreCorner = Instance.new("UICorner")
        restoreCorner.CornerRadius = UDim.new(0, 6)
        restoreCorner.Parent = restoreButton
        local restoreStroke = Instance.new("UIStroke")
        restoreStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        NexusUI:BindColor(restoreStroke, "Color", function() return COLOR_BORDER end)
        restoreStroke.Transparency = 0.3
        restoreStroke.Thickness = 1
        restoreStroke.Parent = restoreButton
        local restoreDragging = false
        local restoreDragMoved = false
        local restoreStartPos = nil
        local restoreStartInputPos = nil
        local restoreInputType = nil
        local restoreDragThreshold = 8

        local function beginRestoreInteraction(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                restoreDragging = true
                restoreDragMoved = false
                restoreStartPos = restoreFrame.Position
                restoreStartInputPos = input.Position
                restoreInputType = input.UserInputType
            end
        end

        local function updateRestoreInteraction(input)
            if not restoreDragging or not restoreStartPos or not restoreStartInputPos then
                return
            end

            local isMouseDrag = restoreInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
            local isTouchDrag = restoreInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch
            if not isMouseDrag and not isTouchDrag then
                return
            end

            local delta = input.Position - restoreStartInputPos
            if math.abs(delta.X) > restoreDragThreshold or math.abs(delta.Y) > restoreDragThreshold then
                restoreDragMoved = true
            end

            restoreFrame.Position = UDim2.new(
                restoreStartPos.X.Scale,
                restoreStartPos.X.Offset + delta.X,
                restoreStartPos.Y.Scale,
                restoreStartPos.Y.Offset + delta.Y
            )
        end

        local function endRestoreInteraction(input)
            if not restoreDragging then
                return
            end
            if input.UserInputType ~= restoreInputType then
                return
            end

            local shouldOpen = not restoreDragMoved
            restoreDragging = false
            restoreDragMoved = false
            restoreStartPos = nil
            restoreStartInputPos = nil
            restoreInputType = nil

            if shouldOpen then
                window:SetVisible(true)
            end
        end

        track(restoreFrame.InputBegan:Connect(beginRestoreInteraction))
        track(restoreButton.InputBegan:Connect(beginRestoreInteraction))
        track(userInputService.InputChanged:Connect(updateRestoreInteraction))
        track(userInputService.InputEnded:Connect(endRestoreInteraction))

        return restoreGui
    end

    local closeConfirmGui
    local setVisible
    local destroyWindow

    local function destroyCloseConfirm()
        if closeConfirmGui then
            closeConfirmGui:Destroy()
            closeConfirmGui = nil
        end
    end

    local function createCloseConfirm()
        if closeConfirmGui then
            return closeConfirmGui
        end

        destroyCloseConfirm()

        closeConfirmGui = Instance.new("Frame")
        closeConfirmGui.Name = "NexusBasketballZeroUI_CloseConfirm"
        closeConfirmGui.Size = UDim2.new(0, 360, 0, 190)
        closeConfirmGui.AnchorPoint = Vector2.new(0.5, 0.5)
        closeConfirmGui.Position = UDim2.new(0.5, 0, 0.5, 0)
        closeConfirmGui.BackgroundTransparency = 1
        closeConfirmGui.BorderSizePixel = 0
        closeConfirmGui.ZIndex = 50
        closeConfirmGui.Parent = mainFrame

        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(1, 0, 1, 0)
        dialog.Position = UDim2.new(0, 0, 0, 0)
        NexusUI:BindColor(dialog, "BackgroundColor3", function() return COLOR_WINDOW end)
        dialog.BorderSizePixel = 0
        dialog.BackgroundTransparency = GUI_OVERLAY_TRANSPARENCY
        dialog.ClipsDescendants = true
        dialog.ZIndex = 51
        dialog.Parent = closeConfirmGui

        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 6)
        dialogCorner.Parent = dialog

        local dialogStroke = Instance.new("UIStroke")
        dialogStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        NexusUI:BindColor(dialogStroke, "Color", function() return COLOR_BORDER end)
        dialogStroke.Transparency = 0.4
        dialogStroke.Thickness = 1
        dialogStroke.Parent = dialog

        local dialogTop = Instance.new("Frame")
        dialogTop.Size = UDim2.new(1, 0, 0, 40)
        dialogTop.Position = UDim2.new(0, 0, 0, 0)
        NexusUI:BindColor(dialogTop, "BackgroundColor3", function() return COLOR_TOPBAR end)
        dialogTop.BorderSizePixel = 0
        dialogTop.BackgroundTransparency = GUI_OVERLAY_TRANSPARENCY
        dialogTop.ZIndex = 52
        dialogTop.Parent = dialog

        local dialogTopCorner = Instance.new("UICorner")
        dialogTopCorner.CornerRadius = UDim.new(0, 6)
        dialogTopCorner.Parent = dialogTop

        local dialogTopPatch = Instance.new("Frame")
        dialogTopPatch.Size = UDim2.new(1, 0, 0, 6)
        dialogTopPatch.Position = UDim2.new(0, 0, 1, -6)
        NexusUI:BindColor(dialogTopPatch, "BackgroundColor3", function() return COLOR_TOPBAR end)
        dialogTopPatch.BackgroundTransparency = GUI_OVERLAY_TRANSPARENCY
        dialogTopPatch.BorderSizePixel = 0
        dialogTopPatch.ZIndex = 52
        dialogTopPatch.Parent = dialogTop

        local dialogTitle = Instance.new("TextLabel")
        dialogTitle.Size = UDim2.new(1, -24, 0, 26)
        dialogTitle.Position = UDim2.new(0, 0, 0, 7)
        dialogTitle.BackgroundTransparency = 1
        dialogTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        dialogTitle.TextSize = 17
        dialogTitle.Text = "Confirm Close"
        NexusUI:BindColor(dialogTitle, "TextColor3", function() return COLOR_TEXT end)
        dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
        dialogTitle.TextYAlignment = Enum.TextYAlignment.Center
        dialogTitle.ZIndex = 53
        dialogTitle.Parent = dialogTop

        local dialogText = Instance.new("TextLabel")
        dialogText.Size = UDim2.new(1, -24, 0, 48)
        dialogText.Position = UDim2.new(0, 12, 0, 52)
        dialogText.BackgroundTransparency = 1
        dialogText.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        dialogText.TextSize = 14
        dialogText.Text = "Press 'Hide' to minimize the UI, or 'Close' to remove it completely."
        NexusUI:BindColor(dialogText, "TextColor3", function() return COLOR_TEXT end)
        dialogText.TextWrapped = true
        dialogText.TextXAlignment = Enum.TextXAlignment.Left
        dialogText.TextYAlignment = Enum.TextYAlignment.Top
        dialogText.ZIndex = 53
        dialogText.Parent = dialog

        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -24, 0, 36)
        buttonContainer.Position = UDim2.new(0, 12, 1, -48)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.ZIndex = 53
        buttonContainer.Parent = dialog

        local buttonLayout = Instance.new("UIListLayout")
        buttonLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        buttonLayout.Padding = UDim.new(0, 10)
        buttonLayout.Parent = buttonContainer

        local hideButton, hideLabel = CreateClickButton(
            buttonContainer,
            "Hide",
            UDim2.new(0, 150, 1, 0),
            UDim2.new(0, 0, 0, 0),
            COLOR_CONTROL,
            COLOR_TEXT,
            Enum.Font.GothamSemibold,
            15,
            true
        )
        hideButton.BackgroundTransparency = 1
        if hideLabel then
            hideLabel.Text = "Hide"
            hideLabel.TextTransparency = 0
            hideLabel.ZIndex = 55
        end
        ApplyButtonStyle(hideButton)
        hideButton.ZIndex = 54

        local closeConfirmButton, closeConfirmLabel = CreateClickButton(
            buttonContainer,
            "Close",
            UDim2.new(0, 150, 1, 0),
            UDim2.new(0, 0, 0, 0),
            ACCENT,
            COLOR_WINDOW,
            Enum.Font.GothamSemibold,
            15,
            true
        )
        closeConfirmButton.BackgroundTransparency = 1
        if closeConfirmLabel then
            closeConfirmLabel.Text = "Close"
            NexusUI:BindColor(closeConfirmLabel, "TextColor3", function() return COLOR_TEXT end)
            closeConfirmLabel.TextTransparency = 0
            closeConfirmLabel.ZIndex = 55
        end
        ApplyButtonStyle(closeConfirmButton)
        closeConfirmButton.ZIndex = 54

        ConnectClick(hideButton, function()
            destroyCloseConfirm()
            setVisible(false)
        end)

        ConnectClick(closeConfirmButton, function()
            if destroyWindow then
                destroyWindow()
            end
        end)

        return closeConfirmGui
    end

    setVisible = function(visible)
        if visible then
            mainFrame.Visible = true
            animateWindowIn()
            if restoreGui then
                restoreGui.Enabled = false
            end
        else
            animateWindowOut(function()
                if mainFrame then
                    mainFrame.Visible = false
                end
            end)
            local mobileButtonGui = createRestoreGui()
            if mobileButtonGui then
                mobileButtonGui.Enabled = true
            end
        end
    end

    local isCollapsed = false

    local function setCollapsed(value)
        isCollapsed = value
        mainFrame.Visible = not value
    end

    local dragHandle = topBar


    local dragging = false
    local dragStartPos = nil
    local dragStartMousePos = nil

    local function isInputInside(guiObject, inputPosition)
        if not guiObject or not guiObject.Parent then return false end
        local pos = guiObject.AbsolutePosition
        local size = guiObject.AbsoluteSize
        local x = inputPosition.X
        local y = inputPosition.Y
        return x >= pos.X and x <= (pos.X + size.X) and y >= pos.Y and y <= (pos.Y + size.Y)
    end

    track(dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- On phones the top tabs must keep the touch gesture for horizontal scrolling.
            if IS_MOBILE and isInputInside(tabStrip, input.Position) then
                return
            end
            dragging = true
            dragStartPos = mainFrame.Position
            dragStartMousePos = input.Position
        end
    end))

    track(dragHandle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if dragStartPos and dragStartMousePos then
                local delta = input.Position - dragStartMousePos
                mainFrame.Position = UDim2.new(
                    dragStartPos.X.Scale,
                    dragStartPos.X.Offset + delta.X,
                    dragStartPos.Y.Scale,
                    dragStartPos.Y.Offset + delta.Y
                )
            end
        end
    end))

    track(userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 1, -(topBarHeight + 42 + mobileTabHintHeight))
    content.Position = UDim2.new(0, 8, 0, topBarHeight + 6 + mobileTabHintHeight)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = innerClip

    local cornerButtons = Instance.new("Frame")
    cornerButtons.Name = "CornerButtons"
    cornerButtons.Size = UDim2.new(0, 92, 0, 28)
    cornerButtons.Position = UDim2.new(1, -104, 1, -36)
    cornerButtons.BackgroundTransparency = 1
    cornerButtons.ZIndex = 5
    cornerButtons.Parent = innerClip

    local cornerButtonsLayout = Instance.new("UIListLayout")
    cornerButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    cornerButtonsLayout.Padding = UDim.new(0, 8)
    cornerButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cornerButtonsLayout.Parent = cornerButtons

    local function createCornerButton(text, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 42, 0, 28)
        NexusUI:BindColor(btn, "BackgroundColor3", function() return COLOR_CONTROL end)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = text
        NexusUI:BindColor(btn, "TextColor3", function() return COLOR_TEXT end)
        btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        btn.TextSize = 16
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.ZIndex = 5
        btn.Parent = cornerButtons

        TrackGuiConnection(btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextColor3 = COLOR_TEXT}):Play()
        end))
        TrackGuiConnection(btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextColor3 = COLOR_TEXT}):Play()
        end))
        return btn
    end

    local HIDE_GUI_SYMBOL = "―"
    local CLOSE_GUI_SYMBOL = "X"

    local hideCornerButton = createCornerButton(HIDE_GUI_SYMBOL, 1)
    ConnectClick(hideCornerButton, function()
        setVisible(false)
    end)

    local closeCornerButton = createCornerButton(CLOSE_GUI_SYMBOL, 2)
    ConnectClick(closeCornerButton, function()
        createCloseConfirm()
    end)

    local tabs = {}
    local currentTab = nil

    local function selectTab(index)
        local tabEntry = tabs[index]
        if not tabEntry then return end
        for i, tab in ipairs(tabs) do
            local selected = (i == index)
            tab.page.Visible = selected
            if tab.underline then
                tab.underline.Visible = selected
            end
            if tab.label then
                NexusUI:BindColor(tab.label, "TextColor3", function() return selected and ACCENT or COLOR_TEXT_DIM end)
            end
        end
        currentTab = tabEntry
    end

    local toggleKey = options and options.MinimizeKey or Enum.KeyCode.LeftAlt
    local toggleKeyName = "LeftAlt"

    local function updateToggleKeyDisplay()
        if toggleKey and toggleKey.Name then
            toggleKeyName = toggleKey.Name
        end
    end

    updateToggleKeyDisplay()

    function window:SetToggleKey(key)
        toggleKey = key or Enum.KeyCode.LeftAlt
        updateToggleKeyDisplay()
    end

    function window:GetToggleKey()
        return toggleKey
    end

    function window:AddTab(tabData)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 0, 1, -8)
        tabButton.AutomaticSize = Enum.AutomaticSize.X
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabData and tabData.Title or "Tab"
        NexusUI:BindColor(tabButton, "TextColor3", function() return COLOR_TEXT_DIM end)
        tabButton.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        tabButton.TextSize = 13
        tabButton.AutoButtonColor = false
        tabButton.LayoutOrder = #tabs + 1
        tabButton.ZIndex = 4
        tabButton.Parent = tabStrip

        local tabButtonPadding = Instance.new("UIPadding")
        tabButtonPadding.PaddingLeft = UDim.new(0, 7)
        tabButtonPadding.PaddingRight = UDim.new(0, 7)
        tabButtonPadding.Parent = tabButton

        local tabLabel = tabButton

        local tabUnderline = Instance.new("Frame")
        tabUnderline.Size = UDim2.new(1, -8, 0, 2)
        tabUnderline.Position = UDim2.new(0, 4, 1, 3)
        NexusUI:BindColor(tabUnderline, "BackgroundColor3", function() return ACCENT end)
        tabUnderline.BorderSizePixel = 0
        tabUnderline.Visible = false
        tabUnderline.ZIndex = 4
        tabUnderline.Parent = tabButton

        local tabShimmer = Instance.new("UIGradient")
        tabShimmer.Color = ColorSequence.new(Color3.new(1, 1, 1))
        tabShimmer.Rotation = 0
        tabShimmer.Offset = Vector2.new(-1, 0)
        tabShimmer.Enabled = false
        tabShimmer.Parent = tabButton

        local tabHovering = false

        TrackGuiConnection(tabButton.MouseEnter:Connect(function()
            if not tabUnderline.Visible then
                NexusUI:BindColor(tabButton, "TextColor3", function() return COLOR_TEXT end)
            end
            tabHovering = true
            tabShimmer.Enabled = true
            task.spawn(function()
                while tabHovering and tabShimmer.Parent and not ScriptUnloaded do
                    tabShimmer.Offset = Vector2.new(-1, 0)
                    local tween = TweenService:Create(
                        tabShimmer,
                        TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                        {Offset = Vector2.new(1, 0)}
                    )
                    tween:Play()
                    tween.Completed:Wait()
                end
            end)
        end))

        TrackGuiConnection(tabButton.MouseLeave:Connect(function()
            if not tabUnderline.Visible then
                NexusUI:BindColor(tabButton, "TextColor3", function() return COLOR_TEXT_DIM end)
            end
            tabHovering = false
            tabShimmer.Enabled = false
        end))

        local tabPage = Instance.new("Frame")
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.Position = UDim2.new(0, 0, 0, 0)
        tabPage.BackgroundTransparency = 1
        tabPage.Visible = false
        tabPage.ClipsDescendants = true
        tabPage.Parent = content

        local function createColumn(position)
            local column = Instance.new("ScrollingFrame")
            column.Size = UDim2.new(0.5, -4, 1, 0)
            column.Position = position
            column.BackgroundTransparency = 1
            column.BorderSizePixel = 0
            column.ScrollBarThickness = 3
            NexusUI:BindColor(column, "ScrollBarImageColor3", function() return COLOR_BORDER end)
            column.AutomaticCanvasSize = Enum.AutomaticSize.Y
            column.CanvasSize = UDim2.new(0, 0, 0, 0)
            column.Parent = tabPage

            local columnLayout = Instance.new("UIListLayout")
            columnLayout.Padding = UDim.new(0, 8)
            columnLayout.SortOrder = Enum.SortOrder.LayoutOrder
            columnLayout.Parent = column

            return column
        end

        local leftColumn = createColumn(UDim2.new(0, 0, 0, 0))
        local rightColumn = createColumn(UDim2.new(0.5, 4, 0, 0))
        local arranging = false
        local function arrangeColumns()
            if arranging then return end
            arranging = true
            local narrow = mainFrame.Size.X.Offset < 540
            leftColumn.Size = UDim2.new(narrow and 1 or 0.5, narrow and 0 or -4, 1, 0)
            rightColumn.Visible = not narrow
            for i,column in ipairs({leftColumn,rightColumn}) do
                for _,o in ipairs(column:GetChildren()) do
                    if o:IsA("GuiObject") then
                        local home = o:GetAttribute("ColumnHome") or i
                        o:SetAttribute("ColumnHome", home)
                        o.Parent = (narrow or home == 1) and leftColumn or rightColumn
                    end
                end
            end
            arranging = false
        end
        TrackGuiConnection(leftColumn.ChildAdded:Connect(arrangeColumns))
        TrackGuiConnection(rightColumn.ChildAdded:Connect(arrangeColumns))
        TrackGuiConnection(mainFrame:GetPropertyChangedSignal("Size"):Connect(arrangeColumns))
        arrangeColumns()


        local tabObject = {}
        local controls = {}
        local sectionCount = 0
        local currentSectionContent = nil
        tabObject.Page = tabPage
        tabObject.Button = tabButton

        function tabObject:AddSection(title)
            sectionCount = sectionCount + 1
            local parentColumn = (sectionCount % 2 == 1) and leftColumn or rightColumn

            local group = Instance.new("Frame")
            group.Size = UDim2.new(1, 0, 0, 0)
            group.AutomaticSize = Enum.AutomaticSize.Y
            NexusUI:BindColor(group, "BackgroundColor3", function() return COLOR_GROUP end)
            group.BackgroundTransparency = GUI_PANEL_TRANSPARENCY
            group.BorderSizePixel = 0
            group.LayoutOrder = sectionCount
            group.Parent = parentColumn

            local groupCorner = Instance.new("UICorner")
            groupCorner.CornerRadius = UDim.new(0, 10)
            groupCorner.Parent = group

            local groupStroke = Instance.new("UIStroke")
            groupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            NexusUI:BindColor(groupStroke, "Color", function() return COLOR_BORDER end)
            groupStroke.Transparency = 0.4
            groupStroke.Thickness = 1
            groupStroke.Parent = group

            local groupLayout = Instance.new("UIListLayout")
            groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
            groupLayout.Parent = group

            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 26)
            header.BackgroundTransparency = 1
            header.Text = ""
            header.AutoButtonColor = false
            header.LayoutOrder = 0
            header.ZIndex = 2
            header.Parent = group

            local headerTitle = Instance.new("TextLabel")
            headerTitle.Size = UDim2.new(1, -40, 1, 0)
            headerTitle.Position = UDim2.new(0, 8, 0, 0)
            headerTitle.BackgroundTransparency = 1
            headerTitle.Text = title
            NexusUI:BindColor(headerTitle, "TextColor3", function() return COLOR_TEXT end)
            headerTitle.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            headerTitle.TextSize = 13
            headerTitle.TextXAlignment = Enum.TextXAlignment.Left
            headerTitle.ZIndex = 2
            headerTitle.Parent = header

            local headerArrow = Instance.new("TextLabel")
            headerArrow.Size = UDim2.new(0, 20, 1, 0)
            headerArrow.Position = UDim2.new(1, -26, 0, 0)
            headerArrow.BackgroundTransparency = 1
            headerArrow.Text = ">"
            headerArrow.Rotation = 90
            NexusUI:BindColor(headerArrow, "TextColor3", function() return COLOR_TEXT end)
            headerArrow.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            headerArrow.TextSize = 15
            headerArrow.ZIndex = 2
            headerArrow.Parent = header

            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.BackgroundTransparency = 1
            sectionContent.LayoutOrder = 1
            sectionContent.Parent = group

            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 2)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Parent = sectionContent

            local contentPadding = Instance.new("UIPadding")
            contentPadding.PaddingLeft = UDim.new(0, 8)
            contentPadding.PaddingRight = UDim.new(0, 8)
            contentPadding.PaddingBottom = UDim.new(0, 8)
            contentPadding.Parent = sectionContent

            local collapsed = false
            ConnectClick(header, function()
                collapsed = not collapsed
                sectionContent.Visible = not collapsed
                local rotation = collapsed and 0 or 90
                TweenService:Create(headerArrow, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Rotation = rotation}):Play()
            end)

            currentSectionContent = sectionContent
            local sectionObject = {Frame = group, Content = sectionContent}
            return sectionObject
        end

        function tabObject:SetActiveSection(sectionObject)
            if sectionObject and sectionObject.Content then
                currentSectionContent = sectionObject.Content
                return true
            end
            return false
        end

        local function getControlParent()
            return currentSectionContent or leftColumn
        end

        function tabObject:AddToggle(id, data)
            local isMobileNoCooldown = IS_MOBILE and id == "NoAbilityCooldown"
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, isMobileNoCooldown and 42 or (IS_MOBILE and 28 or 18))
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Active = true
            toggleFrame.LayoutOrder = #controls + 1
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = getControlParent()

            local checkbox = Instance.new("Frame")
            checkbox.Name = "Checkbox"
            checkbox.Size = IS_MOBILE and UDim2.fromOffset(16, 16) or UDim2.fromOffset(13, 13)
            checkbox.Position = IS_MOBILE and UDim2.new(0, 1, 0.5, -8) or UDim2.new(0, 0, 0.5, -6)
            NexusUI:BindColor(checkbox, "BackgroundColor3", function() return COLOR_GROUP end)
            checkbox.BorderSizePixel = 0
            checkbox.Active = true
            checkbox.Parent = toggleFrame

            local checkboxCorner = Instance.new("UICorner")
            checkboxCorner.CornerRadius = UDim.new(0, 3)
            checkboxCorner.Parent = checkbox

            local checkboxStroke = Instance.new("UIStroke")
            checkboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            NexusUI:BindColor(checkboxStroke, "Color", function() return COLOR_BORDER end)
            checkboxStroke.Transparency = 0.2
            checkboxStroke.Thickness = 1
            checkboxStroke.Parent = checkbox

            local checkMark = Instance.new("TextLabel")
            checkMark.Size = UDim2.new(1, 0, 1, 0)
            checkMark.BackgroundTransparency = 1
            checkMark.Text = "✓"
            NexusUI:BindColor(checkMark, "TextColor3", function() return COLOR_ON_ACCENT end)
            checkMark.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            checkMark.TextSize = 11
            checkMark.Visible = false
            checkMark.ZIndex = 2
            checkMark.Parent = checkbox

            local label = Instance.new("TextLabel")
            label.Size = isMobileNoCooldown
                and UDim2.new(1, -30, 0, 20)
                or UDim2.new(1, IS_MOBILE and -30 or -22, 1, 0)
            label.Position = isMobileNoCooldown
                and UDim2.new(0, 27, 0, 1)
                or UDim2.new(0, IS_MOBILE and 27 or 21, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = data and data.Title or id
            NexusUI:BindColor(label, "TextColor3", function() return COLOR_TEXT end)
            label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.Parent = toggleFrame

            local mobileTimerLabel = nil
            if isMobileNoCooldown then
                mobileTimerLabel = Instance.new("TextLabel")
                mobileTimerLabel.Name = "MobileTimer"
                mobileTimerLabel.Size = UDim2.new(1, -30, 0, 17)
                mobileTimerLabel.Position = UDim2.new(0, 27, 0, 21)
                mobileTimerLabel.BackgroundTransparency = 1
                mobileTimerLabel.Text = ""
                NexusUI:BindColor(mobileTimerLabel, "TextColor3", function() return COLOR_TEXT_DIM end)
                mobileTimerLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                mobileTimerLabel.TextSize = 11
                mobileTimerLabel.TextXAlignment = Enum.TextXAlignment.Left
                mobileTimerLabel.TextYAlignment = Enum.TextYAlignment.Center
                mobileTimerLabel.TextTruncate = Enum.TextTruncate.AtEnd
                mobileTimerLabel.ZIndex = 2
                mobileTimerLabel.Parent = toggleFrame
            end

            local lockedBanner = Instance.new("TextLabel")
            lockedBanner.Name = "LockedBanner"
            lockedBanner.Size = UDim2.new(1, 0, 1, 0)
            lockedBanner.BackgroundTransparency = 1
            lockedBanner.Text = data and data.LockedText or ""
            NexusUI:BindColor(lockedBanner, "TextColor3", function() return COLOR_TEXT_DIM end)
            lockedBanner.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            lockedBanner.TextSize = 12
            lockedBanner.TextXAlignment = Enum.TextXAlignment.Center
            lockedBanner.TextYAlignment = Enum.TextYAlignment.Center
            lockedBanner.TextTruncate = Enum.TextTruncate.AtEnd
            lockedBanner.Visible = false
            lockedBanner.ZIndex = 3
            lockedBanner.Parent = toggleFrame

            local enabled = data and data.Default == true or false
            local locked = false
            local toggleOption = {
                Value = enabled,
                IsToggle = true,
                Locked = false,
                Frame = toggleFrame,
                Label = label,
                MobileTimerLabel = mobileTimerLabel,
                Title = data and data.Title or id
            }

            local function refresh(animated)
                if locked then
                    NexusUI:BindColor(label, "TextColor3", function() return COLOR_TEXT_DIM end)
                    NexusUI:BindColor(checkboxStroke, "Color", function() return COLOR_BORDER end)
                    checkboxStroke.Transparency = 0.5
                    NexusUI:BindColor(checkbox, "BackgroundColor3", function() return COLOR_GROUP end)
                    checkMark.Visible = false
                elseif enabled then
                    NexusUI:BindColor(label, "TextColor3", function() return COLOR_TEXT end)
                    NexusUI:BindColor(checkboxStroke, "Color", function() return ACCENT end)
                    checkboxStroke.Transparency = 0
                    NexusUI:BindColor(checkbox, "BackgroundColor3", function() return ACCENT end)
                    checkMark.Visible = true
                else
                    NexusUI:BindColor(label, "TextColor3", function() return COLOR_TEXT end)
                    NexusUI:BindColor(checkboxStroke, "Color", function() return COLOR_BORDER end)
                    checkboxStroke.Transparency = 0.2
                    NexusUI:BindColor(checkbox, "BackgroundColor3", function() return COLOR_GROUP end)
                    checkMark.Visible = false
                end
                lockedBanner.Visible = locked and lockedBanner.Text ~= ""
                label.Visible = not lockedBanner.Visible
                checkbox.Visible = not lockedBanner.Visible
                if mobileTimerLabel then
                    mobileTimerLabel.Visible = not lockedBanner.Visible
                end
            end
            refresh(false)

            function toggleOption:SetValue(value)
                local newValue = value == true
                if locked and newValue then
                    return false
                end
                if enabled == newValue then
                    return true
                end

                enabled = newValue
                self.Value = enabled
                refresh(true)

                if data and data.Callback then
                    data.Callback(enabled)
                end
                return true
            end

            function toggleOption:SetTitle(text)
                local newTitle = tostring(text or "")
                if newTitle == "" then
                    newTitle = tostring(id)
                end
                self.Title = newTitle

                if mobileTimerLabel then
                    -- Keep the long countdown out of the function-name line on phones.
                    -- Example: "No Ability Cooldown [LOCK 03:59:59]" becomes
                    -- title: "No Ability Cooldown", timer: "LOCK 03:59:59".
                    local baseTitle, timerText = newTitle:match("^(.-)%s*%[(.-)%]%s*$")
                    if baseTitle and timerText then
                        label.Text = baseTitle
                        mobileTimerLabel.Text = timerText
                    else
                        label.Text = newTitle
                        mobileTimerLabel.Text = ""
                    end
                else
                    label.Text = newTitle
                end
            end

            function toggleOption:SetDescription(text)
                local description = tostring(text or "")
                if description ~= "" then
                    label.Text = self.Title or (data and data.Title or id)
                end
            end

            function toggleOption:SetLocked(value)
                local shouldLock = value == true
                if shouldLock and enabled then
                    self:SetValue(false)
                end
                locked = shouldLock
                self.Locked = locked
                refresh(true)
            end

            function toggleOption:SetLockedText(text)
                lockedBanner.Text = tostring(text or "")
                refresh(false)
            end

            function toggleOption:IsLocked()
                return locked
            end

            NexusUI.Options[id] = toggleOption
            NexusUI.Toggles[id] = toggleOption

            if IS_MOBILE then
                -- A full-row TextButton gives Roblox a native touch target and reacts
                -- much more reliably than InputBegan/InputEnded on a Frame.
                local touchHitbox = Instance.new("TextButton")
                touchHitbox.Name = "TouchHitbox"
                touchHitbox.Size = UDim2.fromScale(1, 1)
                touchHitbox.Position = UDim2.fromScale(0, 0)
                touchHitbox.BackgroundTransparency = 1
                touchHitbox.BorderSizePixel = 0
                touchHitbox.Text = ""
                touchHitbox.AutoButtonColor = false
                touchHitbox.Active = true
                touchHitbox.Selectable = true
                touchHitbox.ZIndex = 5
                touchHitbox.Parent = toggleFrame
                TrackGuiConnection(touchHitbox.Activated:Connect(function()
                    toggleOption:SetValue(not enabled)
                end))
            else
                ConnectClick(toggleFrame, function()
                    toggleOption:SetValue(not enabled)
                end)
            end

            table.insert(controls, toggleFrame)
            return toggleFrame
        end

        function tabObject:AddSlider(id, data)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 34)
            frame.BackgroundTransparency = 1
            frame.LayoutOrder = #controls + 1
            frame.BorderSizePixel = 0
            frame.Parent = getControlParent()

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 0, 14)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = data and data.Title or id
            NexusUI:BindColor(label, "TextColor3", function() return COLOR_TEXT end)
            label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 14)
            valueLabel.Position = UDim2.new(1, -50, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(data and data.Default or 0)
            NexusUI:BindColor(valueLabel, "TextColor3", function() return COLOR_TEXT_DIM end)
            valueLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            valueLabel.TextSize = 12
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = frame

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, 0, 0, 4)
            track.Position = UDim2.new(0, 0, 0, 22)
            NexusUI:BindColor(track, "BackgroundColor3", function() return COLOR_CONTROL end)
            track.BorderSizePixel = 0
            track.ZIndex = 5
            track.Active = true
            track.ClipsDescendants = false
            track.Parent = frame

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            NexusUI:BindColor(fill, "BackgroundColor3", function() return ACCENT end)
            fill.BorderSizePixel = 0
            fill.ZIndex = 6
            fill.ClipsDescendants = true
            fill.Parent = track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local knob = Instance.new("Frame")
            knob.Name = "SliderKnob"
            knob.Size = UDim2.fromOffset(8, 8)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            NexusUI:BindColor(knob, "BackgroundColor3", function() return ACCENT end)
            knob.BorderSizePixel = 0
            knob.ZIndex = 8
            knob.Active = true
            knob.Parent = track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local value = data and data.Default or 0
            local step = data and data.Step or 1
            local minValue = data and data.Min or value
            local maxValue = data and data.Max or value
            local rounding = data and data.Rounding or 0

            local function roundValue(v)
                if rounding and rounding > 0 then
                    return tonumber(string.format("%." .. tostring(rounding) .. "f", v))
                end
                return math.floor(v + 0.5)
            end

            local function refresh()
                local clampedValue = Clamp(value, minValue, maxValue)
                value = clampedValue
                local range = maxValue - minValue
                local ratio = range == 0 and 0 or ((value - minValue) / range)
                ratio = Clamp(ratio, 0, 1)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                knob.Position = UDim2.new(ratio, 0, 0.5, 0)
                valueLabel.Text = tostring(roundValue(value))
                NexusUI.Options[id] = {Value = value}
                NexusUI.Options[id .. "Value"] = value
                if data and data.Callback then
                    data.Callback(value)
                end
            end

            local dragging = false

            local function setValueFromPosition(xPosition)
                local trackStart = track.AbsolutePosition.X
                local trackSize = track.AbsoluteSize.X
                local ratio = Clamp((xPosition - trackStart) / math.max(trackSize, 1), 0, 1)
                local range = maxValue - minValue
                value = minValue + (range * ratio)
                if step and step > 0 then
                    value = roundValue(math.floor((value / step) + 0.5) * step)
                end
                refresh()
            end

            local function beginSliderDrag(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setValueFromPosition(input.Position.X)
                end
            end

            table.insert(connections, track.InputBegan:Connect(beginSliderDrag))
            table.insert(connections, knob.InputBegan:Connect(beginSliderDrag))

            table.insert(connections, userInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    setValueFromPosition(input.Position.X)
                end
            end))

            table.insert(connections, userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))

            refresh()
            table.insert(controls, frame)
            return frame
        end

        function tabObject:AddDropdown(id, data)
            local horizontalInset = math.max(0, tonumber(data and data.HorizontalInset) or 8)
            local selectorHeight = math.max(20, tonumber(data and data.SelectorHeight) or 32)
            local listMaxHeight = math.max(90, tonumber(data and data.ListMaxHeight) or 210)
            local optionHeight = math.max(24, tonumber(data and data.OptionHeight) or 32)
            local selectorY = 24
            local closedHeight = selectorY + selectorHeight + 8
            local listY = closedHeight + 4

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, closedHeight)
            NexusUI:BindColor(dropdownFrame, "BackgroundColor3", function() return COLOR_CONTROL end)
            dropdownFrame.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.LayoutOrder = #controls + 1
            dropdownFrame.Parent = getControlParent()

            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 10)
            dropdownCorner.Parent = dropdownFrame

            local dropdownStroke = Instance.new("UIStroke")
            dropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            NexusUI:BindColor(dropdownStroke, "Color", function() return COLOR_BORDER end)
            dropdownStroke.Transparency = 0.4
            dropdownStroke.Thickness = 1
            dropdownStroke.Parent = dropdownFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -16, 0, 14)
            title.Position = UDim2.fromOffset(10, 5)
            title.BackgroundTransparency = 1
            title.Text = data and data.Title or id
            NexusUI:BindColor(title, "TextColor3", function() return COLOR_TEXT end)
            title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            title.TextSize = 12
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = dropdownFrame

            local selector, selectorLabel = CreateClickButton(
                dropdownFrame,
                "Select...",
                UDim2.new(1, -(horizontalInset * 2), 0, selectorHeight),
                UDim2.fromOffset(horizontalInset, selectorY),
                COLOR_CONTROL,
                COLOR_TEXT,
                Enum.Font.GothamSemibold,
                12
            )
            selectorLabel.TextXAlignment = Enum.TextXAlignment.Left
            selectorLabel.TextTruncate = Enum.TextTruncate.AtEnd

            local selectorPadding = Instance.new("UIPadding")
            selectorPadding.PaddingLeft = UDim.new(0, 8)
            selectorPadding.PaddingRight = UDim.new(0, 30)
            selectorPadding.Parent = selectorLabel

            local arrow = Instance.new("TextLabel")
            arrow.BackgroundTransparency = 1
            arrow.Size = UDim2.fromOffset(24, selectorHeight)
            arrow.Position = UDim2.new(1, -28, 0, 0)
            arrow.Text = "⌄"
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 19
            NexusUI:BindColor(arrow, "TextColor3", function() return COLOR_TEXT_DIM end)
            arrow.Parent = selector
            local optionViews, openTween, arrowTween = {}, nil, nil
            local function refreshSelection(value)
                for v, item in pairs(optionViews) do
                    NexusUI:BindColor(item[1], "BackgroundColor3", function() return v == value and COLOR_CONTROL:Lerp(ACCENT, 0.22) or COLOR_CONTROL end)
                    item[2].Text = (v == value and "✓  " or "    ") .. tostring(v)
                    NexusUI:BindColor(item[2], "TextColor3", function() return v == value and COLOR_TEXT or COLOR_TEXT_DIM end)
                end
            end

            local optionsList = Instance.new("ScrollingFrame")
            optionsList.Size = UDim2.new(1, -(horizontalInset * 2), 0, 0)
            optionsList.Position = UDim2.fromOffset(horizontalInset, listY)
            NexusUI:BindColor(optionsList, "BackgroundColor3", function() return COLOR_GROUP end)
            optionsList.BackgroundTransparency = GUI_OVERLAY_TRANSPARENCY
            optionsList.BorderSizePixel = 0
            optionsList.ScrollBarThickness = 2
            NexusUI:BindColor(optionsList, "ScrollBarImageColor3", function() return COLOR_BORDER end)
            optionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
            optionsList.CanvasSize = UDim2.new()
            optionsList.Visible = false
            optionsList.Parent = dropdownFrame

            local optionsCorner = Instance.new("UICorner")
            optionsCorner.CornerRadius = UDim.new(0, 8)
            optionsCorner.Parent = optionsList

            local optionsPadding = Instance.new("UIPadding")
            optionsPadding.PaddingTop = UDim.new(0, 2)
            optionsPadding.PaddingBottom = UDim.new(0, 2)
            optionsPadding.PaddingLeft = UDim.new(0, 2)
            optionsPadding.PaddingRight = UDim.new(0, 2)
            optionsPadding.Parent = optionsList

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Padding = UDim.new(0, 2)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Parent = optionsList

            local dropdown = {
                Value = nil,
                Values = {},
                Opened = false,
            }

            local function connectActivated(guiObject, callback)
                local hitbox = Instance.new("TextButton")
                hitbox.Name = "InputHitbox"
                hitbox.Size = UDim2.fromScale(1, 1)
                hitbox.BackgroundTransparency = 1
                hitbox.BorderSizePixel = 0
                hitbox.Text = ""
                hitbox.AutoButtonColor = false
                hitbox.Active = true
                hitbox.Selectable = true
                hitbox.ZIndex = guiObject.ZIndex + 2
                hitbox.Parent = guiObject
                TrackGuiConnection(hitbox.Activated:Connect(callback))
                return hitbox
            end

            local function updateOpenState(open)
                dropdown.Opened = open == true
                local count = #dropdown.Values
                local listHeight = math.min((count * (optionHeight + 5)) + 6, listMaxHeight)
                optionsList.Visible = dropdown.Opened and count > 0
                optionsList.Size = UDim2.new(1, -(horizontalInset * 2), 0, optionsList.Visible and listHeight or 0)
                if openTween then openTween:Cancel() end
                if arrowTween then arrowTween:Cancel() end
                openTween = TweenService:Create(dropdownFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, optionsList.Visible and (listY + listHeight + 8) or closedHeight)})
                arrowTween = TweenService:Create(arrow, TweenInfo.new(0.16), {Rotation = dropdown.Opened and 180 or 0})
                NexusUI:BindColor(dropdownStroke, "Color", function() return dropdown.Opened and COLOR_TEXT_DIM or COLOR_BORDER end)
                openTween:Play()
                arrowTween:Play()
                if count == 0 then
                    selectorLabel.Text = "No options available"
                else
                    selectorLabel.Text = (dropdown.Value and tostring(dropdown.Value) or "Select...")
                end
            end

            local function setValue(value, invokeCallback)
                if value == nil then return false end
                local found = false
                for _, availableValue in ipairs(dropdown.Values) do
                    if availableValue == value then
                        found = true
                        break
                    end
                end
                if not found then return false end

                dropdown.Value = value
                refreshSelection(value)
                updateOpenState(false)
                if invokeCallback ~= false and data and data.Callback then
                    data.Callback(value)
                end
                return true
            end

            local function rebuildOptions()
                table.clear(optionViews)
                for _, child in ipairs(optionsList:GetChildren()) do
                    if child:IsA("GuiObject") then
                        child:Destroy()
                    end
                end

                for index, value in ipairs(dropdown.Values) do
                    local option, optionLabel = CreateClickButton(
                        optionsList,
                        tostring(value),
                        UDim2.new(1, -2, 0, optionHeight),
                        UDim2.new(),
                        COLOR_CONTROL,
                        COLOR_TEXT,
                        Enum.Font.GothamSemibold,
                        12
                    )
                    option.LayoutOrder = index
                    optionViews[value] = {option, optionLabel}
                    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    local optionPadding = Instance.new("UIPadding")
                    optionPadding.PaddingLeft = UDim.new(0, 8)
                    optionPadding.Parent = optionLabel
                    connectActivated(option, function()
                        setValue(value, true)
                    end)
                end
                refreshSelection(dropdown.Value)
                updateOpenState(dropdown.Opened)
            end

            function dropdown:SetValues(values)
                local same = #self.Values == #(values or {})
                if same then
                    for i, v in ipairs(values or {}) do if self.Values[i] ~= v then same = false; break end end
                end
                if same then return end
                self.Values = {}
                for _, value in ipairs(values or {}) do
                    table.insert(self.Values, value)
                end
                if self.Value then
                    local stillExists = false
                    for _, value in ipairs(self.Values) do
                        if value == self.Value then
                            stillExists = true
                            break
                        end
                    end
                    if not stillExists then
                        self.Value = nil
                    end
                end
                rebuildOptions()
            end

            function dropdown:SetValue(value)
                return setValue(value, true)
            end

            function dropdown:GetValue()
                return self.Value
            end

            connectActivated(selector, function()
                updateOpenState(not dropdown.Opened)
            end)

            dropdown:SetValues(data and data.Values or {})
            if data and data.Default ~= nil then
                setValue(data.Default, false)
            end

            NexusUI.Options[id] = dropdown
            table.insert(controls, dropdownFrame)
            return dropdown
        end

        function tabObject:AddButton(data)
            local hasDesc = data and data.Description and data.Description ~= ""

            local buttonFrame = Instance.new("Frame")
            buttonFrame.Size = hasDesc and UDim2.new(1, 0, 0, 50) or UDim2.new(1, 0, 0, 34)
            NexusUI:BindColor(buttonFrame, "BackgroundColor3", function() return COLOR_CONTROL end)
            buttonFrame.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
            buttonFrame.LayoutOrder = #controls + 1
            buttonFrame.BorderSizePixel = 0
            buttonFrame.Active = true
            buttonFrame.Parent = getControlParent()

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 4)
            bCorner.Parent = buttonFrame

            local bStroke = Instance.new("UIStroke")
            bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            NexusUI:BindColor(bStroke, "Color", function() return COLOR_BORDER end)
            bStroke.Transparency = 0.4
            bStroke.Thickness = 1
            bStroke.Parent = buttonFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = data and data.Title or "Button"
            NexusUI:BindColor(titleLabel, "TextColor3", function() return COLOR_TEXT end)
            titleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            titleLabel.TextSize = 13
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextYAlignment = Enum.TextYAlignment.Center
            if hasDesc then
                titleLabel.Size = UDim2.new(1, -36, 0, 15)
                titleLabel.Position = UDim2.new(0, 10, 0, 7)
            else
                titleLabel.Size = UDim2.new(1, -36, 1, 0)
                titleLabel.Position = UDim2.new(0, 10, 0, 0)
            end
            titleLabel.Parent = buttonFrame

            if hasDesc then
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, -36, 0, 12)
                descLabel.Position = UDim2.new(0, 10, 0, 25)
                descLabel.BackgroundTransparency = 1
                descLabel.Text = data.Description
                NexusUI:BindColor(descLabel, "TextColor3", function() return COLOR_TEXT_DIM end)
                descLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                descLabel.TextSize = 11
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextWrapped = true
                descLabel.Parent = buttonFrame
            end

            local arrowLabel = Instance.new("TextLabel")
            arrowLabel.Size = UDim2.fromOffset(14, 14)
            arrowLabel.AnchorPoint = Vector2.new(1, 0.5)
            arrowLabel.Position = UDim2.new(1, -8, 0.5, 0)
            arrowLabel.BackgroundTransparency = 1
            arrowLabel.Text = ">"
            NexusUI:BindColor(arrowLabel, "TextColor3", function() return COLOR_TEXT_DIM end)
            arrowLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            arrowLabel.TextSize = 14
            arrowLabel.ZIndex = buttonFrame.ZIndex + 1
            arrowLabel.Parent = buttonFrame

            local defaultBg = COLOR_CONTROL
            local hoverBg = COLOR_CONTROL:Lerp(ACCENT, 0.12)
            table.insert(NexusUI.ThemeRefresh, function() defaultBg = COLOR_CONTROL; hoverBg = COLOR_CONTROL:Lerp(ACCENT, 0.12) end)

            TrackGuiConnection(buttonFrame.MouseEnter:Connect(function()
                TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = hoverBg}):Play()
                TweenService:Create(bStroke, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Transparency = 0.3}):Play()
            end))

            TrackGuiConnection(buttonFrame.MouseLeave:Connect(function()
                TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = defaultBg}):Play()
                TweenService:Create(bStroke, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Transparency = 0.55}):Play()
            end))

            ConnectClick(buttonFrame, function()
                TweenService:Create(buttonFrame, TweenInfo.new(0.07, Enum.EasingStyle.Quad), {BackgroundColor3 = COLOR_CONTROL}):Play()
                task.delay(0.12, function()
                    if buttonFrame and buttonFrame.Parent then
                        TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = defaultBg}):Play()
                    end
                end)
                if data and data.Callback then
                    data.Callback()
                end
            end)

            table.insert(controls, buttonFrame)
            return buttonFrame
        end

        local tabIndex = #tabs + 1
        if IS_MOBILE then
            TrackGuiConnection(tabButton.Activated:Connect(function()
                selectTab(tabIndex)
            end))
        else
            ConnectClick(tabButton, function()
                selectTab(tabIndex)
            end)
        end

        table.insert(tabs, {button = tabButton, page = tabPage, label = tabLabel, underline = tabUnderline})
        if tabIndex == 1 then
            selectTab(1)
        end
        return tabObject
    end

    function window:SelectTab(index)
        selectTab(index)
    end

    function window:SetCollapsed(value)
        setCollapsed(value)
    end

    function window:ToggleCollapsed()
        setCollapsed(not isCollapsed)
    end

    function window:SetVisible(visible)
        setVisible(visible)
    end

    function window:IsVisible()
        return mainFrame.Visible
    end

    track(userInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            window:SetVisible(not mainFrame.Visible)
        end
    end))

    local function updateRestoreVisibility()
        if not SHOW_RESTORE_BUTTON then
            if restoreGui then
                restoreGui:Destroy()
                restoreGui = nil
            end
            return
        end

        if not mainFrame.Visible or not screenGui.Enabled then
            local mobileButtonGui = createRestoreGui()
            if mobileButtonGui then
                mobileButtonGui.Enabled = true
            end
        elseif restoreGui then
            restoreGui.Enabled = false
        end
    end

    track(mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        updateRestoreVisibility()
    end))

    track(screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        updateRestoreVisibility()
    end))

    if not isVisibleByDefault then
        setVisible(false)
    else
        animateWindowIn()
        updateRestoreVisibility()
    end

    local windowDestroyed = false
    destroyWindow = function()
        if windowDestroyed then
            return
        end
        windowDestroyed = true

        NexusUI:UnloadFeatures()
        destroyCloseConfirm()

        for _, conn in ipairs(connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        connections = {}
        for _, conn in ipairs(GuiConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        GuiConnections = {}
        if restoreGui then
            restoreGui:Destroy()
            restoreGui = nil
        end
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end

    function window:Destroy()
        destroyWindow()
    end

    return window
end

function NexusUI:CreateMinimizer()
    return nil
end

function NexusUI:Notify(options)
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "NexusNotify"
    notifyGui.ResetOnSpawn = false
    notifyGui.Parent = GuiParent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(240, 48)
    frame.Position = UDim2.new(1, -250, 0, 20)
    NexusUI:BindColor(frame, "BackgroundColor3", function() return COLOR_WINDOW end)
    frame.BackgroundTransparency = 0.02
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    NexusUI:BindColor(frameStroke, "Color", function() return COLOR_BORDER end)
    frameStroke.Transparency = 0.4
    frameStroke.Thickness = 1
    frameStroke.Parent = frame

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -10)
    accentBar.Position = UDim2.new(0, 5, 0, 5)
    NexusUI:BindColor(accentBar, "BackgroundColor3", function() return ACCENT end)
    accentBar.BorderSizePixel = 0
    accentBar.Parent = frame

    local accentBarCorner = Instance.new("UICorner")
    accentBarCorner.CornerRadius = UDim.new(1, 0)
    accentBarCorner.Parent = accentBar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -22, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (options and options.Title or "Notify") .. "\n" .. (options and options.Content or "")
    NexusUI:BindColor(label, "TextColor3", function() return COLOR_TEXT end)
    label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    task.delay((options and options.Duration or 3) + 0.2, function()
        if notifyGui then
            notifyGui:Destroy()
        end
    end)
end

windowSize = IS_MOBILE and UDim2.fromOffset(620, 390) or UDim2.fromOffset(720, 460)

Window = NexusUI:CreateWindow({
    Title = "PRIME",
    Size = windowSize,
    Theme = "Slate",
    visible = true,
    MinimizeKey = Enum.KeyCode.LeftAlt
})

StarterGui:SetCore("SendNotification", {
    Title = "PRIME Loaded",
    Text = "PRIME Loaded Successfully!",
    Duration = 4,
    Button1 = "OK"
})

Tabs = {
    Main = Window:AddTab({ Title = "Main"}),
    Movement = Window:AddTab({ Title = "Movement"}),
    Aim = Window:AddTab({ Title = "Aim"}),
    ESP = Window:AddTab({ Title = "ESP"}),
    Zone = Window:AddTab({ Title = "Zone"}),
    Misc = Window:AddTab({ Title = "Misc"}),
    Visuals = Window:AddTab({ Title = "Visuals"}),
    Other = Window:AddTab({ Title = "Other"})
}

Tabs.Settings = Window:AddTab({ Title = "Settings"})
Tabs.Settings:AddSection("Appearance")
Tabs.Settings:AddDropdown("GUITheme", {Title = "GUI Theme", Default = "Purple", Values = {"Purple", "Light", "Blue", "Mint", "Rose", "Midnight"}, Callback = function(v) NexusUI:SetTheme(v) end})

currentCloseKey = Enum.KeyCode.LeftAlt
waitingForKey = false

if not IS_MOBILE then
SettingsSection = Tabs.Settings:AddSection("Keybinds")

keybindRow = Instance.new("Frame")
keybindRow.Size = UDim2.new(1, 0, 0, 48)
NexusUI:BindColor(keybindRow, "BackgroundColor3", function() return COLOR_CONTROL end)
keybindRow.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
keybindRow.BorderSizePixel = 0
keybindRow.LayoutOrder = 2
keybindRow.Parent = SettingsSection.Content

keybindRowCorner = Instance.new("UICorner")
keybindRowCorner.CornerRadius = UDim.new(0, 4)
keybindRowCorner.Parent = keybindRow

keybindTitle = Instance.new("TextLabel")
keybindTitle.Size = UDim2.new(1, -130, 0, 16)
keybindTitle.Position = UDim2.new(0, 8, 0, 8)
keybindTitle.BackgroundTransparency = 1
keybindTitle.Text = "Toggle GUI"
NexusUI:BindColor(keybindTitle, "TextColor3", function() return COLOR_TEXT end)
keybindTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
keybindTitle.TextSize = 15
keybindTitle.TextXAlignment = Enum.TextXAlignment.Left
keybindTitle.Parent = keybindRow

keybindHint = Instance.new("TextLabel")
keybindHint.Size = UDim2.new(1, -130, 0, 13)
keybindHint.Position = UDim2.new(0, 8, 0, 27)
keybindHint.BackgroundTransparency = 1
keybindHint.Text = "Click box to rebind"
NexusUI:BindColor(keybindHint, "TextColor3", function() return COLOR_TEXT_DIM end)
keybindHint.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
keybindHint.TextSize = 11
keybindHint.TextXAlignment = Enum.TextXAlignment.Left
keybindHint.Parent = keybindRow

keybindBadge = Instance.new("Frame")
keybindBadge.Size = UDim2.fromOffset(78, 28)
keybindBadge.Position = UDim2.new(1, -86, 0.5, -14)
NexusUI:BindColor(keybindBadge, "BackgroundColor3", function() return COLOR_CONTROL end)
keybindBadge.BackgroundTransparency = GUI_BUTTON_TRANSPARENCY
keybindBadge.BorderSizePixel = 0
keybindBadge.Active = true
keybindBadge.ZIndex = 5
keybindBadge.Parent = keybindRow

keybindBadgeCorner = Instance.new("UICorner")
keybindBadgeCorner.CornerRadius = UDim.new(0, 7)
keybindBadgeCorner.Parent = keybindBadge

keybindBadgeStroke = Instance.new("UIStroke")
keybindBadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
NexusUI:BindColor(keybindBadgeStroke, "Color", function() return COLOR_BORDER end)
keybindBadgeStroke.Transparency = 0.4
keybindBadgeStroke.Thickness = 1
keybindBadgeStroke.Parent = keybindBadge

keybindBadgeLabel = Instance.new("TextLabel")
keybindBadgeLabel.Size = UDim2.new(1, -6, 1, 0)
keybindBadgeLabel.Position = UDim2.new(0, 3, 0, 0)
keybindBadgeLabel.BackgroundTransparency = 1
keybindBadgeLabel.Text = "LeftAlt"
NexusUI:BindColor(keybindBadgeLabel, "TextColor3", function() return COLOR_TEXT end)
keybindBadgeLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
keybindBadgeLabel.TextSize = 13
keybindBadgeLabel.TextTruncate = Enum.TextTruncate.AtEnd
keybindBadgeLabel.ZIndex = 6
keybindBadgeLabel.Parent = keybindBadge

function UpdateKeybindBadge()
    keybindBadgeLabel.Text = currentCloseKey and currentCloseKey.Name or "None"
    NexusUI:BindColor(keybindBadgeLabel, "TextColor3", function() return COLOR_TEXT end)
    TweenService:Create(keybindBadge, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        BackgroundColor3 = COLOR_CONTROL
    }):Play()
    TweenService:Create(keybindBadgeStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Color = COLOR_BORDER,
        Transparency = 0.4
    }):Play()
end

function SetGUIKey(key)
    if not key then return end
    currentCloseKey = key
    Window:SetToggleKey(key)
    waitingForKey = false
    UpdateKeybindBadge()
end

function BeginKeyBinding()
    waitingForKey = true
    keybindBadgeLabel.Text = "..."
    NexusUI:BindColor(keybindBadgeLabel, "TextColor3", function() return COLOR_TEXT end)
    TweenService:Create(keybindBadge, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        BackgroundColor3 = COLOR_BORDER
    }):Play()
    TweenService:Create(keybindBadgeStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Color = ACCENT,
        Transparency = 0.1
    }):Play()
end

TrackScriptConnection(userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if waitingForKey then
        if input.KeyCode == Enum.KeyCode.Escape then
            waitingForKey = false
            UpdateKeybindBadge()
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
            SetGUIKey(input.KeyCode)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            SetGUIKey(Enum.KeyCode.MouseButton1)
        else
            waitingForKey = false
            UpdateKeybindBadge()
        end
    end
end))

ConnectClick(keybindBadge, function()
    if waitingForKey then
        waitingForKey = false
        UpdateKeybindBadge()
    else
        BeginKeyBinding()
    end
end)

TrackGuiConnection(keybindBadge.MouseEnter:Connect(function()
    if not waitingForKey then
        TweenService:Create(keybindBadge, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundColor3 = COLOR_CONTROL
        }):Play()
    end
end))

TrackGuiConnection(keybindBadge.MouseLeave:Connect(function()
    if not waitingForKey then
        TweenService:Create(keybindBadge, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundColor3 = COLOR_CONTROL
        }):Play()
    end
end))
end -- desktop-only Settings UI

end}
