--[[
-- i wanted to add a property thing that will fire a changed event when you change it via script by using __newindex in metatables but its doing weird shit so i cant :sanaecry:

ceat_ceat
ceat(mega stupid)jjjjjjjjj#6144

old script panel here:
- https://pastebin.com/BrRrbL5z

_G.becomefumopanel but better

i made this because the original script panel was pretty small
you can go take a look yourself by running it and just look at how small it in
in this version i basically made an interface thats not just all black and white and is more flexible
it just allows me to add more features to it easier and it has a bit more customization

run

	loadstring("https://raw.githubusercontent.com/ceat-ceat/stuff/main/scriptpanelv2.lua")()
	
to get _G.ScriptPanelv2 up and working

Changelog

changelog has moved, please go here instead

	https://github.com/ceat-ceat/ScriptPanelv2/blob/main/Changelog.txt

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/ceat-ceat/ScriptPanelv2/main/fake%20bindable.lua"))()
--require(script:WaitForChild("fakevent"))
local ts,plrs,ts2,uis,coregui,run = game:GetService("TweenService"),game:GetService("Players"),game:GetService("TextService"),game:GetService("UserInputService"),game:GetService("CoreGui"),game:GetService("RunService")

function create(class,prop)
	local inst = Instance.new(class)
	if prop then
		for i, v in next, prop do
			inst[i] = v
		end
	end
	return inst
end
function tween(inst,prop,dur,dir,eas)
	ts:Create(inst,TweenInfo.new(dur,eas or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),prop):Play()
end

if _G.ScriptPanelv2 then return end



-- setup



local openkeybind,scripts,open,selectingkeybind,scrollpos = Enum.KeyCode.BackSlash,{},true,false,0

local screengui = create("ScreenGui",{
	Parent = run:IsStudio() and plrs.LocalPlayer:FindFirstChildOfClass("PlayerGui") or coregui,
	Name = string.format("%s's Script Panel",plrs:GetNameFromUserIdAsync(145632006)),
	ResetOnSpawn = false
})
local frame = create("Frame",{
	Parent = screengui,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 20,0, 20),
	Size = UDim2.new(0, 150,0, 25),
	Name = "Start",
	ZIndex = 2,
})
local mainlist = create("UIListLayout",{
	Parent =  frame,
	Padding = UDim.new(0, 20),
	FillDirection = Enum.FillDirection.Horizontal
})

local screencover = create("ScrollingFrame",{
	Parent = screengui,
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0,0.5, 0),
	Size = UDim2.new(1, -40,1, -40),
	CanvasSize = UDim2.new(),
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.X,
	Name = "ScreenCover",
})

local keybindbutton = create("TextButton",{
	Parent = screengui,
	BackgroundColor3 = Color3.fromRGB(255, 148, 106),
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20,1, -20),
	Size = UDim2.new(0, 150,0, 25),
	Font = Enum.Font.Gotham,
	Text = "Current Keybind : [\\]",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 14
})

function changekeybind(key)
	openkeybind,keybindbutton.Text = key,string.format("Current Keybind: [%s]",key.Name)
	keybindbutton.Size = UDim2.new(0, keybindbutton.TextBounds.X+10,0, 25)
end

keybindbutton.MouseButton1Click:Connect(function()
	if selectingkeybind then return end
	selectingkeybind,keybindbutton.Text,keybindbutton.Size = true,"Press a key",UDim2.new(0, 84,0, 25)
	local key
	repeat
		key = uis.InputBegan:Wait()
	until key.KeyCode ~= Enum.KeyCode.Unknown
	changekeybind(key.KeyCode)
	wait()
	selectingkeybind = false
end)

--[[frame.ChildAdded:Connect(function(inst)
	if inst:IsA("Frame") and not open then
		tween(inst.TextLabel,{Position=UDim2.new(math.random(-5,5), 0,0, screengui.AbsoluteSize.Y)},math.random(40,70)/75,Enum.EasingDirection.In)
	end
end)]]

