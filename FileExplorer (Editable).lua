-- =========================================================
-- Cat's Explorer — ULTIMATE COMBINED / LIVE / STABLE
-- Roots + History + Search + Path + Docked Tweened Props
-- Green Highlight + Live Sync + Toggle + Clean State
-- =========================================================

-- ================= Services =================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ================= Roots =================
local ROOTS = {
	workspace,
	game:GetService("Players"),
	game:GetService("Lighting"),
	game:GetService("MaterialService"),
	game:GetService("ReplicatedFirst"),
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerScriptService"),
	game:GetService("ServerStorage"),
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("StarterPlayer"),
	game:GetService("Teams"),
	game:GetService("SoundService"),
	game:GetService("TextChatService"),
}

-- ================= State =================
local currentRootIndex = 1
local current = ROOTS[currentRootIndex]
local history = {}
local connections = {}

local SelectedInstance = nil
local PropertiesOpenFor = nil
local SelectionHighlights = {}

-- ================= Highlight =================
local function clearHighlights()
	for _, h in ipairs(SelectionHighlights) do
		if h then h:Destroy() end
	end
	table.clear(SelectionHighlights)
	SelectedInstance = nil
end

local function highlight(inst)
	clearHighlights()
	if inst:IsA("BasePart") or inst:IsA("Model") then
		local h = Instance.new("Highlight")
		h.FillColor = Color3.fromRGB(0,255,0)
		h.OutlineColor = Color3.fromRGB(0,255,0)
		h.FillTransparency = 0.25
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = inst
		table.insert(SelectionHighlights, h)
	end
	SelectedInstance = inst
end

-- ================= ScreenGui =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CatsExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ================= Main Window =================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(460,540)
Main.Position = UDim2.fromScale(0.03,0.15)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(80,80,80)

-- ================= Header =================
local Header = Instance.new("TextLabel", Main)
Header.Position = UDim2.fromOffset(10,6)
Header.Size = UDim2.new(1,-90,0,24)
Header.Text = "Cat's Explorer"
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.TextColor3 = Color3.new(1,1,1)
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.BackgroundTransparency = 1

-- ================= Window Buttons =================
local Minimize = Instance.new("TextButton", Main)
Minimize.Size = UDim2.fromOffset(30,24)
Minimize.Position = UDim2.new(1,-70,0,6)
Minimize.Text = "–"
Minimize.BackgroundColor3 = Color3.fromRGB(40,40,40)
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BorderSizePixel = 0
Instance.new("UICorner", Minimize)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.fromOffset(30,24)
Close.Position = UDim2.new(1,-35,0,6)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(120,40,40)
Close.TextColor3 = Color3.new(1,1,1)
Close.BorderSizePixel = 0
Instance.new("UICorner", Close)

-- ================= Path Bar =================
local PathBar = Instance.new("TextLabel", Main)
PathBar.Position = UDim2.fromOffset(10,34)
PathBar.Size = UDim2.new(1,-20,0,18)
PathBar.TextXAlignment = Enum.TextXAlignment.Left
PathBar.Font = Enum.Font.Gotham
PathBar.TextSize = 12
PathBar.TextColor3 = Color3.fromRGB(200,200,200)
PathBar.BackgroundTransparency = 1
PathBar.ClipsDescendants = true

-- ================= Search =================
local Search = Instance.new("TextBox", Main)
Search.Position = UDim2.fromOffset(10,56)
Search.Size = UDim2.new(1,-20,0,28)
Search.PlaceholderText = "Search"
Search.ClearTextOnFocus = false
Search.BackgroundColor3 = Color3.fromRGB(30,30,30)
Search.TextColor3 = Color3.new(1,1,1)
Search.BorderSizePixel = 0
Instance.new("UICorner", Search)

-- ================= Navigation =================
local Back = Instance.new("TextButton", Main)
Back.Position = UDim2.fromOffset(10,90)
Back.Size = UDim2.fromOffset(80,26)
Back.Text = "⬅ Back"
Back.BackgroundColor3 = Color3.fromRGB(40,40,40)
Back.TextColor3 = Color3.new(1,1,1)
Back.BorderSizePixel = 0
Instance.new("UICorner", Back)

local NextRoot = Instance.new("TextButton", Main)
NextRoot.Position = UDim2.fromOffset(100,90)
NextRoot.Size = UDim2.fromOffset(140,26)
NextRoot.Text = "Next Root ▶"
NextRoot.BackgroundColor3 = Color3.fromRGB(40,40,40)
NextRoot.TextColor3 = Color3.new(1,1,1)
NextRoot.BorderSizePixel = 0
Instance.new("UICorner", NextRoot)

-- ================= Explorer List =================
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Position = UDim2.fromOffset(10,124)
Scroll.Size = UDim2.new(1,-20,1,-134)
Scroll.CanvasSize = UDim2.new()
Scroll.BorderSizePixel = 0
Scroll.ScrollBarImageTransparency = 0.3
Scroll.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,6)

-- ================= Properties Panel =================
local Props = Instance.new("Frame", ScreenGui)
Props.Size = UDim2.fromOffset(260,540)
Props.BackgroundColor3 = Color3.fromRGB(18,18,18)
Props.BorderSizePixel = 0
Props.Visible = false
Instance.new("UICorner", Props)
Instance.new("UIStroke", Props).Color = Color3.fromRGB(80,80,80)

local PropTitle = Instance.new("TextLabel", Props)
PropTitle.Size = UDim2.new(1,-10,0,30)
PropTitle.Position = UDim2.fromOffset(5,5)
PropTitle.BackgroundTransparency = 1
PropTitle.Font = Enum.Font.GothamBold
PropTitle.TextSize = 14
PropTitle.TextColor3 = Color3.new(1,1,1)
PropTitle.TextXAlignment = Enum.TextXAlignment.Left

