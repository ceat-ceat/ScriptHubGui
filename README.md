# ScriptHubGui (ScriptPanelv3)
ScriptHubGui, previously ScriptPanelv2, for Roblox exploit scripts

The documentation for ScriptPanelv2 can be found [here](https://github.com/ceat-ceat/ScriptHubGui/wiki/Script-Panel-v2)

ScriptHubGui
---
To use, first load v3 using loadstring

```lua
local scripthub = loadstring(game:HttpGet("https://raw.githubusercontent.com/ceat-ceat/ScriptHubGui/main/v3.lua", true))()
```

then, you create the container for all of your elements

```lua
local gui = scripthub.new("ScriptGui")
gui.Name = "Name"
```

You can add Categories and interactable Elements which you can connect to to let the user change how your script behaves
All objects in ScriptHubGui are designed to be Instance-like to be natural to handle

```lua
local enabled = true -- default value

local gui = scripthub.new("ScriptGui")
gui.Name = "script name wow"

local category = scripthub.new("Category")
category.Name = "other category!!"
-- parent the category to the gui last as to avoid name collision with any existing
-- categories already in the gui
category.Parent = gui

local enabledelement = scripthub.new("BooleanElement")
enabledelement.Name = "Enabled"
enabledelement.Value = enabled -- can set the value of elements like in Instances
-- same thinking as above but with elements and categories instead of categories and guis
enabledelement.Parent = category

enabledelement.ValueChanged:Connect(function(newenabled)
    print("Enabled value has been changed, new value:", newenabled)
    enabled = newenabled
end)
```


Documentation for other Elements can be found [here](https://github.com/ceat-ceat/ScriptHubGui/wiki/ScriptHubGui-(v3))
