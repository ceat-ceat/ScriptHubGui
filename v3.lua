-- ceat_ceat
-- ceat#6144
-- inspired by geometry dash megahack

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local VERSION = "indev 3-21-2023-4"
local MAIN_COLOR = Color3.fromRGB(255, 123, 62)

local shared = getfenv().getgenv and getfenv().getgenv() or _G

if shared.scripthub then
	return shared.scripthub
end

local uis = game:GetService("UserInputService")
local startergui = game:GetService("StarterGui")
local runservice = game:GetService("RunService")

local bindableevent

if runservice:IsStudio() then
	bindableevent = require(script.BindableEvent)
else
	bindableevent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ceat-ceat/roblox-script-utils/main/fakebindable.lua", true))()
end

-- grahhh

local FONT_FAMILIES = {}

for _, v in Enum.Font:GetEnumItems() do
	if v == Enum.Font.Unknown then
		continue
	end
	
	local font = Font.fromEnum(v)
	FONT_FAMILIES[v] = font.Family
end

-- main gui

local screengui = Instance.new("ScreenGui")
screengui.Name = "ScriptHub"
screengui.IgnoreGuiInset = true
screengui.ResetOnSpawn = false
screengui.Enabled = false

local maincontainer = Instance.new("Frame", screengui)
maincontainer.BackgroundTransparency = 1
maincontainer.Position = UDim2.new(0, 10, 0, 46)
maincontainer.Size = UDim2.new(0, 150, 0, 25)
maincontainer.ZIndex = 2
maincontainer.Name = "MainContainer"

local mainuilistlayout = Instance.new("UIListLayout", maincontainer)
mainuilistlayout.Padding = UDim.new(0, 10)
mainuilistlayout.FillDirection = Enum.FillDirection.Horizontal
mainuilistlayout.SortOrder = Enum.SortOrder.Name

local darkbackground = Instance.new("Frame", screengui)
darkbackground.BackgroundColor3 = Color3.new()
darkbackground.BackgroundTransparency = 0.5
darkbackground.BorderSizePixel = 0
darkbackground.Size = UDim2.new(1, 0, 1, 0)
darkbackground.ZIndex = 0
darkbackground.Name = "Background"

local versionlabel = Instance.new("TextLabel", darkbackground)
versionlabel.AnchorPoint = Vector2.new(1, 1)
versionlabel.BackgroundTransparency = 1
versionlabel.Position = UDim2.new(1, -10, 1, -10)
versionlabel.Size = UDim2.new(0, 200, 0, 200)
versionlabel.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham], Enum.FontWeight.Medium)
versionlabel.Text = `ScriptHubv3\nversion {VERSION}`
versionlabel.TextColor3 = Color3.new(1, 1, 1)
versionlabel.TextSize = 14
versionlabel.TextTransparency = 0.75
versionlabel.TextXAlignment = Enum.TextXAlignment.Right
versionlabel.TextYAlignment = Enum.TextYAlignment.Bottom

if getfenv().getgenv then
	screengui.Parent = game:GetService("CoreGui")
else
	screengui.Parent = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

--

function typecheck(any, datatype, argnum)
	local matches = typeof(any) == datatype
	local expectedtext = datatype
	
	if typeof(datatype) == "table" then
		matches = table.find(datatype, typeof(any)) ~= nil
		expectedtext = table.concat(datatype, ", ")
	end
	
	assert(matches, `invalid argument #{argnum} ({expectedtext} expected, got {typeof(any)})`)
end

function guitypecheck(any, class, argnum)
	typecheck(any, "table", argnum)
	assert(any._priv, `invalid argument #{argnum}, must be a scripthub object`)
	
	local matches = any._priv.ClassName == class
	local expectedtext = class

	if typeof(class) == "table" then
		matches = table.find(class, any._priv.ClassName) ~= nil
		expectedtext = table.concat(class, ", ")
	end
	
	assert(matches, `invalid argument #{argnum} ({expectedtext} expected, got {any._priv.ClassName})`)
end

function metamethods(classtable, class)
	local function __index(self, idx)
		if classtable[idx] then
			return classtable[idx]
		end
		assert(table.find(classtable.ReadableProperties, idx), `'{idx}' is not a valid member of {class} '{self._priv.Name}'`)
		return self._priv[idx]
	end
	
	local function __newindex(self, idx, value)
		assert(table.find(classtable.ReadableProperties, idx), `'{idx}' is not a valid member of {class} '{self._priv.Name}'`)
		assert(classtable.PropertySet[idx], `'{idx}' is read only`)
		
		if self._priv[idx] == value then
			return
		end
		classtable.PropertySet[idx](self, self._priv[idx], value)
	end
	
	local function __tostring(self)
		return `{class} {self._priv.Name}`
	end
	
	return __index, __newindex, __tostring
