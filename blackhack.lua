
-- BLACKOUT HUB | Mobile Edition
-- Single LocalScript for your own Roblox experience

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("BlackoutHub")
if old then old:Destroy() end

local Settings = {
    Aim = false,
    ESP = false,
    CFrameSpeed = false,
    Speed = 35,
    AimColor = Color3.fromRGB(110, 80, 255),
    ESPFill = Color3.fromRGB(255, 45, 55),
    ESPOutline = Color3.fromRGB(255, 255, 255),
    AimSmoothness = 0.18,
}

local selectedTab = "Combat"
local highlights = {}
local currentTarget = nil

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

local function stroke(obj, color, thickness, transparency)
    return make("UIStroke", {
        Color = color or Color3.fromRGB(70, 70, 78),
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, obj)
end

local function label(parent, text, size, position, fontSize, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        Text = text,
        TextColor3 = color or Color3.fromRGB(240, 240, 245),
        Font = Enum.Font.GothamMedium,
        TextSize = fontSize or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local gui = make("ScreenGui", {
    Name = "BlackoutHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(480, 320),
    Position = UDim2.new(0.5, -240, 0.5, -160),
    BackgroundColor3 = Color3.fromRGB(13, 13, 16),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ClipsDescendants = false,
}, gui)
corner(main, 12)
stroke(main, Color3.fromRGB(65, 65, 76), 1)
-- Responsive sizing for phones
local function updateLayout()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize

    if viewport.X < 600 then
        main.Size = UDim2.new(0.92, 0, 0, 320)
        main.Position = UDim2.new(0.04, 0, 0.5, -160)
    else
        main.Size = UDim2.fromOffset(480, 320)
        main.Position = UDim2.new(0.5, -240, 0.5, -160)
    end
end

updateLayout()

local top = make("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(20, 20, 24),
    BorderSizePixel = 0,
}, main)
corner(top, 12)

-- Cover the bottom corners of the header
make("Frame", {
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = top.BackgroundColor3,
    BorderSizePixel = 0,
}, top)

label(top, "BLACKOUT", UDim2.new(0, 180, 1, 0),
    UDim2.fromOffset(16, 0), 17, Color3.fromRGB(255, 255, 255))

label(top, "H U B   /   MOBILE", UDim2.new(0, 160, 1, 0),
    UDim2.fromOffset(125, 0), 9, Color3.fromRGB(145, 145, 160))

local close = make("TextButton", {
    Size = UDim2.fromOffset(32, 32),
    Position = UDim2.new(1, -42, 0, 8),
    BackgroundColor3 = Color3.fromRGB(40, 40, 47),
    Text = "×",
    TextSize = 23,
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham,
    AutoButtonColor = true,
}, top)
corner(close, 8)
close.Activated:Connect(function()
    gui:Destroy()
end)

-- Drag window using the header
do
    local dragging = false
    local dragStart, startPos

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(10, 58),
    Size = UDim2.new(0, 145, 1, -68),
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0,
}, main)
corner(sidebar, 8)

label(sidebar, "NAVIGATION", UDim2.new(1, -20, 0, 25),
    UDim2.fromOffset(12, 5), 9, Color3.fromRGB(115, 115, 130))

