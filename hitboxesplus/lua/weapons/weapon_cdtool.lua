AddCSLuaFile()

SWEP.PrintName = "Capsule Hitboxes Debug Tool"
SWEP.Author = "BlacK"
SWEP.Purpose = "Use this to debug capsule hitboxes."

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.AdminOnly = false

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

function SWEP:Reload()
end

function SWEP:CanBePickedUpByNPCs()
	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()


	self:EmitSound("Weapon_357.Single")
	self:ShootEffects(self)
	self:SetNextPrimaryFire(CurTime() + 0.2)

	-- Get table of all entities that use capsule hitboxes.
	local entities = g_CapsuleHitboxes:GetEntitiesWithCapsuleHitboxes(owner) -- This must be owner, or the player will be included in the entity list, causing them to be able to shoot themself.
	PrintTable(entities)
	local shootpos = owner:GetShootPos()
	local direction = owner:GetAimVector()

	local traceData = {}
	traceData.start = shootpos
	traceData.endpos = shootpos + direction * (256 ^ 2)
	traceData.mask = MASK_SHOT
	traceData.filter = table.Copy(entities) -- Filter the entities with capsule hitboxes from the trace since we are doing our own traces for these entities.
	table.insert(traceData.filter, owner) -- And add the owner, shooting yourself is not fun.

	-- Finally cast the trace.
	local traceResult = util.TraceLine(traceData)
	-- And do our own tracing logic to check if we hit any capsule colliders along the way.
	g_CapsuleHitboxes:IntersectRayWithEntities(traceResult, entities)

	if IsFirstTimePredicted() then
		local color = Either(SERVER, Color(0, 0, 255, 127), Color(255, 0, 0, 127))
		debugoverlay.Line(traceResult.StartPos, traceResult.HitPos, 4, color, true)
		debugoverlay.Box(traceResult.HitPos, Vector(-2, -2, -2), Vector(2, 2, 2),  4, color)
	end

	if traceResult.Fraction == 1 then
		return
	end

	local hitEntity = traceResult.Entity
	if SERVER and IsValid(hitEntity) then
		local damageInfo = DamageInfo()
		damageInfo:SetAttacker(owner)
		damageInfo:SetInflictor(self)
		damageInfo:SetDamage(Either(traceResult.HitGroup == HITGROUP_HEAD, 200, 10))
		damageInfo:SetDamageType(DMG_DIRECT)
		damageInfo:SetDamagePosition(traceResult.HitPos)
		damageInfo:SetReportedPosition(traceResult.HitPos)
		damageInfo:SetDamageForce(Vector(0, 0, 1))

		local backupFlags = owner:GetSolidFlags()
		owner:AddSolidFlags(FSOLID_TRIGGER)

		hitEntity:TakeDamageInfo(damageInfo)

		owner:SetSolidFlags(backupFlags)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:GetNPCRestTimes()
	return 0.3, 0.6
end

function SWEP:GetNPCBurstSettings()
	return 1, 6, 0.1
end

function SWEP:GetNPCBulletSpread( proficiency )
	return 1
end

local function draw_Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function SWEP:DoDrawCrosshair(x, y)
	draw.NoTexture()
	surface.SetDrawColor(Color(55, 205, 55, 255))
	draw_Circle(x, y, 2, 6)
end