end

-- classes

-- base element
local elementbase = {}

elementbase.ReadableProperties = {
	"Name",
	"ClassName",
	"LayoutOrder",
	"Parent",
}

elementbase.PropertySet = {
	Name = function(self, oldname, name)
		typecheck(name, "string", 1)
		if self._priv.Parent then
			assert(not self._priv.Parent._priv.Elements[name], `ScriptGui {self._priv.Parent._priv.Name} already has Element {name}`)
		end
		
		self._priv.Name = name
		self._priv.Gui.Label.Text = name
		self._priv.Gui.Frame.Name = name
		
		if self._priv.Parent then
			self._priv.Parent._priv.Elements[name] = self
			self._priv.Parent._priv.Elements[oldname] = nil
		end
	end,
	LayoutOrder = function(self, _, layoutorder)
		typecheck(layoutorder, "number", 1)
		self._priv.LayoutOrder = layoutorder
		self._priv.Gui.Frame.LayoutOrder = layoutorder
	end,
	Parent = function(self, oldparent, parent)
		assert(not self._priv.IsMainCategory, "cannot change Parent of the main category")

		if parent == nil then
			self._priv.Parent = nil
			self._priv.Gui.Frame.Parent = nil
			if oldparent then
				oldparent._priv.Elements[self._priv.Name] = nil
			end
			return
		end

		guitypecheck(parent, {"ScriptGui", "Category", "ListElement"}, 1)
		if parent._priv.ClassName == "ScriptGui" then
			parent = parent._priv.MainCategory
		end
		assert(not parent._priv.Elements[self._priv.Name], `destination Category has an Element that collides with this {self._priv.Name}`)

		self._priv.Parent = parent
		parent._priv.Elements[self._priv.Name] = self

		if oldparent then
			oldparent._priv.Elements[self._priv.Name] = nil
		end

		self._priv.Gui.Frame.Parent = parent._priv.Gui.ElementContainer
	end,
}

function elementbase.addbaseproperties(t)
	return table.move(elementbase.ReadableProperties, 1, #elementbase.ReadableProperties, #t + 1, t)
end

function elementbase.new(labelclass)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 25)
	frame.LayoutOrder = 0
	
	local label = Instance.new(labelclass, frame)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 5, 0, 0)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham], Enum.FontWeight.Medium)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Name = "Label"
	
	return frame
end

-- boolean

local booleanelement = {}
booleanelement.__index, booleanelement.__newindex, booleanelement.__tostring = metamethods(booleanelement, "BooleanElement")

booleanelement.ReadableProperties = elementbase.addbaseproperties({
	"Value",
	"ValueChanged"
})

booleanelement.PropertySet = {
	Name = elementbase.PropertySet.Name,
	LayoutOrder = elementbase.PropertySet.LayoutOrder,
	Parent = elementbase.PropertySet.Parent,
	Value = function(self, _, value)
		typecheck(value, "boolean", 1)
		self._priv.Value = not value
		
		local color = value and MAIN_COLOR or Color3.new(1, 1, 1)
		self._priv.Gui.Indicator.BackgroundColor3 = color
		self._priv.Gui.Label.TextColor3 = color
		self._priv.ValueChangedEvent:Fire(value)
	end,
}

function booleanelement:Destroy()
	for _, c in self._priv.Connections do
		c:Disconnect()
	end
	
	self._priv.ValueChangedEvent:Destroy()
	
	for _, v in self._priv.Gui do
		v:Destroy()
	end
	
	if self._priv.Parent then
		self._priv.Parent._priv.Elements[self._priv.Name] = nil
	end
end

