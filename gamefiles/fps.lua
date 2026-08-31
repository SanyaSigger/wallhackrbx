local t = {}
fps_mt = { __index = t }
local Lighting = game.Lighting
local CurrentCamera = game.Workspace.CurrentCamera
game:GetService("PhysicsService")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
game:GetService("CollectionService")
local _ = UserSettings().GameSettings
local GuiService = game:GetService("GuiService")
local HapticService = game:GetService("HapticService")
local RangedWeapons = game.ReplicatedStorage.RangedWeapons
local ViewModels = game.ReplicatedStorage:WaitForChild("ViewModels")
local ViewModelClothing = game.ReplicatedStorage:WaitForChild("ViewModelClothing")
game.ReplicatedStorage:WaitForChild("Skins")
local v_u_1 = game.ReplicatedFirst.ServerInfo:GetAttribute("GameMode") == "Lobby"
local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local Reload = Remotes:WaitForChild("Reload")
local UpdateViewmodel = Remotes:WaitForChild("UpdateViewmodel")
local ToggleAttachment = game.ReplicatedStorage.Remotes.ToggleAttachment
Remotes:WaitForChild("SoundServiceEvent")
local Consume = Remotes:WaitForChild("Consume")
local ServerProjectile = game.ReplicatedStorage.Remotes.ServerProjectile
local ChangeFireMode = game.ReplicatedStorage.Remotes.ChangeFireMode
local VehicleInteractions = game.ReplicatedStorage.Remotes.VehicleInteractions
local UpdateLeaning = game.ReplicatedStorage.Remotes.UpdateLeaning
local UpdateCrouch = game.ReplicatedStorage.Remotes.UpdateCrouch
local ReviveSystem = game.ReplicatedStorage.Remotes.ReviveSystem
local Modules = game.ReplicatedStorage:WaitForChild("Modules")
local Input = require(game.ReplicatedStorage.Modules.Input)
local SoundHandler = require(game.SoundService.SoundSystem.Modules.SoundHandler)
local v_u_2 = require((Modules:WaitForChild("SpringV2")))
local v_u_3 = require((Modules:WaitForChild("UniversalTables")))
local v_u_4 = require((Modules:WaitForChild("NightVisionSystem")))
local v_u_5 = require((Modules:WaitForChild("ThermalVisionSystem")))
local v_u_6 = require((Modules:WaitForChild("CameraSystem")))
local v_u_7 = require((Modules:WaitForChild("FunctionLibraryExtension")))
local v_u_8 = require((script:WaitForChild("Bullet")))
local v_u_9 = require((script:WaitForChild("Melee")))
local v_u_10 = require((script:WaitForChild("Keys")))
local v_u_11 = RaycastParams.new()
v_u_11.FilterType = Enum.RaycastFilterType.Exclude
v_u_11.CollisionGroup = "WeaponRay"
v_u_11.IgnoreWater = true
InvisibleDescentants = {
	PointLight = true,
	RopeConstraint = true,
	SurfaceGui = true,
	SpotLight = true,
	ParticleEmitter = true
}
local function viewModelClothes(p12, p13)
	--[[ line: 101 | upvalues: (copy) ViewModelClothing, (copy) v_u_7]]
	local v14 = p13:GetChildren()
	for v15 = 1, #v14 do
		if v14[v15].ClassName == "Model" and v14[v15]:GetAttribute("ItemType") then
			v14[v15]:Destroy()
		end
	end
	local v_u_16 = p12.rs_Player.Inventory:GetChildren()
	for v_u_17 = 1, #v_u_16 do
		if v_u_16[v_u_17].Value:FindFirstChild("ItemProperties") and ViewModelClothing:FindFirstChild(v_u_16[v_u_17].Name) then
			local v_u_18 = ViewModelClothing:FindFirstChild(v_u_16[v_u_17].Name):Clone()
			local v19 = v_u_18:GetChildren()
			for v20 = 1, #v19 do
				if v19[v20]:IsA("BasePart") and v19[v20]:GetAttribute("WeldTo") then
					local Weld = Instance.new("Weld")
					Weld.Part0 = p13:FindFirstChild((v19[v20]:GetAttribute("WeldTo")))
					Weld.Part1 = v19[v20]
					Weld.C0 = v19[v20]:GetAttribute("offset")
					Weld.Parent = Weld.Part1
				end
			end
			if v_u_16[v_u_17]:GetAttribute("Skin") and v_u_16[v_u_17]:GetAttribute("Skin") ~= "" then
				v_u_7:UpdateSkin(v_u_16[v_u_17], v_u_18)
			end
			if v_u_16[v_u_17].Value.ItemProperties:GetAttribute("Skin") then
				p12.Connections["SkinConnection" .. v_u_16[v_u_17].Name] = v_u_16[v_u_17]:GetAttributeChangedSignal("Skin"):Connect(function()
					--[[ line: 131 | upvalues: (ref) v_u_7, (copy) v_u_16, (copy) v_u_17, (copy) v_u_18]]
					v_u_7:UpdateSkin(v_u_16[v_u_17], v_u_18)
				end)
			end
			v_u_18.Parent = p13
		end
	end
end
local function viewModel(p_u_21)
	--[[ line: 142 | upvalues: (copy) ViewModels, (copy) v_u_7, (copy) viewModelClothes]]
	if not game.ReplicatedStorage.ItemsListModels:FindFirstChild(p_u_21.weapon.Name) then
		return nil
	end
	local v_u_22
	if ViewModels:FindFirstChild(p_u_21.weapon.Name) then
		v_u_22 = ViewModels:FindFirstChild(p_u_21.weapon.Name):Clone()
	else
		v_u_22 = ViewModels.ViewModelR15:Clone()
		local v23 = game.ReplicatedStorage.ItemsListModels:FindFirstChild(p_u_21.weapon.Name):Clone()
		local ObjectValue = Instance.new("ObjectValue")
		ObjectValue.Name = "SelfRef"
		ObjectValue.Value = p_u_21.weapon
		ObjectValue.Parent = v23
		v23.Name = "Item"
		v23.PrimaryPart.Sounds:Destroy()
		v23.Parent = v_u_22
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Part0 = v_u_22.PrimaryPart
		Motor6D.Part1 = v23.PrimaryPart
		Motor6D.C0 = p_u_21.itemProperties:GetAttribute("OffsetFP") or CFrame.new()
		Motor6D.C1 = p_u_21.itemProperties:GetAttribute("OffsetFP1") or CFrame.new()
		Motor6D.Parent = v_u_22.PrimaryPart
		v23.Parent = v_u_22
	end
	v_u_22.Name = "ViewModel"
	local v24 = v_u_22:GetDescendants()
	for v25 = 1, #v24 do
		if v24[v25]:IsA("BasePart") then
			v24[v25].CollisionGroup = "ViewModel"
			v24[v25].Massless = true
			v24[v25].CanCollide = false
			v24[v25].CanTouch = false
			v24[v25].CanQuery = false
			v24[v25].CastShadow = false
			v24[v25].Massless = true
			v24[v25]:SetAttribute("OriginalTransparency", v24[v25].Transparency)
			v24[v25]:SetAttribute("TransparencyOverride", true)
		end
	end
	v_u_22:FindFirstChildOfClass("BodyColors").HeadColor3 = p_u_21.character:FindFirstChildOfClass("BodyColors").HeadColor3
	v_u_22:FindFirstChildOfClass("BodyColors").LeftArmColor3 = p_u_21.character:FindFirstChildOfClass("BodyColors").LeftArmColor3
	v_u_22:FindFirstChildOfClass("BodyColors").LeftLegColor3 = p_u_21.character:FindFirstChildOfClass("BodyColors").LeftLegColor3
	v_u_22:FindFirstChildOfClass("BodyColors").RightArmColor3 = p_u_21.character:FindFirstChildOfClass("BodyColors").RightArmColor3
	v_u_22:FindFirstChildOfClass("BodyColors").RightLegColor3 = p_u_21.character:FindFirstChildOfClass("BodyColors").RightLegColor3
	v_u_22:FindFirstChildOfClass("BodyColors").TorsoColor3 = p_u_21.character:FindFirstChildOfClass("BodyColors").TorsoColor3
	v_u_22.Clothing.ShirtTemplate = p_u_21.character.Shirt.ShirtTemplate
	if p_u_21.weapon:GetAttribute("Skin") and p_u_21.weapon:GetAttribute("Skin") ~= "" then
		v_u_7:UpdateSkin(p_u_21.weapon, v_u_22.Item)
	end
	if p_u_21.weapon:GetAttribute("Skin") then
		p_u_21.Connections["SkinConnection" .. p_u_21.weapon.Name] = p_u_21.weapon:GetAttributeChangedSignal("Skin"):Connect(function()
			--[[ line: 206 | upvalues: (ref) v_u_7, (copy) p_u_21, (ref) v_u_22]]
			v_u_7:UpdateSkin(p_u_21.weapon, v_u_22.Item)
		end)
	end
	viewModelClothes(p_u_21, v_u_22)
	v_u_22:SetAttribute("Temp", true)
	v_u_22.Parent = workspace.Camera
	return v_u_22
end
local function createWorldModel(p26, p27)
	--[[ line: 222 | upvalues: (copy) v_u_7]]
	local Name = game.ReplicatedStorage.ItemsListModels:FindFirstChild(p27.Value.Name)
	if Name then
		local v28 = Name:Clone()
		local Motor6D2 = Instance.new("Motor6D")
		Motor6D2.Part0 = p26.character.UpperTorso
		Motor6D2.Part1 = v28.ItemRoot
		Motor6D2.C1 = p27.Value.ItemProperties:GetAttribute("Offset3P") or CFrame.new()
		Motor6D2.Parent = v28.ItemRoot
		v28.Parent = p26.character
		v_u_7:UpdateAttachments(p27, v28)
		v_u_7:UpdateSkin(p27, v28)
		for _2, v29 in pairs((v28:GetDescendants())) do
			if v29:IsA("MeshPart") or v29:IsA("BasePart") then
				v29.CollisionGroup = "Zero"
				v29.CanCollide = false
				v29.CanTouch = false
				v29.CanQuery = false
				v29.Massless = true
			end
		end
		v28:SetAttribute("WorldModel", true)
		p26.worldModel = v28
	end
end
local function attachmentsCheck(p_u_30)
	--[[ line: 255 | upvalues: (copy) v_u_7]]
	v_u_7:UpdateAttachments(p_u_30.weapon, p_u_30.viewModel.Item)
	p_u_30.sight = nil
	p_u_30.barrel = nil
	if p_u_30.viewModel.Item:FindFirstChild("Attachments") and p_u_30.viewModel.Item.Attachments:GetAttribute("Front") then
		if p_u_30.viewModel.Item.Attachments:FindFirstChild("Front") then
			p_u_30.barrel = p_u_30.viewModel.Item.Attachments.Front.Barrel
		end
	elseif p_u_30.viewModel.Item:FindFirstChild("Barrel") then
		p_u_30.barrel = p_u_30.viewModel.Item.Barrel
	end
	local KeybindHints = p_u_30.mainGui.MainFrame.InteractionFrame.KeybindHints
	KeybindHints.ToggleAttachment.Visible = false
	if p_u_30.viewModel.Item:FindFirstChild("Attachments") then
		local v31 = p_u_30.viewModel.Item.Attachments:GetChildren()
		if #v31 > 1 then
			local v32 = p_u_30.viewModel.Item:GetDescendants()
			for v33 = 1, #v32 do
				if v32[v33]:IsA("BasePart") and v32[v33]:GetAttribute("OriginalTransparency") then
					v32[v33]:SetAttribute("TransparencyOverride", true)
				end
			end
			for _3, v34 in pairs(v31) do
				local Name2 = v34.Name
				if Name2 == "Sight" then
					local v35 = v_u_7:FindFirstChildOfSlotType(p_u_30.weapon.Attachments, "Sight")
					if v35 then
						local t2 = { AimPart = p_u_30.viewModel.Item.AttachmentPoints.Sight:GetAttribute("AimPartLong") and v34:FindFirstChild("AimPartLong") or v34.AimPart, Sight = v34 }
						local Scope = v34.PrimaryPart:FindFirstChild("Scope")
						if Scope then
							Scope = v35.Value.Name
						end
						t2.Scope = Scope
						local ReSizeScope = v34.PrimaryPart:FindFirstChild("ReSizeScope")
						if ReSizeScope then
							ReSizeScope = v34.PrimaryPart.ReSizeScope.Value
						end
						t2.ReSizeScope = ReSizeScope
						local ReSizeScope2 = v34.PrimaryPart:FindFirstChild("ReSizeScope")
						if ReSizeScope2 then
							ReSizeScope2 = v34.PrimaryPart.ReSizeScope.SizeVector.Value
						end
						t2.ReSizeScopeVector = ReSizeScope2
						t2.ZoomAmount = v35.Value.ItemProperties.Attachment:GetAttribute("Zoom")
						t2.AmbientBoost = v35.Value.ItemProperties.Attachment:GetAttribute("AmbientBoost") or 0
						t2.NightVisionColor = v35.Value.ItemProperties.Attachment:GetAttribute("NightVisionColor") or Color3.new(1, 1, 1)
						t2.GrainEffect = v35.Value.ItemProperties.Attachment:GetAttribute("GrainEffect") or 1
						t2.ThermalVisionColor = v35.Value.ItemProperties.Attachment:GetAttribute("ThermalVisionColor")
						t2.VariableZoom = v35.Value.ItemProperties.Attachment:FindFirstChild("VariableZoom") and v35.Value.ItemProperties.Attachment.VariableZoom:GetAttributes() or nil
						t2.ZoomSpeed = v35.Value.ItemProperties.Attachment:GetAttribute("ZoomSpeed") or 0.3
						t2.ZoomIndex = v35:GetAttribute("ZoomIndex") or 1
						if v35.Value.ItemProperties.Attachment:GetAttribute("AllowIronSight") then
							p_u_30.aimParts[3] = p_u_30.aimParts[1]
							p_u_30.aimParts[1] = t2
							p_u_30.aimPart = p_u_30.aimParts[1].AimPart
							p_u_30.sight = p_u_30.aimParts[1].Sight
							p_u_30.Scope = p_u_30.aimParts[1].Scope
							p_u_30.ReSizeScope = p_u_30.aimParts[1].ReSizeScope
							p_u_30.ReSizeScopeVector = p_u_30.aimParts[1].ReSizeScopeVector
							p_u_30.zoomAmount = p_u_30.aimParts[1].ZoomAmount
							p_u_30.ambientBoost = p_u_30.aimParts[1].AmbientBoost
							p_u_30.nightVisionColor = p_u_30.aimParts[1].NightVisionColor
							p_u_30.grainEffect = p_u_30.aimParts[1].GrainEffect
							p_u_30.thermalVisionColor = p_u_30.aimParts[1].ThermalVisionColor
							p_u_30.variableZoom = p_u_30.aimParts[1].VariableZoom
							p_u_30.zoomSpeed = p_u_30.aimParts[1].ZoomSpeed
							p_u_30.zoomIndex = p_u_30.aimParts[1].ZoomIndex
						else
							p_u_30.aimParts[1] = t2
							p_u_30.aimPart = p_u_30.aimParts[1].AimPart
							p_u_30.sight = p_u_30.aimParts[1].Sight
							p_u_30.Scope = p_u_30.aimParts[1].Scope
							p_u_30.ReSizeScope = p_u_30.aimParts[1].ReSizeScope
							p_u_30.ReSizeScopeVector = p_u_30.aimParts[1].ReSizeScopeVector
							p_u_30.zoomAmount = p_u_30.aimParts[1].ZoomAmount
							p_u_30.ambientBoost = p_u_30.aimParts[1].AmbientBoost
							p_u_30.nightVisionColor = p_u_30.aimParts[1].NightVisionColor
							p_u_30.grainEffect = p_u_30.aimParts[1].GrainEffect
							p_u_30.thermalVisionColor = p_u_30.aimParts[1].ThermalVisionColor
							p_u_30.variableZoom = p_u_30.aimParts[1].VariableZoom
							p_u_30.zoomSpeed = p_u_30.aimParts[1].ZoomSpeed
							p_u_30.zoomIndex = p_u_30.aimParts[1].ZoomIndex
						end
						if p_u_30.variableZoom then
							p_u_30.mobileButtons.GameplayLayer.AimingLayer.ZoomIn.Visible = true
							p_u_30.mobileButtons.GameplayLayer.AimingLayer.ZoomOut.Visible = true
						end
						if p_u_30.sight.PrimaryPart:FindFirstChild("ReticleWeld") then
							v34.PrimaryPart.ReticleWeld:Destroy()
							local v36 = Instance.new("Weld", v34.PrimaryPart)
							v36.Name = "ZoomWeld"
							v36.Part0 = v34.Reticle
							v36.Part1 = v34.AimPart
							v36.C0 = CFrame.new(0, 0, 1)
						end
						if p_u_30.sight.PrimaryPart:FindFirstChild("ZoomWeld") then
							local variableZoom = p_u_30.variableZoom
							local zoomIndex = p_u_30.zoomIndex
							p_u_30.zoomAmount = variableZoom[tostring(zoomIndex) or "1"]
							local v37 = 0.155 + p_u_30.zoomAmount * 0.16
							p_u_30.sight.PrimaryPart.ZoomWeld.C0 = CFrame.new(0, 0, v37)
						end
						if not v34.PrimaryPart:FindFirstChild("NoRail") and p_u_30.viewModel.Item:FindFirstChild("SightRail") then
							p_u_30.viewModel.Item.SightRail.Transparency = 0
						end
					end
				elseif Name2 == "Muzzle" then
					if v34:FindFirstChild("BarrelExtension") then
						p_u_30.barrel = v34:FindFirstChild("BarrelExtension")
					end
				elseif Name2 == "Extra" then
					local ExtraType = v_u_7:FindFirstChildOfSlotType(p_u_30.weapon.Attachments, "Extra").Value.ItemProperties.Attachment:GetAttribute("ExtraType")
					if ExtraType == "Laser" then
						KeybindHints.ToggleAttachment.Frame.Decor.Text = "Laser"
						KeybindHints.ToggleAttachment.Visible = true
					elseif ExtraType == "Flashlight" then
						KeybindHints.ToggleAttachment.Frame.Decor.Text = "Light"
						KeybindHints.ToggleAttachment.Visible = true
					end
				end
			end
		end
		local Attachments = p_u_30.weapon:FindFirstChild("Attachments")
		if Attachments then
			p_u_30.Connections.Attachment_Added = p_u_30.weapon.Attachments.ChildAdded:Connect(function(p_u_38)
				--[[ line: 401 | upvalues: (ref) v_u_7, (copy) p_u_30]]
				print("attachment found")
				if v_u_7:IsItemAccessibleToPlayer(p_u_30.player, p_u_30.weapon) then
					if p_u_38.Value.ItemProperties:GetAttribute("SlotType") ~= "Magazine" then
						print("equip attach")
						p_u_30:equip(p_u_30.weapon, p_u_30.equipId)
						p_u_30.Connections[p_u_38] = p_u_38:GetPropertyChangedSignal("Parent"):Once(function()
							--[[ line: 414 | upvalues: (copy) p_u_38, (ref) p_u_30]]
							if p_u_38.Value.ItemProperties:GetAttribute("SlotType") ~= "Magazine" then
								p_u_30:equip(p_u_30.weapon, p_u_30.equipId)
							end
						end)
					end
				else
					return
				end
			end)
			for _4, v_u_39 in pairs((Attachments:GetChildren())) do
				p_u_30.Connections[v_u_39] = v_u_39:GetPropertyChangedSignal("Parent"):Once(function()
					--[[ line: 428 | upvalues: (copy) v_u_39, (copy) p_u_30]]
					if v_u_39.Value.ItemProperties:GetAttribute("SlotType") ~= "Magazine" then
						if p_u_30.equipId == p_u_30.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
							p_u_30:equip(p_u_30.weapon, p_u_30.equipId)
						end
					end
				end)
			end
			for _5, v_u_40 in pairs((Attachments:GetChildren())) do
				local SlotType = v_u_40.Value.ItemProperties:GetAttribute("SlotType")
				if not p_u_30.Connections["SkinConnection" .. SlotType] and v_u_40.Value.ItemProperties:GetAttribute("Skin") then
					p_u_30.Connections["SkinConnection" .. SlotType] = v_u_40:GetAttributeChangedSignal("Skin"):Connect(function()
						--[[ line: 442 | upvalues: (copy) p_u_30, (copy) SlotType, (ref) v_u_7, (copy) v_u_40]]
						if p_u_30.viewModel.Item.Attachments:FindFirstChild(SlotType) then
							v_u_7:UpdateSkin(v_u_40, p_u_30.viewModel.Item.Attachments[SlotType])
						end
					end)
				end
			end
			if p_u_30.weapon.Attachments:GetAttribute("Extra") then
				local v41 = v_u_7:FindFirstChildOfSlotType(p_u_30.weapon.Attachments, "Extra")
				if v41 then
					local ExtraType2 = v41.Value.ItemProperties.Attachment:GetAttribute("ExtraType")
					if ExtraType2 == "Laser" then
						if ExtraType2 ~= "FlashLight" then
							p_u_30.flashLightActive = true
						end
					else
						p_u_30.laserActive = false
						return
					end
				end
				p_u_30.laserActive = false
				p_u_30.flashLightActive = false
			end
		end
	end
