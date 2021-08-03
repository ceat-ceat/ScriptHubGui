if _G.FakeBindable then return end
-- i know this is bad and absolutely not optimal but im stupid pls dont laugh at me paslpdpsldpasslsldspslplp


-- fake connection


local fakeconnection = {
	__tostring = function()
		return "FakeConnection"
	end
}
fakeconnection.__index = fakeconnection

function fakeconnection:Disconnect()
	self.Callback,self.Connected = nil,false
end

function fakeconnection.new(callback)
	return setmetatable({Callback=callback,Connected=true},fakeconnection)
end

fakeconnection.disconnect = fakeconnection.Disconnect


-- fake event


local fakeevent = {
	__tostring = function()
		return "FakeEvent"
	end
}
fakeevent.__index = fakeevent

function fakeevent:Wait()
	local timesfired = self.TimesFired
	repeat wait() until timesfired ~= self.TimesFired
	return table.unpack(self.LatestArguments)
end

function fakeevent:Connect(callback)
	local connection = fakeconnection.new(callback)
	table.insert(self.Connections,connection)
	return connection
end


-- fake bindable


local fakebindable = {
	__tostring = function()
		return "FakeBindableEvent"
	end
}
fakebindable.__index = fakebindable

function fakebindable:Fire(...)
	self.Event.LatestArguments,self.Event.TimesFired = {...},self.Event.TimesFired + 1
	for i, v in next, self.Event.Connections do
		if v.Callback then v.Callback(...) end
	end
end

function fakebindable.new()
	return setmetatable({Event=setmetatable({LatestArguments={},TimesFired=0,Connections={}},fakeevent)},fakebindable)
end

fakebindable.fire,fakeevent.wait,fakeevent.connect = fakebindable.Fire,fakeevent.Wait,fakeevent.Connect

-- assign functions to _G.FakeEvent

_G.FakeBindable = setmetatable({},fakebindable)

return "fake bindable setup; you may now use _G.FakeBindable.new()"
