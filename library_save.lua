if not memorystats then memorystats={} memorystats.cache=function(a)end memorystats.restore=function(a)end end
for i,v in pairs(({"Internal","HttpCache","Instances","Signals","Script","PhysicsCollision","PhysicsParts","GraphicsSolidModels","GraphicsMeshParts","GraphicsParticles","GraphicsParts","GraphicsSpatialHash","GraphicsTerrain","GraphicsTexture","GraphicsTextureCharacter","Sounds","StreamingSounds","TerrainVoxels","Gui","Animation","Navigation","GeometryCSG"})) do
    memorystats.cache(v)
end
local httpService = cloneref(game:GetService('HttpService'))
if not Options then
	Options = {}
end
if not Toggles then
	Toggles = {}
end
local SaveManager = {} do
	SaveManager.Folder = 'wallhackrbx'
	SaveManager.Ignore = {}
	SaveManager.Windows = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
		WindowPosition = {
			Save = function(idx, object)
				return { type = 'WindowPosition', idx = idx, x = math.floor(object.Position.X.Offset + 0.5), y = math.floor(object.Position.Y.Offset + 0.5) }
			end,
			Load = function(idx, data)
				local frame = SaveManager.Windows[idx]
				if frame and frame.Position and type(data.x) == 'number' and type(data.y) == 'number' then
					frame.Position = UDim2.new(0, data.x, 0, data.y)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:RegisterWindow(name, frame)
		self.Windows[name] = frame
	end

	function SaveManager:Save(name)
		if (not name) then
			return false, 'no config file is selected'
		end

		local fullPath = self.Folder .. '/settings/' .. name .. '.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		for idx, frame in next, self.Windows or {} do
			if frame and frame.Position then
				table.insert(data.objects, self.Parser.WindowPosition.Save(idx, frame))
			end
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, 'no config file is selected'
		end
		
		local file = self.Folder .. '/settings/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end

		return self:ApplyDecodedConfig(decoded)
	end

	function SaveManager:ApplyDecodedConfig(decoded)
		if type(decoded) ~= 'table' or type(decoded.objects) ~= 'table' then
			return false, 'invalid config format'
		end

		for _, option in next, decoded.objects do
			local parser = (type(option) == 'table' and option.type) and self.Parser[option.type]
			if parser then
				task.spawn(function() -- task.spawn() so the config loading wont get stuck.
					local ok, err = pcall(parser.Load, option.idx, option)
					if not ok then
						warn(('[SaveManager] failed to load %s %q: %s'):format(tostring(option.type), tostring(option.idx), tostring(err)))
					end
				end)
			end
		end

		return true
	end

	function SaveManager:LoadFromText(text)
		if not text or type(text) ~= 'string' or text:gsub('%s', '') == '' then
			return false, 'no config JSON provided'
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, text)
		if not success then
			return false, 'failed to decode JSON'
		end

		return self:ApplyDecodedConfig(decoded)
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end


	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local section = tab:AddRightGroupbox('Configuration')

		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })

		section:AddDivider()

		section:AddButton('Create config', function()
			local name = Options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('Created config %q', name))

			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:Notify(string.format('Loaded config %q', name))
		end)

		section:AddButton('Overwrite config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to overwrite config: ' .. err)
			end

			self.Library:Notify(string.format('Overwrote config %q', name))
		end)

		section:AddButton('Refresh list', function()
			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end)

		section:AddButton('Set as autoload', function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)

		section:AddDivider()

		section:AddInput('SaveManager_ImportJSON', { Text = 'Import config from text', Placeholder = 'Paste config JSON here...' })
		section:AddButton('Load from text', function()
			local text = Options.SaveManager_ImportJSON.Value

			local success, err = self:LoadFromText(text)
			if not success then
				return self.Library:Notify('Failed to load from text: ' .. tostring(err), 3)
			end

			self.Library:Notify('Loaded config from text', 2)
		end)

		SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName', 'SaveManager_ImportJSON' })
	end

	function SaveManager:SetOptionsTEMP(_Options, _Toggles)
		Options = _Options
		Toggles = _Toggles
	end

	SaveManager:BuildFolderTree()
end
for i,v in pairs(({"Internal","HttpCache","Instances","Signals","Script","PhysicsCollision","PhysicsParts","GraphicsSolidModels","GraphicsMeshParts","GraphicsParticles","GraphicsParts","GraphicsSpatialHash","GraphicsTerrain","GraphicsTexture","GraphicsTextureCharacter","Sounds","StreamingSounds","TerrainVoxels","Gui","Animation","Navigation","GeometryCSG"})) do
    memorystats.restore(v)
end
return SaveManager