function booleanelement.new()
	local new = setmetatable({
		_priv = {
			Name = "Boolean",
			ClassName = "BooleanElement",
			Parent = nil,
			Value = false,
			Gui = {},
			Connections = {},
		}
	}, booleanelement)
	
	local frame = elementbase.new("TextButton")
	frame.Label.Text = "Boolean"
	
	local indicator = Instance.new("Frame", frame)
	indicator.AnchorPoint = Vector2.new(1, 0)
	indicator.BackgroundColor3 = Color3.new(1, 1, 1)
	indicator.BorderSizePixel = 0
	indicator.Position = UDim2.new(1, -5, 0, 3)
	indicator.Size = UDim2.new(0, 3, 1, -6)
	indicator.Name = "Indicator"
	
	new._priv.Gui.Frame = frame
	new._priv.Gui.Label = frame.Label
	new._priv.Gui.Indicator = indicator
	
	new._priv.ValueChangedEvent = bindableevent.new()
	new._priv.ValueChanged = new._priv.ValueChangedEvent.Event
	
	new._priv.Connections.ButtonClicked = frame.Label.MouseButton1Click:Connect(function()
		new._priv.Value = not new._priv.Value
		
		local color = new._priv.Value and MAIN_COLOR or Color3.new(1, 1, 1)
		new._priv.Gui.Indicator.BackgroundColor3 = color
		new._priv.Gui.Label.TextColor3 = color
		
		new._priv.ValueChangedEvent:Fire(new._priv.Value)
	end)
	
	return new
end

-- string element

local stringelement = {}
stringelement.__index, stringelement.__newindex, stringelement.__tostring = metamethods(stringelement, "StringElement")

stringelement.ReadableProperties = elementbase.addbaseproperties({
	"Value",
	"ValueChanged",
	"PlaceholderText"
})

stringelement.PropertySet = {
	Name = elementbase.PropertySet.Name,
	LayoutOrder = elementbase.PropertySet.LayoutOrder,
	Parent = elementbase.PropertySet.Parent,
	Value = function(self, _, value)
		typecheck(value, "string", 1)
		self._priv.Gui.TextBox.Text = value
	end,
	PlaceholderText = function(self, _, text)
		typecheck(text, "string", 1)
		self._priv.PlaceholderText = text
		self._priv.Gui.TextBox.PlaceholderText = text
	end,
}

function stringelement:Destroy()
	for _, c in self._priv.Connections do
		c:Disconnect()
	end
	
	self._priv.ValueChangedEvent:Destroy()
	
	for _, v in self._priv.Gui do
		v:Destroy()
	end
end

function stringelement.new()
	local new = setmetatable({
		_priv = {
			Name = "String",
			ClassName = "StringElement",
			LayoutOrder = 0,
			Parent = nil,
			Value = "",
			PlaceholderText = "",
			Gui = {},
			Connections = {}
		}	
	}, stringelement)
	
	local frame = elementbase.new("TextLabel")
	frame.Label.Text = "String"
	
	local textbox = Instance.new("TextBox", frame)
	textbox.AnchorPoint = Vector2.new(1, 0)
	textbox.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	textbox.BorderSizePixel = 0
	textbox.Position = UDim2.new(1, -5, 0, 3)
	textbox.Size = UDim2.new(0.5, 0, 1, -6)
	textbox.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham], Enum.FontWeight.Regular)
	textbox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	textbox.PlaceholderText = ""
	textbox.Text = ""
	textbox.TextColor3 = Color3.new(1, 1, 1)
	textbox.TextSize = 12
	
	new._priv.Gui.Frame = frame
	new._priv.Gui.Label = frame.Label
	new._priv.Gui.TextBox = textbox
	
	new._priv.ValueChangedEvent = bindableevent.new()
	new._priv.ValueChanged = new._priv.ValueChangedEvent.Event
	
	new._priv.Connections.TextChanged = textbox:GetPropertyChangedSignal("Text"):Connect(function()
		new._priv.Value = textbox.Text
		new._priv.ValueChangedEvent:Fire(textbox.Text)
	end)
	
	return new
end

-- number element

local numberelement = {}
numberelement.__index, numberelement.__newindex, numberelement.__tostring = metamethods(numberelement, "NumberElement")

numberelement.ReadableProperties = elementbase.addbaseproperties({
	"Value",
	"ValueChanged",
	"PlaceholderText"
})

numberelement.PropertySet = {
	Name = elementbase.PropertySet.Name,
	LayoutOrder = elementbase.PropertySet.LayoutOrder,
	Parent = elementbase.PropertySet.Parent,
	Value = function(self, _, value)
		typecheck(value, "number", 1)
		self._priv.Value = value
		self._priv.Gui.TextBox.Text = tonumber(value)
	end,
	PlaceholderText = stringelement.PropertySet.PlaceholderText
}

function numberelement:Destroy()
	for _, c in self._priv.Connections do
		c:Disconnect()
	end

	self._priv.ValueChangedEvent:Destroy()

	for _, v in self._priv.Gui do
		v:Destroy()
	end
end