local content = make("ScrollingFrame", {
    Position = UDim2.new(0, 165, 0, 58),
    Size = UDim2.new(1, -175, 1, -68),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(100, 100, 115),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)

make("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local navButtons = {}
local tabRenderers = {}
local refreshTab

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function card(title, description)
    local frame = make("Frame", {
        Size = UDim2.new(1, -7, 0, description and 68 or 52),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BorderSizePixel = 0,
    }, content)
    corner(frame, 8)
    stroke(frame, Color3.fromRGB(43, 43, 51), 1)

    label(frame, title, UDim2.new(1, -100, 0, 25),
        UDim2.fromOffset(12, 7), 12)

    if description then
        label(frame, description, UDim2.new(1, -20, 0, 24),
            UDim2.fromOffset(12, 32), 9,
            Color3.fromRGB(145, 145, 158))
    end

    return frame
end

local function addToggle(title, description, getter, setter)
    local frame = card(title, description)

    local button = make("TextButton", {
        Size = UDim2.fromOffset(48, 25),
        Position = UDim2.new(1, -60, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(48, 48, 57),
        Text = "",
        BorderSizePixel = 0,
    }, frame)
    corner(button, 13)

    local dot = make("Frame", {
        Size = UDim2.fromOffset(19, 19),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.fromRGB(230, 230, 235),
        BorderSizePixel = 0,
    }, button)
    corner(dot, 10)

    local function redraw()
        local enabled = getter()
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(115, 85, 255)
            or Color3.fromRGB(48, 48, 57)
        dot.Position = enabled
            and UDim2.new(1, -22, 0, 3)
            or UDim2.fromOffset(3, 3)
    end

    button.Activated:Connect(function()
        setter(not getter())
        redraw()
    end)

    redraw()
end

local function addButton(title, description, callback)
    local frame = card(title, description)
    local button = make("TextButton", {
        Size = UDim2.fromOffset(65, 27),
        Position = UDim2.new(1, -77, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(43, 43, 52),
        Text = "EDIT",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
    }, frame)
    corner(button, 6)
    button.Activated:Connect(callback)
end

local function addSlider(title, minimum, maximum, getter, setter)
    local frame = card(title, nil)
    frame.Size = UDim2.new(1, -7, 0, 65)

    local valueLabel = label(frame, "", UDim2.fromOffset(65, 25),
        UDim2.new(1, -78, 0, 3), 11,
        Color3.fromRGB(175, 160, 255))
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = make("Frame", {
        Position = UDim2.new(0, 12, 0, 39),
        Size = UDim2.new(1, -24, 0, 5),
        BackgroundColor3 = Color3.fromRGB(53, 53, 63),
        BorderSizePixel = 0,
    }, frame)
    corner(bar, 4)

    local fill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(125, 95, 255),
        BorderSizePixel = 0,
    }, bar)
    corner(fill, 4)

    local knob = make("TextButton", {
        Size = UDim2.fromOffset(17, 17),
        Position = UDim2.new(0, -8, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        BorderSizePixel = 0,
    }, bar)
    corner(knob, 10)

    local dragging = false

    local function redraw()
        local value = math.clamp(getter(), minimum, maximum)
        local ratio = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -8, 0.5, -8)
        valueLabel.Text = tostring(math.floor(value + 0.5))
    end

    local function setFromX(x)
        local ratio = math.clamp(
            (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setter(minimum + ratio * (maximum - minimum))
        redraw()
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    redraw()
end

-- Color editor popup
local function openColorEditor(title, currentColor, onApply)
    local popup = make("Frame", {
        Size = UDim2.new(0.85, 0, 0, 195),
        Position = UDim2.new(0.075, 0, 0.5, -97),
        BackgroundColor3 = Color3.fromRGB(22, 22, 28),
        BorderSizePixel = 0,
        ZIndex = 20,
    }, main)
    corner(popup, 10)
    stroke(popup, Color3.fromRGB(115, 90, 255), 1)

    label(popup, title, UDim2.new(1, -45, 0, 30),
        UDim2.fromOffset(12, 5), 13)

    local closePopup = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -34, 0, 4),
        BackgroundColor3 = Color3.fromRGB(45, 45, 53),
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        ZIndex = 21,
    }, popup)
    corner(closePopup, 6)
    closePopup.Activated:Connect(function()
        popup:Destroy()
    end)

    local hex = make("TextBox", {
        Position = UDim2.fromOffset(12, 43),
        Size = UDim2.new(1, -24, 0, 35),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        Text = "#" .. currentColor:ToHex(),
        PlaceholderText = "#7855FF",
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
        Font = Enum.Font.Code,
        TextSize = 14,
        ClearTextOnFocus = false,
        ZIndex = 21,
    }, popup)
    corner(hex, 6)

    local preview = make("Frame", {
        Position = UDim2.fromOffset(12, 86),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, popup)
    corner(preview, 6)

    local palette = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 45, 55),
        Color3.fromRGB(115, 75, 255),
        Color3.fromRGB(40, 155, 255),
        Color3.fromRGB(0, 220, 160),
        Color3.fromRGB(255, 180, 40),
        Color3.fromRGB(255, 90, 180),
        Color3.fromRGB(20, 20, 25),
    }

    for i, color in ipairs(palette) do
        local swatch = make("TextButton", {
            Position = UDim2.fromOffset(12 + (i - 1) * 35, 119),
            Size = UDim2.fromOffset(27, 24),
            BackgroundColor3 = color,
            Text = "",
            BorderSizePixel = 0,
            ZIndex = 21,
        }, popup)
        corner(swatch, 5)
        swatch.Activated:Connect(function()
            hex.Text = "#" .. color:ToHex()
            preview.BackgroundColor3 = color
        end)
    end

    hex:GetPropertyChangedSignal("Text"):Connect(function()
        local raw = hex.Text:gsub("#", "")
        if #raw == 6 and raw:match("^%x%x%x%x%x%x$") then
            local ok, color = pcall(Color3.fromHex, raw)
            if ok then preview.BackgroundColor3 = color end
        end
    end)

    local apply = make("TextButton", {
        Position = UDim2.new(0, 12, 1, -38),
        Size = UDim2.new(1, -24, 0, 28),
        BackgroundColor3 = Color3.fromRGB(112, 82, 255),
        Text = "APPLY COLOR",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 21,
    }, popup)
    corner(apply, 6)

    apply.Activated:Connect(function()
        local raw = hex.Text:gsub("#", "")
        if #raw == 6 and raw:match("^%x%x%x%x%x%x$") then
            local ok, color = pcall(Color3.fromHex, raw)
            if ok then
                onApply(color)
                popup:Destroy()
            end
        else
            hex.Text = "Invalid HEX!"
        end
    end)