end
local function SwapMagazine(p42, p43, p44)
	--[[ line: 466 | upvalues: (copy) v_u_7]]
	if p43 ~= "" then
		if p42.viewModel.Item.Attachments:FindFirstChild("Magazine") then
			p42.viewModel.Item.Attachments.Magazine:Destroy()
		end
		local Magazine = p42.viewModel.Item.AttachmentPoints:FindFirstChild("Magazine")
		local v45 = game.ReplicatedStorage.ItemsListModels:FindFirstChild(p43):Clone()
		v45.Name = "Magazine"
		local v46 = v45:GetDescendants()
		for _6, v47 in pairs(v46) do
			if v47:IsA("BasePart") then
				v47.CastShadow = false
			end
		end
		v45:PivotTo(Magazine.CFrame)
		local WeldConstraint = Instance.new("WeldConstraint")
		WeldConstraint.Name = "AttachmentWeld"
		WeldConstraint.Part0 = Magazine
		WeldConstraint.Part1 = v45.PrimaryPart
		WeldConstraint.Parent = v45.PrimaryPart
		v45.Parent = p42.viewModel.Item.Attachments
		if v45 and p44 then
			local LoadedAmmo = p44:GetAttribute("LoadedAmmo")
			if v45:FindFirstChild("Bullet1") then
				if LoadedAmmo > 0 then
					v45.Bullet1.Transparency = 0
					local v48 = p44.LoadedAmmo:GetChildren()
					local AmmoType = v48[#v48]:GetAttribute("AmmoType")
					local v49 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(AmmoType)
					if v49:FindFirstChild("Ammo") then
						if v45.Bullet1:FindFirstChild("SurfaceAppearance") then
							v45.Bullet1:FindFirstChild("SurfaceAppearance"):Destroy()
						end
						v49.Ammo.SurfaceAppearance:Clone().Parent = v45.Bullet1
					end
				else
					v45.Bullet1.Transparency = 1
				end
			end
			if v45:FindFirstChild("Bullet2") then
				if LoadedAmmo > 1 then
					v45.Bullet2.Transparency = 0
				else
					v45.Bullet2.Transparency = 1
				end
			end
			if v45:FindFirstChild("AmmoBelt") then
				for _7, v50 in pairs((v45.AmmoBelt:GetChildren())) do
					if v50:GetAttribute("Order") then
						local v51 = LoadedAmmo <= v50:GetAttribute("Order") and 1 or 0
						for _8, v52 in pairs((v50:GetChildren())) do
							v52.Transparency = v51
						end
					end
				end
			end
			if p44:GetAttribute("Skin") then
				v_u_7:UpdateSkin(p44, v45)
			end
		end
	end
end
local function MagazineTypeCheck(p53, p54)
	--[[ line: 547 | upvalues: (copy) v_u_7, (copy) SwapMagazine]]
	if p53.weapon:FindFirstChild("Attachments") and p53.weapon.Attachments:GetAttribute("Magazine") then
		local v55 = v_u_7:FindFirstChildOfSlotType(p53.weapon.Attachments, "Magazine")
		if v55 then
			if p54 then
				local Name3 = v55.Value.Name
				if Name3 ~= "" then
					SwapMagazine(p53, Name3)
				end
			end
			return true
		end
		if p53.viewModel.Item.Attachments:FindFirstChild("Magazine") then
			p53.viewModel.Item.Attachments.Magazine:Destroy()
		end
		return false
	end
end
local function MovementSpeed(p56)
	--[[ line: 596 | upvalues: (copy) v_u_7, (copy) Input, (copy) Lighting]]
	local _9 = p56.humanoid.moveDirection
	local SprintStrafe = p56.SprintStrafe
	local v57 = p56.humanoid:GetState()
	local v58, v59
	if v_u_7:IsPlayerAlive(p56.player) then
		local MovementModifier = p56.character.HumanoidRootPart:GetAttribute("MovementModifier")
		local movementModifier = p56.movementModifier
		local v60 = MovementModifier + math.clamp(movementModifier, -10, 0)
		if p56.rs_Player.Status.GameplayVariables.Buffs:GetAttribute("SerumRed") then
			v60 = v60 * 0.4 + 2
		end
		if p56.sprinting == true and (SprintStrafe < -0.35 and p56.LegFracture:GetAttribute("Value") == 0) then
			if v57 == Enum.HumanoidStateType.Swimming then
				v58 = 18.2 + v60
				v59 = 3.3
				p56:changeLean(0, true)
				if p56.stance ~= "Standing" then
					p56:changeStance("Standing", true)
				end
			else
				p56:changeLean(0, true)
				local v61 = (tick() - p56.lastStumbleTime) * 2.75
				local v62 = 1 - math.clamp(v61, 0, 1)
				local v63 = (1 - math.pow(v62, 2)) * (18.2 + v60)
				v58 = math.max(12.5, v63)
				v59 = 3.5 + v60 / 3.3
			end
		elseif v57 == Enum.HumanoidStateType.Swimming then
			v58 = 12
			v59 = 3.3
			p56:changeLean(0, true)
			if p56.stance ~= "Standing" then
				p56:changeStance("Standing", true)
			end
		else
			v58 = 9 + v60 / 4
			v59 = 3.3 + v60 / 3.3
		end
		if p56.sprinting and (p56.horizontalVelocity < 9 and (os.clock() - p56.sprintStart > 1 and Input.getInputType() == "Gamepad")) then
			p56.sprinting = false
			p56.rs_Player.Status.GameplayVariables.Sprinting:SetAttribute("Value", p56.sprinting)
		end
		if p56.stance == "Crouching" then
			if v57 == Enum.HumanoidStateType.Swimming then
				v58 = 13
				v59 = 3.3
				p56:changeLean(0, true)
				if p56.stance ~= "Standing" then
					p56:changeStance("Standing", true)
				end
			else
				v58 = v58 * 0.6
				v59 = 3.3 + v60 / 3.3
			end
		end
	else
		v59 = 0
		v58 = 0
	end
	local v64 = p56.jumpDebounce and 0 or v59
	if Input.getInputType() == "Gamepad" then
		local v65 = Lighting.InventoryBlur.Size > 5 and 0 or v64
		local v66 = (p56.mainGui.MainFrame.InteractionFrame.InteractionDisplay.SpeechBox.Visible or p56.mainGui.MainFrame.InteractionFrame.InteractionList.Visible) and 0 or v65
		v64 = p56.menuGui and p56.menuGui.Enabled and 0 or v66
	end
	local v67 = p56.rs_Player.Status.GameplayVariables.Vehicle.CurrentSeat.Value and 0 or v64
	if v67 > 0 and p56.humanoid:GetAttribute("JumpCooldown") then
		local _10 = tick() < p56.humanoid:GetAttribute("JumpCooldown")
	end
	if v67 ~= p56.lastJumpHeight then
		p56.humanoid.JumpHeight = v67
		p56.lastJumpHeight = v67
	end
	if v58 ~= p56.lastSpeed then
		p56.humanoid.WalkSpeed = v58
		p56.lastSpeed = v58
	end
end
local function airSpeed(p68, p69)
	--[[ line: 748 | upvalues: none]]
	if not p68.hrp:FindFirstChild("AirSpeed") then
		local horizontalVelocity = p68.horizontalVelocity
		if tick() - p68.lastJumpTime > 0.333 then
			horizontalVelocity = p68.horizontalVelocity * 1.32
		end
		p68.lastStumbleTime = tick() + 0.6
		local Unit = p68.velocity.Unit
		local v70 = Vector3.new(1, 0, 1)
		if p69 then
			horizontalVelocity = p69.Magnitude
			Unit = p69.Unit
		end
		local LinearVelocity = Instance.new("LinearVelocity")
		LinearVelocity.Name = "AirSpeed"
		LinearVelocity.Attachment0 = p68.hrp.RootRigAttachment
		LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		LinearVelocity.MaxAxesForce = v70 * horizontalVelocity * 1000
		LinearVelocity.VectorVelocity = Unit * horizontalVelocity
		LinearVelocity:SetAttribute("Temp", true)
		LinearVelocity.Parent = p68.hrp
		local _11 = p68.hrp.Position
		local v71 = 0
		while true do
			local v72 = task.wait()
			v71 = v71 + v72
			local Magnitude = p68.hrp.AssemblyLinearVelocity.Magnitude
			local v73 = horizontalVelocity - 10 * v72
			horizontalVelocity = math.clamp(v73, 0, 40)
			LinearVelocity.MaxAxesForce = (p68.onGround and Vector3.new(1, 0, 1) or Vector3.new(0.2, 0, 0.2)) * horizontalVelocity * 1000
			LinearVelocity.VectorVelocity = Unit * horizontalVelocity
			if v71 > 0.1 and (p68.onGround and p68.humanoid:GetState() == Enum.HumanoidStateType.Running) or (p68.humanoid:GetState() == Enum.HumanoidStateType.Climbing or (Magnitude < 5 or horizontalVelocity < 6)) then
				break
			end
			local _12 = p68.hrp.Position
		end
		LinearVelocity:Destroy()
	end
end
local function WallCollision(p74)
	--[[ line: 846 | upvalues: (copy) v_u_11, (copy) CurrentCamera]]
	local ItemLength = p74.ItemLength
	v_u_11.FilterDescendantsInstances = { CurrentCamera, p74.character, workspace.NoCollision }
	local v75 = 0
	for _13, v76 in pairs({
		{ Up = -0.32, Right = 0 },
		{ Up = 0.1, Right = 0.32 },
		{ Up = 0.1, Right = -0.32 }
	}) do
		local v77 = CFrame.new(CurrentCamera.CFrame.Position + CurrentCamera.CFrame.RightVector * v76.Right + CurrentCamera.CFrame.UpVector * v76.Up)
		local LookVector = CurrentCamera.CFrame.LookVector
		local v78 = workspace:Raycast(v77.Position, LookVector * ItemLength, v_u_11)
		Vector3.new()
		if v78 then
			local _14 = v78.Position
			local v79 = (ItemLength - (v78.Position - CurrentCamera.CFrame.Position).Magnitude) / ItemLength
			if v75 < v79 then
				v75 = v79
			end
		else
			local _15 = v77.Position + LookVector * ItemLength
		end
	end
	return v75
end
local function UseBullet(p80)
	--[[ line: 928 | upvalues: none]]
	if p80.Bullets > 0 then
		p80.Bullets = p80.Bullets - 1
		local v81 = #p80.BulletsList
		if p80.BulletsList[v81].Amount <= 0 then
			local v82 = p80.BulletsList[v81 - 1].Amount - 1
			p80.BulletsList[v81 - 1].Amount = v82
			v83 = p80.BulletsList[v81 - 1].AmmoType
			if v82 < 1 then
				table.remove(p80.BulletsList, v81 - 1)
			end
			return v83
		end
		local v84 = p80.BulletsList[v81].Amount - 1
		p80.BulletsList[v81].Amount = v84
		local v83 = p80.BulletsList[v81].AmmoType
		if v84 >= 1 then
			return v83
		end
		table.remove(p80.BulletsList, v81)
		return v83
	end
end
local function UpdateBulletsList()
	--[[ line: 954 | upvalues: (copy) v_u_7]]
	-- failed to decompile function 26: called `Option::unwrap()` on a `None` value
end
useTypes = {
	RangedWeaponDefault = function(p_u_85)
		--[[ line: 997 | upvalues: (copy) v_u_7, (copy) SoundHandler, (copy) RangedWeapons, (copy) UseBullet, (copy) v_u_8, (copy) CurrentCamera, (copy) HapticService, (copy) Reload]]
		if not p_u_85.clientAnimationTracks.Equip or (not p_u_85.clientAnimationTracks.Equip.IsPlaying or p_u_85.clientAnimationTracks.Equip.TimePosition > p_u_85.clientAnimationTracks.Equip.Length * 0.8) then
			if p_u_85.timeNow > p_u_85.FireRate then
				p_u_85.timeNow = 0
				if v_u_7:IsCharacterUnderWater(p_u_85.character) then
					SoundHandler:PlayEquippedItem("Empty", p_u_85.character, 2)
					SoundHandler:Play(p_u_85.worldModel.ItemRoot.Sounds.Empty, p_u_85.SoundsTemp)
					p_u_85.MouseHeld = false
					return
				end
				local v86, v87
				if p_u_85.useDebounce == false and (p_u_85.isEquipped and (p_u_85.reloading == false and p_u_85.Bullets > 0)) then
					local v88
					if p_u_85.weapon:GetAttribute("Durability") then
						v88 = p_u_85.weapon:GetAttribute("Durability") > 0
					else
						v88 = true
					end
					if v88 and p_u_85.Operational then
						if p_u_85.clientAnimationTracks.Use then
							p_u_85.clientAnimationTracks.Use:Stop(0)
						end
						p_u_85.sprinting = false
						p_u_85.rs_Player.Status.GameplayVariables.Sprinting:SetAttribute("Value", p_u_85.sprinting)
						RangedWeapons:FindFirstChild(p_u_85.weapon.Name)
						local _16 = p_u_85.itemProperties
						p_u_85.timeSinceUse = 0
						local v89 = p_u_85.RecoilPatternPos + 1
						local MaxAmmo = p_u_85.MaxAmmo
						p_u_85.RecoilPatternPos = math.clamp(v89, 0, MaxAmmo)
						local v_u_90 = UseBullet(p_u_85)
						local v_u_91, v_u_92, v93, v94 = v_u_8:CreateBullet(p_u_85.weapon, p_u_85.worldModel, p_u_85.viewModel, p_u_85.aimPart, p_u_85.ToolStance, v_u_90, p_u_85.lastUseTime, p_u_85.RecoilPatternPos)
						if p_u_85.FireModes[p_u_85.FireModeIndex] == "Double" and p_u_85.Bullets > 0 then
							coroutine.wrap(function()
								--[[ line: 1030 | upvalues: (ref) v_u_90, (ref) UseBullet, (copy) p_u_85, (ref) v_u_8, (ref) v_u_91, (ref) v_u_92]]
								task.wait(0.015)
								v_u_90 = UseBullet(p_u_85)
								v_u_8:CreateBullet(p_u_85.weapon, p_u_85.worldModel, p_u_85.viewModel, p_u_85.aimPart, p_u_85.ToolStance, v_u_90, p_u_85.lastUseTime, p_u_85.RecoilPatternPos)
								v_u_91 = v_u_91 * 1.7
								v_u_92 = v_u_92 * 1.7
							end)()
						end
						local v_u_95 = Vector2.new(v94.y.Value * v_u_92, v94.x.Value * v_u_91)
						local v96 = p_u_85.FireModes[p_u_85.FireModeIndex] == "Auto"
						local new = Vector2.new
						local v97 = v_u_92 * 3
						local v98 = v_u_92 * 5
						local v99 = math.random(v97, v98) * (v96 and math.random() > 0.5 and -1 or 1) * 0.1
						local v100 = v_u_91 * 3
						local v101 = v_u_91 * 5
						local v102 = new(v99, math.random(v100, v101) * (v96 and math.random() > 0.5 and -1 or 1) * 0.1)
						local v103
						if p_u_85.isAiming then
							v103 = p_u_85.aimPart.Name == "AimPartCanted" and not p_u_85.laserActive and 0.5 or 0.18
						else
							v103 = p_u_85.laserActive and 0.45 or 0.7
						end
						local v104 = v102 * v103 * 0.57
						local v105 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(v_u_90)
						local Heat = v105:GetAttribute("Heat")
						local Damage = v105:GetAttribute("Damage")
						local Arrow = v105:GetAttribute("Arrow")
						local AlwaysRecoil = v105:GetAttribute("AlwaysRecoil")
						if p_u_85.isAiming then
							if p_u_85.FireModes[p_u_85.FireModeIndex] == "Bolt Action" and not AlwaysRecoil then
								local recoilRot = p_u_85.springs.recoilRot
								local v106 = 0.01 + v_u_95.X + v104.x
								local v107 = v_u_95.Y + v104.y
								local v108 = v_u_91 * 2
								local v109 = v_u_91 * 5
								local v110 = math.random(v108, v109) * (math.random() > 0.5 and -1 or 1) * 0.002
								recoilRot:shove(Vector3.new(v106, v107, v110) * 0.25)
								p_u_85.springs.recoilPos:shove(Vector3.new(0, 0, 0.35))
							else
								local recoilRot2 = p_u_85.springs.recoilRot
								local v111 = 0.01 + v_u_95.X + v104.x
								local v112 = v_u_95.Y + v104.y
								local v113 = v_u_91 * 2
								local v114 = v_u_91 * 5
								local v115 = math.random(v113, v114) * (math.random() > 0.5 and -1 or 1) * 0.005
								recoilRot2:shove((Vector3.new(v111, v112, v115)))
								p_u_85.springs.recoilPos:shove(Vector3.new(0, 0, 0.4))
							end
						else
							local recoilRot3 = p_u_85.springs.recoilRot
							local v116 = 0.15 + v_u_95.X + v104.x
							local v117 = v_u_95.Y + v104.y
							local v118 = v_u_91 * 3
							local v119 = v_u_91 * 5
							local v120 = math.random(v118, v119) * (math.random() > 0.5 and -1 or 1) * 0.01
							recoilRot3:shove((Vector3.new(v116, v117, v120)))
							local recoilPos = p_u_85.springs.recoilPos
							local v121 = math.random(2, 5) * (math.random() > 0.5 and -1 or 1) * 0.005
							local v122 = math.random(2, 5) * (math.random() > 0.5 and -1 or 1) * 0.005 - 0.05
							recoilPos:shove((Vector3.new(v121, v122, 1)))
						end
						if p_u_85.isAiming and (p_u_85.FireModes[p_u_85.FireModeIndex] == "Bolt Action" and not AlwaysRecoil) then
							local cameraRecoil = p_u_85.springs.cameraRecoil
							local v123 = v_u_95.X * 2
							local v124 = v_u_95.Y * 1
							cameraRecoil:shove((Vector3.new(v123, v124, 0)))
						else
							local cameraRecoil2 = p_u_85.springs.cameraRecoil
							local v125 = v_u_95.X * 12
							local v126 = v_u_95.Y * 6
							cameraRecoil2:shove((Vector3.new(v125, v126, 0)))
						end
						if p_u_85.FireModes[p_u_85.FireModeIndex] == "Bolt Action" then
							p_u_85.useDebounce = true
							p_u_85.weapon:SetAttribute("NeedsCycle", true)
						else
							local v_u_127 = v_u_90
							task.spawn(function()
								--[[ line: 574 | upvalues: (copy) p_u_85, (copy) v_u_127]]
								local viewModel2 = p_u_85.viewModel
								if p_u_85.settings.EjectionDelay then
									wait(p_u_85.settings.EjectionDelay)
								end
								if viewModel2 == p_u_85.viewModel and p_u_85.viewModel.Parent then
									local EjectionPort = p_u_85.viewModel.Item:FindFirstChild("EjectionPort")
									if EjectionPort then
										if v_u_127 then
											local v128 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(v_u_127)
											if v128:FindFirstChild("Casing") then
												EjectionPort.Casing.Texture = v128.Casing.Texture
											end
										end
										EjectionPort.Casing:Emit(1)
									end
								end
							end)
						end
						if not Arrow then
							local v129 = v93 == "Suppressor" and 2 or 1
							if Heat then
								if v93 == "Suppressor" then
									v129 = Heat / 2 or Heat
								else
									v129 = Heat
								end
							elseif Damage > 65 then
								v129 = v93 == "Suppressor" and 5 or 10
							end
							p_u_85.firedInRow = p_u_85.firedInRow + v129
						end
						task.spawn(function()
							--[[ line: 916 | upvalues: (copy) v_u_95, (ref) HapticService, (copy) p_u_85]]
							local v130 = (v_u_95.Y + v_u_95.X) * 10
							local v131 = math.clamp(v130, 0.1, 1)
							HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, v131)
							task.wait(0.15)
							if p_u_85.MouseHeld == false or p_u_85.Bullets == 0 then
								HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
							end
						end)
						if (not p_u_85.isAiming or (p_u_85.FireModes[p_u_85.FireModeIndex] ~= "Bolt Action" or AlwaysRecoil)) and p_u_85.clientAnimationTracks.Use then
							p_u_85.clientAnimationTracks.Use:Play(0.1)
							p_u_85.serverAnimationTracks.Use:AdjustSpeed(1)
						end
						if p_u_85.isAiming then
							if p_u_85.serverAnimationTracks.Use then
								p_u_85.serverAnimationTracks.UseAiming:Play(0.1)
							end
						elseif p_u_85.serverAnimationTracks.Use then
							p_u_85.serverAnimationTracks.Use:Play(0.1)
						end
						if p_u_85.Bullets <= 12 then
							if p_u_85.viewModel.Item:FindFirstChild("Attachments") and p_u_85.viewModel.Item.Attachments:GetAttribute("Magazine") then
								local Magazine2 = p_u_85.viewModel.Item.Attachments.Magazine
								if Magazine2 then
									local Bullets = p_u_85.Bullets
									if p_u_85.Bullets <= 2 then
										if Magazine2:FindFirstChild("Bullet1") then
											if Bullets > 0 then
												Magazine2.Bullet1.Transparency = 0
											else
												Magazine2.Bullet1.Transparency = 1
											end
										end
										if Magazine2:FindFirstChild("Bullet2") then
											if Bullets > 1 then
												Magazine2.Bullet2.Transparency = 0
											else
												Magazine2.Bullet2.Transparency = 1
											end
										end
									end
									if Magazine2:FindFirstChild("AmmoBelt") then
										for _17, v132 in pairs((Magazine2.AmmoBelt:GetChildren())) do
											if v132:GetAttribute("Order") then
												local v133 = Bullets <= v132:GetAttribute("Order") and 1 or 0
												for _18, v134 in pairs((v132:GetChildren())) do
													v134.Transparency = v133
												end
											end
										end
									end
								end
							end
							if p_u_85.viewModel.Item:FindFirstChild("Bullets") then
								local Bullets2 = p_u_85.Bullets
								if p_u_85.viewModel.Item.Bullets:FindFirstChild("Bullet1") then
									if Bullets2 > 0 then
										p_u_85.viewModel.Item.Bullets.Bullet1.Transparency = 0
									else
										p_u_85.viewModel.Item.Bullets.Bullet1.Transparency = 1
									end
								end
								if p_u_85.viewModel.Item.Bullets:FindFirstChild("Bullet2") then
									if Bullets2 > 1 then
										p_u_85.viewModel.Item.Bullets.Bullet2.Transparency = 0
									else
										p_u_85.viewModel.Item.Bullets.Bullet2.Transparency = 1
									end
								end
							end
						end
						if p_u_85.Bullets == 0 then
							if p_u_85.clientAnimationTracks.BoltLock then
								p_u_85.clientAnimationTracks.BoltLock:Play(0)
							end
							if p_u_85.clientAnimationTracks.Empty then
								p_u_85.clientAnimationTracks.Empty:Play(0)
							end
							if p_u_85.clientAnimationTracks.BoltOpen then
								p_u_85.clientAnimationTracks.BoltOpen:Stop()
							end
							for _19, v135 in pairs((p_u_85.worldModel:GetChildren())) do
								if v135:GetAttribute("HideEmpty") then
									v135.Transparency = 1
								end
							end
						end
					elseif p_u_85.isEquipped and (p_u_85.Bullets > 0 and (p_u_85.reloading and (p_u_85.reloadType == "loadByHand" and p_u_85.MaxAmmo > 1))) then
						p_u_85.cancellingReload = true
						Reload:InvokeServer(p_u_85.weapon, 30, true)
					elseif p_u_85.useDebounce == false and p_u_85.reloading == false then
						p_u_85.MouseHeld = false
						SoundHandler:PlayEquippedItem("Empty", p_u_85.character, 2)
						SoundHandler:Play(p_u_85.worldModel.ItemRoot.Sounds.Empty, p_u_85.SoundsTemp)
						v86 = p_u_85.springs.recoilRot
						v87 = -(math.random(3, 5) * 1 * 0.01)
						v86:shove((Vector3.new(v87, 0, 0)))
						if p_u_85.clientAnimationTracks.BoltOpen then
							if p_u_85.clientAnimationTracks.Empty then
								p_u_85.clientAnimationTracks.Empty:Play()
							end
							if p_u_85.clientAnimationTracks.BoltOpen then
								p_u_85.clientAnimationTracks.BoltOpen:Stop()
							end
						end
						if p_u_85.clientAnimationTracks.HammerLock and (not p_u_85.clientAnimationTracks.BoltLock or p_u_85.clientAnimationTracks.BoltLock and not p_u_85.clientAnimationTracks.BoltLock.IsPlaying) then
							p_u_85.clientAnimationTracks.HammerLock:Play(0.1)
						end
					end
				elseif p_u_85.isEquipped and (p_u_85.Bullets > 0 and (p_u_85.reloading and (p_u_85.reloadType == "loadByHand" and p_u_85.MaxAmmo > 1))) then
					p_u_85.cancellingReload = true
					Reload:InvokeServer(p_u_85.weapon, 30, true)
				elseif p_u_85.useDebounce == false and p_u_85.reloading == false then
					p_u_85.MouseHeld = false
					SoundHandler:PlayEquippedItem("Empty", p_u_85.character, 2)
					SoundHandler:Play(p_u_85.worldModel.ItemRoot.Sounds.Empty, p_u_85.SoundsTemp)
					v86 = p_u_85.springs.recoilRot
					v87 = -(math.random(3, 5) * 1 * 0.01)
					v86:shove((Vector3.new(v87, 0, 0)))
					if p_u_85.clientAnimationTracks.BoltOpen then
						if p_u_85.clientAnimationTracks.Empty then
							p_u_85.clientAnimationTracks.Empty:Play()
						end
						if p_u_85.clientAnimationTracks.BoltOpen then
							p_u_85.clientAnimationTracks.BoltOpen:Stop()
						end
					end
					if p_u_85.clientAnimationTracks.HammerLock and (not p_u_85.clientAnimationTracks.BoltLock or p_u_85.clientAnimationTracks.BoltLock and not p_u_85.clientAnimationTracks.BoltLock.IsPlaying) then
						p_u_85.clientAnimationTracks.HammerLock:Play(0.1)
					end
				end
			end
			if p_u_85.FireModes[p_u_85.FireModeIndex] == "Semi" or p_u_85.FireModes[p_u_85.FireModeIndex] == "Double" then
				p_u_85.MouseHeld = false
			end
		end
	end,
	MeleeWeaponDefault = function(p_u_136)
		--[[ line: 1216 | upvalues: (copy) SoundHandler, (copy) v_u_9]]
		if (not p_u_136.clientAnimationTracks.Equip or (not p_u_136.clientAnimationTracks.Equip.IsPlaying or p_u_136.clientAnimationTracks.Equip.TimePosition > p_u_136.clientAnimationTracks.Equip.Length * 0.8)) and p_u_136.useDebounce == false then
			local v137
			if p_u_136.weapon:GetAttribute("Durability") then
				v137 = p_u_136.weapon:GetAttribute("Durability") > 0
			else
				v137 = true
			end
			if v137 and p_u_136.Operational then
				p_u_136.useDebounce = true
				p_u_136.MouseHeld = false
				p_u_136.sprinting = false
				p_u_136.rs_Player.Status.GameplayVariables.Sprinting:SetAttribute("Value", p_u_136.sprinting)
				local _20 = p_u_136.weapon
				if p_u_136.worldModel.ItemRoot.Sounds.Swing:GetAttribute("Delay") then
					task.delay(p_u_136.worldModel.ItemRoot.Sounds.Swing:GetAttribute("Delay"), function()
						--[[ line: 1228 | upvalues: (ref) SoundHandler, (copy) p_u_136]]
						SoundHandler:PlayEquippedItem("Swing", p_u_136.character, 2)
						SoundHandler:Play(p_u_136.worldModel.ItemRoot.Sounds.Swing, p_u_136.SoundsTemp)
					end)
				else
					SoundHandler:PlayEquippedItem("Swing", p_u_136.character, 2)
					SoundHandler:Play(p_u_136.worldModel.ItemRoot.Sounds.Swing, p_u_136.SoundsTemp)
				end
				local v138
				if p_u_136.altUseCounter == 1 and p_u_136.clientAnimationTracks.UseAlt then
					p_u_136.altUseCounter = 0
					v138 = p_u_136.clientAnimationTracks.UseAlt
					p_u_136.clientAnimationTracks.UseAlt:Play(0.08)
					p_u_136.serverAnimationTracks.UseAlt:Play(0.08)
					p_u_136.clientAnimationTracks.Use:Stop()
					p_u_136.serverAnimationTracks.Use:Stop()
					p_u_136.clientAnimationTracks.Stab:Stop()
					p_u_136.serverAnimationTracks.Stab:Stop()
				else
					p_u_136.altUseCounter = 1
					v138 = p_u_136.clientAnimationTracks.Use
					p_u_136.clientAnimationTracks.Use:Play(0.08)
					p_u_136.serverAnimationTracks.Use:Play(0.08)
					p_u_136.clientAnimationTracks.UseAlt:Stop()
					p_u_136.serverAnimationTracks.UseAlt:Stop()
					p_u_136.clientAnimationTracks.Stab:Stop()
					p_u_136.serverAnimationTracks.Stab:Stop()
				end
				local v_u_139 = nil
				v_u_139 = v138:GetMarkerReachedSignal("SwingEnd"):Connect(function()
					--[[ line: 1267 | upvalues: (copy) p_u_136, (ref) v_u_139]]
					p_u_136.useDebounce = false
					if p_u_136.LeftMouseDown == true then
						p_u_136.MouseHeld = true
					end
					v_u_139:Disconnect()
				end)
				local v_u_140 = nil
				v_u_140 = v138:GetMarkerReachedSignal("HitScan"):Connect(function()
					--[[ line: 1278 | upvalues: (ref) v_u_9, (copy) p_u_136, (ref) v_u_140]]
					local _21, _22 = v_u_9:StartSwing(p_u_136.weapon, p_u_136.worldModel, p_u_136.viewModel, "NormalAttack", p_u_136.SprintStrafe)
					v_u_140:Disconnect()
				end)
			end
		end
	end,
	LauncherDefault = function(p141)
		--[[ line: 1298 | upvalues: (copy) v_u_1, (copy) UseBullet, (copy) SoundHandler, (copy) ServerProjectile, (copy) CurrentCamera]]
		if not v_u_1 then
			if p141.Bullets > 0 and (not p141.clientAnimationTracks.Equip.IsPlaying or p141.clientAnimationTracks.Equip.TimePosition > p141.clientAnimationTracks.Equip.Length * 0.8) then
				p141.MouseHeld = false
				UseBullet(p141)
				if p141.clientAnimationTracks.Use then
					p141.clientAnimationTracks.Use:Play(0.1)
				end
				if p141.serverAnimationTracks.Use then
					p141.serverAnimationTracks.Use:Play(0.1)
				end
				if p141.clientAnimationTracks.Empty then
					p141.clientAnimationTracks.Empty:Play()
				end
				SoundHandler:PlayEquippedItem("FireSound", p141.character, 2)
				SoundHandler:Play(p141.worldModel.ItemRoot.Sounds.FireSound, p141.SoundsTemp)
				ServerProjectile:FireServer(CurrentCamera.CFrame.LookVector, true, p141.isAiming)
			end
		end
	end,
	GrenadeDefault = function(p_u_142)
		--[[ line: 1324 | upvalues: (copy) v_u_1, (copy) SoundHandler, (copy) ServerProjectile, (copy) CurrentCamera]]
		if not v_u_1 then
			if p_u_142.useDebounce == false and (not p_u_142.clientAnimationTracks.Equip.IsPlaying or p_u_142.clientAnimationTracks.Equip.TimePosition > p_u_142.clientAnimationTracks.Equip.Length * 0.8) then
				p_u_142.useDebounce = true
				p_u_142.MouseHeld = false
				local equipAttemptId = p_u_142.equipAttemptId
				SoundHandler:PlayEquippedItem("Use", p_u_142.character, 2)
				SoundHandler:Play(p_u_142.worldModel.ItemRoot.Sounds.Use, p_u_142.SoundsTemp)
				if p_u_142.clientAnimationTracks.Use then
					p_u_142.clientAnimationTracks.Use:Play(0.05)
				end
				if p_u_142.serverAnimationTracks.Use then
					p_u_142.serverAnimationTracks.Use:Play(0.05)
				end
				local Amount = p_u_142.weapon:GetAttribute("Amount")
				coroutine.wrap(function()
					--[[ line: 1341 | upvalues: (copy) p_u_142, (copy) equipAttemptId, (ref) ServerProjectile, (ref) CurrentCamera]]
					task.wait(p_u_142.settings.GrenadeThrowDelay)
					if equipAttemptId == p_u_142.equipAttemptId then
						ServerProjectile:FireServer(CurrentCamera.CFrame.LookVector, true)
					end
				end)()
				local v143 = tick()
				while p_u_142.useDebounce == true and p_u_142.isEquipped == true do
					wait()
					if tick() - v143 > p_u_142.clientAnimationTracks.Use.Length - 0.15 then
						break
					end
				end
				if equipAttemptId == p_u_142.equipAttemptId then
					if Amount - 1 > 0 then
						p_u_142.ToolStance = "Idle"
						p_u_142.EquipTValue = 0
						if p_u_142.serverAnimationTracks.Equip then
							p_u_142.serverAnimationTracks.Equip:Play(0)
						end
						if p_u_142.viewModel then
							p_u_142.clientAnimationTracks.Idle:Play()
							if p_u_142.clientAnimationTracks.Equip then
								p_u_142.clientAnimationTracks.Equip:Play(0)
							end
							SoundHandler:PlayEquippedItem("Equip", p_u_142.character, 2)
							SoundHandler:Play(p_u_142.worldModel.ItemRoot.Sounds.Equip, p_u_142.SoundsTemp)
						end
						wait(0.35)
						if equipAttemptId == p_u_142.equipAttemptId then
							p_u_142.useDebounce = false
						end
					end
					wait(0.1)
					if equipAttemptId == p_u_142.equipAttemptId then
						p_u_142:unequip()
					end
				end
			end
		end
	end,
	FlareDefault = function(p144)
		--[[ line: 1387 | upvalues: (copy) v_u_1, (copy) SoundHandler, (copy) ServerProjectile, (copy) CurrentCamera]]
		if not v_u_1 then
			if p144.useDebounce == false and (not p144.clientAnimationTracks.Equip.IsPlaying or p144.clientAnimationTracks.Equip.TimePosition > p144.clientAnimationTracks.Equip.Length * 0.8) then
				p144.useDebounce = true
				p144.MouseHeld = false
				local weapon = p144.weapon
				if p144.clientAnimationTracks.Use then
					p144.clientAnimationTracks.Use:Play(0.05)
				end
				if p144.serverAnimationTracks.Use then
					p144.serverAnimationTracks.Use:Play(0.05)
				end
				wait(p144.settings.GrenadeThrowDelay)
				if weapon == p144.weapon then
					SoundHandler:PlayEquippedItem("Use", p144.character, 2)
					SoundHandler:Play(p144.worldModel.ItemRoot.Sounds.Use, p144.SoundsTemp)
					ServerProjectile:FireServer(CurrentCamera.CFrame.LookVector, true)
					wait(0.7)
					if weapon == p144.weapon then
						p144:unequip(nil, true)
					end
				end
			end
		end
	end,
	KeyDefault = function(p145)
		--[[ line: 1425 | upvalues: (copy) v_u_10]]
		if p145.useDebounce == false then
			p145.useDebounce = true
			p145.MouseHeld = false
			local _23 = p145.weapon
			p145.clientAnimationTracks.Use:Play(0.08)
			p145.serverAnimationTracks.Use:Play(0.08)
			wait(0.6)
			v_u_10:UseKey(p145.weapon)
			wait(1)
			p145.useDebounce = false
		end
	end,
	Consumable = function(p146)
		--[[ line: 1445 | upvalues: (copy) SoundHandler, (copy) Consume]]
		if (not p146.clientAnimationTracks.Equip or (not p146.clientAnimationTracks.Equip.IsPlaying or p146.clientAnimationTracks.Equip.TimePosition > p146.clientAnimationTracks.Equip.Length * 0.5)) and p146.useDebounce == false then
			p146.useDebounce = true
			p146.MouseHeld = false
			local weapon2 = p146.weapon
			SoundHandler:PlayEquippedItem("Use", p146.character, 2)
			SoundHandler:Play(p146.worldModel.ItemRoot.Sounds.Use, p146.SoundsTemp)
			if p146.clientAnimationTracks.Use then
				p146.clientAnimationTracks.Use:Play(0.08)
			end
			if p146.serverAnimationTracks.Use then
				p146.serverAnimationTracks.Use:Play(0.08)
			end
			local Amount2 = p146.weapon:GetAttribute("Amount")
			Consume:FireServer()
			local v147 = tick()
			while p146.useDebounce == true and p146.isEquipped == true do
				wait()
				if tick() - v147 > p146.clientAnimationTracks.Use.Length - 0.2 then
					break
				end
			end
			if weapon2 == p146.weapon then
				if Amount2 then
					if Amount2 - 1 > 0 then
						p146.ToolStance = "Idle"
						p146.EquipTValue = 0
						if p146.clientAnimationTracks.Use then
							p146.clientAnimationTracks.Use:Stop(0)
						end
						if p146.serverAnimationTracks.Use then
							p146.serverAnimationTracks.Use:Stop(0)
						end
						if p146.serverAnimationTracks.Equip then
							p146.serverAnimationTracks.Equip:Play(0)
						end
						if p146.viewModel then
							p146.clientAnimationTracks.Idle:Play()
							if p146.clientAnimationTracks.Equip then
								p146.clientAnimationTracks.Equip:Play(0)
							end
						end
						wait(0.35)
						if weapon2 == p146.weapon then
							p146.useDebounce = false
						end
					else
						wait(0.1)
						if weapon2 == p146.weapon then
							p146:unequip()
						end
					end
				end
				wait(0.35)
				if weapon2 == p146.weapon then
					p146.useDebounce = false
				end
			end
		end
	end,
	Defib = function(p148)
		--[[ line: 1513 | upvalues: (copy) SoundHandler, (copy) v_u_7, (copy) CurrentCamera, (copy) v_u_11, (copy) ReviveSystem]]
		if (not p148.clientAnimationTracks.Equip or (not p148.clientAnimationTracks.Equip.IsPlaying or p148.clientAnimationTracks.Equip.TimePosition > p148.clientAnimationTracks.Equip.Length * 0.5)) and p148.useDebounce == false then
			p148.useDebounce = true
			p148.MouseHeld = false
			local weapon3 = p148.weapon
			SoundHandler:PlayEquippedItem("Use", p148.character, 2)
			SoundHandler:Play(p148.worldModel.ItemRoot.Sounds.Use, p148.SoundsTemp)
			if p148.clientAnimationTracks.Use then
				p148.clientAnimationTracks.Use:Play(0.08)
			end
			if p148.serverAnimationTracks.Use then
				p148.serverAnimationTracks.Use:Play(0.08)
			end
			local Amount3 = p148.weapon:GetAttribute("Amount")
			local v149 = tick()
			local player = v_u_7:GetEstimatedCameraPosition(p148.player)
			local Unit2 = (CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * 1000 - player).Unit
			local v150 = workspace:Raycast(player, Unit2 * 10, v_u_11)
			if v150 then
				local v151 = v_u_7:FindDeepAncestor(v150.Instance, "Model")
				if v151:FindFirstChild("Humanoid") then
					ReviveSystem:InvokeServer("Defib", v151, v150.Position)
				end
			end
			while p148.useDebounce == true and p148.isEquipped == true do
				wait()
				if tick() - v149 > p148.clientAnimationTracks.Use.Length - 0.2 then
					break
				end
			end
			if weapon3 == p148.weapon then
				if Amount3 then
					if Amount3 - 1 > 0 then
						p148.ToolStance = "Idle"
						p148.EquipTValue = 0
						if p148.clientAnimationTracks.Use then
							p148.clientAnimationTracks.Use:Stop(0)
						end
						if p148.serverAnimationTracks.Use then
							p148.serverAnimationTracks.Use:Stop(0)
						end
						if p148.serverAnimationTracks.Equip then
							p148.serverAnimationTracks.Equip:Play(0)
						end
						SoundHandler:Play(p148.worldModel.ItemRoot.Sounds.Equip, p148.SoundsTemp)
						if p148.viewModel then
							p148.clientAnimationTracks.Idle:Play()
							if p148.clientAnimationTracks.Equip then
								p148.clientAnimationTracks.Equip:Play(0)
							end
						end
						wait(0.35)
						if weapon3 == p148.weapon then
							p148.useDebounce = false
						end
					else
						wait(0.1)
						if weapon3 == p148.weapon then
							warn("unequip")
							p148:unequip()
						end
					end
				end
				wait(0.35)
				if weapon3 == p148.weapon then
					p148.useDebounce = false
				end
			end
		end
	end
}
useTypes2 = { MeleeWeaponDefault = function(p_u_152)
		--[[ line: 1594 | upvalues: (copy) SoundHandler, (copy) v_u_9]]
		if p_u_152.useDebounce == false and (not p_u_152.clientAnimationTracks.Equip or (not p_u_152.clientAnimationTracks.Equip.IsPlaying or p_u_152.clientAnimationTracks.Equip.TimePosition > p_u_152.clientAnimationTracks.Equip.Length * 0.8)) then
			p_u_152.useDebounce = true
			p_u_152.MouseHeld = false
			p_u_152.sprinting = false
			p_u_152.rs_Player.Status.GameplayVariables.Sprinting:SetAttribute("Value", p_u_152.sprinting)
			local _24 = p_u_152.weapon
			local Swing = p_u_152.worldModel.ItemRoot.Sounds.Swing
			if p_u_152.worldModel.ItemRoot.Sounds:FindFirstChild("SwingPower") then
				Swing = p_u_152.worldModel.ItemRoot.Sounds.SwingPower
			end
			if Swing:GetAttribute("Delay") then
				task.delay(Swing:GetAttribute("Delay"), function()
					--[[ line: 1612 | upvalues: (ref) SoundHandler, (ref) Swing, (copy) p_u_152]]
					SoundHandler:PlayEquippedItem(Swing.Name, p_u_152.character, 2)
					SoundHandler:Play(Swing, p_u_152.SoundsTemp)
				end)
			else
				SoundHandler:PlayEquippedItem(Swing.Name, p_u_152.character, 2)
				SoundHandler:Play(Swing, p_u_152.SoundsTemp)
			end
			local Stab = p_u_152.clientAnimationTracks.Stab
			p_u_152.clientAnimationTracks.Stab:Play(0)
			p_u_152.serverAnimationTracks.Stab:Play(0)
			p_u_152.clientAnimationTracks.Use:Stop()
			p_u_152.clientAnimationTracks.UseAlt:Stop()
			p_u_152.serverAnimationTracks.Use:Stop()
			p_u_152.serverAnimationTracks.UseAlt:Stop()
			local v_u_153 = nil
			v_u_153 = Stab:GetMarkerReachedSignal("SwingEnd"):Connect(function()
				--[[ line: 1631 | upvalues: (copy) p_u_152, (ref) v_u_153]]
				p_u_152.useDebounce = false
				if p_u_152.LeftMouseDown == true then
					p_u_152.MouseHeld = true
				end
				v_u_153:Disconnect()
			end)
			local v_u_154 = nil
			v_u_154 = Stab:GetMarkerReachedSignal("HitScan"):Connect(function()
				--[[ line: 1642 | upvalues: (ref) v_u_9, (copy) p_u_152, (ref) v_u_154]]
				local _25, _26 = v_u_9:StartSwing(p_u_152.weapon, p_u_152.worldModel, p_u_152.viewModel, "PowerAttack", p_u_152.SprintStrafe)
				v_u_154:Disconnect()
			end)
		end
	end, Lighter = function(p_u_155)
		--[[ line: 1662 | upvalues: (copy) SoundHandler, (copy) ToggleAttachment]]
		if p_u_155.useDebounce == false and (not p_u_155.clientAnimationTracks.Equip or (not p_u_155.clientAnimationTracks.Equip.IsPlaying or p_u_155.clientAnimationTracks.Equip.TimePosition > p_u_155.clientAnimationTracks.Equip.Length * 0.8)) then
			p_u_155.useDebounce = true
			if p_u_155.worldModel.ItemRoot.Sounds:FindFirstChild("Toggle") then
				SoundHandler:PlayEquippedItem("Toggle", p_u_155.character, 2)
				SoundHandler:Play(p_u_155.worldModel.ItemRoot.Sounds.Toggle, p_u_155.SoundsTemp)
			end
			local weapon4 = p_u_155.weapon
			if weapon4 == p_u_155.weapon then
				local v_u_156 = not p_u_155.weapon:GetAttribute("Toggle")
				if v_u_156 then
					p_u_155.serverAnimationTracks.Open:Play()
					p_u_155.clientAnimationTracks.Open:Play()
					p_u_155.serverAnimationTracks.Opened:Play()
					p_u_155.clientAnimationTracks.Opened:Play()
				else
					p_u_155.serverAnimationTracks.Close:Play()
					p_u_155.clientAnimationTracks.Close:Play()
					p_u_155.serverAnimationTracks.Opened:Stop()
					p_u_155.clientAnimationTracks.Opened:Stop()
				end
				task.spawn(function()
					--[[ line: 1696 | upvalues: (ref) ToggleAttachment, (copy) p_u_155, (copy) v_u_156]]
					ToggleAttachment:InvokeServer(p_u_155.weapon, v_u_156)
				end)
			end
			task.wait(0.7)
			if weapon4 == p_u_155.weapon then
				p_u_155.useDebounce = false
			end
		end
	end, GrenadeDefault = function(p_u_157)
		--[[ line: 1710 | upvalues: (copy) SoundHandler, (copy) ServerProjectile, (copy) CurrentCamera]]
		if p_u_157.useDebounce == false and (not p_u_157.clientAnimationTracks.Equip.IsPlaying or p_u_157.clientAnimationTracks.Equip.TimePosition > p_u_157.clientAnimationTracks.Equip.Length * 0.8) then
			p_u_157.useDebounce = true
			p_u_157.MouseHeld = false
			local weapon5 = p_u_157.weapon
			SoundHandler:PlayEquippedItem("Use", p_u_157.character, 2)
			SoundHandler:Play(p_u_157.worldModel.ItemRoot.Sounds.Use, p_u_157.SoundsTemp)
			if p_u_157.clientAnimationTracks.UseAlt then
				p_u_157.clientAnimationTracks.UseAlt:Play()
			end
			if p_u_157.serverAnimationTracks.UseAlt then
				p_u_157.serverAnimationTracks.UseAlt:Play()
			end
			local Amount4 = p_u_157.weapon:GetAttribute("Amount")
			coroutine.wrap(function()
				--[[ line: 1725 | upvalues: (copy) p_u_157, (ref) ServerProjectile, (ref) CurrentCamera]]
				wait(p_u_157.settings.GrenadeThrowDelay)
				ServerProjectile:FireServer(CurrentCamera.CFrame.LookVector)
			end)()
			local v158 = tick()
			while p_u_157.useDebounce == true and p_u_157.isEquipped == true do
				wait()
				if tick() - v158 > p_u_157.clientAnimationTracks.UseAlt.Length - 0.15 then
					break
				end
			end
			if weapon5 == p_u_157.weapon and Amount4 - 1 > 0 then
				p_u_157.ToolStance = "Idle"
				p_u_157.EquipTValue = 0
				if p_u_157.serverAnimationTracks.Equip then
					p_u_157.serverAnimationTracks.Equip:Play(0)
				end
				if p_u_157.viewModel then
					p_u_157.clientAnimationTracks.Idle:Play()
					if p_u_157.clientAnimationTracks.Equip then
						p_u_157.clientAnimationTracks.Equip:Play(0)
					end
					SoundHandler:PlayEquippedItem("Equip", p_u_157.character, 2)
					SoundHandler:Play(p_u_157.worldModel.ItemRoot.Sounds.Equip, p_u_157.SoundsTemp)
				end
				wait(0.35)
				if weapon5 == p_u_157.weapon then
					p_u_157.useDebounce = false
				end
			end
			wait(0.1)
			p_u_157:unequip()
		end
	end }