function numberelement.new()
	local new = setmetatable({
		_priv = {
			Name = "Number",
			ClassName = "NumberElement",
			LayoutOrder = 0,
			Parent = nil,
			Value = 0,
			PlaceholderText = "",
			Gui = {},
			Connections = {}
		}	
	}, numberelement)

	local frame = elementbase.new("TextLabel")
	frame.Label.Text = "Number"

	local textbox = Instance.new("TextBox", frame)
	textbox.AnchorPoint = Vector2.new(1, 0)
	textbox.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	textbox.BorderSizePixel = 0
	textbox.Position = UDim2.new(1, -5, 0, 3)
	textbox.Size = UDim2.new(0.5, 0, 1, -6)
	textbox.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham], Enum.FontWeight.Regular)
	textbox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	textbox.PlaceholderText = ""
	textbox.Text = ""
	textbox.TextColor3 = Color3.new(1, 1, 1)
	textbox.TextSize = 12

	new._priv.Gui.Frame = frame
	new._priv.Gui.Label = frame.Label
	new._priv.Gui.TextBox = textbox

	new._priv.ValueChangedEvent = bindableevent.new()
	new._priv.ValueChanged = new._priv.ValueChangedEvent.Event

	new._priv.Connections.FocusLost = textbox.FocusLost:Connect(function()
		if textbox.Text == new._priv.Value then
			return
		end
		
		if not tonumber(textbox.Text) then
			textbox.Text = new._priv.Value
		end
		
		new._priv.Value = tonumber(textbox.Text)
		new._priv.ValueChangedEvent:Fire(tonumber(textbox.Text))
	end)

	return new
end

-- keybind element

local keybindelement = {}
keybindelement.__index, keybindelement.__newindex, keybindelement.__tostring = metamethods(keybindelement, "KeybindElement")

keybindelement.ReadableProperties = elementbase.addbaseproperties({
	"Value",
	"ValueChanged",
	"SelectionBegan",
	"SelectionEnded"
})

keybindelement.PropertySet = {
	Name = elementbase.PropertySet.Name,
	LayoutOrder = elementbase.PropertySet.LayoutOrder,
	Parent = elementbase.PropertySet.Parent,
	Value = function(self, _, key)
		typecheck(key, "EnumItem", 1)
		assert(key.EnumType == Enum.KeyCode, "Value must be a KeyCode")
		
		self._priv.Value = key
		self._priv.Gui.Button.Text = keybindelement.getkeytext(key)
		self._priv.ValueChangedEvent:Fire(key)
	end,
}

function keybindelement:Destroy()
	for _, c in self._priv.Connections do
		c:Disconnect()
	end

	self._priv.ValueChangedEvent:Destroy()
	self._priv.SelectionBeganEvent:Destroy()
	self._priv.SelectionEndedEvent:Destroy()

	for _, v in self._priv.Gui do
		v:Destroy()
	end
end

local KEY_TEXT_OVERRIDES = {
	[Enum.KeyCode.Tab] = "Tab",
	[Enum.KeyCode.Return] = "Enter",
	[Enum.KeyCode.Space] = "Space",
	[Enum.KeyCode.Delete] = "Delete",
	[Enum.KeyCode.Escape] = "Escape",
	[Enum.KeyCode.Pause] = "Pause",
	[Enum.KeyCode.Unknown] = "Unknown"
}

function keybindelement.getkeytext(keycode)
	if KEY_TEXT_OVERRIDES[keycode] then
		return KEY_TEXT_OVERRIDES[keycode]
	end
	
	local validchar, name = pcall(string.char, keycode.Value)
	if validchar then
		return name:upper()
	end
	
	return keycode.Name
end

