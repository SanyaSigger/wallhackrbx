local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local type_custom = typeof
if not LPH_OBFUSCATED then
	LPH_JIT = function(...)
		return ...;
	end;
	LPH_JIT_MAX = function(...)
		return ...;
	end;
	LPH_NO_VIRTUALIZE = function(...)
		return ...;
	end;
	LPH_NO_UPVALUES = function(f)
		return (function(...)
			return f(...);
		end);
	end;
	LPH_ENCSTR = function(...)
		return ...;
	end;
	LPH_ENCNUM = function(...)
		return ...;
	end;
	LPH_ENCFUNC = function(func, key1, key2)
		if key1 ~= key2 then return print("LPH_ENCFUNC mismatch") end
		return func
	end
	LPH_CRASH = function()
		return print(debug.traceback());
	end;
    SWG_DiscordUser = "swim"
    SWG_DiscordID = 1337
    SWG_Private = true
    SWG_Dev = false
    SWG_Version = "1.4.8.8"
    SWG_Title = 'wallhack.rbx | %s | %s'
    SWG_ShortName = 'wallhack'
    SWG_FullName = 'project delta'
    SWG_FFA = false
end;
local workspace = cloneref(Workspace)
local Players = cloneref(Players)
local RunService = cloneref(RunService)
local Lighting = cloneref(game:GetService("Lighting"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local GuiInset = cloneref(game:GetService("GuiService")):GetGuiInset()
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _Vector3new = Vector3.new
local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = workspace.Raycast
local _IsKeyDown = UserInputService.IsKeyDown
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _Vector3zeromin = Vector3.zero.Min
local _Vector2zeromin = Vector2.zero.Min
local _Vector3zeromax = Vector3.zero.Max
local _Vector2zeromax = Vector2.zero.Max
local _IsA = game.IsA
local tablecreate = table.create
local mathfloor = math.floor
local mathround = math.round
local tostring = tostring
local unpack = unpack
local getupvalues = debug.getupvalues
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getconstants = debug.getconstants
local getconstant = debug.getconstant
local setconstant = debug.setconstant
local getstack = debug.getstack
local setstack = debug.setstack
local getinfo = debug.getinfo
local rawget = rawget
local function getfile(name)
    local repo = "https://raw.githubusercontent.com/SanyaSigger/wallhackrbx/refs/heads/main/" -- Changed to standard raw content URL format
    local success, content = pcall(request, {Url = repo..name, Method = "GET"})
    if success then
        if content.StatusCode == 200 then
            return content.Body
        else
            return print("getfile returned error code: " .. tostring(content.StatusCode))
        end
    else
        return print("getfile pcall error: " .. tostring(content))
    end
end
local function iswhfile(file)
    return isfile("wallhackrbx/new/files/"..file)
end
local function readwhfile(file)
    if not iswhfile(file) then return false end
    local success, returns = pcall(readfile, "wallhackrbx/new/files/"..file)
    if success then return returns else return print(returns) end
end
local function loadwhfile(file)
    if not iswhfile(file) then return false end
    local success, returns = pcall(loadstring, readwhfile(file))
    if success then return returns else return print(returns) end
end
local function getwhasset(file)
    if iswhfile(file) then return false end
    local success, returns = pcall(getcustomasset, "wallhackrbx/new/files/"..file)
    if success then return returns else return print(returns) end
end
do
    if not isfolder("wallhackrbx") then makefolder("wallhackrbx") end
    if not isfolder("wallhackrbx/new") then makefolder("wallhackrbx/new") end
    if not isfolder("wallhackrbx/new/files") then makefolder("wallhackrbx/new/files") end
    local function getfiles(force, list)
        for _, file in list do
            if (force or not force and not iswhfile(file)) then
                writefile("wallhackrbx/new/files/"..file, getfile(file))
            end
        end
    end
    local gotassets = getfile("assets.json")
    if not gotassets then return end
    local assets = HttpService:JSONDecode(gotassets)
    local localassets = readwhfile("assets.json")
    if localassets then
        localassets = HttpService:JSONDecode(localassets)
        if localassets.version ~= assets.version then
            writefile("wallhackrbx/new/files/assets.json", gotassets)
            getfiles(true, assets.list)
        end
    else
        writefile("wallhackrbx/new/files/assets.json", gotassets)
    end
    getfiles(false, assets.list)
end
local cheat = {
    Library = nil,
    Toggles = nil,
    Options = nil,
    ThemeManager = nil,
    SaveManager = nil,
    connections = {
        heartbeats = {},
        renderstepped = {}
    },
    drawings = {},
    hooks = {},
}
local tipanel_settings = {
    bgcolor = Color3.fromRGB(15, 15, 15),
    bordercolor = Color3.fromRGB(45, 45, 45),
    accentcolor = Color3.fromRGB(120, 110, 180),
    glowcolor = Color3.fromRGB(120, 110, 180),
    bgtrans = 0.9,
}
local ui = {}
cheat.utility = {} do
    cheat.utility.new_heartbeat = function(func)
        local obj = {}
        cheat.connections.heartbeats[func] = func
        function obj:Disconnect()
            if func then
                cheat.connections.heartbeats[func] = nil
                func = nil
            end
        end
        return obj
    end
    cheat.utility.new_renderstepped = function(func)
        local obj = {}
        cheat.connections.renderstepped[func] = func
        function obj:Disconnect()
            if func then
                cheat.connections.renderstepped[func] = nil
                func = nil
            end
        end
        return obj
    end

    local vischeck_params = RaycastParams.new()
    vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
    vischeck_params.CollisionGroup = "WeaponRay"
    vischeck_params.IgnoreWater = true

    cheat.utility.is_visible = function(cframe, target, target_part)
        if not (target and target_part and cframe) then return false end
        if cheat.freecam_enabled and cheat.Toggles.freecam_vis_original and cheat.Toggles.freecam_vis_original.Value then
            local my_char = LocalPlayer.Character
            local my_head = my_char and (my_char:FindFirstChild("Head") or my_char:FindFirstChild("CollisionPilot", true) or my_char:FindFirstChild("Mi24_Prop_M", true))
            if my_head then
                cframe = my_head.CFrame
            end
        end
        local char = LocalPlayer.Character
        if char ~= cheat.utility._last_vis_char then
            cheat.utility._last_vis_char = char
            vischeck_params.FilterDescendantsInstances = { Workspace.NoCollision, Camera, char }
        end
        local castresults = Workspace:Raycast(cframe.p, target_part.Position - cframe.p, vischeck_params)
        if not castresults then return true end
        if castresults and castresults.Instance then
            if target_part and castresults.Instance == target_part then return true end
            return castresults.Instance:IsDescendantOf(target)
        end
        return false
    end

    cheat.utility.spawn_kill_effect = function(pos)
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Position = pos
        part.Parent = workspace.Terrain

        local emit = Instance.new("ParticleEmitter")
        emit.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        emit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0)})
        emit.Color = ColorSequence.new(Color3.new(1, 1, 1))
        emit.LightEmission = 1
        emit.LightInfluence = 0
        emit.ZOffset = 1
        emit.Lifetime = NumberRange.new(1, 2)
        emit.Rate = 0
        emit.Speed = NumberRange.new(15, 40)
        emit.SpreadAngle = Vector2.new(360, 360)
        emit.Drag = 2
        emit.Parent = part

        local amount = cheat.Options.killeffect_amount and cheat.Options.killeffect_amount.Value or 100
        emit:Emit(amount)

        game:GetService("Debris"):AddItem(part, 3)
    end

    cheat.utility.world_to_screen = function(world)
        local screen, inBounds = Camera:WorldToViewportPoint(world)
        return Vector2.new(screen.X, screen.Y), inBounds, screen.Z
    end
    cheat.utility.new_drawing = function(drawobj, args)
        local obj = Drawing.new(drawobj)
        for i, v in pairs(args) do
            obj[i] = v
        end
        cheat.drawings[obj] = obj
        return obj
    end
    cheat.utility.new_hook = function(f, newf, usecclosure) LPH_NO_VIRTUALIZE(function()
        if usecclosure then
            local old; old = hookfunction(f, newcclosure(function(...)
                return newf(old, ...)
            end))
            cheat.hooks[f] = old
            return old
        else
            local old; old = hookfunction(f, function(...)
                return newf(old, ...)
            end)
            cheat.hooks[f] = old
            return old
        end
    end)() end
    local connection; connection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(delta)
        for _, func in pairs(cheat.connections.heartbeats) do
            func(delta)
        end
    end))
    local connection1; connection1 = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(delta)
        for _, func in pairs(cheat.connections.renderstepped) do
            func(delta)
        end
    end))
    cheat.utility.unload = function()
        connection:Disconnect()
        connection1:Disconnect()
        for key, _ in pairs(cheat.connections.heartbeats) do
            cheat.connections.heartbeats[key] = nil
        end
        for key, _ in pairs(cheat.connections.renderstepped) do
            cheat.connections.heartbeats[key] = nil
        end
        for _, drawing in pairs(cheat.drawings) do
            drawing:Remove()
            cheat.drawings[_] = nil
        end
        for hooked, original in pairs(cheat.hooks) do
            if type(original) == "function" then
                hookfunction(hooked, clonefunction(original))
            else
                hookmetamethod(original["instance"], original["metamethod"], clonefunction(original["func"]))
            end
        end
    end
    cheat.utility.create_loading_screen = function()
        local screen_size = Camera.ViewportSize
        local panel_size = _Vector2new(350, 100)
        local panel_pos = (screen_size / 2) - (panel_size / 2)
        local objects = {}
        local function draw(type, args)
            local obj = cheat.utility.new_drawing(type, args)
            table.insert(objects, obj)
            return obj
        end
        local bg = draw("Square", {
            Size = panel_size, Position = panel_pos, Color = Color3.fromRGB(10, 10, 10),
            Filled = true, Transparency = 0.95, Visible = true, ZIndex = 1000
        })
        for i = 1, 8 do
            draw("Square", {
                Size = panel_size + _Vector2new(i*2, i*2), Position = panel_pos - _Vector2new(i, i),
                Color = tipanel_settings.glowcolor, Thickness = 1, Filled = false,
                Transparency = 0.2 - (i * 0.02), Visible = true, ZIndex = 999
            })
        end
        local bar_bg = draw("Square", {
            Size = _Vector2new(panel_size.X - 60, 6), Position = panel_pos + _Vector2new(30, 65),
            Color = Color3.fromRGB(25, 25, 25), Filled = true, Visible = true, ZIndex = 1001
        })
        local bar = draw("Square", {
            Size = _Vector2new(0, 6), Position = panel_pos + _Vector2new(30, 65),
            Color = tipanel_settings.accentcolor, Filled = true, Visible = true, ZIndex = 1002
        })
        local bar_glows = {}
        for i = 1, 6 do
            bar_glows[i] = draw("Square", {
                Size = _Vector2new(0, 6) + _Vector2new(i*2, i*2), Position = bar.Position - _Vector2new(i, i),
                Color = tipanel_settings.glowcolor, Thickness = 1, Filled = false,
                Transparency = 0.3 - (i * 0.04), Visible = true, ZIndex = 1001
            })
        end
        local text = draw("Text", {
            Text = "initializing wallhack.rbx", Size = 16, Center = true,
            Position = panel_pos + _Vector2new(panel_size.X / 2, 25),
            Color = Color3.new(1, 1, 1), Font = Drawing.Fonts.UI, Outline = true,
            Visible = true, ZIndex = 1003
        })
        local status_text = draw("Text", {
            Text = "Bypassing anticheat...", Size = 13, Center = true,
            Position = panel_pos + _Vector2new(panel_size.X / 2, 45),
            Color = Color3.fromRGB(200, 200, 200), Font = Drawing.Fonts.UI, Outline = true,
            Visible = true, ZIndex = 1003
        })
        local statuses = {
            "Bypassing anticheat...", "Loading core modules...", "Initializing combat engine...",
            "Fetching latest config...", "Connecting to server...", "Optimizing performance...",
            "Setting up visual environment...", "Securing connection...", "Cleaning memory caches...",
            "Ready to play!"
        }
        local start = tick()
        local last_status = 0
        while tick() - start < 5 do
            local elapsed = tick() - start
            local progress = math.clamp(elapsed / 5, 0, 1)
            local bar_width = (panel_size.X - 60) * progress
            bar.Size = _Vector2new(bar_width, 6)
            for i = 1, 6 do
                if bar_glows[i] then
                    bar_glows[i].Size = _Vector2new(bar_width, 6) + _Vector2new(i*2, i*2)
                end
            end
            text.Transparency = 0.7 + (math.sin(tick() * 5) * 0.3)

            if tick() - last_status > 0.6 then
                last_status = tick()
                status_text.Text = statuses[math.random(1, #statuses-1)]
            end
            if progress > 0.95 then status_text.Text = "Ready to play!" end
            task.wait()
        end
        for _, v in objects do v:Remove() end
        if cheat.Library then
            -- Simulate Right Shift press to toggle menu
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
        end
    end
end
-- task.spawn(cheat.utility.create_loading_screen)
local _ok, _err
_ok, cheat.Library, cheat.Toggles, cheat.Options = pcall(function()
    local chunk = loadwhfile("library_main.lua")
    if not chunk then error("library_main.lua not found or failed to compile") end
    return chunk()
end)
if not _ok then return print("[wh] library_main load error: " .. tostring(cheat.Library)) end

_ok, cheat.ThemeManager = pcall(function()
    local chunk = loadwhfile("library_theme.lua")
    if not chunk then error("library_theme.lua not found or failed to compile") end
    return chunk()
end)
if not _ok then return print("[wh] library_theme load error: " .. tostring(cheat.ThemeManager)) end

_ok, cheat.SaveManager = pcall(function()
    local chunk = loadwhfile("library_save.lua")
    if not chunk then error("library_save.lua not found or failed to compile") end
    return chunk()
end)
if not _ok then return print("[wh] library_save load error: " .. tostring(cheat.SaveManager)) end
ui = {
    window = cheat.Library:CreateWindow({
        Title=string.format(
            SWG_Title,
            SWG_Version,
            SWG_FullName
        ),
    Center=false,AutoShow=true,Size=UDim2.new(0, 550, 0, 850)})
}
local globals = {
    fov_enabled = false,
    zoom_enabled = false,
    EnableTime = false,
    Time = 12,
    noshadows = false,
    gradientenabled = false,
}

local tp_peek_state = {
    active = false,
    origin = nil,
    target = nil,
    end_time = 0,
}

local function trigger_tp_peek(duration)
    duration = math.clamp(duration or 0.08, 0.03, 0.25)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local look = Camera and Camera.CFrame and Camera.CFrame.LookVector or Vector3.new(0, 0, -1)
    local flat_look = Vector3.new(look.X, 0, look.Z)
    if flat_look.Magnitude < 0.01 then
        flat_look = Vector3.new(1, 0, 0)
    else
        flat_look = flat_look.Unit
    end

    local origin = hrp.CFrame
    local target = origin + flat_look * 1.5

    tp_peek_state.active = true
    tp_peek_state.origin = origin
    tp_peek_state.target = target
    tp_peek_state.end_time = tick() + duration

    hrp.CFrame = target
    if cheat.real_CFrame then
        cheat.real_CFrame = target
    end
end

cheat.utility.new_heartbeat(function()
    if not tp_peek_state.active then return end

    local now = tick()
    if now >= tp_peek_state.end_time then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = tp_peek_state.origin
            if cheat.real_CFrame then
                cheat.real_CFrame = tp_peek_state.origin
            end
        end
        tp_peek_state.active = false
        tp_peek_state.origin = nil
        tp_peek_state.target = nil
        tp_peek_state.end_time = 0
        return
    end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = tp_peek_state.target
        if cheat.real_CFrame then
            cheat.real_CFrame = tp_peek_state.target
        end
    end
end)

ui.tabs = {
    combat = ui.window:AddTab('combat'),
    visuals = ui.window:AddTab('visuals'),
    misc = ui.window:AddTab('misc'),
    config = ui.window:AddTab('config'),
    players = ui.window:AddTab('players'),
}
ui.box = {
    mods = ui.tabs.combat:AddRightTabbox(),
    antiaim = ui.tabs.combat:AddRightTabbox(),
    esp = ui.tabs.visuals:AddLeftTabbox(),
    world = ui.tabs.visuals:AddRightTabbox(),
    crosshair = ui.tabs.visuals:AddRightTabbox(),
    themeconfig = ui.tabs.config:AddLeftGroupbox('theme config'),
}

local whitelisted_players = {}
local prioritized_players = {}
local player_list_box = ui.tabs.players:AddLeftGroupbox('Player List')

local function add_player_to_list(player)
    if player ~= LocalPlayer then
        player_list_box:AddDropdown(player.Name..'_status', {
            Values = {'None', 'Whitelist', 'Prioritize'},
            Default = 1, -- 'None'
            Multi = false,
            Text = player.Name,
            Callback = function(Value)
                if Value == 'Whitelist' then
                    whitelisted_players[player.Name] = true
                    prioritized_players[player.Name] = false
                elseif Value == 'Prioritize' then
                    whitelisted_players[player.Name] = false
                    prioritized_players[player.Name] = true
                else -- 'None'
                    whitelisted_players[player.Name] = false
                    prioritized_players[player.Name] = false
                end
            end
        })
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    add_player_to_list(player)
end

Players.PlayerAdded:Connect(add_player_to_list)

-- there is no easy way to remove from the UI, so I will just leave the old player names.


-- Hacky fix to make internal UI containers scale with the taller window height
task.spawn(function()
    if cheat.Library and cheat.Library.ScreenGui then
        for _, tabFrame in ipairs(cheat.Library.ScreenGui:GetDescendants()) do
            if tabFrame:IsA("Frame") and tabFrame.Name == "TabFrame" then
                local tabs = {}
                for _, child in ipairs(tabFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        table.insert(tabs, child)
                    end
                end

                if #tabs > 0 then
                    local totalWidth = tabFrame.AbsoluteSize.X
                    local tabWidth = totalWidth / #tabs
                    for i, tab in ipairs(tabs) do
                        tab.Size = UDim2.new(0, tabWidth, 1, 0)
                        tab.Position = UDim2.new(0, (i - 1) * tabWidth, 0, 0)
                    end
                end
            end
            if tabFrame:IsA("ScrollingFrame") and tabFrame.Parent and tabFrame.Parent.Name == "TabFrame" then
                -- Change the Y scale to 1 to fill the window, and keep a small offset for padding
                tabFrame.Size = UDim2.new(tabFrame.Size.X.Scale, tabFrame.Size.X.Offset, 1, -14)
            end
        end
    end
end)

-- Apply a decal image to the Linoria background frame
task.spawn(function()
    if cheat.Library and cheat.Library.ScreenGui then
        for _, desc in ipairs(cheat.Library.ScreenGui:GetDescendants()) do
            if desc:IsA("Frame") and desc.Name == "Inner" and desc.Parent and desc.Parent.Name == "Outer" then
                local decal = Instance.new("ImageLabel", desc)
                decal.Name = "BackgroundDecal"
                decal.Image = "rbxassetid://11778372953"
                decal.ScaleType = Enum.ScaleType.Crop
                decal.Size = UDim2.new(1, 0, 1, 0)
                decal.Position = UDim2.new(0, 0, 0, 0)
                decal.BackgroundTransparency = 1
                decal.ImageTransparency = 0.85
                decal.ZIndex = 0
                break
            end
        end
    end
end)

cheat.EspLibrary = {} LPH_NO_VIRTUALIZE(function()
    local esp_table = {}
    local workspace = cloneref(Workspace)
    local rservice = cloneref(RunService)
    local plrs = cloneref(Players)
    local lplr = plrs.LocalPlayer
    local success, coregui = pcall(game.GetService, game, "CoreGui")
    local container = Instance.new("Folder", (success and coregui:FindFirstChild("RobloxGui")) or lplr:WaitForChild("PlayerGui"))
    esp_table = {
        __loaded = false,
        main_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.UI,
            distancelimit = false,
            maxdistance = 200,
            fadetime = 1,
            infiniterange = false
        },
        main_object_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.UI,
            distancelimit = false,
            maxdistance = 200,
            useteamcolor = false,
            teamcheck = false,
            sleepcheck = false,
            allowed = {}
        },
        settings = {
            enemy = {
                enabled = false,
                box = false,
                box_fill = false,
                realname = false,
                displayname = false,
                health = false,
                dist = false,
                weapon = false,
                skeleton = false,
                outline = false,
                outline_vis = false,
                outline_manip = false,
                box_color = { Color3.new(1, 1, 1), 1 },
                box_fill_color = { Color3.new(1, 0, 0), 0.5 },
                realname_color = { Color3.new(1, 1, 1), 1 },
                displayname_color = { Color3.new(1, 1, 1), 1 },
                health_color = { Color3.new(1, 1, 1), 1 },
                dist_color = { Color3.new(1, 1, 1), 1 },
                weapon_color = { Color3.new(1, 1, 1), 1 },
                skeleton_color = { Color3.new(1, 1, 1), 1 },
                outline_color = { Color3.new(), 1 },
                outline_vis_color = { Color3.new(), 1 },
                outline_manip_color = { Color3.fromRGB(255, 255, 0), 1 },
                health_color_top = Color3.new(0, 1, 0),
                health_color_bottom = Color3.new(1, 0, 0),
                health_thickness = 2,
                health_glow_size = 5,
                chams = false,
                chams_visible_only = false,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chamsoutline_color = { Color3.new(1, 1, 1), 0 },
                chams_material = "Neon",
                high_kd_marker = false,
                high_kd_outline_color = Color3.fromRGB(255, 0, 0),
            },
            corpse = {
                enabled = false,
                name = true,
                distance = false,
                color = Color3.fromRGB(0, 255, 0),
                outline = false,
                outline_color = Color3.new()
            },
            wreck = {
                enabled = false,
                name = true,
                distance = false,
                color = Color3.fromRGB(255, 165, 0),
                outline = false,
                outline_color = Color3.new()
            },
            boss = {
                enabled = false,
                name = true,
                distance = false,
                color = Color3.fromRGB(255, 0, 255),
                outline = false,
                outline_color = Color3.new()
            }
        }
    }
    local loaded_plrs = {}
    local camera = workspace.CurrentCamera
    local viewportsize = camera.ViewportSize
    local VERTICES = {
        _Vector3new(-1, -1, -1),
        _Vector3new(-1, 1, -1),
        _Vector3new(-1, 1, 1),
        _Vector3new(-1, -1, 1),
        _Vector3new(1, -1, -1),
        _Vector3new(1, 1, -1),
        _Vector3new(1, 1, 1),
        _Vector3new(1, -1, 1)
    }
    local skeleton_order = {
        ["LeftFoot"] = "LeftLowerLeg",
        ["LeftLowerLeg"] = "LeftUpperLeg",
        ["LeftUpperLeg"] = "LowerTorso",
        ["RightFoot"] = "RightLowerLeg",
        ["RightLowerLeg"] = "RightUpperLeg",
        ["RightUpperLeg"] = "LowerTorso",
        ["LeftHand"] = "LeftLowerArm",
        ["LeftLowerArm"] = "LeftUpperArm",
        ["LeftUpperArm"] = "UpperTorso",
        ["RightHand"] = "RightLowerArm",
        ["RightLowerArm"] = "RightUpperArm",
        ["RightUpperArm"] = "UpperTorso",
        ["LowerTorso"] = "UpperTorso",
        ["UpperTorso"] = "Head"
    }
    local esp = {}
    esp.create_obj = function(type, args)
        local obj = Drawing.new(type)
        for i, v in args do
            obj[i] = v
        end
        return obj
    end
    local function isBodyPart(name)
        return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm") or name:find("Mi24") or name:find("Prop_") or name:find("Hull") or name:find("BTR") or name:find("Pilot")
    end
    local function getBoundingBox(parts)
        local min, max
        for i = 1, #parts do
            local part = parts[i]
            local cframe, size = part.CFrame, part.Size
            min = _Vector3zeromin(min or cframe.Position, (cframe - size * 0.5).Position)
            max = _Vector3zeromax(max or cframe.Position, (cframe + size * 0.5).Position)
        end
        local center = (min + max) * 0.5
        local front = _Vector3new(center.X, center.Y, max.Z)
        return _CFramenew(center, front), max - min
    end
    local function worldToScreen(world)
        local screen, inBounds = _WorldToViewportPoint(camera, world)
        return _Vector2new(screen.X, screen.Y), inBounds, screen.Z
    end
    local function calculateCorners(cframe, size)
        local corners = table.create(#VERTICES)
        for i = 1, #VERTICES do
            corners[i] = worldToScreen((cframe + size * 0.5 * VERTICES[i]).Position)
        end
        local min = _Vector2zeromin(camera.ViewportSize, unpack(corners))
        local max = _Vector2zeromax(Vector2.zero, unpack(corners))
        return {
            corners = corners,
            topLeft = _Vector2new(mathfloor(min.X), mathfloor(min.Y)),
            topRight = _Vector2new(mathfloor(max.X), mathfloor(min.Y)),
            bottomLeft = _Vector2new(mathfloor(min.X), mathfloor(max.Y)),
            bottomRight = _Vector2new(mathfloor(max.X), mathfloor(max.Y))
        }
    end
    local get_mainpart = function(model, modelname)
        if modelname == "corpse" then
            return _FindFirstChild(model, "UpperTorso")
        end
    end
    local identify_model = function(model, modelname)
        if not model then return false, false end
        if modelname == "corpse" and _FindFirstChildOfClass(model, "Humanoid") then
            return model.Name.."'s corpse"
        end
        if modelname == "wreck" then
            if model.Name == "MI24V_Wreck" then
                return "MI-24V Wreck"
            elseif model.Name == "BTR80_Wreck" then
                return "BTR-80 Wreck"
            end
        end
        if modelname == "boss" then
            return model.Name
        end
        return false, false
    end
    local function create_esp(player, isnpc)
        if not player then return end
        if player.ClassName == "Model" then isnpc = true end
        loaded_plrs[player] = {
            obj = {
                box_fill = esp.create_obj("Square", { Filled = true, Visible = false }),
                box_outline = esp.create_obj("Square", { Filled = false, Thickness = 3, Visible = false, ZIndex = -1 }),
                box = esp.create_obj("Square", { Filled = false, Thickness = 1, Visible = false }),
                realname = esp.create_obj("Text", { Center = true, Visible = false, Text = player.Name }),
                displayname = esp.create_obj("Text", { Center = true, Visible = false, Text = isnpc and "" or player.Name == player.DisplayName and "" or player.DisplayName }),
                healthtext = esp.create_obj("Text", { Center = false, Visible = false }),
                health_bar_cap_top = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 2 }),
                health_bar_cap_bottom = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 2 }),
                dist = esp.create_obj("Text", { Center = true, Visible = false }),
                weapon = esp.create_obj("Text", { Center = true, Visible = false }),
            },
            chams_object = Instance.new("Highlight", container),
            chams_active = false,
            chams_original = {},
            last_chams_update = 0,
            plr_instance = player
        }
        for required, _ in next, skeleton_order do
            loaded_plrs[player].obj["skeleton_" .. required] = esp.create_obj("Line", { Visible = false })
        end
        for i = 1, 10 do
            loaded_plrs[player].obj["health_bar_" .. i] = esp.create_obj("Line", { Visible = false, Thickness = 2, ZIndex = 2 })
        end
        for i = 1, 6 do
            loaded_plrs[player].obj["health_bar_glow_" .. i] = esp.create_obj("Line", { Visible = false, ZIndex = 1 })
            loaded_plrs[player].obj["health_bar_glow_cap_top_" .. i] = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 1 })
            loaded_plrs[player].obj["health_bar_glow_cap_bottom_" .. i] = esp.create_obj("Circle", { Visible = false, Filled = true, ZIndex = 1 })
        end
        local plr = loaded_plrs[player]
        local obj = plr.obj
        local esp = plr.esp
        local box = obj.box
        local box_outline = obj.box_outline
        local box_fill = obj.box_fill
        local healthtext = obj.healthtext
        local realname = obj.realname
        local displayname = obj.displayname
        local dist = obj.dist
        local weapon = obj.weapon
        local cham = plr.chams_object
        local cham_original = plr.chams_original
        local settings = esp_table.settings.enemy
        local main_settings = esp_table.main_settings
        local character = isnpc and player or not isnpc and player.Character
        local head = character and _FindFirstChild(character, "Head")
        local humanoid = character and _FindFirstChildOfClass(character, "Humanoid")
        local setvis_cache = false
        local fadetime = main_settings.fadetime
        local fadethread
        function plr:forceupdate()
            fadetime = main_settings.fadetime
            cham.DepthMode = settings.chams_visible_only and 1 or 0
            cham.FillColor = settings.chams_fill_color[1]
            cham.OutlineColor = settings.chamsoutline_color[1]
            cham.FillTransparency = settings.chams_fill_color[2]
            cham.OutlineTransparency = settings.chamsoutline_color[2]
            box.Color = settings.box_color[1]
            box_outline.Color = settings.outline_color[1]
            box_fill.Color = settings.box_fill_color[1]
            realname.Size = main_settings.textSize
            realname.Font = main_settings.textFont
            realname.Color = settings.realname_color[1]
            realname.Outline = settings.outline
            realname.OutlineColor = settings.outline_color[1]
            displayname.Size = main_settings.textSize
            displayname.Font = main_settings.textFont
            displayname.Color = settings.displayname_color[1]
            displayname.Outline = settings.outline
            displayname.OutlineColor = settings.outline_color[1]
            dist.Size = main_settings.textSize
            dist.Font = main_settings.textFont
            dist.Color = settings.dist_color[1]
            dist.Outline = settings.outline
            dist.OutlineColor = settings.outline_color[1]
            weapon.Size = main_settings.textSize
            weapon.Font = main_settings.textFont
            weapon.Color = settings.weapon_color[1]
            weapon.Outline = settings.outline
            weapon.OutlineColor = settings.outline_color[1]
            for required, _ in next, skeleton_order do
                local skeletonobj = obj["skeleton_" .. required]
                if skeletonobj then
                    skeletonobj.Color = settings.skeleton_color[1]
                end
            end
            box.Transparency = settings.box_color[2]
            box_outline.Transparency = settings.outline_color[2]
            box_fill.Transparency = settings.box_fill_color[2]
            realname.Transparency = settings.realname_color[2]
            displayname.Transparency = settings.displayname_color[2]
            dist.Transparency = settings.dist_color[2]
            weapon.Transparency = settings.weapon_color[2]
            for required, _ in next, skeleton_order do
                obj["skeleton_" .. required].Transparency = settings.skeleton_color[2]
            end

            for i = 1, 10 do
                if obj["health_bar_"..i] then
                    obj["health_bar_"..i].Thickness = settings.health_thickness
                end
            end
            if setvis_cache then
                cham.Enabled = settings.chams
                box.Visible = settings.box
                box_outline.Visible = settings.outline
                box_fill.Visible = settings.box_fill
                realname.Visible = settings.realname
                displayname.Visible = settings.displayname
                obj.health_bar_cap_top.Visible = settings.health
                obj.health_bar_cap_bottom.Visible = settings.health
                for i = 1, 6 do
                    if obj["health_bar_glow_"..i] then
                        obj["health_bar_glow_"..i].Visible = settings.health
                        obj["health_bar_glow_cap_top_"..i].Visible = settings.health
                        obj["health_bar_glow_cap_bottom_"..i].Visible = settings.health
                    end
                end
                for i = 1, 10 do
                    if obj["health_bar_"..i] then
                        obj["health_bar_"..i].Visible = settings.health
                    end
                end
                dist.Visible = settings.dist
                weapon.Visible = settings.weapon
                for required, _ in next, skeleton_order do
                    local skeletonobj = obj["skeleton_" .. required]
                    if (skeletonobj) then
                        skeletonobj.Visible = settings.skeleton
                    end
                end
            end
        end
        function plr:togglevis(bool, fade)
            if setvis_cache ~= bool then
                setvis_cache = bool
                if not bool then
                        for _, v in obj do v.Visible = false end
                        cham.Enabled = false
                else
                    cham.Enabled = settings.chams
                    box.Visible = settings.box
                    box_outline.Visible = settings.outline
                    box_fill.Visible = settings.box_fill
                    realname.Visible = settings.realname
                    displayname.Visible = settings.displayname
                    healthtext.Visible = false -- disabled for neon bar
                    obj.health_bar_cap_top.Visible = settings.health
                    obj.health_bar_cap_bottom.Visible = settings.health
                    for i = 1, 6 do
                        if obj["health_bar_glow_"..i] then
                            obj["health_bar_glow_"..i].Visible = settings.health
                            obj["health_bar_glow_cap_top_"..i].Visible = settings.health
                            obj["health_bar_glow_cap_bottom_"..i].Visible = settings.health
                        end
                    end
                    for i = 1, 10 do
                        obj["health_bar_"..i].Visible = settings.health
                    end
                    dist.Visible = settings.dist
                    weapon.Visible = settings.weapon
                    for required, _ in next, skeleton_order do
                        local skeletonobj = obj["skeleton_" .. required]
                        if (skeletonobj) then
                            skeletonobj.Visible = settings.skeleton
                        end
                    end
                end
            end
        end
        plr.connection = cheat.utility.new_renderstepped(function(delta)
            if whitelisted_players[player.Name] then
                return plr:togglevis(false)
            end
            local plr = loaded_plrs[player]
            if not settings.enabled then
                return plr:togglevis(false)
            end
            character = isnpc and player or not isnpc and player.Character
            humanoid = character and _FindFirstChildOfClass(character, "Humanoid")
            head = character and _FindFirstChild(character, "Head")

            local is_heli = isnpc and (character.Name == "MI24V" or character.Name == "BTR80")
            if is_heli then
                local pilots = _FindFirstChild(character, "Pilots")
                head = character:FindFirstChild("CollisionPilot", true) or character:FindFirstChild("Mi24_Prop_M", true)
                humanoid = humanoid or { Health = character:GetAttribute("Health") or 1000, MaxHealth = 1000, Parent = character }
            end

            if not (character and head and humanoid and character.Parent and (head.Parent or is_heli) and (humanoid.Parent or is_heli)) then
                if main_settings.infiniterange and not isnpc then
                    local res = (function()
                        local rp_plr = _FindFirstChild(ReplicatedStorage.Players, player.Name)
                        local plrstatus = rp_plr and _FindFirstChild(rp_plr, "Status")
                        local worldpos = plrstatus and _FindFirstChild(plrstatus, "UAC") and _FindFirstChild(plrstatus, "UAC"):GetAttribute("LastVerifiedPos")
                        local screenpos, onscreen = typeof(worldpos) == "Vector3" and worldToScreen(worldpos)
                        if not (onscreen) then return false end
                        realname.Position = screenpos
                        realname.Text = player.Name .. " ["..mathround((worldpos - camera.CFrame.p).Magnitude / 3).."]"
                        return true
                    end)();
                    plr:togglevis(false)
                    realname.Visible = res
                    return
                else
                    realname.Visible = false
                    return plr:togglevis(false)
                end
            end
            local _, onScreen = _WorldToViewportPoint(camera, head.Position)
            if not onScreen then
                return plr:togglevis(false)
            end
            local humanoid_distance = (camera.CFrame.p - head.Position).Magnitude
            local humanoid_health = humanoid.Health

            if plr.last_health and humanoid_health < plr.last_health then
                local hitmarker_recent = cheat.utility.last_hitmarker_tick and (tick() - cheat.utility.last_hitmarker_tick < 0.25)
                if hitmarker_recent and cheat.Toggles.killeffect and cheat.Toggles.killeffect.Value then
                    cheat.utility.spawn_kill_effect(head.Position)
                end
            end
            plr.last_health = humanoid_health

            if humanoid_health <= 0 then
                if not plr.was_dead then
                    plr.was_dead = true
                end
                return plr:togglevis(false)
            else
                plr.was_dead = false
            end
            local humanoid_max_health = humanoid.MaxHealth
            local corners do
                if plr.last_character ~= character then
                    plr.last_character = character
                    plr.body_parts = {}
                    plr._skel_parts = nil
                    local check_descendants = isnpc and (character.Name == "MI24V" or character.Name == "BTR80")
                    local parts_to_check = check_descendants and character:GetDescendants() or character:GetChildren()
                    for _, part in parts_to_check do
                        if _IsA(part, "BasePart") and isBodyPart(part.Name) then
                            plr.body_parts[#plr.body_parts + 1] = part
                        end
                    end
                end
                local cache = plr.body_parts
                if not cache or #cache <= 0 then return plr:togglevis(false) end
                corners = calculateCorners(getBoundingBox(cache))
            end
            plr:togglevis(true)
            cham.Adornee = character

            local is_vis = false
            if settings.outline_vis then
                if not plr.last_vis_check or (os.clock() - plr.last_vis_check) > 0.15 then
                    plr.last_vis_check = os.clock()
                    plr.is_vis_cached = cheat.utility.is_visible(camera.CFrame, character, head)
                end
                is_vis = plr.is_vis_cached or false
            end
            local is_manip = false
            if settings.outline_manip then
                local sa_state = cheat.silent_aim
                if sa_state and sa_state.target_part and sa_state.manipulated and sa_state.manipulated_origin then
                    local sa_tp = sa_state.target_part
                    if sa_tp.Parent and character and sa_tp:IsDescendantOf(character) then
                        is_manip = true
                    end
                end
            end
            do
                local is_cheater = false
                if not isnpc and settings.high_kd_marker then
                    if not plr._kd_cached_time or (os.clock() - plr._kd_cached_time) > 2 then
                        plr._kd_cached_time = os.clock()
                        local pfolder = ReplicatedStorage:FindFirstChild("Players") and ReplicatedStorage.Players:FindFirstChild(player.Name)
                        local stats_obj = pfolder and (pfolder:FindFirstChild("WipeStatistics", true) or pfolder:FindFirstChild("Statistics", true))
                        if stats_obj then
                            local kills = stats_obj:GetAttribute("Kills") or 0
                            local deaths = stats_obj:GetAttribute("Deaths") or 0
                            local ratio = kills / math.max(1, deaths)
                            plr._kd_is_cheater = ratio > 5
                        else
                            plr._kd_is_cheater = false
                        end
                    end
                    is_cheater = plr._kd_is_cheater or false
                end

                local pos = corners.topLeft
                local size = corners.bottomRight - corners.topLeft
                box.Position = pos
                box.Size = size
                local drawingFix = getgenv().DrawingFix
                if drawingFix then
                    box_outline.Position = pos - _Vector2new(1, 1)
                    box_outline.Size = size + _Vector2new(2, 2)
                else
                    box_outline.Position = pos
                    box_outline.Size = size
                end
                box_fill.Position = pos
                box_fill.Size = size

                if is_cheater then
                    box_outline.Color = settings.high_kd_outline_color
                    box_outline.Transparency = 1
                elseif settings.outline_manip and is_manip then
                    box_outline.Color = settings.outline_manip_color[1]
                    box_outline.Transparency = settings.outline_manip_color[2]
                elseif settings.outline_vis and is_vis then
                    box_outline.Color = settings.outline_vis_color[1]
                    box_outline.Transparency = settings.outline_vis_color[2]
                else
                    box_outline.Color = settings.outline_color[1]
                    box_outline.Transparency = settings.outline_color[2]
                end
            end
            do
                local min_healthbar_height = 5
                local healthbar_top_y = corners.topLeft.Y
                if (corners.bottomLeft.Y - corners.topLeft.Y) < min_healthbar_height then
                    healthbar_top_y = corners.bottomLeft.Y - min_healthbar_height
                end
                local top_text_y = math.min(corners.topLeft.Y, healthbar_top_y)

                local pos = _Vector2new((corners.topLeft.X + corners.topRight.X) * 0.5, top_text_y) - Vector2.yAxis
                realname.Position = pos - (Vector2.yAxis * realname.TextBounds.Y) - _Vector2new(0, 2)
                displayname.Position = pos - Vector2.yAxis * displayname.TextBounds.Y - (realname.Visible and Vector2.yAxis * realname.TextBounds.Y or Vector2.zero)

                local name_str = player.Name
                if not isnpc and settings.high_kd_marker and loaded_plrs[player]._kd_is_cheater then
                    name_str = "[CHEATER] " .. name_str
                end
                realname.Text = name_str

                if settings.outline_manip and is_manip then
                    realname.OutlineColor = settings.outline_manip_color[1]
                elseif settings.outline_vis and is_vis then
                    realname.OutlineColor = settings.outline_vis_color[1]
                else
                    realname.OutlineColor = settings.outline_color[1]
                end
                if settings.outline_manip and is_manip then
                    displayname.OutlineColor = settings.outline_manip_color[1]
                elseif settings.outline_vis and is_vis then
                    displayname.OutlineColor = settings.outline_vis_color[1]
                else
                    displayname.OutlineColor = settings.outline_color[1]
                end
            end
            do
                local pos = (corners.bottomLeft + corners.bottomRight) * 0.5
                dist.Text = mathround(humanoid_distance / 3) .. " meters"
                dist.Position = pos
                if not plr._gun_cache_time or (os.clock() - plr._gun_cache_time) > 0.5 then
                    plr._gun_cache_time = os.clock()
                    plr._gun_cache_text = isnpc and "" or esp_table.get_gun(player)
                end
                weapon.Text = plr._gun_cache_text or ""
                weapon.Position = pos + (dist.Visible and Vector2.yAxis * dist.TextBounds.Y - _Vector2new(0, 2) or Vector2.zero)

                if settings.outline_manip and is_manip then
                    dist.OutlineColor = settings.outline_manip_color[1]
                elseif settings.outline_vis and is_vis then
                    dist.OutlineColor = settings.outline_vis_color[1]
                else
                    dist.OutlineColor = settings.outline_color[1]
                end
                if settings.outline_manip and is_manip then
                    weapon.OutlineColor = settings.outline_manip_color[1]
                elseif settings.outline_vis and is_vis then
                    weapon.OutlineColor = settings.outline_vis_color[1]
                else
                    weapon.OutlineColor = settings.outline_color[1]
                end
            end
            -- Neon Gradient Health Bar
            healthtext.Visible = false
            local h_percent = math.clamp(humanoid_health / humanoid_max_health, 0, 1)
            local bar_start = corners.bottomLeft - _Vector2new(6, 0)
            local bar_end = corners.topLeft - _Vector2new(6, 0)

            local min_healthbar_height = 5
            if (bar_start.Y - bar_end.Y) < min_healthbar_height then
                bar_end = bar_start - _Vector2new(0, min_healthbar_height)
            end

            local glow_color = settings.health_color_top:Lerp(settings.health_color_bottom, 0.5)

            for i = 1, 6 do
                local glow = obj["health_bar_glow_"..i]
                local cap_top = obj["health_bar_glow_cap_top_"..i]
                local cap_bottom = obj["health_bar_glow_cap_bottom_"..i]

                if settings.health and h_percent > 0 then
                    local th = (i / 6) * settings.health_glow_size
                    local tr = 0.3 - (i * 0.04)

                    glow.Visible = true
                    glow.From = bar_start
                    glow.To = bar_start:Lerp(bar_end, h_percent)
                    glow.Color = glow_color
                    glow.Thickness = th
                    glow.Transparency = tr

                    cap_top.Visible = true
                    cap_top.Position = bar_start:Lerp(bar_end, h_percent)
                    cap_top.Color = glow_color
                    cap_top.Radius = th / 2
                    cap_top.Transparency = tr

                    cap_bottom.Visible = true
                    cap_bottom.Position = bar_start
                    cap_bottom.Color = glow_color
                    cap_bottom.Radius = th / 2
                    cap_bottom.Transparency = tr
                else
                    glow.Visible = false
                    cap_top.Visible = false
                    cap_bottom.Visible = false
                end
            end

            if settings.health and h_percent > 0 then
                obj.health_bar_cap_top.Visible = true
                obj.health_bar_cap_top.Position = bar_start:Lerp(bar_end, h_percent)
                obj.health_bar_cap_top.Color = settings.health_color_top:Lerp(settings.health_color_bottom, 1 - h_percent)
                obj.health_bar_cap_top.Radius = settings.health_thickness / 2

                obj.health_bar_cap_bottom.Visible = true
                obj.health_bar_cap_bottom.Position = bar_start
                obj.health_bar_cap_bottom.Color = settings.health_color_bottom
                obj.health_bar_cap_bottom.Radius = settings.health_thickness / 2
            else
                obj.health_bar_cap_top.Visible = false
                obj.health_bar_cap_bottom.Visible = false
            end

            for i = 1, 10 do
                local seg_line = obj["health_bar_"..i]
                if settings.health and i <= math.ceil(h_percent * 10) then
                    seg_line.Visible = true
                    local seg_start = bar_start:Lerp(bar_end, (i - 1) / 10)
                    local seg_end = bar_start:Lerp(bar_end, i / 10)
                    if i == math.ceil(h_percent * 10) then
                        seg_end = bar_start:Lerp(bar_end, h_percent)
                    end
                    seg_line.From = seg_start
                    seg_line.To = seg_end
                    local col_percent = 1 - (i / 10)
                    seg_line.Color = settings.health_color_top:Lerp(settings.health_color_bottom, col_percent)
                else
                    seg_line.Visible = false
                end
            end
            if settings.skeleton then
                if not plr._skel_parts then
                    plr._skel_parts = {}
                    for _, part in next, character:GetChildren() do
                        local parent_name = skeleton_order[part.Name]
                        if parent_name then
                            local parent_instance = _FindFirstChild(character, parent_name)
                            local line = obj["skeleton_" .. part.Name]
                            if parent_instance and line then
                                plr._skel_parts[#plr._skel_parts + 1] = { part = part, parent = parent_instance, line = line }
                            end
                        end
                    end
                end
                for i = 1, #plr._skel_parts do
                    local entry = plr._skel_parts[i]
                    if entry.part.Parent and entry.parent.Parent then
                        local part_position = _WorldToViewportPoint(camera, entry.part.Position)
                        local parent_part_position = _WorldToViewportPoint(camera, entry.parent.Position)
                        entry.line.From = _Vector2new(part_position.X, part_position.Y)
                        entry.line.To = _Vector2new(parent_part_position.X, parent_part_position.Y)
                    end
                end
            end
            cham.Adornee = character
            cham.Enabled = settings.chams
            if settings.chams then
                if tick() - plr.last_chams_update >= 2 then
                    plr.chams_active = true
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not cham_original[part] then
                                cham_original[part] = { Material = part.Material, Color = part.Color, Transparency = part.Transparency }
                            end
                            part.Material = Enum.Material[settings.chams_material or "Neon"]
                            part.Color = settings.chams_fill_color[1]
                            part.Transparency = 0
                            local sa = part:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                        end
                    end
                    plr.last_chams_update = tick()
                end
            elseif plr.chams_active then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and cham_original[part] then
                        part.Material = cham_original[part].Material
                        part.Color = cham_original[part].Color
                        part.Transparency = cham_original[part].Transparency
                        cham_original[part] = nil
                    end
                end
                plr.chams_active = false
                plr.last_chams_update = 0
            end
        end)
        plr:forceupdate()
    end
    local function create_object_esp(model, modelname)
        if not model then return end
        local espname = identify_model(model, modelname)
        if not (espname) then return end
        loaded_plrs[model] = {
            obj = {
                name = esp.create_obj("Text", { Center = true, Visible = false, Text = espname }),
            },
            modeltype = modelname
        }
        local plr = loaded_plrs[model]
        local obj = plr.obj
        local realname = obj.name

        local main_settings = esp_table.main_settings
        local object_settings = esp_table.settings[modelname] or esp_table.settings.corpse

        local setvis_cache = false
        function plr:forceupdate()
            realname.Size = main_settings.textSize
            realname.Font = main_settings.textFont
            realname.Color = object_settings.color
            realname.Outline = object_settings.outline
            realname.OutlineColor = object_settings.outline_color
            realname.Transparency = 1
        end
        function plr:togglevis(bool)
            if setvis_cache ~= bool then
                for _, v in obj do v.Visible = bool end
                setvis_cache = bool
            end
        end
        plr.connection = cheat.utility.new_heartbeat(function(delta)
            local plr = loaded_plrs[model]
            if not object_settings.enabled then
                return plr:togglevis(false)
            end

            local mainpart = get_mainpart(model, modelname)
            local worldPos = mainpart and mainpart.Position or model:GetPivot().Position
            local position, onscreen = worldToScreen(worldPos)
            if not onscreen then
                return plr:togglevis(false)
            end

            local str = ""
            if object_settings.name then str = espname end
            if object_settings.distance then
                local dist = math.floor((Camera.CFrame.p - worldPos).Magnitude / 4)
                if str ~= "" then str = str .. " [" .. dist .. "m]" else str = "[" .. dist .. "m]" end
            end

            if str == "" then
                return plr:togglevis(false)
            end

            realname.Text = str
            realname.Position = position
            plr:togglevis(true)
        end)
        plr:forceupdate()
    end
    local function destroy_esp(player)
        if not loaded_plrs[player] then return end
        loaded_plrs[player].connection:Disconnect()
        for i,v in loaded_plrs[player].obj do
            v:Remove()
        end
        if loaded_plrs[player].chams_object then
            loaded_plrs[player].chams_object:Destroy()
        end
        loaded_plrs[player] = nil
    end
    function esp_table.load()
        assert(not esp_table.__loaded, "[ESP] already loaded");
        local shortcut = function(is_obj, remove, name)
            return function(model)(remove and destroy_esp or (is_obj and create_object_esp or create_esp))(model, is_obj and name or nil) end;
        end
        for i, v in next, plrs:GetPlayers() do
            if v ~= lplr then create_esp(v) end
        end
        for _, folder in next, workspace.AiZones:GetChildren() do
            for _, npc in next, folder:GetChildren() do
                create_esp(npc, true)
            end
        end
        for _, item in next, workspace.DroppedItems:GetChildren() do
            create_object_esp(item, "corpse")
        end
        
        -- Add wreck objects
        local function check_and_add_wreck(obj)
            if obj.Name == "MI24V_Wreck" or obj.Name == "BTR80_Wreck" then
                create_object_esp(obj, "wreck")
            end
        end
        
        for _, child in pairs(workspace:GetChildren()) do
            check_and_add_wreck(child)
        end
        
        -- Boss objects (specific names)
        local boss_names = {"Mi24V", "BTR80", "Whisper", "Dozer", "Anton", "ScavKing", "Grif"}
        local function is_boss(name)
            for _, bname in ipairs(boss_names) do
                if name == bname then return true end
            end
            return false
        end
        
        local function check_and_add_boss(obj)
            if is_boss(obj.Name) then
                create_object_esp(obj, "boss")
            end
        end
        
        for _, child in pairs(workspace:GetChildren()) do
            check_and_add_boss(child)
        end
        
        esp_table.objectAdded = {
            plrs.PlayerAdded:Connect(shortcut(false, false)),
            workspace.DroppedItems.ChildAdded:Connect(shortcut(true, false, "corpse")),
            workspace.ChildAdded:Connect(function(obj)
                if obj.Name == "MI24V_Wreck" or obj.Name == "BTR80_Wreck" then
                    create_object_esp(obj, "wreck")
                elseif is_boss(obj.Name) then
                    create_object_esp(obj, "boss")
                end
            end)
        };
        esp_table.objectRemoving = {
            plrs.PlayerRemoving:Connect(shortcut(false, true)),
            workspace.DroppedItems.ChildRemoved:Connect(shortcut(true, true, "corpse")),
            workspace.ChildRemoved:Connect(function(obj)
                destroy_esp(obj)
            end)
        };
        for _, __no in pairs(workspace.AiZones:GetChildren()) do
            esp_table.objectAdded[#esp_table.objectAdded + 1] = __no.ChildAdded:Connect(shortcut(false, false))
            esp_table.objectRemoving[#esp_table.objectRemoving + 1] = __no.ChildRemoved:Connect(shortcut(false, true))
        end
        esp_table.__loaded = true;
    end
    function esp_table.unload()
        assert(esp_table.__loaded, "[ESP] not loaded yet");
        for player, _ in next, loaded_plrs do
            destroy_esp(player)
        end
        for _, connection in next, esp_table.objectAdded do
            connection:Disconnect()
        end
        for _, connection in next, esp_table.objectRemoving do
            connection:Disconnect()
        end
        esp_table.__loaded = false;
    end
    function esp_table.get_gun(player)
        local Player = _FindFirstChild(ReplicatedStorage.Players, player.Name);
        if Player and _FindFirstChild(Player, "Status") and _FindFirstChild(Player.Status, "GameplayVariables") and _FindFirstChild(Player.Status.GameplayVariables, "EquippedTool") and Player.Status.GameplayVariables.EquippedTool.Value then
            local Equipped = Player.Status.GameplayVariables.EquippedTool.Value;
            return tostring(Equipped);
        end;
        return "None";
    end
    function esp_table.icaca()
        for _, v in loaded_plrs do
            task.spawn(function() v:forceupdate() end)
        end
    end
    cheat.EspLibrary = esp_table
end)()
local is_visible = cheat.utility.is_visible
local function is_pos_visible(posfrom, posto, target)
    if not (target and target_part and cframe) then return false end
    vischeck_params.FilterDescendantsInstances = { workspace.NoCollision, Camera, LocalPlayer.Character }
    local castresults = _Raycast(workspace, posfrom, posto - posfrom, vischeck_params)
    return (
        castresults and castresults.Instance and _IsDescendantOf(castresults.Instance, target) or
        not (castresults and castresults.Instance)
    )
end
local function predict_velocity(Origin, Destination, DestinationVelocity, ProjectileSpeed)
    local Distance = (Destination - Origin).Magnitude;
    local TimeToHit = (Distance / ProjectileSpeed);
    local Predicted = Destination + DestinationVelocity * TimeToHit;
    local Delta = (Predicted - Origin).Magnitude / ProjectileSpeed;
    TimeToHit = TimeToHit + (Delta / ProjectileSpeed);
    local Actual = Destination + DestinationVelocity * TimeToHit;
    return Actual;
end;
local function bezier_point(points, t)
    local n = #points
    if n == 1 then return points[1] end
    local new_points = {}
    for i = 1, n - 1 do
        new_points[i] = points[i]:Lerp(points[i + 1], t)
    end
    return bezier_point(new_points, t)
end

local function predict_drop(Origin, Destination, ProjectileSpeed, ProjectileDrop)
    if ProjectileDrop == 0 then return 0 end
    local Distance = (Destination - Origin).Magnitude;
    local TimeToHit = (Distance / ProjectileSpeed);
    TimeToHit = TimeToHit + (Distance / ProjectileSpeed);
    local DropTime = ProjectileDrop * TimeToHit ^ 2;
    if tostring(DropTime):find("nan") or (Distance <= 100) then
        return 0
    end;
    return DropTime;
end;
local function is_pos_wallbanged(posfrom, posto, target)
    return true
end

local function get_closest_target(usefov, fov_size, aimpart, npc, is_rage, rage_dist, target_heli, require_triggerable, allow_manip, manip_origin, prefer_ug)
    local ermm_part, isnpc = nil, false
    local maximum_distance = is_rage and rage_dist or (usefov and fov_size or math.huge)
    local mousepos = _Vector2new(Mouse.X, Mouse.Y)
    local ug_only = false
    local ug_y_threshold = Camera.CFrame.Position.Y - 1.5

    local function is_triggerable(parent, part)
        if is_visible(Camera.CFrame, parent, part) then return true end
        if is_pos_wallbanged(Camera.CFrame.p, part.Position, parent) then return true end
        if allow_manip and manip_origin then
            local p = RaycastParams.new()
            p.FilterType = Enum.RaycastFilterType.Exclude
            local noc = workspace:FindFirstChild("NoCollision")
            if noc then p.FilterDescendantsInstances = {LocalPlayer.Character, Camera, noc}
            else p.FilterDescendantsInstances = {LocalPlayer.Character, Camera} end
            local res = workspace:Raycast(manip_origin, part.Position - manip_origin, p)
            if not res or (res.Instance and res.Instance:IsDescendantOf(parent)) then return true end
        end
        return false
    end

    local function process_player(plr)
        if plr ~= LocalPlayer and not whitelisted_players[plr.Name] then
            local character = plr.Character
            if character then
                local part = _FindFirstChild(character, aimpart)
                local humanoid = _FindFirstChildOfClass(character, "Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    if ug_only and part.Position.Y >= ug_y_threshold then
                        return false
                    end
                    local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
                    local distance = is_rage and ((Camera.CFrame.p - part.Position).Magnitude / 3) or (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
                    if (is_rage or onscreen) and distance <= maximum_distance then
                        if require_triggerable then
                            if is_triggerable(character, part) then
                                ermm_part = part
                                maximum_distance = distance
                                isnpc = false
                                return true
                            end
                        elseif not is_rage or is_visible(Camera.CFrame, character, part) or is_pos_wallbanged(Camera.CFrame.p, part.Position, character) then
                            ermm_part = part
                            maximum_distance = distance
                            isnpc = false
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local function scan_prioritized()
        for plr_name, _ in pairs(prioritized_players) do
            if prioritized_players[plr_name] then
                local plr = Players:FindFirstChild(plr_name)
                if plr and process_player(plr) then
                    return true
                end
            end
        end
        return false
    end

    local function scan_world()
        LPH_NO_VIRTUALIZE(function()
            if npc then
                for _, __no in pairs(workspace.AiZones:GetChildren()) do for _, npcs in pairs(__no:GetChildren()) do
                    local part = _FindFirstChild(npcs, aimpart)

                    local is_heli = false
                    if target_heli and (npcs.Name == "MI24V" or npcs.Name == "BTR80") then
                        is_heli = true
                        part = npcs:FindFirstChild("CollisionPilot", true) or npcs:FindFirstChild("Mi24_Prop_M", true)
                    end

                    if not is_heli and (npcs.Name == "MI24V" or npcs.Name == "BTR80") then continue end
                    if ug_only and part and part.Position.Y >= ug_y_threshold then continue end

                    local humanoid = _FindFirstChildOfClass(npcs, "Humanoid")
                    if part and (is_heli or (humanoid and humanoid.Health > 0)) then
                        if (Camera.CFrame.p - part.Position).Magnitude < 2500 then
                            local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
                            local distance = is_rage and ((Camera.CFrame.p - part.Position).Magnitude / 3) or (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
                            if (is_rage or onscreen) and distance < maximum_distance then
                                if require_triggerable then
                                    if is_triggerable(npcs, part) then
                                        ermm_part = part
                                        maximum_distance = distance
                                        isnpc = true
                                    end
                                elseif not is_rage or is_visible(Camera.CFrame, npcs, part) then
                                    ermm_part = part
                                    maximum_distance = distance
                                    isnpc = true
                                end
                            end
                        end
                    end
                end end
            end
            for _, plr in Players:GetPlayers() do
                process_player(plr)
            end
        end)()
    end

    local function run_scan()
        if scan_prioritized() then
            return
        end
        scan_world()
    end

    -- Do a normal closest-to-crosshair scan first so there is always a center-priority
    -- baseline, then optionally refine it with the UG ("under camera") preference.
    run_scan()
    local best_part, best_isnpc, best_distance = ermm_part, isnpc, maximum_distance

    if prefer_ug then
        -- "prioritize ug manip": prefer below-camera targets for manipulation shots, but
        -- keep them close to the aim center. Without the bounded window below, the UG-only
        -- scan would lock onto *any* player below us (up to the old max distance, which is
        -- effectively infinite when no FOV is set), grabbing targets that sit at the edge of
        -- the screen or fully off it.
        ug_only = true
        ermm_part, isnpc = nil, false
        if usefov then
            -- Stay inside the FOV ring so we never snap away from what the user is aiming at.
            maximum_distance = fov_size
        elseif best_distance == math.huge then
            -- No normal target near the cursor: only allow UG targets that are actually
            -- close to the screen center instead of grabbing anything below us.
            maximum_distance = 150
        else
            -- Only take the lock for a UG target that is reasonably close to the current aim
            -- point, never much farther from the crosshair than the normal best target.
            maximum_distance = best_distance + 150
        end

        run_scan()

        if ermm_part then
            return ermm_part, isnpc
        end

        -- No suitable UG target near the center: fall back to the normal result.
        return best_part, best_isnpc
    end

    return best_part, best_isnpc
end
local function make_beam(Origin, Position, Color, Thickness)
    local part1, part2 = Instance.new("Part", workspace.NoCollision), Instance.new("Part", workspace.NoCollision)
    part1.Position = Origin; part2.Position = Position;
    part1.Transparency = 1; part2.Transparency = 1;
    part1.CanCollide = false; part2.CanCollide = false;
    part1.Size = Vector3.zero; part2.Size = Vector3.zero;
    part1.Anchored = true; part2.Anchored = true;
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Beam = Instance.new("Beam", workspace.NoCollision)
    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color),
        ColorSequenceKeypoint.new(1,Color)
    };
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Texture = "http://www.roblox.com/asset/?id=446111271"
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = Thickness or 0.25
    Beam.Width1 = Thickness or 0.25
    return Beam, part1, part2
end

local function make_segmented_tracer(points, Color, Thickness, Lifetime, Smoothness)
    local beams = {}
    local subdivisions = math.max(1, math.floor((Smoothness or 2) * 4))
    for i = 1, #points - 1 do
        local start_point = points[i]
        local end_point = points[i + 1]
        local previous_point = start_point
        for subdivision = 1, subdivisions do
            local next_point = start_point:Lerp(end_point, subdivision / subdivisions)
            local beam, start_part, end_part = make_beam(previous_point, next_point, Color, Thickness)
            table.insert(beams, {beam = beam, start_part = start_part, end_part = end_part})
            previous_point = next_point
        end
    end
    local elapsed = 0
    local connection
    local function cleanup()
        for _, segment in ipairs(beams) do
            if segment.beam and segment.beam.Parent then segment.beam:Destroy() end
            if segment.start_part and segment.start_part.Parent then segment.start_part:Destroy() end
            if segment.end_part and segment.end_part.Parent then segment.end_part:Destroy() end
        end
        if connection then connection:Disconnect() end
    end
    connection = cheat.utility.new_renderstepped(function(delta)
        elapsed = elapsed + delta
        local progress = math.clamp(elapsed / Lifetime, 0, 1)
        local transparency = progress ^ (Smoothness or 2)
        for _, segment in ipairs(beams) do
            if segment.beam.Parent then
                segment.beam.Transparency = NumberSequence.new(transparency)
            end
        end
        if elapsed >= Lifetime then
            cleanup()
        end
    end)
end

local function make_smooth_manipulation_tracer(origin, bend, target, Color, Thickness, Lifetime, Smoothness)
    local beams = {}
    local subdivisions = math.max(8, math.floor((Smoothness or 2) * 8))
    local last_point = origin

    for subdivision = 1, subdivisions do
        local t = subdivision / subdivisions
        local current_point = bezier_point({origin, bend, target}, t)
        local beam, start_part, end_part = make_beam(last_point, current_point, Color, Thickness)
        table.insert(beams, {beam = beam, start_part = start_part, end_part = end_part})
        last_point = current_point
    end

    local elapsed = 0
    local connection
    local function cleanup()
        for _, segment in ipairs(beams) do
            if segment.beam and segment.beam.Parent then segment.beam:Destroy() end
            if segment.start_part and segment.start_part.Parent then segment.start_part:Destroy() end
            if segment.end_part and segment.end_part.Parent then segment.end_part:Destroy() end
        end
        if connection then connection:Disconnect() end
    end
    connection = cheat.utility.new_renderstepped(function(delta)
        elapsed = elapsed + delta
        local progress = math.clamp(elapsed / Lifetime, 0, 1)
        local transparency = progress ^ (Smoothness or 2)
        for _, segment in ipairs(beams) do
            if segment.beam.Parent then
                segment.beam.Transparency = NumberSequence.new(transparency)
            end
        end
        if elapsed >= Lifetime then
            cleanup()
        end
    end)
end

local function create_advanced_tracer(Origin, Position, Color1, Color2, Thickness)
    local part1, part2 = Instance.new("Part", workspace.NoCollision), Instance.new("Part", workspace.NoCollision)
    part1.Position = Origin; part2.Position = Position;
    part1.Transparency = 1; part2.Transparency = 1;
    part1.CanCollide = false; part2.CanCollide = false;
    part1.Size = Vector3.zero; part2.Size = Vector3.zero;
    part1.Anchored = true; part2.Anchored = true;
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local colorSeq = ColorSequence.new{ColorSequenceKeypoint.new(0,Color1), ColorSequenceKeypoint.new(0.3,Color2), ColorSequenceKeypoint.new(1,Color2)}
    local CoreBeam = Instance.new("Beam", workspace.NoCollision)
    CoreBeam.Name = "CoreBeam"
    CoreBeam.Color = colorSeq
    CoreBeam.Width0 = Thickness
    CoreBeam.Width1 = Thickness
    CoreBeam.Texture = ""
    CoreBeam.TextureSpeed = 0
    CoreBeam.LightEmission = 1
    CoreBeam.LightInfluence = 0
    CoreBeam.TextureMode = Enum.TextureMode.Stretch
    CoreBeam.Attachment0 = OriginAttachment
    CoreBeam.Attachment1 = PositionAttachment
    CoreBeam.FaceCamera = true
    CoreBeam.Segments = 1
    CoreBeam.Transparency = NumberSequence.new(0)
    local PulseBeam = Instance.new("Beam", workspace.NoCollision)
    PulseBeam.Name = "PulseBeam"
    PulseBeam.Color = colorSeq
    PulseBeam.Width0 = Thickness * 0.5
    PulseBeam.Width1 = Thickness * 0.5
    PulseBeam.Texture = "rbxassetid://446111271"
    PulseBeam.TextureSpeed = 0
    PulseBeam.LightEmission = 1
    PulseBeam.LightInfluence = 0
    PulseBeam.TextureMode = Enum.TextureMode.Stretch
    PulseBeam.Attachment0 = OriginAttachment
    PulseBeam.Attachment1 = PositionAttachment
    PulseBeam.FaceCamera = true
    PulseBeam.Segments = 1
    PulseBeam.Transparency = NumberSequence.new(0)
    return {CoreBeam, PulseBeam}, part1, part2
end


local silent_aim = {
    enabled = false,
    triggerbot = false,
    target_ai = false,
    target_heli = false,
    testwallbang = true,
    part = "Head",
    random_part = false,
    fov = false,
    fov_show = false,
    fov_color = Color3.new(1, 1, 1),
    fov_outline = false,
    fov_outline_color = Color3.new(0, 0, 0),
    fov_size = 100,
    fov_glow_intensity = 1,
    indicator = false,
    indicator_text = "",
    nospread = false,
    instant = false,
    crosshair_status = false,
    status_bar_width = 100,
    status_bar_height = 6,
    status_bar_offset = 32,
    corner_shoot = false,
    corner_shoot_dist = 5,
    force_wallbang = false,
    prioritize_ug_manip = false,
    manipulated = false,
    manipulated_origin = nil,
    target_part = nil, is_npc = false, isvisible = false,
    instantreload = false,
    tracer = false,
    tracer_style = "Tracer 1",
    tracer_color = Color3.new(1, 1, 1),
    tracer_color2 = Color3.new(0, 0.5, 1),
    tracer_thickness = 0.5,
    tracer_lifetime = 1,
    tracer_smoothness = 2,
        miss_distance = 2,
    hitchance = 100,
    tipanel_x = 20,
    tipanel_y = 350,
    show_cr_on_target = false,
    rage_bot = false,
    rage_max_dist = 500,
    lift_hitboxes = false,
    lift_hitboxes_height = 2,
    magic_bullet = true,
}
cheat.silent_aim = silent_aim
do
    local curve_raycast_params = RaycastParams.new()
    local magic_bullet_magnet = 5
    local magic_bullet_segments = 20
    curve_raycast_params.FilterType = Enum.RaycastFilterType.Exclude
    curve_raycast_params.CollisionGroup = "WeaponRay"
    curve_raycast_params.IgnoreWater = true



    local function bezier_tangent(points, t)
        local dt = 0.001
        local t0 = math.max(0, t - dt)
        local t1 = math.min(1, t + dt)
        local p0 = bezier_point(points, t0)
        local p1 = bezier_point(points, t1)
        return (p1 - p0).Unit
    end

    local function find_obstacles_between(origin, destination)
        local char = LocalPlayer.Character
        curve_raycast_params.FilterDescendantsInstances = { workspace.NoCollision, Camera, char }
        local obstacles = {}
        local direction = destination - origin
        local distance = direction.Magnitude
        
        local results = workspace:Raycast(origin, direction, curve_raycast_params)

        if results then
            table.insert(obstacles, {
                position = results.Position,
                normal = results.Normal,
                fraction = results.Distance / distance
            })
        end

        return obstacles
    end

    local function compute_curve_control_points(origin, destination)
        local obstacles = find_obstacles_between(origin, destination)
        if #obstacles == 0 then
            return nil
        end
        local points = { origin }
        local magnet = magic_bullet_magnet

        for _, obs in ipairs(obstacles) do
            -- First control point to go around the obstacle
            local offset1 = obs.normal * magnet
            local ctrl1 = obs.position + offset1
            table.insert(points, ctrl1)

            -- Second control point to smooth the curve after the obstacle
            local point_after_obs = origin:Lerp(destination, obs.fraction + 0.1) -- 10% of the way after the obstacle
            local offset2 = obs.normal * (magnet * 0.5) -- less agressive correction
            local ctrl2 = point_after_obs + offset2
            table.insert(points, ctrl2)
        end

        table.insert(points, destination)
        return points
    end

    local function get_curved_direction(origin, destination)
        local control_points = compute_curve_control_points(origin, destination)
        if not control_points then
            return (destination - origin).Unit
        end
        return bezier_tangent(control_points, 0)
    end

    local ignorelist=require(ReplicatedStorage.Modules.UniversalTables).ReturnTable("GlobalIgnoreListProjectile")
    local function get_local_weapon()
        local Player = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
        if Player and Player:FindFirstChild("Status") and Player.Status:FindFirstChild("GameplayVariables") and Player.Status.GameplayVariables:FindFirstChild("EquippedTool") and Player.Status.GameplayVariables.EquippedTool.Value then
            local Equipped = Player.Status.GameplayVariables.EquippedTool.Value
            return Equipped.Name
        end
        return "None"
    end
    local shoot_debounce = tick()
    local rpplrs = ReplicatedStorage.Players
    local bulletmodule = require(ReplicatedStorage.Modules.FPS.Bullet)
    local CreateBullet = require(ReplicatedStorage.Modules.FPS.Bullet).CreateBullet
    local ProjectileInflict = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ProjectileInflict")
    local FireProjectile = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FireProjectile")
    function cheat.shoot_weapon(speedmult)
        local weapon = get_local_weapon()
        local rpinv = rpplrs[LocalPlayer.Name] and rpplrs[LocalPlayer.Name].Inventory
        local aimpart = Camera and _FindFirstChild(Camera, "ViewModel") and _FindFirstChild(Camera.ViewModel, "AimPart")
        local inv_weapon = rpinv and _FindFirstChild(rpinv, weapon)
        local charweapon = LocalPlayer.Character and _FindFirstChild(LocalPlayer.Character, weapon)
        local magazine = inv_weapon and _FindFirstChild(inv_weapon, "Attachments") and _FindFirstChild(inv_weapon.Attachments, "Magazine") and inv_weapon.Attachments.Magazine:FindFirstChildOfClass("StringValue")
        local loadedammo = magazine and magazine.ItemProperties:FindFirstChild("LoadedAmmo") and magazine.ItemProperties.LoadedAmmo:FindFirstChildOfClass("Folder")
        if weapon ~= "None" and rpinv and aimpart and inv_weapon and _FindFirstChild(inv_weapon, "SettingsModule") and charweapon and loadedammo then
            local weapon_settings = require(_FindFirstChild(inv_weapon, "SettingsModule"))
            if rawget(weapon_settings, "FireRate") and shoot_debounce <= tick() then
                local bullet_type = loadedammo:GetAttribute("AmmoType")
                CreateBullet(bulletmodule, inv_weapon, LocalPlayer.Character:FindFirstChild(weapon),
                Camera:FindFirstChild("ViewModel"), "Idle", bullet_type, 0, 1, Camera.ViewModel:FindFirstChild("AimPart"))
                shoot_debounce = tick() + (rawget(weapon_settings, "FireRate") * speedmult)
            end
        end
    end
    function cheat.shoot_weapon_packet(isvis, speedmult, prediction, hitscan, hitscanwalls)
        local weapon = get_local_weapon()
        local rpinv = _FindFirstChild(rpplrs, LocalPlayer.Name) and rpplrs[LocalPlayer.Name].Inventory
        local inv_weapon = rpinv and weapon and _FindFirstChild(rpinv, weapon)
        local aimpart = Camera and _FindFirstChild(Camera, "ViewModel") and _FindFirstChild(Camera.ViewModel, "AimPart")
        if inv_weapon and _FindFirstChild(inv_weapon, "SettingsModule") then
            local weapon_settings = require(_FindFirstChild(inv_weapon, "SettingsModule"))
            if rawget(weapon_settings, "FireRate") and shoot_debounce <= tick() then
                local real_orig = Camera.CFrame.p
                if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                    real_orig = silent_aim.manipulated_origin
                elseif cheat.freecam_enabled then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Head") then real_orig = char.Head.Position end
                end


                local dist = silent_aim.target_part and (silent_aim.target_part.Position - real_orig).Magnitude or 0
                autoshootdelay = tick() - (dist / 1000)
                local rnd = math.random(-10000, 10000)
                if silent_aim then silent_aim._exact_fire_tick = tick() end

                local as_dir
                if silent_aim.target_part then
                    local aim_position = silent_aim.target_part.Position
                    if math.random(1, 100) > silent_aim.hitchance then
                        local miss_direction = Vector3.new(
                            math.random() * 2 - 1,
                            math.random() * 2 - 1,
                            math.random() * 2 - 1
                        )
                        if miss_direction.Magnitude > 0 then
                            aim_position = aim_position + miss_direction.Unit * silent_aim.miss_distance
                        end
                    end
                    if silent_aim.magic_bullet then
                        as_dir = get_curved_direction(real_orig, aim_position)
                    else
                        as_dir = (aim_position - real_orig).Unit
                    end
                else
                    as_dir = Vector3.new(0, 1, 0)
                end
                if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                    trigger_tp_peek(0.5)
                end

                if FireProjectile:InvokeServer(as_dir, rnd, autoshootdelay) then
                    ProjectileInflict:FireServer(
                        silent_aim.target_part,
                        silent_aim.target_part.CFrame:ToObjectSpace(CFrame.new(0, 0.0001, 0)),
                        rnd,
                        tick()
                    )
                    if silent_aim.tracer then
                        local t_orig = real_orig
                        if not cheat.freecam_enabled then
                            t_orig = aimpart and aimpart.Position or Camera.CFrame.p
                        end
                        if silent_aim.manipulated_origin then
                            make_smooth_manipulation_tracer(t_orig, silent_aim.manipulated_origin, silent_aim.target_part.Position, silent_aim.tracer_color, silent_aim.tracer_thickness, silent_aim.tracer_lifetime, silent_aim.tracer_smoothness)
                        else
                            local drawing, deleteme, deleteme1 = make_beam(t_orig, silent_aim.target_part.Position, silent_aim.tracer_color, silent_aim.tracer_thickness)
                            local wtf = -1
                            local conn; conn = cheat.utility.new_renderstepped(function(delta)
                                wtf = wtf + delta
                                drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1) ^ (silent_aim.tracer_smoothness or 2))
                                if wtf >= 1 then
                                    drawing:Destroy()
                                    deleteme:Destroy()
                                    deleteme1:Destroy()
                                    conn:Disconnect()
                                end
                            end)
                        end
                    end
                end
                shoot_debounce = tick() + (rawget(weapon_settings, "FireRate") * speedmult)
            end
        end
    end
end
do
    local norecoil, nobob = false, false
    local instantreload, forceauto, instantaim = false, false, false
    local instantreload_speed = 100000
    -- Hand-loaded guns (Izh12/Izh81 etc, reloadType == "loadByHand") insert
    -- shells one at a time via animation markers: the reload track fires a
    -- "BulletIn" marker per shell -> Reload:InvokeServer per shell, and a
    -- "LoopTo" marker that restarts the loop. At 100000x speed the animation
    -- jumps past those markers every frame, so NO shells get loaded and the
    -- track instantly ends ("reload" finishes with an empty gun). Magazine-fed
    -- guns don't have this problem because the mag-swap remote isn't marker
    -- driven. So hand-load weapons get a fast but marker-safe speed instead.
    local instantreload_handload_speed = 6
    local instant_reload_weapons = {
        NagantRevolver = true,
        Mosin = true,
        SKS = true,
        IZh12 = true,
        IZh81 = true,
    }
    local shootwhile_reloading = false
    local autoreload = false
    local autoreload_force = false
    local omni_action = false
    local current_fps = nil

    local function is_instant_reload_weapon(fps)
        local weapon = fps and fps.weapon
        weapon = weapon and (weapon.Value or weapon)
        if not weapon then return false end
        -- case-insensitive lookup so naming variations (Izh12 vs IZh12) still match
        local lname = string.lower(weapon.Name)
        for name in pairs(instant_reload_weapons) do
            if string.lower(name) == lname then return true end
        end
        return false
    end
    -- hand-loaded (tube fed / break action) guns: shells are added per animation
    -- marker, so they need a marker-safe speed instead of instantreload_speed
    local function is_handload_weapon(fps)
        return fps ~= nil and fps.reloadType == "loadByHand"
    end
    local function get_instantreload_speed(fps)
        return (fps and is_handload_weapon(fps)) and instantreload_handload_speed or instantreload_speed
    end
    -- full set of reload-sequence animations: the reload itself plus the chamber/
    -- bolt/hammer/empty tracks the game plays alongside it
    local reload_anim_words = { "reload", "bolt", "chamber", "hammer", "empty" }
    local function is_reload_anim_name(name)
        local lname = string.lower(name)
        if lname:find("cancel") then return false end
        for _, word in ipairs(reload_anim_words) do
            if lname:find(word) then return true end
        end
        return false
    end
    local autoshoot, packetautoshoot, packetpred, packetscan, packetthruscan, shootspeed = false, false, false, false, false, 1
    local target_part, is_npc, isvisible;
    local instant_equip = false
    local rapid_fire = false
    local rapid_fire_delay = 0.05
    local unlock_firemodes = false
    local salobox = ui.tabs.combat:AddLeftGroupbox('silent aim')
    local gunmodbox = ui.box.mods:AddTab('gun mods')
    local got_that = false
    repeat LPH_JIT_MAX(function()
        for i, gc in next, getgc(true) do
            if type(gc) == "table" then
                if rawget(gc, "shove") and rawget(gc, "update") then
                    local shove, update = (gc.shove), (gc.update)
                    cheat.utility.new_hook(shove, function(old, ...)
                        return norecoil or old(...)
                    end, true)
                    cheat.utility.new_hook(update, function(old, ...)
                        return nobob and Vector3.zero or old(...)
                    end, true)
                end
                if type(rawget(gc, "create")) == "function" and getinfo(gc.create).short_src == "ReplicatedStorage.Modules.SpringV2" then
                    local old_create = (gc.create)
                    cheat.utility.new_hook(old_create, function(old, ...)
                        local returns = old(...)
                        local shove, update = (returns.shove), (returns.update)
                        returns.shove = function(...)
                            return norecoil or shove(...)
                        end
                        returns.update = function(...)
                            return nobob and Vector3.zero or update(...)
                        end
                        return returns
                    end, true)
                end
                if rawget(gc, "CreateBullet") then
                    local old_bullet = gc.CreateBullet
                    cheat.utility.new_hook(old_bullet, LPH_JIT_MAX(function(old, self, ...)
                        local args = { ... };
                        local argCount = select("#", ...);
                        if silent_aim.enabled or silent_aim.rage_bot then
                            local loadedammo, aimpart_index do
                                for i, v in args do
                                    if typeof(v) == "Instance" and v.Name == "AimPart" then
                                        aimpart_index = i
                                    end
                                    if type(v) == "string" then
                                        local tmp = _FindFirstChild(ReplicatedStorage.AmmoTypes, v)
                                        if tmp then loadedammo = tmp end
                                    end
                                end
                            end
                            if not (loadedammo and aimpart_index) then
                                return old(self, unpack(args, 1, argCount))
                            end
                            if silent_aim.tracer then
                                local manipulated_origin = silent_aim.manipulated_origin
                                local tracer_target = silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000
                                if manipulated_origin then
                                    make_smooth_manipulation_tracer(args[aimpart_index].Position, manipulated_origin, tracer_target, silent_aim.tracer_color, silent_aim.tracer_thickness, silent_aim.tracer_lifetime, silent_aim.tracer_smoothness)
                                elseif silent_aim.tracer_style == "Tracer 2" then
                                    local t_orig = silent_aim.manipulated_origin or args[aimpart_index].Position
                                    local beams, d1, d2 = create_advanced_tracer(t_orig, silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000, silent_aim.tracer_color, silent_aim.tracer_color2, silent_aim.tracer_thickness)
                                    local lifetime = silent_aim.tracer_lifetime
                                    local t = 0
                                    local conn; conn = cheat.utility.new_renderstepped(function(delta)
                                        t = t + delta
                                        local trans = math.clamp((t / lifetime) ^ 2, 0, 1)
                                        local pulse = (math.sin(t * 20) + 1) / 2
                                        for _, b in pairs(beams) do 
                                            b.Transparency = NumberSequence.new(trans) 
                                            if b.Name == "PulseBeam" then
                                                b.Width0 = silent_aim.tracer_thickness * (0.5 + pulse)
                                                b.Width1 = silent_aim.tracer_thickness * (0.5 + pulse)
                                            end
                                        end
                                        if t >= lifetime then
                                            for _, b in pairs(beams) do b:Destroy() end
                                            d1:Destroy(); d2:Destroy(); conn:Disconnect()
                                        end
                                    end)
                                elseif silent_aim.tracer_style == "Beam" then
                                    local t_orig = silent_aim.manipulated_origin or args[aimpart_index].Position
                                    local t_end = silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000
                                    
                                    local StartPart = Instance.new("Part", workspace.NoCollision)
                                    local EndPart = Instance.new("Part", workspace.NoCollision)
                                    StartPart.Transparency = 1
                                    StartPart.Size = Vector3.new(0.05, 0.05, 0.05)
                                    StartPart.Anchored = true
                                    StartPart.CanCollide = false
                                    StartPart.Position = t_orig
                                    
                                    EndPart.Transparency = 1
                                    EndPart.Size = Vector3.new(0.05, 0.05, 0.05)
                                    EndPart.Anchored = true
                                    EndPart.CanCollide = false
                                    EndPart.Position = t_end
                                    
                                    local StartAttachment = Instance.new("Attachment", StartPart)
                                    local EndAttachment = Instance.new("Attachment", EndPart)
                                    
                                    local Beam = Instance.new("Beam", workspace.NoCollision)
                                    Beam.Color = ColorSequence.new(silent_aim.tracer_color)
                                    Beam.Enabled = true
                                    Beam.FaceCamera = true
                                    Beam.Attachment0 = StartAttachment
                                    Beam.Attachment1 = EndAttachment
                                    Beam.Width0 = silent_aim.tracer_thickness * 2
                                    Beam.Width1 = silent_aim.tracer_thickness * 2
                                    Beam.LightEmission = 1
                                    Beam.LightInfluence = 0
                                    Beam.Texture = "rbxassetid://446111271"
                                    Beam.TextureLength = 14
                                    Beam.TextureSpeed = 12
                                    Beam.TextureMode = Enum.TextureMode.Wrap
                                    
                                    task.spawn(function()
                                        task.wait(0.2)
                                        local SpeedTween = TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                                        local CreatedTween = game:GetService("TweenService"):Create(Beam, SpeedTween, { TextureSpeed = 2 })
                                        CreatedTween:Play()
                                    end)
                                    
                                    task.delay(silent_aim.tracer_lifetime, function()
                                        local Tween = game:GetService("TweenService"):Create(Beam, TweenInfo.new(1), {
                                            Width0 = 0,
                                            Width1 = 0,
                                            TextureSpeed = 0,
                                        })
                                        Tween:Play()
                                        Tween.Completed:Wait()
                                        Beam:Destroy()
                                        StartPart:Destroy()
                                        EndPart:Destroy()
                                    end)
                                elseif silent_aim.tracer_style == "Curved" then
                                    local t_orig = silent_aim.manipulated_origin or args[aimpart_index].Position
                                    local t_end = silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000
                                    
                                    local distance = (t_end - t_orig).Magnitude
                                    local dir = (t_end - t_orig).Unit

                                    local p0 = t_orig
                                    local p3 = t_end
                                    local p1 = t_orig + dir * (distance * 0.3)
                                    
                                    local side_dir = dir:Cross(Vector3.new(0, 1, 0)).Unit
                                    if side_dir.Magnitude < 0.1 then side_dir = dir:Cross(Vector3.new(0,0,1)).Unit end
                                    
                                    local curve_magnitude = math.clamp(distance / 100, 2, 20)
                                    local p2 = t_orig:Lerp(t_end, 0.5) + side_dir * curve_magnitude
                                    
                                    local control_points = {p0, p1, p2, p3}

                                    if silent_aim.magic_bullet then
                                        local obstacle_points = compute_curve_control_points(t_orig, t_end)
                                        if obstacle_points then
                                            control_points = obstacle_points
                                        end
                                    end

                                    -- Safely get bullet properties with defaults
                                    local projectile_speed = loadedammo and loadedammo:GetAttribute("MuzzleVelocity") or 1000
                                    local projectile_drop = loadedammo and loadedammo:GetAttribute("BulletDrop") or 0

                                    local beams, parts = {}, {}
                                    local segments = magic_bullet_segments
                                    local last_pos = t_orig
                                    
                                    for i = 1, segments do
                                        local t = i / segments
                                        local current_pos = bezier_point(control_points, t)

                                        if projectile_drop > 0 then
                                            local drop = predict_drop(t_orig, t_orig:Lerp(t_end,t), projectile_speed, projectile_drop)
                                            current_pos = current_pos - Vector3.new(0, drop, 0)
                                        end

                                        local part1 = Instance.new("Part", workspace.NoCollision)
                                        part1.Position = last_pos; part1.Transparency = 1; part1.CanCollide = false; part1.Anchored = true; part1.Size = Vector3.one * 0.1
                                        table.insert(parts, part1)
                                        
                                        local part2 = Instance.new("Part", workspace.NoCollision)
                                        part2.Position = current_pos; part2.Transparency = 1; part2.CanCollide = false; part2.Anchored = true; part2.Size = Vector3.one * 0.1
                                        table.insert(parts, part2)
                                
                                        local attachment1 = Instance.new("Attachment", part1)
                                        local attachment2 = Instance.new("Attachment", part2)
                                
                                        local beam = Instance.new("Beam", workspace.NoCollision)
                                        beam.Name = "CurvedBeam_Segment"; beam.Color = ColorSequence.new(silent_aim.tracer_color); beam.Width0 = silent_aim.tracer_thickness; beam.Width1 = silent_aim.tracer_thickness
                                        beam.Attachment0 = attachment1; beam.Attachment1 = attachment2
                                        beam.FaceCamera = true; beam.Segments = 1; beam.Transparency = NumberSequence.new(0)
                                        table.insert(beams, beam)

                                        last_pos = current_pos
                                    end

                                    task.delay(silent_aim.tracer_lifetime, function()
                                        for _, beam in ipairs(beams) do beam:Destroy() end
                                        for _, part in ipairs(parts) do part:Destroy() end
                                    end)
                                else
                                    local real_orig = Camera.CFrame.p
                                    if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                                        real_orig = silent_aim.manipulated_origin
                                    elseif cheat.freecam_enabled then
                                        local char = LocalPlayer.Character
                                        if char and char:FindFirstChild("Head") then real_orig = char.Head.Position end
                                    end
                                    local t_orig = real_orig
                                    if not (silent_aim.corner_shoot and silent_aim.manipulated_origin) and not cheat.freecam_enabled then
                                        t_orig = args[aimpart_index].Position
                                    end
                                    local tracer_target = silent_aim.target_part and silent_aim.target_part.Position or args[aimpart_index].CFrame.LookVector * 10000
                                    local drawing, deleteme, deleteme1 = make_beam(t_orig, tracer_target, silent_aim.tracer_color, silent_aim.tracer_thickness)
                                    local wtf = -1
                                    local conn; conn = cheat.utility.new_renderstepped(function(delta)
                                        wtf = wtf + delta
                                            drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1) ^ (silent_aim.tracer_smoothness or 2))
                                        if wtf >= 1 then
                                            drawing:Destroy()
                                            deleteme:Destroy()
                                            deleteme1:Destroy()
                                            conn:Disconnect()
                                        end
                                    end)
                                end
                            end
                            if silent_aim.instant then
                                return old(self, unpack(args, 1, argCount))
                            end
                            if not silent_aim.target_part or silent_aim.instant then
                                return old(self, unpack(args, 1, argCount))
                            end
                            local ProjectileSpeed = loadedammo:GetAttribute("MuzzleVelocity")
                            local Destination = silent_aim.target_part.Position
                            if silent_aim.lift_hitboxes then
                                local lift_h = silent_aim.lift_hitboxes_height or 2
                                Destination = Destination + Vector3.new(0, lift_h, 0)
                            end
                            local DestinationVelocity = silent_aim.target_part.Velocity
                            local Origin = Camera.CFrame.p
                            local real_aimpart = args[aimpart_index]
                            local old_cf = real_aimpart.CFrame
                            if silent_aim.magic_bullet then
                                local curve_dir = get_curved_direction(real_aimpart.Position, Destination)
                                local look_target = real_aimpart.Position + curve_dir * 1000
                                real_aimpart.CFrame = _CFramenew(real_aimpart.Position, look_target)
                            else
                                real_aimpart.CFrame = _CFramenew(real_aimpart.Position, Destination)
                            end
                            local ret = old(self, unpack(args, 1, argCount))
                            real_aimpart.CFrame = old_cf
                            return ret
                        else
                            return old(self, ...)
                        end
                    end), true)
                end
                if type(rawget(gc, "reload")) == "function" then
                    local old_reload = gc.reload
                    cheat.utility.new_hook(old_reload, LPH_JIT_MAX(function(old, self, ...)
                        -- remember the fps object so auto reload can call reload on it later
                        current_fps = self
                        local result = old(self, ...)
                        if instantreload and self and is_instant_reload_weapon(self) then
                            -- snapshot the weapon / equip id up front: fps:unequip()
                            -- clears self.weapon, so we need the refs saved first
                            local equip_id = self.equipId
                            -- 1) fill the mag client-side: the HUD/sniper count the
                            --    gun reads comes from the inventory magazine's
                            --    ItemProperties.LoadedAmmo children, so topping it up
                            --    here makes the gun immediately usable/full. For
                            --    magazine-fed guns this is the "extract the mag into
                            --    inventory + put bullets in it + put it back" step.
                            pcall(function()
                                local inv_weapon = weapon_obj and weapon_obj.Value
                                local mag_slot = inv_weapon and inv_weapon:FindFirstChild("Attachments")
                                    and inv_weapon.Attachments:FindFirstChild("Magazine")
                                local mag_item = mag_slot and mag_slot.Value
                                local props = mag_item and mag_item:FindFirstChild("ItemProperties")
                                local loaded = props and props:FindFirstChild("LoadedAmmo")
                                local max_ammo = props and props:GetAttribute("MaxLoadedAmmo") or 0
                                if loaded and max_ammo and max_ammo > 0 then
                                    local template = loaded:FindFirstChildOfClass("Folder")
                                    while #loaded:GetChildren() < max_ammo do
                                        local clone = template and template:Clone()
                                        if not clone then break end
                                        clone.Parent = loaded
                                    end
                                end
                                -- client-side state so the gun can fire right away
                                if max_ammo and max_ammo > 0 then
                                    self.Bullets = max_ammo
                                    self.RecoilPatternPos = 0
                                end
                            end)
                            -- 2) kill the reload animation so reloading launches
                            --    with no visible animation. Hand-loaded guns keep
                            --    the (sped up) track because shells are loaded per
                            --    animation marker; magazine guns get it stopped.
                            local handload = is_handload_weapon(self)
                            local reload_speed = get_instantreload_speed(self)
                            local function speed_reload_tracks(tracks)
                                for _, track in pairs(tracks or {}) do
                                    if typeof(track) == "Instance" and track:IsA("AnimationTrack") and track.IsPlaying then
                                        if handload then
                                            if track.Name:lower():find("reload") then
                                                track:AdjustSpeed(reload_speed)
                                            end
                                        elseif is_reload_anim_name(track.Name) then
                                            track:Stop(0)
                                        end
                                    end
                                end
                            end
                            pcall(function()
                                speed_reload_tracks(self.clientAnimationTracks)
                                speed_reload_tracks(self.serverAnimationTracks)
                                -- some weapons (pistols) start the reload track a frame later,
                                -- so re-apply the speed shortly after the reload begins
                                task.delay(0.05, function()
                                    if self and (self.isEquipped or self.reloading) then
                                        speed_reload_tracks(self.clientAnimationTracks)
                                        speed_reload_tracks(self.serverAnimationTracks)
                                    end
                                end)
                                task.delay(0.2, function()
                                    if self and self.reloading then
                                        speed_reload_tracks(self.clientAnimationTracks)
                                        speed_reload_tracks(self.serverAnimationTracks)
                                    end
                                end)
                            end)
                        end
                        return result
                    end), true)
                end
                if type(rawget(gc, "updateClient")) == "function" then
                    local old_update = gc.updateClient
                    cheat.utility.new_hook(old_update, LPH_JIT_MAX(function(old, ...)
                        local args = {...};
                        local argCount = select("#", ...);
                        -- keep a live reference to the fps object so the omni-/auto-reload
                        -- heartbeats can use it
                        current_fps = args[1]
                        -- shoot while reloading: the useTypes fire logic checks
                        -- self.reloading inside updateClient's task.spawn, so
                        -- briefly hide the flag for this call only
                        local saved_reloading = nil
                        if shootwhile_reloading and args[1] and type(args[1]) == "table"
                            and args[1].reloading == true and args[1].isEquipped then
                            saved_reloading = true
                            args[1].reloading = false
                        end
                        if instantaim then
                            args[1].AimInSpeed = 0
                            args[1].AimOutSpeed = 0
                        end;
                        if forceauto then
                            args[1].FireMode = "Auto"
                        end
                        if unlock_firemodes and rawget(args[1], "FireModes") then
                            args[1].FireModes = {
                                "Auto",
                                "Semi"
                            }
                        end
                        if rapid_fire then
                            args[1].FireRate = rapid_fire_delay
                        end
                        local result = old(unpack(args, 1, argCount))
                        if saved_reloading and args[1] and type(args[1]) == "table" then
                            -- restore only if the reload is still actually needed:
                            -- if the game finished it during this call (mag now full)
                            -- we must not resurrect the flag and soft-lock the weapon
                            local b = tonumber(args[1].Bullets) or 0
                            local m = tonumber(args[1].MaxAmmo) or 0
                            if args[1].reloading == false and m > 0 and b < m then
                                args[1].reloading = true
                            end
                        end
                        return result
                    end), true)
                    got_that = true
                end
            end
        end
    end)() if not got_that then print("didnt get that") task.wait(1) end until got_that

    -- Aggressive auto reload: triggers a reload whenever the equipped weapon's
    -- magazine is not full (not just empty). Uses the game's own fps:reload()
    -- captured in current_fps by the reload hook above.
    -- Also enforces instant reload continuously: AnimationTrack:Play() resets
    -- speed to 1, so a one-shot AdjustSpeed at hook time gets overwritten for
    -- most weapons - re-applying it every frame while reloading fixes that.
    -- Only applies to the recognized equipped weapons above.
    local function enforce_instant_reload_speed()
        local fps = current_fps
        if not (instantreload and fps and fps.reloading and is_instant_reload_weapon(fps)) then return end
        local handload = is_handload_weapon(fps)
        local reload_speed = get_instantreload_speed(fps)
        pcall(function()
            local function handle_tracks(tracks)
                for _, track in pairs(tracks or {}) do
                    if typeof(track) == "Instance" and track:IsA("AnimationTrack") and track.IsPlaying then
                        if handload then
                            -- hand-loaded guns need the animation markers
                            -- (BulletIn / LoopTo) firing to load shells, so
                            -- keep the track playing, just sped up
                            if track.Name:lower():find("reload") then
                                track:AdjustSpeed(reload_speed)
                            end
                        elseif is_reload_anim_name(track.Name) then
                            -- magazine-fed guns: the mag-swap remote is sent
                            -- the moment reload() is called and the cheat
                            -- fills the mag client-side, so the animation is
                            -- pure cosmetics - kill it completely (includes
                            -- bolt/chamber/hammer/empty sub-animations)
                            track:Stop(0)
                        end
                    end
                end
            end
            handle_tracks(fps.clientAnimationTracks)
            handle_tracks(fps.serverAnimationTracks)
        end)
    end
    -- Backup shell pump for hand-loaded guns (Izh12/Izh81): shells are loaded
    -- per animation marker, which can still be missed. While the reload is
    -- active, directly send the same per-shell remote the game's marker handler
    -- sends (Reload:InvokeServer(nil, 1, ammoItem)) until the gun is full.
    local last_shell_pump = 0
    local function pump_handload_shells()
        local fps = current_fps
        if not (instantreload and fps and fps.reloading and fps.isEquipped and is_handload_weapon(fps)) then return end
        local now = tick()
        if now - last_shell_pump < 0.1 then return end
        last_shell_pump = now
        pcall(function()
            local bullets = tonumber(fps.Bullets) or 0
            local max_ammo = tonumber(fps.MaxAmmo) or 0
            if bullets >= max_ammo or max_ammo <= 0 then return end
            local remote = ReplicatedStorage and ReplicatedStorage:FindFirstChild("Remotes")
            remote = remote and remote:FindFirstChild("Reload")
            if not remote then return end
            -- find the ammo item in the player inventory, same logic as the
            -- game's loadByHand (CompatibleAmmo + PreferredAmmo)
            local ip = fps.itemProperties
            local comp = ip and ip:FindFirstChild("CompatibleAmmo")
            if not comp then return end
            local preferred = ip:GetAttribute("PreferredAmmo")
            local inv = fps.rs_Player and fps.rs_Player:FindFirstChild("Inventory")
            if not inv then return end
            local ammo_item
            for _, entry in ipairs(inv:GetChildren()) do
                local sub = entry:FindFirstChild("Inventory")
                if sub then
                    for _, item in ipairs(sub:GetChildren()) do
                        if comp:GetAttribute(item.Name) then
                            if not ammo_item or item.Name == preferred then
                                ammo_item = item
                            end
                        end
                    end
                end
            end
            if ammo_item then
                remote:InvokeServer(nil, 1, ammo_item)
            end
        end)
    end
    -- Omni action: lets you keep moving at full (sprint) speed while firing /
    -- doing anything else, i.e. no slowdowns when shooting while sprinting.
    -- climbing, swimming, etc. The fire coroutine resets fps.sprinting=false
    -- on every shot, so we re-apply sprinting every frame while the mouse is held
    -- so the move-speed code keeps using sprint speed instead of dropping to walk.

    cheat.utility.new_heartbeat(LPH_JIT_MAX(function()
        if not omni_action then return end
        local fps = current_fps
        if not (fps and fps.isEquipped) then return end
        if fps.MouseHeld then
            -- keep sprinting=true so MovementSpeed keeps full walk speed (no slowdown)
            fps.sprinting = true
            -- and keep the sprint attribute the game reads in sync so it stays sprinting
            local spr_track = fps.rs_Player and fps.rs_Player.Status and fps.rs_Player.Status.GameplayVariables and fps.rs_Player.Status.GameplayVariables.Sprinting
            if spr_track then spr_track:SetAttribute("Value", true) end
        end
    end))
    -- Auto reload: triggers a reload whenever the equipped weapon's magazine is
    -- not full. Fires one reload then waits for the weapon's real ReloadLength
    -- (or until Bullets change) before triggering again - spamming the reload
    -- remote resets the server-side reload window, which DELAYS the ammo.
    local last_auto_reload = 0
    local last_auto_bullets = -1
    -- auto reload: triggers a reload when the mag is EMPTY. When the "force"
    -- option is on it will also reload whenever the mag isn't full (so it keeps
    -- being topped up even at 99/100). The old percentage sliders are gone -
    -- the behavior is hardcoded to empty-or-force. Fires one reload then waits
    -- for the weapon's real reload timing before triggering again - spamming the
    -- reload remote resets the server-side reload window, which DELAYS the ammo.
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function()
        enforce_instant_reload_speed()
        pump_handload_shells()
        if not autoreload then return end
        local fps = current_fps
        if not (fps and fps.isEquipped and fps.reloadType and fps.reload ~= nil) then return end
        if fps.reloading or fps.cancellingReload or fps.useDebounce then return end
        local bullets = fps.Bullets or 0
        local max_ammo = fps.MaxAmmo or 0
        -- reload when empty, or (force) whenever the mag isn't full
        local should_reload = max_ammo > 0 and bullets == 0
        if autoreload_force then
            should_reload = max_ammo > 0 and bullets < max_ammo
        end
        if should_reload then
            local now = tick()
            -- retry window: prefer the shorter chamber timing when available
            local reload_len = math.max(tonumber(fps.ReloadChamberLength) or tonumber(fps.ReloadLength) or 2.5, 0.4)
            local bullets_changed = bullets ~= last_auto_bullets
            if bullets_changed or (now - last_auto_reload) > reload_len then
                last_auto_reload = now
                last_auto_bullets = bullets
                task.spawn(function()
                    pcall(function() fps:reload() end)
                end)
            end
        else
            -- above the trigger: reset so the next dip fires immediately
            last_auto_bullets = -1
        end
    end))

    gunmodbox:AddToggle('gunmods_rapidfire', {Text = 'rapid fire',Default = false,Callback = function(first)
        rapid_fire = first
    end})
    gunmodbox:AddSlider('gunmods_rapidfire_delay', {Text = 'rapid fire delay', Default = 0.05, Min = 0.01, Max = 0.5, Rounding = 3, Callback = function(v)
        rapid_fire_delay = v
    end})

    gunmodbox:AddToggle('gunmods_norecoil', {Text = 'no recoil',Default = false,Callback = function(first)
        norecoil = first
    end})

    gunmodbox:AddToggle('gunmods_nospread', {Text = 'no spread',Default = false,Callback = function(first)
        silent_aim.nospread = first
    end})
    gunmodbox:AddToggle('gunmods_nobob', {Text = 'no gun bob',Default = false,Callback = function(first)
        nobob = first
    end})
    gunmodbox:AddToggle('gunmods_instantaim', {Text = 'instant aim',Default = false,Callback = function(first)
        instantaim = first
    end})
    gunmodbox:AddToggle('gunmods_instantreload', {Text = 'instant reload',Default = false,Callback = function(first)
        instantreload = first
    end})
    -- status label: shows the currently held weapon while instant reload is on
    local instantreload_label = gunmodbox:AddLabel('instant reload: off')
    local last_instantreload_label_text = 'instant reload: off'
    local function set_instantreload_label(text)
        if instantreload_label and instantreload_label.SetText then
            pcall(instantreload_label.SetText, instantreload_label, text)
        end
    end
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function()
        local fps = current_fps
        local weapon = fps and fps.weapon
        weapon = weapon and (weapon.Value or weapon)
        local text
        if instantreload and weapon then
            text = 'instant reload: holding ' .. weapon.Name
        elseif instantreload then
            text = 'instant reload: no weapon'
        else
            text = 'instant reload: off'
        end
        -- only touch the UI when the text actually changed - calling SetText
        -- every frame forces the whole UI to re-layout every frame, which
        -- makes the ESP flicker/lag while instant reloading
        if text ~= last_instantreload_label_text then
            last_instantreload_label_text = text
            set_instantreload_label(text)
        end
    end))
    gunmodbox:AddToggle('gunmods_shootwhilereloading', {Text = 'shoot while reloading',Default = false,Tooltip = 'allows firing mid-reload (still requires bullets in the mag)',Callback = function(first)
        shootwhile_reloading = first
    end})
