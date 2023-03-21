--[[
ceat_ceat
ceat#6144

old script panel here:
- https://pastebin.com/BrRrbL5z


_G.becomefumopanel but better

I made this because the original script panel was pretty small,
you can go take a look yourself by running it and just look at how small it is.
In this version I basically made an interface that's not just all black and white and is more flexible
it just allows me to add more features to it easier and it has a bit more customization.

run

	loadstring(game:HttpGet("https://raw.githubusercontent.com/ceat-ceat/stuff/main/scriptpanelv2.lua"))()
	
to get _G.ScriptPanelv2 up and working



Changelog

changelog has moved, please go here instead

	https://github.com/ceat-ceat/ScriptPanelv2/blob/main/Changelog.txt

]]

local ts,plrs,ts2,uis,coregui,run = game:GetService("TweenService"),game:GetService("Players"),game:GetService("TextService"),game:GetService("UserInputService"),game:GetService("CoreGui"),game:GetService("RunService")
assert(run:IsClient(),"Please run this in a local environment!")
--require(script:WaitForChild("fakebindable"))
loadstring(game:HttpGet("https://raw.githubusercontent.com/ceat-ceat/roblox-script-utils/main/fakebindable.lua"))()
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

if _G.ScriptPanelv2 then return "Script Panel v2 is already setup; use _G.ScriptPanelv2:AddScript()" end


-- reference


local reference = {Keys=Enum.KeyCode:GetEnumItems()}


-- setup



local openkeybind,scripts,open,selectingkeybind,scrollpos = Enum.KeyCode.BackSlash,{},true,false,0

local screengui = create("ScreenGui",{
	Parent = pcall(function() create("Hole",{Parent=coregui,Name="isexploit diagnostic"}) end) and coregui or plrs.LocalPlayer:FindFirstChildOfClass("PlayerGui"),
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
		Position = UDim2.new(0, 10,0, 5),
		Size = UDim2.new(1, -10,0, 20),
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


-- property


local property = {
	__index = function(self,index)
		return index == "Value" and rawget(self,"__value") or index == "__event" and rawget(self,"__event") or index == "Changed" and rawget(self,"Changed") or getmetatable(self)[index]
	end,
	__newindex = function(self,index,value)
		if index == "Value" or index == "Value_silent" then
			value = rawget(self,"__ValueFilter")(value)
			local oldvalue = rawget(self,"__value")
			rawset(self,"__value",value)
			if index == "Value" and value ~= oldvalue then
				self.__event:Fire(value)
			end
		end
	end,
	__tostring = function(self)
		return string.format("spv2Item_%s %s",rawget(self,"Name"),tostring(rawget(self,"__value")))
	end,
}

function property.new(valuefilter,default)
	assert(typeof(valuefilter) == "function","Argument 1 missing or nil")
	local bindable = _G.FakeBindable.new()
	local prop = setmetatable({Name="to be set",Frame="to be set",Parent="to be set",ParentType="to be set",Color="to be set",__event=bindable,Changed=bindable.Event,__ValueFilter=valuefilter},property)
	if default then
		prop.Value_silent = default
	end
	return prop
end


-- itemtypes that require entire objects


local listdropdown = {
	__tostring = function(self)
		return string.format("spv2Item_%s",self.Name)
	end,
}
listdropdown.__index = listdropdown


-- item creating


local itemtypes = {
	String = function(params)
		local new,default = createbasicframe(params.Name),typeof(params.Default) == "string" and params.Default or ""
		local property = property.new(function(value)
			return typeof(value) == "string" and value or default
		end,default)
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
		textbox.FocusLost:Connect(function()
			property.Value = textbox.Text
		end)
		property.Changed:Connect(function()
			textbox.Text = property.Value
		end)
		property.Value = default
		return new,property
	end,
	Number = function(params)
		local new,default = createbasicframe(params.Name),tonumber(params.Default) or 0
		local property = property.new(function(value)
			return tonumber(value) or default
		end,default)
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
		textbox.FocusLost:Connect(function()
			property.Value = textbox.Text
		end)
		property.Changed:Connect(function(value)
			textbox.Text = value
		end)
		return new,property
	end,
	Boolean = function(params,otherdata)
		local new,default = createbasicframe(params.Name),typeof(params.Default) == "boolean" and params.Default or false
		local property = property.new(function(value)
			return typeof(value) == "boolean" and value or false
		end,default)
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
		new.Label.TextColor3 = (property.Value and otherdata.Color or Color3.fromRGB(255, 255, 255))
		button.MouseButton1Click:Connect(function()
			property.Value = not property.Value
		end)
		property.Changed:Connect(function(v)
			local color = (property.Value and otherdata.Color or Color3.fromRGB(255, 255, 255))
			tween(bar,{BackgroundColor3 = color},0.3)
			tween(new.Label,{TextColor3 = color},0.3)
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
		local new,default = createbasicframe(params.Name),table.find(reference.Keys,params.Default) and params.Default or Enum.KeyCode.E
		local property,changing = property.new(function(value)
			return table.find(reference.Keys,value) and value or default
		end),false
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
		button.MouseButton1Click:Connect(function()
			if changing then return end
			changing,button.Text,button.Size = true,"Press a key",UDim2.new(0, 80,0, 21)
			local key
			repeat
				key = uis.InputBegan:Wait()
			until key.KeyCode ~= Enum.KeyCode.Unknown or not changing
			if key and key.KeyCode ~= Enum.KeyCode.Unknown then
				property.Value = key.KeyCode
			end
		end)
		property.Changed:Connect(function(value)
			button.Text,button.Size = value.Name,UDim2.new(0, math.max(ts2:GetTextSize(value.Name,14,Enum.Font.Gotham,Vector2.new()).X+6,50),0, 21)
			changing = false
		end)
		return new,property
	end,
	Dropdown = function(params)
		assert(typeof(params.Values) == "table","Values array invalid or nil")
		local new,default = createbasicframe(params.Name),params.Values[params.Default]
		local property,open = property.new(function(value)
			return params.Values[value] or default
		end,default),false
		local button = create("TextButton",{
			Parent = new,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -5,0.5, 0),
			Size = UDim2.new(0, 57,0, 21),
			Text = ""
		})
		local label,arrow,container = create("TextLabel",{
			Parent = button,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 7,0, 0),
			Size = UDim2.new(0, 43,0, 21),
			Font = Enum.Font.Gotham,
			Text = default and params.Default or "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14
		}),create("ImageLabel",{
			Parent = button,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0,0, 0),
			Size = UDim2.new(0, 14,1, 0),
			Image = "rbxassetid://4430382116",
			ScaleType = Enum.ScaleType.Fit
		}),create("Frame",{
			Parent = button,
			Name = 'shuksdhfusdf',
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0,1, 0),
			Size = UDim2.new(1, 0,0, 0),
			ClipsDescendants = true
		})
		local list = create("UIListLayout",{Parent=container})
		local function openclose()
			tween(container,{Size=UDim2.new(1, 0,0, open and list.AbsoluteContentSize.Y or 0)},0.3)
			tween(arrow,{Rotation=open and 180 or 0},0.3)
		end
		local function findindex(value)
			for i, v in next, params.Values do
				if v == value then
					return i
				end
			end
		end
		for i, v in next, params.Values do
			local newbutton = create("TextButton",{
				Parent = container,
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0,0, 21),
				Font = Enum.Font.Gotham,
				Text = i,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14
			})
			newbutton.MouseButton1Click:Connect(function()
				property.Value,open = i,false
				openclose()
			end)
		end
		button.MouseButton1Click:Connect(function()
			open = not open
			openclose()
		end)
		property.Changed:Connect(function(value)
			open,label.Text = false,findindex(value)
			openclose()
		end)
		return new,property
	end,
	-- listdropdown is in the listdropdown functions section i know it sucks ok just go down ther
}