function keybindelement.new()
	local new = setmetatable({
		_priv = {
			Name = "Keybind",
			ClassName = "KeybindElement",
			LayoutOrder = 0,
			Parent = nil,
			Value = Enum.KeyCode.Unknown,
			IsSelecting = false,
			Gui = {},
			Connections = {}
		}	
	}, keybindelement)

	local frame = elementbase.new("TextLabel")
	frame.Label.Text = "Keybind"

	local button = Instance.new("TextButton", frame)
	button.AnchorPoint = Vector2.new(1, 0)
	button.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(1, -5, 0, 3)
	button.Size = UDim2.new(0.5, 0, 1, -6)
	button.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham], Enum.FontWeight.Regular)
	button.Text = "Unknown"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 12

	new._priv.Gui.Frame = frame
	new._priv.Gui.Label = frame.Label
	new._priv.Gui.Button = button

	new._priv.ValueChangedEvent = bindableevent.new()
	new._priv.ValueChanged = new._priv.ValueChangedEvent.Event
	
	new._priv.SelectionBeganEvent = bindableevent.new()
	new._priv.SelectionBegan = new._priv.SelectionBeganEvent.Event
	
	new._priv.SelectionEndedEvent = bindableevent.new()
	new._priv.SelectionEnded = new._priv.SelectionEndedEvent.Event

	new._priv.Connections.Button1Clicked = button.MouseButton1Click:Connect(function()
		if new._priv.IsSelecting then
			return
		end
		
		new._priv.IsSelecting = true
		new._priv.Gui.Button.Text = "Press any key"
		
		new._priv.SelectionBeganEvent:Fire()
		
		local input
		repeat
			input = uis.InputBegan:Wait()
		until input.UserInputType == Enum.UserInputType.Keyboard
		
		new._priv.Value = input.KeyCode
		new._priv.Gui.Button.Text = keybindelement.getkeytext(input.KeyCode)
		new._priv.ValueChangedEvent:Fire(input.KeyCode)
		
		task.wait()
		new._priv.SelectionEndedEvent:Fire()
		new._priv.IsSelecting = false
	end)

	return new
end

-- boolean

local buttonelement = {}
buttonelement.__index, buttonelement.__newindex, buttonelement.__tostring = metamethods(buttonelement, "ButtonElement")

buttonelement.ReadableProperties = elementbase.addbaseproperties({
	"Text",
	"OnClick"
})

buttonelement.PropertySet = {
	Name = elementbase.PropertySet.Name,
	LayoutOrder = elementbase.PropertySet.LayoutOrder,
	Parent = elementbase.PropertySet.Parent,
	Text = function(self, _, text)
		typecheck(text, "string", 1)
		self._priv.Text = text
		self._priv.Gui.Button.Text = text
	end,
}

function buttonelement:Destroy()
	for _, c in self._priv.Connections do
		c:Disconnect()
	end

	self._priv.OnClickEvent:Destroy()

	for _, v in self._priv.Gui do
		v:Destroy()
	end

	if self._priv.Parent then
		self._priv.Parent._priv.Elements[self._priv.Name] = nil
	end
end

function buttonelement.new()
	local new = setmetatable({
		_priv = {
			Name = "Button",
			ClassName = "ButtonElement",
			Parent = nil,
			Text = "",
			Gui = {},
			Connections = {},
		}
	}, buttonelement)

	local frame = elementbase.new("TextLabel")
	frame.Label.Text = "Button"

	local button = Instance.new("TextButton", frame)
	button.AutomaticSize = Enum.AutomaticSize.X
	button.AnchorPoint = Vector2.new(1, 0)
	button.BackgroundColor3 = Color3.new(1, 1, 1)
	button.BorderSizePixel = 0
	button.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham])
	button.Position = UDim2.new(1, -5, 0, 3)
	button.Size = UDim2.new(0, 10, 1, -6)
	button.Text = ""
	button.TextSize = 12
	button.Name = "Indicator"
	
	local uipadding = Instance.new("UIPadding", button)
	uipadding.PaddingLeft = UDim.new(0, 5)
	uipadding.PaddingRight = UDim.new(0, 5)

	new._priv.Gui.Frame = frame
	new._priv.Gui.Label = frame.Label
	new._priv.Gui.Button = button
	new._priv.Gui.UIPadding = uipadding

	new._priv.OnClickEvent = bindableevent.new()
	new._priv.OnClick = new._priv.OnClickEvent.Event

	new._priv.Connections.ButtonClicked = button.MouseButton1Click:Connect(function()
		new._priv.OnClickEvent:Fire()
	end)

	return new
end

-- list element

local listelement = {}
listelement.__index, listelement.__newindex, listelement.__tostring = metamethods(listelement, "ListElement")

listelement.ReadableProperties = elementbase.addbaseproperties({
	"Elements",
	"SortOrder"
})

listelement.PropertySet = {
	Name = elementbase.PropertySet.Name,
	LayoutOrder = elementbase.PropertySet.LayoutOrder,
	Parent = elementbase.PropertySet.Parent,
	SortOrder = function(self, _, sortorder)
		typecheck(sortorder, "EnumItem", 1)
		assert(sortorder == Enum.SortOrder.Name or sortorder == Enum.SortOrder.LayoutOrder, "SortOrder must be Name or LayoutOrder")

		self._priv.SortOrder = sortorder
		self._priv.Gui.ElementUIListLayout.SortOrder = sortorder
	end,
}