gunmodbox:AddToggle('gunmods_omni_action', {Text = 'omni action',Default = false,Tooltip = 'shoot while sprinting/climbing/swimming etc without any slowdowns - keeps you moving at full speed while firing',Callback = function(first)
        omni_action = first
    end})
    gunmodbox:AddToggle('gunmods_autoreload', {Text = 'auto reload',Default = false,Tooltip = 'automatically reloads when the mag is empty',Callback = function(first)
        autoreload = first
    end})
    local autoreload_dep = gunmodbox:AddDependencyBox()
    autoreload_dep:AddToggle('gunmods_autoreload_force', {Text = 'force',Default = false,Tooltip = 'when on, keeps reloading even at 99/100 (whenever the mag isnt full)',Callback = function(first)
        autoreload_force = first
    end})
    autoreload_dep:SetupDependencies({
        { cheat.Toggles.gunmods_autoreload, true }
    })
    gunmodbox:AddToggle('gunmods_unlockfiremodes', {Text = 'unlock firemodes',Default = false,Callback = function(first)
        unlock_firemodes = first
    end})
    salobox:AddToggle('silentaim_enabled', {Text = 'silent aim',Default = false,Callback = function(first)
        silent_aim.enabled = first
    end}):AddKeyPicker('silentaim_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'silent aim bind', NoUI = false})
    salobox:AddToggle('silentaim_instant', {Text = 'instant hit',Default = false,Callback = function(first)
        silent_aim.instant = first
    end})
    salobox:AddToggle('silentaim_wallbang', {Text = 'wallbang',Default = false,Callback = function(first)
        silent_aim.testwallbang = first
    end})
    salobox:AddToggle('silentaim_corner', {Text = 'manipulation',Default = false,Callback = function(first)
        silent_aim.corner_shoot = first
    end})
    -- force wallbang: only visible while manipulation is on. Extends the
    -- manip scan far past the normal distance cap so it brute-forces a
    -- manip origin for everyone, even targets 20+ studs away
    local force_wallbang_dep = salobox:AddDependencyBox()
    force_wallbang_dep:AddToggle('silentaim_force_wallbang', {Text = 'force wallbang',Default = false,Tooltip = 'tries to manip everyone regardless of distance (works past 20 studs)',Callback = function(first)
        silent_aim.force_wallbang = first
    end})
    force_wallbang_dep:SetupDependencies({
        { cheat.Toggles.silentaim_corner, true }
    })
    salobox:AddToggle('silentaim_prioritize_ug_manip', {Text = 'prioritize ug manip', Default = false, Callback = function(v)
        silent_aim.prioritize_ug_manip = v
    end})
    salobox:AddSlider('silentaim_corner_dist', {Text = 'manipulation distance', Default = 5, Min = 5, Max = 15, Rounding = 0, Callback = function(v)
        silent_aim.corner_shoot_dist = v
    end})

    salobox:AddToggle('silentaim_crosshairstat', {Text = 'crosshair target status',Default = false,Callback = function(first)
        silent_aim.crosshair_status = first
    end})
    salobox:AddSlider('silentaim_status_width', {Text = 'status bar width', Default = 100, Min = 10, Max = 300, Rounding = 0, Callback = function(v)
        silent_aim.status_bar_width = v
    end})
    salobox:AddSlider('silentaim_status_height', {Text = 'status bar height', Default = 6, Min = 1, Max = 50, Rounding = 0, Callback = function(v)
        silent_aim.status_bar_height = v
    end})
    salobox:AddSlider('silentaim_status_offset', {Text = 'status bar offset', Default = 32, Min = -100, Max = 200, Rounding = 0, Callback = function(v)
        silent_aim.status_bar_offset = v
    end})

    salobox:AddToggle('silentaim_npcaim', {Text = 'target AI',Default = false,Callback = function(first)
        silent_aim.target_npc = first
    end})

    salobox:AddToggle('silentaim_heliaim', {Text = 'target heli',Default = false,Callback = function(first)
        silent_aim.target_heli = first
    end})

    local resolve_desync = false
    salobox:AddToggle('resolve_desync', {Text = 'resolve desync', Default = false, Callback = function(v)
        resolve_desync = v
    end}):AddKeyPicker('resolve_desync_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'resolve desync'})

    cheat.utility.new_renderstepped(function()
        local rep_players = ReplicatedStorage:WaitForChild("Players")
        -- We loop over all players to handle either desync resolution or hitbox lifting (physically shifting the character models up by 2 studs)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Resolve desync location / lift hitboxes without accumulating offsets
                    local p_folder = rep_players:FindFirstChild(player.Name)
                    local status = p_folder and p_folder:FindFirstChild("Status")
                    local uac = status and status:FindFirstChild("UAC")
                    local lastpos = uac and uac:GetAttribute("LastVerifiedPos")

                    if resolve_desync and lastpos and typeof(lastpos) == "Vector3" then
                        local base_cf = (root.CFrame - root.Position) + lastpos
                        if silent_aim.lift_hitboxes then
                            local lift_h = silent_aim.lift_hitboxes_height or 2
                            root.CFrame = base_cf + Vector3.new(0, lift_h, 0)
                        else
                            root.CFrame = base_cf
                        end
                    else
                        -- Fallback for when LastVerifiedPos is not available or resolver is off (keeps baseline in sync)
                        local current_cf = root.CFrame
                        local last_lifted = root:GetAttribute("LastLiftedCFrame")
                        local base_cf = current_cf

                        if last_lifted and typeof(last_lifted) == "CFrame" then
                            local last_h = root:GetAttribute("LastLiftedHeight") or 2
                            -- If the current Y matches our previously lifted Y closely, we preserve the new horizontal movement (X, Z)
                            -- from Roblox's replication engine but strip our vertical lift to find the true baseline.
                            if math.abs(current_cf.Position.Y - last_lifted.Position.Y) < 0.05 then
                                base_cf = current_cf - Vector3.new(0, last_h, 0)
                            end
                        end

                        if silent_aim.lift_hitboxes then
                            local lift_h = silent_aim.lift_hitboxes_height or 2
                            local new_cf = base_cf + Vector3.new(0, lift_h, 0)
                            root.CFrame = new_cf
                            root:SetAttribute("LastLiftedCFrame", new_cf)
                            root:SetAttribute("LastLiftedHeight", lift_h)
                        else
                            root.CFrame = base_cf
                            root:SetAttribute("LastLiftedCFrame", nil)
                            root:SetAttribute("LastLiftedHeight", nil)
                        end
                    end
                end
            end
        end
    end)
    salobox:AddDropdown('silentaim_hitreg', {Values = {'Head','FaceHitBox','HeadTopHitbox','UpperTorso','LowerTorso','HumanoidRootPart','LeftFoot','LeftLowerLeg','LeftUpperLeg','LeftHand','LeftLowerArm','LeftUpperArm','RightFoot','RightLowerLeg','RightUpperLeg','RightHand','RightLowerArm','RightUpperArm'},Default = 1,Multi = false,Text = 'aim part',Tooltip = 'select part',Callback = function(Value)
        silent_aim.part = Value
    end})

    salobox:AddToggle('silentaim_random_part', {Text = 'randomize hit part', Default = false, Callback = function(Value)
        silent_aim.random_part = Value
    end})
    salobox:AddToggle('silentaim_lifthitbox', {Text = 'lift enemy hitboxes', Default = false, Callback = function(Value)
        silent_aim.lift_hitboxes = Value
    end}):AddKeyPicker('lifthitboxes_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'lift enemy hitboxes', NoUI = false})
    salobox:AddSlider('silentaim_lifthitbox_height', {Text = 'lift height', Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v)
        silent_aim.lift_hitboxes_height = v
    end})
    local tbot_tab = ui.tabs.combat:AddRightGroupbox("trigger bot")
    tbot_tab:AddToggle('triggerbot_enabled', {Text = 'enabled', Default = false, Callback = function(v) silent_aim.triggerbot = v end})
    tbot_tab:AddToggle('triggerbot_manip', {Text = 'shoot on manipulated', Default = false, Callback = function(v) silent_aim.triggerbot_manipulation = v end})

    local triggerbot_active = false
    tbot_tab:AddToggle('triggerbot_mouse1', {Text = 'use mouse1', Default = false, Callback = function(v)
        triggerbot_active = v
    end})

    cheat.utility.new_renderstepped(function()
        if silent_aim.triggerbot and triggerbot_active and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local target_part, is_npc = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_npc, false, 0, silent_aim.target_heli, true, silent_aim.triggerbot_manipulation, silent_aim.manipulated_origin, silent_aim.prioritize_ug_manip)
            if target_part then
                silent_aim.target_part = target_part
                silent_aim.is_npc = is_npc
                cheat.shoot_weapon_packet(true, 1)
            end
        end
    end)




    salobox:AddToggle('silentaim_tracer', {Text = 'bullet tracer',Default = false,Callback = function(Value)
        silent_aim.tracer = Value
    end}):AddColorPicker('silentaim_tracer_color',{Default = Color3.new(1, 1, 1),Title = 'tracer color',Transparency = 0,Callback = function(Value)
        silent_aim.tracer_color = Value
    end}):AddColorPicker('silentaim_tracer_color2',{Default = Color3.new(0, 0.5, 1),Title = 'tracer pulse color',Transparency = 0,Callback = function(Value)
        silent_aim.tracer_color2 = Value
    end})
    salobox:AddDropdown('silentaim_tracer_style', {Values = {'Tracer 1', 'Tracer 2', 'Beam'}, Default = 1, Multi = false, Text = 'tracer style', Callback = function(v) silent_aim.tracer_style = v end})
    salobox:AddSlider('tracer_thickness', { Text = 'tracer thickness', Default = 0.5, Min = 0.1, Max = 10, Rounding = 1, Compact = true, Callback = function(v) silent_aim.tracer_thickness = v end })
    salobox:AddSlider('tracer_lifetime', { Text = 'tracer lifetime', Default = 1, Min = 0.1, Max = 5, Rounding = 1, Compact = true, Callback = function(v) silent_aim.tracer_lifetime = v end })
    salobox:AddSlider('tracer_smoothness', {Text = 'tracer smoothness', Default = 2, Min = 1, Max = 5, Rounding = 1, Compact = true, Callback = function(v)
        silent_aim.tracer_smoothness = v
    end})
    salobox:AddSlider('silentaim_hitchance', {Text = 'hitchance', Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = '%', Compact = true, Callback = function(v)
        silent_aim.hitchance = v
    end})
    salobox:AddSlider('silentaim_miss_distance', {Text = 'miss distance', Default = 2, Min = 0.1, Max = 20, Rounding = 1, Compact = true, Callback = function(v)
        silent_aim.miss_distance = v
    end})
    salobox:AddToggle('silentaim_fov', {Text = 'use fov',Default = false,Callback = function(Value)
        silent_aim.fov = Value
    end})
    salobox:AddToggle('instan t_equip', {Text = 'instant equip', Default = false, Callback = function(v)
        instant_equip = v
    end})
    -- Instant equip: hook camera for ViewModel equip animation
    Camera.ChildAdded:Connect(function(child)
        if not instant_equip then return end
        if child.Name == LocalPlayer.Name then return end
        if not child:IsA("Model") then return end
        task.spawn(function()
            local iters = 0
            while child.Parent and iters < 500 do
                iters = iters + 1
                local hum = child:FindFirstChild("Humanoid")
                if hum and hum.Animator then
                    for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
                        if track.Animation.Name == "Equip" then
                            pcall(function()
                                track:AdjustSpeed(15)
                                track.TimePosition = track.Length - 0.01
                            end)
                            return
                        end
                    end
                end
                task.wait(0.001)
            end
        end)
    end)
    local Depbox1 = salobox:AddDependencyBox();
    Depbox1:AddToggle('silentaim_fov_show', {Text = 'show fov',Default = false,Callback = function(Value)
        silent_aim.fov_show = Value
    end}):AddColorPicker('silentaim_fov_color',{Default = Color3.new(1, 1, 1),Title = 'fov color',Transparency = 0,Callback = function(Value)
        silent_aim.fov_color = Value
    end})
    Depbox1:AddToggle('silentaim_fov_outline', {Text = 'fov outline',Default = false,Callback = function(Value)
        silent_aim.fov_outline = Value
    end})
    Depbox1:AddSlider('silentaim_fov_size',{Text = 'target fov',Default = 100,Min = 10,Max = 1000,Rounding = 0,Compact = true,Callback = function(State)
        silent_aim.fov_size = State
    end})
    Depbox1:AddSlider('silentaim_fov_glow_intensity',{Text = 'glow intensity',Default = 1,Min = 0.1,Max = 10,Rounding = 1,Compact = true,Callback = function(v)
        silent_aim.fov_glow_intensity = v
    end})
    Depbox1:SetupDependencies({
        { cheat.Toggles.silentaim_fov, true }
    });
    local CircleInline = Drawing.new("Circle")
    CircleInline.Transparency = 1
    CircleInline.Thickness = 1
    CircleInline.ZIndex = 2
    local StatusText = Drawing.new("Text")
    StatusText.Size = 16
    StatusText.Center = true
    StatusText.Outline = true
    StatusText.Font = 2
    StatusText.ZIndex = 3
    StatusText.Visible = false
    local StatusBarBg = Drawing.new("Square")
    StatusBarBg.Filled = true
    StatusBarBg.Color = Color3.new(0, 0, 0)
    StatusBarBg.ZIndex = 2
    StatusBarBg.Visible = false
    local StatusBarFill = Drawing.new("Square")
    StatusBarFill.Filled = true
    StatusBarFill.ZIndex = 3
    StatusBarFill.Visible = false
    local fov_glow = {}
    for i = 1, 20 do
        fov_glow[i] = cheat.utility.new_drawing("Circle", {
            Thickness = 1,
            ZIndex = 1,
            Visible = false
        })
    end
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function()
        local pos = (_Vector2new(Mouse.X, Mouse.Y + GuiInset.Y))
        CircleInline.Position = pos
        CircleInline.Radius = silent_aim.fov_size
        CircleInline.Color = silent_aim.fov_color
        CircleInline.Visible = silent_aim.fov and silent_aim.fov_show

        local glow_visible = silent_aim.fov and silent_aim.fov_show and silent_aim.fov_outline
        local intensity = silent_aim.fov_glow_intensity
        local thickness = 1 + (intensity * 0.5)
        for i = 1, 10 do
            -- Outer layers
            local out_circle = fov_glow[i]
            out_circle.Position = pos
            out_circle.Radius = silent_aim.fov_size + (i * (intensity * 0.5))
            out_circle.Color = silent_aim.fov_color
            out_circle.Transparency = (0.2 - (i * 0.02))
            out_circle.Thickness = thickness
            out_circle.Visible = glow_visible

            -- Inner layers
            local in_circle = fov_glow[i+10]
            in_circle.Position = pos
            in_circle.Radius = math.max(0, silent_aim.fov_size - (i * (intensity * 0.5)))
            in_circle.Color = silent_aim.fov_color
            in_circle.Transparency = (0.2 - (i * 0.02))
            in_circle.Thickness = thickness
            in_circle.Visible = glow_visible
        end

        if silent_aim.crosshair_status and silent_aim.target_part then
            local viewport = Camera.ViewportSize
            local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
            local textPos = center + Vector2.new(0, 20 + 6 + (silent_aim.status_bar_offset or 32))

            if silent_aim.isvisible then
                StatusText.Text = "visible"
                StatusText.Color = Color3.new(0, 1, 0)
                StatusText.Position = textPos
                StatusText.Visible = true
            elseif silent_aim.manipulated and silent_aim.manipulated_origin then
                local dist = (silent_aim.manipulated_origin - Camera.CFrame.Position).Magnitude
                StatusText.Text = "manip " .. math.floor(dist + 0.5)
                StatusText.Color = Color3.new(1, 1, 0)
                StatusText.Position = textPos
                StatusText.Visible = true
            else
                StatusText.Visible = false
            end

            StatusBarBg.Visible = false
            StatusBarFill.Visible = false
        else
            StatusText.Visible = false
            StatusBarBg.Visible = false
            StatusBarFill.Visible = false
        end
    end))
    local random_part_timer = tick()
    local available_random_parts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerArm", "RightLowerArm"}

    cheat.utility.new_heartbeat(LPH_NO_VIRTUALIZE(function()
        if silent_aim.random_part and tick() - random_part_timer > (1 / 50) then
            random_part_timer = tick()
            silent_aim.part = available_random_parts[math.random(1, #available_random_parts)]
        end

        local indtxt = ""
        silent_aim.target_part, silent_aim.is_npc = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_npc, silent_aim.rage_bot, silent_aim.rage_max_dist, silent_aim.target_heli, false, silent_aim.corner_shoot, silent_aim.manipulated_origin, silent_aim.prioritize_ug_manip);

        silent_aim.manipulated = false
        local old_origin = silent_aim.manipulated_origin
        silent_aim.manipulated_origin = nil
        if silent_aim.target_part then
            local tp_active = cheat.Toggles and cheat.Toggles.tpkill_enabled and cheat.Toggles.tpkill_enabled.Value
            if silent_aim.corner_shoot and not tp_active then
                local hitpart = silent_aim.target_part
                local camera = workspace.CurrentCamera
                if camera then
                    local base_pos = camera.CFrame.Position
                    local target_pos = hitpart.Position
                    if silent_aim.lift_hitboxes then
                        local lift_h = silent_aim.lift_hitboxes_height or 2
                        target_pos = target_pos + Vector3.new(0, lift_h, 0)
                    end
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local nocollision = workspace:FindFirstChild("NoCollision")
                    if nocollision then
                        params.FilterDescendantsInstances = {LocalPlayer.Character, camera, nocollision}
                    else
                        params.FilterDescendantsInstances = {LocalPlayer.Character, camera}
                    end

                    local res = workspace:Raycast(base_pos, target_pos - base_pos, params)
                    if not res or (res.Instance and res.Instance:IsDescendantOf(hitpart.Parent)) then
                        silent_aim.isvisible = true
                    else
                        silent_aim.isvisible = false
                        local best_origin = nil
                        local best_score = math.huge
                        -- force wallbang: brute-force the scan far past the
                        -- normal 15 stud cap so everyone gets manip'd, even
                        -- targets 20+ studs away
                        local max_dist = silent_aim.force_wallbang and 60 or math.min(15, silent_aim.corner_shoot_dist)

                        -- Scan around the camera, including below it, so
                        -- manipulation can find a valid origin under floors.
                        local right = camera.CFrame.RightVector
                        local up = camera.CFrame.UpVector
                        local down = -up
                        local world_down = _Vector3new(0, -1, 0)
                        local directions = {
                            right,
                            -right,
                            up,
                            down,
                            world_down,
                            (right + up).Unit,
                            (-right + up).Unit,
                            (right + down).Unit,
                            (-right + down).Unit,
                            (right + world_down).Unit,
                            (-right + world_down).Unit
                        }

                        local function try_manip_origin(origin)
                            local offset = origin - base_pos
                            if offset.Magnitude < 1e-4 then
                                return nil
                            end
                            local to_origin_res = workspace:Raycast(base_pos, offset, params)
                            local is_underground = origin.Y < base_pos.Y
                            if to_origin_res and not is_underground then
                                return nil
                            end
                            local scan_res = workspace:Raycast(origin, target_pos - origin, params)
                            if scan_res and not (scan_res.Instance and scan_res.Instance:IsDescendantOf(hitpart.Parent)) then
                                return nil
                            end
                            local buffered_origin = origin + offset.Unit * 1.5
                            local b_to_orig = workspace:Raycast(base_pos, buffered_origin - base_pos, params)
                            local buffered_underground = buffered_origin.Y < base_pos.Y
                            if not b_to_orig or buffered_underground then
                                local b_res = workspace:Raycast(buffered_origin, target_pos - buffered_origin, params)
                                if not b_res or (b_res.Instance and b_res.Instance:IsDescendantOf(hitpart.Parent)) then
                                    return buffered_origin
                                end
                            end
                            return origin
                        end

                        local function score_origin(origin)
                            if not origin then return math.huge end
                            local dist_to_target = (target_pos - origin).Magnitude
                            local dist_to_cam = (base_pos - origin).Magnitude
                            return dist_to_target + (dist_to_cam * 0.4)
                        end

                        local function consider_origin(origin)
                            if not origin then return end
                            local score = score_origin(origin)
                            if score < best_score then
                                best_score = score
                                best_origin = origin
                            end
                        end

                        if silent_aim.prioritize_ug_manip then
                            local to_target = target_pos - base_pos
                            local to_target_h = _Vector3new(to_target.X, 0, to_target.Z)
                            if to_target_h.Magnitude > 1e-4 then
                                to_target_h = to_target_h.Unit
                            else
                                local look = camera.CFrame.LookVector
                                to_target_h = _Vector3new(look.X, 0, look.Z)
                                if to_target_h.Magnitude > 1e-4 then
                                    to_target_h = to_target_h.Unit
                                end
                            end
                            for d = 1, max_dist, 1 do
                                local below = base_pos + world_down * d
                                local laterals = {
                                    _Vector3new(0, 0, 0),
                                    to_target_h * math.min(d, 4),
                                    to_target_h * math.min(d * 0.5, 2),
                                    right * math.min(d, 3),
                                    -right * math.min(d, 3)
                                }
                                for _, lateral in ipairs(laterals) do
                                    consider_origin(try_manip_origin(below + lateral))
                                end
                            end
                        end

                        if not best_origin then
                            for d = 1, max_dist, 1 do
                                for _, dir in ipairs(directions) do
                                    consider_origin(try_manip_origin(base_pos + dir * d))
                                end
                            end
                        end

                        if best_origin then
                            silent_aim.manipulated = true
                            silent_aim.manipulated_origin = best_origin
                        else
                            silent_aim.manipulated_origin = nil
                        end
                    end
                end
            else
                silent_aim.isvisible = is_visible(Camera.CFrame, silent_aim.target_part.Parent, silent_aim.target_part) or false
            end
        else
            silent_aim.isvisible = false
        end

        if silent_aim.target_part then
            indtxt = indtxt..(silent_aim.target_part.Parent.Name)
            if silent_aim.isvisible then
                indtxt = indtxt.." (visible)"
            elseif silent_aim.manipulated and silent_aim.manipulated_origin then
                local dist = (silent_aim.manipulated_origin - Camera.CFrame.Position).Magnitude
                indtxt = indtxt.." (manip. visible (" .. math.floor(dist + 0.5) .. "))"
            end
            if silent_aim.is_npc then
                indtxt = indtxt.." (ai)"
            end
        else
            indtxt = ""
        end
        silent_aim.indicator_text = indtxt
        if autoshoot then
            cheat.shoot_weapon_packet(silent_aim.isvisible, shootspeed, packetpred, packetscan, packetthruscan)
        end

        local triggerable = silent_aim.isvisible
        if silent_aim.triggerbot_manipulation and silent_aim.manipulated_origin ~= nil then
            triggerable = true
        end

        if silent_aim.triggerbot and not triggerable and not triggerbot_active then
            local alt_part, alt_npc = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_npc, false, 0, silent_aim.target_heli, true, silent_aim.triggerbot_manipulation, silent_aim.manipulated_origin, silent_aim.prioritize_ug_manip)
            if alt_part then
                silent_aim.target_part = alt_part
                silent_aim.is_npc = alt_npc
                triggerable = true
            end
        end

        local tp_tbot = cheat.Toggles and cheat.Toggles.tpkill_enabled and cheat.Toggles.tpkill_enabled.Value and cheat.Toggles.tpkill_autotbot and cheat.Toggles.tpkill_autotbot.Value
        if (silent_aim.triggerbot or silent_aim.rage_bot or tp_tbot) and silent_aim.target_part and triggerable then
            if not silent_aim._trigger_held then
                silent_aim._trigger_held = true
                if mouse1press then mouse1press() end
            end
        else
            if silent_aim._trigger_held then
                silent_aim._trigger_held = false
                if mouse1release then mouse1release() end
            end
        end
    end))
