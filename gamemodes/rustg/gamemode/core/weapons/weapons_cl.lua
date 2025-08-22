local function SetSkin()
	local Skin = net.ReadString()
	local SkinData = gRust.Skins[Skin]
	local pl = LocalPlayer()

	timer.Simple(FrameTime() * 2, function()
		pl:GetActiveWeapon():Deploy()
	end)

	if (!SkinData) then
		pl:GetViewModel():SetSubMaterial(0, "")
		pl:GetViewModel():SetSubMaterial(1, "")
		pl:GetViewModel():SetSubMaterial(2, "")
		return
	end
	
	pl:GetViewModel():SetSubMaterial(SkinData.index, SkinData.mat)
end
net.Receive("gRust.SetSkin", SetSkin)