function listelement:Destroy()
	for _, c in self._priv.Connections do
		c:Disconnect()
	end
	
	for _, v in self._priv.Elements do
		v:Destroy()
	end

	for _, v in self._priv.Gui do
		v:Destroy()
	end
end

function listelement.new()
	local new = setmetatable({
		_priv = {
			Name = "List",
			ClassName = "ListElement",
			LayoutOrder = 0,
			SortOrder = Enum.SortOrder.Name,
			Parent = nil,
			IsOpen = false,
			Gui = {},
			Elements = {},
			Connections = {}
		}	
	}, keybindelement)
	
	local frame = elementbase.new("TextButton")
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Label.Text = "List"
	
	local topcontainer = Instance.new("Frame", frame)
	topcontainer.BackgroundTransparency = 1
	topcontainer.Size = UDim2.new(1, 0, 0, 25)
	topcontainer.LayoutOrder = 0
	topcontainer.Name = "TopContainer"
	
	local arrow = Instance.new("ImageLabel", topcontainer)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.BackgroundTransparency = 1
	arrow.Position = UDim2.new(1, -5, 0, 3)
	arrow.Size = UDim2.new(0, 10, 1, -6)
	arrow.Image = "rbxassetid://4430392611"
	arrow.ScaleType = Enum.ScaleType.Fit
	
	frame.Label.Parent = topcontainer
	
	local elementcontainer = Instance.new("Frame", frame)
	elementcontainer.AutomaticSize = Enum.AutomaticSize.Y
	elementcontainer.BackgroundTransparency = 0.4
	elementcontainer.BackgroundColor3 = Color3.new()
	elementcontainer.BorderSizePixel = 0
	elementcontainer.Size = UDim2.new(1, 0, 0, 25)
	elementcontainer.LayoutOrder = 1
	elementcontainer.Visible = false
	elementcontainer.Name = "ElementContainer"
	
	local uilistlayout = Instance.new("UIListLayout", frame)
	uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local uilistlayout2 = Instance.new("UIListLayout", elementcontainer)
	uilistlayout2.SortOrder = Enum.SortOrder.Name
	
	new._priv.Gui.Frame = frame
	new._priv.Gui.Label = topcontainer.Label
	new._priv.Gui.Arrow = arrow
	new._priv.Gui.ElementContainer = elementcontainer
	new._priv.Gui.UIListLayout = uilistlayout
	new._priv.Gui.ElementUIListLayout = uilistlayout2
	
	new._priv.Connections.MouseClicked = topcontainer.Label.MouseButton1Click:Connect(function()
		new._priv.IsOpen = not new._priv.IsOpen
		new._priv.Gui.ElementContainer.Visible = new._priv.IsOpen
		new._priv.Gui.Arrow.Rotation = new._priv.IsOpen and 180 or 0
		
		local color = new._priv.IsOpen and MAIN_COLOR or Color3.new(1, 1, 1)
		new._priv.Gui.Label.TextColor3 = color
		arrow.ImageColor3 = color
	end)

	return new
end

-- category
local category = {}
category.__index, category.__newindex, category.__tostring = metamethods(category, "Category")

category.ReadableProperties = {
	"Name",
	"ClassName",
	"SortOrder",
	"LayoutOrder",
	"Parent",
	"Elements"
}