end
do
    local espb = ui.box.esp:AddTab("player esp")
    local es = cheat.EspLibrary.settings.enemy
    espb:AddDropdown('espfont',{ Values = { 'UI', 'System', 'Plex', 'Monospace' }, Default = 1, Multi = false, Text = 'esp font', Tooltip = 'select font', Callback = function(a)
        cheat.EspLibrary.main_settings.textFont = Drawing.Fonts[a]; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espfontsize', { Text = 'esp font size', Default = 13, Min = 1, Max = 30, Rounding = 0, Compact = true }):OnChanged(function(b)
        cheat.EspLibrary.main_settings.textSize = b; cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('espinfinite',{ Text = 'infinite range', Default = false, Callback = function(c)
        cheat.EspLibrary.main_settings.infiniterange = c; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espswitch',{ Text = 'enable esp', Default = false, Callback = function(c)
        es.enabled = c; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espbox', { Text = 'box esp', Default = false, Callback = function(c)
        es.box = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espboxcolor',{ Default = Color3.new(1, 1, 1), Title = 'box color', Transparency = 0, Callback = function(a)
        es.box_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espboxfill',{ Text = 'box fill', Default = false, Callback = function(c)
        es.box_fill = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espboxfillcolor',{ Default = Color3.new(1, 1, 1), Title = 'box fill color', Transparency = 0, Callback = function(a)
        es.box_fill_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espoutline',{ Text = 'outline', Default = false, Callback = function(c)
        es.outline = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espoutlinecolor',{ Default = Color3.new(), Title = 'outline color', Transparency = 0, Callback = function(a)
        es.outline_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espoutlinevis',{ Text = 'visible outline', Default = false, Callback = function(c)
        es.outline_vis = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espoutlineviscolor',{ Default = Color3.new(), Title = 'visible outline color', Transparency = 0, Callback = function(a)
        es.outline_vis_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espoutlinemanip',{ Text = 'manipulated outline', Default = false, Callback = function(c)
        es.outline_manip = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espoutlinemanipcolor',{ Default = Color3.fromRGB(255, 255, 0), Title = 'manipulated outline color', Transparency = 0, Callback = function(a)
        es.outline_manip_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espoutlinetransparency',{ Text = 'outline transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.outline_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddSlider('espboxtransparency', { Text = 'box transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.box_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddSlider('espboxfilltransparency', { Text = 'box fill transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.box_fill_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    -- body esp was moved to a new tab
    espb:AddToggle('esprealname',{ Text = 'name esp', Default = false, Callback = function(c)
        es.realname = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('esprealnamecolor',{ Default = Color3.new(1, 1, 1), Title = 'name color', Transparency = 0, Callback = function(a)
        es.realname_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('esprealnametransparency', { Text = 'name transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.realname_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('esphealth', { Text = 'health esp', Default = false, Callback = function(c)
        es.health = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('esphealthcolortop',{ Default = Color3.new(0, 1, 0), Title = 'health color top', Transparency = 0, Callback = function(a)
        es.health_color_top = a; cheat.EspLibrary.icaca()
    end}):AddColorPicker('esphealthcolorbottom',{ Default = Color3.new(1, 0, 0), Title = 'health color bottom', Transparency = 0, Callback = function(a)
        es.health_color_bottom = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('esphealththickness', { Text = 'health bar thickness', Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v)
        es.health_thickness = v; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('esphealthglowsize', { Text = 'health glow size', Default = 5, Min = 1, Max = 20, Rounding = 1, Callback = function(v)
        es.health_glow_size = v; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espdisplayname',{ Text = 'display name esp', Default = false, Callback = function(c)
        es.displayname = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espdisplaynamecolor',{ Default = Color3.new(1, 1, 1), Title = 'display name color', Transparency = 0, Callback = function(a)
        es.displayname_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espdisplaynametransparency',{ Text = 'display name transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.displayname_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('espdistance',{ Text = 'distance esp', Default = false, Callback = function(c)
        es.dist = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espdistancecolor',{ Default = Color3.new(1, 1, 1), Title = 'distance color', Transparency = 0, Callback = function(a)
        es.dist_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espdistancetransparency', { Text = 'distance transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.dist_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('espweapon', { Text = 'weapon esp', Default = false, Callback = function(c)
        es.weapon = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espweaponcolor',{ Default = Color3.new(1, 1, 1), Title = 'weapon color', Transparency = 0, Callback = function(a)
        es.weapon_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espweapontransparency', { Text = 'weapon transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.weapon_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('espskeleton',{ Text = 'skeleton esp', Default = false, Callback = function(c)
        es.skeleton = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espskeletoncolor',{ Default = Color3.new(1, 1, 1), Title = 'skeleton color', Transparency = 0, Callback = function(a)
        es.skeleton_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espskeletontransparency', { Text = 'skeleton transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(b)
        es.skeleton_color[2] = 1 - b; cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('espchams', { Text = 'chams', Default = false, Callback = function(c)
        es.chams = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('espchamsfillcolor',{ Default = Color3.new(1, 1, 1), Title = 'chams color', Transparency = 0, Callback = function(a)
        es.chams_fill_color[1] = a; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('espchamsvisibleonly',{ Text = 'chams visible check', Default = false, Callback = function(c)
        es.chams_visible_only = c; cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espchamstransparency', { Text = 'chams transparency', Default = 0, Min = 0, Max = 1, Rounding = 2, Compact = true, Callback = function(v)
        es.chams_fill_color[2] = v; cheat.EspLibrary.icaca()
    end})
    espb:AddDropdown('espchams_material', { Text = 'chams material', Default = 'Neon', Values = { 'Neon', 'ForceField', 'Glass', 'SmoothPlastic' }, Callback = function(v)
        es.chams_material = v; cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('esp_high_kd_marker', { Text = 'highlight high kd (>5)', Default = false, Callback = function(c)
        es.high_kd_marker = c; cheat.EspLibrary.icaca()
    end}):AddColorPicker('esphighkdcolor', { Default = Color3.fromRGB(255, 0, 0), Title = 'cheater outline color', Transparency = 0, Callback = function(a)
        es.high_kd_outline_color = a; cheat.EspLibrary.icaca()
    end})
    
end
do
    local corpseb = ui.box.esp:AddTab("misc")
    local es = cheat.EspLibrary.settings.corpse

    corpseb:AddLabel("Corpse ESP")
    corpseb:AddToggle("corpseespswitch", {Text = "enable esp", Default = false, Callback = function(first)
        es.enabled = first
        cheat.EspLibrary.icaca()
    end}):AddColorPicker("corpseespcolor", {Default = Color3.fromRGB(0, 255, 0), Title = "color", Transparency = 0, Callback = function(Value)
        es.color = Value
        cheat.EspLibrary.icaca()
    end})

    corpseb:AddToggle("corpseespname", {Text = "show name", Default = true, Callback = function(first)
        es.name = first
        cheat.EspLibrary.icaca()
    end})

    corpseb:AddToggle("corpseespdist", {Text = "show distance", Default = false, Callback = function(first)
        es.distance = first
        cheat.EspLibrary.icaca()
    end})

    corpseb:AddToggle("corpseespoutline", {Text = "outline (name + distance)", Default = false, Callback = function(first)
        es.outline = first
        cheat.EspLibrary.icaca()
    end}):AddColorPicker("corpseespoutlinecolor", {Default = Color3.new(), Title = "outline color", Transparency = 0, Callback = function(Value)
        es.outline_color = Value
        cheat.EspLibrary.icaca()
    end})
    
    corpseb:AddLabel("Inventory")
    corpseb:AddToggle('inventoryviewer', { Text = 'inventory checker window', Default = false, Callback = function(v) if cheat.target_inv_window then cheat.target_inv_window:SetVisible(v) end end })

    corpseb:AddLabel("Item Finder")
    local item_finder_items = {}
    pcall(function()
        local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")
        if ItemsList then
            for _, item in pairs(ItemsList:GetChildren()) do
                local is_melee = false
                local props = item:FindFirstChild("ItemProperties")
                if props and props:GetAttribute("ItemType") == "Melee" then
                    is_melee = true
                end
                if item.Name ~= "Lighter" and not is_melee then
                    table.insert(item_finder_items, item.Name)
                end
            end
        end
    end)
    table.sort(item_finder_items, function(a, b) return string.lower(a) < string.lower(b) end)
    local inv_item_finder = corpseb:AddDropdown('inv_item_finder', { Text = 'Items to Find', Default = {}, Values = item_finder_items, Multi = true, Callback = function() end })
    local finder_toggle = corpseb:AddToggle('inv_finder_enabled', { Text = 'item finder window', Default = false, Callback = function(v) if cheat.item_finder_window then cheat.item_finder_window:SetVisible(v) end end })
end
do
    local bossesb = ui.box.esp:AddTab("bosses")
    local boss_settings = cheat.EspLibrary.settings.boss

    bossesb:AddLabel('Wreck ESP')
    local wreck_settings = cheat.EspLibrary.settings.wreck
    bossesb:AddToggle('show_heli_wreck', { Text = 'show heli wreck', Default = false, Callback = function(c)
        wreck_settings.enabled = c
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('heli_wreck_color', { Default = Color3.fromRGB(255, 165, 0), Title = 'heli wreck color', Transparency = 0, Callback = function(a)
        wreck_settings.color = a
        cheat.EspLibrary.icaca()
    end})
    bossesb:AddToggle('show_btr_wreck', { Text = 'show btr wreck', Default = false, Callback = function(c)
        wreck_settings.enabled = c
        cheat.EspLibrary.icaca()
    end})

    bossesb:AddToggle("boss_esp_enable", {Text = "enable boss esp", Default = false, Callback = function(first)
        boss_settings.enabled = first
        cheat.EspLibrary.icaca()
    end}):AddColorPicker("boss_esp_color", {Default = Color3.fromRGB(255, 0, 255), Title = "boss esp color", Transparency = 0, Callback = function(Value)
        boss_settings.color = Value
        cheat.EspLibrary.icaca()
    end})

    bossesb:AddToggle("boss_show_name", {Text = "show name", Default = true, Callback = function(first)
        boss_settings.name = first
        cheat.EspLibrary.icaca()
    end})

    bossesb:AddToggle("boss_show_distance", {Text = "show distance", Default = false, Callback = function(first)
        boss_settings.distance = first
        cheat.EspLibrary.icaca()
    end})

    bossesb:AddLabel("Individual Boss Toggles")
    local boss_types = {"Mi24V", "BTR80", "Whisper", "Dozer", "Anton", "ScavKing", "Grif"}
    for _, boss_name in ipairs(boss_types) do
        bossesb:AddToggle('show_' .. boss_name:lower(), { Text = 'show ' .. boss_name, Default = false })
    end
end
do
    local miscbox = ui.tabs.misc:AddLeftGroupbox('misc')
    
    -- Remove Landmines feature
    local landmines_connection = nil
    miscbox:AddToggle('remove_landmines', { Text = 'remove landmines', Default = false, Callback = function(enabled)
        if enabled then
            -- Remove existing landmines
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "PMN2" or obj.Name == "MON50" then
                    pcall(function() obj:Destroy() end)
                end
            end
            -- Connect to new landmines spawning
            if not landmines_connection then
                landmines_connection = workspace.ChildAdded:Connect(function(child)
                    if child.Name == "PMN2" or child.Name == "MON50" then
                        pcall(function() child:Destroy() end)
                    end
                end)
            end
        else
            -- Disconnect when disabled
            if landmines_connection then
                landmines_connection:Disconnect()
                landmines_connection = nil
            end
        end
    end })

    local cursor = {
        Enabled = false,
        CustomPos = false,
        Position = _Vector2new(0, 0),
        Speed = 5,
        Radius = 25,
        Color = Color3.fromRGB(180, 50, 255),
        Thickness = 1.7,
        Outline = false,
        Resize = false,
        Dot = false,
        Gap = 10,
        TheGap = false,
        Font = Drawing.Fonts.UI,
        Text = {
            Logo = false,
            LogoColor = Color3.new(1, 1, 1),
            Name = false,
            NameColor = Color3.new(1, 1, 1),
            LogoFadingOffset = 0,
        }
    }
    local CrosshairTab = ui.box.crosshair:AddTab("crosshair")
    cursor.rainbow = false
    cursor.sussy = false
    CrosshairTab:AddDropdown('cursorfont', {Values = { 'UI', 'System', 'Plex', 'Monospace' },Default = 1,Multi = false,Text = 'crosshiar font',Tooltip = 'select font',Callback = function(Value)
        cursor.Font = Drawing.Fonts[Value]
    end})
    CrosshairTab:AddToggle('crosshairenable', {Text = 'enable crosshair',Default = false,Callback = function(first)
        cursor.Enabled = first
    end}):AddColorPicker('crosshaircolor', {Default = Color3.new(1, 1, 1),Title = 'crosshair color',Transparency = 0,Callback = function(Value)
        cursor.Color = Value
    end})
    CrosshairTab:AddSlider('crosshairspeed', {Text = 'speed',Default = 3,Min = 0.1,Max = 15,Rounding = 1,Compact = true}):OnChanged(function(State)
        cursor.Speed = State / 10
    end)
    CrosshairTab:AddSlider('crosshairradius', {Text = 'radius',Default = 25,Min = 0,Max = 100,Rounding = 2,Compact = true,}):OnChanged(function(State)
        cursor.Radius = State
    end)
    CrosshairTab:AddSlider('crosshairthickness', {Text = 'thickness',Default = 1.5,Min = 0.1,Max = 10,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Thickness = State
    end)
    CrosshairTab:AddSlider('crosshairgapsize', {Text = 'gap',Default = 5,Min = 0,Max = 50,Rounding = 2,Compact = true,}):OnChanged(function(State)
        cursor.Gap = State
    end)
    CrosshairTab:AddToggle('crosshairenablegap', {Text = 'math divide gap',Default = false,Callback = function(first)
        cursor.TheGap = first
    end})
    CrosshairTab:AddToggle('crosshairenableoutline', {Text = 'outline',Default = false,Callback = function(first)
        cursor.Outline = first
    end})
    CrosshairTab:AddToggle('crosshairenableresize', {Text = 'resize animation',Default = false,Callback = function(first)
        cursor.Resize = first
    end})
    CrosshairTab:AddToggle('crosshairenabledot', {Text = 'dot',Default = false,Callback = function(first)
        cursor.Dot = first
    end})
    CrosshairTab:AddToggle('crosshairenablenazi', {Text = 'sussy',Default = false,Callback = function(first)
        cursor.sussy = first
        end})
        CrosshairTab:AddToggle('crosshairenablefaggot', {Text = 'rainbow',Default = false,Callback = function(first)
        cursor.rainbow = first
    end})
    CrosshairTab:AddToggle('crosshairtextLogo', {Text = 'text logo',Default = false,Callback = function(first)
        cursor.Text.Logo = first
    end}):AddColorPicker('crosshairlogocolor', {Default = Color3.new(1, 1, 1),Title = 'logo color',Transparency = 0,Callback = function(Value)
        cursor.Text.LogoColor = Value
    end})
    CrosshairTab:AddToggle('crosshairtextName', {Text = 'text name',Default = false,Callback = function(first)
        cursor.Text.Name = first
    end}):AddColorPicker('crosshairtextcolor', {Default = Color3.new(1, 1, 1),Title = 'text color',Transparency = 0,Callback = function(Value)
        cursor.Text.NameColor = Value
    end})
    CrosshairTab:AddSlider('crosshairlogooffset', {Text = 'logo fade offset',Default = 0,Min = 0,Max = 5,Rounding = 1,Compact = true}):OnChanged(function(State)
        cursor.Text.LogoFadingOffset = State
    end)
    -- A crosshair "set" bundles all drawings needed to render the custom
    -- crosshair (4 lines + dot + outline) so it can be drawn at any screen
    -- position. The main set follows the mouse, the target set is rendered on
    -- the current silent aim target when "target crosshair" is enabled (the
    -- main set is hidden while locked so the crosshair appears to move).
    -- Everything is created invisible; the render loop manages visibility.
    local function create_crosshair_set()
        local set = {}
        set.outline = cheat.utility.new_drawing("Square", {
            Visible = false,
            Size = _Vector2new(4, 4),
            Color = Color3.fromRGB(0, 0, 0),
            Filled = true,
            ZIndex = 1,
            Transparency = 1
        })
        set.dot = cheat.utility.new_drawing("Square", {
            Visible = false,
            Size = _Vector2new(2, 2),
            Color = cursor.Color,
            Filled = true,
            ZIndex = 2,
            Transparency = 1
        })
        set.lines = {}
        for i = 1, 4 do
            local line_outline = cheat.utility.new_drawing("Line", {
                Visible = false,
                From = _Vector2new(200, 500),
                To = _Vector2new(200, 500),
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = cursor.Thickness + 2.5,
                ZIndex = 1,
                Transparency = 1
            })
            local line = cheat.utility.new_drawing("Line", {
                Visible = false,
                From = _Vector2new(200, 500),
                To = _Vector2new(200, 500),
                Color = cursor.Color,
                Thickness = cursor.Thickness,
                ZIndex = 2,
                Transparency = 1
            })
            local naziline = cheat.utility.new_drawing("Line", {
                Visible = false,
                From = _Vector2new(200, 500),
                To = _Vector2new(200, 500),
                Color = cursor.Color,
                Thickness = cursor.Thickness,
                ZIndex = 2,
                Transparency = 1
            })
            set.lines[i] = { line, line_outline, naziline }
        end
        return set
    end
    local crosshair_main = create_crosshair_set()
    local crosshair_target = create_crosshair_set()
    -- Target tracking (misc tab -> right column "target" groupbox). Both the
    -- target line and the target crosshair follow the part the silent aim is
    -- currently aiming on. The target crosshair re-uses the crosshair made in
    -- the visuals tab (same color, radius, gap, thickness, dot, outline...).
    local target_crosshair = { enabled = false, speed = 20 }
    local target_line = {
        enabled = false,
        color = Color3.fromRGB(255, 0, 0),
        thickness = 1,
    }
    local target_line_draw = cheat.utility.new_drawing("Line", {
        Visible = false,
        From = _Vector2new(0, 0),
        To = _Vector2new(0, 0),
        Color = target_line.color,
        Thickness = target_line.thickness,
        Transparency = 1,
        ZIndex = 1
    })
    local targetbox = ui.tabs.misc:AddRightGroupbox('target')
    targetbox:AddToggle('targetline', {Text = 'target line', Default = false, Tooltip = 'draws a line to the player/ai the silent aim is aiming on', Callback = function(first)
        target_line.enabled = first
    end}):AddColorPicker('targetlinecolor', {Default = target_line.color, Title = 'target line color', Transparency = 0, Callback = function(Value)
        target_line.color = Value
    end})
    targetbox:AddSlider('targetlinethickness', {Text = 'target line thickness', Default = 1, Min = 1, Max = 10, Rounding = 0, Compact = true}):OnChanged(function(State)
        target_line.thickness = State
    end)
    targetbox:AddToggle('targetcrosshair', {Text = 'target crosshair', Default = false, Tooltip = 'draws the crosshair from the visuals tab on the target the silent aim is aiming on (the crosshair at your mouse is hidden while locked)', Callback = function(first)
        target_crosshair.enabled = first
    end})
    targetbox:AddSlider('targetcrosshairspeed', {Text = 'target crosshair speed', Default = 20, Min = 1, Max = 50, Rounding = 0, Compact = true, Tooltip = 'how fast the crosshair glides when switching from one target to another'}):OnChanged(function(State)
        target_crosshair.speed = State
    end)
    local logotext = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = cursor.Font,
        Size = 13,
        Color = Color3.fromRGB(138, 128, 255),
        ZIndex = 3,
        Transparency = 1,
        Text = "wallhack.rbx",
        Center = true,
        Outline = true,
    })
    local nametext = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = cursor.Font,
        Size = 13,
        Color = Color3.fromRGB(138, 128, 255),
        ZIndex = 3,
        Transparency = 1,
        Text = LocalPlayer.Name,
        Center = true,
        Outline = true,
    })
    local angle = 0
    local transp = 0
    local reverse = false
    local function setreverse(value)
        if reverse ~= value then
            reverse = value
        end
    end
    local pos, rainbow, rotationdegree, color = Vector2.zero, 0, 0, Color3.new()
    local math_cos, math_atan, math_pi, math_sin = math.cos, math.atan, math.pi, math.sin
    local function DEG2RAD(x) return x * math_pi / 180 end
    local function RAD2DEG(x) return x * 180 / math_pi end
    -- Screen position of the part the silent aim is currently aiming on, or
    -- nil when silent aim is disabled / has no target / the target is off
    -- screen (or behind the camera). Also returns the character/model so the
    -- target crosshair can tween only when the locked player/ai changes.
    local function get_target_screen_pos()
        if not (silent_aim.enabled or silent_aim.rage_bot) then return nil, nil end
        local part = silent_aim.target_part
        if not (part and part.Parent) then return nil, nil end
        local screen, onscreen, depth = cheat.utility.world_to_screen(part.Position)
        if not onscreen or depth <= 0 then return nil, nil end
        return screen, part.Parent
    end
    -- Draws one crosshair "set" (4 lines + dot + outline) at a screen
    -- position using the current cursor config. `anim_angle` drives the
    -- normal/resize animation and `anim_rotation` the sussy animation; both
    -- sets are drawn with the same values so the target crosshair stays in
    -- sync with the main one.
    local function draw_crosshair_set(set, cpos, ccolor, anim_angle, anim_rotation)
        local dot, outline, lines = set.dot, set.outline, set.lines
        if cursor.sussy then
            local a = math.max(cursor.Radius - 10, 1)
            local gamma = math_atan(a / a)
            dot.Visible = false
            outline.Visible = false
            for i = 1, 4 do
                local su, cu = math_sin(DEG2RAD(anim_rotation + (i * 90))), math_cos(DEG2RAD(anim_rotation + (i * 90)))
                local sv, cv = math_sin(DEG2RAD(anim_rotation + (i * 90) + RAD2DEG(gamma))), math_cos(DEG2RAD(anim_rotation + (i * 90) + RAD2DEG(gamma)))
                local p_0, p_1 = a * su, a * cu
                local p_2, p_3 = (a / math_cos(gamma)) * sv, (a / math_cos(gamma)) * cv
                lines[i][1].From = _Vector2new(cpos.X, cpos.Y)
                lines[i][1].To = _Vector2new(cpos.X + p_0, cpos.Y - p_1)
                lines[i][1].Color = ccolor
                lines[i][1].Thickness = cursor.Thickness
                lines[i][1].Visible = true
                lines[i][2].Visible = false
                lines[i][3].From = _Vector2new(cpos.X + p_0, cpos.Y - p_1)
                lines[i][3].To = _Vector2new(cpos.X + p_2, cpos.Y - p_3)
                lines[i][3].Color = ccolor
                lines[i][3].Thickness = cursor.Thickness
                lines[i][3].Visible = true
            end
        else
            dot.Visible = cursor.Dot
            dot.Color = ccolor
            dot.Position = _Vector2new(cpos.X - 1, cpos.Y - 1)
            outline.Visible = cursor.Outline and cursor.Dot
            outline.Position = _Vector2new(cpos.X - 2, cpos.Y - 2)
            for index, line in pairs(lines) do
                local off = index * (math.pi / 2)
                -- radius = line length, gap = empty pixels from center
                local inner_gap = cursor.Gap
                local main_radius = cursor.Gap + cursor.Radius
                if cursor.TheGap and cursor.Gap ~= 0 then
                    inner_gap = cursor.Radius / cursor.Gap
                    main_radius = cursor.Radius
                end
                if cursor.Resize then
                    main_radius = main_radius + ((cursor.Radius * math_sin(anim_angle)) / 9)
                end
                if inner_gap < 0 then inner_gap = 0 end
                if inner_gap > main_radius then inner_gap = main_radius end
                local inner, outer = main_radius + 1, inner_gap
                local x = { cpos.X + (math_cos(anim_angle + off) * main_radius), cpos.X + (math_cos(anim_angle + off) * inner_gap) }
                local y = { cpos.Y + (math_sin(anim_angle + off) * main_radius), cpos.Y + (math_sin(anim_angle + off) * inner_gap) }
                local x1 = { cpos.X + (math_cos(anim_angle + off) * inner), cpos.X + (math_cos(anim_angle + off) * outer) }
                local y1 = { cpos.Y + (math_sin(anim_angle + off) * inner), cpos.Y + (math_sin(anim_angle + off) * outer) }
                line[1].Visible = true
                line[1].Color = ccolor
                line[1].From = _Vector2new(x[2], y[2])
                line[1].To = _Vector2new(x[1], y[1])
                line[1].Thickness = cursor.Thickness
                line[2].Visible = cursor.Outline
                line[2].From = _Vector2new(x1[2], y1[2])
                line[2].To = _Vector2new(x1[1], y1[1])
                line[2].Thickness = cursor.Thickness + 2.5
                line[3].Visible = false
            end
        end
    end
    -- Hides every drawing belonging to a crosshair "set".
    local function hide_crosshair_set(set)
        set.dot.Visible = false
        set.outline.Visible = false
        for _, line in pairs(set.lines) do
            line[1].Visible = false
            line[2].Visible = false
            line[3].Visible = false
        end
    end
    -- Target-crosshair follow state. Tweens only when the locked player/ai
    -- changes; once the glide finishes the crosshair sticks to the part.
    local display_pos = nil
    local locked_target = nil
    local tweening = false
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function(delta)
        rainbow = rainbow + (delta * 0.5)
        if rainbow > 1.0 then rainbow = 0.0 end
        color = Color3.fromHSV(rainbow, 1, 1)
        if cursor.CustomPos then pos = cursor.Position else pos = _Vector2new(
            Mouse.X,
            Mouse.Y + GuiInset.Y) end
        if cursor.rainbow then color = Color3.fromHSV(rainbow, 1, 1) else color = cursor.Color end

        local target_screen, target_model = get_target_screen_pos()
        local main_visible = cursor.Enabled
        -- when a target is locked the crosshair "moves" onto it: the main
        -- crosshair at the mouse is hidden and only the target set is drawn
        local on_target = target_crosshair.enabled and target_screen ~= nil

        local draw_pos = pos
        if target_crosshair.enabled then
            if on_target then
                if locked_target ~= target_model then
                    if locked_target ~= nil and display_pos ~= nil then
                        tweening = true
                    else
                        display_pos = target_screen
                        tweening = false
                    end
                    locked_target = target_model
                end
                if tweening then
                    local alpha = 1 - math.exp(-(target_crosshair.speed or 20) * delta)
                    display_pos = display_pos + (target_screen - display_pos) * alpha
                    if (target_screen - display_pos).Magnitude < 2 then
                        display_pos = target_screen
                        tweening = false
                    end
                else
                    display_pos = target_screen
                end
                draw_pos = display_pos
            else
                locked_target = nil
                display_pos = nil
                tweening = false
            end
        else
            locked_target = nil
            display_pos = nil
            tweening = false
        end

        local main_shown = main_visible and not on_target
        local target_shown = on_target

        if main_shown or target_shown then
            if cursor.sussy then
                if rotationdegree >= 90 then rotationdegree = 0 end
                if main_shown then
                    draw_crosshair_set(crosshair_main, draw_pos, color, nil, rotationdegree)
                else
                    hide_crosshair_set(crosshair_main)
                end
                if target_shown then
                    draw_crosshair_set(crosshair_target, draw_pos, color, nil, rotationdegree)
                end
                rotationdegree = rotationdegree + ((cursor.Speed * delta) * 1000)
            else
                angle = angle + ((cursor.Speed * 10) * delta)
                if angle >= 90 then
                    angle = 0
                end
                if main_shown then
                    draw_crosshair_set(crosshair_main, draw_pos, color, angle, nil)
                else
                    hide_crosshair_set(crosshair_main)
                end
                if target_shown then
                    draw_crosshair_set(crosshair_target, draw_pos, color, angle, nil)
                end
            end
        else
            hide_crosshair_set(crosshair_main)
        end
        if not target_shown then
            hide_crosshair_set(crosshair_target)
        end

        if main_visible then
            if transp <= 1.5 + cursor.Text.LogoFadingOffset and not reverse then
                transp = transp + ((cursor.Speed * 10) * delta)
                if transp >= 1.5 + cursor.Text.LogoFadingOffset then setreverse(true) end
            elseif reverse then
                transp = transp - ((cursor.Speed * 10) * delta)
                if transp <= 0 - cursor.Text.LogoFadingOffset then setreverse(false) end
            end
            logotext.Position = _Vector2new(draw_pos.X, (draw_pos + _Vector2new(0, cursor.Radius + 5)).Y)
            logotext.Transparency = transp
            logotext.Visible = cursor.Text.Logo
            logotext.Color = cursor.Text.LogoColor
            logotext.Font = cursor.Font
            nametext.Position = _Vector2new(draw_pos.X, draw_pos.Y - cursor.Radius - 5 - nametext.TextBounds.Y)
            nametext.Transparency = transp
            nametext.Visible = cursor.Text.Name
            nametext.Color = cursor.Text.NameColor
            nametext.Font = cursor.Font
        else
            logotext.Visible = false
            nametext.Visible = false
        end

        -- target line: from the center of the screen to the target
        if target_line.enabled and target_screen then
            local viewport = Camera.ViewportSize
            target_line_draw.From = _Vector2new(viewport.X / 2, viewport.Y / 2)
            target_line_draw.To = target_screen
            target_line_draw.Color = target_line.color
            target_line_draw.Thickness = target_line.thickness
            target_line_draw.Visible = true
        else
            target_line_draw.Visible = false
        end
    end))
end
do
    local WorldTab = ui.box.world:AddTab("world")
    local gradientcolor1 = Color3.fromRGB(90, 90, 90)
    local gradientcolor2 = Color3.fromRGB(150, 150, 150)
    local oldgradient1 = Lighting.Ambient
    local oldgradient2 = Lighting.OutdoorAmbient
    local oldTime = mathround(Lighting.ClockTime)
    local nofog = false
    local visuals_BloomInstance = Lighting:FindFirstChildOfClass("BloomEffect")
    local visuals_BloomIntensity = 0
    local visuals_BloomSize = 17
    local visuals_BloomThreshold = 0.9
    local visuals_BloomEnabled = false
    WorldTab:AddToggle('enabletimechanger', {Text = 'enable time changer',Default = false,Callback = function(first)
        globals.EnableTime = first
    end})
    WorldTab:AddSlider('timechanger',{ Text = 'time changer', Default = oldTime, Min = 0, Max = 24, Rounding = 1, Compact = false }):OnChanged(function(State)
        globals.Time = State
    end)
    WorldTab:AddToggle('ambientswitch', {Text = 'enable ambient',Default = false,Callback = function(first)
        globals.gradientenabled = first
    end}):AddColorPicker('ambientcolor', {Default = Color3.new(1, 1, 1),Title = 'ambient color1',Transparency = 0,Callback = function(Value)
        gradientcolor1 = Value
    end}):AddColorPicker('ambientcolor1',{Default = Color3.new(1, 1, 1),Title = 'ambient color2',Transparency = 0,Callback = function(Value)
        gradientcolor2 = Value
    end})
    WorldTab:AddToggle('fogswitch', {
        Text = 'no fog',
        Default = false,
        Callback = function(first)
            nofog = first
        end
    })
    WorldTab:AddToggle('grassswitch', {
        Text = 'no grass',
        Default = false,
        Callback = function(first)
            sethiddenproperty(_FindFirstChildOfClass(workspace, "Terrain"), "Decoration", not first)
        end
    })
    local muzzle_color = Color3.fromRGB(255, 100, 0)
    local last_star_emit = 0
    local star_texture = "rbxassetid://12555502283" -- Star texture
    WorldTab:AddToggle('custommuzzleflash', {
        Text = 'custom muzzle flash',
        Default = false,
        Callback = function(first)
        end
    }):AddColorPicker('muzzleflashcolor', { Default = Color3.fromRGB(255, 100, 0), Title = 'muzzle flash color', Callback = function(Value)
        muzzle_color = Value
    end})
    WorldTab:AddToggle('shadowswitch', {
        Text = 'no shadows',
        Default = false,
        Callback = function(first)
            globals.noshadows = first
        end
    })
    local leafs_enabled = false
    local function apply_no_leafs()
        local zones = workspace:FindFirstChild("SpawnerZones")
        if not zones then return end
        local foliage = zones:FindFirstChild("Foliage")
        if not foliage then return end
        for _, v in pairs(foliage:GetDescendants()) do
            if v:FindFirstChildOfClass("SurfaceAppearance") then
                v.Transparency = leafs_enabled and 1 or 0
            end
        end
    end
    WorldTab:AddToggle('no_leafs', {Text = 'no leafs', Default = false, Callback = function(v)
        leafs_enabled = v
        apply_no_leafs()
        if v then
            task.spawn(function()
                while leafs_enabled do
                    task.wait(10)
                    apply_no_leafs()
                end
            end)
        end
    end})
    cheat.utility.new_heartbeat(function()
        local char = LocalPlayer.Character
        if Lighting.GlobalShadows ~= (not globals.noshadows) then Lighting.GlobalShadows = not globals.noshadows end
        if globals.gradientenabled then
            if Lighting.Ambient ~= gradientcolor1 then Lighting.Ambient = gradientcolor1 end
            if Lighting.OutdoorAmbient ~= gradientcolor2 then Lighting.OutdoorAmbient = gradientcolor2 end
        end
        if globals.EnableTime and Lighting.ClockTime ~= globals.Time then Lighting.ClockTime = globals.Time end
        if cheat.Toggles.custommuzzleflash and cheat.Toggles.custommuzzleflash.Value then
            local muzzle_active = false
            for _, v in ipairs(Camera:GetDescendants()) do
                if v:IsA("Light") or (v:IsA("BasePart") and (v.Name:find("Flash") or v.Name:find("Muzzle") or v.Name:find("Smoke"))) or v:IsA("ParticleEmitter") then
                    local is_muzzle_part = v.Name:find("Flash") or v.Name:find("Muzzle") or v.Name:find("Smoke")
                    if (v:IsA("Light") and v.Enabled) or (v:IsA("ParticleEmitter") and v.Enabled) or (v:IsA("BasePart") and v.Transparency < 0.9 and is_muzzle_part) then
                        muzzle_active = true
                    end

                    if v:IsA("Light") then
                        v.Color = muzzle_color
                        v.Brightness = 25
                        v.Range = 25
                    elseif v:IsA("ParticleEmitter") then
                        v.Color = ColorSequence.new(muzzle_color)
                        -- Removed transparency override to keep it natural
                    elseif v:IsA("BasePart") then
                        v.Color = muzzle_color
                        if not v.Name:find("Smoke") then
                            v.Transparency = 0 -- Keep fire visible, but let smoke animate
                        end
                        local sa = v:FindFirstChildOfClass("SurfaceAppearance") or v:FindFirstChildOfClass("Texture")
                        if sa then sa:Destroy() end
                    end
                end
            end

            if muzzle_active and tick() - last_star_emit > 0.04 then
                last_star_emit = tick()
                local vm = _FindFirstChildOfClass(Camera, "Model")
                local item = vm and _FindFirstChild(vm, "Item")
                local muzzle = (item and (_FindFirstChild(item, "Muzzle") or _FindFirstChild(item, "AimPart"))) or (vm and _FindFirstChild(vm, "AimPart")) or Camera

                if muzzle then
                    task.spawn(function()
                        local att = Instance.new("Attachment")
                        if muzzle:IsA("Camera") then
                            att.Parent = workspace.Terrain
                            att.WorldPosition = Camera.CFrame.p + (Camera.CFrame.LookVector * 2.5)
                        else
                            att.Parent = muzzle
                        end

                        local emitter = Instance.new("ParticleEmitter")
                        emitter.Texture = star_texture
                        emitter.Color = ColorSequence.new(muzzle_color)
                        emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
                        emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                        emitter.Lifetime = NumberRange.new(0.3, 0.5)
                        emitter.Speed = NumberRange.new(15, 35)
                        emitter.SpreadAngle = Vector2.new(60, 60)
                        emitter.ZOffset = 1
                        emitter.Rate = 0
                        emitter.Parent = att
                        emitter:Emit(8)
                        task.wait(0.6)
                        emitter:Destroy()
                        att:Destroy()
                    end)
                end
            end

            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("Light") or (v:IsA("BasePart") and (v.Name:find("Flash") or v.Name:find("Muzzle") or v.Name:find("Smoke"))) or v:IsA("ParticleEmitter") then
                        if v:IsA("Light") then
                            v.Color = muzzle_color
                            v.Brightness = 25
                        elseif v:IsA("ParticleEmitter") then
                            v.Color = ColorSequence.new(muzzle_color)
                        elseif v:IsA("BasePart") then
                            v.Color = muzzle_color
                            v.Transparency = 0
                            local sa = v:FindFirstChildOfClass("SurfaceAppearance") or v:FindFirstChildOfClass("Texture")
                            if sa then sa:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end
do
    local othervisuals = ui.box.world:AddTab("other")
    local zoom_enabled, zoom_size = false, 10
    local fov_enabled, fov_size = false, 70
    othervisuals:AddToggle('fov_enabled', {Text = 'fov enabled',Default = false,Callback = function(first)
        fov_enabled = first
        globals.fov_enabled = first
        Camera.FieldOfView = zoom_enabled and zoom_size or fov_enabled and fov_size
    end})
    local zoom_toggle = othervisuals:AddToggle('zoom_enabled', {Text = 'zoom enabled',Default = false,Callback = function(first)
        zoom_enabled = first
        globals.zoom_enabled = first
    end})
    local zoom_picker = zoom_toggle:AddKeyPicker('zoom_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'zoom bind',NoUI = false})
    cheat.utility.new_renderstepped(function()
        local is_zoomed = cheat.Toggles.zoom_enabled.Value
        if zoom_picker and zoom_picker.Mode == "Hold" then
            is_zoomed = zoom_picker.State
        end
        Camera.FieldOfView = is_zoomed and zoom_size or fov_enabled and fov_size or Camera.FieldOfView
    end)
    othervisuals:AddSlider('zoom_size', { Text = 'zoom size', Default = 10, Min = 0, Max = 90, Rounding = 0, Compact = true, Callback = function(value)
        zoom_size = value
    end})
    othervisuals:AddSlider('fov_size', { Text = 'fov size', Default = 70, Min = 0, Max = 120, Rounding = 0, Compact = true, Callback = function(value)
        fov_size = value
    end})
    othervisuals:AddToggle('noscreenfx', { Text = 'no screen effects', Default = false });
    othervisuals:AddToggle('nomuzzleflash', { Text = 'remove muzzle flash', Default = false });
    othervisuals:AddToggle('killeffect', { Text = 'hit / kill effect (stars)', Default = false });
    othervisuals:AddSlider('killeffect_amount', { Text = 'hit effect stars amount', Default = 100, Min = 50, Max = 200, Rounding = 0, Compact = true });

    othervisuals:AddLabel("viewmodel offset");

    local function remove_muzzle(v)
        if cheat.Toggles.nomuzzleflash and cheat.Toggles.nomuzzleflash.Value then
            if v:IsA("ParticleEmitter") or v:IsA("Light") or v:IsA("Beam") then
                local name = v.Name:lower()
                local parentName = v.Parent and v.Parent.Name:lower() or ""
                if name:find("flash") or name:find("muzzle") or parentName:find("muzzle") or parentName:find("aimpart") or name:find("smoke") or name:find("spark") then
                    v.Enabled = false
                    if v:IsA("ParticleEmitter") then
                        v:Clear()
                        v.Transparency = NumberSequence.new(1)
                    end
                end
            end
        end
    end

    workspace.CurrentCamera.DescendantAdded:Connect(remove_muzzle)
    cheat.utility.new_heartbeat(function()
        if cheat.Toggles.nomuzzleflash and cheat.Toggles.nomuzzleflash.Value then
            for _, v in workspace.CurrentCamera:GetDescendants() do
                remove_muzzle(v)
            end
        end
    end)
    -- ─── PRETTY PRINT JSON UTILITY ───────────────────────────────────────────
    local function format_target_data(data)
        local lines = {}
        
        if data.status then
            table.insert(lines, data.status)
            return table.concat(lines, "\n")
        end
        
        if data.target then
            table.insert(lines, "target: " .. data.target)
            table.insert(lines, "  health: " .. data.health .. " / " .. data.max_health)
            table.insert(lines, "  distance: " .. data.distance .. " studs")
            table.insert(lines, "  visible: " .. (data.visible and "yeah" or "nah"))
            
            if data.weapons and #data.weapons > 0 then
                table.insert(lines, "")
                table.insert(lines, "weapons:")
                for _, weapon in ipairs(data.weapons) do
                    table.insert(lines, "  " .. weapon.name .. " (" .. weapon.slot .. ")")
                    if weapon.attachments and #weapon.attachments > 0 then
                        local display_attachments = {}
                        local chosen_grip = nil
                        for _, att in ipairs(weapon.attachments) do
                            local lower = att:lower()
                            if lower:find("grip") or lower:find("hand") then
                                if not chosen_grip then
                                    chosen_grip = att
                                end
                            else
                                table.insert(display_attachments, att)
                            end
                        end
                        if chosen_grip then
                            table.insert(display_attachments, 1, chosen_grip)
                        end

                        for _, att in ipairs(display_attachments) do
                            table.insert(lines, "      " .. att)
                        end
                    end
                end
            end
        end
        
        return table.concat(lines, "\n")
    end

    local function format_inventory_data(data)
        local lines = {}
        
        if data.status then
            table.insert(lines, data.status)
            return table.concat(lines, "\n")
        end
        
        if data.target then
            table.insert(lines, "target: " .. data.target)
            table.insert(lines, "  total: " .. data.total_items)
            table.insert(lines, "  whole value: $" .. data.total_value)
            
            if data.items and #data.items > 0 then
                table.insert(lines, "")
                table.insert(lines, "items:")
                for _, item in ipairs(data.items) do
                    local item_line = "  " .. item.name
                    if item.amount and item.amount > 1 then
                        item_line = item_line .. " x" .. item.amount
                    end
                    if item.value then
                        item_line = item_line .. " [$" .. item.value .. "]"
                    end
                    table.insert(lines, item_line)
                end
            end
        end
        
        return table.concat(lines, "\n")
    end

    local function format_item_finder_data(data)
        local lines = {}
        
        table.insert(lines, "tracking: " .. (data.found_count or 0) .. " items found")
        
        if data.results and #data.results > 0 then
            local by_owner = {}
            for _, result in ipairs(data.results) do
                if not by_owner[result.owner] then
                    by_owner[result.owner] = {}
                end
                table.insert(by_owner[result.owner], result.item)
            end
            
            table.insert(lines, "")
            local owners = {}
            for owner in pairs(by_owner) do
                table.insert(owners, owner)
            end
            table.sort(owners)
            
            for _, owner in ipairs(owners) do
                table.insert(lines, owner .. ":")
                for _, item in ipairs(by_owner[owner]) do
                    table.insert(lines, "    " .. item)
                end
            end
        else
            table.insert(lines, "No items found")
        end
        
        return table.concat(lines, "\n")
    end

    local function pretty_json(obj, indent)
        indent = indent or 0
        local spacing = string.rep("  ", indent)
        local sub_spacing = string.rep("  ", indent + 1)
        local t = type(obj)

        if t == "nil" then
            return "null"
        elseif t == "boolean" then
            return tostring(obj)
        elseif t == "number" then
            return tostring(obj)
        elseif t == "string" then
            return string.format("%q", obj)
        elseif t == "table" then
            local is_array = true
            local max_k = 0
            for k in pairs(obj) do
                if type(k) == "number" and k > 0 and math.floor(k) == k then
                    if k > max_k then max_k = k end
                else
                    is_array = false
                    break
                end
            end
            if is_array and max_k == #obj then
                if #obj == 0 then return "[]" end
                local parts = {}
                for _, v in ipairs(obj) do
                    table.insert(parts, sub_spacing .. pretty_json(v, indent + 1))
                end
                return "[\n" .. table.concat(parts, ",\n") .. "\n" .. spacing .. "]"
            else
                local keys = {}
                for k in pairs(obj) do table.insert(keys, tostring(k)) end
                table.sort(keys)
                if #keys == 0 then return "{}" end
                local parts = {}
                for _, k in ipairs(keys) do
                    local v = obj[k]
                    table.insert(parts, sub_spacing .. string.format("%q", k) .. ": " .. pretty_json(v, indent + 1))
                end
                return "{\n" .. table.concat(parts, ",\n") .. "\n" .. spacing .. "}"
            end
        else
            return string.format("%q", tostring(obj))
        end
    end

    local function create_json_window(title, default_pos)
        local outer = cheat.Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0),
            Position = default_pos,
            Size = UDim2.new(0, 270, 0, 320),
            Visible = false,
            ZIndex = 100,
            Parent = cheat.Library.ScreenGui
        })

        local inner = cheat.Library:Create('Frame', {
            BackgroundColor3 = cheat.Library.MainColor,
            BorderColor3 = cheat.Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 101,
            Parent = outer
        })

        cheat.Library:AddToRegistry(inner, {
            BackgroundColor3 = 'MainColor',
            BorderColor3 = 'OutlineColor'
        }, true)

        local color_bar = cheat.Library:Create('Frame', {
            BackgroundColor3 = cheat.Library.AccentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 102,
            Parent = inner
        })

        cheat.Library:AddToRegistry(color_bar, {
            BackgroundColor3 = 'AccentColor'
        }, true)

        local header_label = Instance.new("TextLabel")
        header_label.BackgroundTransparency = 1
        header_label.Size = UDim2.new(1, -10, 0, 22)
        header_label.Position = UDim2.fromOffset(6, 2)
        header_label.TextXAlignment = Enum.TextXAlignment.Left
        header_label.Text = title
        header_label.Font = Enum.Font.Code
        header_label.TextSize = 14
        header_label.TextColor3 = cheat.Library.FontColor or Color3.fromRGB(240, 240, 240)
        header_label.TextStrokeTransparency = 1
        header_label.ZIndex = 104
        header_label.Parent = inner

        local scroll = cheat.Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 24),
            Size = UDim2.new(1, -10, 1, -29),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            BorderSizePixel = 0,
            ZIndex = 105,
            Parent = inner
        })

        local text_label = Instance.new("TextLabel")
        text_label.BackgroundTransparency = 1
        text_label.Size = UDim2.new(1, -5, 1, 0)
        text_label.Position = UDim2.new(0, 2, 0, 2)
        text_label.TextXAlignment = Enum.TextXAlignment.Left
        text_label.TextYAlignment = Enum.TextYAlignment.Top
        text_label.Font = Enum.Font.Code
        text_label.TextSize = 14
        text_label.TextColor3 = Color3.fromRGB(240, 240, 240)
        text_label.TextWrapped = true
        text_label.TextStrokeTransparency = 1
        text_label.ZIndex = 106
        text_label.Parent = scroll

        cheat.Library:MakeDraggable(outer)

        return {
            Outer = outer,
            Inner = inner,
            Header = header_label,
            TextLabel = text_label,
            Scroll = scroll,
            SetJson = function(self, data, formatter)
                local display_str = formatter and formatter(data) or pretty_json(data)
                self.TextLabel.Text = display_str
                local vp = cheat.Library.ScreenGui.AbsoluteSize
                local bounds = game:GetService("TextService"):GetTextSize(display_str, 14, Enum.Font.Code, Vector2.new(math.max(vp.X - 60, 270), 10000))
                local new_w = math.clamp(bounds.X + 25, 270, math.max(vp.X - 40, 270))
                local new_h = math.clamp(bounds.Y + 42, 180, math.max(vp.Y - 40, 180))
                local old_size = self.Outer.Size
                -- keep the window centered so it expands outward on all sides
                local old_center = Vector2.new(self.Outer.Position.X.Offset + old_size.X.Offset / 2, self.Outer.Position.Y.Offset + old_size.Y.Offset / 2)
                self.Outer.Position = UDim2.new(0, math.clamp(old_center.X - new_w / 2, 0, math.max(vp.X - new_w, 0)), 0, math.clamp(old_center.Y - new_h / 2, 0, math.max(vp.Y - new_h, 0)))
                self.Scroll.CanvasSize = UDim2.new(0, 0, 0, bounds.Y + 20)
                self.Outer.Size = UDim2.new(0, new_w, 0, new_h)
            end,
            SetVisible = function(self, vis)
                self.Outer.Visible = vis
            end
        }
    end

    local target_data_window = create_json_window("Target Data", UDim2.new(0, 20, 0, 350))
    local target_inv_window = create_json_window("Target Inventory", UDim2.new(0, 300, 0, 200))
    local item_finder_window = create_json_window("Item Finder", UDim2.new(0, 580, 0, 200))

    cheat.target_data_window = target_data_window
    cheat.target_inv_window = target_inv_window
    cheat.item_finder_window = item_finder_window

    if cheat.SaveManager and cheat.SaveManager.RegisterWindow then
        cheat.SaveManager:RegisterWindow('target_data', target_data_window.Outer)
        cheat.SaveManager:RegisterWindow('target_inventory', target_inv_window.Outer)
        cheat.SaveManager:RegisterWindow('item_finder', item_finder_window.Outer)
    end

    cheat.utility.new_renderstepped(function()
        -- 1. Target Data UI (JSON)
        if target_data_window.Outer.Visible then
            local target = silent_aim and silent_aim.target_part and silent_aim.target_part.Parent
            local data = {}
            if target then
                local player = Players:GetPlayerFromCharacter(target)
                local hum = target:FindFirstChildOfClass("Humanoid")
                local target_name = player and player.Name or target.Name
                local is_vis = false
                if cheat.utility.is_visible and silent_aim.target_part then
                    is_vis = cheat.utility.is_visible(Camera.CFrame, target, silent_aim.target_part)
                end
                local dist = math.floor((target:GetPivot().Position - Camera.CFrame.Position).Magnitude)

                local inv = target:FindFirstChild("Inventory")
                if not inv and player then
                    local rp = ReplicatedStorage:FindFirstChild("Players")
                    local rpp = rp and rp:FindFirstChild(player.Name)
                    inv = rpp and rpp:FindFirstChild("Inventory")
                end

                local weapons = {}
                if inv then
                    for _, slot_item in pairs(inv:GetChildren()) do
                        local slot_attr = slot_item:GetAttribute("Slot")
                        if slot_attr and not string.find(slot_attr, "Clothing") and slot_item:FindFirstChild("Attachments") then
                            local att_list = {}
                            for _, att in pairs(slot_item.Attachments:GetChildren()) do
                                table.insert(att_list, att.Name)
                            end
                            table.insert(weapons, {
                                name = slot_item.Name,
                                slot = slot_attr,
                                attachments = att_list
                            })
                        end
                    end
                end

                data = {
                    target = target_name,
                    health = hum and math.floor(hum.Health) or 0,
                    max_health = hum and math.floor(hum.MaxHealth) or 0,
                    distance = dist,
                    visible = is_vis,
                    weapons = weapons
                }
            else
                data = { target = nil, status = "No target locked" }
            end
            target_data_window:SetJson(data, format_target_data)
        end

        -- 2. Target Inventory UI (JSON)
        if target_inv_window.Outer.Visible then
            local target = silent_aim and silent_aim.target_part and silent_aim.target_part.Parent
            local inv_obj = target
            local inv = inv_obj and inv_obj:FindFirstChild("Inventory")
            if not inv and inv_obj then
                local player = Players:GetPlayerFromCharacter(inv_obj)
                if player then
                    local rp = ReplicatedStorage:FindFirstChild("Players")
                    local rpp = rp and rp:FindFirstChild(player.Name)
                    inv = rpp and rpp:FindFirstChild("Inventory")
                end
            end

            local data = {}
            if inv then
                local items = {}
                local total_val = 0
                local total_items = 0
                local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")

                local function process_json_inv_item(item_folder)
                    local n = string.lower(item_folder.Name)
                    if n:find("dagr") or n:find("keychain") or n:find("map") or n:find("lighter") or n:find("radio") or n:find("compass") or n:find("pathfinder") then return end
                    local amt = item_folder:GetAttribute("Amount") or 1
                    total_items = total_items + amt

                    local val = 0
                    if ItemsList then
                        local item_ref = ItemsList:FindFirstChild(item_folder.Name)
                        if item_ref and item_ref:FindFirstChild("ItemProperties") then
                            local price = item_ref.ItemProperties:GetAttribute("Price") or 1
                            val = price * amt
                            total_val = total_val + val
                        end
                    end

                    table.insert(items, {
                        name = item_folder.Name,
                        amount = amt,
                        value = val > 0 and val or nil
                    })
                end

                for _, slot in pairs(inv:GetChildren()) do
                    process_json_inv_item(slot)
                    local slot_attr = slot:GetAttribute("Slot")
                    if slot_attr and slot_attr:find("Clothing") and slot:FindFirstChild("Inventory") then
                        for _, sub in pairs(slot.Inventory:GetChildren()) do
                            process_json_inv_item(sub)
                        end
                    end
                end

                data = {
                    target = inv_obj and inv_obj.Name or "Unknown",
                    total_items = total_items,
                    total_value = math.floor(total_val),
                    items = items
                }
            else
                data = { target = nil, status = "No inventory target" }
            end
            target_inv_window:SetJson(data, format_inventory_data)
        end

        -- 3. Item Finder UI (JSON)
        if item_finder_window.Outer.Visible then
            local selected_items = cheat.Options.inv_item_finder and cheat.Options.inv_item_finder.Value or {}
            local found_list = {}

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local p_inv = ReplicatedStorage:FindFirstChild("Players") and ReplicatedStorage.Players:FindFirstChild(player.Name) and ReplicatedStorage.Players[player.Name]:FindFirstChild("Inventory")
                    if p_inv then
                        local found_for_player = {}
                        local function check_item(item)
                            if selected_items[item.Name] and not found_for_player[item.Name] then
                                found_for_player[item.Name] = true
                                table.insert(found_list, {
                                    item = item.Name,
                                    owner = player.Name,
                                    location = "Player Inventory"
                                })
                            end
                            local sub_inv = item:FindFirstChild("Inventory")
                            if sub_inv then
                                for _, sub_item in ipairs(sub_inv:GetChildren()) do check_item(sub_item) end
                            end
                        end
                        for _, item in ipairs(p_inv:GetChildren()) do check_item(item) end
                    end
                end
            end

            local data = {
                tracked_items = selected_items,
                found_count = #found_list,
                results = found_list
            }
            item_finder_window:SetJson(data, format_item_finder_data)
        end
    end)

    othervisuals:AddLabel("viewmodel offset");
    othervisuals:AddSlider('viewmodel_x', { Text = 'x', Default = 0, Min = -5, Max = 5, Rounding = 2, Compact = true });
    othervisuals:AddSlider('viewmodel_y', { Text = 'y', Default = 0, Min = -5, Max = 5, Rounding = 2, Compact = true });
    othervisuals:AddSlider('viewmodel_z', { Text = 'z', Default = 0, Min = -5, Max = 5, Rounding = 2, Compact = true });
    othervisuals:AddToggle("ac", { Text = "arm chams", Default = false }):AddColorPicker('acc', { Default = Color3.new(1, 1, 1), Title = 'arm chams color' });
    othervisuals:AddToggle("noarms", { Text = "remove arms (viewmodel)", Default = false, Callback = function(v)
        vmchams(true)
    end });
    othervisuals:AddToggle("gm", { Text = "gun chams", Default = false }):AddColorPicker('gcc', { Default = Color3.new(1, 1, 1), Title = 'gun chams color' });
    othervisuals:AddDropdown("acm", { Text = "arm chams material", Default = "SmoothPlastic", Values = { "SmoothPlastic", "ForceField", "Neon", "Plastic", "Glass" } });
    othervisuals:AddDropdown("gcm", { Text = "gun chams material", Default = "SmoothPlastic", Values = { "SmoothPlastic", "ForceField", "Neon", "Plastic", "Glass" } });

    local force_render_enabled = false
    othervisuals:AddToggle('force_render', { Text = 'force render all players (3k max)', Default = false, Callback = function(v)
        force_render_enabled = v
    end}):AddKeyPicker('force_render_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'force render'})

    local extreme_potato_mode = false
    othervisuals:AddToggle('extreme_potato_mode', { Text = 'extreme potato map (max fps)', Default = false, Callback = function(v)
        extreme_potato_mode = v
        if v then
            pcall(function()
                workspace.Terrain.Decoration = false
                workspace.Terrain.WaterWaveSize = 0
                workspace.Terrain.WaterWaveSpeed = 0
                workspace.Terrain.WaterReflectance = 0
                workspace.Terrain.WaterTransparency = 0
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").FogEnd = 9e9
                for _, obj in pairs(game:GetService("Lighting"):GetChildren()) do
                    if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") then
                        obj.Enabled = false
                    end
                end
            end)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not (obj.Parent and obj.Parent:FindFirstChild("Humanoid")) then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end
        end
    end});

    workspace.DescendantAdded:Connect(function(obj)
        if extreme_potato_mode then
            if obj:IsA("BasePart") and not (obj.Parent and obj.Parent:FindFirstChild("Humanoid")) then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    end)

    task.spawn(function()
        local last_requested = {}
        while task.wait(0.5) do
            if force_render_enabled then
                local rp_players = ReplicatedStorage:FindFirstChild("Players")
                local my_char = LocalPlayer.Character
                local my_pos = my_char and my_char:FindFirstChild("HumanoidRootPart") and my_char.HumanoidRootPart.Position

                if rp_players and my_pos then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and (not p.Character or not p.Character:FindFirstChild("HumanoidRootPart")) then
                            local rp_plr = rp_players:FindFirstChild(p.Name)
                            local status = rp_plr and rp_plr:FindFirstChild("Status")
                            local uac = status and status:FindFirstChild("UAC")
                            local pos = uac and uac:GetAttribute("LastVerifiedPos")

                            if pos and typeof(pos) == "Vector3" then
                                local dist = (pos - my_pos).Magnitude
                                if dist <= 12000 then -- 12000 studs ~ 3360 meters
                                    local now = tick()
                                    if not last_requested[p] or (now - last_requested[p] > 1.5) then
                                        last_requested[p] = now
                                        task.spawn(function()
                                            pcall(function()
                                                LocalPlayer:RequestStreamAroundAsync(pos, 0.5)
                                            end)
                                        end)
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    local viewmodel_x = cheat.Options["viewmodel_x"]
    local viewmodel_y = cheat.Options["viewmodel_y"]
    local viewmodel_z = cheat.Options["viewmodel_z"]
    local gcm = cheat.Options.gcm
    local gcc = cheat.Options.gcc
    local acm = cheat.Options.acm
    local acc = cheat.Options.acc
    local function vmpos(vm)
        if not vm then return end
        local hrp = vm:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vec = Vector3.new(viewmodel_x.Value, viewmodel_y.Value, viewmodel_z.Value)
        local function apply_joint(name)
            local joint = hrp:FindFirstChild(name)
            if joint and joint:IsA("Motor6D") then
                local orig = joint:GetAttribute("OriginalC0")
                if not orig then
                    orig = joint.C0
                    joint:SetAttribute("OriginalC0", orig)
                end
                joint.C0 = orig + vec
            end
        end
        apply_joint("LeftUpperArm")
        apply_joint("RightUpperArm")
        apply_joint("ItemRoot")
        apply_joint("Motor6D")
    end
    local last_vm_item
    local last_vm_update = 0
    local is_chamming = false
    local function vmchams(force) LPH_JIT_MAX(function()
        if is_chamming then return end
        local vm = _FindFirstChildOfClass(Camera, "Model")
        if not vm then return end
        local ItemView = _FindFirstChild(vm, "Item")
        if not force and ItemView == last_vm_item and tick() - last_vm_update < 0.5 then return end
        last_vm_item = ItemView
        last_vm_update = tick()
        is_chamming = true
        task.spawn(function()
            if not vm.Parent then is_chamming = false return end
            local guncolor = gcc.Value
            local gunmaterial = gcm.Value
            local armcolor = acc.Value
            local armmaterial = acm.Value
            if ItemView and Toggles.gm.Value then
                for _, v in pairs(ItemView:GetDescendants()) do
                    if (v:IsA("MeshPart") or v:IsA("BasePart")) and v.Transparency < 1 and v.Name ~= "Muzzle" and v.Name ~= "SightMark" and v.Name ~= "AimPart" and v.Name ~= "SmokePart" and v.Name ~= "FirePoint" and v.Name ~= "Flash" and v.Name ~= "Flame" then
                        v.Material = Enum.Material[gunmaterial]
                        v.Color = guncolor
                        local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                        if sa then sa:Destroy() end
                    end
                end
            end
            if Toggles.noarms.Value then
                for _, vm_item in pairs(vm:GetChildren()) do
                    if vm_item:IsA("MeshPart") then
                        if vm_item.Name:find("Hand") or vm_item.Name:find("Arm") then
                            vm_item.Transparency = 1
                        end
                    elseif vm_item:IsA("Model") and (_FindFirstChild(vm_item, "LL") or _FindFirstChild(vm_item, "LH")) then
                        for _, shirt_item in pairs(vm_item:GetChildren()) do
                            shirt_item.Transparency = 1
                        end
                    end
                end
            else
                -- Restore normal transparency if noarms is off
                for _, vm_item in pairs(vm:GetChildren()) do
                    if vm_item:IsA("MeshPart") then
                        if vm_item.Name:find("Hand") or vm_item.Name:find("Arm") then
                            vm_item.Transparency = 0
                        end
                    elseif vm_item:IsA("Model") and (_FindFirstChild(vm_item, "LL") or _FindFirstChild(vm_item, "LH")) then
                        for _, shirt_item in pairs(vm_item:GetChildren()) do
                            shirt_item.Transparency = 0
                        end
                    end
                end
            end
            if Toggles.ac.Value and not Toggles.noarms.Value then
                for _, vm_item in pairs(vm:GetChildren()) do
                if vm_item:IsA("MeshPart") then
                    if vm_item.Name:find("Hand") or vm_item.Name:find("Arm") then
                            vm_item.Material = Enum.Material[armmaterial]
                            vm_item.Color = armcolor
                        end
                    elseif vm_item:IsA("Model") and (_FindFirstChild(vm_item, "LL") or _FindFirstChild(vm_item, "LH")) then
                        for _, shirt_item in pairs(vm_item:GetChildren()) do
                            local sa = shirt_item:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                            shirt_item.Material = Enum.Material[armmaterial]
                            shirt_item.Color = armcolor
                        end
                    end
                end
            end
            is_chamming = false
        end)
    end)() end
    Camera.ChildAdded:Connect(function(child)
        task.spawn(function()
            if child:IsA("Model") then
                child:WaitForChild("HumanoidRootPart", 1)
                task.wait()
                vmpos(child)
            end
        end)
        if child:IsA("Model") then
            vmchams(true)
        end
    end)
    Camera.DescendantAdded:Connect(vmchams)
    cheat.utility.new_heartbeat(function()
        local vm = _FindFirstChildOfClass(Camera, "Model")
        if vm then vmpos(vm) end

        local char = LocalPlayer.Character
        if char then
            local guncolor = gcc.Value
            local gunmaterial = gcm.Value
            local armcolor = acc.Value
            local armmaterial = acm.Value
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Shirt") then
                    v.ShirtTemplate = ""
                elseif v:IsA("Pants") then
                    v.PantsTemplate = ""
                elseif v:IsA("ShirtGraphic") then
                    v.Graphic = ""
                end
            end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    local is_weapon = v:FindFirstAncestor("Item") or v:FindFirstAncestor("Weapon") or v.Name:find("Gun") or v.Name:find("Handle")
                    if Toggles.gm.Value and is_weapon then
                        if v.Color ~= guncolor or v.Material ~= Enum.Material[gunmaterial] or (v:IsA("MeshPart") and v.TextureID ~= "") then
                            v.Material = Enum.Material[gunmaterial]
                            v.Color = guncolor
                            if v:IsA("MeshPart") then v.TextureID = "" end
                            local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                        end
                    elseif Toggles.ac.Value then
                        if v.Color ~= armcolor or v.Material ~= Enum.Material[armmaterial] or (v:IsA("MeshPart") and v.TextureID ~= "") then
                            v.Material = Enum.Material[armmaterial]
                            v.Color = armcolor
                            if v:IsA("MeshPart") then v.TextureID = "" end
                            local sa = v:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end
                        end
                    end
                end
            end
        end
        vmchams()
    end)
    cheat.utility.new_renderstepped(LPH_JIT_MAX(function()
        local playergui = LocalPlayer.PlayerGui
		local noinsetgui = playergui and _FindFirstChild(playergui, "NoInsetGui")
		local mainframe = noinsetgui and _FindFirstChild(noinsetgui, "MainFrame")
		local screeneffects = mainframe and _FindFirstChild(mainframe, "ScreenEffects")
		if screeneffects then screeneffects.Visible = not cheat.Toggles.noscreenfx.Value end
        if (zoom_enabled or fov_enabled) then
            Camera.FieldOfView = zoom_enabled and zoom_size or fov_enabled and fov_size
        end
    end))
end
do
    local mvb = ui.tabs.misc:AddLeftGroupbox('character')
    local speed_enabled, speed = false, 55
    local tp_enabled, tp_dist = false, 10
    local jesus_enabled = false
    local water_part = nil
    local spiderman_enabled, spiderman_speed = false, 26

    mvb:AddToggle('speedhack_enabled', {Text = 'speedhack enabled',Default = false,Callback = function(first)
        speed_enabled = first
    end})
    mvb:AddSlider('speedhack_speed',{ Text = 'speed', Default = 18.2, Min = 10, Max = 22, Rounding = 1, Suffix = "sps", Compact = false }):OnChanged(function(State)
        speed = State
    end)

    mvb:AddToggle('thirdperson_enabled', {Text = 'third person', Default = false, Callback = function(first)
        tp_enabled = first
        if not first then
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end}):AddKeyPicker('thirdperson_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'third person', NoUI = false})
    mvb:AddSlider('thirdperson_distance', {Text = 'distance', Default = 10, Min = 0, Max = 50, Rounding = 1, Callback = function(state)
        tp_dist = state
    end})
    mvb:AddToggle('jesus_walk_water', {Text = 'Jesus (walk on water)', Default = false, Callback = function(first)
        jesus_enabled = first
    end})
    mvb:AddToggle('spiderman_enabled', {Text = 'spiderman mode', Default = false, Callback = function(first)
        spiderman_enabled = first
    end}):AddKeyPicker('spiderman_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'spiderman bind', NoUI = false})
    mvb:AddSlider('spiderman_speed', {Text = 'climb speed', Default = 26, Min = 8, Max = 60, Rounding = 0, Suffix = 'sps', Compact = false, Callback = function(value)
        spiderman_speed = value
    end})
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function(delta)
        local character = LocalPlayer.Character
        local humanoid = character and _FindFirstChildOfClass(character, "Humanoid")
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if humanoid then
            if speed_enabled then
                humanoid.WalkSpeed = speed
            end
        end
        if tp_enabled then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = tp_dist
            LocalPlayer.CameraMinZoomDistance = tp_dist
            if humanoid then
                humanoid.CameraOffset = _Vector3new(0, 2, 0)
            end
            if not cheat.Library.Opened then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                if hrp then
                    local look = Camera.CFrame.LookVector
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + _Vector3new(look.X, 0, look.Z))
                end
            end
        else
            if humanoid then
                humanoid.CameraOffset = _Vector3new(0, 0, 0)
            end
        end

        if spiderman_enabled and humanoid and hrp and UserInputService:IsKeyDown(Enum.KeyCode.W) then
            local forward = Camera.CFrame.LookVector
            local wall_direction = _Vector3new(forward.X, 0, forward.Z)
            if wall_direction.Magnitude > 0 then
                local wall_params = RaycastParams.new()
                wall_params.FilterType = Enum.RaycastFilterType.Exclude
                wall_params.FilterDescendantsInstances = {character, Camera}
                local wall = workspace:Raycast(hrp.Position, wall_direction.Unit * 3.5, wall_params)
                if wall and math.abs(wall.Normal.Y) < 0.65 then
                    local velocity = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = _Vector3new(velocity.X, spiderman_speed, velocity.Z)
                    humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
                end
            end
        end

        -- Walk on water / Jesus logic
        if jesus_enabled and hrp then
            local RAY = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
            local _, Position, _, Material = workspace:FindPartOnRayWithWhitelist(RAY, { workspace.Terrain })

            if Material and Material == Enum.Material.Water then
                if not water_part then
                    local parent = workspace:FindFirstChild("NoCollision") or workspace
                    water_part = Instance.new("Part", parent)
                    water_part.Transparency = 1
                    water_part.Size = Vector3.new(10, 1, 10)
                    water_part.CanCollide = true
                    water_part.Anchored = true
                else
                    water_part.Position = Position
                end
            else
                if water_part then
                    water_part:Destroy()
                    water_part = nil
                end
            end
        else
            if water_part then
                water_part:Destroy()
                water_part = nil
            end
        end
    end))
    local misctab = ui.tabs.misc:AddRightGroupbox('misc')
    local camera_pos_enabled = false
    local camera_pos_offset = Vector3.new(0, 0, 0)
    misctab:AddToggle('camera_pos', {Text = 'camera pos', Default = false, Callback = function(v)
        camera_pos_enabled = v
        -- Ensure the default camera controller is active before applying the
        -- offset. The old implementation left the camera Scriptable, which
        -- prevented normal mouse-look from updating it.
        if v and not cheat.freecam_enabled and workspace.CurrentCamera then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end})
    misctab:AddSlider('camera_pos_x', { Text = 'camera pos X', Default = 0, Min = -50, Max = 50, Rounding = 1, Compact = true, Callback = function(v)
        camera_pos_offset = Vector3.new(v, camera_pos_offset.Y, camera_pos_offset.Z)
    end})
    misctab:AddSlider('camera_pos_y', { Text = 'camera pos Y', Default = 0, Min = -50, Max = 50, Rounding = 1, Compact = true, Callback = function(v)
        camera_pos_offset = Vector3.new(camera_pos_offset.X, v, camera_pos_offset.Z)
    end})
    misctab:AddSlider('camera_pos_z', { Text = 'camera pos Z', Default = 0, Min = -50, Max = 50, Rounding = 1, Compact = true, Callback = function(v)
        camera_pos_offset = Vector3.new(camera_pos_offset.X, camera_pos_offset.Y, v)
    end})
    -- Run after Roblox's camera controller so the offset is applied to the
    -- current camera pose each frame, without locking its rotation or
    -- accumulating the offset from prior frames.
    RunService:BindToRenderStep("CameraPositionOffset", Enum.RenderPriority.Camera.Value + 1, function()
        if not camera_pos_enabled or cheat.freecam_enabled then return end

        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not root or not cam or cam.CameraType == Enum.CameraType.Scriptable then return end

        local offset = root.CFrame:VectorToWorldSpace(camera_pos_offset)
        cam.CFrame = cam.CFrame + offset
        cam.Focus = cam.Focus + offset
    end)
    misctab:AddToggle('target_data_window_toggle', { Text = 'target data window', Default = false, Callback = function(v)
        if cheat.target_data_window then cheat.target_data_window:SetVisible(v) end
    end })
    local hit_sounds = {
        ["never lose"] = "rbxassetid://6607204501",
        ["rust"] = "rbxassetid://4764109000",
        ["gamesense"] = "rbxassetid://4817809188",
        ["fatalety"] = "rbxassetid://94204395881101",
        ["bubble"] = "rbxassetid://85730811347567",
        ["fahhhh"] = "rbxassetid://134512042804789",
        ["csgo kill"] = "rbxassetid://7269900245",
        ["csgo headshot"] = "rbxassetid://6937353691",
        ["minecraft bow"] = "rbxassetid://1053296915",
        ["fortnite headshot"] = "rbxassetid://2513174484",
        ["arsenal headshot"] = "rbxassetid://8522515167",
        ["fallen headshot"] = "rbxassetid://988593556",
        ["mogged"] = "rbxassetid://130607335183129",
        ["moan"] = "rbxassetid://7606020137",
        ["mommy asmr"] = "rbxassetid://111500468013640"
    }
    local custom_hitsound_enabled = false
    local custom_hitsound_id = "rbxassetid://6607204501"
    local custom_hitsound_volume = 1

    misctab:AddToggle('custom_hitsound_enable', {Text = 'custom hit sound', Default = false, Callback = function(c)
        custom_hitsound_enabled = c
    end})
    misctab:AddDropdown('custom_hitsound_select', {Text = 'hit sound', Default = 1, Values = {'never lose', 'rust', 'gamesense', 'fatalety','bubble', 'fahhhh', 'csgo kill', 'csgo headshot', 'minecraft bow', 'fortnite headshot', 'arsenal headshot', 'fallen headshot', 'mogged', 'moan', 'mommy asmr'}, Callback = function(v)
        custom_hitsound_id = hit_sounds[v]
    end})
    misctab:AddSlider('custom_hitsound_vol', {Text = 'hit sound volume', Default = 100, Min = 1, Max = 500, Rounding = 0, Callback = function(v)
        custom_hitsound_volume = v / 100
    end})
    misctab:AddButton('test hit sound', function()
        local sound = Instance.new("Sound")
        sound.SoundId = custom_hitsound_id
        sound.Volume = custom_hitsound_volume
        if custom_hitsound_id == "rbxassetid://7606020137" then
            sound.TimePosition = 2
            task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
        end
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
    end)

    local custom_gunsound_enabled = false
    local custom_gunsound_id = "rbxassetid://3060494212"
    local custom_gunsound_volume = 1

    local gun_sounds = {
        ["bubble"] = "rbxassetid://85730811347567",
        ["minecraft bow"] = "rbxassetid://3442683707",
        ["oof"] = "rbxassetid://3060494212",
        ["fart"] = "rbxassetid://3068648094",
        ["hee hee"] = "rbxassetid://3048623108",
        ["this is sparta"] = "rbxassetid://130781067",
        ["godzilla"] = "rbxassetid://130783046",
        ["roger that"] = "rbxassetid://135308704",
        ["fallen pkm"] = "rbxassetid://4803858563"
    }

    misctab:AddToggle('custom_gunsound_enable', {Text = 'custom gun sound', Default = false, Callback = function(c)
        custom_gunsound_enabled = c
    end})
    misctab:AddDropdown('custom_gunsound_select', {Text = 'gun sound', Default = 1, Values = {'bubble','minecraft bow', 'oof', 'fart', 'hee hee', 'this is sparta', 'godzilla', 'roger that', 'fallen pkm'}, Callback = function(v)
        custom_gunsound_id = gun_sounds[v]
    end})
    misctab:AddSlider('custom_gunsound_vol', {Text = 'gun sound volume', Default = 100, Min = 1, Max = 500, Rounding = 0, Callback = function(v)
        custom_gunsound_volume = v / 100
    end})
    misctab:AddButton('test gun sound', function()
        local sound = Instance.new("Sound")
        sound.SoundId = custom_gunsound_id
        sound.Volume = custom_gunsound_volume
        if custom_gunsound_id == "rbxassetid://7606020137" then
            sound.TimePosition = 2
            task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
        end
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 5)
    end)

    local gun_sounds_volume = 100
    local hitmarker_sounds_volume = 100

    local gun_sound_names = {
        ["FireSound"] = true,
        ["FireFarSound"] = true,
        ["FireSoundSupressed"] = true,
    }

    -- the 4 impact sounds we intercept for custom hitsound
    local hitsound_ids = {
        ["rbxassetid://4585382589"] = true,
        ["rbxassetid://4585351098"] = true,
        ["rbxassetid://4585382046"] = true,
        ["rbxassetid://4585364605"] = true,
    }

    -- all hitmarker sounds (for the volume slider)
    local hitmarker_sound_ids = {
        ["rbxassetid://4585382589"] = true,
        ["rbxassetid://4585351098"] = true,
        ["rbxassetid://4585382046"] = true,
        ["rbxassetid://4585364605"] = true,
        ["rbxassetid://9120454415"] = true,
        ["rbxassetid://4504226333"] = true,
        ["rbxassetid://6668102812"] = true,
        ["rbxassetid://9119166195"] = true,
        ["rbxassetid://4581728529"] = true,
    }

    local function check_sound_volume(sound)
        if not sound:IsA("Sound") then return end
        local soundid = sound.SoundId
        local is_impact = hitsound_ids[soundid]
        local is_hit = hitmarker_sound_ids[soundid]
        local is_gun = gun_sound_names[sound.Name]

        if is_hit then
            cheat.utility.last_hitmarker_tick = tick()
        end

        -- If custom hitsound intercepts it, we do NOT want this volume scaler touching it.
        if custom_hitsound_enabled and is_impact then
            return -- Ignore impact sounds from the volume scaler if custom hitsound is taking them over
        end

        -- If custom gunsound intercepts it, we do NOT want this volume scaler touching it.
        if custom_gunsound_enabled and is_gun then
            sound.SoundId = custom_gunsound_id
            sound.Volume = custom_gunsound_volume
            if custom_gunsound_id == "rbxassetid://7606020137" then
                sound.TimePosition = 2
                task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
            end
            return
        end

        -- volume scaling for gun and hitmarker sounds
        if is_hit or is_gun then
            if not sound:GetAttribute("OriginalVolume") then
                sound:SetAttribute("OriginalVolume", sound.Volume)
            end
            local vol = is_hit and hitmarker_sounds_volume or gun_sounds_volume
            sound.Volume = sound:GetAttribute("OriginalVolume") * (vol / 100)
            sound:GetPropertyChangedSignal("Volume"):Connect(function()
                local orig_vol = sound:GetAttribute("OriginalVolume")
                if not orig_vol then return end

                local new_vol = sound.Volume
                local current_target_vol = is_hit and hitmarker_sounds_volume or gun_sounds_volume
                local expected_vol = orig_vol * (current_target_vol / 100)
                if math.abs(new_vol - expected_vol) > 0.01 then
                    sound:SetAttribute("OriginalVolume", new_vol)
                    sound.Volume = new_vol * (current_target_vol / 100)
                end
            end)
        end
    end

    game.DescendantAdded:Connect(check_sound_volume)
    for _, child in ipairs(game:GetDescendants()) do
        check_sound_volume(child)
    end

    misctab:AddSlider('gun_sounds_volume', {Text = 'gun sounds volume', Default = 100, Min = 0, Max = 100, Rounding = 0, Callback = function(v)
        gun_sounds_volume = v
        for _, child in ipairs(game:GetDescendants()) do
            if child:IsA("Sound") and gun_sound_names[child.Name] and child:GetAttribute("OriginalVolume") then
                child.Volume = child:GetAttribute("OriginalVolume") * (v / 100)
            end
        end
    end})
    misctab:AddSlider('hitmarker_sounds_volume', {Text = 'hitmarker sounds volume', Default = 100, Min = 0, Max = 100, Rounding = 0, Callback = function(v)
        hitmarker_sounds_volume = v
    end})

    local unlock_all_skins_enabled = false
    misctab:AddToggle('unlock_all_skins', { Text = 'unlock all skins (client)', Default = false, Callback = function(v)
        unlock_all_skins_enabled = v
    end})

    task.spawn(function()
        pcall(function()
            local fl = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FunctionLibraryExtension"))
            if fl and fl.UpdateSkin then
                local old_UpdateSkin = fl.UpdateSkin
                fl.UpdateSkin = function(self, p140, p141, p142)
                    if p140 and typeof(p140) == "Instance" and p140:IsA("ObjectValue") then
                        local rep = ReplicatedStorage
                        local p_inv = rep:FindFirstChild("Players") and rep.Players:FindFirstChild(LocalPlayer.Name) and rep.Players[LocalPlayer.Name]:FindFirstChild("Inventory")
                        if p_inv then
                            for _, item in ipairs(p_inv:GetChildren()) do
                                if item:IsA("ObjectValue") and item.Value == p140.Value then
                                    local forced = item:GetAttribute("Skin")
                                    if forced ~= nil then
                                        p142 = (forced == "" and nil or forced)
                                    end
                                    break
                                end
                            end
                        end
                    end
                    return old_UpdateSkin(self, p140, p141, p142)
                end

                if fl.FindDeepAncestor then
                    fl.FindDeepAncestor = function(self, p92, p93, p94)
                        local v95 = 0
                        if not p92 or typeof(p92) ~= "Instance" then return p92 end
                        while p92 and p92.Parent and p92.Parent.ClassName == p93 do
                            if p92.Parent.Parent and p92.Parent.Parent.Parent and p92.Parent.Parent.Parent.Name == "Attachments" then
                                p92 = p92.Parent.Parent.Parent
                            else
                                p92 = p92.Parent
                            end
                            v95 = v95 + 1
                            if p94 and typeof(p94) == "table" and p94.SearchForInteraction then
                                if p92:GetAttribute(p94.SearchForInteraction) then break end
                            end
                            if v95 > 10 or p92:FindFirstChild("DeepAncestorBreak") or p92:FindFirstChild("Moving") then
                                break
                            end
                        end
                        return p92
                    end
                end
            end
        end)
    end)

    task.spawn(function()
        local rep = ReplicatedStorage
        while task.wait(2) do
            if unlock_all_skins_enabled then
                pcall(function()
                    local p_purchases = rep:FindFirstChild("Players") and rep.Players:FindFirstChild(LocalPlayer.Name) and rep.Players[LocalPlayer.Name]:FindFirstChild("Status") and rep.Players[LocalPlayer.Name].Status:FindFirstChild("Purchases")
                    if p_purchases then
                        if not p_purchases:FindFirstChild("Skins") then
                            local s = Instance.new("Folder")
                            s.Name = "Skins"
                            s.Parent = p_purchases
                        end
                        local p_skins = p_purchases.Skins

                        local function unlock_from(folder_name)
                            local f = rep:FindFirstChild(folder_name)
                            if f then
                                for _, weapon_skins in pairs(f:GetChildren()) do
                                    local p_weapon = p_skins:FindFirstChild(weapon_skins.Name)
                                    if not p_weapon then
                                        p_weapon = Instance.new("Folder")
                                        p_weapon.Name = weapon_skins.Name
                                        p_weapon.Parent = p_skins
                                    end
                                    for _, skin in pairs(weapon_skins:GetChildren()) do
                                        if not p_weapon:FindFirstChild(skin.Name) then
                                            local mock = Instance.new("Folder")
                                            mock.Name = skin.Name
                                            mock.Parent = p_weapon
                                        end
                                    end
                                end
                            end
                        end
                        unlock_from("skins")
                        unlock_from("skin packs")
                        unlock_from("Skin Packs")
                        unlock_from("Skins")
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        local rep = ReplicatedStorage
        while task.wait(0.1) do
            pcall(function()
                local p_inv = rep:FindFirstChild("Players") and rep.Players:FindFirstChild(LocalPlayer.Name) and rep.Players[LocalPlayer.Name]:FindFirstChild("Inventory")
                local p_holding = rep:FindFirstChild("Players") and rep.Players:FindFirstChild(LocalPlayer.Name) and rep.Players[LocalPlayer.Name]:FindFirstChild("Holding")
                if p_inv and p_holding and p_holding.Value and p_holding.Value:IsA("ObjectValue") then
                    local active_weapon = p_holding.Value
                    local weapon_name = active_weapon.Value and active_weapon.Value.Name
                    for _, item in ipairs(p_inv:GetChildren()) do
                        if item:IsA("ObjectValue") and item.Value == active_weapon.Value then
                            local forced_skin = item:GetAttribute("SpoofedSkin")
                            if forced_skin ~= nil then
                                local target_skin = (forced_skin == "" and nil or forced_skin)
                                if active_weapon:GetAttribute("Skin") ~= target_skin then
                                    active_weapon:SetAttribute("Skin", target_skin)
                                end

                                if target_skin and weapon_name then
                                    local fl = require(rep:WaitForChild("Modules"):WaitForChild("FunctionLibraryExtension"))
                                    local function paint_model(parent)
                                        if not parent then return end
                                        local w_model = parent:FindFirstChild(weapon_name)
                                        if w_model and w_model:IsA("Model") and w_model:GetAttribute("SpoofSkinApplied") ~= target_skin then
                                            pcall(function()
                                                fl:UpdateSkin(nil, w_model, target_skin)
                                                w_model:SetAttribute("SpoofSkinApplied", target_skin)
                                            end)
                                        end
                                    end
                                    paint_model(LocalPlayer.Character)
                                    local cam = workspace.CurrentCamera
                                    if cam then
                                        for _, child in ipairs(cam:GetChildren()) do
                                            if child:GetAttribute("Temp") or child.Name == LocalPlayer.Name then
                                                paint_model(child)
                                            end
                                        end
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end)
        end
    end)
    for _, child in ipairs(game:GetDescendants()) do
        if child:IsA("Sound") and hitmarker_sound_ids[child.SoundId] and child:GetAttribute("OriginalVolume") then
            child.Volume = child:GetAttribute("OriginalVolume") * (hitmarker_sounds_volume / 100)
        end
    end

    local player_gui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    player_gui.ChildAdded:Connect(function(child)
        if child.Name == "MainGui" then
            child.ChildAdded:Connect(function(sound)
                if sound:IsA("Sound") and custom_hitsound_enabled then
                    if sound.SoundId == "rbxassetid://4585382589" or sound.SoundId == "rbxassetid://4585351098" or sound.SoundId == "rbxassetid://4585382046" or sound.SoundId == "rbxassetid://4585364605" then
                        sound.SoundId = custom_hitsound_id
                        sound.Volume = custom_hitsound_volume
                        if custom_hitsound_id == "rbxassetid://7606020137" then
                            sound.TimePosition = 2
                            task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
                        end
                    end
                end
            end)
        end
    end)

    local main_gui = player_gui:FindFirstChild("MainGui")
    if main_gui then
        main_gui.ChildAdded:Connect(function(sound)
            if sound:IsA("Sound") and custom_hitsound_enabled then
                if sound.SoundId == "rbxassetid://4585382589" or sound.SoundId == "rbxassetid://4585351098" or sound.SoundId == "rbxassetid://4585382046" or sound.SoundId == "rbxassetid://4585364605" then
                    sound.SoundId = custom_hitsound_id
                    sound.Volume = custom_hitsound_volume
                    if custom_hitsound_id == "rbxassetid://7606020137" then
                        sound.TimePosition = 2
                        task.delay(0.9, function() if sound and sound.Parent then sound:Stop() end end)
                    end
                end
            end
        end)
    end
end
do
    local fmvb = ui.tabs.misc:AddLeftGroupbox('peek tp')
    local fly_enabled, fly_speed, fly_yspeed = false, 10, 10
    local fly_collision_state = {}
    local fly_blink_origin = nil
    local fly_blink_target = nil
    local fly_blink_return_at = 0
    local fly_next_blink_at = 0

    local function set_fly_noclip(enabled)
        local character = LocalPlayer.Character
        if not character then return end
        if enabled then
            for _, part in character:GetDescendants() do
                if part:IsA("BasePart") then
                    if fly_collision_state[part] == nil then
                        fly_collision_state[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        else
            for part, can_collide in pairs(fly_collision_state) do
                if part and part.Parent then
                    part.CanCollide = can_collide
                end
            end
            fly_collision_state = {}
        end
    end

    fmvb:AddToggle('flyhack_enabled', {Text = 'peek teleport',Default = false,Callback = function(first)
        fly_enabled = first
        fly_blink_origin = nil
        fly_blink_target = nil
        fly_blink_return_at = 0
        fly_next_blink_at = 0
        set_fly_noclip(first)
    end}):AddKeyPicker('flyhack_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'tp peek',NoUI = false})
    fmvb:AddSlider('flyhack_speed',{ Text = 'peek speed', Default = 10, Min = 1, Max = 50, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        fly_speed = State
    end)
    fmvb:AddSlider('flyhack_y_speed',{ Text = 'peek y speed', Default = 10, Min = 1, Max = 50, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        fly_yspeed = State
    end)
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function(delta)
        local character = LocalPlayer.Character
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if fly_enabled and hrp then
            set_fly_noclip(true)
            local cameralook = Camera.CFrame.LookVector
            cameralook = _Vector3new(cameralook.X, 0, cameralook.Z)
            local direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.Space) and direction + Vector3.yAxis or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) and direction - Vector3.yAxis or direction;
            if direction ~= Vector3.zero then
                direction = direction.Unit
            end

            local now = tick()
            local current_cf = cheat.real_CFrame or hrp.CFrame
            if fly_blink_origin and now >= fly_blink_return_at then
                hrp.CFrame = fly_blink_origin
                cheat.real_CFrame = fly_blink_origin
                fly_blink_origin = nil
                fly_blink_target = nil
                fly_next_blink_at = now + 0.1
            elseif fly_blink_target then
                hrp.CFrame = fly_blink_target
                cheat.real_CFrame = fly_blink_origin
            elseif direction ~= Vector3.zero and now >= fly_next_blink_at then
                fly_blink_origin = current_cf
                fly_blink_target = current_cf + _Vector3new(1, 0, 1) * (direction * fly_speed) + Vector3.yAxis * (direction * fly_yspeed)
                fly_blink_return_at = now + 1
                hrp.CFrame = fly_blink_target
                cheat.real_CFrame = fly_blink_origin
            end
        elseif not fly_enabled and next(fly_collision_state) then
            set_fly_noclip(false)
        end
    end))
end
do

    local pr_fly_enabled, pr_fly_speed, pr_fly_yspeed = false, 10, 10
    local pr_fmvb = ui.tabs.misc:AddLeftGroupbox('fly')
    pr_fmvb:AddToggle('pr_flyhack_enabled', {Text = 'flyhack enabled',Default = false,Callback = function(first)
        pr_fly_enabled = first
    end}):AddKeyPicker('pr_flyhack_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'flyhack',NoUI = false})
    pr_fmvb:AddSlider('pr_flyhack_speed',{ Text = 'fly speed', Default = 10, Min = 1, Max = 50, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        pr_fly_speed = State
    end)
    pr_fmvb:AddSlider('pr_flyhack_y_speed',{ Text = 'fly y speed', Default = 10, Min = 1, Max = 50, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        pr_fly_yspeed = State
    end)
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function(delta)
        local character = LocalPlayer.Character
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if pr_fly_enabled and hrp then
            local cameralook = Camera.CFrame.LookVector
            cameralook = _Vector3new(cameralook.X, 0, cameralook.Z)
            local direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.Space) and direction + Vector3.yAxis or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) and direction - Vector3.yAxis or direction;
            if direction ~= Vector3.zero then
                direction = direction.Unit
            end
            local current_cf = hrp.CFrame
            if cheat.real_CFrame then current_cf = cheat.real_CFrame end
            local new_cf = current_cf + _Vector3new(1, 0, 1) * (direction * delta * pr_fly_speed) + Vector3.yAxis * (direction * delta * pr_fly_yspeed)
            hrp.CFrame = new_cf
            if cheat.real_CFrame then cheat.real_CFrame = new_cf end
            for _, part in character:GetDescendants() do
                if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.zero end
            end
        end
    end))
end
do
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function(delta)
        local character = LocalPlayer.Character
        local hrp = character and _FindFirstChild(character, "HumanoidRootPart")
        if enabled and hrp then
            local cameralook = Camera.CFrame.LookVector
            cameralook = _Vector3new(cameralook.X, 0, cameralook.Z)
            local direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.Space) and direction + Vector3.yAxis or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) and direction - Vector3.yAxis or direction;
            if direction ~= Vector3.zero then
                direction = direction.Unit
            end
            local current_cf = hrp.CFrame
            if cheat.real_CFrame then current_cf = cheat.real_CFrame end
            local new_cf = current_cf + _Vector3new(1, 0, 1) * (direction * delta * speed) + Vector3.yAxis * (direction * delta * yspeed)
            hrp.CFrame = new_cf
            if cheat.real_CFrame then cheat.real_CFrame = new_cf end
            for _, part in character:GetDescendants() do
                if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.zero end
            end
        end
    end))
end

do
    local game_TweenService = game:GetService("TweenService")
    local _firing_rapidly = false
    cheat.is_dead_or_respawning = false
    cheat.last_fly_or_tp_time = 0
    cheat.is_flying_or_tp = function()
        if not cheat.Toggles then return false end
        local tp_active = cheat.Toggles.tpkill_enabled and cheat.Toggles.tpkill_enabled.Value
        local fly_active = cheat.Toggles.flyhack_enabled and cheat.Toggles.flyhack_enabled.Value
        if tp_active or fly_active then
            cheat.last_fly_or_tp_time = tick()
            cheat.real_CFrame = nil
            return true
        elseif cheat.last_fly_or_tp_time > 0 and (tick() - cheat.last_fly_or_tp_time < 1.2) then
            cheat.real_CFrame = nil
            return true
        end
        return false
    end

    local __index; __index = hookmetamethod(game, "__index", newcclosure(LPH_NO_VIRTUALIZE(function(self, k)
        if checkcaller() then return __index(self, k) end

        if k == "Trail" and typeof(self) == "Instance" and self.Name == "VisualTracer" then
            local real_trail = self:FindFirstChild("Trail")
            if real_trail then return real_trail end
            return Instance.new("Trail")
        end

        if k == "Handle" and typeof(self) == "Instance" and self:IsA("Accessory") then
            local handle = self:FindFirstChild("Handle")
            if handle then return handle end
            local dummy = Instance.new("Part")
            dummy.Name = "Handle"
            dummy.Transparency = 1
            return dummy
        end

        if (k == "CFrame" or k == "Position") and cheat.real_CFrame and not cheat.is_dead_or_respawning and not cheat.is_flying_or_tp() then
            local char = LocalPlayer.Character
            if char and typeof(self) == "Instance" and self == char:FindFirstChild("HumanoidRootPart") then
                if k == "CFrame" then return cheat.real_CFrame end
                if k == "Position" then return cheat.real_CFrame.Position end
            end
        end
        return __index(self, k)
    end)))
    local __newindex; __newindex = hookmetamethod(game, "__newindex", newcclosure(LPH_NO_VIRTUALIZE(function(self, k, v)
        if checkcaller() then return __newindex(self, k, v) end
        if self == Lighting then
            if k == "ClockTime" and globals.EnableTime then return end
            if k == "GlobalShadows" and globals.noshadows then return end
            if k == "Ambient" and globals.gradientenabled then return end
            if k == "OutdoorAmbient" and globals.gradientenabled then return end
            if k == "ExposureCompensation" or k == "Brightness" then return end
        end
        if self == Camera then
            if k == "FieldOfView" and (globals.fov_enabled or globals.zoom_enabled) then
                return
            end
        end
        return __newindex(self, k, v)
    end)))
    local __namecall; __namecall = hookmetamethod(game, "__namecall", newcclosure(LPH_NO_VIRTUALIZE(function(self,...)
        if checkcaller() then return __namecall(self, ...) end
        local args = {...}
        local argCount = select("#", ...)
        local method = getnamecallmethod()
        local methodstr = tostring(method)



        if methodstr == "InvokeServer" or methodstr == "invokeServer" or methodstr == "FireServer" or methodstr == "fireServer" then
            local success, rname = pcall(function() return self.Name end)
            if success and rname == "ChangeSkin" then
                local weaponObj = args[1]
                local skinName = args[2]
                if weaponObj then
                    if tostring(skinName) == "Default" then
                        pcall(function() weaponObj:SetAttribute("SpoofedSkin", "") end)
                    else
                        pcall(function() weaponObj:SetAttribute("SpoofedSkin", tostring(skinName)) end)
                    end
                    return true
                end
            end
        end
        if self == game_TweenService and method == "Create" and args[1] == Camera and rawget(args[3], "FieldOfView") and (globals.fov_enabled or globals.zoom_enabled) then
            args[3] = {}
            setnamecallmethod(methodstr)
            return __namecall(self, unpack(args, 1, argCount))
        end
        if method == "Play" and typeof(self) == "Instance" and self.ClassName == "Sound" then
            local sname = self.Name
            local gun_vol = cheat._gun_sounds_volume and cheat._gun_sounds_volume() or 100
            if gun_vol < 100 then
                if sname == "FireSound" or sname == "FireFarSound" or sname == "FireSoundSupressed" then
                    if gun_vol == 0 then return end
                    if not self:GetAttribute("OriginalVolume") then
                        self:SetAttribute("OriginalVolume", self.Volume)
                    end
                    self.Volume = self:GetAttribute("OriginalVolume") * (gun_vol / 100)
                end
            end
            local hit_vol = cheat._hitmarker_sounds_volume and cheat._hitmarker_sounds_volume() or 100
            if hit_vol < 100 then
                if sname == "Helmet" or sname == "BodyArmor" or sname == "Bodyshot" or sname == "Headshot" or sname == "Kill" or sname == "BarbedWire" or sname == "Vehicle" or sname == "Burn" or self.SoundId == "rbxassetid://4581728529" then
                    if hit_vol == 0 then return end
                    if not self:GetAttribute("OriginalVolume") then
                        self:SetAttribute("OriginalVolume", self.Volume)
                    end
                    self.Volume = self:GetAttribute("OriginalVolume") * (hit_vol / 100)
                end
            end
        end
        if method == "GetAttribute" then
            local attribute = args[1]
            if silent_aim.nospread and attribute == "AccuracyDeviation" then
                return 0
            end
            if silent_aim.enabled then
                if attribute == "ProjectileDrop" then
                    return 0
                end
                if attribute == "Drag" then
                    return 0
                end
            end
        end
        if method == "InvokeServer" and self.Name == "FireProjectile" then
            if silent_aim then silent_aim._exact_fire_tick = tick() end
            local is_empty = false
            local weapon_name = get_local_weapon and get_local_weapon() or "None"
            if weapon_name ~= "None" then
                local rpplrs = ReplicatedStorage:FindFirstChild("Players")
                local rpinv = rpplrs and rpplrs:FindFirstChild(LocalPlayer.Name) and rpplrs[LocalPlayer.Name]:FindFirstChild("Inventory")
                local inv_weapon = rpinv and rpinv:FindFirstChild(weapon_name)
                if inv_weapon and inv_weapon:FindFirstChild("SettingsModule") then
                    local magazine = _FindFirstChild(inv_weapon, "Attachments") and _FindFirstChild(inv_weapon.Attachments, "Magazine") and inv_weapon.Attachments.Magazine:FindFirstChildOfClass("StringValue")
                    local loadedammo = magazine and magazine:FindFirstChild("ItemProperties") and magazine.ItemProperties:FindFirstChild("LoadedAmmo")
                    local ammo_count = 0
                    if loadedammo then
                        if loadedammo:IsA("Folder") then
                            ammo_count = #loadedammo:GetChildren()
                        else
                            ammo_count = loadedammo:GetAttribute("LoadedAmmo") or loadedammo:GetAttribute("Ammo") or 0
                        end
                    end
                    if not magazine or ammo_count <= 0 then
                        is_empty = true
                    end
                end
            end
            if is_empty then
                return
            end

            local real_orig = Camera.CFrame.p
            local origin_spoofed = false

            if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                real_orig = silent_aim.manipulated_origin
                origin_spoofed = true
            elseif cheat.freecam_enabled then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Head") then
                    real_orig = char.Head.Position
                    origin_spoofed = true
                end
            end

            if origin_spoofed and silent_aim.enabled and silent_aim.target_part then
                args[1] = (silent_aim.target_part.Position - real_orig).Unit
            elseif origin_spoofed and cheat.freecam_enabled then
                local hit_pos = Mouse.Hit.Position
                args[1] = (hit_pos - real_orig).Unit
            end

            if not _firing_rapidly and silent_aim.enabled and silent_aim.instant and silent_aim.target_part then
                local dist = (silent_aim.target_part.Position - real_orig).Magnitude
                args[3] = tick() - (dist / 1000)
            end
            setnamecallmethod(methodstr)
            return __namecall(self, unpack(args, 1, argCount))
        end
        if method == "Raycast" then
            local origin = args[1]
            if typeof(origin) == "Vector3" then
                if cheat.freecam_enabled then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Head") then
                        origin = char.Head.Position
                        args[1] = origin
                    end
                end

                if silent_aim.enabled and silent_aim.target_part then
                    local hitpart = silent_aim.target_part
                    if hitpart and hitpart.Parent then
                        if silent_aim.corner_shoot and silent_aim.manipulated_origin then
                            origin = silent_aim.manipulated_origin
                            args[1] = origin
                        end

                        local direction = hitpart.Position - origin
                        args[2] = direction
                        return {
                            Instance = hitpart,
                            Position = hitpart.Position,
                            Normal = direction.Unit * -1,
                            Material = hitpart.Material,
                            Distance = direction.Magnitude
                        }
                    end
                end
            end
        end
        -- hit sound is handled via MainGui.ChildAdded, not here
        setnamecallmethod(methodstr)
        return __namecall(self, unpack(args, 1, argCount))
    end)))

end
-- Add color pickers for the theme. These are chained to dummy toggles as a workaround.
ui.box.themeconfig:AddToggle('accent_color_toggle', {Text = 'Accent Color',Default = true, Callback = function() end}):AddColorPicker('accent_color', {
    Default = Color3.fromRGB(120, 110, 180),
    Title = 'accent color',
    Transparency = 0,
    Callback = function(Value)
        tipanel_settings.accentcolor = Value
    end
})
ui.box.themeconfig:AddToggle('glow_color_toggle', {Text = 'Glow Color',Default = true, Callback = function() end}):AddColorPicker('glow_color', {
    Default = Color3.fromRGB(120, 110, 180),
    Title = 'glow color',
    Transparency = 0,
    Callback = function(Value)
        tipanel_settings.glowcolor = Value
    end
})
ui.box.themeconfig:AddToggle('bg_color_toggle', {Text = 'Background Color',Default = true, Callback = function() end}):AddColorPicker('bg_color', {
    Default = Color3.fromRGB(15, 15, 15),
    Title = 'background color',
    Transparency = 0,
    Callback = function(Value)
        tipanel_settings.bgcolor = Value
    end
})
ui.box.themeconfig:AddToggle('border_color_toggle', {Text = 'Border Color',Default = true, Callback = function() end}):AddColorPicker('border_color', {
    Default = Color3.fromRGB(45, 45, 45),
    Title = 'border color',
    Transparency = 0,
    Callback = function(Value)
        tipanel_settings.bordercolor = Value
    end
})

ui.box.themeconfig:AddToggle('keybindshoww', {Text = 'show keybinds UI',Default = false,Callback = function(first)cheat.Library.KeybindFrame.Visible = first end})

-- ─── ANTI-AIM TAB ────────────────────────────────────────────────────────────
do
    local aa = ui.box.antiaim:AddTab('anti aim')

    local aa_enabled = false
    local aa_mode = "Reverse"
    local aa_spin_speed = 10
    local aa_yaw_offset = 0
    local flat_angle = nil
    local flat_rotation = CFrame.Identity
    local nogravity_phase = Vector3.new(
        math.random() * math.pi * 2,
        math.random() * math.pi * 2,
        math.random() * math.pi * 2
    )
    local nogravity_rotation = CFrame.Angles(
        nogravity_phase.X,
        nogravity_phase.Y,
        nogravity_phase.Z
    )
    local set_aa_visual_hidden
    local destroy_aa_visual
    local create_aa_visual

    aa:AddToggle('aa_enabled', {Text = 'anti aim enabled', Default = false, Callback = function(v)
        aa_enabled = v
        if not v then
            set_aa_visual_hidden(false)
            destroy_aa_visual()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.AutoRotate = true
            end
            if not fake_lag_enabled and not silent_aim.corner_shoot and not visualize_server_pos then
                aa_cleanup()
            end
        end
    end}):AddKeyPicker('aa_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'anti aim bind', NoUI = false})

    aa:AddDropdown('aa_mode', {Text = 'anti aim mode', Default = 1, Values = {"Reverse", "Spin", "Random", "Flat", "FlatRandom", "nogravity", "None"}, Callback = function(v)
        aa_mode = v
        flat_angle = nil
        flat_rotation = CFrame.Identity
        if v == "Flat" or v == "FlatRandom" then
            flat_angle = math.rad(math.random(0, 360))
            flat_rotation = CFrame.Angles(0, flat_angle, 0) * CFrame.Angles(math.rad(90), 0, 0)
        elseif v == "nogravity" then
            nogravity_rotation = CFrame.Angles(
                nogravity_phase.X,
                nogravity_phase.Y,
                nogravity_phase.Z
            )
        end
    end})

    aa:AddSlider('aa_spin_speed', {Text = 'spin speed', Default = 10, Min = 1, Max = 100, Rounding = 0, Callback = function(v)
        aa_spin_speed = v
    end})

    local aa_upside_down = false
    aa:AddToggle('aa_upside_down', {Text = 'upside down', Default = false, Callback = function(v)
        aa_upside_down = v
    end})

    local aa_upside_down_changer = false
    local last_upside_down_change = 0
    aa:AddToggle('aa_upside_down_changer', {Text = 'upside down changer', Default = false, Callback = function(v)
        aa_upside_down_changer = v
    end})

    aa:AddSlider('aa_yaw_offset', {Text = 'yaw offset', Default = 0, Min = -360, Max = 360, Rounding = 0, Callback = function(v)
        aa_yaw_offset = v
    end})

    local aa_pitch_value = 0
    aa:AddSlider('aa_pitch_value', {Text = 'direction look changer (tilt)', Default = 0, Min = -250, Max = 250, Rounding = 0, Callback = function(v)
        aa_pitch_value = v
    end})

    local fake_lag_enabled = false
    local fake_lag_interval = 0.4
    aa:AddToggle('fake_lag_enabled', {Text = 'fake lag desync', Default = false, Callback = function(v)
        fake_lag_enabled = v
        if not v then
            fake_lag_CFrame = nil
            if not aa_enabled and not silent_aim.corner_shoot and not visualize_server_pos then
                aa_cleanup()
            end
        end
    end}):AddKeyPicker('fake_lag_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'fake lag desync', NoUI = false})
    aa:AddSlider('fake_lag_interval', {Text = 'fake lag interval', Default = 0.4, Min = 0.1, Max = 0.7, Rounding = 1, Callback = function(v)
        fake_lag_interval = v
    end})

    local visualize_server_pos = false
    local visualize_color = Color3.fromRGB(255, 50, 50)
    aa:AddToggle('visualize_server_pos', {Text = 'visualize server pos', Default = false, Callback = function(v)
        visualize_server_pos = v
        if not v and not aa_enabled and not fake_lag_enabled and not silent_aim.corner_shoot then
            aa_cleanup()
        end
    end}):AddColorPicker('visualize_color', {Text = 'visualize color', Default = Color3.fromRGB(255, 50, 50), Callback = function(v)
        visualize_color = v
    end})

    local visualize_transparency = 0
    aa:AddSlider('visualize_transparency', {Text = 'visualize transparency', Default = 0, Min = 0, Max = 1, Rounding = 2, Callback = function(v)
        visualize_transparency = v
    end})

    local aa_custom_offset = false
    aa:AddToggle('aa_custom_offset', {Text = 'custom position offset', Default = false, Callback = function(v)
        aa_custom_offset = v
    end})

    local aa_custom_offset_radius = 5
    aa:AddSlider('aa_custom_offset_radius', {Text = 'offset radius', Default = 5, Min = 1, Max = 5, Rounding = 1, Callback = function(v)
        aa_custom_offset_radius = v
    end})

    local aa_floor_clip = false
    local aa_floor_clip_depth = 5
    aa:AddToggle('aa_floor_clip', {Text = 'floor clip', Default = false, Callback = function(v)
        aa_floor_clip = v
    end})
    aa:AddSlider('aa_floor_clip_depth', {Text = 'floor clip depth', Default = 3, Min = 0, Max = 5, Rounding = 1, Callback = function(v)
        aa_floor_clip_depth = v
    end})

    local current_jitter_offset = Vector3.zero
    local target_jitter_offset = Vector3.zero
    local fake_lag_CFrame = nil
    local last_fake_lag_time = 0
    local last_sent_server_cframe = nil
    local server_pos_cham = nil
    local server_pos_motors = {}
    local aa_visual_character = nil
    local aa_visual_motors = {}
    local real_visual_character = nil
    local real_visual_motors = {}
    local aa_hidden_properties = {}

    local function is_third_person_enabled()
        return cheat.Toggles and cheat.Toggles.thirdperson_enabled and cheat.Toggles.thirdperson_enabled.Value
    end

    local function should_show_server_pos()
        return visualize_server_pos and is_third_person_enabled()
    end

    local function destroy_server_pos_cham()
        if server_pos_cham then
            server_pos_cham:Destroy()
            server_pos_cham = nil
        end
        server_pos_motors = {}
    end

    local function apply_server_pos_forcefield(model)
        if not model then return end
        for _, object in ipairs(model:GetDescendants()) do
            if object:IsA("BasePart") then
                object.Material = Enum.Material.ForceField
                object.Color = visualize_color
                object.Reflectance = 0
                object.Transparency = visualize_transparency
                object.LocalTransparencyModifier = 0
                object.CanCollide = false
                object.CanTouch = false
                object.CanQuery = false
                object.Massless = true
                object.Anchored = true
            elseif object:IsA("Decal") or object:IsA("Texture") then
                object.Transparency = 1
            elseif object:IsA("Shirt") or object:IsA("Pants") or object:IsA("ShirtGraphic") or object:IsA("Clothing") then
                object:Destroy()
            end
        end
    end

    set_aa_visual_hidden = function(hidden)
        local char = LocalPlayer.Character
        if not char then return end
        for _, object in ipairs(char:GetDescendants()) do
            if object:IsA("BasePart") then
                if hidden then
                    if aa_hidden_properties[object] == nil then
                        aa_hidden_properties[object] = {
                            Transparency = object.Transparency,
                            LocalTransparencyModifier = object.LocalTransparencyModifier
                        }
                    end
                    object.Transparency = 1
                    object.LocalTransparencyModifier = 1
                elseif aa_hidden_properties[object] then
                    object.Transparency = aa_hidden_properties[object].Transparency
                    object.LocalTransparencyModifier = aa_hidden_properties[object].LocalTransparencyModifier
                end
            elseif object:IsA("Decal") or object:IsA("Texture") then
                if hidden then
                    if aa_hidden_properties[object] == nil then
                        aa_hidden_properties[object] = object.Transparency
                    end
                    object.Transparency = 1
                elseif aa_hidden_properties[object] ~= nil then
                    object.Transparency = aa_hidden_properties[object]
                end
            elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                if hidden then
                    if aa_hidden_properties[object] == nil then
                        aa_hidden_properties[object] = object.Enabled
                    end
                    object.Enabled = false
                elseif aa_hidden_properties[object] ~= nil then
                    object.Enabled = aa_hidden_properties[object]
                end
            end
        end
        if not hidden then
            aa_hidden_properties = {}
        end
    end

    destroy_aa_visual = function()
        if aa_visual_character then
            aa_visual_character:Destroy()
            aa_visual_character = nil
        end
        aa_visual_motors = {}
        if real_visual_character then
            real_visual_character:Destroy()
            real_visual_character = nil
        end
        real_visual_motors = {}
    end

    create_aa_visual = function(char)
        destroy_aa_visual()
        local old_archivable = char.Archivable
        char.Archivable = true
        aa_visual_character = char:Clone()
        char.Archivable = old_archivable
        if not aa_visual_character then return end
        aa_visual_character.Name = "AntiAimVisual"
        for _, object in ipairs(aa_visual_character:GetDescendants()) do
            if object:IsA("BasePart") then
                object.Anchored = true
                object.CanCollide = false
                object.CanTouch = false
                object.CanQuery = false
                object.LocalTransparencyModifier = 0
            elseif object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") or object:IsA("Humanoid") then
                object:Destroy()
            end
        end
        local source_motors, visual_motors = {}, {}
        for _, object in ipairs(char:GetDescendants()) do
            if object:IsA("Motor6D") then table.insert(source_motors, object) end
        end
        for _, object in ipairs(aa_visual_character:GetDescendants()) do
            if object:IsA("Motor6D") then table.insert(visual_motors, object) end
        end
        for index, visual_motor in ipairs(visual_motors) do
            if source_motors[index] then
                table.insert(aa_visual_motors, {source = source_motors[index], visual = visual_motor})
            end
        end
        aa_visual_character.Parent = workspace.Terrain
        local old_real_archivable = char.Archivable
        char.Archivable = true
        real_visual_character = char:Clone()
        char.Archivable = old_real_archivable
        if real_visual_character then
            real_visual_character.Name = "RealPositionVisual"
            for _, object in ipairs(real_visual_character:GetDescendants()) do
                if object:IsA("BasePart") then
                    object.Anchored = true
                    object.CanCollide = false
                    object.CanTouch = false
                    object.CanQuery = false
                    object.LocalTransparencyModifier = 0
                elseif object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") or object:IsA("Humanoid") then
                    object:Destroy()
                end
            end
            local real_source_motors, real_visual_motors_list = {}, {}
            for _, object in ipairs(char:GetDescendants()) do
                if object:IsA("Motor6D") then table.insert(real_source_motors, object) end
            end
            for _, object in ipairs(real_visual_character:GetDescendants()) do
                if object:IsA("Motor6D") then table.insert(real_visual_motors_list, object) end
            end
            for index, visual_motor in ipairs(real_visual_motors_list) do
                if real_source_motors[index] then
                    table.insert(real_visual_motors, {source = real_source_motors[index], visual = visual_motor})
                end
            end
            real_visual_character.Parent = workspace.Terrain
        end
    end

    local function build_aa_rotation(mode, delta)
        if mode == "Flat" or mode == "FlatRandom" then
            local camera_yaw = select(2, workspace.CurrentCamera.CFrame:ToOrientation())
            if mode == "FlatRandom" then
                flat_angle = camera_yaw + math.rad(math.random(-120, 120))
            else
                flat_angle = camera_yaw + math.rad(180)
            end
            flat_rotation = CFrame.Angles(0, flat_angle, 0) * CFrame.Angles(math.rad(90), 0, 0)
            return flat_rotation
        end

        if mode == "nogravity" then
            local rotation_step = math.rad(aa_spin_speed * 2) * (delta or (1 / 60))
            nogravity_rotation = nogravity_rotation * CFrame.Angles(rotation_step, rotation_step, rotation_step)
            return nogravity_rotation
        end

        return CFrame.Identity
    end

    local function aa_cleanup()
        cheat.real_CFrame = nil
        fake_lag_CFrame = nil
        last_sent_server_cframe = nil
        set_aa_visual_hidden(false)
        destroy_aa_visual()
        destroy_server_pos_cham()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if hum then
            hum.AutoRotate = true
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
        pcall(function()
            ReplicatedStorage.Remotes.UpdateTilt:FireServer(0)
        end)
    end

    -- UG Resolver
    local ug_resolver_enabled = false
    local ug_resolver_depth = 30
    aa:AddToggle('ug_resolver', {Text = 'ug resolver', Default = false, Callback = function(v)
        ug_resolver_enabled = v
    end}):AddKeyPicker('ug_resolver_bind', {Default = 'X', SyncToggleState = true, Mode = 'Toggle', Text = 'ug resolver bind', NoUI = false})
    aa:AddSlider('ug_resolver_depth', {Text = 'ug resolver depth', Default = 30, Min = 5, Max = 100, Rounding = 0, Callback = function(v)
        ug_resolver_depth = v
    end})

    local function UGRESOLVER()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local originalCF = hrp.CFrame
        local originalVel = hrp.AssemblyLinearVelocity

        hrp.CFrame = originalCF * CFrame.new(0, -ug_resolver_depth, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero

        task.delay(0.10, function()
            if hrp and hrp.Parent then
                hrp.CFrame = originalCF
                hrp.AssemblyLinearVelocity = Vector3.new(originalVel.X, 0, originalVel.Z)
            end
        end)
    end

    -- Desync State
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health <= 0 then
        cheat.is_dead_or_respawning = true
    end

    LocalPlayer.CharacterAdded:Connect(function()
        cheat.is_dead_or_respawning = true
        task.delay(0.5, function()
            cheat.is_dead_or_respawning = false
        end)
    end)

    -- Restore CFrame before physics so local client acts completely normal physically
    RunService.Stepped:Connect(function()
        if (not aa_enabled and not fake_lag_enabled and not silent_aim.corner_shoot and not visualize_server_pos) or cheat.is_dead_or_respawning then return end
        if cheat.is_flying_or_tp() then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and cheat.real_CFrame then
            local linVel = hrp.AssemblyLinearVelocity
            local angVel = hrp.AssemblyAngularVelocity
            hrp.CFrame = cheat.real_CFrame
            hrp.AssemblyLinearVelocity = linVel
            hrp.AssemblyAngularVelocity = angVel
        end
    end)

    -- Restore CFrame before camera so no visual stutter
    RunService:BindToRenderStep("AADesyncRestore", 0, function()
        if (not aa_enabled and not fake_lag_enabled and not silent_aim.corner_shoot and not visualize_server_pos) or cheat.is_dead_or_respawning then return end
        if cheat.is_flying_or_tp() then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and cheat.real_CFrame then
            local linVel = hrp.AssemblyLinearVelocity
            local angVel = hrp.AssemblyAngularVelocity
            hrp.CFrame = cheat.real_CFrame
            hrp.AssemblyLinearVelocity = linVel
            hrp.AssemblyAngularVelocity = angVel
        end
    end)

    -- Keep the ghost's pose in sync every rendered frame. Its root position is
    -- still driven by LastVerifiedPos below, while Motor6D transforms carry the
    -- local running, jumping, and idle animation pose.
    cheat.utility.new_renderstepped(function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if aa_enabled then
            set_aa_visual_hidden(true)
        end
        if aa_enabled and aa_visual_character and aa_visual_character.Parent then
            for _, pair in ipairs(aa_visual_motors) do
                if pair.source.Parent and pair.visual.Parent then
                    pair.visual.Transform = pair.source.Transform
                end
            end
            if last_sent_server_cframe then
                aa_visual_character:PivotTo(last_sent_server_cframe)
            end
        end
        if aa_enabled and real_visual_character and real_visual_character.Parent then
            for _, pair in ipairs(real_visual_motors) do
                if pair.source.Parent and pair.visual.Parent then
                    pair.visual.Transform = pair.source.Transform
                end
            end
            if cheat.real_CFrame then
                real_visual_character:PivotTo(cheat.real_CFrame)
            end
        end
        if not should_show_server_pos() then
            destroy_server_pos_cham()
            return
        end
        if not server_pos_cham or not server_pos_cham.Parent then return end
        for _, pair in ipairs(server_pos_motors) do
            if pair.source and pair.source.Parent and pair.ghost and pair.ghost.Parent then
                pair.ghost.Transform = pair.source.Transform
            end
        end

        local player_data = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
        local status = player_data and player_data:FindFirstChild("Status")
        local uac = status and status:FindFirstChild("UAC")
        local verified_pos = uac and uac:GetAttribute("LastVerifiedPos")
        if last_sent_server_cframe then
            local server_cframe = last_sent_server_cframe
            if typeof(verified_pos) == "Vector3" then
                server_cframe = CFrame.new(verified_pos) * (last_sent_server_cframe - last_sent_server_cframe.Position)
            end
            server_pos_cham:PivotTo(server_cframe)
        end
    end)

    -- Heartbeat: Anti-Aim (Look Direction Spoof)
    cheat.utility.new_heartbeat(function(delta)
        if not aa_enabled and not fake_lag_enabled and not silent_aim.corner_shoot and not visualize_server_pos then
            if cheat.real_CFrame or fake_lag_CFrame or server_pos_cham then
                aa_cleanup()
            end
            return
        end
        if cheat.is_dead_or_respawning then return end
        if cheat.is_flying_or_tp() then return end
        local char = LocalPlayer.Character
        if not char then return end

        if aa_upside_down_changer and tick() - last_upside_down_change > 1 then
            last_upside_down_change = tick()
            aa_upside_down = not aa_upside_down
            if cheat.Toggles.aa_upside_down then
                cheat.Toggles.aa_upside_down:SetValue(aa_upside_down)
            end
        end

        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if hum.Health <= 0 then
            cheat.is_dead_or_respawning = true
            fake_lag_CFrame = nil
            destroy_server_pos_cham()
            return
        end

        pcall(function()
            if aa_enabled then
                hum.AutoRotate = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                if not aa_visual_character or not aa_visual_character.Parent then
                    create_aa_visual(char)
                end
                set_aa_visual_hidden(true)
            end

            -- Save real CFrame so physics and camera act normal
            cheat.real_CFrame = hrp.CFrame

            -- Fake lag logic
            if fake_lag_enabled then
                if tick() - last_fake_lag_time >= fake_lag_interval then
                    last_fake_lag_time = tick()
                    fake_lag_CFrame = hrp.CFrame
                end
            else
                fake_lag_CFrame = nil
            end

            -- Base reverse calculation
            local Angle = -math.atan2(
                workspace.CurrentCamera.CFrame.LookVector.Z,
                workspace.CurrentCamera.CFrame.LookVector.X
            ) + math.rad(-90)

            if aa_mode == "Random" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + math.rad(90) + math.rad(math.random(-120, 120))
            elseif aa_mode == "Spin" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + tick() * aa_spin_speed % 360
            elseif aa_mode == "Reverse" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + math.rad(90) -- Look backward
            elseif aa_mode == "None" then
                Angle = -math.atan2(
                    workspace.CurrentCamera.CFrame.LookVector.Z,
                    workspace.CurrentCamera.CFrame.LookVector.X
                ) + math.rad(-90)
            end

            local yaw_offset = math.rad(aa_yaw_offset)
            local rotation_cframe = CFrame.Angles(0, Angle, 0)
            if aa_mode == "Flat" or aa_mode == "FlatRandom" or aa_mode == "nogravity" then
                rotation_cframe = build_aa_rotation(aa_mode, delta)
            end
            local Angled = CFrame.new(hrp.Position) * rotation_cframe * CFrame.Angles(0, yaw_offset, 0)

            -- Target-based reverse if silent aim has a target
            if (aa_mode == "Reverse" or aa_mode == "Random") and silent_aim and silent_aim.target_part then
                local additional_offset = 0
                if aa_mode == "Random" then
                    additional_offset = math.rad(math.random(-120, 120))
                end
                Angled = CFrame.new(hrp.Position, silent_aim.target_part.Position) * CFrame.Angles(0, math.rad(180) + additional_offset + yaw_offset, 0)
            end

            -- Position Jitter (Interpolated for anti-cheat bypass)
            local pos_offset = Vector3.new(0, 0.2, 0) -- 0.2 studs above ground
            if aa_floor_clip then
                pos_offset = Vector3.new(0, -aa_floor_clip_depth, 0)
            end
            if aa_custom_offset then
                local rx = (math.random() - 0.5) * 2
                local ry = (math.random() - 0.5) * 2
                local rz = (math.random() - 0.5) * 2
                local rand_dir = Vector3.new(rx, ry, rz)
                if rand_dir.Magnitude > 0 then
                    local dist = math.random() * aa_custom_offset_radius
                    local proposed_target = rand_dir.Unit * dist

                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {char, workspace.CurrentCamera}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.IgnoreWater = true

                    local rayResult = workspace:Raycast(hrp.Position, proposed_target, rayParams)
                    if rayResult then
                        local safe_dist = math.max(0, (rayResult.Position - hrp.Position).Magnitude - 0.5)
                        pos_offset = pos_offset + (rand_dir.Unit * safe_dist)
                    else
                        pos_offset = pos_offset + proposed_target
                    end
                end
            end

            local recently_shot = silent_aim and silent_aim._exact_fire_tick and (tick() - silent_aim._exact_fire_tick < 0.05)

            -- Apply spoofed CFrame for network replication ONLY
            local spoof_pos
            if recently_shot and silent_aim and silent_aim.manipulated_origin then
                local manip_offset = silent_aim.manipulated_origin - workspace.CurrentCamera.CFrame.Position
                spoof_pos = hrp.Position + manip_offset
            elseif fake_lag_enabled and fake_lag_CFrame then
                spoof_pos = fake_lag_CFrame.Position + pos_offset
            else
                spoof_pos = hrp.Position + pos_offset
            end

            if recently_shot and silent_aim and silent_aim.manipulated_origin then
                hrp.CFrame = CFrame.new(spoof_pos) * CFrame.Angles(0, select(2, hrp.CFrame:ToOrientation()), 0)
            else
                local X, Y, Z = Angled:ToOrientation()
                local final_cframe
                if aa_enabled then
                    if aa_mode == "FlatRandom" or aa_mode == "Flat" or aa_mode == "nogravity" then
                        final_cframe = CFrame.new(spoof_pos) * (Angled - Angled.Position)
                    else
                        final_cframe = CFrame.new(spoof_pos) * CFrame.Angles(0, Y, 0)
                    end
                else
                    final_cframe = CFrame.new(spoof_pos) * CFrame.Angles(0, select(2, hrp.CFrame:ToOrientation()), 0)
                end
                hrp.CFrame = final_cframe * (aa_upside_down and CFrame.Angles(0, 0, math.rad(180)) or CFrame.new())
            end
            last_sent_server_cframe = hrp.CFrame

            if should_show_server_pos() then
                if not server_pos_cham or not server_pos_cham.Parent then
                    local oldArchivable = char.Archivable
                    char.Archivable = true
                    server_pos_cham = char:Clone()
                    char.Archivable = oldArchivable

                    if server_pos_cham then
                        server_pos_cham.Name = "FakeLagGhost_ESP_IGNORE"

                        for _, v in pairs(server_pos_cham:GetDescendants()) do
                            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Humanoid") then
                                v:Destroy()
                            end
                        end

                        apply_server_pos_forcefield(server_pos_cham)

                        -- Clone order is stable, so pair each ghost motor with
                        -- its source motor once and copy only its animated pose.
                        local source_motors, ghost_motors = {}, {}
                        for _, motor in ipairs(char:GetDescendants()) do
                            if motor:IsA("Motor6D") then
                                table.insert(source_motors, motor)
                            end
                        end
                        for _, motor in ipairs(server_pos_cham:GetDescendants()) do
                            if motor:IsA("Motor6D") then
                                table.insert(ghost_motors, motor)
                            end
                        end
                        server_pos_motors = {}
                        for i, ghost_motor in ipairs(ghost_motors) do
                            local source_motor = source_motors[i]
                            if source_motor then
                                table.insert(server_pos_motors, { source = source_motor, ghost = ghost_motor })
                            end
                        end

                        server_pos_cham.Parent = workspace.Terrain
                    end
                end

                if server_pos_cham then
                    server_pos_cham.Parent = workspace.Terrain

                    local pitch_to_send = aa_enabled and aa_pitch_value or 0
                    if aa_enabled and (aa_mode == "FlatRandom" or aa_mode == "Flat") then
                        pitch_to_send = 250
                    end
                    local pitch_angle
                    if aa_enabled and (aa_mode == "FlatRandom" or aa_mode == "Flat") then
                        pitch_angle = CFrame.new()
                    else
                        pitch_angle = CFrame.Angles(math.rad(pitch_to_send / 2.77), 0, 0)
                    end

                    -- LastVerifiedPos is the position replicated by the game's UAC state.
                    -- It is a closer view of the server's accepted position than the local HRP,
                    -- which is restored immediately after the spoof is sent.
                    local player_data = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
                    local status = player_data and player_data:FindFirstChild("Status")
                    local uac = status and status:FindFirstChild("UAC")
                    local verified_pos = uac and uac:GetAttribute("LastVerifiedPos")
                    local orientation = last_sent_server_cframe or hrp.CFrame
                    local server_cframe_for_visuals
                    if typeof(verified_pos) == "Vector3" then
                        server_cframe_for_visuals = CFrame.new(verified_pos) * (orientation - orientation.Position)
                    else
                        -- Some sessions do not replicate UAC state locally. In that case,
                        -- show the last CFrame sent by this script rather than attaching to HRP.
                        server_cframe_for_visuals = last_sent_server_cframe or hrp.CFrame
                    end
                    server_pos_cham:PivotTo(server_cframe_for_visuals * pitch_angle)
                    apply_server_pos_forcefield(server_pos_cham)
                end
            else
                destroy_server_pos_cham()
            end

            -- Removed block cham logic

            -- Fire original look direction tilt
            local pitch_to_send = aa_enabled and aa_pitch_value or 0
            if aa_enabled and (aa_mode == "FlatRandom" or aa_mode == "Flat") then
                pitch_to_send = 250
            end
            ReplicatedStorage.Remotes.UpdateTilt:FireServer(pitch_to_send)
        end)
    end)

    -- UG Resolver loop (triggered only when enabled and shooting)
    task.spawn(function()
        while true do
            if ug_resolver_enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                UGRESOLVER()
                task.wait(0.12)
            else
                task.wait(0.05)
            end
        end
    end)
end

-- ─── COMBAT EXTRAS ───────────────────────────────────────────────────────────
do
    local combat_extras = ui.tabs.combat:AddLeftGroupbox('tp kill')

    local tpkill_enabled = false
    local tpkill_height = 200
    local tpkill_start_time = 0
    local tpkill_last_used = 0
    local tpkill_original_cf = nil
    local current_tp_target = nil
    local fake_platform = nil

    local tpkill_color1 = Color3.fromRGB(128, 0, 128) -- Purple
    local tpkill_color2 = Color3.fromRGB(0, 0, 139)   -- Dark Blue

    combat_extras:AddToggle('tpkill_enabled', {Text = 'tp kill', Default = false, Callback = function(v)
        tpkill_enabled = v
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if v then
            -- Cooldown check
            if tick() - tpkill_last_used < 5 then
                cheat.Toggles.tpkill_enabled:SetValue(false)
                cheat.Library:Notify("TP Kill", "On cooldown!")
                return
            end

            -- Use silent aim target if available AT ACTIVATION
            local target_part = silent_aim and silent_aim.target_part
            if target_part then
                current_tp_target = target_part
                tpkill_original_cf = hrp.CFrame
                tpkill_start_time = tick()

                -- Create invisible fake platform for the client to stand on so the server thinks we are grounded
                fake_platform = Instance.new("Part")
                fake_platform.Size = Vector3.new(10, 1, 10)
                fake_platform.Anchored = true
                fake_platform.CanCollide = true
                fake_platform.Transparency = 1
                fake_platform.Name = "TPKillPlatform"
                fake_platform.Parent = workspace

                -- Teleport once, preserving our current rotation so the camera doesn't glitch
                local new_pos = current_tp_target.Position + Vector3.new(0, tpkill_height, 0)
                hrp.CFrame = CFrame.new(new_pos) * hrp.CFrame.Rotation

                cheat.Library:Notify("TP Kill", "Teleported above targeted enemy")
            else
                -- No target found, disable
                current_tp_target = nil
                cheat.Toggles.tpkill_enabled:SetValue(false)
                cheat.Library:Notify("TP Kill", "No silent aim target found in FOV")
            end
        else
            -- Only start the cooldown if we actually teleported (prevents resetting the timer if we spam the bind)
            if tpkill_original_cf then
                tpkill_last_used = tick()
            end

            -- Restore original position
            if tpkill_original_cf and hrp then
                -- Teleport 2 studs up to prevent clipping into the floor
                hrp.CFrame = tpkill_original_cf + Vector3.new(0, 2, 0)
                if cheat.real_CFrame then cheat.real_CFrame = hrp.CFrame end
                tpkill_original_cf = nil
                current_tp_target = nil
                cheat.Library:Notify("TP Kill", "Returned to original position")

                -- Destroy fake platform
                if fake_platform then
                    fake_platform:Destroy()
                    fake_platform = nil
                end

                -- Force Landed state to completely prevent any pending fall damage
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                end
            end
        end
    end}):AddKeyPicker('tpkill_key', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'tp kill bind', NoUI = false})
    :AddColorPicker('tpkill_color1', {Default = tpkill_color1, Title = 'active bar color', Transparency = 0, Callback = function(v) tpkill_color1 = v end})
    :AddColorPicker('tpkill_color2', {Default = tpkill_color2, Title = 'recharge bar color', Transparency = 0, Callback = function(v) tpkill_color2 = v end})

    combat_extras:AddSlider('tpkill_height', {Text = 'height offset', Default = 200, Min = 5, Max = 300, Rounding = 0, Callback = function(v)
        tpkill_height = v

        -- Dynamically adjust height if we change the slider while active
        if tpkill_enabled then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and current_tp_target and current_tp_target.Parent then
                local new_pos = current_tp_target.Position + Vector3.new(0, tpkill_height, 0)
                hrp.CFrame = CFrame.new(new_pos) * hrp.CFrame.Rotation
            end
        end
    end})

    local tpkill_glow_size = 5
    local tpkill_glow_color = tipanel_settings.glowcolor
    combat_extras:AddSlider('tpkill_glow_size', {Text = 'neon glow size', Default = 5, Min = 1, Max = 15, Rounding = 0, Callback = function(v)
        tpkill_glow_size = v
    end})

    local tpkill_show_bar = true
    combat_extras:AddToggle('tpkill_show_bar', {Text = 'show charge bar', Default = true, Callback = function(v)
        tpkill_show_bar = v
    end}):AddColorPicker('tpkill_glow_color', {Default = tpkill_glow_color, Title = 'neon glow color', Transparency = 0, Callback = function(v)
        tpkill_glow_color = v
    end})

    local tpkill_autolook = false
    combat_extras:AddToggle('tpkill_autolook', {Text = 'auto look at target', Default = false, Callback = function(v)
        tpkill_autolook = v
    end})

    local tpkill_autotbot = false
    combat_extras:AddToggle('tpkill_autotbot', {Text = 'auto triggerbot', Default = false, Callback = function(v)
        tpkill_autotbot = v
    end})

    -- Auto Look processing
    RunService:BindToRenderStep("TPKillAutoLook", 201, function()
        if tpkill_enabled and current_tp_target and current_tp_target.Parent then
            if tpkill_autolook then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, current_tp_target.Position)
            end
        end
    end)

    -- Glowing Edges using Drawing API
    local tpkill_bar_glow = {}
    for i = 1, 6 do
        tpkill_bar_glow[i] = Drawing.new("Square")
        tpkill_bar_glow[i].Filled = false
        tpkill_bar_glow[i].Color = tipanel_settings.glowcolor
        tpkill_bar_glow[i].Thickness = i
        tpkill_bar_glow[i].Transparency = 0.2 - (i * 0.03)
        tpkill_bar_glow[i].ZIndex = 0
        tpkill_bar_glow[i].Visible = false
    end

    local tpkill_bar_bg = Drawing.new("Square")
    tpkill_bar_bg.Thickness = 1
    tpkill_bar_bg.Filled = false
    tpkill_bar_bg.Color = Color3.new(0, 0, 0)
    tpkill_bar_bg.ZIndex = 2
    tpkill_bar_bg.Visible = false

    -- Gradient Bar using ScreenGui
    local tpk_gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    tpk_gui.Name = "TPKillBarGUI"
    tpk_gui.DisplayOrder = 1000
    tpk_gui.IgnoreGuiInset = true

    local tpk_clip = Instance.new("Frame", tpk_gui)
    tpk_clip.ClipsDescendants = true
    tpk_clip.BackgroundTransparency = 1
    tpk_clip.BorderSizePixel = 0
    tpk_clip.Visible = false

    local tpk_fill = Instance.new("Frame", tpk_clip)
    tpk_fill.BorderSizePixel = 0
    tpk_fill.BackgroundColor3 = Color3.new(1,1,1)

    local tpk_grad = Instance.new("UIGradient", tpk_fill)
    tpk_grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, tpkill_color2),
        ColorSequenceKeypoint.new(1, tpkill_color1)
    })

    -- Heartbeat for TP Kill logic (Fly Bypass & UI)
    cheat.utility.new_heartbeat(function(delta)
        local now = tick()
        local is_active = tpkill_enabled
        local time_since_used = now - tpkill_last_used

        -- Handle Bar Rendering
        local show_bar = false
        local progress = 0
        local bar_color = tpkill_color1

        if is_active then
            show_bar = true
            progress = math.clamp(1 - ((now - tpkill_start_time) / 5), 0, 1)
            bar_color = tpkill_color1
        else
            show_bar = true
            progress = math.clamp(time_since_used / 5, 0, 1)
            bar_color = tpkill_color2
        end

        if show_bar and tpkill_show_bar then
            local viewport = Camera.ViewportSize
            local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
            local bar_width = 100
            local bar_height = 6
            local bar_pos = center + Vector2.new(-bar_width / 2, 20)

            for i = 1, 6 do
                local th = (i / 6) * tpkill_glow_size
                local tr = 0.3 - (i * 0.04)
                tpkill_bar_glow[i].Visible = true
                tpkill_bar_glow[i].Color = tpkill_glow_color
                tpkill_bar_glow[i].Thickness = math.max(1, th)
                tpkill_bar_glow[i].Transparency = tr
                tpkill_bar_glow[i].Size = Vector2.new(bar_width, bar_height) + Vector2.new(th*2, th*2)
                tpkill_bar_glow[i].Position = bar_pos - Vector2.new(th, th)
            end

            tpkill_bar_bg.Visible = true
            tpkill_bar_bg.Size = Vector2.new(bar_width, bar_height)
            tpkill_bar_bg.Position = bar_pos

            tpk_clip.Visible = true
            tpk_clip.Size = UDim2.new(0, bar_width * progress, 0, bar_height)
            tpk_clip.Position = UDim2.new(0, bar_pos.X, 0, bar_pos.Y)

            tpk_fill.Size = UDim2.new(0, bar_width, 0, bar_height)

            tpk_grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, tpkill_color2),
                ColorSequenceKeypoint.new(1, tpkill_color1)
            })
        else
            for i = 1, 6 do tpkill_bar_glow[i].Visible = false end
            tpkill_bar_bg.Visible = false
            tpk_clip.Visible = false
        end

        if not tpkill_enabled then return end

        -- Automatic timeout check (5 seconds)
        if now - tpkill_start_time >= 5 then
            cheat.Toggles.tpkill_enabled:SetValue(false)
            return
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if current_tp_target and current_tp_target.Parent then
            -- Continuously force position to fight anti-cheat rubberbanding, but allow rotation so they can aim
            local frozen_pos = current_tp_target.Position + Vector3.new(0, tpkill_height, 0)
            hrp.CFrame = CFrame.new(frozen_pos) * hrp.CFrame.Rotation

            -- Track platform exactly below the player's feet (about 3.5 studs below HRP)
            if fake_platform then
                fake_platform.CFrame = CFrame.new(frozen_pos - Vector3.new(0, 3.5, 0))
            end
        end
    end)
end

do
    local peek_kill_box = ui.tabs.combat:AddRightGroupbox('peek kill')
    
    local peekkill_up_vel = 50
    local peekkill_side_vel = 100
    
    peek_kill_box:AddSlider('peekkill_up_vel', {Text = 'up velocity', Default = 50, Min = 10, Max = 150, Rounding = 0, Callback = function(v)
        peekkill_up_vel = v
    end})
    
    peek_kill_box:AddSlider('peekkill_side_vel', {Text = 'side velocity', Default = 100, Min = 10, Max = 200, Rounding = 0, Callback = function(v)
        peekkill_side_vel = v
    end})
    
    local function do_peek_kill(direction_vector)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lookVector = workspace.CurrentCamera.CFrame.LookVector
            local rightVector = workspace.CurrentCamera.CFrame.RightVector
            
            -- Flatten the vectors so you don't launch into the ground or sky unnecessarily if looking up/down
            local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            
            local final_vel = Vector3.new(0, peekkill_up_vel, 0)
            
            if direction_vector.X ~= 0 then
                final_vel = final_vel + (flatRight * direction_vector.X * peekkill_side_vel)
            end
            if direction_vector.Z ~= 0 then
                final_vel = final_vel + (flatLook * direction_vector.Z * peekkill_side_vel)
            end
            
            hrp.AssemblyLinearVelocity = final_vel
        end
    end
    
    local pk_left = false
    local pk_right = false
    local pk_original_cf = nil
    local pk_return = true
    
    peek_kill_box:AddToggle('peekkill_return', {Text = 'return to original pos', Default = true, Callback = function(v)
        pk_return = v
    end})

    local function handle_pk_state(is_active)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if is_active then
            if not pk_original_cf then
                pk_original_cf = hrp.CFrame
            end
        else
            -- if neither is held, we finished peeking
            if not (pk_left or pk_right) and pk_original_cf then
                if pk_return then
                    hrp.CFrame = pk_original_cf + Vector3.new(0, 1, 0)
                    if cheat.real_CFrame then cheat.real_CFrame = hrp.CFrame end
                    
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Landed)
                    end
                end
                pk_original_cf = nil
            end
        end
    end

    peek_kill_box:AddToggle('peekkill_left_t', {Text = 'peek left', Default = false, Callback = function(v)
        pk_left = v
        handle_pk_state(v)
    end}):AddKeyPicker('peekkill_left', {Default = 'None', Mode = 'Hold', SyncToggleState = true, Text = 'peek left bind', NoUI = false})
    
    peek_kill_box:AddToggle('peekkill_right_t', {Text = 'peek right', Default = false, Callback = function(v)
        pk_right = v
        handle_pk_state(v)
    end}):AddKeyPicker('peekkill_right', {Default = 'None', Mode = 'Hold', SyncToggleState = true, Text = 'peek right bind', NoUI = false})

    local last_peek_time = 0
    cheat.utility.new_heartbeat(function()
        if not (pk_left or pk_right) then return end
        
        local now = tick()
        if now - last_peek_time < 0.5 then return end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            local rightVector = workspace.CurrentCamera.CFrame.RightVector
            
            local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z)
            if flatRight.Magnitude > 0.001 then flatRight = flatRight.Unit else flatRight = Vector3.new(1, 0, 0) end
            
            local final_vel = Vector3.new(0, peekkill_up_vel, 0)
            local has_dir = false
            
            if pk_left then
                final_vel = final_vel + (flatRight * -1 * peekkill_side_vel)
                has_dir = true
            end
            if pk_right then
                final_vel = final_vel + (flatRight * 1 * peekkill_side_vel)
                has_dir = true
            end
            
            if has_dir then
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
                hrp.AssemblyLinearVelocity = final_vel
                last_peek_time = now
            end
        end
    end)
end

-- ─── MISC EXTRAS: Bunny Hop + No Fall Damage (misc tab) ──────────────────────
do
    local misctab_mv = ui.tabs.misc:AddLeftGroupbox('movement')

    -- Bunny Hop
    local bunnyhop_enabled = false
    local bunnyhop_active = false
    local last_jump_time = 0
    local bunnyhop_velocity = 20
    misctab_mv:AddToggle('bunnyhop_enabled', {Text = 'bunny hop', Default = false, Callback = function(v)
        bunnyhop_enabled = v
    end}):AddKeyPicker('bunnyhop_key', {Default = 'None', Mode = 'Hold', Text = 'bunny hop bind', NoUI = false, Callback = function(v)
        bunnyhop_active = v
    end})
    misctab_mv:AddSlider('bunnyhop_velocity', {Text = 'jump velocity', Default = 20, Min = 1, Max = 100, Rounding = 0, Callback = function(v)
        bunnyhop_velocity = v
    end})

    -- No Fall Damage
    local no_fall = false
    misctab_mv:AddToggle('no_fall', {Text = 'no fall damage', Default = false, Callback = function(v)
        no_fall = v
    end})

    -- Bunny hop heartbeat
    cheat.utility.new_heartbeat(function(delta)
        if not (bunnyhop_enabled and bunnyhop_active) then return end
        local now = tick()
        if now - last_jump_time < 0.2 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = hrp.Velocity + Vector3.new(0, bunnyhop_velocity, 0)
                last_jump_time = now
            end
        end
    end)

    -- No fall damage heartbeat
    cheat.utility.new_heartbeat(function(delta)
        if not no_fall then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                if hrp.AssemblyLinearVelocity.Y < -12.5 then
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                end
            end
        end
    end)
end

-- ─── MOD DETECTOR (in misc tab) ──────────────────────────────────────────────
do
    local misctab2 = ui.tabs.misc:AddLeftGroupbox('detector')
    local mod_detector = false
    local cheat_detector = false
    local mod_warnings = {}
    local mod_alerted = {}
    local cheater_alerted = {}

    misctab2:AddToggle('mod_detector', {Text = 'mod detector', Default = false, Callback = function(v)
        mod_detector = v
        if v then cheat.Library:Notify('Mod Detector', 'Mod Detector enabled') end
    end})
    misctab2:AddToggle('cheat_detector', {Text = 'cheater detector (requires mod detector)', Default = false, Callback = function(v)
        cheat_detector = v
        if v then cheat.Library:Notify('Cheater Detector', 'Cheater Detector enabled') end
    end})

    local function check_cheater(plr)
        if plr == LocalPlayer then return end
        if not cheat_detector then return end
        if cheater_alerted[plr.Name] then return end
        local rs_plr = ReplicatedStorage:FindFirstChild("Players") and
            ReplicatedStorage.Players:FindFirstChild(plr.Name)
        if not rs_plr then return end
        local status = rs_plr:FindFirstChild("Status")
        if not status then return end
        local journey = status:FindFirstChild("Journey")
        if not journey then return end
        local wipe = journey:FindFirstChild("WipeStatistics")
        if not wipe then return end
        local deaths = wipe:GetAttribute("Deaths") or 0
        if deaths == 0 then deaths = 1 end
        local kills = wipe:GetAttribute("Kills") or 0
        if kills == 0 then kills = 1 end
        local kdr = math.floor(kills / deaths * 10) / 10
        if kills >= 15 and kdr >= 5 then
            cheater_alerted[plr.Name] = true
            cheat.Library:Notify('Cheater Detector (KDR: '..kdr..')', plr.Name..' suspected cheater!')
        end
        local report = (ReplicatedStorage:FindFirstChild("ReportList"))
        if report then
            local entry = report:FindFirstChild("MostWanted") and report.MostWanted:FindFirstChild(plr.Name)
                or report:FindFirstChild("Recent") and report.Recent:FindFirstChild(plr.Name)
            if entry then
                local flags = entry:GetAttribute("TotalFlags") or 0
                local hsr = entry:GetAttribute("HSR") or 0
                local age = entry:GetAttribute("Age") or 0
                if kills >= 15 and hsr >= 95 then
                    cheater_alerted[plr.Name] = true
                    cheat.Library:Notify('Cheater Detector (B)', plr.Name..' suspected cheater!')
                end
                if flags >= 75 and age <= 50 then
                    cheater_alerted[plr.Name] = true
                    cheat.Library:Notify('Cheater Detector (C)', plr.Name..' suspected cheater!')
                end
            end
        end
    end

    local function run_mod_detector()
        if not mod_detector then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                check_cheater(plr)
                if plr.Character then
                    -- Method A: high premium level = likely mod/admin
                    if not mod_warnings[plr.Name] then mod_warnings[plr.Name] = 0 end
                    if mod_warnings[plr.Name] < 5 and not mod_alerted[plr.Name] then
                        local rs_plr = ReplicatedStorage:FindFirstChild("Players") and
                            ReplicatedStorage.Players:FindFirstChild(plr.Name)
                        if rs_plr then
                            local status = rs_plr:FindFirstChild("Status")
                            if status and status:FindFirstChild("GameplayVariables") and
                                status.GameplayVariables:GetAttribute("PremiumLevel") and
                                status.GameplayVariables:GetAttribute("PremiumLevel") >= 4 then
                                mod_warnings[plr.Name] = mod_warnings[plr.Name] + 1
                                cheat.Library:Notify('Mod Detector (A)', 'Mod detected: '..plr.Name)
                            end
                        end
                        -- Method B: invisible body parts
                        for _, part in pairs(plr.Character:GetChildren()) do
                            local bodyParts = {Head=true,LeftFoot=true,LeftHand=true,LeftLowerArm=true,
                                LeftLowerLeg=true,LeftUpperArm=true,LeftUpperLeg=true,LowerTorso=true,
                                RightFoot=true,RightHand=true,RightLowerArm=true,RightUpperArm=true,
                                RightUpperLeg=true,UpperTorso=true}
                            if bodyParts[part.Name] and part:IsA("BasePart") and part.Transparency >= 1 then
                                mod_warnings[plr.Name] = mod_warnings[plr.Name] + 1
                                cheat.Library:Notify('Mod Detector (B)', 'Mod detected (invis): '..plr.Name)
                                mod_alerted[plr.Name] = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- Run mod detector every 3 seconds
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(run_mod_detector)
        end
    end)
end

-- ─── FREECAM ─────────────────────────────────────────────────────────────
do
    local freecam_tab = ui.box.world:AddTab("freecam")
    cheat.freecam_enabled = false
    local freecam_show_distance = true
    local freecam_speed = 50
    local freecam_cf = nil
    local freecam_part = nil
    local freecam_ghost = nil
    local freecam_ghost_label = nil
    local pitch, yaw = 0, 0

    freecam_tab:AddToggle('freecam_show_distance', {Text = 'show distance esp', Default = true, Callback = function(v)
        freecam_show_distance = v
    end})

    freecam_tab:AddToggle('freecam_vis_original', {Text = 'Vis-Check From Real Character', Default = false})

    freecam_tab:AddToggle('freecam_enabled', {Text = 'freecam', Default = false, Callback = function(v)
        cheat.freecam_enabled = v
        if v then
            freecam_cf = workspace.CurrentCamera.CFrame
            pitch, yaw = freecam_cf:ToOrientation()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

            if not freecam_part then
                freecam_part = Instance.new("Part")
                freecam_part.Anchored = true
                freecam_part.CanCollide = false
                freecam_part.Transparency = 1
                freecam_part.Name = "FreecamFocus"
                freecam_part.Parent = workspace.Terrain
            end
            pcall(function() LocalPlayer.ReplicationFocus = freecam_part end)

            local char = LocalPlayer.Character
            if char then
                local oldArchivable = char.Archivable
                char.Archivable = true
                freecam_ghost = char:Clone()
                char.Archivable = oldArchivable

                if freecam_ghost then
                    freecam_ghost.Name = "FreecamGhost_ESP_IGNORE"

                    local hl = Instance.new("Highlight")
                    local es_enemy = cheat.EspLibrary.settings.enemy
                    hl.FillColor = es_enemy.chams_fill_color[1]
                    hl.OutlineColor = es_enemy.chamsoutline_color[1]
                    hl.FillTransparency = es_enemy.chams_fill_color[2]
                    hl.OutlineTransparency = es_enemy.chamsoutline_color[2]
                    hl.DepthMode = es_enemy.chams_visible_only and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = freecam_ghost

                    for _, desc in pairs(freecam_ghost:GetDescendants()) do
                        if desc:IsA("BasePart") then
                            desc.Material = Enum.Material[es_enemy.chams_material or "Neon"]
                            desc.Color = es_enemy.chams_fill_color[1]
                            desc.Transparency = 0
                            local sa = desc:FindFirstChildOfClass("SurfaceAppearance")
                            if sa then sa:Destroy() end

                            desc.CanCollide = false
                            desc.CanTouch = false
                            desc.CanQuery = false
                            desc.Massless = true
                            desc.Anchored = true
                        elseif desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("Clothing") or desc:IsA("Accessory") or desc:IsA("Script") or desc:IsA("LocalScript") then
                            desc:Destroy()
                        end
                    end

                    local humanoid = freecam_ghost:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:Destroy() end

                    local hrp = freecam_ghost:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local text = Drawing.new("Text")
                        text.Center = true
                        text.Font = cheat.EspLibrary.main_settings.textFont
                        text.Color = cheat.EspLibrary.settings.corpse.color or Color3.fromRGB(255, 255, 255)
                        text.Outline = true
                        text.Size = cheat.EspLibrary.main_settings.textSize
                        text.Visible = false
                        freecam_ghost_label = text
                    end

                    freecam_ghost.Parent = workspace.Terrain
                    local real_hrp = char:FindFirstChild("HumanoidRootPart")
                    if real_hrp then
                        freecam_ghost:PivotTo(real_hrp.CFrame)
                    end
                end
            end
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            pcall(function() LocalPlayer.ReplicationFocus = nil end)
            if freecam_part then freecam_part:Destroy(); freecam_part = nil end
            if freecam_ghost_label then freecam_ghost_label:Remove(); freecam_ghost_label = nil end
            if freecam_ghost then freecam_ghost:Destroy(); freecam_ghost = nil end
        end
    end}):AddKeyPicker('freecam_bind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'freecam', NoUI = false})

    freecam_tab:AddSlider('freecam_speed', {Text = 'freecam speed', Default = 50, Min = 10, Max = 575, Rounding = 0, Callback = function(v)
        freecam_speed = v
    end})

    local last_stream_req = 0
    local last_pin_pos = nil
    local pin_pause_until = 0
    RunService.RenderStepped:Connect(function(dt)
        if cheat.freecam_enabled then
            local cam = workspace.CurrentCamera

            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                local delta = UserInputService:GetMouseDelta()
                pitch = math.clamp(pitch - delta.Y * 0.005, -math.pi/2 + 0.01, math.pi/2 - 0.01)
                yaw = yaw - delta.X * 0.005
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end

            local moveVector = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector + Vector3.new(0, -1, 0) end

            freecam_cf = CFrame.new(freecam_cf.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)

            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit
                freecam_cf = freecam_cf + (freecam_cf.RightVector * moveVector.X + freecam_cf.UpVector * moveVector.Y + freecam_cf.LookVector * moveVector.Z) * (freecam_speed * dt)
            end

            cam.CFrame = freecam_cf
            if freecam_part then
                freecam_part.CFrame = freecam_cf
                pcall(function() LocalPlayer.ReplicationFocus = freecam_part end)
                if tick() - last_stream_req > 1 then
                    last_stream_req = tick()
                    task.spawn(function()
                        pcall(function() LocalPlayer:RequestStreamAroundAsync(freecam_cf.Position) end)
                    end)
                end
            end

            if freecam_ghost_label then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and freecam_show_distance then
                    local dist = math.floor((hrp.Position - freecam_cf.Position).Magnitude)
                    freecam_ghost_label.Text = "[" .. dist .. "m]"
                    freecam_ghost_label.Font = cheat.EspLibrary.main_settings.textFont
                    freecam_ghost_label.Size = cheat.EspLibrary.main_settings.textSize

                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        freecam_ghost_label.Position = Vector2.new(pos.X, pos.Y)
                        freecam_ghost_label.Visible = true
                    else
                        freecam_ghost_label.Visible = false
                    end
                else
                    freecam_ghost_label.Visible = false
                end
            end

            -- Pin the character in place ONLY while the user is actually giving
            -- freecam movement input. Forcing velocity/Move every single frame
            -- fights server-side teleports (the character gets dragged back to its
            -- old spot), so with no input we leave the character alone entirely.
            local char = LocalPlayer.Character
            if char and moveVector.Magnitude > 0 then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Teleport detection: a large position jump while pinning means
                    -- the server moved us - pause pinning briefly so it can complete.
                    local now = os.clock()
                    if last_pin_pos and (root.Position - last_pin_pos).Magnitude > 10 then
                        pin_pause_until = now + 1
                    end
                    last_pin_pos = root.Position
                    if now >= pin_pause_until then
                        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:Move(Vector3.zero, false)
                        end
                    end
                end
            end
        end
    end)
end

cheat.ThemeManager:SetOptionsTEMP(cheat.Options, cheat.Toggles)
cheat.SaveManager:SetOptionsTEMP(cheat.Options, cheat.Toggles)
cheat.ThemeManager:SetLibrary(cheat.Library)
cheat.SaveManager:SetLibrary(cheat.Library)
cheat.SaveManager:IgnoreThemeSettings()
cheat.ThemeManager:SetFolder('wallhackrbx')
cheat.SaveManager:SetFolder('wallhackrbx')
cheat.SaveManager:BuildConfigSection(ui.tabs.config)
cheat.ThemeManager:ApplyToGroupbox(ui.box.themeconfig)

local lol_theme = {
    Name = "lol",
    ["Window.BgColor"] = Color3.fromRGB(8, 8, 8),
    ["Window.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Window.TitleColor"] = Color3.fromRGB(187, 187, 187),
    ["Tab.BgColor"] = Color3.fromRGB(8, 8, 8),
    ["Tab.TextColor"] = Color3.fromRGB(187, 187, 187),
    ["Tab.ActiveTextColor"] = Color3.fromRGB(255, 255, 255),
    ["Groupbox.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["Groupbox.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Groupbox.TitleColor"] = Color3.fromRGB(187, 187, 187),
    ["Button.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["Button.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Button.TextColor"] = Color3.fromRGB(187, 187, 187),
    ["Toggle.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["Toggle.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Toggle.TextColor"] = Color3.fromRGB(187, 187, 187),
    ["Toggle.ActiveColor"] = Color3.fromRGB(255, 255, 255),
    ["Slider.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["Slider.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Slider.ThumbColor"] = Color3.fromRGB(255, 255, 255),
    ["Slider.TextColor"] = Color3.fromRGB(187, 187, 187),
    ["Dropdown.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["Dropdown.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Dropdown.TextColor"] = Color3.fromRGB(187, 187, 187),
    ["ColorPicker.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["ColorPicker.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["KeyPicker.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["KeyPicker.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["KeyPicker.TextColor"] = Color3.fromRGB(187, 187, 187),
    ["Primary"] = Color3.fromRGB(255, 255, 255),
    ["Accent"] = Color3.fromRGB(255, 255, 255),
    ["Text"] = Color3.fromRGB(187, 187, 187),
    ["BgColor"] = Color3.fromRGB(8, 8, 8),
    ["BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Tooltip.BgColor"] = Color3.fromRGB(6, 6, 6),
    ["Tooltip.BorderColor"] = Color3.fromRGB(39, 39, 39),
    ["Tooltip.TextColor"] = Color3.fromRGB(187, 187, 187),
}
if cheat.ThemeManager.schemes then
    cheat.ThemeManager.schemes["lol"] = lol_theme
end
if cheat.ThemeManager.ApplyScheme then
    cheat.ThemeManager:ApplyScheme("lol")
elseif cheat.ThemeManager.Load then
    cheat.ThemeManager:Load("lol")
end

if cheat.SaveManager and cheat.SaveManager.LoadAutoloadConfig then
    local ok, err = pcall(function() cheat.SaveManager:LoadAutoloadConfig() end)
    if not ok then print("[wh] LoadAutoloadConfig error: " .. tostring(err)) end
end
cheat.EspLibrary.load()
task.spawn(function()
    for _, v in getconnections(game.ReplicatedStorage.Remotes.NotificationMessage.OnClientEvent) do
        if not v.Function then return end
        for i=1,5 do task.spawn(function()v.Function("Welcome to wallhack.rbx!", 5, i)end) task.wait(1) end
    end
end)