local t3 = { RangedWeaponDefault = function(p_u_159)
		--[[ line: 1769 | upvalues: (copy) CurrentCamera]]
		if (p_u_159.useDebounce == true or p_u_159.weapon:GetAttribute("NeedsCycle")) and (p_u_159.FireModes[p_u_159.FireModeIndex] == "Bolt Action" and not p_u_159.clientAnimationTracks.Bolt.IsPlaying) then
			local weapon6 = p_u_159.weapon
			local EquipId = p_u_159.rs_Player.Status.GameplayVariables:GetAttribute("EquipId")
			if p_u_159.clientAnimationTracks.Use.IsPlaying then
				wait((p_u_159.clientAnimationTracks.Use.Length - p_u_159.clientAnimationTracks.Use.TimePosition) / 1.4)
			end
			if weapon6 ~= p_u_159.weapon then
				return
			end
			if EquipId ~= p_u_159.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
				return
			end
			if p_u_159.useDebounce == true and not p_u_159.clientAnimationTracks.Bolt.IsPlaying then
				if p_u_159.clientAnimationTracks.Bolt then
					p_u_159.clientAnimationTracks.Bolt:Play()
				end
				if p_u_159.serverAnimationTracks.Bolt then
					p_u_159.serverAnimationTracks.Bolt:Play()
				end
				wait(p_u_159.settings.CycleTiming[1])
				if weapon6 ~= p_u_159.weapon then
					return
				end
				if EquipId ~= p_u_159.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
					return
				end
				local v_u_160 = nil
				task.spawn(function()
					--[[ line: 574 | upvalues: (copy) p_u_159, (copy) v_u_160]]
					local viewModel2 = p_u_85.viewModel
					if p_u_85.settings.EjectionDelay then
						wait(p_u_85.settings.EjectionDelay)
					end
					if viewModel2 == p_u_85.viewModel and p_u_85.viewModel.Parent then
						local EjectionPort = p_u_85.viewModel.Item:FindFirstChild("EjectionPort")
						if EjectionPort then
							if v_u_127 then
								local v128 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(v_u_127)
								if v128:FindFirstChild("Casing") then
									EjectionPort.Casing.Texture = v128.Casing.Texture
								end
							end
							EjectionPort.Casing:Emit(1)
						end
					end
				end)
				wait(p_u_159.settings.CycleTiming[2])
				if weapon6 ~= p_u_159.weapon then
					return
				end
				if EquipId ~= p_u_159.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
					return
				end
				p_u_159.useDebounce = false
				p_u_159.weapon:SetAttribute("NeedsCycle", nil)
				if p_u_159.clientAnimationTracks.Bolt then
					p_u_159.clientAnimationTracks.Bolt:Stop()
				end
				if p_u_159.serverAnimationTracks.Bolt then
					p_u_159.serverAnimationTracks.Bolt:Stop()
				end
				if p_u_159.RightMouseDown then
					p_u_159:aim(true)
				end
			end
		end
	end }