uis.InputBegan:Connect(function(key,gp)
	if gp or selectingkeybind then return end
	if key.KeyCode == openkeybind then
		open = not open
		for i, v in next, scripts do
			tween(v.Frame,{Position=(open and UDim2.new() or UDim2.new(math.random(-500,500)/100, 0,0, screengui.AbsoluteSize.Y))},math.random(40,70)/75,not open and Enum.EasingDirection.In)
		end
		screencover.Visible = open
	end
end)

screengui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if not open then
		for i, v in next, scripts do
			tween(v.Frame,{Position=(open and UDim2.new() or UDim2.new(math.random(-5,5), 0,0, screengui.AbsoluteSize.Y))},math.random(40,70)/75,Enum.EasingDirection.InOut)
		end
	end
end)

run.RenderStepped:Connect(function(delta)
	frame.Position = UDim2.new(0, frame.Position.X.Offset+(20-screencover.CanvasPosition.X-frame.Position.X.Offset)*delta*50,0, 20)
end)

changekeybind(Enum.KeyCode.BackSlash)

-- itemtypes



function createbasicframe(text)
	local new = create("Frame",{
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0,0, 30),
		Name = text
	})
	create("TextLabel",{
		Parent = new,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10,0.5, 0),
		Size = UDim2.new(1, -10,1, 0),
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Name = "Label"
	})
	return new
end

local itemtypes = {
	String = function(params)
		local new,default = createbasicframe(params.Name),typeof(params.Default) == "string" and params.Default or ""
		local property = {Value=default}
		local textbox = create("TextBox",{
			Parent = new,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55),
			Position = UDim2.new(1, -5,0.5, 0),
			Size = UDim2.new(0, 50,0, 21),
			Font = Enum.Font.Gotham,
			Text = "",
			TextSize = 14,
			PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			PlaceholderText = default
		})
		local event = _G.FakeBindable.new()
		property.Changed = event.Event
		textbox.FocusLost:Connect(function()
			property.Value = (textbox.Text ~= "" and textbox.Text or default)
			textbox.Text = property.Value
			event:Fire(property.Value)
		end)
		return new,property
	end,
	Number = function(params)
		local new,default = createbasicframe(params.Name),tonumber(params.Default) or 0
		local property = {Value=default}
		local textbox = create("TextBox",{
			Parent = new,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55),
			Position = UDim2.new(1, -5,0.5, 0),
			Size = UDim2.new(0, 50,0, 21),
			Font = Enum.Font.Gotham,
			Text = "",
			TextSize = 14,
			PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			PlaceholderText = default
		})
		local event = _G.FakeBindable.new()
		property.Changed = event.Event
		textbox.FocusLost:Connect(function()
			property.Value = tonumber(textbox.Text) or default
			textbox.Text = property.Value
			event:Fire(property.Value)
		end)
		return new,property
	end,
	Boolean = function(params,otherdata)
		local new,default = createbasicframe(params.Name),((params.Default and typeof(params.Default) == "boolean") and params.Default or false)
		local property = {Value=default}
		local bar = create("Frame",{
			Parent = new,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -5,0.5, 0),
			Size = UDim2.new(0, 3,0, 21),
			BackgroundColor3 = (property.Value and otherdata.Color or Color3.fromRGB(255, 255, 255))
		})
		local button = create("TextButton",{
			Parent = new,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0,0.5, 0),
			Size = UDim2.new(1, -10,1, -10),
			Text = "",
			ZIndex = 2
		})
		local event = _G.FakeBindable.new()
		property.Changed = event.Event
		new.Label.TextColor3 = (property.Value and otherdata.Color or Color3.fromRGB(255, 255, 255))
		button.MouseButton1Click:Connect(function()
			property.Value = not property.Value
			local color = (property.Value and otherdata.Color or Color3.fromRGB(255, 255, 255))
			tween(bar,{BackgroundColor3 = color},0.3)
			tween(new.Label,{TextColor3 = color},0.3)
			event:Fire(property.Value)
		end)
		return new,property
	end,
	Button = function(params)
		local new,text = createbasicframe(params.Name),(params.Text and tostring(params.Text) or "")
		local button = create("TextButton",{
			Parent = new,
			AnchorPoint = Vector2.new(1, 0.5),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(1, -5,0.5, 0),
			Size = UDim2.new(0, math.max(ts2:GetTextSize(text,14,Enum.Font.Gotham,Vector2.new()).X+6,21),0, 21),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Text = text,
			TextColor3 = Color3.fromRGB(),
		})
		local event = _G.FakeBindable.new()
		button.MouseButton1Click:Connect(function()
			event:Fire()
		end)
		return new,{Click = event.Event}
	end,
	Keybind = function(params)
		local new,default = createbasicframe(params.Name),typeof(params.Default) == "EnumItem" and params.Default or Enum.KeyCode.E
		local property,changing = {Value=default},false
		local button = create("TextButton",{
			Parent = new,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55),
			Position = UDim2.new(1, -5,0.5, 0),
			Size = UDim2.new(0, 50,0, 21),
			Font = Enum.Font.Gotham,
			Text = default.Name,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
		})
		local event = _G.FakeBindable.new()
		property.Changed = event.Event
		button.MouseButton1Click:Connect(function()
			if changing then return end
			changing,button.Text,button.Size = true,"Press a key",UDim2.new(0, 80,0, 21)
			local key
			repeat
				key = uis.InputBegan:Wait()
			until key.KeyCode ~= Enum.KeyCode.Unknown
			button.Text,button.Size = key.KeyCode.Name,UDim2.new(0, math.max(ts2:GetTextSize(key.KeyCode.Name,14,Enum.Font.Gotham,Vector2.new()).X+6,50),0, 21)
			property.Value = key.KeyCode
			event:Fire(key.KeyCode)
			changing = false
		end)
		return new,property
	end,
}