-- functions



-- item functions



function additem(_frame,type,params,other)
	local itemtype = itemtypes[type]
	assert(itemtype,"Invalid item type")
	assert(params.Name and tostring(params.Name),"Name is required")
	local new,thing = itemtype(params,other)
	new.Parent,new.LayoutOrder,thing.ParentType,thing.Name,thing.Color = _frame,params.LayoutOrder or 0,other.ParentType,string.format("%s_%s",type,params.Name),other.Color
	return new,thing
end

local item = {}
item.__index = item

function setitemmetatotable(tabl)
	local existingmeta = getmetatable(tabl)
	if existingmeta and existingmeta ~= item then setitemmetatotable(existingmeta) return end
	setmetatable(tabl,item)
end

function item:Remove()
	local list = self.Frame.Parent
	self.Frame:Destroy()
	self.Parent.Items[self.Name] = nil
end

function item.new(...)
	local new,thing = additem(...)
	thing.Frame = new
	setitemmetatotable(thing)
	return thing
end


-- that part where i make the functions for items that need their own objects


function listdropdown:AddItem(itemtype,params)
	assert(itemtype and tostring(itemtype),"Argument 1 invalid or nil")
	assert(self.Items[params.Name] == nil,string.format("Item name '%s' is taken",params.Name))
	local newitem = item.new(self.Frame.List,itemtype,params,{Color=self.Color,ParentType="Item"})
	self.Items[params.Name],newitem.Parent = newitem,self
	return newitem
end