local t4 = { magazine = function(p_u_161, p162)
		--[[ line: 1821 | upvalues: (copy) v_u_7, (copy) v_u_6, (copy) SoundHandler, (copy) TweenService, (copy) SwapMagazine, (copy) Reload, (copy) UpdateBulletsList]]
		if not p_u_161.clientAnimationTracks.Equip or (not p_u_161.clientAnimationTracks.Equip.IsPlaying or p_u_161.clientAnimationTracks.Equip.TimePosition > p_u_161.clientAnimationTracks.Equip.Length * 0.8) then
			if p_u_161.useDebounce then
				return
			end
			p162 = p162
			local v163 = p162 and p162:GetAttribute("LoadedAmmo") or 0
			local v_u_164
			if game.ReplicatedFirst.ServerInfo:GetAttribute("GameMode") == "GunGame" then
				v_u_164 = v_u_7:FindFirstChildOfSlotType(p_u_161.weapon.Attachments, "Magazine")
				if v_u_164 then
					v163 = 1 / 0
				else
					v_u_164 = p162
				end
			end
			if not v_u_164 then
				local CompatibleMagazines = p_u_161.itemProperties.CompatibleMagazines
				local v165 = p_u_161.rs_Player.Inventory:GetChildren()
				for v166 = 1, #v165 do
					if v165[v166]:FindFirstChild("Inventory") then
						local v167 = v165[v166].Inventory:GetChildren()
						for v168 = 1, #v167 do
							if CompatibleMagazines:GetAttribute(v167[v168].Name) and (v163 < v167[v168]:GetAttribute("LoadedAmmo") or v_u_164 == nil) then
								v_u_164 = v167[v168]
								v163 = v_u_164:GetAttribute("LoadedAmmo")
							end
						end
					end
				end
			end
			if v_u_164 and v163 > 0 then
				if p_u_161.Scope or p_u_161.sight and p_u_161.sight:GetAttribute("NoReloadAim") then
					p_u_161:aim(false)
				end
				local v169 = v_u_7:FindFirstChildOfSlotType(p_u_161.weapon.Attachments, "Magazine")
				v_u_6:SetZoomTarget(1, p_u_161.Scope, 0.1)
				p_u_161:ambientBoostUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
				p_u_161:thermalVisionUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
				p_u_161.reloading = true
				if p_u_161.clientAnimationTracks.Use then
					p_u_161.clientAnimationTracks.Use:Stop()
				end
				if p_u_161.serverAnimationTracks.Use then
					p_u_161.serverAnimationTracks.Use:Stop()
				end
				if p_u_161.clientAnimationTracks.UseAiming then
					p_u_161.clientAnimationTracks.UseAiming:Stop()
				end
				if p_u_161.serverAnimationTracks.UseAiming then
					p_u_161.serverAnimationTracks.UseAiming:Stop()
				end
				local v170 = 0.1
				local v171 = 0
				local v172 = 0.1
				local v173 = 0
				local ReloadFadeOut = p_u_161.settings.ReloadFadeOut
				local ReloadFadeOutTimePos = p_u_161.settings.ReloadFadeOutTimePos
				local SlideReleaseTimePos = p_u_161.settings.SlideReleaseTimePos
				if v169 then
					local Name4 = p_u_161.viewModel.Item.Attachments.Magazine:FindFirstChild(v169.Name)
					if Name4 then
						local LoadedAmmo2 = v169:GetAttribute("LoadedAmmo")
						if Name4:FindFirstChild("Bullet1") then
							if LoadedAmmo2 > 0 then
								Name4.Bullet1.Transparency = 0
							else
								Name4.Bullet1.Transparency = 1
							end
						end
						if Name4:FindFirstChild("Bullet2") then
							if LoadedAmmo2 > 1 then
								Name4.Bullet2.Transparency = 0
							else
								Name4.Bullet2.Transparency = 1
							end
						end
						if Name4:FindFirstChild("AmmoBelt") then
							for _27, v174 in pairs((Name4.AmmoBelt:GetChildren())) do
								if v174:GetAttribute("Order") then
									local v175 = LoadedAmmo2 <= v174:GetAttribute("Order") and 1 or 0
									for _28, v176 in pairs((v174:GetChildren())) do
										v176.Transparency = v175
									end
								end
							end
						end
					end
				else
					if not p_u_161.clientAnimationTracks.ReloadNoMag then
						v170 = p_u_161.settings.ReloadFadeIn
						v171 = p_u_161.settings.ReloadFadeInTimePos
					end
					if not p_u_161.serverAnimationTracks.ReloadNoMag then
						v172 = p_u_161.settings.ReloadFadeIn
						v173 = p_u_161.settings.ReloadFadeInTimePos
					end
				end
				if p_u_161.clientAnimationTracks.BoltLock then
					coroutine.wrap(function()
						--[[ line: 1928 | upvalues: (copy) ReloadFadeOutTimePos, (copy) SlideReleaseTimePos, (copy) p_u_161]]
						wait(ReloadFadeOutTimePos + SlideReleaseTimePos)
						p_u_161.clientAnimationTracks.HammerLock:Stop(0.01)
						p_u_161.clientAnimationTracks.BoltLock:Stop(0.02)
					end)()
				end
				if p_u_161.clientAnimationTracks.BoltOpen then
					coroutine.wrap(function()
						--[[ line: 1937 | upvalues: (copy) ReloadFadeOutTimePos, (copy) SlideReleaseTimePos, (copy) p_u_161]]
						wait(ReloadFadeOutTimePos + SlideReleaseTimePos)
						p_u_161.clientAnimationTracks.BoltOpen:Play(0.02)
					end)()
				end
				if p_u_161.clientAnimationTracks.Empty then
					coroutine.wrap(function()
						--[[ line: 1944 | upvalues: (copy) ReloadFadeOutTimePos, (copy) p_u_161]]
						wait(ReloadFadeOutTimePos)
						p_u_161.clientAnimationTracks.Empty:Stop(0.01)
						if p_u_161.serverAnimationTracks.Empty then
							p_u_161.serverAnimationTracks.Empty:Stop(0.01)
						end
					end)()
				end
				local v177
				if p_u_161.Bullets == 0 then
					if v169 then
						SoundHandler:PlayEquippedItem("ReloadSoundChamber", p_u_161.character, 2)
						SoundHandler:Play(p_u_161.worldModel.ItemRoot.Sounds.ReloadSoundChamber, p_u_161.SoundsTemp)
						v177 = 2
					else
						SoundHandler:PlayEquippedItem("ReloadSoundNoMag", p_u_161.character, 2)
						SoundHandler:Play(p_u_161.worldModel.ItemRoot.Sounds.ReloadSoundNoMag, p_u_161.SoundsTemp)
						v177 = 3
					end
				else
					coroutine.wrap(function()
						--[[ line: 1954 | upvalues: (copy) ReloadFadeOutTimePos, (copy) p_u_161, (copy) ReloadFadeOut]]
						wait(ReloadFadeOutTimePos)
						if not p_u_161.clientAnimationTracks.Reload then
							p_u_161.clientAnimationTracks.ReloadChamber:Stop(ReloadFadeOut)
						end
						if not p_u_161.serverAnimationTracks.Reload then
							p_u_161.serverAnimationTracks.ReloadChamber:Stop(ReloadFadeOut)
						end
					end)()
					SoundHandler:PlayEquippedItem("ReloadSound", p_u_161.character, 2)
					SoundHandler:Play(p_u_161.worldModel.ItemRoot.Sounds.ReloadSound, p_u_161.SoundsTemp)
					v177 = 1
				end
				if p_u_161.clientAnimationTracks.ReloadChamber then
					local ReloadChamber = p_u_161.clientAnimationTracks.ReloadChamber
					local ReloadChamber2 = p_u_161.serverAnimationTracks.ReloadChamber
					if p_u_161.Bullets ~= 0 then
						if p_u_161.clientAnimationTracks.Reload then
							ReloadChamber = p_u_161.clientAnimationTracks.Reload
						end
						if p_u_161.serverAnimationTracks.Reload then
							ReloadChamber2 = p_u_161.serverAnimationTracks.Reload
						end
					end
					if not v169 then
						if p_u_161.clientAnimationTracks.ReloadNoMag then
							ReloadChamber = p_u_161.clientAnimationTracks.ReloadNoMag
						end
						if p_u_161.serverAnimationTracks.ReloadNoMag then
							ReloadChamber2 = p_u_161.serverAnimationTracks.ReloadNoMag
						end
					end
					ReloadChamber:Play(v170)
					ReloadChamber.TimePosition = v171
					ReloadChamber2:Play(v172)
					ReloadChamber2.TimePosition = v173
					p_u_161.actionId = math.random(-1000000, 1000000)
					local _29 = p_u_161.actionId
					if p_u_161.leftHandGrip_ik then
						task.spawn(function()
							--[[ line: 2010 | upvalues: (ref) ReloadChamber, (ref) TweenService, (copy) p_u_161]]
							local Length = ReloadChamber.Length
							local v178 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
							TweenService:Create(p_u_161.leftHandGrip_ik, v178, { Weight = 0 }):Play()
							task.wait(Length - 0.4)
							local _30 = ReloadChamber.Length
							local v179 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
							TweenService:Create(p_u_161.leftHandGrip_ik, v179, { Weight = 1 }):Play()
						end)
					end
					local v_u_180 = nil
					v_u_180 = ReloadChamber:GetMarkerReachedSignal("NewMag"):Connect(function(_31)
						--[[ line: 2026 | upvalues: (ref) SwapMagazine, (copy) p_u_161, (ref) v_u_164, (ref) v_u_180]]
						SwapMagazine(p_u_161, v_u_164.Name, v_u_164)
						v_u_180:Disconnect()
					end)
				end
				Reload:InvokeServer(nil, v177, v_u_164)
				UpdateBulletsList(p_u_161)
				local v181 = v_u_7:FindFirstChildOfSlotType(p_u_161.weapon.Attachments, "Magazine")
				if v181 then
					p_u_161.MaxAmmo = v181.Value.ItemProperties:GetAttribute("MaxLoadedAmmo")
				end
				if p_u_161.reloading == true then
					p_u_161.reloading = false
					p_u_161.RecoilPatternPos = 0
					wait(0.2)
					if p_u_161.RightMouseDown then
						p_u_161:aim(true)
					end
				end
			end
		end
	end, loadByHand = function(p_u_182, p183)
		--[[ line: 2080 | upvalues: (copy) v_u_6, (copy) TweenService, (copy) SoundHandler, (copy) Reload, (copy) UpdateBulletsList]]
		if not p_u_182.clientAnimationTracks.Equip or (not p_u_182.clientAnimationTracks.Equip.IsPlaying or p_u_182.clientAnimationTracks.Equip.TimePosition > p_u_182.clientAnimationTracks.Equip.Length * 0.8) then
			if p_u_182.useDebounce then
				return
			end
			local v184 = p_u_182.MaxAmmo - p_u_182.Bullets
			if v184 > 0 then
				local v_u_185 = 0
				local v_u_186 = p183
				if not v_u_186 and p_u_182.itemProperties:GetAttribute("PreferredAmmo") then
					local CompatibleAmmo = p_u_182.itemProperties.CompatibleAmmo
					local v187 = p_u_182.rs_Player.Inventory:GetChildren()
					for v188 = 1, #v187 do
						if v187[v188]:FindFirstChild("Inventory") then
							local v189 = v187[v188].Inventory:GetChildren()
							for v190 = 1, #v189 do
								if CompatibleAmmo:GetAttribute(v189[v190].Name) and p_u_182.itemProperties:GetAttribute("PreferredAmmo") == v189[v190].Name then
									v_u_185 = v_u_185 + v189[v190]:GetAttribute("Amount")
									v_u_186 = v189[v190]
								end
							end
						end
					end
				end
				if v_u_186 then
					v_u_185 = v_u_186:GetAttribute("Amount")
				else
					local CompatibleAmmo2 = p_u_182.itemProperties.CompatibleAmmo
					local v191 = p_u_182.rs_Player.Inventory:GetChildren()
					for v192 = 1, #v191 do
						if v191[v192]:FindFirstChild("Inventory") then
							local v193 = v191[v192].Inventory:GetChildren()
							for v194 = 1, #v193 do
								if CompatibleAmmo2:GetAttribute(v193[v194].Name) then
									v_u_185 = v_u_185 + v193[v194]:GetAttribute("Amount")
									v_u_186 = v193[v194]
								end
							end
						end
					end
				end
				if game.ReplicatedFirst.ServerInfo:GetAttribute("GameMode") == "GunGame" then
					local DefaultAmmo = game.ReplicatedStorage.RangedWeapons[p_u_182.weapon.Value.Name]:GetAttribute("DefaultAmmo")
					v_u_186 = game.ReplicatedStorage.ItemsList:FindFirstChild(DefaultAmmo)
					v_u_185 = 1 / 0
				end
				if p_u_182.MaxAmmo < v_u_185 then
					v_u_185 = p_u_182.MaxAmmo
				end
				if v_u_186 then
					if v184 == 1 then
						if p_u_182.clientAnimationTracks.Empty then
							p_u_182.clientAnimationTracks.Empty:Stop()
						end
						if p_u_182.serverAnimationTracks.Empty then
							p_u_182.serverAnimationTracks.Empty:Stop()
						end
					end
					if p_u_182.viewModel.Item:FindFirstChild("Bullets") then
						if p_u_182.viewModel.Item.Bullets:FindFirstChild("Bullet1") then
							p_u_182.viewModel.Item.Bullets.Bullet1.Transparency = 0
						end
						if p_u_182.viewModel.Item.Bullets:FindFirstChild("Bullet2") then
							p_u_182.viewModel.Item.Bullets.Bullet2.Transparency = 0
						end
					end
					local Name5 = game.ReplicatedStorage.AmmoTypes:FindFirstChild(v_u_186.Name)
					if Name5:FindFirstChild("Ammo") then
						if p_u_182.viewModel.Item:FindFirstChild("Ammo") then
							if p_u_182.viewModel.Item.Ammo:FindFirstChild("SurfaceAppearance") then
								p_u_182.viewModel.Item.Ammo:FindFirstChild("SurfaceAppearance"):Destroy()
							end
							Name5.Ammo.SurfaceAppearance:Clone().Parent = p_u_182.viewModel.Item.Ammo
						end
						if p_u_182.viewModel.Item:FindFirstChild("Ammo1") then
							if p_u_182.viewModel.Item.Ammo1:FindFirstChild("SurfaceAppearance") then
								p_u_182.viewModel.Item.Ammo1:FindFirstChild("SurfaceAppearance"):Destroy()
							end
							Name5.Ammo.SurfaceAppearance:Clone().Parent = p_u_182.viewModel.Item.Ammo1
						end
						if p_u_182.viewModel.Item:FindFirstChild("Ammo2") then
							if p_u_182.viewModel.Item.Ammo2:FindFirstChild("SurfaceAppearance") then
								p_u_182.viewModel.Item.Ammo2:FindFirstChild("SurfaceAppearance"):Destroy()
							end
							Name5.Ammo.SurfaceAppearance:Clone().Parent = p_u_182.viewModel.Item.Ammo2
						end
					end
					v_u_6:SetZoomTarget(1, p_u_182.Scope, 0.1)
					p_u_182:ambientBoostUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
					p_u_182:thermalVisionUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
					if p_u_182.Scope or p_u_182.sight and p_u_182.sight:GetAttribute("NoReloadAim") then
						p_u_182:aim(false)
					end
					p_u_182.reloading = true
					if p_u_182.clientAnimationTracks.Use then
						p_u_182.clientAnimationTracks.Use:Stop()
					end
					if p_u_182.serverAnimationTracks.Use then
						p_u_182.serverAnimationTracks.Use:Stop()
					end
					if p_u_182.clientAnimationTracks.UseAiming then
						p_u_182.clientAnimationTracks.UseAiming:Stop()
					end
					if p_u_182.serverAnimationTracks.UseAiming then
						p_u_182.serverAnimationTracks.UseAiming:Stop()
					end
					local v_u_195 = 0
					if p_u_182.clientAnimationTracks.ReloadChamber then
						local ReloadChamber3 = p_u_182.clientAnimationTracks.ReloadChamber
						local ReloadChamber4 = p_u_182.serverAnimationTracks.ReloadChamber
						if p_u_182.Bullets ~= 0 then
							if p_u_182.clientAnimationTracks.Reload then
								ReloadChamber3 = p_u_182.clientAnimationTracks.Reload
							end
							if p_u_182.serverAnimationTracks.Reload then
								ReloadChamber4 = p_u_182.serverAnimationTracks.Reload
							end
						end
						ReloadChamber3:Play()
						ReloadChamber4:Play()
						p_u_182.actionId = math.random(-1000000, 1000000)
						local _32 = p_u_182.actionId
						if p_u_182.leftHandGrip_ik then
							task.spawn(function()
								--[[ line: 2215 | upvalues: (ref) ReloadChamber3, (ref) TweenService, (copy) p_u_182]]
								local Length2 = ReloadChamber3.Length
								local v196 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
								TweenService:Create(p_u_182.leftHandGrip_ik, v196, { Weight = 0 }):Play()
								task.wait(Length2 - 0.4)
								local _33 = ReloadChamber3.Length
								local v197 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
								TweenService:Create(p_u_182.leftHandGrip_ik, v197, { Weight = 1 }):Play()
							end)
						end
						if p_u_182.worldModel.ItemRoot.Sounds:FindFirstChild("ReloadSound") then
							SoundHandler:PlayEquippedItem("ReloadSound", p_u_182.character, 2)
							SoundHandler:Play(p_u_182.worldModel.ItemRoot.Sounds.ReloadSound, p_u_182.SoundsTemp)
						end
						local v_u_198 = nil
						v_u_198 = ReloadChamber3:GetMarkerReachedSignal("BulletIn"):Connect(function(p199)
							--[[ line: 2236 | upvalues: (ref) Reload, (ref) v_u_186, (ref) UpdateBulletsList, (copy) p_u_182, (ref) v_u_195, (ref) v_u_185, (ref) v_u_198]]
							for _34 = 1, p199 and tonumber(p199) or 1 do
								Reload:InvokeServer(nil, 1, v_u_186)
								UpdateBulletsList(p_u_182)
								v_u_195 = v_u_195 + 1
							end
							if v_u_185 <= p_u_182.Bullets and v_u_195 ~= p_u_182.MaxAmmo or p_u_182.cancellingReload == true then
								p_u_182.reloading = false
								p_u_182.cancellingReload = false
								if p_u_182.clientAnimationTracks.Empty then
									p_u_182.clientAnimationTracks.Empty:Stop()
								end
								if p_u_182.serverAnimationTracks.Empty then
									p_u_182.serverAnimationTracks.Empty:Stop()
								end
								p_u_182.clientAnimationTracks.ReloadChamber.TimePosition = p_u_182.settings.ReloadFadeOutTimePos
								p_u_182.serverAnimationTracks.ReloadChamber.TimePosition = p_u_182.settings.ReloadFadeOutTimePos
								p_u_182.RecoilPatternPos = 0
								if p_u_182.RightMouseDown then
									p_u_182:aim(true)
								end
								v_u_198:Disconnect()
							end
						end)
						local v_u_202 = ReloadChamber3:GetMarkerReachedSignal("LoopTo"):Connect(function(p200)
							--[[ line: 2266 | upvalues: (copy) p_u_182, (ref) v_u_185, (ref) v_u_195]]
							local v201 = p200 and tonumber(p200) or 1
							if p_u_182.Bullets < v_u_185 and (v_u_195 ~= p_u_182.MaxAmmo and not p_u_182.cancellingReload) then
								p_u_182.clientAnimationTracks.ReloadChamber.TimePosition = v201
								p_u_182.serverAnimationTracks.ReloadChamber.TimePosition = v201
							end
						end)
						coroutine.wrap(function()
							--[[ line: 2277 | upvalues: (ref) ReloadChamber3, (copy) p_u_182, (ref) ReloadChamber4, (ref) v_u_198, (ref) v_u_202]]
							ReloadChamber3.Ended:Wait()
							if p_u_182.reloading then
								p_u_182.reloading = false
								p_u_182.cancellingReload = false
								if p_u_182.clientAnimationTracks.Empty then
									p_u_182.clientAnimationTracks.Empty:Stop()
								end
								if p_u_182.serverAnimationTracks.Empty then
									p_u_182.serverAnimationTracks.Empty:Stop()
								end
								ReloadChamber3:Stop()
								ReloadChamber4:Stop()
								p_u_182.RecoilPatternPos = 0
								if p_u_182.RightMouseDown then
									p_u_182:aim(true)
								end
								v_u_198:Disconnect()
								v_u_202:Disconnect()
							end
						end)()
					end
				end
			end
		end
	end }
StanceTypes = { Standing = function(p203)
		--[[ line: 2314 | upvalues: (copy) TweenService, (copy) UpdateCrouch]]
		local v204 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		TweenService:Create(p203.crouchTweenValue, v204, { Value = 0 }):Play()
		UpdateCrouch:FireServer(false)
	end, Crouching = function(p205)
		--[[ line: 2321 | upvalues: (copy) TweenService, (copy) UpdateCrouch]]
		local v206 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		TweenService:Create(p205.crouchTweenValue, v206, { Value = -1 }):Play()
		UpdateCrouch:FireServer(true)
	end, Proning = function(_35)
		--[[ line: 2329 | upvalues: none]]
	end }
if ... then
	for _36 = nil, nil do
		return
	end
	for _37 = nil, nil do
		break
	end
end
function t.new(p207, p208)
	--[[ line: 2340 | upvalues: (copy) CurrentCamera, (copy) v_u_3, (copy) v_u_2, (copy) v_u_6, (copy) t, (copy) UpdateBulletsList, (copy) UserInputService]]
	local t5 = {
		player = p207,
		rs_Player = game.ReplicatedStorage.Players:WaitForChild(p207.Name),
		character = p208,
		viewModel = nil,
		hrp = p208.HumanoidRootPart,
		humanoid = p208.Humanoid
	}
	t5.humanoid.AutoJumpEnabled = false
	t5.mouse = t5.player:GetMouse()
	t5.GameplayVariables = t5.rs_Player.Status.GameplayVariables
	t5.LegFracture = t5.GameplayVariables.LegFracture
	t5.rs_Vehicle = t5.GameplayVariables.Vehicle
	t5.GameplaySettings = t5.rs_Player.Settings.GameplaySettings
	t5.VisualSettings = t5.rs_Player.Settings.VisualSettings
	t5.baseFov = t5.GameplaySettings:GetAttribute("DefaultFOV")
	t5.GameplaySettings:GetAttributeChangedSignal("DefaultFOV"):Connect(function()
		--[[ line: 2359 | upvalues: (copy) t5, (ref) CurrentCamera]]
		t5.baseFov = t5.GameplaySettings:GetAttribute("DefaultFOV")
		CurrentCamera.FieldOfView = t5.baseFov
	end)
	t5.mainGui = p207.PlayerGui.MainGui
	t5.menuGui = p207.PlayerGui:FindFirstChild("MenuGui")
	t5.noInsetGui = p207.PlayerGui:WaitForChild("NoInsetGui")
	t5.mobileButtons = t5.noInsetGui.MainFrame.MobileButtons
	t5.SoundsTemp = t5.mainGui.TempSound
	t5.CancelTables = {}
	local CancelTables = v_u_3.UniversalTable.CancelTables
	for v209 = 1, #CancelTables do
		if t5.mainGui.MainFrame:FindFirstChild(CancelTables[v209]) then
			local CancelTables2 = t5.CancelTables
			local MainFrame = t5.mainGui.MainFrame
			local v210 = CancelTables[v209]
			table.insert(CancelTables2, (MainFrame:FindFirstChild(v210)))
		end
		if t5.menuGui and t5.menuGui.MainFrame:FindFirstChild(CancelTables[v209]) then
			local CancelTables3 = t5.CancelTables
			local MainFrame2 = t5.menuGui.MainFrame
			local v211 = CancelTables[v209]
			table.insert(CancelTables3, (MainFrame2:FindFirstChild(v211)))
		end
	end
	t5.crouchTweenValue = Instance.new("NumberValue")
	t5.isAiming = false
	t5.character:SetAttribute("isAiming", false)
	t5.isEquipped = false
	t5.equipping = false
	t5.firedInRow = 0
	t5.jumpDebounce = false
	t5.equipAttemptId = 0
	t5.movementModifier = 0
	t5.RecoilPatternLastTick = tick()
	t5.weaponOffSet = CFrame.new()
	t5.sprintOffSet = Vector3.new()
	t5.swayMult = 0.18
	t5.FrameRateSync = 0
	t5.HorizontalVelocityDelta = 0
	t5.horizontalVelocityTime = 0
	t5.timeNow = 0
	t5.timeTotal = 0
	t5.sprintStart = 0
	t5.actionId = 0
	t5.ActionButtonHeld = false
	t5.AltActionButtonHeld = false
	t5.SprintButtonHeld = false
	t5.lastSpeed = 0
	t5.lastJumpHeight = 0
	t5.lastJumpTime = 0
	t5.lastStumbleTime = 0
	t5.horizontalVelocity = 0
	t5.sprinting = false
	t5.stance = "Standing"
	t5.lastStance = "Standing"
	t5.lean = 0
	t5.aimingLeanRotation = 0
	t5.leftHandGrip_ik = nil
	t5.DefaultWalkSpeed = 10
	t5.LaserUpdateHz = 0.016666666666666666
	t5.LastLaserUpdate = 0
	t5.characterAnimations = {}
	t5.humanoid:WaitForChild("Animator")
	t5.characterAnimations.LeaningBlend = t5.humanoid.Animator:LoadAnimation(script.Animations.LeaningBlend)
	t5.clientAnimationTracks = {}
	t5.serverAnimationTracks = {}
	t5.Connections = {}
	t5.Emitter = nil
	t5.tweens = {}
	t5.springs = {}
	t5.springs.walkCycle = v_u_2.create()
	t5.springs.gunSway = v_u_2.create()
	t5.springs.sprintCycle = v_u_2.create()
	t5.springs.sway = v_u_2.create(nil, 15, 100, 4, 4)
	t5.springs.strafeTilt = v_u_2.create()
	t5.springs.jumpTilt = v_u_2.create(nil, 5, 90, 3, 4)
	t5.springs.jumpCameraTilt = v_u_2.create(nil, 5, 90, 3, 4)
	t5.springs.recoilPos = v_u_2.create(nil, 5, 75, 3.5, 5)
	t5.springs.recoilRot = v_u_2.create(nil, 5, 35, 3.5, 3)
	t5.springs.cameraRecoil = v_u_2.create(nil, 5, 100, 3.5, 6)
	t5.springs.leanAlpha = v_u_2.create()
	t5.springs.wallTouchTilt = v_u_2.create()
	t5.lerpValues = {}
	t5.lerpValues.sprint = Instance.new("NumberValue")
	CurrentCamera.FieldOfView = t5.baseFov
	v_u_6:SetZoomTarget(1, t5.Scope, 0.3)
	t:ambientBoostUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
	t:thermalVisionUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
	t5.swayDeadzone = Vector2.new(0.05, 0.05)
	t5.swayDeadzoneTarget = Vector2.new(0, 0)
	script.Binds.AdjustBullets.Event:Connect(function(p212, _38)
		--[[ line: 2497 | upvalues: (copy) t5, (ref) UpdateBulletsList]]
		if t5.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") == p212 then
			UpdateBulletsList(t5)
		end
	end)
	t5.character.DescendantAdded:Connect(function(p_u_213)
		--[[ line: 2503 | upvalues: none]]
		if InvisibleDescentants[p_u_213.ClassName] then
			p_u_213.Enabled = false
			p_u_213:GetPropertyChangedSignal("Enabled"):Connect(function()
				--[[ line: 2506 | upvalues: (copy) p_u_213]]
				p_u_213.Enabled = false
			end)
		end
	end)
	for _39, v_u_214 in pairs((t5.character:GetDescendants())) do
		if InvisibleDescentants[v_u_214.ClassName] then
			v_u_214.Enabled = false
			v_u_214:GetPropertyChangedSignal("Enabled"):Connect(function()
				--[[ line: 2514 | upvalues: (copy) v_u_214]]
				v_u_214.Enabled = false
			end)
		end
	end
	UserInputService.InputBegan:Connect(function(p215)
		--[[ line: 2520 | upvalues: (copy) t5]]
		if p215.KeyCode == Enum.KeyCode.Space or p215.KeyCode == Enum.KeyCode.ButtonA then
			while t5.humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and (not t5.jumpDebounce and t5.humanoid.JumpHeight > 0) do
				task.wait()
			end
			t5.jumpDebounce = true
		end
	end)
	UserInputService.InputEnded:Connect(function(p216)
		--[[ line: 2529 | upvalues: (copy) t5]]
		if p216.KeyCode == Enum.KeyCode.Space or p216.KeyCode == Enum.KeyCode.ButtonA then
			task.wait()
			t5.jumpDebounce = false
		end
	end)
	local v217 = workspace.Camera:GetChildren()
	for v218 = 1, #v217 do
		if v217[v218].Name == "ViewModel" then
			v217[v218]:Destroy()
		end
	end
	local v219 = fps_mt
	return setmetatable(t5, v219)
end
function t.updateSway(p220, p221, p222, _40)
	--[[ line: 2556 | upvalues: none]]
	local FrameRateSync = p220.FrameRateSync
	math.clamp(FrameRateSync, 0.05, 5)
	local v223 = p220.isAiming and p221 * p220.swayMult / 3 or p221 * p220.swayMult
	local v224 = math.rad(v223)
	local v225 = p220.isAiming and p222 * p220.swayMult / 3 or p222 * p220.swayMult
	local v226 = math.rad(v225)
	local v227
	if p220.isAiming or p220.ToolStance == "Aim" then
		p220.swayDeadzoneTarget = Vector2.new(0, 0)
		v227 = v224
	else
		local v228 = p220.swayDeadzoneTarget.X + v224
		local v229 = p220.swayDeadzoneTarget.Y + v226
		if p220.swayDeadzone.X < v228 then
			v227 = v228 - p220.swayDeadzone.X
			v228 = p220.swayDeadzone.X
		elseif v228 < -p220.swayDeadzone.X then
			v227 = v228 + p220.swayDeadzone.X
			v228 = -p220.swayDeadzone.X
		else
			v227 = v224
		end
		if p220.swayDeadzone.Y < v229 then
			v226 = v229 - p220.swayDeadzone.Y
			v229 = p220.swayDeadzone.Y
		elseif v229 < -p220.swayDeadzone.Y then
			v226 = v229 + p220.swayDeadzone.Y
			v229 = -p220.swayDeadzone.Y
		end
		p220.swayDeadzoneTarget = Vector2.new(v228, v229)
	end
	local sway = p220.springs.sway
	local v230 = p220.swayDeadzoneTarget.X + v227
	local v231 = p220.swayDeadzoneTarget.Y + v226
	sway.Target = Vector3.new(v230, v231, v224)