category.PropertySet = {
	Name = function(self, oldname, name)
		assert(not self._priv.IsMainCategory, "cannot change Name of the main category")
		typecheck(name, "string", 1)
		if self._priv.Parent then
			assert(not self._priv.Parent._priv.Categories[name], `ScriptGui {self._priv.Parent._priv.Name} already has Category {name}`)
		end
		
		self._priv.Name = name
		
		if self._priv.IsMainCategory then
			self._priv.Gui.Container.Name = `!{name}`
		else
			self._priv.Gui.Container.Name = `1{name}`
		end
		
		self._priv.Gui.Title.Text = name
		
		if self._priv.Parent then
			self._priv.Parent._priv.Categories[name] = self
			self._priv.Parent._priv.Categories[oldname] = nil
		end
	end,
	SortOrder = function(self, _, sortorder)
		typecheck(sortorder, "EnumItem", 1)
		assert(sortorder == Enum.SortOrder.Name or sortorder == Enum.SortOrder.LayoutOrder, "SortOrder must be Name or LayoutOrder")

		self._priv.SortOrder = sortorder
		self._priv.Gui.ElementUIListLayout.SortOrder = sortorder
	end,
	LayoutOrder = function(self, _, layoutorder)
		assert(not self._priv.IsMainCategory, "cannot change LayoutOrder of the main category")
		layoutorder = tonumber(layoutorder)
		typecheck(layoutorder, "number", 1)
		assert(layoutorder > 0, "LayoutOrder cannot be less than 0")

		self._priv.LayoutOrder = layoutorder
		self._priv.Gui.Container.LayoutOrder = layoutorder + 1
	end,
	Parent = function(self, oldparent, parent)
		assert(not self._priv.IsMainCategory, "cannot change Parent of the main category")
		
		if parent == nil then
			self._priv.Parent = nil
			self._priv.Gui.Container.Parent = nil
			if oldparent then
				oldparent._priv.Categories[self._priv.Name] = nil
			end
			return
		end

		guitypecheck(parent, "ScriptGui", 1)
		assert(not parent._priv.Categories[self._priv.Name], `destination ScriptGui has a Category that collides with this {self._priv.Name}`)

		self._priv.Parent = parent
		parent._priv.Categories[self._priv.Name] = self
		
		if oldparent then
			oldparent._priv.Categories[self._priv.Name] = nil
		end
		
		self._priv.Gui.Container.Parent = parent._priv.Gui.Container
	end,
}

function category:_SetMainCategoryName(name)
	if self._priv.Parent then
		self._priv.Parent._priv.Categories[self._priv.Name] = nil
		self._priv.Parent._priv.Categories[name] = self
	end
	
	self._priv.Name = name
	self._priv.Gui.Title.Text = name
	self._priv.Gui.Container.Name = `!{name}`
end

function category:_SetIsMainCategory(bool)
	self._priv.IsMainCategory = bool
	if bool then
		self:_SetMainCategoryName(self._priv.Parent._priv.Name)
		self._priv.Gui.Container.LayoutOrder = 0
	else
		self._priv.Gui.Container.Name = `1{self._priv.Name}`
	end
end

function category:Destroy()
	for _, v in self._priv.Connections do
		v:Disconnect()
	end
	
	for _, v in self._priv.Gui do
		v:Destroy()
	end

	if self._priv.Parent then
		self._priv.Parent._priv.Categories[self._priv.Name] = nil
	end
end

function category.new()
	local new = setmetatable({
		_priv = {
			Name = "Category",
			ClassName = "Category",
			IsMainCategory = false,
			SortOrder = Enum.SortOrder.Name,
			IsOpen = true,
			LayoutOrder = 0,
			Parent = nil,
			Gui = {},
			Elements = {},
			Connections = {}
		}
	}, category)
	
	local container = Instance.new("Frame")
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, 0)
	container.Name = "1Category"
	
	local uilistlayout = Instance.new("UIListLayout", container)
	uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local uipadding = Instance.new("UIPadding", container)
	uipadding.PaddingBottom = UDim.new(0, 2)
	uipadding.PaddingLeft = UDim.new(0, 2)
	uipadding.PaddingRight = UDim.new(0, 2)
	uipadding.PaddingTop = UDim.new(0, 2)
	
	local title = Instance.new("TextButton", container)
	title.BackgroundColor3 = MAIN_COLOR
	title.BorderSizePixel = 0
	title.LayoutOrder = 0
	title.Size = UDim2.new(1, 0, 0, 25)
	title.FontFace = Font.new(FONT_FAMILIES[Enum.Font.Gotham], Enum.FontWeight.Bold)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 13
	title.Text = "Category"
	title.Name = "Title"
	
	local arrow = Instance.new("ImageLabel", title)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.BackgroundTransparency = 1
	arrow.Position = UDim2.new(1, -5, 0, 3)
	arrow.Rotation = 180
	arrow.Size = UDim2.new(0, 10, 1, -6)
	arrow.Image = "rbxassetid://4430392611"
	arrow.ScaleType = Enum.ScaleType.Fit
	
	local elementcontainer = Instance.new("Frame", container)
	elementcontainer.AutomaticSize = Enum.AutomaticSize.Y
	elementcontainer.BackgroundTransparency = 1
	elementcontainer.LayoutOrder = 1
	elementcontainer.Size = UDim2.new(1, 0, 0, 0)
	elementcontainer.Name = "ElementContainer"
	
	local uilistlayout2 = Instance.new("UIListLayout", elementcontainer)
	uilistlayout2.SortOrder = Enum.SortOrder.Name
	
	new._priv.Gui.Container = container
	new._priv.Gui.ElementContainer = elementcontainer
	new._priv.Gui.Title = title
	new._priv.Gui.Arrow = arrow
	new._priv.Gui.UIListLayout = uilistlayout
	new._priv.Gui.ElementUIListLayout = uilistlayout2
	new._priv.Gui.UIPadding = uipadding
	
	new._priv.Connections.MouseClick = title.MouseButton1Click:Connect(function()
		new._priv.IsOpen = not new._priv.IsOpen
		arrow.Rotation = new._priv.IsOpen and 180 or 0
		elementcontainer.Visible = new._priv.IsOpen
	end)

	return new