-- functions



-- item functions



function additem(_frame,type,params,other)
	local itemtype = itemtypes[type]
	assert(itemtype,"Invalid item type")
	assert(params.Name and tostring(params.Name),"Name is required")
	local new,thing = itemtype(params,other)
	new.Parent,new.LayoutOrder,thing.ParentType = _frame,params.LayoutOrder or 0,other.ParentType
	return new,thing
end

local item = {}
item.__index = item

function item:Remove()
	local list,categorycontainer = self.Frame.Parent,self.ParentType == "Category" and self.Frame.Parent.Parent.Parent
	self.Frame:Destroy()
	list.Size = UDim2.new(1, 0,0, list.List.AbsoluteContentSize.Y)
	if categorycontainer then
		categorycontainer.Size = UDim2.new(1, 0,0, 25+list.List.AbsoluteContentSize.Y)
	end
	self = nil
end

function item.new(...)
	local new,thing = additem(...)
	thing.Frame = new
	return setmetatable(thing,item)
end



-- script category functions



local category = {}
category.__index = category

function category:AddItem(itemtype,params)
	assert(itemtype and tostring(itemtype),"Argument 1 invalid or nil")
	assert(self.Items[params.Name] == nil,string.format("Item name '%s' is taken",params.Name))
	local newitem = item.new(self.Frame.Frame.List,itemtype,params,{Color=self.Color,ParentType="Category"})
	self.Frame.Frame.List.Size = UDim2.new(1, 0,0, self.Frame.Frame.List.List.AbsoluteContentSize.Y)
	self.Frame.Size = UDim2.new(1, 0,0, 25+self.Frame.Frame.List.Size.Y.Offset)
	self.Items[params.Name] = newitem
	return newitem
end