end
function t.updateClient(p_u_232, p233)
	--[[ line: 2594 | upvalues: (copy) v_u_7, (copy) GuiService, (copy) MovementSpeed, (copy) TweenService, (copy) v_u_6, (copy) WallCollision, (copy) CurrentCamera]]
	if v_u_7:IsPlayerAlive(p_u_232.player) then
		local v234 = p233 * 60
		p_u_232.FrameRateSync = v234
		if p233 > 0.199 then
			warn("large delta time view model render frame skipped", p233)
			return
		end
		local v235
		if p_u_232.humanoid.FloorMaterial == Enum.Material.Air then
			v235 = p_u_232.humanoid:GetState() == Enum.HumanoidStateType.Swimming
		else
			v235 = true
		end
		p_u_232.onGround = v235
		p_u_232.velocity = p_u_232.hrp.AssemblyLinearVelocity
		p_u_232.verticalVelocity = p_u_232.velocity.Y
		p_u_232.horizontalVelocity = Vector2.new(p_u_232.velocity.X, p_u_232.velocity.Z).Magnitude
		p_u_232.moveDirection = p_u_232.humanoid.MoveDirection
		p_u_232.strafeDirection = -p_u_232.hrp.CFrame.rightVector:Dot(p_u_232.moveDirection)
		p_u_232.SprintStrafe = p_u_232.character:GetAttribute("AltLook") and -1 or -p_u_232.hrp.CFrame.lookVector:Dot(p_u_232.moveDirection)
		p_u_232.horizontalVelocityTime = p_u_232.horizontalVelocityTime + v234 * p_u_232.horizontalVelocity * 0.01
		p_u_232.timeNow = p_u_232.timeNow + p233
		p_u_232.timeTotal = p_u_232.timeTotal + p233
		local ReducedMotionEnabled = GuiService.ReducedMotionEnabled
		p_u_232.modifierMovement = p_u_232.ToolStance == "Ready" and 0.014 or 0.05
		MovementSpeed(p_u_232)
		if p_u_232.rs_Vehicle.CurrentSeat.Value then
			p_u_232:changeLean(0, true)
			if p_u_232.stance ~= "Standing" then
				p_u_232:changeStance("Standing", true)
			end
		end
		if p_u_232.stance ~= p_u_232.lastStance then
			StanceTypes[p_u_232.stance](p_u_232)
			p_u_232.lastStance = p_u_232.stance
		end
		local strafeTilt = p_u_232.springs.strafeTilt
		local v236 = (p_u_232.isAiming and 0.2 or 1) * v234
		local v237 = p_u_232.strafeDirection * 0.05
		strafeTilt:shove(v236 * Vector3.new(v237))
		local jumpTilt = p_u_232.springs.jumpTilt
		local v238
		if p_u_232.onGround then
			v238 = 0
		elseif p_u_232.verticalVelocity > 5 then
			v238 = -0.03
		else
			v238 = p_u_232.verticalVelocity < -5 and 0.03 or 0
		end
		jumpTilt:shove(Vector3.new(v238) * v234)
		local v239 = p_u_232.humanoid:GetState()
		if v239 ~= Enum.HumanoidStateType.Climbing and v239 ~= Enum.HumanoidStateType.Swimming then
			local jumpCameraTilt = p_u_232.springs.jumpCameraTilt
			local v240
			if p_u_232.onGround then
				v240 = 0
			elseif p_u_232.verticalVelocity > 5 then
				v240 = -0.03
			else
				v240 = p_u_232.verticalVelocity < -5 and 0.03 or 0
			end
			jumpCameraTilt:shove(Vector3.new(v240) * v234)
		end
		if p_u_232.GameplayVariables.Sprinting:GetAttribute("Value") and p_u_232.SprintStrafe < -0.35 then
			if not p_u_232.tweens.sprintTransitionIn then
				if p_u_232.tweens.sprintTransitionOut then
					p_u_232.tweens.sprintTransitionOut:Cancel()
					p_u_232.tweens.sprintTransitionOut = nil
				end
				local v241 = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				p_u_232.tweens.sprintTransitionIn = TweenService:Create(p_u_232.lerpValues.sprint, v241, { Value = 1 })
				p_u_232.tweens.sprintTransitionIn:Play()
			end
		elseif not p_u_232.tweens.sprintTransitionOut then
			if p_u_232.tweens.sprintTransitionIn then
				p_u_232.tweens.sprintTransitionIn:Cancel()
				p_u_232.tweens.sprintTransitionIn = nil
			end
			local v242 = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			p_u_232.tweens.sprintTransitionOut = TweenService:Create(p_u_232.lerpValues.sprint, v242, { Value = 0 })
			p_u_232.tweens.sprintTransitionOut:Play()
		end
		if p_u_232.onGround then
			local v243 = p_u_232.isAiming and 0.03 or 0.1
			local v244 = p_u_232.LegFracture:GetAttribute("Value") > 0
			local v245 = p_u_232.horizontalVelocityTime * 1
			local v246 = math.sin(v245) * v243
			local v247 = p_u_232.horizontalVelocityTime * 2
			local v248 = math.sin(v247) * v243
			local v249 = Vector3.new(v246, v248, 0.05) * (v244 and 4.5 or 1)
			if p_u_232.horizontalVelocity > 1 then
				p_u_232.springs.walkCycle:shove(v249 * 0.05 * v234 * p_u_232.horizontalVelocity)
			else
				local gunSway = p_u_232.springs.gunSway
				local v250 = tick()
				local v251 = math.sin(v250) * 2
				local v252 = tick()
				local v253 = math.sin(v252) * 6
				local v254 = Vector3.new(v251, v253, 0)
				local v255
				if p_u_232.isAiming then
					v255 = v_u_6:GetZoomTarget() < 2 and 0 or 0.001
				else
					v255 = 0.001
				end
				local v256 = v254 * v255
				local v257 = v234 * v234
				gunSway:shove(v256 * math.clamp(v257, 0.001, 2))
			end
			if p_u_232.GameplayVariables.Sprinting:GetAttribute("Value") and p_u_232.SprintStrafe < -0.35 then
				p_u_232.springs.sprintCycle:shove(v249 * 0.05 * v234 * p_u_232.horizontalVelocity)
			end
		end
		local v258 = p_u_232.springs.sway:update(p233)
		local v259 = p_u_232.springs.strafeTilt:update(p233)
		local v260 = p_u_232.springs.jumpTilt:update(p233)
		local v261 = p_u_232.springs.jumpCameraTilt:update(p233)
		local v262 = p_u_232.springs.walkCycle:update(p233)
		local v263 = p_u_232.springs.gunSway:update(p233)
		local v264 = p_u_232.springs.sprintCycle:update(p233)
		local v265 = p_u_232.springs.recoilPos:update(p233)
		local v266 = p_u_232.springs.recoilRot:update(p233)
		local v267 = p_u_232.springs.leanAlpha:update(p233)
		local v268 = p_u_232.springs.wallTouchTilt:update(p233)
		if p_u_232.isEquipped and (p_u_232.weapon and p_u_232.weapon.Parent == nil or p_u_232.rs_Player.Status.GameplayVariables.EquippedTool.Value ~= p_u_232.weapon) then
			p_u_232:unequip(nil, true)
		end
		if p_u_232.viewModel and p_u_232.viewModel.PrimaryPart ~= nil then
			p_u_232.timeSinceUse = p_u_232.timeSinceUse + v234
			local v269, v270
			if p_u_232.MouseHeld then
				local v271 = true
				for v272 = 1, #p_u_232.CancelTables do
					if p_u_232.CancelTables[v272].Visible == true then
						v271 = false
						break
					end
				end
				if v271 and useTypes[p_u_232.useModuleName] then
					if p_u_232.clientAnimationTracks.Inspect then
						p_u_232.clientAnimationTracks.Inspect:Stop()
						p_u_232.serverAnimationTracks.Inspect:Stop()
					end
					task.spawn(function()
						--[[ line: 2734 | upvalues: (copy) p_u_232]]
						useTypes[p_u_232.useModuleName](p_u_232)
					end)
				else
					p_u_232.MouseHeldTime = 0
					if tick() - p_u_232.RecoilPatternLastTick > p_u_232.RecoilPatternRecoverySpeed then
						p_u_232.RecoilPatternLastTick = tick()
						v269 = p_u_232.RecoilPatternPos - 1
						v270 = p_u_232.MaxAmmo
						p_u_232.RecoilPatternPos = math.clamp(v269, 0, v270)
					end
				end
			else
				p_u_232.MouseHeldTime = 0
				if tick() - p_u_232.RecoilPatternLastTick > p_u_232.RecoilPatternRecoverySpeed then
					p_u_232.RecoilPatternLastTick = tick()
					v269 = p_u_232.RecoilPatternPos - 1
					v270 = p_u_232.MaxAmmo
					p_u_232.RecoilPatternPos = math.clamp(v269, 0, v270)
				end
			end
			local v273 = p_u_232.firedInRow - 0.05 * p_u_232.FrameRateSync
			p_u_232.firedInRow = math.clamp(v273, 0, 100)
			if p_u_232.barrel then
				if p_u_232.firedInRow > 6 then
					if p_u_232.barrel:FindFirstChild("OverHeat") then
						local OverHeat = p_u_232.barrel.OverHeat
						local v274 = p_u_232.firedInRow / 3
						local v275 = math.floor(v274)
						OverHeat.Rate = math.clamp(v275, 3, 21)
						p_u_232.barrel.OverHeat.Enabled = true
					else
						game.ReplicatedStorage.VFX.MuzzleEffects.OverHeat:Clone().Parent = p_u_232.barrel
					end
				elseif p_u_232.barrel:FindFirstChild("OverHeat") then
					p_u_232.barrel.OverHeat.Enabled = false
				end
			end
			p_u_232.aimingLeanRotation = -v267.x * 11
			if p_u_232.isAiming == true and p_u_232.aimPart then
				local CFrame = p_u_232.aimPart.CFrame
				local fromEulerAnglesXYZ = CFrame.fromEulerAnglesXYZ
				local aimingLeanRotation = p_u_232.aimingLeanRotation
				local v276 = CFrame * fromEulerAnglesXYZ(0, 0, (math.rad(aimingLeanRotation)))
				local v277 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local t6 = { Value = v276:ToObjectSpace(p_u_232.viewModel.HumanoidRootPart.CFrame) }
				TweenService:Create(p_u_232.TempCFrame, v277, t6):Play()
			end
			if p_u_232.sprinting and p_u_232.horizontalVelocity > 5 then
				if p_u_232.serverAnimationTracks.Sprint then
					if p_u_232.SprintStrafe == 0 then
						if p_u_232.serverAnimationTracks.Sprint then
							p_u_232.serverAnimationTracks.Sprint:Stop(0.3)
						end
						if p_u_232.clientAnimationTracks.Sprint then
							p_u_232.clientAnimationTracks.Sprint:Stop(0.1)
						end
					else
						if p_u_232.serverAnimationTracks.Sprint and not p_u_232.serverAnimationTracks.Sprint.IsPlaying then
							p_u_232.serverAnimationTracks.Sprint:Play(0.3)
						end
						if p_u_232.clientAnimationTracks.Sprint and not p_u_232.clientAnimationTracks.Sprint.IsPlaying then
							p_u_232.clientAnimationTracks.Sprint:Play(0.1)
						end
					end
				end
			else
				if p_u_232.serverAnimationTracks.Sprint then
					p_u_232.serverAnimationTracks.Sprint:Stop(0.3)
				end
				if p_u_232.clientAnimationTracks.Sprint then
					p_u_232.clientAnimationTracks.Sprint:Stop(0.1)
				end
			end
			local TouchWallPosY = p_u_232.TouchWallPosY
			local TouchWallPosZ = p_u_232.TouchWallPosZ
			local TouchWallRotX = p_u_232.TouchWallRotX
			local TouchWallRotY = p_u_232.TouchWallRotY
			local wallTouchTilt = p_u_232.springs.wallTouchTilt
			local v278 = WallCollision(p_u_232)
			wallTouchTilt.Target = Vector3.new(v278, 0, 0)
			if p_u_232.isAiming then
				local v279 = true
				for v280 = 1, #p_u_232.CancelTables do
					if p_u_232.CancelTables[v280].Visible == true then
						v279 = false
						break
					end
				end
				if v279 then
					if v268.X > 0.1 then
						p_u_232.reAimDebunce = false
						p_u_232:aim(false, nil, "Wall")
					elseif p_u_232.reAimDebunce == false and p_u_232.Mouse2Held then
						p_u_232.reAimDebunce = true
						p_u_232:aim(true)
					end
				else
					p_u_232:aim(false)
				end
			elseif v268.X > 0.1 then
				p_u_232.reAimDebunce = false
				p_u_232:aim(false, nil, "Wall")
			elseif p_u_232.reAimDebunce == false and p_u_232.Mouse2Held then
				p_u_232.reAimDebunce = true
				p_u_232:aim(true)
			end
			if p_u_232.viewModel.PrimaryPart ~= nil and p_u_232.TempCFrame then
				local Value = p_u_232.TempCFrame.Value
				local v281 = (p_u_232.character:GetAttribute("IsAltLooking") and CFrame.new(workspace.CurrentCamera.CFrame.Position) * p_u_232.character:GetAttribute("AltLook") or workspace.CurrentCamera.CFrame) * Value:Lerp(p_u_232.sprintIdleOffset, p_u_232.lerpValues.sprint.Value) * CFrame.Angles(v260.x, 0, v259.x)
				local X = v268.X
				if v268.X > 0.4 then
					local v282 = 0.4 - (v268.X - 0.4)
					X = math.abs(v282)
					if v268.X > 0.8 then
						TouchWallPosZ = -TouchWallPosZ * 1.7
					end
				end
				local v283 = v268.X - 0.4
				local v284 = math.clamp(v283, 0, 1)
				local v285 = CFrame.new(0, v284 * TouchWallPosY, X * TouchWallPosZ)
				local fromEulerAnglesYXZ = CFrame.fromEulerAnglesYXZ
				local v286 = v284 * TouchWallRotX
				local v287 = math.rad(v286)
				local v288 = v284 * TouchWallRotY
				local v289 = v281 * (v285 * fromEulerAnglesYXZ(v287, math.rad(v288), 0))
				local fromEulerAnglesXYZ2 = CFrame.fromEulerAnglesXYZ
				local v290 = 0
				local v291 = 0
				local v292, v293
				if p_u_232.ToolStance == "Idle" then
					v292 = v267.X * 11
					v293 = math.rad(v292)
				else
					local v294 = v267.X * 11 + p_u_232.aimingLeanRotation
					v293 = math.rad(v294) / 2
					if not v293 then
						v292 = v267.X * 11
						v293 = math.rad(v292)
					end
				end
				local v295 = v289 * fromEulerAnglesXYZ2(v290, v291, v293) * CFrame.Angles(v260.x, 0, 0) * CFrame.Angles(-v258.y, 0, v258.y * 0.2)
				local v296 = CFrame.Angles(0, v258.x, 0):ToObjectSpace(v295)
				local v297 = CFrame.fromMatrix(v295.Position, v296.XVector, v296.YVector, v296.ZVector)
				local v298 = v262.x / 4
				local v299 = v262.y / 4
				local v300 = (v297 + Vector3.new(v298, v299)) * CFrame.new(0, 0, v262.z) * CFrame.Angles(0, 0, v262.x / 3) * CFrame.new(0, v264.y / 3, 0) * CFrame.Angles(0, v264.x / 4, 0) * CFrame.new(v265.x, v265.y, v265.z) * CFrame.Angles(v266.x, v266.y, v266.z)
				if (p_u_232.isEquipped or p_u_232.equipping) and p_u_232.timeTotal > 0.05 then
					p_u_232.viewModel.Item:PivotTo(v300 * p_u_232.viewModel:GetPivot():ToObjectSpace((p_u_232.viewModel.Item:GetPivot())))
				else
					p_u_232.viewModel:PivotTo(CFrame.new(0, 1000, 0))
				end
				if not ReducedMotionEnabled then
					if p_u_232.clientAnimationTracks.Equip then
						local CFrame2 = p_u_232.viewModel.FakeCamera.CFrame:ToObjectSpace(p_u_232.viewModel.HumanoidRootPart.CFrame)
						if p_u_232.oldCamCF then
							local _41, _42, v301 = CFrame2:ToOrientation()
							local v302, v303, _43 = CFrame2:ToObjectSpace(p_u_232.oldCamCF):ToEulerAnglesXYZ()
							CurrentCamera.CFrame = CurrentCamera.CFrame * CFrame.Angles(v302 * 0.4, v303 * 0.4, -v301 * 0.4)
						end
						p_u_232.oldCamCF = CFrame2
					else
						local CFrame3 = p_u_232.viewModel.FakeCamera.CFrame:ToObjectSpace(p_u_232.viewModel.HumanoidRootPart.CFrame)
						if p_u_232.oldCamCF then
							local _44, _45, v304 = CFrame3:ToOrientation()
							local v305, v306, _46 = CFrame3:ToObjectSpace(p_u_232.oldCamCF):ToEulerAnglesXYZ()
							CurrentCamera.CFrame = CurrentCamera.CFrame * CFrame.Angles(v305 * 0.4, v306 * 0.4, -v304 * 0.4)
						end
						p_u_232.oldCamCF = CFrame3
					end
				end
				if p_u_232.sight then
					local v307 = p_u_232.sight:FindFirstChild("Reticle") or p_u_232.sight.AimPart
					local v308 = p_u_232.sight:FindFirstChild("ReticleTarget") and p_u_232.sight.ReticleTarget.CFrame or v307.CFrame * CFrame.new(-v307.Size.X / 2, 0, 0)
					local v309 = v308 * CFrame.new(3, 0, 0)
					local CFrame4 = CurrentCamera.CFrame
					local v310 = CFrame4:ToObjectSpace(v308)
					local v311 = CFrame4:ToObjectSpace(v309)
					local Z = v310.Z
					local v312 = v311.X / v311.Z * Z - v310.X
					local v313 = v311.Y / v311.Z * Z - v310.Y
					local v314 = v308:ToObjectSpace(CFrame.lookAt(v308.Position, v308.Position + v308.RightVector) * CFrame.new((Vector3.new(v312, v313, 0))))
					if v307:FindFirstChild("PrismScopeGui") then
						local PrismScopeGui = v307.PrismScopeGui
						local Sight = PrismScopeGui.Sight
						local PixelsPerStud = PrismScopeGui.PixelsPerStud
						Sight.Position = UDim2.new(0.5, v314.Z * PixelsPerStud, 0.5, -v314.Y * PixelsPerStud)
					else
						local ScopeGui = v307.ScopeGui
						local Sight2 = ScopeGui.Sight
						local PixelsPerStud2 = ScopeGui.PixelsPerStud
						Sight2.Position = UDim2.new(0.5, v314.Z * PixelsPerStud2, 0.5, -v314.Y * PixelsPerStud2)
						p_u_232.noInsetGui.MainFrame.ScreenEffects.Parallax.Visible = false
					end
				end
			end
		end
		local v315 = p_u_232.springs.cameraRecoil:update(p233)
		local v316 = v262.X / 3 + v264.X
		local v317 = v262.Y / 3 + v264.Y + v261.X
		p_u_232.noInsetGui.MainFrame.ScreenEffects.Visor.Position = UDim2.new(0.5 + v316 / 45, 0, 0.5 + v317 / 12, 0)
		p_u_232.noInsetGui.MainFrame.ScreenEffects.HelmetMask.Position = p_u_232.noInsetGui.MainFrame.ScreenEffects.Visor.Position
		local CFrame5 = CurrentCamera.CFrame
		if not ReducedMotionEnabled then
			CFrame5 = CFrame5 * CFrame.Angles(v262.y * 0.001, 0, -v262.x * 0.01) * CFrame.Angles(v264.y * 0.007, 0, -v264.x * 0.038) * CFrame.Angles(v261.x * 0.1, 0, -v261.x * 0.5)
		end
		local fromEulerAnglesXYZ3 = CFrame.fromEulerAnglesXYZ
		local v318 = v267.X * 14
		CurrentCamera.CFrame = CFrame5 * fromEulerAnglesXYZ3(0, 0, (math.rad(v318))) * CFrame.Angles(v263.y * 0.001, 0, -v263.x * 0.01) * CFrame.Angles(v315.x * 0.1 * v234, v315.y * 0.1 * v234, 0)
		local humanoid = p_u_232.humanoid
		local v319 = -v267.X * 1.2
		local v320 = v267.X * 0.16
		local v321 = math.abs(v320) + p_u_232.crouchTweenValue.Value
		humanoid.CameraOffset = Vector3.new(v319, v321, 0)
		local v322 = CurrentCamera.FieldOfView / 70 < 1 and 1.35 or 1
		local player2 = p_u_232.player
		local v323 = CurrentCamera.FieldOfView / 70 / v322
		player2:SetAttribute("CameraSensitivity", (math.clamp(v323, 0.1, 1)))
	end
end
function t.action(p324, p325)
	--[[ line: 3035 | upvalues: (copy) v_u_7, (copy) t3]]
	if not (p324.isEquipped and (v_u_7:IsPlayerAlive(p324.player) and (p324.viewModel and p325))) then
		p324.MouseHeld = false
		p324.LeftMouseDown = false
		if t3[p324.useModuleName] then
			t3[p324.useModuleName](p324)
		end
		return
	end
	local v326 = true
	for v327 = 1, #p324.CancelTables do
		if p324.CancelTables[v327].Visible == true then
			v326 = false
			break
		end
	end
	if v326 then
		p324.MouseHeld = true
		p324.LeftMouseDown = true
	else
		p324.MouseHeld = false
		p324.LeftMouseDown = false
		if t3[p324.useModuleName] then
			t3[p324.useModuleName](p324)
		end
	end
end
function t.action2(p328, p329)
	--[[ line: 3046 | upvalues: none]]
	p328.Mouse2Held = p329
	p328:aim(p329, true)
