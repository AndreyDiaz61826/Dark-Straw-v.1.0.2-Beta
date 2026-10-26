
-- BLACKOUT HUB | Complete LocalScript
-- For your own Roblox Studio experience

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("BlackoutHub")
if oldGui then oldGui:Destroy() end

local S = {
    Aim = false,
    ESP = false,
    Speed = false,
    SpeedValue = 35,
    Smoothness = 18,
    AimColor = Color3.fromRGB(110, 80, 255),
    FillColor = Color3.fromRGB(255, 45, 55),
    OutlineColor = Color3.fromRGB(255, 255, 255),
}

local espHighlights = {}
local aimHighlights = {}
local currentTarget
local currentTab = "Combat"

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

local function outline(obj, color, thickness)
    return make("UIStroke", {
        Color = color or Color3.fromRGB(55, 55, 65),
        Thickness = thickness or 1,
    }, obj)
end

local function text(parent, value, size, pos, fontSize, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = size,
        Position = pos,
        Text = value,
        TextColor3 = color or Color3.fromRGB(240, 240, 245),
        Font = Enum.Font.GothamMedium,
        TextSize = fontSize or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local gui = make("ScreenGui", {
    Name = "BlackoutHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- Floating circular logo
local logo = make("ImageButton", {
    Name = "FloatingLogo",
    Size = UDim2.fromOffset(44, 44),
    Position = UDim2.new(0, 14, 0.5, -22),
    BackgroundTransparency = 1,
    Image = "rbxassetid://96019926640194",
    ScaleType = Enum.ScaleType.Crop,
    AutoButtonColor = true,
    Visible = false,
    ZIndex = 20,
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(1, 0)
}, logo)

-- Main window
local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(480, 320),
    Position = UDim2.new(0.5, -240, 0.5, -160),
    BackgroundColor3 = Color3.fromRGB(13, 13, 16),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ClipsDescendants = false,
}, gui)

round(main, 12)
outline(main, Color3.fromRGB(65, 65, 76), 1)

-- Background image
local bg = make("ImageLabel", {
    Name = "MenuBackground",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Image = "rbxassetid://112525965968613",
    ImageTransparency = 0.30,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 0,
}, main)

round(bg, 12)

local function updateLayout()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local v = camera.ViewportSize

    if v.X < 600 then
        main.Size = UDim2.new(0.92, 0, 0, 320)
        main.Position = UDim2.new(0.04, 0, 0.5, -160)
    else
        main.Size = UDim2.fromOffset(480, 320)
        main.Position = UDim2.new(0.5, -240, 0.5, -160)
    end
end

updateLayout()

local top = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = Color3.fromRGB(18, 18, 23),
    BackgroundTransparency = 0.10,
    BorderSizePixel = 0,
    ZIndex = 2,
}, main)

round(top, 12)

make("Frame", {
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = top.BackgroundColor3,
    BackgroundTransparency = top.BackgroundTransparency,
    BorderSizePixel = 0,
    ZIndex = 2,
}, top)

text(top, "BLACKOUT", UDim2.new(0, 115, 1, 0),
    UDim2.fromOffset(13, 0), 16)

text(top, "H U B  /  MOBILE", UDim2.new(0, 145, 1, 0),
    UDim2.fromOffset(112, 0), 9, Color3.fromRGB(150, 150, 165))

local close = make("TextButton", {
    Size = UDim2.fromOffset(29, 29),
    Position = UDim2.new(1, -36, 0, 7),
    BackgroundColor3 = Color3.fromRGB(48, 35, 43),
    Text = "×",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 21,
    Font = Enum.Font.Gotham,
    BorderSizePixel = 0,
    ZIndex = 3,
}, top)

round(close, 7)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Drag window
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
            local d = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
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
    Name = "Sidebar",
    Position = UDim2.fromOffset(9, 51),
    Size = UDim2.new(0, 132, 1, -60),
    BackgroundColor3 = Color3.fromRGB(17, 17, 21),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 2,
}, main)

round(sidebar, 8)

text(sidebar, "NAVIGATION", UDim2.new(1, -16, 0, 24),
    UDim2.fromOffset(10, 3), 9, Color3.fromRGB(145, 145, 160))

local content = make("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.new(0, 150, 0, 51),
    Size = UDim2.new(1, -159, 1, -60),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(115, 90, 255),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 2,
}, main)

