--[================================================================]--
--[   TRANSPARENT MOBILE DEV PANEL: AIM, ESP, FLY & SPEEDHACK      ]--
--[================================================================]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Pg = LP:WaitForChild("PlayerGui")

if Pg:FindFirstChild("UltimateDevHub") then Pg.UltimateDevHub:Destroy() end

local S = {
	Open = true,
	SpeedHack = false,
	SpeedValue = 2,
	Fly = false,
	FlySpeed = 50,
	FlyUp = false,
	FlyDown = false,
	AimBot = false,
	ESP = false
}

local Conns = {}
local LockedTarget = nil

local Gui = Instance.new("ScreenGui", Pg)
Gui.Name = "UltimateDevHub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Свернутая кнопка (меньше, без обводки)
local MinBtn = Instance.new("ImageButton", Gui)
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(0, 20, 0.35, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MinBtn.Image = "rbxassetid://96019926640194"
MinBtn.Visible = false
MinBtn.Active = true
MinBtn.Draggable = true
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- Главное компактное полупрозрачное окно
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 440, 0, 260)
Main.Position = UDim2.new(0.5, -220, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BackgroundTransparency = 0.25 -- Сделано более прозрачным
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Верхняя панель
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TopBar.BackgroundTransparency = 0.2
TopBar.Active = true
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TopFix = Instance.new("Frame", TopBar)
TopFix.Size = UDim2.new(1, 0, 0, 6)
TopFix.Position = UDim2.new(0, 0, 1, -6)
TopFix.BackgroundColor3 = TopBar.BackgroundColor3
TopFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Dev Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка скрытия (-)
local HideBtn = Instance.new("TextButton", TopBar)
HideBtn.Size = UDim2.new(0, 28, 0, 28)
HideBtn.Position = UDim2.new(1, -64, 0.5, -14)
HideBtn.BackgroundTransparency = 1
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.TextSize = 16
HideBtn.Font = Enum.Font.GothamBold

-- Кнопка закрытия (×)
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold

HideBtn.MouseButton1Click:Connect(function()
	S.Open = false
	Main.Visible = false
	MinBtn.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
	S.Open = true
	Main.Visible = true
	MinBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
	for _, conn in ipairs(Conns) do
		if conn.Connected then conn:Disconnect() end
	end
	Gui:Destroy()
end)

-- Боковое меню
local Sidebar = Instance.new("ScrollingFrame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, -42)
Sidebar.Position = UDim2.new(0, 6, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Sidebar.BackgroundTransparency = 0.4
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 3)
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 4)

local PagesContainer = Instance.new("Folder", Main)

local function CreatePage()
	local p = Instance.new("ScrollingFrame", PagesContainer)
	p.Size = UDim2.new(1, -134, 1, -44)
	p.Position = UDim2.new(0, 130, 0, 40)
	p.BackgroundTransparency = 1
	p.ScrollBarThickness = 2
	p.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	p.Visible = false
	local l = Instance.new("UIListLayout", p)
	l.Padding = UDim.new(0, 6)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	return p
end

local P_Movement = CreatePage()
local P_Visuals = CreatePage()
local P_Combat = CreatePage()

local function AddTab(name, page)
	local b = Instance.new("TextButton", Sidebar)
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	b.BackgroundTransparency = 0.3
	b.Text = name
	b.TextColor3 = Color3.fromRGB(180, 180, 180)
	b.TextSize = 11
	b.Font = Enum.Font.GothamMedium
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	
	b.MouseButton1Click:Connect(function()
		for _, child in ipairs(PagesContainer:GetChildren()) do child.Visible = false end
		for _, child in ipairs(Sidebar:GetChildren()) do
			if child:IsA("TextButton") then 
				child.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				child.TextColor3 = Color3.fromRGB(180, 180, 180)
			end
		end
		page.Visible = true
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	return b
end

local t1 = AddTab("Movement", P_Movement)
AddTab("Visuals", P_Visuals)
AddTab("Combat", P_Combat)

P_Movement.Visible = true
t1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
t1.TextColor3 = Color3.fromRGB(255, 255, 255)

local function AddToggle(parent, text, cb)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -6, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	btn.BackgroundTransparency = 0.3
	btn.Text = "  " .. text
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamMedium
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	
	local active = false
	btn.MouseButton1Click:Connect(function()
		active = not active
		btn.BackgroundColor3 = active and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(18, 18, 18)
		pcall(function() cb(active) end)
	end)
end

local function AddSlider(parent, title, min, max, cur, cb)
	local card = Instance.new("Frame", parent)
	card.Size = UDim2.new(1, -6, 0, 44)
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	card.BackgroundTransparency = 0.3
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
	
	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -12, 0, 18)
	lbl.Position = UDim2.new(0, 6, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = title .. ": " .. cur
	lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.TextSize = 11
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local bar = Instance.new("Frame", card)
	bar.Size = UDim2.new(1, -12, 0, 5)
	bar.Position = UDim2.new(0, 6, 0, 28)
	bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	
	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((cur - min)/(max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	
	local dragging = false
	bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
			local pos = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local val = math.floor(min + (max - min) * pos)
			fill.Size = UDim2.new(pos, 0, 1, 0)
			lbl.Text = title .. ": " .. val
			cb(val)
		end
	end)
end

-- 1. Movement items
AddToggle(P_Movement, "CFrame SpeedHack", function(active)
	S.SpeedHack = active
	if active then
		table.insert(Conns, RunService.RenderStepped:Connect(function()
			if not S.SpeedHack then return end
			local char = LP.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.MoveDirection.Magnitude > 0 then
				root.CFrame = root.CFrame + (hum.MoveDirection * S.SpeedValue)
			end
		end))
	end
end)

AddSlider(P_Movement, "Speed Value", 1, 5, S.SpeedValue, function(val) S.SpeedValue = val end)

AddToggle(P_Movement, "Fly (Physics Flight)", function(active)
	S.Fly = active
	local char = LP.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	
	if active and root and hum then
		hum.PlatformStand = true
		local bv = Instance.new("BodyVelocity", root)
		bv.Name = "DevFlyBV"
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = Vector3.zero
		
		local bg = Instance.new("BodyGyro", root)
		bg.Name = "DevFlyBG"
		bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		bg.CFrame = root.CFrame
		
		table.insert(Conns, RunService.RenderStepped:Connect(function()
			if not S.Fly or not root.Parent then
				bv:Destroy() bg:Destroy()
				return
			end
			local cam = workspace.CurrentCamera
			local move = Vector3.zero
			if hum.MoveDirection.Magnitude > 0 then
				move = cam.CFrame.LookVector * (hum.MoveDirection.Z * -1) + cam.CFrame.RightVector * hum.MoveDirection.X
			end
			local yVel = 0
			if S.FlyUp then yVel = S.FlySpeed elseif S.FlyDown then yVel = -S.FlySpeed end
			bv.Velocity = (move * S.FlySpeed) + Vector3.new(0, yVel, 0)
			bg.CFrame = cam.CFrame
		end))
	else
		if hum then hum.PlatformStand = false end
		if root then
			if root:FindFirstChild("DevFlyBV") then root.DevFlyBV:Destroy() end
			if root:FindFirstChild("DevFlyBG") then root.DevFlyBG:Destroy() end
		end
	end
end)

AddSlider(P_Movement, "Fly Speed", 20, 200, S.FlySpeed, function(val) S.FlySpeed = val end)

-- Кнопки управления полетом (Вверх / Вниз)
local FlyControlFrame = Instance.new("Frame", Gui)
FlyControlFrame.Size = UDim2.new(0, 100, 0, 45)
FlyControlFrame.Position = UDim2.new(1, -120, 0.5, -22)
FlyControlFrame.BackgroundTransparency = 1
FlyControlFrame.Visible = false

table.insert(Conns, RunService.RenderStepped:Connect(function()
	FlyControlFrame.Visible = S.Fly
end))

local function CreateFlyImgBtn(imgId, posX, cb)
	local btn = Instance.new("ImageButton", FlyControlFrame)
	btn.Size = UDim2.new(0, 42, 0, 42)
	btn.Position = UDim2.new(0, posX, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	btn.BackgroundTransparency = 0.3
	btn.Image = "rbxassetid://" .. imgId
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	
	btn.MouseButton1Down:Connect(function() cb(true) end)
	btn.MouseButton1Up:Connect(function() cb(false) end)
	btn.TouchEnded:Connect(function() cb(false) end)
end

CreateFlyImgBtn("110617138060480", 0, function(state) S.FlyUp = state end)
CreateFlyImgBtn("111531869775223", 52, function(state) S.FlyDown = state end)


-- 2. Visuals items: ESP (Только игроки, белый контур + красная заливка)
AddToggle(P_Visuals, "ESP (Players Only)", function(active)
	S.ESP = active
	if active then
		table.insert(Conns, RunService.RenderStepped:Connect(function()
			if not S.ESP then return end
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LP and p.Character then
					local char = p.Character
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						if char ~= LockedTarget then
							local hl = char:FindFirstChild("HubESP")
							if not hl then
								hl = Instance.new("Highlight", char)
								hl.Name = "HubESP"
								hl.FillColor = Color3.fromRGB(220, 30, 30) -- Красная заливка
								hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белый контур
							end
						else
							if char:FindFirstChild("HubESP") then char.HubESP:Destroy() end
						end
					end
				end
			end
		end))
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("HubESP") then p.Character.HubESP:Destroy() end
		end
	end
end)


-- 3. Combat items: Aim-Bot (Сине-розовый перелив, жесткая фиксация, динамический прицел)
local AimGui = Instance.new("BillboardGui", Gui)
AimGui.Size = UDim2.new(0, 60, 0, 60)
AimGui.AlwaysOnTop = true
AimGui.Enabled = false

local CrosshairImg = Instance.new("ImageLabel", AimGui)
CrosshairImg.Size = UDim2.new(1, 0, 1, 0)
CrosshairImg.BackgroundTransparency = 1
CrosshairImg.Image = "rbxassetid://117749037231625"
CrosshairImg.ImageColor3 = Color3.fromRGB(255, 100, 200)

AddToggle(P_Combat, "Aim-Bot (Strict Lock + Crosshair)", function(active)
	S.AimBot = active
	if active then
		table.insert(Conns, RunService.RenderStepped:Connect(function()
			if not S.AimBot then
				if LockedTarget and LockedTarget.Parent then
					if LockedTarget:FindFirstChild("AimHL") then LockedTarget.AimHL:Destroy() end
				end
				LockedTarget = nil
				AimGui.Enabled = false
				return
			end
			
			local cam = workspace.CurrentCamera
			local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end
			
			local nearest, minDist = nil, math.huge
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LP and p.Character then
					local char = p.Character
					local hum = char:FindFirstChildOfClass("Humanoid")
					local root = char:FindFirstChild("HumanoidRootPart")
					if hum and hum.Health > 0 and root then
						local dist = (root.Position - myRoot.Position).Magnitude
						if dist < minDist then
							minDist = dist
							nearest = char
						end
					end
				end
			end
			
			if LockedTarget and LockedTarget ~= nearest then
				if LockedTarget:FindFirstChild("AimHL") then LockedTarget.AimHL:Destroy() end
				LockedTarget = nil
			end
			
			if nearest then
				LockedTarget = nearest
				if nearest:FindFirstChild("HubESP") then nearest.HubESP:Destroy() end
				
				local root = nearest:FindFirstChild("HumanoidRootPart")
				if root then
					-- Жесткая фиксация камеры на цели
					cam.CFrame = CFrame.new(cam.CFrame.Position, root.Position)
					
					AimGui.Adornee = root
					AimGui.Enabled = true
					-- Размер прицела меняется в зависимости от дистанции
					local scaleFactor = math.clamp(15 / minDist, 0.4, 2.5)
					AimGui.Size = UDim2.new(0, math.floor(50 * scaleFactor), 0, math.floor(50 * scaleFactor))
				end
				
				-- Сине-розовый переливающийся цвет подсветки
				local hl = nearest:FindFirstChild("AimHL") or Instance.new("Highlight", nearest)
				hl.Name = "AimHL"
				local t = tick() * 4
				hl.FillColor = Color3.fromRGB(0 + math.sin(t)*40, 60, 200 + math.cos(t)*55)
				hl.OutlineColor = Color3.fromRGB(255, 100, 220)
			else
				if LockedTarget and LockedTarget:FindFirstChild("AimHL") then LockedTarget.AimHL:Destroy() end
				LockedTarget = nil
				AimGui.Enabled = false
			end
		end))
	else
		if LockedTarget and LockedTarget:FindFirstChild("AimHL") then LockedTarget.AimHL:Destroy() end
		LockedTarget = nil
		AimGui.Enabled = false
	end
end)


-- Перетаскивание главного окна
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = i.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

print("[DevHub]: Transparent version successfully loaded.")
