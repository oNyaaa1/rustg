CreateClientConVar("grust_lefthand", "0", true)


local lp = LocalPlayer()

function GM:CalcViewModelView( wep, vm, oldpos, oldang, pos, posang )
	if ( !IsValid( wep ) ) then return end

	local vm_origin, vm_angles = pos, posang

	local func = wep.GetViewModelPosition
	if ( func ) then
		local pos, ang = func( wep, pos*1, posang*1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end

	func = wep.CalcvmView
	if ( func ) then
		local pos, ang = func( wep, vm, oldpos*1, oldang*1, pos*1, posang*1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end
    
    wep.ViewModelFlip = GetConVar("grust_lefthand"):GetBool()

	return vm_origin, vm_angles
end

local LegsBool = CreateConVar("cl_legs", "1", FCVAR_ARCHIVE, "Enable/Disable the rendering of the legs")

local Legs = {}
Legs.LegEnt = nil
Legs.PlaybackRate = 1
Legs.Sequence = nil
Legs.Velocity = 0
Legs.BonesToRemove = {}
Legs.RenderAngle = nil
Legs.RenderPos = nil
Legs.RenderColor = {}
Legs.ClipVector = vector_up * -1
Legs.ForwardOffset = -24

local freelooking = false

local function holdingbind(ply)
    if !input.LookupBinding("freelook") then 
        return ply:KeyDown(IN_WALK)
    else
        return freelooking
    end
end


function Legs:SetUp()
    if not IsValid(self.LegEnt) then
        self.LegEnt = ClientsideModel(lp:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
    else
        self.LegEnt:SetModel(lp:GetModel())
    end

    self.LegEnt:SetNoDraw(true)

    for k, v in pairs(lp:GetBodyGroups()) do
        local current = lp:GetBodygroup(v.id)
        self.LegEnt:SetBodygroup(v.id, current)
    end

    for k, v in ipairs(lp:GetMaterials()) do
        self.LegEnt:SetSubMaterial(k - 1, lp:GetSubMaterial(k - 1))
    end

    self.LegEnt:SetSkin(lp:GetSkin())
    self.LegEnt:SetMaterial(lp:GetMaterial())
    self.LegEnt:SetColor(lp:GetColor())

    self.LegEnt.GetPlayerColor = function()
        return lp:GetPlayerColor()
    end

    self.LegEnt.Anim = nil
    self.LegEnt.LastTick = 0

    self:WeaponChanged()
end

function Legs:WeaponChanged()
    if IsValid(self.LegEnt) then
        for i = 0, self.LegEnt:GetBoneCount() do
            self.LegEnt:ManipulateBoneScale(i, Vector(1,1,1))
            self.LegEnt:ManipulateBonePosition(i, vector_origin)
        end

        self.BonesToRemove = {
            "ValveBiped.Bip01_Head1",
            "ValveBiped.Bip01_L_Hand",
            "ValveBiped.Bip01_L_Forearm",
            "ValveBiped.Bip01_L_Upperarm",
            "ValveBiped.Bip01_L_Clavicle",
            "ValveBiped.Bip01_R_Hand",
            "ValveBiped.Bip01_R_Forearm",
            "ValveBiped.Bip01_R_Upperarm",
            "ValveBiped.Bip01_R_Clavicle",
            "ValveBiped.Bip01_Spine4",
            "ValveBiped.Bip01_Spine2"
        }

        for k, v in pairs(self.BonesToRemove) do
            local bone = self.LegEnt:LookupBone(v)
            if bone then
                self.LegEnt:ManipulateBoneScale(bone, Vector(0,0,0))
                self.LegEnt:ManipulateBonePosition(bone, Vector(0,-100,0))
            end
        end
    end
end

function Legs:Update(maxseqgroundspeed)
    if IsValid(self.LegEnt) then
        self:WeaponChanged()
        
        self.Velocity = lp:GetVelocity():Length2D()
        self.PlaybackRate = 1

        if self.Velocity > 0.5 then
            if maxseqgroundspeed < 0.001 then
                self.PlaybackRate = 0.01
            else
                self.PlaybackRate = self.Velocity / maxseqgroundspeed
                self.PlaybackRate = math.Clamp(self.PlaybackRate, 0.01, 10)
            end
        end

        self.LegEnt:SetPlaybackRate(self.PlaybackRate)
        self.Sequence = lp:GetSequence()

        if self.LegEnt.Anim ~= self.Sequence then
            self.LegEnt.Anim = self.Sequence
            self.LegEnt:ResetSequence(self.Sequence)
        end

        self.LegEnt:FrameAdvance(CurTime() - self.LegEnt.LastTick)
        self.LegEnt.LastTick = CurTime()

        self.LegEnt:SetPoseParameter("move_x", (lp:GetPoseParameter("move_x") * 2) - 1)
        self.LegEnt:SetPoseParameter("move_y", (lp:GetPoseParameter("move_y") * 2) - 1)
        self.LegEnt:SetPoseParameter("move_yaw", (lp:GetPoseParameter("move_yaw") * 360) - 180)
        self.LegEnt:SetPoseParameter("body_yaw", (lp:GetPoseParameter("body_yaw") * 180) - 90)
        self.LegEnt:SetPoseParameter("spine_yaw", (lp:GetPoseParameter("spine_yaw") * 180) - 90)
    end
end

function ShouldDrawLegs()
    return LegsBool:GetBool() and
           IsValid(Legs.LegEnt) and
           lp:Alive() and
           GetViewEntity() == lp and
           not lp:ShouldDrawLocalPlayer() and
           not holdingbind(lp) and
           not lp:InVehicle()
end

function Legs:DoFinalRender()
    cam.Start3D(EyePos(), EyeAngles())
    
    if ShouldDrawLegs() then
        if lp:Crouching() then
            self.RenderPos = lp:GetPos()
        else
            self.RenderPos = lp:GetPos() + Vector(0,0,5)
        end

        local eyeAngles = lp:EyeAngles()
        self.RenderAngle = Angle(0, eyeAngles.y, 0)
        local radAngle = math.rad(eyeAngles.y)
        self.ForwardOffset = -22

        self.RenderPos.x = self.RenderPos.x + math.cos(radAngle) * self.ForwardOffset
        self.RenderPos.y = self.RenderPos.y + math.sin(radAngle) * self.ForwardOffset

        if lp:GetGroundEntity() == NULL then
            self.RenderPos.z = self.RenderPos.z + 8
            if lp:KeyDown(IN_DUCK) then
                self.RenderPos.z = self.RenderPos.z - 28
            end
        end

        self.RenderColor = lp:GetColor()

        local bEnabled = render.EnableClipping(true)
        render.PushCustomClipPlane(self.ClipVector, self.ClipVector:Dot(EyePos()))

        render.SetColorModulation(self.RenderColor.r / 255, self.RenderColor.g / 255, self.RenderColor.b / 255)
        render.SetBlend(self.RenderColor.a / 255)

        self.LegEnt:SetRenderOrigin(self.RenderPos)
        self.LegEnt:SetRenderAngles(self.RenderAngle)
        self.LegEnt:SetupBones()
        self.LegEnt:DrawModel()
        self.LegEnt:SetRenderOrigin()
        self.LegEnt:SetRenderAngles()

        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)
        render.PopCustomClipPlane()
        render.EnableClipping(bEnabled)
    end
    
    cam.End3D()
end

hook.Add("UpdateAnimation", "LegsUpdateAnimation", function(ply, velocity, maxseqgroundspeed)
    if ply == lp then
        if IsValid(Legs.LegEnt) then
            Legs:Update(maxseqgroundspeed)
            
            if string.lower(lp:GetModel()) ~= string.lower(Legs.LegEnt:GetModel()) then
                Legs:SetUp()
            end
        else
            Legs:SetUp()
        end
    end
end)

hook.Add("PostDrawTranslucentRenderables", "LegsRender", function()
    if lp then
        Legs:DoFinalRender()
    end
end)

timer.Simple(3, function()
    if IsValid(lp) then
        Legs:SetUp()
    end
end)

hook.Add("PlayerSpawn", "LegsSpawn", function(ply)
    if ply == lp then
        timer.Simple(1, function()
            Legs:SetUp()
        end)
    end
end)
