local countdown = 0

pyro_config = {
	["size"] = 48,
	["font"] = 28,
	["limiter"] = 30
}
pyro = {}
pyro.abilityList = {
	["A780DFFDE16BB58CA"] = {
		["name"] = "Fire Storm",
		["id"] = 1,
	},
}
pyro.timeStamp = 0

function pyro.loadConfig()
	if not pyro.icon then
		if not pyro_config["size"] then pyro_config["size"] = 48 end
		if not pyro_config["X"] then pyro_config["X"] = UIParent:GetWidth() / 2 - pyro_config["size"] end
		if not pyro_config["Y"] then pyro_config["Y"] = UIParent:GetHeight() / 2 end
		if not pyro_config["limiter"] then pyro_config["limiter"] = 30 end
	end
end

function pyro.init()
	pyro.move = false
	pyro.context = UI.CreateContext("pyro_context")
	pyro.icon = {}
	pyro.icon[1] = UI.CreateFrame("Texture", "icon1", pyro.context)
	pyro.icon[1]:SetWidth(pyro_config["size"])
	pyro.icon[1]:SetHeight(pyro_config["size"])
	pyro.icon[1]:SetPoint("TOPLEFT", pyro.context, "TOPLEFT", pyro_config["X"], pyro_config["Y"])
	pyro.icon[1]:SetMouseMasking("limited")
	pyro.icon[1]:SetLayer(1)
	pyro.icon[1]:SetTexture("Rift", pyro.abilityList["A780DFFDE16BB58CA"].icon)
	pyro.icon[1]:SetVisible(false)
	
	pyro.icon[1].text = UI.CreateFrame("Text", "icon1text", pyro.icon[1])
	pyro.icon[1].text:SetPoint("CENTER", pyro.icon[1], "CENTER")
	pyro.icon[1].text:SetText("")
	pyro.icon[1].text:SetFontSize(pyro_config["font"])
	pyro.icon[1].text:SetLayer(2)
	pyro.icon[1].text:SetEffectGlow({
		colorA = 0.8, colorB = 0, colorG = 0, colorR = 0,
		offsetX = 0, offsetY = 0,
		blurX = 1, blurY = 1,
		knockout = false,
		replace = false,
		strength = 3
	})
	pyro.icon[1].text:SetFontColor(1, 1, 1, 1)

	pyro.windowMover = UI.CreateFrame("Frame", "windowMover", pyro.icon[1])
	pyro.windowMover:SetPoint("TOPLEFT", pyro.icon[1], "TOPLEFT")
	pyro.windowMover:SetHeight(pyro.icon[1]:GetHeight())
	pyro.windowMover:SetWidth(pyro.icon[1]:GetWidth() * 2)
	pyro.windowMover:SetBackgroundColor(0, 0, 0, 0)
	
	function pyro.windowMover.Event:LeftDown()
		self.MouseDown = pyro.move
		mouseData = Inspect.Mouse()
		self.MyStartX = pyro.icon[1]:GetLeft()
		self.MyStartY = pyro.icon[1]:GetTop()
		self.StartX = mouseData.x - self.MyStartX
		self.StartY = mouseData.y - self.MyStartY
	end
	
	function pyro.windowMover.Event:MouseMove(mouseX, mouseY)
		if self.MouseDown then
			pyro.icon[1]:ClearPoint("TOPLEFT")
			pyro.icon[1]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (mouseX - self.StartX), (mouseY - self.StartY))
		end
	end
	
	function pyro.windowMover.Event:LeftUp()
		self.MouseDown = false
	end
	
	function pyro.windowMover.Event:WheelBack()
		pyro.resize( pyro.icon[1]:GetWidth() - 1 )
	end
	
	function pyro.windowMover.Event:WheelForward()
		pyro.resize( pyro.icon[1]:GetWidth() + 1 )
	end
	
	pyro.icon[1].cd = 0
	
	print("/pyro help - for options")
end

function pyro.eventHandler(event, cooldowns)
	if (cooldowns["A780DFFDE16BB58CA"] and cooldowns["A780DFFDE16BB58CA"] == 8) then
        countdown = Inspect.Time.Real() + 30
	end