end

local function getCharacter(player)
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return nil
    end
    return char, root, humanoid
end

local function removeHighlight(player)
    local item = highlights[player]
    if item then
        item:Destroy()
        highlights[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local _, _, humanoid = getCharacter(player)

            if Settings.ESP and char and humanoid then
                local h = highlights[player]
                if not h or h.Parent ~= char then
                    removeHighlight(player)
                    h = Instance.new("Highlight")
                    h.Name = "BlackoutESP"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = char
                    highlights[player] = h
                end

                h.Enabled = true
                h.FillColor = Settings.ESPFill
                h.OutlineColor = Settings.ESPOutline
                h.FillTransparency = 0.35
                h.OutlineTransparency = 0
            else
                removeHighlight(player)
            end
        end
    end
end

local function nearestTarget()
    local _, myRoot = getCharacter(LocalPlayer)
    if not myRoot then return nil end

    local best, bestDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char, root = getCharacter(player)
            if char and root then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    best = player
                end
            end
        end
    end

    return best
end

local function updateAim()
    local target = nearestTarget()
    currentTarget = target

    if target and target.Character then
        local char = target.Character
        local h = highlights[target]

        -- Target highlight is separate from the ESP colors.
        if Settings.Aim then
            if not h or h.Parent ~= char then
                removeHighlight(target)
                h = Instance.new("Highlight")
                h.Name = "BlackoutAimTarget"
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = char
                highlights[target] = h
            end

            h.FillColor = Settings.AimColor
            h.OutlineColor = Settings.AimColor
            h.FillTransparency = 0.35
            h.OutlineTransparency = 0
        end

        -- Aim camera toward the nearest target.
        local head = char:FindFirstChild("Head")
        local camera = workspace.CurrentCamera

        if head and camera then
            local desired = CFrame.lookAt(
                camera.CFrame.Position, head.Position)
            camera.CFrame = camera.CFrame:Lerp(
                desired, Settings.AimSmoothness)
        end
    end
end

local function renderTab(tab)
    selectedTab = tab
    clearContent()

    for name, button in pairs(navButtons) do
        button.BackgroundColor3 = name == tab
            and Color3.fromRGB(48, 42, 78)
            or Color3.fromRGB(18, 18, 22)
    end

    label(content, string.upper(tab), UDim2.new(1, -8, 0, 28),
        UDim2.new(), 15, Color3.fromRGB(190, 175, 255)).LayoutOrder = 0

    if tab == "Combat" then
        addToggle("Aim Assist", "Track the nearest player",
            function() return Settings.Aim end,
            function(v) Settings.Aim = v end)

        addSlider("Aim Smoothness", 1, 40,
            function() return Settings.AimSmoothness * 100 end,
            function(v) Settings.AimSmoothness = v / 100 end)

        addButton("Aim Target Color", "Choose target highlight color", function()
            openColorEditor("AIM COLOR", Settings.AimColor, function(c)
                Settings.AimColor = c
            end)
        end)

    elseif tab == "Visuals" then
        addToggle("Player ESP", "Outline other players",
            function() return Settings.ESP end,
            function(v) Settings.ESP = v end)

        addButton("Fill Color", "Default: red", function()
            openColorEditor("ESP FILL", Settings.ESPFill, function(c)
                Settings.ESPFill = c
            end)
        end)

        addButton("Outline Color", "Default: white", function()
            openColorEditor("ESP OUTLINE", Settings.ESPOutline, function(c)
                Settings.ESPOutline = c
            end)
        end)

    elseif tab == "Movement" then
        addToggle("CFrame SpeedHack", "Move faster in your own experience",
            function() return Settings.CFrameSpeed end,
            function(v) Settings.CFrameSpeed = v end)

        addSlider("CFrame Speed", 10, 100,
            function() return Settings.Speed end,
            function(v) Settings.Speed = v end)

    elseif tab == "Settings" then
        addButton("Reset Colors", "Restore default colors", function()
            Settings.AimColor = Color3.fromRGB(110, 80, 255)
            Settings.ESPFill = Color3.fromRGB(255, 45, 55)
            Settings.ESPOutline = Color3.fromRGB(255, 255, 255)
            renderTab("Settings")
        end)

        addButton("Hide / Show", "Toggle panel visibility", function()
            sidebar.Visible = not sidebar.Visible
            content.Visible = not content.Visible
        end)

        addButton("Stop All", "Disable active features", function()
            Settings.Aim = false
            Settings.ESP = false
            Settings.CFrameSpeed = false
            renderTab("Settings")
        end)
    end
end

local tabs = {"Combat", "Visuals", "Movement", "Settings"}

for i, tab in ipairs(tabs) do
    local button = make("TextButton", {
        Position = UDim2.fromOffset(6, 34 + (i - 1) * 43),
        Size = UDim2.new(1, -12, 0, 37),
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        Text = tab,
        TextColor3 = Color3.fromRGB(235, 235, 242),
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
    }, sidebar)
    corner(button, 7)
    navButtons[tab] = button

    button.Activated:Connect(function()
        renderTab(tab)
    end)
end

-- Runtime features
local espTimer = 0

RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end

    espTimer += dt
    if espTimer >= 0.2 then
        espTimer = 0
        updateESP()
    end

    if Settings.Aim then
        updateAim()
    end

    if Settings.CFrameSpeed then
        local _, root, humanoid = getCharacter(LocalPlayer)
        if root and humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local direction = humanoid.MoveDirection
            local movement = direction * Settings.Speed * dt

            -- Apply only horizontal movement.
            root.CFrame = root.CFrame + Vector3.new(
                movement.X, 0, movement.Z)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeHighlight(player)
end)

renderTab("Combat")
print("Blackout Hub loaded successfully")

          