end
function t.aim(p_u_330, p_u_331, p_u_332, p_u_333)
	--[[ line: 3052 | upvalues: (copy) v_u_7, (copy) TweenService, (copy) v_u_6, (copy) SoundHandler]]
	if p_u_330.viewModel then
		task.spawn(function()
			--[[ line: 3054 | upvalues: (copy) p_u_332, (copy) p_u_330, (copy) p_u_331, (copy) p_u_333, (ref) v_u_7, (ref) TweenService, (ref) v_u_6, (ref) SoundHandler]]
			if p_u_332 then
				p_u_330.RightMouseDown = p_u_331
			end
			p_u_330.actionId = math.random(-1000000, 1000000)
			local _47 = p_u_330.actionId
			if p_u_330.allowAiming then
				local ToggleADSDof = p_u_330.VisualSettings:GetAttribute("ToggleADSDof")
				if p_u_330.clientAnimationTracks.Inspect and (p_u_330.clientAnimationTracks.Inspect.IsPlaying and (p_u_333 ~= "Cancel" and p_u_333 ~= "Wall")) then
					p_u_330.clientAnimationTracks.Inspect:Stop(0.25)
					p_u_330.serverAnimationTracks.Inspect:Stop(0.25)
				end
				local v334 = p_u_330.rs_Player.Inventory:GetChildren()
				for v335 = 1, #v334 do
					if v_u_7:IsInClothingSlot(v334[v335]) and (v334[v335].Value.ItemProperties.Clothing:GetAttribute("BlockADS") and p_u_330.itemProperties:GetAttribute("SlotType") ~= "Pistol") then
						p_u_330:cycleSight()
						break
					end
				end
				local v336, v337, v338, v339, v340, v341, v342, v343, v344, v345, v346
				if p_u_331 and (p_u_330.isEquipped or p_u_330.equipping) and (v_u_7:IsPlayerAlive(p_u_330.player) and p_u_330.viewModel) then
					local v347 = p_u_330
					local v348 = true
					for v349 = 1, #v347.CancelTables do
						if v347.CancelTables[v349].Visible == true then
							v348 = false
							break
						end
					end
					if v348 then
						if p_u_330.clientAnimationTracks.Equip and (p_u_330.clientAnimationTracks.Equip.IsPlaying and p_u_330.clientAnimationTracks.Equip.TimePosition < p_u_330.clientAnimationTracks.Equip.Length * 0.5) then
							local viewModel3 = p_u_330.viewModel
							while p_u_330.viewModel and (p_u_330.clientAnimationTracks.Equip.IsPlaying and p_u_330.clientAnimationTracks.Equip.TimePosition < p_u_330.clientAnimationTracks.Equip.Length * 0.5) do
								wait()
							end
							if viewModel3 ~= p_u_330.viewModel or (p_u_330.ToolStance == "Aim" or (p_u_330.ToolStance == "Ready" or p_u_330.RightMouseDown == false)) then
								return
							end
						end
						p_u_330.sprinting = false
						p_u_330.rs_Player.Status.GameplayVariables.Sprinting:SetAttribute("Value", p_u_330.sprinting)
						if not p_u_330.settings.AimWhileActing and p_u_330.reloading == true or (p_u_330.useDebounce == true or p_u_330.Scope and p_u_330.reloading == true) then
							return
						end
						if not p_u_330.reloading then
							if p_u_330.sight and p_u_330.variableZoom then
								if not p_u_330.zoomIndex then
									p_u_330.zoomIndex = 1
								end
								local v350 = p_u_330
								local variableZoom2 = p_u_330.variableZoom
								local zoomIndex2 = p_u_330.zoomIndex
								v350.zoomAmount = variableZoom2[tostring(zoomIndex2)]
								if p_u_330.sight.PrimaryPart:FindFirstChild("ZoomWeld") then
									local v351 = 0.155 + p_u_330.zoomAmount * 0.16
									TweenService:Create(p_u_330.sight.PrimaryPart.ZoomWeld, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(0, 0, v351) }):Play()
								end
								local v352 = p_u_330.sight:FindFirstChild("Reticle") or p_u_330.sight.AimPart
								if v352:FindFirstChild("PrismScopeGui") then
									local PrismScopeGui2 = v352.PrismScopeGui
									if PrismScopeGui2.Sight:FindFirstChild("ZoomDisplay") then
										for _48, v353 in pairs((PrismScopeGui2.Sight.ZoomDisplay:GetChildren())) do
											v353.Visible = false
										end
										local ZoomDisplay = PrismScopeGui2.Sight.ZoomDisplay
										local zoomIndex3 = p_u_330.zoomIndex
										ZoomDisplay["Zoom" .. tostring(zoomIndex3)].Visible = true
									end
								end
								if v352:FindFirstChild("ScopeGui") then
									local ScopeGui2 = v352.ScopeGui
									if ScopeGui2.Sight:FindFirstChild("CloseSight") then
										local t7 = { Size = ScopeGui2.Sight.CloseSight:GetAttribute("Zoom" .. p_u_330.zoomIndex) }
										TweenService:Create(ScopeGui2.Sight.CloseSight, TweenInfo.new(p_u_330.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), t7):Play()
									end
									if ScopeGui2.Sight:FindFirstChild("FarSight") then
										local t8 = { Size = ScopeGui2.Sight.FarSight:GetAttribute("Zoom" .. p_u_330.zoomIndex) }
										TweenService:Create(ScopeGui2.Sight.FarSight, TweenInfo.new(p_u_330.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), t8):Play()
									end
								end
							end
							v_u_6:SetZoomTarget(p_u_330.zoomAmount, p_u_330.Scope, 0.3)
						end
						if p_u_330.useDof and ToggleADSDof then
							game.Lighting.ADS_DOF.Enabled = true
						end
						game.Lighting.DDOF.Enabled = false
						local v354 = tick()
						p_u_330.ToolStance = "Aim"
						p_u_330:updateSway(0, 0)
						if p_u_330.ReSizeScope ~= 0 then
							local v355 = p_u_330.viewModel:GetDescendants()
							for v356 = 1, #v355 do
								if v355[v356]:IsA("BasePart") and v355[v356]:FindFirstChild("ScopePart") then
									local Size = v355[v356].Size
									local v357
									if v355[v356]:FindFirstChild("ScopePart").Value == Vector3.new(0, 0, 0) then
										v355[v356]:FindFirstChild("ScopePart").Value = v355[v356].Size
										v357 = Size
									else
										v357 = v355[v356]:FindFirstChild("ScopePart").Value
									end
									local v358 = TweenInfo.new(0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.11)
									if p_u_330.ReSizeScopeVector == "X" then
										local v359 = v357.X / p_u_330.ReSizeScope
										local Y = v357.Y
										local Z2 = v357.Z
										Size = Vector3.new(v359, Y, Z2)
									elseif p_u_330.ReSizeScopeVector == "Z" then
										local X2 = v357.X
										local Y2 = v357.Y
										local v360 = v357.Z / p_u_330.ReSizeScope
										Size = Vector3.new(X2, Y2, v360)
									end
									TweenService:Create(v355[v356], v358, { Size = Size }):Play()
								end
							end
						end
						if p_u_330.sight then
							for _49, v361 in pairs((p_u_330.sight:GetChildren())) do
								if v361:GetAttribute("aimHide") then
									v361.Transparency = 1
								end
							end
						end
						if p_u_330.sight and p_u_330.sight:FindFirstChild("Glass") then
							local v362 = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
							TweenService:Create(p_u_330.sight.Glass, v362, { Transparency = 1 }):Play()
						end
						if p_u_330.worldModel.ItemRoot.Sounds:FindFirstChild("Aim") then
							SoundHandler:PlayEquippedItem("Aim", p_u_330.character, 2)
							SoundHandler:Play(p_u_330.worldModel.ItemRoot.Sounds.Aim, p_u_330.SoundsTemp)
						end
						if p_u_330.serverAnimationTracks.Aim then
							p_u_330.serverAnimationTracks.Aim:Play()
							p_u_330.serverAnimationTracks.Aim:AdjustSpeed(1.5)
						end
						if p_u_330.clientAnimationTracks.Aim then
							p_u_330.clientAnimationTracks.Aim:Play()
							p_u_330.clientAnimationTracks.Aim:AdjustSpeed(1.5)
						end
						if p_u_330.aimPart then
							local CFrame6 = p_u_330.aimPart.CFrame
							local fromEulerAnglesXYZ4 = CFrame.fromEulerAnglesXYZ
							local aimingLeanRotation2 = p_u_330.aimingLeanRotation
							local v363 = CFrame6 * fromEulerAnglesXYZ4(0, 0, (math.rad(aimingLeanRotation2)))
							local v364 = TweenInfo.new(p_u_330.AimInSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							local t9 = { Value = v363:ToObjectSpace(p_u_330.viewModel.HumanoidRootPart.CFrame) }
							TweenService:Create(p_u_330.TempCFrame, v364, t9):Play()
						end
						if p_u_330.Scope and not p_u_330.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_330.Scope):FindFirstChild("Sight") then
							coroutine.wrap(function()
								--[[ line: 3242 | upvalues: (ref) p_u_330]]
								-- irreducible control flow represented as a structured state loop
								local v365, v366, v367, v368, v369, v370, v371, v372, v373, v374
								local v375 = 44
								while v375 do
									if v375 == 44 then
										v365 = tick()
										v375 = 18
									elseif v375 == 18 then
										if true then
											v375 = 6
										else
											v375 = 11
										end
									elseif v375 == 6 then
										if p_u_330.ToolStance == "Aim" and (p_u_330.isEquipped or p_u_330.equipping) then
											v375 = 4
										else
											v375 = 2
										end
									elseif v375 == 2 then
										if p_u_330.ToolStance ~= "Ready" or p_u_330.isEquipped ~= true then
											break
										end
										v366 = p_u_330
										v367 = true
										for v376 = 1, #v366.CancelTables do
											if v366.CancelTables[v376].Visible == true then
												v367 = false
												break
											end
										end
										if not v367 then
											break
										end
										v375 = 9
									elseif v375 == 9 then
										wait()
										if tick() - v365 > p_u_330.AimInSpeed * 0.14 then
											break
										end
										v375 = 18
									elseif v375 == 4 then
										v368 = p_u_330
										v369 = true
										for v377 = 1, #v368.CancelTables do
											if v368.CancelTables[v377].Visible == true then
												v369 = false
												break
											end
										end
										if v369 then
											v375 = 9
										else
											v375 = 2
										end
									elseif v375 == 11 then
										if p_u_330.ToolStance == "Aim" and (p_u_330.isEquipped or p_u_330.equipping) then
											v375 = 22
										else
											v375 = 20
										end
									elseif v375 == 20 then
										if p_u_330.ToolStance == "Ready" and (p_u_330.isEquipped or p_u_330.equipping) then
											v370 = p_u_330
											v371 = true
											for v378 = 1, #v370.CancelTables do
												if v370.CancelTables[v378].Visible == true then
													v371 = false
													break
												end
											end
											if v371 then
												if p_u_330.sight.Reticle:FindFirstChild("PrismScopeGui") then
													p_u_330.sight.Reticle.PrismScopeGui.Enabled = true
												end
												if not p_u_330.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_330.Scope):FindFirstChild("Sight") then
													v372 = p_u_330.viewModel:GetDescendants()
													for v379 = 1, #v372 do
														if v372[v379]:IsA("BasePart") and v372[v379].Name ~= "Reticle" or v372[v379]:IsA("Decal") then
															v372[v379].Transparency = 1
														end
													end
												end
											end
										end
										v375 = 29
									elseif v375 == 29 then
										return
									elseif v375 == 22 then
										v373 = p_u_330
										v374 = true
										for v380 = 1, #v373.CancelTables do
											if v373.CancelTables[v380].Visible == true then
												v374 = false
												break
											end
										end
										if v374 then
											v375 = 27
										else
											v375 = 20
										end
									elseif v375 == 27 then
										if p_u_330.sight.Reticle:FindFirstChild("PrismScopeGui") then
											p_u_330.sight.Reticle.PrismScopeGui.Enabled = true
										end
										if not p_u_330.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_330.Scope):FindFirstChild("Sight") then
											v372 = p_u_330.viewModel:GetDescendants()
											for v379 = 1, #v372 do
												if v372[v379]:IsA("BasePart") and v372[v379].Name ~= "Reticle" or v372[v379]:IsA("Decal") then
													v372[v379].Transparency = 1
												end
											end
										end
										v375 = 29
									else
										v375 = nil
									end
								end
							end)()
						end
						local equipAttemptId2 = p_u_330.equipAttemptId
						task.delay(p_u_330.AimInSpeed * p_u_330.AimReadyTime * 0.5, function()
							--[[ line: 3275 | upvalues: (copy) equipAttemptId2, (ref) p_u_330]]
							if equipAttemptId2 == p_u_330.equipAttemptId and (p_u_330.ToolStance == "Aim" and (p_u_330.isEquipped or p_u_330.equipping)) then
								local v381 = p_u_330
								local v382 = true
								for v383 = 1, #v381.CancelTables do
									if v381.CancelTables[v383].Visible == true then
										v382 = false
										break
									end
								end
								if v382 then
									p_u_330:ambientBoostUpdate(p_u_330.ambientBoost, p_u_330.nightVisionColor, p_u_330.grainEffect, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
									p_u_330:thermalVisionUpdate(p_u_330.thermalVisionColor and 1 or 0, p_u_330.thermalVisionColor, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
								end
							end
						end)
						while p_u_330.ToolStance == "Aim" and (p_u_330.isEquipped or p_u_330.equipping) do
							local v384 = p_u_330
							local v385 = true
							for v386 = 1, #v384.CancelTables do
								if v384.CancelTables[v386].Visible == true then
									v385 = false
									break
								end
							end
							if not v385 then
								break
							end
							wait()
							if tick() - v354 > p_u_330.AimInSpeed * p_u_330.AimReadyTime then
								break
							end
						end
						local v387 = p_u_330
						local v388 = true
						for v389 = 1, #v387.CancelTables do
							if v387.CancelTables[v389].Visible == true then
								v388 = false
								break
							end
						end
						if not v388 then
							p_u_330:aim(false)
						end
						if p_u_330.ToolStance == "Aim" and (p_u_330.isEquipped or p_u_330.equipping) then
							local v390 = p_u_330
							local v391 = true
							for v392 = 1, #v390.CancelTables do
								if v390.CancelTables[v392].Visible == true then
									v391 = false
									break
								end
							end
							if v391 then
								if p_u_330.settings.allowAiming then
									p_u_330.mobileButtons.GameplayLayer.AimingLayer.Visible = true
									p_u_330.mobileButtons.GameplayLayer.TopRow.CycleSight.Visible = true
								end
								p_u_330.isAiming = true
								p_u_330.character:SetAttribute("isAiming", true)
								p_u_330:updateSway(0, 0)
								p_u_330.ToolStance = "Ready"
							end
						end
						while p_u_330.isAiming and (p_u_330.isEquipped or p_u_330.equipping) do
							local v393 = p_u_330
							local v394 = true
							for v395 = 1, #v393.CancelTables do
								if v393.CancelTables[v395].Visible == true then
									v394 = false
									break
								end
							end
							if not v394 then
								break
							end
							wait()
							if tick() - v354 > p_u_330.AimInSpeed - 0.17 then
								break
							end
						end
						local v396 = p_u_330
						local v397 = true
						for v398 = 1, #v396.CancelTables do
							if v396.CancelTables[v398].Visible == true then
								v397 = false
								break
							end
						end
						if not v397 then
							p_u_330:aim(false)
						end
						if p_u_330.isAiming and (p_u_330.isEquipped or p_u_330.equipping) then
							local v399 = p_u_330
							local v400 = true
							for v401 = 1, #v399.CancelTables do
								if v399.CancelTables[v401].Visible == true then
									v400 = false
									break
								end
							end
							if v400 then
								if p_u_330.serverAnimationTracks.Aim then
									p_u_330.serverAnimationTracks.Aim:AdjustSpeed(0)
								end
								if p_u_330.clientAnimationTracks.Aim then
									p_u_330.clientAnimationTracks.Aim:AdjustSpeed(0)
								end
							else
								return
							end
						else
							return
						end
					elseif p_u_330.isEquipped or p_u_330.equipping then
						if p_u_330.isAiming and p_u_330.worldModel.ItemRoot.Sounds:FindFirstChild("UnAim") then
							SoundHandler:PlayEquippedItem("UnAim", p_u_330.character, 2)
							SoundHandler:Play(p_u_330.worldModel.ItemRoot.Sounds.UnAim, p_u_330.SoundsTemp)
						end
						v_u_6:SetZoomTarget(1, p_u_330.Scope, 0.3)
						p_u_330:ambientBoostUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
						p_u_330:thermalVisionUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
						p_u_330.ToolStance = "Idle"
						p_u_330.isAiming = false
						p_u_330.character:SetAttribute("isAiming", false)
						p_u_330.mobileButtons.GameplayLayer.AimingLayer.Visible = false
						p_u_330.mobileButtons.GameplayLayer.TopRow.CycleSight.Visible = false
						if p_u_330.Scope then
							if p_u_330.sight.Reticle:FindFirstChild("PrismScopeGui") then
								p_u_330.sight.Reticle.PrismScopeGui.Enabled = false
							end
							if not p_u_330.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_330.Scope):FindFirstChild("Sight") then
								v336 = p_u_330.viewModel:GetDescendants()
								for v402 = 1, #v336 do
									if v336[v402]:IsA("BasePart") or v336[v402]:IsA("Decal") then
										v336[v402].Transparency = v336[v402]:GetAttribute("OriginalTransparency") or 0
									end
								end
							end
							if p_u_330.aimPart.Parent:FindFirstChild("Dot") then
								p_u_330.aimPart.Parent.Dot.SurfaceGui.Enabled = false
							end
						end
						if p_u_330.ReSizeScope ~= 0 then
							v337 = p_u_330.viewModel:GetDescendants()
							for v403 = 1, #v337 do
								if v337[v403]:IsA("BasePart") and v337[v403]:FindFirstChild("ScopePart") then
									v338 = v337[v403].Size
									if v337[v403]:FindFirstChild("ScopePart").Value == Vector3.new(0, 0, 0) then
										v337[v403]:FindFirstChild("ScopePart").Value = v337[v403].Size
									else
										v338 = v337[v403]:FindFirstChild("ScopePart").Value
									end
									v339 = TweenInfo.new(0, Enum.EasingStyle.Quart)
									v340 = v338.X
									v341 = v338.Y
									v342 = v338.Z
									v343 = { Size = Vector3.new(v340, v341, v342) }
									TweenService:Create(v337[v403], v339, v343):Play()
								end
							end
						end
						if p_u_330.sight then
							for _50, v404 in pairs((p_u_330.sight:GetChildren())) do
								if v404:GetAttribute("aimHide") then
									v404.Transparency = 0
								end
							end
						end
						if p_u_330.sight and p_u_330.sight:FindFirstChild("Glass") then
							v344 = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
							TweenService:Create(p_u_330.sight.Glass, v344, { Transparency = p_u_330.sight.Glass:GetAttribute("OriginalTransparency") or 0.4 }):Play()
						end
						if p_u_330.useDof then
							game.Lighting.ADS_DOF.Enabled = false
						end
						game.Lighting.DDOF.Enabled = true
						if p_u_330.aimPart then
							v345 = TweenInfo.new(p_u_330.AimOutSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							v346 = { Value = p_u_330.weaponOffSet }
							TweenService:Create(p_u_330.TempCFrame, v345, v346):Play()
						end
						if p_u_330.serverAnimationTracks.Aim then
							p_u_330.serverAnimationTracks.Aim:AdjustSpeed(-1.5)
						end
						if p_u_330.clientAnimationTracks.Aim then
							p_u_330.clientAnimationTracks.Aim:AdjustSpeed(-1.5)
						end
					else
						return
					end
				elseif p_u_330.isEquipped or p_u_330.equipping then
					if p_u_330.isAiming and p_u_330.worldModel.ItemRoot.Sounds:FindFirstChild("UnAim") then
						SoundHandler:PlayEquippedItem("UnAim", p_u_330.character, 2)
						SoundHandler:Play(p_u_330.worldModel.ItemRoot.Sounds.UnAim, p_u_330.SoundsTemp)
					end
					v_u_6:SetZoomTarget(1, p_u_330.Scope, 0.3)
					p_u_330:ambientBoostUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
					p_u_330:thermalVisionUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
					p_u_330.ToolStance = "Idle"
					p_u_330.isAiming = false
					p_u_330.character:SetAttribute("isAiming", false)
					p_u_330.mobileButtons.GameplayLayer.AimingLayer.Visible = false
					p_u_330.mobileButtons.GameplayLayer.TopRow.CycleSight.Visible = false
					if p_u_330.Scope then
						if p_u_330.sight.Reticle:FindFirstChild("PrismScopeGui") then
							p_u_330.sight.Reticle.PrismScopeGui.Enabled = false
						end
						if not p_u_330.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_330.Scope):FindFirstChild("Sight") then
							v336 = p_u_330.viewModel:GetDescendants()
							for v402 = 1, #v336 do
								if v336[v402]:IsA("BasePart") or v336[v402]:IsA("Decal") then
									v336[v402].Transparency = v336[v402]:GetAttribute("OriginalTransparency") or 0
								end
							end
						end
						if p_u_330.aimPart.Parent:FindFirstChild("Dot") then
							p_u_330.aimPart.Parent.Dot.SurfaceGui.Enabled = false
						end
					end
					if p_u_330.ReSizeScope ~= 0 then
						v337 = p_u_330.viewModel:GetDescendants()
						for v403 = 1, #v337 do
							if v337[v403]:IsA("BasePart") and v337[v403]:FindFirstChild("ScopePart") then
								v338 = v337[v403].Size
								if v337[v403]:FindFirstChild("ScopePart").Value == Vector3.new(0, 0, 0) then
									v337[v403]:FindFirstChild("ScopePart").Value = v337[v403].Size
								else
									v338 = v337[v403]:FindFirstChild("ScopePart").Value
								end
								v339 = TweenInfo.new(0, Enum.EasingStyle.Quart)
								v340 = v338.X
								v341 = v338.Y
								v342 = v338.Z
								v343 = { Size = Vector3.new(v340, v341, v342) }
								TweenService:Create(v337[v403], v339, v343):Play()
							end
						end
					end
					if p_u_330.sight then
						for _50, v404 in pairs((p_u_330.sight:GetChildren())) do
							if v404:GetAttribute("aimHide") then
								v404.Transparency = 0
							end
						end
					end
					if p_u_330.sight and p_u_330.sight:FindFirstChild("Glass") then
						v344 = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
						TweenService:Create(p_u_330.sight.Glass, v344, { Transparency = p_u_330.sight.Glass:GetAttribute("OriginalTransparency") or 0.4 }):Play()
					end
					if p_u_330.useDof then
						game.Lighting.ADS_DOF.Enabled = false
					end
					game.Lighting.DDOF.Enabled = true
					if p_u_330.aimPart then
						v345 = TweenInfo.new(p_u_330.AimOutSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
						v346 = { Value = p_u_330.weaponOffSet }
						TweenService:Create(p_u_330.TempCFrame, v345, v346):Play()
					end
					if p_u_330.serverAnimationTracks.Aim then
						p_u_330.serverAnimationTracks.Aim:AdjustSpeed(-1.5)
					end
					if p_u_330.clientAnimationTracks.Aim then
						p_u_330.clientAnimationTracks.Aim:AdjustSpeed(-1.5)
					end
				else
					return
				end
			else
				if p_u_332 and useTypes2[p_u_330.useModuleName] then
					local v405 = p_u_330
					local v406 = true
					for v407 = 1, #v405.CancelTables do
						if v405.CancelTables[v407].Visible == true then
							v406 = false
							break
						end
					end
					if v406 and p_u_333 ~= "Cancel" then
						p_u_330.clientAnimationTracks.Inspect:Stop(0.25)
						p_u_330.serverAnimationTracks.Inspect:Stop(0.25)
						useTypes2[p_u_330.useModuleName](p_u_330)
					end
				end
				return
			end
		end)
	end
end
function t.reload(p408, p409)
	--[[ line: 3431 | upvalues: (copy) t4]]
	if p408.viewModel then
		if p408.viewModel.Item:FindFirstChild("AmmoTypes") then
			local Value2 = p408.itemProperties.AmmoType.Value
			local v410 = p408.viewModel.Item.AmmoTypes:GetChildren()
			for v411 = 1, #v410 do
				v410[v411].Transparency = 1
			end
			p408.viewModel.Item.AmmoTypes:FindFirstChild(Value2).Transparency = 0
			if p408.viewModel.Item:FindFirstChild("AmmoTypes2") then
				local v412 = p408.viewModel.Item.AmmoTypes2:GetChildren()
				for v413 = 1, #v412 do
					v412[v413].Transparency = 1
				end
				p408.viewModel.Item.AmmoTypes2:FindFirstChild(Value2).Transparency = 0
			end
		end
		if p408.reloading == false and (p408.cancellingReload == false and p408.MaxAmmo > 0) then
			local v414 = true
			for v415 = 1, #p408.CancelTables do
				if p408.CancelTables[v415].Visible == true then
					v414 = false
					break
				end
			end
			if v414 then
				if p408.clientAnimationTracks.Inspect then
					p408.clientAnimationTracks.Inspect:Stop()
					p408.serverAnimationTracks.Inspect:Stop()
				end
				if not p408.settings.AimWhileActing and p408.isAiming then
					p408:aim(false)
				end
				if t4[p408.reloadType] then
					t4[p408.reloadType](p408, p409)
				end
			end
		end
	end
end
function t.fireMode(p416)
	--[[ line: 3475 | upvalues: (copy) SoundHandler, (copy) ChangeFireMode]]
	if p416.weapon and (p416.FireModes and #p416.FireModes > 1) then
		local v417 = p416.FireModeIndex + 1
		local v418 = #p416.FireModes < v417 and 1 or v417
		SoundHandler:PlayEquippedItem("FireSelector", p416.character, 2)
		SoundHandler:Play(p416.worldModel.ItemRoot.Sounds.FireSelector, p416.SoundsTemp)
		p416.weapon:SetAttribute("FireMode", p416.FireModes[v418])
		p416.weapon:SetAttribute("FireModeIndex", v418)
		p416.FireModeIndex = v418
		ChangeFireMode:FireServer(p416.weapon, p416.FireModeIndex)
	end
end
function t.cycleSight(p_u_419)
	--[[ line: 3495 | upvalues: (copy) v_u_7, (copy) TweenService, (copy) v_u_6, (copy) SoundHandler]]
	if p_u_419.weapon then
		local v420 = p_u_419.SightCycleIndex + 1
		local v421 = #p_u_419.aimParts < v420 and 1 or v420
		local v422 = p_u_419.rs_Player.Inventory:GetChildren()
		local v423 = false
		for v424 = 1, #v422 do
			if v_u_7:IsInClothingSlot(v422[v424]) and (v422[v424].Value.ItemProperties.Clothing:GetAttribute("BlockADS") and p_u_419.itemProperties:GetAttribute("SlotType") ~= "Pistol") then
				v423 = true
				break
			end
		end
		if v423 then
			local v425 = 2
			v421 = not p_u_419.aimParts[v425] and 1 or v425
		end
		if p_u_419.SightCycleIndex ~= v421 and (p_u_419.sight and p_u_419.ReSizeScope ~= 0) then
			local v426 = p_u_419.viewModel:GetDescendants()
			for v427 = 1, #v426 do
				if v426[v427]:IsA("BasePart") and v426[v427]:FindFirstChild("ScopePart") then
					local Size2 = v426[v427].Size
					if v426[v427]:FindFirstChild("ScopePart").Value == Vector3.new(0, 0, 0) then
						v426[v427]:FindFirstChild("ScopePart").Value = v426[v427].Size
					else
						Size2 = v426[v427]:FindFirstChild("ScopePart").Value
					end
					local v428 = TweenInfo.new(0.1, Enum.EasingStyle.Quart)
					local X3 = Size2.X
					local Y3 = Size2.Y
					local Z3 = Size2.Z
					local t10 = { Size = Vector3.new(X3, Y3, Z3) }
					TweenService:Create(v426[v427], v428, t10):Play()
				end
			end
			if p_u_419.sight then
				for _51, v429 in pairs((p_u_419.sight:GetChildren())) do
					if v429:GetAttribute("aimHide") then
						v429.Transparency = 0
					end
				end
			end
			if p_u_419.sight and p_u_419.sight:FindFirstChild("Glass") then
				local v430 = TweenInfo.new(0.1, Enum.EasingStyle.Quart)
				TweenService:Create(p_u_419.sight.Glass, v430, { Transparency = p_u_419.sight.Glass:GetAttribute("OriginalTransparency") or 0.4 }):Play()
			end
		end
		if p_u_419.SightCycleIndex ~= v421 and (p_u_419.sight and p_u_419.sight.Reticle:FindFirstChild("ScopeGui")) then
			p_u_419.sight.Reticle.ScopeGui.Enabled = false
		end
		if p_u_419.SightCycleIndex ~= v421 and p_u_419.Scope then
			if p_u_419.sight.Reticle:FindFirstChild("PrismScopeGui") then
				p_u_419.sight.Reticle.PrismScopeGui.Enabled = false
			end
			if not p_u_419.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_419.Scope):FindFirstChild("Sight") then
				local v431 = p_u_419.viewModel:GetDescendants()
				for v432 = 1, #v431 do
					if v431[v432]:IsA("BasePart") or v431[v432]:IsA("Decal") then
						v431[v432].Transparency = v431[v432]:GetAttribute("OriginalTransparency") or 0
					end
				end
			end
		end
		p_u_419.aimPart = p_u_419.aimParts[v421].AimPart
		p_u_419.sight = p_u_419.aimParts[v421].Sight
		p_u_419.Scope = p_u_419.aimParts[v421].Scope
		p_u_419.ReSizeScope = p_u_419.aimParts[v421].ReSizeScope
		p_u_419.ReSizeScopeVector = p_u_419.aimParts[v421].ReSizeScopeVector
		p_u_419.zoomAmount = p_u_419.aimParts[v421].ZoomAmount
		p_u_419.ambientBoost = p_u_419.aimParts[v421].AmbientBoost
		p_u_419.nightVisionColor = p_u_419.aimParts[v421].NightVisionColor
		p_u_419.grainEffect = p_u_419.aimParts[v421].GrainEffect
		p_u_419.thermalVisionColor = p_u_419.aimParts[v421].ThermalVisionColor
		p_u_419.variableZoom = p_u_419.aimParts[v421].VariableZoom
		p_u_419.zoomSpeed = p_u_419.aimParts[v421].ZoomSpeed
		p_u_419.zoomIndex = p_u_419.aimParts[v421].zoomIndex
		if p_u_419.variableZoom then
			p_u_419.mobileButtons.GameplayLayer.AimingLayer.ZoomIn.Visible = true
			p_u_419.mobileButtons.GameplayLayer.AimingLayer.ZoomOut.Visible = true
		end
		local v433 = false
		local _52, v434, v435, v436, v437, v438, v439, v440, v441, v442, v443, v444, v445, v446, v447, v448, v449, v450, v451, v452, v453, v454
		if p_u_419.ToolStance == "Aim" and (p_u_419.isEquipped or p_u_419.equipping) then
			local v455 = true
			for v456 = 1, #p_u_419.CancelTables do
				if p_u_419.CancelTables[v456].Visible == true then
					v455 = false
					break
				end
			end
			if v455 then
				p_u_419.actionId = math.random(-1000000, 1000000)
				_52 = p_u_419.actionId
				if p_u_419.sight and p_u_419.variableZoom then
					if not p_u_419.zoomIndex then
						p_u_419.zoomIndex = 1
					end
					v434 = p_u_419.variableZoom
					v435 = p_u_419.zoomIndex
					p_u_419.zoomAmount = v434[tostring(v435)]
					if p_u_419.sight.PrimaryPart:FindFirstChild("ZoomWeld") then
						v436 = 0.155 + p_u_419.zoomAmount * 0.16
						TweenService:Create(p_u_419.sight.PrimaryPart.ZoomWeld, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(0, 0, v436) }):Play()
					end
					v437 = p_u_419.sight:FindFirstChild("Reticle") or p_u_419.sight.AimPart
					if v437:FindFirstChild("PrismScopeGui") then
						v438 = v437.PrismScopeGui
						if v438.Sight:FindFirstChild("ZoomDisplay") then
							for _53, v457 in pairs((v438.Sight.ZoomDisplay:GetChildren())) do
								v457.Visible = false
							end
							v439 = v438.Sight.ZoomDisplay
							v440 = p_u_419.zoomIndex
							v439["Zoom" .. tostring(v440)].Visible = true
						end
					end
					if v437:FindFirstChild("ScopeGui") then
						v441 = v437.ScopeGui
						if v441.Sight:FindFirstChild("CloseSight") then
							v442 = { Size = v441.Sight.CloseSight:GetAttribute("Zoom" .. p_u_419.zoomIndex) }
							TweenService:Create(v441.Sight.CloseSight, TweenInfo.new(p_u_419.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v442):Play()
						end
						if v441.Sight:FindFirstChild("FarSight") then
							v443 = { Size = v441.Sight.FarSight:GetAttribute("Zoom" .. p_u_419.zoomIndex) }
							TweenService:Create(v441.Sight.FarSight, TweenInfo.new(p_u_419.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v443):Play()
						end
					end
				end
				v_u_6:SetZoomTarget(p_u_419.zoomAmount, p_u_419.Scope, 0.3)
				p_u_419:ambientBoostUpdate(p_u_419.ambientBoost, p_u_419.nightVisionColor, p_u_419.grainEffect, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				p_u_419:thermalVisionUpdate(p_u_419.thermalVisionColor and 1 or 0, p_u_419.thermalVisionColor, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				if p_u_419.worldModel.ItemRoot.Sounds:FindFirstChild("Aim") then
					SoundHandler:PlayEquippedItem("Aim", p_u_419.character, 2)
					SoundHandler:Play(p_u_419.worldModel.ItemRoot.Sounds.Aim, p_u_419.SoundsTemp)
				end
				if p_u_419.SightCycleIndex ~= v421 and p_u_419.ReSizeScope ~= 0 then
					v444 = p_u_419.viewModel:GetDescendants()
					for v458 = 1, #v444 do
						if v444[v458]:IsA("BasePart") and v444[v458]:FindFirstChild("ScopePart") then
							v445 = v444[v458].Size
							if v444[v458]:FindFirstChild("ScopePart").Value == Vector3.new(0, 0, 0) then
								v444[v458]:FindFirstChild("ScopePart").Value = v444[v458].Size
								v446 = v445
							else
								v446 = v444[v458]:FindFirstChild("ScopePart").Value
							end
							v447 = TweenInfo.new(0.1, Enum.EasingStyle.Quart)
							if p_u_419.ReSizeScopeVector == "X" then
								v448 = v446.X / p_u_419.ReSizeScope
								v449 = v446.Y
								v450 = v446.Z
								v445 = Vector3.new(v448, v449, v450)
							elseif p_u_419.ReSizeScopeVector == "Z" then
								v451 = v446.X
								v452 = v446.Y
								v453 = v446.Z / p_u_419.ReSizeScope
								v445 = Vector3.new(v451, v452, v453)
							end
							TweenService:Create(v444[v458], v447, { Size = v445 }):Play()
						end
					end
				end
				if p_u_419.sight then
					for _54, v459 in pairs((p_u_419.sight:GetChildren())) do
						if v459:GetAttribute("aimHide") then
							v459.Transparency = 1
						end
					end
				end
				if p_u_419.sight and p_u_419.sight:FindFirstChild("Glass") then
					v454 = TweenInfo.new(0.1, Enum.EasingStyle.Quart)
					TweenService:Create(p_u_419.sight.Glass, v454, { Transparency = 1 }):Play()
				end
				v433 = true
			end
		end
		if not v433 then
			if p_u_419.ToolStance == "Ready" and (p_u_419.isEquipped or p_u_419.equipping) then
				local v460 = true
				for v461 = 1, #p_u_419.CancelTables do
					if p_u_419.CancelTables[v461].Visible == true then
						v460 = false
						break
					end
				end
				if v460 then
					p_u_419.actionId = math.random(-1000000, 1000000)
					_52 = p_u_419.actionId
					if p_u_419.sight and p_u_419.variableZoom then
						if not p_u_419.zoomIndex then
							p_u_419.zoomIndex = 1
						end
						v434 = p_u_419.variableZoom
						v435 = p_u_419.zoomIndex
						p_u_419.zoomAmount = v434[tostring(v435)]
						if p_u_419.sight.PrimaryPart:FindFirstChild("ZoomWeld") then
							v436 = 0.155 + p_u_419.zoomAmount * 0.16
							TweenService:Create(p_u_419.sight.PrimaryPart.ZoomWeld, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(0, 0, v436) }):Play()
						end
						v437 = p_u_419.sight:FindFirstChild("Reticle") or p_u_419.sight.AimPart
						if v437:FindFirstChild("PrismScopeGui") then
							v438 = v437.PrismScopeGui
							if v438.Sight:FindFirstChild("ZoomDisplay") then
								for _53, v457 in pairs((v438.Sight.ZoomDisplay:GetChildren())) do
									v457.Visible = false
								end
								v439 = v438.Sight.ZoomDisplay
								v440 = p_u_419.zoomIndex
								v439["Zoom" .. tostring(v440)].Visible = true
							end
						end
						if v437:FindFirstChild("ScopeGui") then
							v441 = v437.ScopeGui
							if v441.Sight:FindFirstChild("CloseSight") then
								v442 = { Size = v441.Sight.CloseSight:GetAttribute("Zoom" .. p_u_419.zoomIndex) }
								TweenService:Create(v441.Sight.CloseSight, TweenInfo.new(p_u_419.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v442):Play()
							end
							if v441.Sight:FindFirstChild("FarSight") then
								v443 = { Size = v441.Sight.FarSight:GetAttribute("Zoom" .. p_u_419.zoomIndex) }
								TweenService:Create(v441.Sight.FarSight, TweenInfo.new(p_u_419.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v443):Play()
							end
						end
					end
					v_u_6:SetZoomTarget(p_u_419.zoomAmount, p_u_419.Scope, 0.3)
					p_u_419:ambientBoostUpdate(p_u_419.ambientBoost, p_u_419.nightVisionColor, p_u_419.grainEffect, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					p_u_419:thermalVisionUpdate(p_u_419.thermalVisionColor and 1 or 0, p_u_419.thermalVisionColor, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
					if p_u_419.worldModel.ItemRoot.Sounds:FindFirstChild("Aim") then
						SoundHandler:PlayEquippedItem("Aim", p_u_419.character, 2)
						SoundHandler:Play(p_u_419.worldModel.ItemRoot.Sounds.Aim, p_u_419.SoundsTemp)
					end
					if p_u_419.SightCycleIndex ~= v421 and p_u_419.ReSizeScope ~= 0 then
						v444 = p_u_419.viewModel:GetDescendants()
						for v458 = 1, #v444 do
							if v444[v458]:IsA("BasePart") and v444[v458]:FindFirstChild("ScopePart") then
								v445 = v444[v458].Size
								if v444[v458]:FindFirstChild("ScopePart").Value == Vector3.new(0, 0, 0) then
									v444[v458]:FindFirstChild("ScopePart").Value = v444[v458].Size
									v446 = v445
								else
									v446 = v444[v458]:FindFirstChild("ScopePart").Value
								end
								v447 = TweenInfo.new(0.1, Enum.EasingStyle.Quart)
								if p_u_419.ReSizeScopeVector == "X" then
									v448 = v446.X / p_u_419.ReSizeScope
									v449 = v446.Y
									v450 = v446.Z
									v445 = Vector3.new(v448, v449, v450)
								elseif p_u_419.ReSizeScopeVector == "Z" then
									v451 = v446.X
									v452 = v446.Y
									v453 = v446.Z / p_u_419.ReSizeScope
									v445 = Vector3.new(v451, v452, v453)
								end
								TweenService:Create(v444[v458], v447, { Size = v445 }):Play()
							end
						end
					end
					if p_u_419.sight then
						for _54, v459 in pairs((p_u_419.sight:GetChildren())) do
							if v459:GetAttribute("aimHide") then
								v459.Transparency = 1
							end
						end
					end
					if p_u_419.sight and p_u_419.sight:FindFirstChild("Glass") then
						v454 = TweenInfo.new(0.1, Enum.EasingStyle.Quart)
						TweenService:Create(p_u_419.sight.Glass, v454, { Transparency = 1 }):Play()
					end
				end
			end
		end
		if p_u_419.SightCycleIndex ~= v421 and (p_u_419.sight and p_u_419.sight.Reticle:FindFirstChild("ScopeGui")) then
			p_u_419.sight.Reticle.ScopeGui.Enabled = true
		end
		local Scope2 = p_u_419.Scope
		if p_u_419.SightCycleIndex ~= v421 and p_u_419.Scope then
			task.spawn(function()
				--[[ line: 3724 | upvalues: (copy) Scope2, (copy) p_u_419]]
				-- irreducible control flow represented as a structured state loop
				local v462, v463, v464, v465, v466, v467
				local v468 = 40
				while v468 do
					if v468 == 40 then
						v468 = 0
					elseif v468 == 0 then
						if Scope2 ~= p_u_419.Scope then
							return
						end
						v468 = 1
					elseif v468 == 1 then
						wait(0.1)
						if p_u_419.Scope and p_u_419.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_419.Scope).Visible == false then
							v468 = 5
						else
							v468 = 0
						end
					elseif v468 == 5 then
						if p_u_419.ToolStance == "Aim" and (p_u_419.isEquipped or p_u_419.equipping) then
							v468 = 9
						else
							v468 = 7
						end
					elseif v468 == 7 then
						if p_u_419.ToolStance == "Ready" and (p_u_419.isEquipped or p_u_419.equipping) then
							v468 = 18
						else
							v468 = 16
						end
					elseif v468 == 16 then
						if p_u_419.sight.Reticle:FindFirstChild("PrismScopeGui") then
							p_u_419.sight.Reticle.PrismScopeGui.Enabled = false
						end
						if not p_u_419.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_419.Scope):FindFirstChild("Sight") then
							v462 = p_u_419.viewModel:GetDescendants()
							for v469 = 1, #v462 do
								if v462[v469]:IsA("BasePart") or v462[v469]:IsA("Decal") then
									v462[v469].Transparency = v462[v469]:GetAttribute("OriginalTransparency") or 0
								end
							end
						end
						v468 = nil
					elseif v468 == 18 then
						v463 = p_u_419
						v464 = true
						for v470 = 1, #v463.CancelTables do
							if v463.CancelTables[v470].Visible == true then
								v464 = false
								break
							end
						end
						if v464 then
							v468 = 14
						else
							v468 = 16
						end
					elseif v468 == 14 then
						if p_u_419.sight.Reticle:FindFirstChild("PrismScopeGui") then
							p_u_419.sight.Reticle.PrismScopeGui.Enabled = true
						end
						if not p_u_419.noInsetGui.MainFrame.ScreenEffects.Scopes:FindFirstChild(p_u_419.Scope):FindFirstChild("Sight") then
							v465 = p_u_419.viewModel:GetDescendants()
							for v471 = 1, #v465 do
								if v465[v471]:IsA("BasePart") and v465[v471].Name ~= "Reticle" or v465[v471]:IsA("Decal") then
									v465[v471].Transparency = 1
								end
							end
						end
						v468 = nil
					elseif v468 == 9 then
						v466 = p_u_419
						v467 = true
						for v472 = 1, #v466.CancelTables do
							if v466.CancelTables[v472].Visible == true then
								v467 = false
								break
							end
						end
						if v467 then
							v468 = 14
						else
							v468 = 7
						end
					else
						v468 = nil
					end
				end
			end)
		end
		p_u_419.SightCycleIndex = v421
	end
end
function t.inspect(p_u_473)
	--[[ line: 3772 | upvalues: (copy) SoundHandler, (copy) TweenService]]
	if p_u_473.worldModel and (p_u_473.reloading == false and (p_u_473.isAiming == false and (p_u_473.clientAnimationTracks.Inspect and not (p_u_473.clientAnimationTracks.Inspect.IsPlaying or p_u_473.useDebounce)))) then
		SoundHandler:PlayEquippedItem("Inspect", p_u_473.character, 2)
		local v_u_474 = SoundHandler:Play(p_u_473.worldModel.ItemRoot.Sounds.Inspect, p_u_473.SoundsTemp)
		p_u_473.clientAnimationTracks.Inspect:Play()
		p_u_473.serverAnimationTracks.Inspect:Play()
		p_u_473.actionId = math.random(-1000000, 1000000)
		local _55 = p_u_473.actionId
		if p_u_473.leftHandGrip_ik then
			task.spawn(function()
				--[[ line: 3783 | upvalues: (copy) p_u_473, (ref) TweenService]]
				local Length3 = p_u_473.clientAnimationTracks.Inspect.Length
				local v475 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
				TweenService:Create(p_u_473.leftHandGrip_ik, v475, { Weight = 0 }):Play()
				task.wait(Length3 - 0.3)
				local _56 = p_u_473.clientAnimationTracks.Inspect.Length
				local v476 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
				TweenService:Create(p_u_473.leftHandGrip_ik, v476, { Weight = 1 }):Play()
			end)
		end
		task.spawn(function()
			--[[ line: 3800 | upvalues: (copy) p_u_473, (copy) v_u_474, (ref) SoundHandler]]
			p_u_473.clientAnimationTracks.Inspect.Stopped:Wait()
			p_u_473.inspecting = false
			if v_u_474 then
				SoundHandler:StopEquippedItem("Inspect", p_u_473.character, 2)
				v_u_474:Stop()
			end
		end)
	end
end
function t.toggleAttachmentExtra(p_u_477)
	--[[ line: 3811 | upvalues: (copy) v_u_7, (copy) SoundHandler, (copy) ToggleAttachment, (copy) VehicleInteractions]]
	if p_u_477.weapon and (p_u_477.weapon:FindFirstChild("Attachments") and p_u_477.weapon.Attachments:GetAttribute("Extra")) then
		local v478 = v_u_7:FindFirstChildOfSlotType(p_u_477.weapon.Attachments, "Extra")
		if v478 and v478.Value.ItemProperties.Attachment:GetAttribute("Active") ~= nil then
			SoundHandler:PlayEquippedItem("FireSelector", p_u_477.character, 2)
			SoundHandler:Play(p_u_477.worldModel.ItemRoot.Sounds.FireSelector, p_u_477.SoundsTemp)
			task.spawn(function()
				--[[ line: 3820 | upvalues: (ref) v_u_7, (copy) p_u_477, (ref) ToggleAttachment]]
				ToggleAttachment:InvokeServer((v_u_7:FindFirstChildOfSlotType(p_u_477.weapon.Attachments, "Extra")))
			end)
		end
	end
	if p_u_477.rs_Player.Status.GameplayVariables.Vehicle.CurrentSeat.Value and p_u_477.rs_Player.Status.GameplayVariables.Vehicle.CurrentSeat.Value.ClassName == "VehicleSeat" then
		VehicleInteractions:FireServer({ Action = "HeadLights" })
	end
end
function t.zoomScope(p479, p480, p481)
	--[[ line: 3839 | upvalues: (copy) v_u_7, (copy) SoundHandler, (copy) TweenService, (copy) v_u_6]]
	if p479.variableZoom then
		if p479.isAiming then
			local v482 = v_u_7:FindFirstChildOfSlotType(p479.weapon.Attachments, "Sight")
			if v482 then
				if not p479.zoomIndex then
					p479.zoomIndex = 1
				end
				local zoomIndex4 = p479.zoomIndex
				p479.zoomIndex = p479.zoomIndex + p480
				local v483 = 0
				for _57, _58 in pairs(p479.variableZoom) do
					v483 = v483 + 1
				end
				if v483 < p479.zoomIndex then
					if p481 then
						p479.zoomIndex = 1
					else
						p479.zoomIndex = v483
					end
				end
				if p479.zoomIndex < 1 then
					p479.zoomIndex = 1
				end
				v482:SetAttribute("ZoomIndex", p479.zoomIndex)
				if p479.zoomIndex ~= zoomIndex4 then
					local variableZoom3 = p479.variableZoom
					local zoomIndex5 = p479.zoomIndex
					p479.zoomAmount = variableZoom3[tostring(zoomIndex5)]
					SoundHandler:PlayEquippedItem("Zoom", p479.character, 2)
					SoundHandler:Play(p479.worldModel.ItemRoot.Sounds.Zoom, p479.SoundsTemp)
					if p479.sight.PrimaryPart:FindFirstChild("ZoomWeld") then
						local v484 = 0.155 + p479.zoomAmount * 0.16
						TweenService:Create(p479.sight.PrimaryPart.ZoomWeld, TweenInfo.new(p479.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = CFrame.new(0, 0, v484) }):Play()
					end
					local v485 = p479.sight:FindFirstChild("Reticle") or p479.sight.AimPart
					if v485:FindFirstChild("PrismScopeGui") then
						local PrismScopeGui3 = v485.PrismScopeGui
						if PrismScopeGui3.Sight:FindFirstChild("ZoomDisplay") then
							for _59, v486 in pairs((PrismScopeGui3.Sight.ZoomDisplay:GetChildren())) do
								v486.Visible = false
							end
							local ZoomDisplay2 = PrismScopeGui3.Sight.ZoomDisplay
							local zoomIndex6 = p479.zoomIndex
							ZoomDisplay2["Zoom" .. tostring(zoomIndex6)].Visible = true
						end
					end
					if v485:FindFirstChild("ScopeGui") then
						local ScopeGui3 = v485.ScopeGui
						if ScopeGui3.Sight:FindFirstChild("CloseSight") then
							local t11 = { Size = ScopeGui3.Sight.CloseSight:GetAttribute("Zoom" .. p479.zoomIndex) }
							TweenService:Create(ScopeGui3.Sight.CloseSight, TweenInfo.new(p479.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), t11):Play()
						end
						if ScopeGui3.Sight:FindFirstChild("FarSight") then
							local t12 = { Size = ScopeGui3.Sight.FarSight:GetAttribute("Zoom" .. p479.zoomIndex) }
							TweenService:Create(ScopeGui3.Sight.FarSight, TweenInfo.new(p479.zoomSpeed * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), t12):Play()
						end
					end
					v_u_6:SetZoomTarget(p479.zoomAmount, p479.Scope, p479.zoomSpeed)
				end
			else
				return
			end
		else
			return
		end
	else
		return
	end
end
function t.ambientBoostUpdate(_60, p487, p488, p489, p490, p491, p492)
	--[[ line: 3939 | upvalues: (copy) v_u_4]]
	v_u_4:SetScopeTarget(p487, p488, p489, p490, p491, p492)
end
function t.thermalVisionUpdate(_61, p493, p494, p495, p496, p497, p498)
	--[[ line: 3943 | upvalues: (copy) v_u_5]]
	v_u_5:SetScopeTarget(p493, p494, p495, p496, p497, p498)
end
function t.equip(p_u_499, p500, p_u_501)
	--[[ line: 3947 | upvalues: (copy) CurrentCamera, (copy) v_u_7, (copy) createWorldModel, (copy) RangedWeapons, (copy) viewModel, (copy) attachmentsCheck, (copy) UpdateBulletsList, (copy) MagazineTypeCheck, (copy) viewModelClothes, (copy) SoundHandler, (copy) TweenService, (copy) t3, (copy) UpdateViewmodel]]
	if CurrentCamera.CameraSubject == p_u_499.humanoid and (v_u_7:IsPlayerAlive(p_u_499.player) and p500) then
		p_u_499.equipAttemptId = p_u_499.equipAttemptId + 1
		p_u_499:unequip(true)
		p_u_499.weapon = p500
		p_u_499.equipping = true
		createWorldModel(p_u_499, p500)
		p_u_499.itemProperties = p_u_499.weapon.Value.ItemProperties
		p_u_499.MaxAmmo = 1
		p_u_499.weaponInfo = RangedWeapons:FindFirstChild(p_u_499.weapon.Name)
		if p_u_499.weaponInfo then
			p_u_499.ReloadLength = p_u_499.weaponInfo:GetAttribute("ReloadLength") or 0
			p_u_499.ReloadChamberLength = p_u_499.weaponInfo:GetAttribute("ReloadChamberLength") or 0
			p_u_499.ReloadNoMagLength = p_u_499.weaponInfo:GetAttribute("ReloadNoMagLength") or 0
		end
		p_u_499.settings = require(p_u_499.weapon.Value.SettingsModule)
		p_u_499.Operational = true
		if p_u_499.weapon:FindFirstChild("Attachments") and p_u_499.itemProperties:FindFirstChild("VitalParts") then
			local v502 = p_u_499.itemProperties.VitalParts:GetAttributes()
			for v503, _62 in pairs(v502) do
				local v504 = v_u_7:FindFirstChildOfSlotType(p_u_499.weapon.Attachments, v503)
				local v505 = v_u_7:FindFirstChildOfSlotType(p_u_499.weapon.Attachments, "Stock")
				if v504 == nil and v503 ~= "Handle" or (v504 == nil and not v505 or v504 == nil and (v503 == "Handle" and (v505 and not v505.Value.ItemProperties.Attachment:GetAttribute("UseAsHandle")))) then
					p_u_499.Operational = false
					break
				end
			end
		end
		p_u_499.RightMouseDown = false
		p_u_499.LeftMouseDown = false
		p_u_499.lastUseTime = 0
		p_u_499.timeSinceUse = 0
		p_u_499.timeNow = 0
		p_u_499.timeTotal = 0
		p_u_499.MouseHeldTime = 0
		p_u_499.jump = 0
		p_u_499.reAimDebunce = true
		p_u_499.RecoilTValue = 0
		p_u_499.RecoilReduction = 0
		p_u_499.EquipTValue = p_u_499.settings.EquipTValue or -75
		p_u_499.firedInRow = 0
		p_u_499.MouseHeld = false
		p_u_499.Mouse2Held = false
		p_u_499.reloading = false
		p_u_499.cancellingReload = false
		p_u_499.oldCamCF = nil
		p_u_499.oldCamCF2 = nil
		p_u_499.altUseCounter = 0
		p_u_499.useDebounce = false
		p_u_499.Bullets = 0
		p_u_499.sight = nil
		p_u_499.weaponOffSet = p_u_499.settings.weaponOffSet
		p_u_499.aimOffSet = CFrame.new()
		p_u_499.TempCFrame = nil
		p_u_499.sprintOffSet = p_u_499.settings.sprintOffSet or Vector3.new(1, 1, 1)
		p_u_499.AimInSpeed = p_u_499.settings.AimInSpeed or 0.3
		p_u_499.AimOutSpeed = p_u_499.settings.AimOutSpeed or 0.3
		p_u_499.swayMult = p_u_499.settings.swayMult or 0.1
		p_u_499.useDof = p_u_499.settings.useDof or false
		p_u_499.allowAiming = p_u_499.settings.allowAiming or false
		p_u_499.useModuleName = p_u_499.settings.useModuleName
		p_u_499.reloadType = p_u_499.settings.reloadType
		p_u_499.WeldHand = p_u_499.settings.WeldHand or "RightHand"
		p_u_499.FireRate = p_u_499.settings.FireRate or 0.1
		p_u_499.FireModes = p_u_499.settings.FireModes or { "" }
		p_u_499.FireModeIndex = 1
		p_u_499.SightCycleIndex = 1
		if p_u_499.weapon:GetAttribute("FireModeIndexS") then
			local weapon7 = p_u_499.weapon
			if typeof((weapon7:GetAttribute("FireModeIndexS"))) == "number" and p_u_499.FireModes[p_u_499.weapon:GetAttribute("FireModeIndexS")] then
				p_u_499.FireModeIndex = p_u_499.weapon:GetAttribute("FireModeIndexS")
				p_u_499.weapon:SetAttribute("FireMode", p_u_499.FireModes[p_u_499.FireModeIndex])
			elseif p_u_499.weapon:GetAttribute("FireModeIndex") then
				p_u_499.FireModeIndex = p_u_499.weapon:GetAttribute("FireModeIndex")
				p_u_499.weapon:SetAttribute("FireMode", p_u_499.FireModes[p_u_499.FireModeIndex])
			else
				p_u_499.weapon:SetAttribute("FireModeIndex", p_u_499.FireModeIndex)
				p_u_499.FireModeIndex = p_u_499.FireModeIndex
				p_u_499.weapon:SetAttribute("FireMode", p_u_499.FireModes[p_u_499.FireModeIndex])
			end
		elseif p_u_499.weapon:GetAttribute("FireModeIndex") then
			p_u_499.FireModeIndex = p_u_499.weapon:GetAttribute("FireModeIndex")
			p_u_499.weapon:SetAttribute("FireMode", p_u_499.FireModes[p_u_499.FireModeIndex])
		else
			p_u_499.weapon:SetAttribute("FireModeIndex", p_u_499.FireModeIndex)
			p_u_499.FireModeIndex = p_u_499.FireModeIndex
			p_u_499.weapon:SetAttribute("FireMode", p_u_499.FireModes[p_u_499.FireModeIndex])
		end
		p_u_499.Scope = p_u_499.settings.Scope
		p_u_499.ReSizeScope = p_u_499.settings.ReSizeScope or 0
		p_u_499.ReSizeScopeVector = p_u_499.settings.ReSizeScopeVector or "Z"
		p_u_499.CycleTiming = p_u_499.settings.CycleTiming
		p_u_499.ReloadTiming = p_u_499.settings.ReloadTiming
		p_u_499.AimWhileActing = p_u_499.settings.AimWhileActing or true
		p_u_499.PlayRackSoundBeforeEnd = p_u_499.settings.PlayRackSoundBeforeEnd or false
		p_u_499.AimReadyTime = p_u_499.settings.AimReadyTime or 0.4
		p_u_499.ItemLength = p_u_499.settings.ItemLength
		p_u_499.TouchWallPosY = p_u_499.settings.TouchWallPosY
		p_u_499.TouchWallPosZ = p_u_499.settings.TouchWallPosZ
		p_u_499.TouchWallRotX = p_u_499.settings.TouchWallRotX * 1.3
		p_u_499.TouchWallRotY = p_u_499.settings.TouchWallRotY * 1.3
		p_u_499.RecoilPatternPos = 0
		p_u_499.RecoilPatternRecoverySpeed = 0.6
		p_u_499.MaximumKickBack = p_u_499.settings.MaximumKickBack or 1
		p_u_499.MaxRecoil = p_u_499.settings.MaxRecoil or 4
		p_u_499.ReductionStartTime = p_u_499.settings.ReductionStartTime or 15
		p_u_499.RecoilReductionMax = p_u_499.settings.RecoilReductionMax or 1
		p_u_499.RecoilTValueMax = p_u_499.settings.RecoilTValueMax or 5
		p_u_499.IdleSwayModifier = p_u_499.settings.IdleSwayModifier
		p_u_499.WalkSwayModifer = p_u_499.settings.WalkSwayModifer
		p_u_499.SprintSwayModifer = p_u_499.settings.SprintSwayModifer
		p_u_499.meleeHitEffect = p_u_499.settings.meleeHitEffect or false
		p_u_499.swingStartWait = p_u_499.settings.swingStartWait or 0
		p_u_499.swingEndWait = p_u_499.settings.swingEndWait or 0
		p_u_499.swingSpeedMod = p_u_499.settings.swingSpeedMod or 0
		p_u_499.clientAnimationTracks = {}
		p_u_499.serverAnimationTracks = {}
		p_u_499.viewModel = viewModel(p_u_499)
		if p_u_499.viewModel then
			local Offsets = p_u_499.viewModel.Item:FindFirstChild("Offsets")
			if Offsets then
				Offsets = p_u_499.viewModel.Item.Offsets:FindFirstChild("AimPart")
			end
			p_u_499.aimPart = Offsets
			p_u_499.aimParts = {}
			local t13 = {
				Sight = nil,
				Scope = nil,
				ReSizeScope = 0,
				adsBlock = true,
				ReSizeScopeVector = "Z",
				AmbientBoost = 0,
				GrainEffect = 1,
				VariableZoom = nil,
				AimPart = p_u_499.aimPart
			}
			local Tool = p_u_499.itemProperties:FindFirstChild("Tool")
			if Tool then
				Tool = p_u_499.itemProperties.Tool:GetAttribute("Zoom")
			end
			t13.ZoomAmount = Tool
			t13.NightVisionColor = Color3.new(1, 1, 1)
			local aimParts = p_u_499.aimParts
			table.insert(aimParts, t13)
			if p_u_499.viewModel.Item:FindFirstChild("Offsets") and p_u_499.viewModel.Item.Offsets:FindFirstChild("AimPartCanted") then
				local t14 = {
					Sight = nil,
					Scope = nil,
					ReSizeScope = 0,
					ReSizeScopeVector = "Z",
					AmbientBoost = 0,
					GrainEffect = 1,
					VariableZoom = nil,
					AimPart = p_u_499.viewModel.Item.Offsets:FindFirstChild("AimPartCanted")
				}
				local Tool2 = p_u_499.itemProperties:FindFirstChild("Tool")
				if Tool2 then
					Tool2 = p_u_499.itemProperties.Tool:GetAttribute("Zoom")
				end
				t14.ZoomAmount = Tool2
				t14.NightVisionColor = Color3.new(1, 1, 1)
				local aimParts2 = p_u_499.aimParts
				table.insert(aimParts2, t14)
			end
			p_u_499.aimPart = p_u_499.aimParts[1].AimPart
			p_u_499.zoomAmount = p_u_499.aimParts[1].ZoomAmount
			p_u_499.ambientBoost = p_u_499.aimParts[1].AmbientBoost
			p_u_499.nightVisionColor = p_u_499.aimParts[1].NightVisionColor
			p_u_499.grainEffect = p_u_499.aimParts[1].GrainEffect
			p_u_499.thermalVisionColor = p_u_499.aimParts[1].ThermalVisionColor
			p_u_499.variableZoom = p_u_499.aimParts[1].VariableZoom
			p_u_499.zoomSpeed = p_u_499.aimParts[1].ZoomSpeed
			p_u_499.zoomIndex = p_u_499.aimParts[1].ZoomIndex
			p_u_499.barrel = p_u_499.viewModel.Item:FindFirstChild("Barrel")
			attachmentsCheck(p_u_499)
			UpdateBulletsList(p_u_499)
			if p_u_499.weapon:FindFirstChild("Attachments") then
				if p_u_499.weapon.Attachments:GetAttribute("Magazine") then
					MagazineTypeCheck(p_u_499)
					local v506 = v_u_7:FindFirstChildOfSlotType(p_u_499.weapon.Attachments, "Magazine")
					if v506 then
						p_u_499.MaxAmmo = v506.Value.ItemProperties:GetAttribute("MaxLoadedAmmo")
					end
					local Magazine3 = p_u_499.viewModel.Item.Attachments:FindFirstChild("Magazine")
					if Magazine3 then
						local Bullets3 = p_u_499.Bullets
						if Magazine3:FindFirstChild("Bullet1") then
							if Bullets3 > 0 then
								Magazine3.Bullet1.Transparency = 0
							else
								Magazine3.Bullet1.Transparency = 1
							end
						end
						if Magazine3:FindFirstChild("Bullet2") then
							if Bullets3 > 1 then
								Magazine3.Bullet2.Transparency = 0
							else
								Magazine3.Bullet2.Transparency = 1
							end
						end
						if Magazine3:FindFirstChild("AmmoBelt") then
							for _63, v507 in pairs((Magazine3.AmmoBelt:GetChildren())) do
								if v507:GetAttribute("Order") then
									local v508 = Bullets3 <= v507:GetAttribute("Order") and 1 or 0
									for _64, v509 in pairs((v507:GetChildren())) do
										v509.Transparency = v508
									end
								end
							end
						end
					end
				else
					local Bullets4 = p_u_499.Bullets
					if p_u_499.viewModel.Item:FindFirstChild("Bullets") then
						if p_u_499.viewModel.Item.Bullets:FindFirstChild("Bullet1") then
							if Bullets4 > 0 then
								p_u_499.viewModel.Item.Bullets.Bullet1.Transparency = 0
							else
								p_u_499.viewModel.Item.Bullets.Bullet1.Transparency = 1
							end
						end
						if p_u_499.viewModel.Item.Bullets:FindFirstChild("Bullet2") then
							if Bullets4 > 1 then
								p_u_499.viewModel.Item.Bullets.Bullet2.Transparency = 0
							else
								p_u_499.viewModel.Item.Bullets.Bullet2.Transparency = 1
							end
						end
					end
					p_u_499.MaxAmmo = p_u_499.itemProperties:GetAttribute("MaxLoadedAmmo")
				end
			end
			local v510 = p_u_499.viewModel:GetDescendants()
			for _65, v511 in pairs(v510) do
				if v511:IsA("BasePart") then
					v511.CastShadow = false
				end
			end
			for _66, v512 in pairs((p_u_499.character.Clothing:GetChildren())) do
				p_u_499.Connections["ClothingConnection_" .. v512.Name] = v512.Changed:Connect(function()
					--[[ line: 4218 | upvalues: (ref) viewModelClothes, (copy) p_u_499, (ref) v_u_7]]
					viewModelClothes(p_u_499, p_u_499.viewModel)
					task.delay(0.1, function()
						--[[ line: 4221 | upvalues: (ref) p_u_499, (ref) v_u_7]]
						local v513 = p_u_499.rs_Player.Inventory:GetChildren()
						for v514 = 1, #v513 do
							if v_u_7:IsInClothingSlot(v513[v514]) and (v513[v514].Value.ItemProperties.Clothing:GetAttribute("BlockADS") and p_u_499.itemProperties:GetAttribute("SlotType") ~= "Pistol") then
								p_u_499:cycleSight()
								return
							end
						end
					end)
				end)
			end
			if p_u_499.allowAiming and p_u_499.aimPart then
				p_u_499.TempCFrame = p_u_499.aimPart.TempCFrame
				p_u_499.TempCFrame.Value = p_u_499.weaponOffSet
			else
				p_u_499.TempCFrame = {}
				p_u_499.TempCFrame.Value = p_u_499.weaponOffSet
			end
			if p_u_499.viewModel.Item:FindFirstChild("AmmoTypes") then
				local Value3 = p_u_499.itemProperties.AmmoType.Value
				local v515 = p_u_499.viewModel.Item.AmmoTypes:GetChildren()
				for v516 = 1, #v515 do
					v515[v516].Transparency = 1
				end
				p_u_499.viewModel.Item.AmmoTypes:FindFirstChild(Value3).Transparency = 0
				if p_u_499.viewModel.Item:FindFirstChild("AmmoTypes2") then
					local v517 = p_u_499.viewModel.Item.AmmoTypes2:GetChildren()
					for v518 = 1, #v517 do
						v517[v518].Transparency = 1
					end
					p_u_499.viewModel.Item.AmmoTypes2:FindFirstChild(Value3).Transparency = 0
				end
			end
			local KeybindHints2 = p_u_499.mainGui.MainFrame.InteractionFrame.KeybindHints
			if #p_u_499.FireModes > 1 then
				KeybindHints2.CycleFiremode.Visible = true
			end
			if #p_u_499.aimParts > 1 then
				KeybindHints2.CycleSights.Visible = true
			end
			if p_u_499.reloadType then
				KeybindHints2.Reload.Visible = true
			end
		end
		p_u_499.movementModifier = 0
		if p_u_499.weapon and p_u_499.itemProperties:FindFirstChild("Tool") then
			p_u_499.movementModifier = p_u_499.movementModifier + (p_u_499.itemProperties.Tool:GetAttribute("MovementModifer") or 0)
			if p_u_499.weapon:FindFirstChild("Attachments") then
				local v519 = p_u_499.weapon.Attachments:GetChildren()
				for v520 = 1, #v519 do
					if v519[v520].Value.ItemProperties:FindFirstChild("Attachment") then
						p_u_499.movementModifier = p_u_499.movementModifier + (v519[v520].Value.ItemProperties.Attachment:GetAttribute("MovementModifer") or 0)
					end
				end
			end
		end
		if p_u_499.viewModel then
			for v521, v522 in pairs(p_u_499.settings.Animations.FirstPerson) do
				local Animation = Instance.new("Animation")
				Animation.AnimationId = v522
				Animation.Name = v521
				p_u_499.clientAnimationTracks[v521] = p_u_499.viewModel.Humanoid.Animator:LoadAnimation(Animation)
				p_u_499.clientAnimationTracks[v521].Name = v521
				Animation:Destroy()
				p_u_499.Connections.PlaySound = p_u_499.clientAnimationTracks[v521]:GetMarkerReachedSignal("PlaySound"):Connect(function(p523)
					--[[ line: 4302 | upvalues: (copy) p_u_499, (ref) SoundHandler]]
					local v524 = p_u_499.worldModel.ItemRoot.Sounds:FindFirstChild(p523)
					SoundHandler:PlayEquippedItem(v524.Name, p_u_499.character, 2)
					SoundHandler:Play(v524, p_u_499.SoundsTemp)
				end)
			end
		end
		for v525, v526 in pairs(p_u_499.settings.Animations.ThirdPerson) do
			local Animation2 = Instance.new("Animation")
			Animation2.AnimationId = v526
			Animation2.Name = v525
			p_u_499.serverAnimationTracks[v525] = p_u_499.humanoid.Animator:LoadAnimation(Animation2)
			p_u_499.serverAnimationTracks[v525].Name = v525
			Animation2:Destroy()
		end
		p_u_499.Connections.Empty = p_u_499.weapon:GetAttributeChangedSignal("Empty"):Connect(function()
			--[[ line: 4321 | upvalues: (copy) p_u_499]]
			for _67, v527 in pairs((p_u_499.worldModel:GetChildren())) do
				if v527:GetAttribute("HideEmpty") then
					v527.Transparency = p_u_499.weapon:GetAttribute("Empty") and 1 or 0
				end
			end
			for _68, v528 in pairs((p_u_499.viewModel.Item:GetChildren())) do
				if v528:GetAttribute("HideEmpty") then
					v528.Transparency = p_u_499.weapon:GetAttribute("Empty") and 1 or 0
				end
			end
		end)
		if p_u_499.Bullets == 0 then
			if p_u_499.clientAnimationTracks.Empty then
				p_u_499.clientAnimationTracks.Empty:Play()
			end
			if p_u_499.serverAnimationTracks.Empty then
				p_u_499.serverAnimationTracks.Empty:Play()
			end
			for _69, v529 in pairs((p_u_499.worldModel:GetChildren())) do
				if v529:GetAttribute("HideEmpty") then
					v529.Transparency = 1
				end
			end
			for _70, v530 in pairs((p_u_499.viewModel.Item:GetChildren())) do
				if v530:GetAttribute("HideEmpty") then
					v530.Transparency = 1
				end
			end
		end
		if p_u_499.clientAnimationTracks.BoltOpen then
			p_u_499.clientAnimationTracks.BoltOpen:Play()
		end
		if p_u_499.serverAnimationTracks.BoltOpen then
			p_u_499.serverAnimationTracks.BoltOpen:Play()
		end
		if p_u_499.viewModel then
			if p_u_499.settings.sprintOffset2 then
				p_u_499.sprintIdleOffset = p_u_499.viewModel.Item:FindFirstChild("Offsets") and p_u_499.viewModel.Item.Offsets.Sprint.CFrame:ToObjectSpace((p_u_499.viewModel:GetPivot())) * p_u_499.settings.sprintOffset2 or p_u_499.weaponOffSet * CFrame.new(0, -0.15, 0)
			else
				p_u_499.sprintIdleOffset = p_u_499.viewModel.Item:FindFirstChild("Offsets") and p_u_499.viewModel.Item.Offsets.Sprint.CFrame:ToObjectSpace((p_u_499.viewModel:GetPivot())) * CFrame.new(-0.3, 0, -0.55) or p_u_499.weaponOffSet * CFrame.new(0, -0.15, 0)
			end
			if p_u_499.clientAnimationTracks.Equip then
				p_u_499.clientAnimationTracks.Equip:Play(0)
			end
			if p_u_499.clientAnimationTracks.Idle then
				p_u_499.clientAnimationTracks.Idle:Play()
			end
			local v531 = nil
			for _71, v532 in pairs((p_u_499.viewModel.Item:GetDescendants())) do
				if v532.Name == "LeftHandGripOffset" then
					v531 = v532
				end
			end
			if v531 then
				p_u_499.leftHandGrip_ik = Instance.new("IKControl")
				p_u_499.leftHandGrip_ik.Name = "LeftHandGrip_IK"
				p_u_499.leftHandGrip_ik.Type = Enum.IKControlType.Position
				p_u_499.leftHandGrip_ik.ChainRoot = p_u_499.viewModel.LeftUpperArm
				p_u_499.leftHandGrip_ik.EndEffector = p_u_499.viewModel.LeftLowerArm
				p_u_499.leftHandGrip_ik.Target = v531
				p_u_499.leftHandGrip_ik.Weight = 0
				p_u_499.leftHandGrip_ik.SmoothTime = 0
				p_u_499.leftHandGrip_ik.Parent = p_u_499.viewModel.Humanoid
				p_u_499.actionId = math.random(-1000000, 1000000)
				local _72 = p_u_499.actionId
				if p_u_499.leftHandGrip_ik then
					task.spawn(function()
						--[[ line: 4388 | upvalues: (copy) p_u_499, (ref) TweenService]]
						local Length4 = p_u_499.clientAnimationTracks.Equip.Length
						local v533 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, Length4 - 0.3)
						TweenService:Create(p_u_499.leftHandGrip_ik, v533, { Weight = 1 }):Play()
					end)
				end
			end
		else
			p_u_499.sprintIdleOffset = CFrame.new()
		end
		if p_u_499.serverAnimationTracks.Equip then
			p_u_499.serverAnimationTracks.Equip:Play(0)
		end
		if p_u_499.serverAnimationTracks.Idle then
			p_u_499.serverAnimationTracks.Idle:Play()
		end
		SoundHandler:PlayEquippedItem("Equip", p_u_499.character, 3)
		SoundHandler:Play(p_u_499.worldModel.ItemRoot.Sounds.Equip, p_u_499.SoundsTemp)
		if p_u_499.weapon:GetAttribute("NeedsCycle") then
			p_u_499.useDebounce = true
		end
		if p_u_499.weapon:GetAttribute("NeedsCycle") then
			task.spawn(function()
				--[[ line: 4416 | upvalues: (copy) p_u_499, (ref) t3]]
				if p_u_499.clientAnimationTracks.Equip then
					task.wait(p_u_499.clientAnimationTracks.Equip.Length * 0.9)
				end
				t3.RangedWeaponDefault(p_u_499)
			end)
		end
		p_u_499.Connections.ViewModelUpdate = UpdateViewmodel.OnClientEvent:Connect(function()
			--[[ line: 4425 | upvalues: (copy) p_u_499, (copy) p_u_501]]
			p_u_499:equip(p_u_499.weapon, p_u_501)
		end)
		p_u_499.ToolStance = "Idle"
		if p_u_499.settings.useModuleName == "RangedWeaponDefault" or (p_u_499.settings.useModuleName == "FlareDefault" or p_u_499.settings.useModuleName == "LauncherDefault") then
			p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "shoot")
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "shoot")
			p_u_499.mobileButtons.GameplayLayer.UseAction2:SetAttribute("Action", p_u_499.settings.allowAiming and "aim" or "default")
			p_u_499.mobileButtons.GameplayLayer.UseAction2.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2.Visible = p_u_499.settings.allowAiming
		elseif p_u_499.settings.useModuleName == "GrenadeDefault" then
			p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "grenade")
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "grenade")
			p_u_499.mobileButtons.GameplayLayer.UseAction1.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2.Visible = true
		elseif p_u_499.settings.useModuleName == "MeleeWeaponDefault" then
			p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "melee")
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "melee")
			p_u_499.mobileButtons.GameplayLayer.UseAction2:SetAttribute("Action", "meleePower")
			p_u_499.mobileButtons.GameplayLayer.UseAction2.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2.Visible = true
		elseif p_u_499.settings.useModuleName == "Consumable" then
			if p_u_499.itemProperties:GetAttribute("ItemType") == "Medical" then
				p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "heal")
				p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "heal")
			else
				p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "consume")
				p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "consume")
			end
			p_u_499.mobileButtons.GameplayLayer.UseAction1.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2.Visible = true
		elseif p_u_499.settings.useModuleName == "KeyDefault" then
			p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "key")
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "key")
			p_u_499.mobileButtons.GameplayLayer.UseAction1.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2.Visible = true
		elseif p_u_499.settings.useModuleName == "Lighter" then
			p_u_499.mobileButtons.GameplayLayer.UseAction2:SetAttribute("Action", "lighter")
			p_u_499.mobileButtons.GameplayLayer.UseAction2.Visible = true
		else
			p_u_499.mobileButtons.GameplayLayer.UseAction1:SetAttribute("Action", "default")
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2:SetAttribute("Action", "default")
			p_u_499.mobileButtons.GameplayLayer.UseAction1.Visible = true
			p_u_499.mobileButtons.GameplayLayer.UseAction1_2.Visible = true
		end
		p_u_499.mobileButtons.GameplayLayer.UseMode.Visible = #p_u_499.FireModes > 1
		p_u_499.mobileButtons.GameplayLayer.TopRow.Inspect.Visible = true
		p_u_499.mobileButtons.GameplayLayer.Reload.Visible = p_u_499.settings.reloadType and true
		p_u_499.mobileButtons.GameplayLayer.Reload:SetAttribute("Action", "reload")
		local Attachment = p_u_499.mobileButtons.GameplayLayer.Attachment
		local v534 = p_u_499.weapon:FindFirstChild("Attachments") and v_u_7:FindFirstChildOfSlotType(p_u_499.weapon.Attachments, "Extra")
		Attachment.Visible = v534 and true or v534
		p_u_499.mobileButtons.GameplayLayer.AimingLayer.Visible = false
		p_u_499.mobileButtons.GameplayLayer.TopRow.CycleSight.Visible = false
		p_u_499.mobileButtons.GameplayLayer.AimingLayer.ZoomIn.Visible = false
		p_u_499.mobileButtons.GameplayLayer.AimingLayer.ZoomOut.Visible = false
		if p_u_499.variableZoom then
			p_u_499.mobileButtons.GameplayLayer.AimingLayer.ZoomIn.Visible = true
			p_u_499.mobileButtons.GameplayLayer.AimingLayer.ZoomOut.Visible = true
		end
		if p_u_501 ~= p_u_499.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
			local equipAttemptId3 = p_u_499.equipAttemptId
			local v535 = 0
			local v536 = 3
			while v535 < v536 and p_u_499.equipping do
				v535 = v535 + task.wait()
				if p_u_501 == p_u_499.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
					break
				end
			end
			if equipAttemptId3 == p_u_499.equipAttemptId and p_u_501 ~= p_u_499.rs_Player.Status.GameplayVariables:GetAttribute("EquipId") then
				warn("id miss match")
				p_u_499:unequip(nil, true)
				return
			end
		end
		p_u_499.equipId = p_u_499.rs_Player.Status.GameplayVariables:GetAttribute("EquipId")
		p_u_499.isEquipped = true
		p_u_499.equipping = false
	end