function listdropdown:GetItem(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return self.Items[name]
end

function listdropdown.new(params,other)
	local new,open = createbasicframe(params.Name),false
	local button,arrow,container = create("TextButton",{
		Parent = new,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5,0, 5),
		Size = UDim2.new(1, -10,0, 20),
		Text = "",
		ZIndex = 2
	}),create("ImageLabel",{
		Parent = new,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5,0, 0),
		Size = UDim2.new(0, 20,0, 30),
		Image = "rbxassetid://4430382116",
		ScaleType = Enum.ScaleType.Fit
	}),create("Frame",{
		Parent = new,
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0,0, 30),
		Size = UDim2.new(1, 0,1, -30),
		ClipsDescendants = true,
		Name = "List"
	})
	local list = create("UIListLayout",{Parent=container,Name="List"})
	new.ClipsDescendants = true
	local function openclose()
		tween(new,{Size=UDim2.new(1, 0,0, (open and list.AbsoluteContentSize.Y or 0) + 30)},0.3)
		tween(arrow,{Rotation=open and 180 or 0},0.3)
	end
	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(openclose)
	button.MouseButton1Click:Connect(function()
		open = not open
		openclose()
	end)
	return new,setmetatable({Frame=new,Color=other.Color,Items={},Name="to be set"},listdropdown)
end

itemtypes.ListDropdown = listdropdown.new


-- script category functions



local category = {
	__metatable = "The metatable is locked",
	__tostring = function(self)
		return string.format("spv2Category_%s",self.Name)
	end,
}
category.__index = category

function category:AddItem(itemtype,params)
	assert(itemtype and tostring(itemtype),"Argument 1 invalid or nil")
	assert(self.Items[params.Name] == nil,string.format("Item name '%s' is taken",params.Name))
	local newitem = item.new(self.Frame.Frame.List,itemtype,params,{Color=self.Color,ParentType="Category"})
	self.Frame.Size = UDim2.new(1, 0,0, 25+self.Frame.Frame.List.Size.Y.Offset)
	self.Items[params.Name],newitem.Parent = newitem,self
	return newitem
end

function category:GetItem(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return self.Items[name]
end

function category:Remove()
	self.Frame:Destroy()
	self.Parent.Categories[self.Name] = nil
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
	local uilist = create("UIListLayout",{
		Parent = listframe,
		SortOrder = (sort == Enum.SortOrder.LayoutOrder or sort == Enum.SortOrder.Name) and sort or Enum.SortOrder.Name,
		Name = "List"
	})
	uilist:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		listframe.Size,container.Size = UDim2.new(1, 0,0, uilist.AbsoluteContentSize.Y),UDim2.new(1, 0,0, uilist.AbsoluteContentSize.Y + 25)
	end)
	return setmetatable({Frame=container,Color=color,Items={},Name=name},category)
end


-- script functions



local newscript = {
	__metatable = "The metatable is locked",
	__tostring = function(self)
		return string.format("spv2Script_%s",self.Name)
	end,
}
newscript.__index = newscript

function newscript:AddItem(itemtype,params)
	assert(itemtype and tostring(itemtype),"Argument 1 invalid or nil")
	assert(self.Items[params.Name] == nil,string.format("Item name '%s' is taken",params.Name))
	local newitem = item.new(self.Frame.InitialList.MainCategory,itemtype,params,{Color=self.Color,ParentType="Script"})
	self.Items[params.Name],newitem.Parent = newitem,self
	return newitem
end

function newscript:AddCategory(name,sort,layoutorder)
	assert(self.Categories[name] == nil,string.format("Category name '%s' is taken",name))
	local newcategory = category.new(name,self.Frame.InitialList,self.Color,sort,layoutorder)
	self.Categories[name],newcategory.Parent = newcategory,self
	for i, v in next, self.Categories do
		v.Frame.ZIndex += 1
	end
	return newcategory
end

function newscript:GetCategory(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return self.Categories[name]
end

function newscript:Remove()
	self.Container:Destroy()
	scripts[self.Name] = nil
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
		Name = "MainCategory",
	})
	local list = create("UIListLayout",{
		Parent = category1,
		SortOrder = (itemsort == Enum.SortOrder.LayoutOrder or itemsort == Enum.SortOrder.Name) and itemsort or Enum.SortOrder.Name,
		Name = "List"
	})
	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		category1.Size = UDim2.new(1, 0,0, list.AbsoluteContentSize.Y)
	end)
	if open then
		tween(label,{Position= UDim2.new()},math.random(40,70)/75,not open and Enum.EasingDirection.In)
	end
	return setmetatable({Container=new,Frame=label,Color=color,Categories={},Items={},Name=name},newscript)
end

-- panel functions

local panel = {
	__metatable = "The metatable is locked"
}
panel.__index = panel

function panel:AddScript(name,color,itemsort,categorysort)
	assert(name and typeof(tostring(name)) == "string","Argument 1 Invalid or nil")
	assert(scripts[name] == nil,string.format("Script name '%s' is taken",name))
	color = color or Color3.fromRGB(255, 148, 106)
	local newscript = newscript.new(name,color,itemsort,categorysort)
	scripts[name],newscript.Parent = newscript,scripts
	screencover.CanvasSize = UDim2.new(0, mainlist.AbsoluteContentSize.X,0, 0)
	return newscript
end

function panel:GetScript(name)
	assert(name and tostring(name),"Argument 1 invalid or nil")
	return scripts[name]
end

-- assign functions to _G.ScriptPanelv2

_G.ScriptPanelv2 = setmetatable({},panel)

return "Script Panel v2 setup; you may now use _G.ScriptPanelv2:AddScript()"