local PropList = Instance.new("ScrollingFrame", Props)
PropList.Position = UDim2.fromOffset(5,40)
PropList.Size = UDim2.new(1,-10,1,-45)
PropList.BorderSizePixel = 0
PropList.ScrollBarImageTransparency = 0.3
PropList.BackgroundTransparency = 1

local PropLayout = Instance.new("UIListLayout", PropList)
PropLayout.Padding = UDim.new(0,4)

-- ================= Dock + Tween =================
local function updatePropsPosition()
	Props.Position = Main.Position + UDim2.fromOffset(Main.AbsoluteSize.X + 8, 0)
end

Main:GetPropertyChangedSignal("Position"):Connect(updatePropsPosition)

local function tweenProps(show)
	updatePropsPosition()
	local tween = TweenService:Create(
		Props,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = Props.Position}
	)
	if show then Props.Visible = true end
	tween:Play()
	if not show then
		tween.Completed:Once(function()
			Props.Visible = false
		end)
	end
end

-- ================= Property Groups =================
local PROPERTY_GROUPS = {
	Appearance = {"Transparency","Reflectance","Color","Material","BrickColor","CastShadow"},
	Collision = {"CanCollide","CanTouch","CanQuery","CollisionGroup","Massless"},
	Transform = {"Position","Orientation","Size","Velocity","AssemblyLinearVelocity"},
	Data = {"Name","ClassName","Parent","Archivable"},
}

-- ================= Properties =================
local function showProperties(inst)
	if PropertiesOpenFor == inst then
		PropertiesOpenFor = nil
		tweenProps(false)
		clearHighlights()
		return
	end

	PropertiesOpenFor = inst
	clearHighlights()
	highlight(inst)

	for _,c in ipairs(PropList:GetChildren()) do
		if c:IsA("TextLabel") then c:Destroy() end
	end

	PropTitle.Text = inst.Name.." ["..inst.ClassName.."]"

	local function header(text)
		local h = Instance.new("TextLabel", PropList)
		h.Size = UDim2.new(1,-6,0,22)
		h.Text = text
		h.Font = Enum.Font.GothamBold
		h.TextSize = 14
		h.TextColor3 = Color3.new(1,1,1)
		h.BackgroundTransparency = 1
		h.TextXAlignment = Enum.TextXAlignment.Left
	end

	local function add(text)
		local l = Instance.new("TextLabel", PropList)
		l.Size = UDim2.new(1,-6,0,20)
		l.TextWrapped = true
		l.Text = text
		l.Font = Enum.Font.Gotham
		l.TextSize = 13
		l.TextColor3 = Color3.fromRGB(210,210,210)
		l.BackgroundTransparency = 1
		l.TextXAlignment = Enum.TextXAlignment.Left
	end

	for group, list in pairs(PROPERTY_GROUPS) do
		header(group)
		for _,prop in ipairs(list) do
			local ok,val = pcall(function() return inst[prop] end)
			if ok then add(prop.." = "..tostring(val)) end
		end
	end

	task.wait()
	PropList.CanvasSize = UDim2.fromOffset(0,PropLayout.AbsoluteContentSize.Y + 8)
	tweenProps(true)
end

-- ================= Helpers =================
local function updatePath()
	PathBar.Text = current:GetFullName():gsub("%.", " → ")
end

local function disconnectAll()
	for _,c in ipairs(connections) do c:Disconnect() end
	table.clear(connections)
end

-- ================= Refresh =================
local function refresh()
	disconnectAll()
	updatePath()

	for _,c in ipairs(Scroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end

	local q = Search.Text:lower()

	for _,child in ipairs(current:GetChildren()) do
		if q == "" or child.Name:lower():find(q,1,true) then
			local b = Instance.new("TextButton", Scroll)
			b.Size = UDim2.new(1,-6,0,30)
			b.Text = child.Name.."  ["..child.ClassName.."]"
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.BackgroundColor3 = Color3.fromRGB(35,35,35)
			b.TextColor3 = Color3.new(1,1,1)
			b.BorderSizePixel = 0
			Instance.new("UICorner", b)

			b.MouseButton1Click:Connect(function()
				table.insert(history,current)
				current = child
				Search.Text = ""
				refresh()
			end)

			b.MouseButton2Click:Connect(function()
				showProperties(child)
			end)
		end
	end

	Scroll.CanvasSize = UDim2.fromOffset(0,Layout.AbsoluteContentSize.Y + 6)

	table.insert(connections, current.ChildAdded:Connect(refresh))
	table.insert(connections, current.ChildRemoved:Connect(refresh))
end

-- ================= Controls =================
Search:GetPropertyChangedSignal("Text"):Connect(refresh)

Back.MouseButton1Click:Connect(function()
	if #history > 0 then
		current = table.remove(history)
	else
		currentRootIndex = (currentRootIndex - 2) % #ROOTS + 1
		current = ROOTS[currentRootIndex]
	end
	refresh()
end)

NextRoot.MouseButton1Click:Connect(function()
	history = {}
	currentRootIndex = currentRootIndex % #ROOTS + 1
	current = ROOTS[currentRootIndex]
	refresh()
end)

Minimize.MouseButton1Click:Connect(function()
	Main.Visible = false
	Props.Visible = false
	clearHighlights()
end)

Close.MouseButton1Click:Connect(function()
	clearHighlights()
	ScreenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightAlt then
		Main.Visible = not Main.Visible
		if not Main.Visible then
			Props.Visible = false
			clearHighlights()
		end
	end
end)

-- ================= Start =================
refresh()