end

-- script gui
local scriptgui = {}
scriptgui.__index, scriptgui.__newindex, scriptgui.__tostring = metamethods(scriptgui, "ScriptGui")

scriptgui.ReadableProperties = {
	"Name",
	"ClassName",
	"SortOrder",
	"LayoutOrder",
	"MainCategory",
	"Categories"
}

scriptgui.PropertySet = {
	Name = function(self, _, name)
		typecheck(name, "string", 1)

		self._priv.Name = name
		self._priv.Gui.Container.Name = name
		self._priv.MainCategory:_SetMainCategoryName(name)
	end,
	SortOrder = function(self, _, sortorder)
		typecheck(sortorder, "EnumItem", 1)
		assert(sortorder == Enum.SortOrder.Name or sortorder == Enum.SortOrder.LayoutOrder, "SortOrder must be Name or LayoutOrder")

		self._priv.SortOrder = sortorder
		self._priv.Gui.UIListLayout.SortOrder = sortorder
	end,
	LayoutOrder = function(self, _, layoutorder)
		layoutorder = tonumber(layoutorder)
		typecheck(layoutorder, "number", 1)

		self._priv.LayoutOrder = layoutorder
	end,
}

function scriptgui:Destroy()
	for _, c in self._priv.Categories do
		c:Destroy()
	end
	
	for _, v in self._priv.Gui do
		v:Destroy()
	end
end

function scriptgui._new()
	local new = setmetatable({
		_priv = {
			Name = "ScriptGui",
			ClassName = "ScriptGui",
			SortOrder = Enum.SortOrder.Name,
			LayoutOrder = 0,
			MainCategory = nil,
			Gui = {},
			Categories = {}
		}
	}, scriptgui)
	
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	container.LayoutOrder = 0
	container.Name = "ScriptGui"
	
	local uilistlayout = Instance.new("UIListLayout", container)
	uilistlayout.Padding = UDim.new(0, 5)
	uilistlayout.SortOrder = Enum.SortOrder.Name
	
	new._priv.Gui.Container = container
	new._priv.Gui.UIListLayout = uilistlayout
	
	container.Parent = maincontainer
	
	return new
end

function scriptgui.new()
	local new = scriptgui._new()
	
	local maincategory = category.new()
	maincategory.Parent = new
	maincategory.Name = new._priv.Name
	maincategory:_SetIsMainCategory(true)
	new._priv.MainCategory = maincategory
	
	return new
end

-- open and close

local mainkeybind = Enum.KeyCode.Equals
local ignorekeybind = false

uis.InputBegan:Connect(function(input, gameprocessed)
	if gameprocessed then
		return
	end
	
	if ignorekeybind then
		return
	end
	
	if input.KeyCode ~= mainkeybind then
		return
	end
	
	screengui.Enabled = not screengui.Enabled
end)

startergui:SetCore("SendNotification", { Title = "ScriptHub", Text = "Press '=' to open" })

--

local scripthub = {}

local classes = {
	ScriptGui = scriptgui.new,
	Category = category.new,
	BooleanElement = booleanelement.new,
	StringElement = stringelement.new,
	NumberElement = numberelement.new,
	KeybindElement = keybindelement.new,
	ButtonElement = buttonelement.new,
	ListElement = listelement.new
}

function scripthub.new(class)
	assert(classes[class], `'{class}' is not a valid class`)
	return classes[class]()
end

-- main :]

local main = scripthub.new("ScriptGui")
main.Name = "ScriptHub"

local key = scripthub.new("KeybindElement")
key.Parent = main
key.Name = "Toggle"
key.Value = Enum.KeyCode.Equals

key.SelectionBegan:Connect(function()
	ignorekeybind = true
end)

key.SelectionEnded:Connect(function()
	ignorekeybind = false
end)

key.ValueChanged:Connect(function(k)
	mainkeybind = k
end)

shared.scripthub = scripthub
return scripthub