end
function t.unequip(p537, p538, p539)
	--[[ line: 4545 | upvalues: (copy) v_u_6]]
	p537.isEquipped = false
	p537.equipping = false
	p537.isAiming = false
	p537.character:SetAttribute("isAiming", false)
	p537.movementModifier = 0
	p537.leftHandGrip_ik = nil
	p537.mobileButtons.GameplayLayer.UseAction1.Visible = false
	p537.mobileButtons.GameplayLayer.UseAction1_2.Visible = false
	p537.mobileButtons.GameplayLayer.UseAction2.Visible = false
	p537.mobileButtons.GameplayLayer.UseMode.Visible = false
	p537.mobileButtons.GameplayLayer.TopRow.Inspect.Visible = false
	p537.mobileButtons.GameplayLayer.Reload.Visible = false
	p537.mobileButtons.GameplayLayer.Attachment.Visible = false
	p537.mobileButtons.GameplayLayer.AimingLayer.Visible = false
	p537.mobileButtons.GameplayLayer.TopRow.CycleSight.Visible = false
	v_u_6:SetZoomTarget(1, p537.Scope, 0.3)
	p537:ambientBoostUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
	p537:thermalVisionUpdate(0, Color3.new(1, 1, 1), 1, 0.1)
	local KeybindHints3 = p537.mainGui.MainFrame.InteractionFrame.KeybindHints
	KeybindHints3.CycleFiremode.Visible = false
	KeybindHints3.CycleSights.Visible = false
	KeybindHints3.ToggleAttachment.Visible = false
	KeybindHints3.Reload.Visible = false
	local v540, _73
	if p537.settings and (not p538 and (p537.settings.UnequipTime and p539)) then
		local viewModel4 = p537.viewModel
		task.wait(p537.settings.UnequipTime)
		if viewModel4 == p537.viewModel then
			if p537.viewModel then
				p537.viewModel:Destroy()
			end
			if p537.worldModel then
				p537.worldModel:Destroy()
			end
			v540 = workspace.Camera:GetChildren()
			for v541 = 1, #v540 do
				if v540[v541].Name == "ViewModel" then
					v540[v541]:Destroy()
				end
			end
			p537.SoundsTemp:ClearAllChildren()
			p537.worldModel = nil
			p537.useModuleName = nil
			p537.flashLightActive = false
			p537.laserActive = false
			for v542, _74 in pairs(p537.Connections) do
				p537.Connections[v542]:Disconnect()
				p537.Connections[v542] = nil
			end
			for v543, _75 in pairs(p537.serverAnimationTracks) do
				p537.serverAnimationTracks[v543]:Stop()
				p537.serverAnimationTracks[v543]:Destroy()
				p537.serverAnimationTracks[v543] = nil
			end
			local _73 = p537.Scope
			p537.weapon = nil
			p537.itemProperties = nil
		end
	else
		if p537.viewModel then
			p537.viewModel:Destroy()
		end
		if p537.worldModel then
			p537.worldModel:Destroy()
		end
		v540 = workspace.Camera:GetChildren()
		for v541 = 1, #v540 do
			if v540[v541].Name == "ViewModel" then
				v540[v541]:Destroy()
			end
		end
		p537.SoundsTemp:ClearAllChildren()
		p537.worldModel = nil
		p537.useModuleName = nil
		p537.flashLightActive = false
		p537.laserActive = false
		for v542, _74 in pairs(p537.Connections) do
			p537.Connections[v542]:Disconnect()
			p537.Connections[v542] = nil
		end
		for v543, _75 in pairs(p537.serverAnimationTracks) do
			p537.serverAnimationTracks[v543]:Stop()
			p537.serverAnimationTracks[v543]:Destroy()
			p537.serverAnimationTracks[v543] = nil
		end
		local _73 = p537.Scope
		p537.weapon = nil
		p537.itemProperties = nil
		return
	end