function category:GetItem(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return self.Items[name]
end

function category:Remove()
	local list = self.Frame.Parent
	self.Frame:Destroy()
	list.Size = UDim2.new(1, 0,0, list.List.AbsoluteContentSize.Y)
	self = nil
end

function category.new(name,list,color,sort,layoutorder)
	local container = create("Frame",{
		Parent = list,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0,0, 25),
		Name = string.format("c_%s",name),
		LayoutOrder = layoutorder or 0
	})
	local label = create("TextLabel",{
		Parent = container,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0,0, 25),
		Font = Enum.Font.Gotham,
		Text = name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		Name = "Frame"
	})
	local listframe = create("Frame",{
		Parent = label,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0,0, 0),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Position = UDim2.new(0, 0,1, 0),
		Name = "List"
	})
	create("UIListLayout",{
		Parent = listframe,
		SortOrder = (sort == Enum.SortOrder.LayoutOrder or sort == Enum.SortOrder.Name) and sort or Enum.SortOrder.Name,
		Name = "List"
	})
	return setmetatable({Frame=container,Color=color,Items={}},category)
end


-- script functions



local newscript = {}
newscript.__index = newscript

function newscript:AddItem(itemtype,params)
	assert(itemtype and tostring(itemtype),"Argument 1 invalid or nil")
	assert(self.Items[params.Name] == nil,string.format("Item name '%s' is taken",params.Name))
	local newitem = item.new(self.Frame.InitialList.MainCategory,itemtype,params,{Color=self.Color,ParentType="Script"})
	self.Frame.InitialList.MainCategory.Size = UDim2.new(1, 0,0, self.Frame.InitialList.MainCategory.List.AbsoluteContentSize.Y)
	self.Items[params.Name] = newitem
	return newitem
end

function newscript:AddCategory(name,sort,layoutorder)
	assert(self.Categories[name] == nil,string.format("Category name '%s' is taken",name))
	local newcategory = category.new(name,self.Frame.InitialList,self.Color,sort,layoutorder)
	self.Categories[name] = newcategory
	return newcategory
end

function newscript:GetCategory(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return self.Categories[name]
end

function newscript:Remove()
	self.Container:Destroy()
	self = nil
end

function newscript.new(name,color,itemsort,categorysort)
	local new = create("Frame",{
		Parent = frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0,1, 0),
		Name = name
	})
	local label = create("TextLabel",{
		Parent = new,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.new(math.random(-500,500)/100, 0,0, screengui.AbsoluteSize.Y),
		Size = UDim2.new(0, 150,1, 0),
		Font = Enum.Font.Gotham,
		Text = name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
	})
	local firstlayerlist = create("Frame",{
		Parent = label,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0,1, 0),
		Size = UDim2.new(1, 0,0, 100),
		Name = "InitialList"
	})
	create("UIListLayout",{
		Parent = firstlayerlist,
		Padding = UDim.new(0, 10),
		SortOrder = (categorysort == Enum.SortOrder.LayoutOrder or categorysort == Enum.SortOrder.Name) and categorysort or Enum.SortOrder.Name,
		Name = "List"
	})
	local category1 = create("Frame",{
		Parent = firstlayerlist,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0,0, 0),
		Name = "MainCategory"
	})
	create("UIListLayout",{
		Parent = category1,
		SortOrder = (itemsort == Enum.SortOrder.LayoutOrder or itemsort == Enum.SortOrder.Name) and itemsort or Enum.SortOrder.Name,
		Name = "List"
	})
	if open then
		tween(label,{Position= UDim2.new()},math.random(40,70)/75,not open and Enum.EasingDirection.In)
	end
	return setmetatable({Container=new,Frame=label,Color=color,Categories={},Items={}},newscript)
end

-- panel functions

local panel = {}
panel.__index = panel

function panel:AddScript(name,color,itemsort,categorysort)
	assert(name and typeof(tostring(name)) == "string","Argument 1 Invalid or nil")
	assert(scripts[name] == nil,string.format("Script name '%s' is taken",name))
	color = color or Color3.fromRGB(255, 148, 106)
	local thenewscript = newscript.new(name,color,itemsort,categorysort)
	scripts[name] = thenewscript
	screencover.CanvasSize = UDim2.new(0, mainlist.AbsoluteContentSize.X,0, 0)
	return thenewscript
end

function panel:GetScript(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return scripts[name]
end

-- assign functions to _G.ScriptPanelv2

_G.ScriptPanelv2 = setmetatable({},panel)

return "Script Panel v2 setup; you may now use _G.ScriptPanelv2:AddScript()"