end

function pyro.update()
	if pyro.move == false and (Inspect.Time.Real() - pyro.timeStamp) > 0.5 then
		pyro.timeStamp = Inspect.Time.Real()
		if (countdown - Inspect.Time.Frame()) > -0.5 and (countdown - Inspect.Time.Frame()) < pyro_config["limiter"] then
			pyro.icon[1]:SetVisible(true)
			pyro.icon[1].text:SetText( tostring(math.abs(math.ceil(countdown - Inspect.Time.Frame()))) )
		elseif pyro.icon[1]:GetVisible() then pyro.icon[1]:SetVisible(false) end
	elseif not pyro.icon then
        pcall(function() pyro.abilityList["A780DFFDE16BB58CA"].icon = Inspect.Ability.New.Detail("A780DFFDE16BB58CA")["icon"] end)
		if pyro.abilityList["A780DFFDE16BB58CA"].icon then
			pyro.init()
		end
	end
end

function pyro.resize( size )
	pyro.icon[1]:SetWidth(size)
	pyro.icon[1]:SetHeight(size)
	pyro_config["size"] = size
end

function pyro.command(h, args)
	if args:find("size") then
		local size
		local pos = args:find("=")
		if pos then
			size = args:sub(pos+1)
			if tonumber(size) and tonumber(size) > 0 then
				pyro.resize(tonumber(size))
			end
		end
	elseif args:find("font") then
		local size
		local pos = args:find("=")
		if pos then
			size = args:sub(pos+1)
			if tonumber(size) and tonumber(size) > 0 then
				pyro.icon[1].text:SetFontSize(tonumber(size))
				pyro_config["font"] = tonumber(size)
			end
		end
	elseif args == "move" then
		if not pyro.move then
			pyro.icon[1]:SetVisible(true)
			pyro.windowMover:SetVisible(true)
			pyro.move = true
			pyro.icon[1].text:SetText(tostring(pyro_config["limiter"]))
		else
			pyro.icon[1]:SetVisible(false)
			pyro.windowMover:SetVisible(false)
			pyro.move = false
			pyro_config["X"] = pyro.icon[1]:GetLeft()
			pyro_config["Y"] = pyro.icon[1]:GetTop()
		end
	elseif args:find("limiter") then
		local size
		local pos = args:find("=")
		if pos then
			size = args:sub(pos+1)
			if tonumber(size) and (tonumber(size) > 0 and tonumber(size) <= 30) then
				pyro.limiter = tonumber(size)
				pyro_config["limiter"] = tonumber(size)
			end
		end
	else
		print("/pyro size=X - to change icon size")
		print("/pyro font=X - to change timer size")
		print("/pyro move - to unlock/lock icons")
		print("/pyro limiter=X - to change number of seconds you want to start to track with")
	end
end


local function AbilityCheck(event, abilities) -- Check if you play Pyro with Legendary Fire Storm
    if pyro.icon then
        pyro.icon[1]:SetVisible(false)
    end
    countdown = 0
    local abilitiies_detail = Inspect.Ability.New.Detail(abilities)
    for id, detail in pairs(abilitiies_detail) do
        if detail.idNew == "A780DFFDE16BB58CA" then -- Legendary Fire Storm
            Command.Event.Detach(Event.System.Update.Begin, pyro.update, "pyro update")
            Command.Event.Detach(Event.Ability.New.Cooldown.Begin, pyro.eventHandler, "pyro event handler")
            Command.Event.Attach(Event.System.Update.Begin, pyro.update, "pyro update")
            Command.Event.Attach(Event.Ability.New.Cooldown.Begin, pyro.eventHandler, "pyro event handler")
            break
        end
    end
end

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, pyro.loadConfig, "pyro load config")
Command.Event.Attach(Command.Slash.Register("pyro"), pyro.command, "pyro Slash commandr")
Command.Event.Attach(Event.Ability.New.Add, AbilityCheck, "AbilityCheck")