end
function t.sprint(p544, p545, p546)
	--[[ line: 4631 | upvalues: (copy) Input]]
	p544.SprintButtonHeld = p545
	if p544.SprintButtonHeld == true and not p544.isAiming then
		if p544.ActionButtonHeld == false and p544.AltActionButtonHeld == false then
			if p544.sprinting == false then
				p544.sprinting = true
				p544.sprintStart = os.clock()
				p544:aim(false, nil)
				p544:changeStance("Standing", true)
			else
				p544.sprinting = false
			end
		end
	elseif p544.GameplaySettings:GetAttribute("ToggleSprint") == false and Input.getInputType() ~= "Gamepad" or p546 then
		p544.sprinting = false
	end
	p544.rs_Player.Status.GameplayVariables.Sprinting:SetAttribute("Value", p544.sprinting)
end
function t.changeStance(p547, p548, p549)
	--[[ line: 4654 | upvalues: (copy) Input]]
	if p548 == "Crouching" and not p547.rs_Vehicle.CurrentSeat.Value then
		if p547.humanoid:GetState() == Enum.HumanoidStateType.Swimming then
			return
		end
		if Input.getInputType() == "Gamepad" and p547.mainGui.MainFrame.InteractionFrame.InteractionDisplay.SpeechBox.Visible then
			return
		end
		if p547.stance == "Standing" then
			p547.stance = "Crouching"
			p547:sprint(false, true)
		else
			p547.stance = "Standing"
		end
	elseif p548 == "Standing" and (p547.GameplaySettings:GetAttribute("ToggleCrouch") == false and Input.getInputType() ~= "Gamepad" or p549) then
		p547.stance = "Standing"
	end
	p547.rs_Player.Status.GameplayVariables:SetAttribute("Stance", p547.stance)
end
function t.changeLean(p550, p551, _76)
	--[[ line: 4679 | upvalues: (copy) UpdateLeaning]]
	if p551 == 0 and p550.lean == 0 then
		return
	elseif p550.rs_Vehicle.CurrentSeat.Value and p550.lean == 0 then
		return
	elseif p550.humanoid:GetState() == Enum.HumanoidStateType.Swimming and p550.lean == 0 then
		return
	elseif not p550.sprinting or p550.lean ~= 0 then
		p550.lean = p551 == p550.lean and 0 or p551
		local leanAlpha = p550.springs.leanAlpha
		local v552 = -p550.lean
		leanAlpha.Target = Vector3.new(v552, 0, 0)
		local v553 = nil
		if p550.springs.leanAlpha.Target.X == 1 then
			v553 = true
		elseif p550.springs.leanAlpha.Target.X == -1 then
			v553 = false
		end
		UpdateLeaning:FireServer(v553)
	end
end
function t.setAirSpeed(p554)
	--[[ line: 4711 | upvalues: (copy) airSpeed]]
	if p554.horizontalVelocity >= 5 then
		airSpeed(p554)
	end
end
return t