make("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local navButtons = {}

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function card(title, description)
    local height = description and 61 or 48

    local frame = make("Frame", {
        Size = UDim2.new(1, -5, 0, height),
        BackgroundColor3 = Color3.fromRGB(24, 24, 29),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, content)

    round(frame, 7)
    outline(frame, Color3.fromRGB(44, 44, 52), 1)

    text(frame, title, UDim2.new(1, -85, 0, 25),
        UDim2.fromOffset(10, 4), 11)

    if description then
        text(frame, description, UDim2.new(1, -15, 0, 22),
            UDim2.fromOffset(10, 29), 9,
            Color3.fromRGB(150, 150, 163))
    end

    return frame
end

local function toggle(title, description, getter, setter)
    local frame = card(title, description)

    local button = make("TextButton", {
        Size = UDim2.fromOffset(42, 23),
        Position = UDim2.new(1, -52, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(48, 48, 57),
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 3,
    }, frame)

    round(button, 12)

    local dot = make("Frame", {
        Size = UDim2.fromOffset(17, 17),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.fromRGB(240, 240, 245),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, button)

    round(dot, 10)

    local function redraw()
        local enabled = getter()
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(115, 85, 255)
            or Color3.fromRGB(48, 48, 57)

        dot.Position = enabled
            and UDim2.new(1, -20, 0, 3)
            or UDim2.fromOffset(3, 3)
    end

    button.Activated:Connect(function()
        setter(not getter())
        redraw()
    end)

    redraw()
end

local function actionButton(title, description, caption, callback)
    local frame = card(title, description)

    local button = make("TextButton", {
        Size = UDim2.fromOffset(59, 25),
        Position = UDim2.new(1, -68, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(51, 44, 76),
        Text = caption or "EDIT",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, frame)

    round(button, 6)
    button.Activated:Connect(callback)
end

local function slider(title, minimum, maximum, getter, setter)
    local frame = card(title, nil)
    frame.Size = UDim2.new(1, -5, 0, 60)

    local valueLabel = text(frame, "", UDim2.fromOffset(48, 22),
        UDim2.new(1, -58, 0, 1), 10,
        Color3.fromRGB(180, 160, 255))

    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = make("Frame", {
        Position = UDim2.new(0, 10, 0, 37),
        Size = UDim2.new(1, -20, 0, 5),
        BackgroundColor3 = Color3.fromRGB(54, 54, 64),
        BorderSizePixel = 0,
        ZIndex = 3,
    }, frame)

    round(bar, 4)

    local fill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(125, 95, 255),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, bar)

    round(fill, 4)

    local knob = make("TextButton", {
        Size = UDim2.fromOffset(15, 15),
        Position = UDim2.new(0, -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 5,
    }, bar)

    round(knob, 10)

    local dragging = false

    local function redraw()
        local value = math.clamp(getter(), minimum, maximum)
        local ratio = (value - minimum) / (maximum - minimum)

        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -7, 0.5, -7)
        valueLabel.Text = tostring(math.floor(value + 0.5))
    end

    local function setX(x)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local ratio = math.clamp(
            (x - bar.AbsolutePosition.X) / width, 0, 1)

        setter(minimum + ratio * (maximum - minimum))
        redraw()
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setX(input.Position.X)
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            setX(input.Position.X)
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

-- Color picker with HEX input and palette
local function colorPicker(title, initial, callback)
    local popup = make("Frame", {
        Size = UDim2.new(0.84, 0, 0, 190),
        Position = UDim2.new(0.08, 0, 0.5, -95),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BorderSizePixel = 0,
        ZIndex = 10,
    }, main)

    round(popup, 9)
    outline(popup, Color3.fromRGB(115, 90, 255), 1)

    text(popup, title, UDim2.new(1, -42, 0, 27),
        UDim2.fromOffset(10, 3), 12).ZIndex = 11

    local closePopup = make("TextButton", {
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(1, -29, 0, 4),
        BackgroundColor3 = Color3.fromRGB(47, 47, 55),
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 17,
        ZIndex = 12,
    }, popup)

    round(closePopup, 5)
    closePopup.Activated:Connect(function()
        popup:Destroy()
    end)

    local hex = make("TextBox", {
        Position = UDim2.fromOffset(10, 35),
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundColor3 = Color3.fromRGB(11, 11, 15),
        Text = "#" .. initial:ToHex(),
        PlaceholderText = "#7855FF",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Code,
        TextSize = 13,
        ClearTextOnFocus = false,
        ZIndex = 11,
    }, popup)

    round(hex, 5)

    local preview = make("Frame", {
        Position = UDim2.fromOffset(10, 72),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundColor3 = initial,
        BorderSizePixel = 0,
        ZIndex = 11,
    }, popup)

    round(preview, 4)

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
            Position = UDim2.fromOffset(10 + (i - 1) * 34, 101),
            Size = UDim2.fromOffset(26, 23),
            BackgroundColor3 = color,
            Text = "",
            BorderSizePixel = 0,
            ZIndex = 11,
        }, popup)

        round(swatch, 4)

        swatch.Activated:Connect(function()
            hex.Text = "#" .. color:ToHex()
            preview.BackgroundColor3 = color
        end)
    end

    hex:GetPropertyChangedSignal("Text"):Connect(function()
        local raw = hex.Text:gsub("#", "")
        if #raw == 6 and raw:match("^%x%x%x%x%x%x$") then
            local ok, color = pcall(function()
                return Color3.fromHex(raw)
            end)
            if ok then preview.BackgroundColor3 = color end
        end
    end)

    local apply = make("TextButton", {
        Position = UDim2.new(0, 10, 1, -32),
        Size = UDim2.new(1, -20, 0, 24),
        BackgroundColor3 = Color3.fromRGB(112, 82, 255),
        Text = "APPLY COLOR",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 11,
    }, popup)

    round(apply, 5)

    apply.Activated:Connect(function()
        local raw = hex.Text:gsub("#", "")
        if #raw == 6 and raw:match("^%x%x%x%x%x%x$") then
            local ok, color = pcall(function()
                return Color3.fromHex(raw)
            end)

            if ok then
                callback(color)
                popup:Destroy()
            end
        end
    end)
end

local function getCharacter(plr)
    local char = plr.Character
    if not char then return nil end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid or humanoid.Health <= 0 then
        return nil
    end

    return char, root, humanoid
end

local function removeFrom(store, plr)
    local h = store[plr]
    if h then
        h:Destroy()
        store[plr] = nil
    end
end

local function getHighlight(store, plr, char, name)
    local h = store[plr]

    if not h or h.Parent ~= char then
        removeFrom(store, plr)

        h = Instance.new("Highlight")
        h.Name = name
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        store[plr] = h
    end

    return h
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char, _, humanoid = getCharacter(plr)

            if S.ESP and char and humanoid then
                local h = getHighlight(
                    espHighlights, plr, char, "BlackoutESP")

                h.Enabled = true
                h.FillColor = S.FillColor
                h.OutlineColor = S.OutlineColor
                h.FillTransparency = 0.35
                h.OutlineTransparency = 0
            else
                removeFrom(espHighlights, plr)
            end
        end
    end
end

local function nearestTarget()
    local _, myRoot = getCharacter(player)
    if not myRoot then return nil end

    local best, bestDistance

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local _, root = getCharacter(plr)

            if root then
                local distance = (root.Position - myRoot.Position).Magnitude

                if not bestDistance or distance < bestDistance then
                    best = plr
                    bestDistance = distance
                end
            end
        end
    end

    return best
end

local function updateAim()
    local target = nearestTarget()
    currentTarget = target

    for plr in pairs(aimHighlights) do
        if plr ~= target or not S.Aim then
            removeFrom(aimHighlights, plr)
        end
    end

    if not target then return end

    local char = target.Character
    if not char then return end

    local h = getHighlight(
        aimHighlights, target, char, "BlackoutAimTarget")

    h.FillColor = S.AimColor
    h.OutlineColor = S.AimColor
    h.FillTransparency = 0.35
    h.OutlineTransparency = 0

    local head = char:FindFirstChild("Head")
    local camera = workspace.CurrentCamera

    if head and camera then
        local desired = CFrame.lookAt(camera.CFrame.Position, head.Position)
        camera.CFrame = camera.CFrame:Lerp(
            desired, math.clamp(S.Smoothness / 100, 0.01, 1))
    end
end

local function renderTab(tab)
    currentTab = tab
    clearContent()

    for name, button in pairs(navButtons) do
        button.BackgroundColor3 = name == tab
            and Color3.fromRGB(48, 42, 78)
            or Color3.fromRGB(18, 18, 22)
    end

    local heading = text(content, string.upper(tab),
        UDim2.new(1, -5, 0, 25), UDim2.new(), 14,
        Color3.fromRGB(190, 175, 255))

    heading.LayoutOrder = 0

    if tab == "Combat" then
        toggle("Aim Assist", "Track the nearest player",
            function() return S.Aim end,
            function(v)
                S.Aim = v
                if not v then
                    for plr in pairs(aimHighlights) do
                        removeFrom(aimHighlights, plr)
                    end
                end
            end)

        slider("Aim Smoothness", 1, 100,
            function() return S.Smoothness end,
            function(v) S.Smoothness = v end)

        actionButton("Aim Color", "Target highlight color", "EDIT",
            function()
                colorPicker("AIM COLOR", S.AimColor, function(c)
                    S.AimColor = c
                end)
            end)

    elseif tab == "Visuals" then
        toggle("Player ESP", "White outline and red fill",
            function() return S.ESP end,
            function(v)
                S.ESP = v
                if not v then
                    for plr in pairs(espHighlights) do
                        removeFrom(espHighlights, plr)
                    end
                end
            end)

        actionButton("Fill Color", "Default: red", "EDIT", function()
            colorPicker("ESP FILL", S.FillColor, function(c)
                S.FillColor = c
            end)
        end)

        actionButton("Outline Color", "Default: white", "EDIT", function()
            colorPicker("ESP OUTLINE", S.OutlineColor, function(c)
                S.OutlineColor = c
            end)
        end)

    elseif tab == "Movement" then
        toggle("CFrame SpeedHack", "Accelerated local movement",
            function() return S.Speed end,
            function(v) S.Speed = v end)

        slider("CFrame Speed", 10, 100,
            function() return S.SpeedValue end,
            function(v) S.SpeedValue = v end)

    elseif tab == "Settings" then
        actionButton("Hide Menu", "Leave the floating logo visible", "HIDE",
            function()
                main.Visible = false
                logo.Visible = true
            end)

        actionButton("Reset Colors", "Restore default palette", "RESET",
            function()
                S.AimColor = Color3.fromRGB(110, 80, 255)
                S.FillColor = Color3.fromRGB(255, 45, 55)
                S.OutlineColor = Color3.fromRGB(255, 255, 255)
                renderTab("Settings")
            end)

        actionButton("Stop All", "Disable active features", "STOP",
            function()
                S.Aim = false
                S.ESP = false
                S.Speed = false

                for plr in pairs(aimHighlights) do
                    removeFrom(aimHighlights, plr)
                end

                for plr in pairs(espHighlights) do
                    removeFrom(espHighlights, plr)
                end

                renderTab("Settings")
            end)
    end
end

local tabs = {"Combat", "Visuals", "Movement", "Settings"}

for i, tab in ipairs(tabs) do
    local button = make("TextButton", {
        Position = UDim2.fromOffset(6, 31 + (i - 1) * 40),
        Size = UDim2.new(1, -12, 0, 34),
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        Text = tab,
        TextColor3 = Color3.fromRGB(235, 235, 242),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)

    round(button, 6)
    navButtons[tab] = button

    button.Activated:Connect(function()
        renderTab(tab)
    end)
end

-- Reopen menu by tapping the circular logo
logo.Activated:Connect(function()
    main.Visible = true
    logo.Visible = false
end)

-- Runtime loop
local espTimer = 0

RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end

    espTimer += dt

    if espTimer >= 0.2 then
        espTimer = 0
        updateESP()
    end

    if S.Aim then
        updateAim()
    end

    if S.Speed then
        local _, root, humanoid = getCharacter(player)

        if root and humanoid then
            local direction = humanoid.MoveDirection

            if direction.Magnitude > 0 then
                local move = direction * S.SpeedValue * dt

                root.CFrame = root.CFrame + Vector3.new(
                    move.X, 0, move.Z)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeFrom(espHighlights, plr)
    removeFrom(aimHighlights, plr)
end)

renderTab("Combat")
print("Blackout Hub loaded")
