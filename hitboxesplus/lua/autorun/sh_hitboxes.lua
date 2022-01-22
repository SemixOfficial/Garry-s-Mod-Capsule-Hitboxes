g_CapsuleHitboxes = {}
g_CapsuleHitboxes.ModelData = {}

local VECTOR_ORIGIN = Vector(0, 0, 0)
local ANGLE_ZERO = Angle(0, 0, 0)

local g_hitbox_debug_intersection = CreateConVar("g_hitbox_debug_intersection", "0", {FCVAR_REPLICATED, FCVAR_DONTRECORD}, "debug ray capsule intersection algorithm", 0, 1)
local g_hitbox_debug_positions = CreateConVar("g_hitbox_debug_positions", "0", {FCVAR_REPLICATED, FCVAR_DONTRECORD}, "debug bone positions", 0, 1)

local modellist = {
	"modeldata/player_css_cterrorist.lua",
	"modeldata/player_css_terrorist.lua",
	"modeldata/player_hl2_combine.lua",
	"modeldata/player_hl2_generic_female.lua",
	"modeldata/player_hl2_generic.lua",
	"modeldata/player_hl2_metrocop_female.lua",
	"modeldata/player_hl2_zombie_fast.lua",
	"modeldata/player_hl2_zombie.lua",
	"modeldata/player_hl2_zombine.lua"
}

function g_CapsuleHitboxes:LoadModelData()
	-- local searchDir = "addons/hitboxesplus/lua/modeldata/"
	-- local files, _ = file.Find(searchDir .. "*", "GAME", "nameasc")

	-- PrintTable(files)

	-- for idx, fileName in pairs(files) do
	-- 	AddCSLuaFile("modeldata/" .. fileName)

	-- 	local modeldata = include("modeldata/" .. fileName)
	-- 	print(modeldata)
	-- 	for _, model in pairs(modeldata.Models) do
	-- 		self.ModelData[model] = table.Copy(modeldata.Capsules)
	-- 	end
	-- end

	for idx, fileName in pairs(modellist) do
		AddCSLuaFile(fileName)

		local modeldata = include(fileName)
		for _, model in pairs(modeldata.Models) do
			self.ModelData[model] = table.Copy(modeldata.Capsules)
		end
	end
end

-- Crappy function to draw capsule overlays in Garry's mod.
function g_CapsuleHitboxes:DrawCapsuleOverlay(pos, ang, mins, maxs, radius, color, time)
	if not g_hitbox_debug_intersection:GetBool() then
		return
	end

	local zmin = LocalToWorld(mins, Angle(0, 0, 0), pos, ang)
	local zmax = LocalToWorld(maxs, Angle(0, 0, 0), pos, ang)

	local segments = 8
	local step = 360 / segments
	local angle = (zmax - zmin):GetNormalized():Angle()
	local right, up = angle:Right(), angle:Up()
	for i = 0, segments do
		local sin = math.sin(math.rad(step * i)) * radius
		local cos = math.cos(math.rad(step * i)) * radius

		local zmin_seg = zmin + right * sin + up * cos
		local zmax_seg = zmax + right * sin + up * cos

		debugoverlay.Line(zmin_seg, zmax_seg, time, color, true)
	end

	local alpha = color.a
	color.a = 0
	debugoverlay.Sphere(zmin, radius, time, color, true)
	debugoverlay.Sphere(zmax, radius, time, color, true)
	color.a = alpha
end

function g_CapsuleHitboxes:IsPointWhitinCapsule(point, pos, ang, mins, maxs, radius)
	local zmin = LocalToWorld(mins, ANGLE_ZERO, pos, ang)
	local zmax = LocalToWorld(maxs, ANGLE_ZERO, pos, ang)
	local dist, p1, _ = util.DistanceToLine(zmin, zmax, point)

	local hitnormal = (point - p1):GetNormalized()
	local hitpos = p1 + hitnormal * radius

	if dist <= radius then
		debugoverlay.Cross(hitpos, 3, 0.05, Color( 255, 255, 255 ), false)
		debugoverlay.Line(hitpos, hitpos + hitnormal * radius)
	end

	return dist <= radius, hitpos, hitnormal
end

-- NOTE: This function doesn't calculate the normal because it's easily derived for a sphere (p - center).
function g_CapsuleHitboxes:IntersectRayWithSphere(rayStart, rayDirection, pos, radius)
	local delta = rayStart - pos

	local a = rayDirection:Dot(rayDirection)
	local b = 2.0 * delta:Dot(rayDirection)
	local c = delta:Dot(delta) - (radius * radius)

	local discriminant = b * b - 4 * a * c
	if discriminant < 0.0 then
		return false
	end

	discriminant = math.sqrt(discriminant)

	local tmin = (-b - discriminant) / (2 * a)
	local tmax = (-b + discriminant) / (2 * a)
	if (tmin > tmax) then
		local temp = tmin
		tmin = tmax
		tmax = temp
	end

	return true, tmin, tmax
end

function g_CapsuleHitboxes:IntersectRayWithCapsule(ray, pos, ang, mins, maxs, radius)
	-- Capsule is defined by A, B and r (A, B are points, r is the radius of the capsule)
	-- Ray is defined by it's origin O and the direction d.

	-- We want to find the two points, P1 and P2, which are the intersections of the ray with the capsule. Let's try to calculate one of them and call it P.

	-- Equations:
	-- 1) P is on the ray (O, d)
	-- Px = Ox + t * dx (1)
	-- Py = Oy + t * dy (2)
	-- Pz = Oz + t * dz (3)

	-- 2) A point K exists which is on the AB line for which the following is true:
	-- dot(AB, KP) = 0 (I)
	-- This point is on the AB line so the following holds true
	-- Kx = Ax + t' * ABx (4)
	-- Ky = Ay + t' * ABy (5)
	-- Kz = Az + t' * ABz (6)

	-- 3) The magnitude of KP is r
	-- |KP| = r (II)

	-- Subtituting eq. (1) - (6) in (I) and (II) gives us two equations with two unknowns. Let's call them (I') and (II'). Solving (II') for (e.g.) t' and subtituting t' into (I') gives us two solutions for t. For each one of these solution we get a different t'. t1 and t2 correspond to intersection points P1 and P2 with the cylinder. t1' and t2' correspond to K1 and K2 on the AB line segment.

	-- If t1' and t2' are in the [0, 1] range the intersection points P1 and P2 are on the cylindrical part of the capsule. Otherwise they are invalid. So we check against the two spheres (A, r) and (B, r).

	-- Normals are the unit vectors KP if the intersection points are on the cylinder. Otherwise they can be calculated by the intesection point with the spheres and the corresponding center (A or B).

	-- Note that this doesn't take into account a ray parallel to the cylinder which intersects it at the two end spheres, but this should be easy.

	-- Substituting equ. (1) - (6) to equ. (I) and solving for t' gives:
	--
	-- t' = (t * dot(AB, d) + dot(AB, AO)) / dot(AB, AB) (7) or
	-- t' = t * m + n where
	-- m = dot(AB, d) / dot(AB, AB) and
	-- n = dot(AB, AO) / dot(AB, AB)
	--

	local rayStart = ray.StartPos
	local zmin = LocalToWorld(mins, ANGLE_ZERO, pos, ang)
	local zmax = LocalToWorld(maxs, ANGLE_ZERO, pos, ang)
	local dist, p1, _ = util.DistanceToLine(zmin, zmax, rayStart)

	-- Special case, we are or have started inside the capsule, therefore we can just quit right here.
	if dist <= radius then
		local hitnormal = (rayStart - p1):GetNormalized()
		local hitpos = p1 + hitnormal * radius

		return dist <= radius, hitpos, hitnormal, true
	end

	local hitPos = ray.HitPos
	local hitNormal = ray.HitNormal
	local rayDirection = ray.HitPos - ray.StartPos
	rayDirection:Normalize()

	local AB = zmin - zmax
	local AO = rayStart - zmax

	local AB_dot_d = AB:Dot(rayDirection)
	local AB_dot_AO = AB:Dot(AO)
	local AB_dot_AB = AB:Dot(AB)

	local m = AB_dot_d / AB_dot_AB
	local n = AB_dot_AO / AB_dot_AB

	-- Substituting (7) into (II) and solving for t gives:

	-- dot(Q, Q)*t^2 + 2*dot(Q, R)*t + (dot(R, R) - r^2) = 0
	-- where
	-- Q = d - AB * m
	-- R = AO - AB * n
	local Q = rayDirection - (AB * m)
	local R = AO - (AB * n)

	local a = Q:Dot(Q)
	local b = 2.0 * Q:Dot(R)
	local c = R:Dot(R) - (radius * radius)

	if a == 0.0 then
		-- Special case: AB and ray direction are parallel. If there is an intersection it will be on the end spheres...
		-- NOTE: Why is that?
		-- Q = d - AB * m =>
		-- Q = d - AB * (|AB|*|d|*cos(AB,d) / |AB|^2) => |d| == 1.0
		-- Q = d - AB * (|AB|*cos(AB,d)/|AB|^2) =>
		-- Q = d - AB * cos(AB, d) / |AB| =>
		-- Q = d - unit(AB) * cos(AB, d)

		-- |Q| == 0 means Q = (0, 0, 0) or d = unit(AB) * cos(AB,d)
		-- both d and unit(AB) are unit vectors, so cos(AB, d) = 1 => AB and d are parallel.

		local atintersect, atmin, atmax = self:IntersectRayWithSphere(rayStart, rayDirection, zmax, radius)
		local btintersect, btmin, btmax = self:IntersectRayWithSphere(rayStart, rayDirection, zmin, radius)

		if not atintersect or not btintersect then
			-- No intersection with one of the spheres means no intersection at all...
			return false
		end

		if atmin < btmin then
			hitPos = rayStart + (rayDirection * atmin)
			hitNormal = hitPos - zmax
		else
			hitPos = rayStart + (rayDirection * btmin)
			hitNormal = hitpos - zmin
		end

		hitNormal:Normalize()

		return true, hitPos, hitNormal
	end

	local discriminant = b * b - 4.0 * a * c
	if discriminant < 0.0 then
		-- The ray doesn't hit the infinite cylinder defined by (A, B).
		-- No intersection.
		return false
	end

	discriminant = math.sqrt(discriminant)

	local tmin = (-b - discriminant) / (2.0 * a)
	local tmax = (-b + discriminant) / (2.0 * a)
	if tmin > tmax then
		local temp = tmin
		tmin = tmax
		tmax = temp
	end

	-- Now check to see if K1 and K2 are inside the line segment defined by A,B
	local t_k1 = tmin * m + n
	if t_k1 < 0.0 then
		-- On sphere (A, r)...
		local stintersect, stmin, _ = self:IntersectRayWithSphere(rayStart, rayDirection, zmax, radius)
		if stintersect then
			hitPos = rayStart + (rayDirection * stmin)
			hitNormal = hitPos - zmax
		else
			return false
		end
	elseif t_k1 > 1.0 then
		-- On sphere (B, r)...
		local stintersect, stmin, _ = self:IntersectRayWithSphere(rayStart, rayDirection, zmin, radius)
		if stintersect then
			hitPos = rayStart + (rayDirection * stmin)
			hitNormal = hitPos - zmin
		else
			return false
		end
	else
		-- On the cylinder...
		hitPos = rayStart + (rayDirection * tmin)
		hitNormal = hitPos - (zmax + AB * t_k1)
	end

	hitNormal:Normalize()

	return true, hitPos, hitNormal
end

function g_CapsuleHitboxes:IntersectRayWithEntity(entity, model, trace)
	local modelData = self.ModelData[model]
	if not modelData then
		return false
	end

	local bboxsize = entity:OBBMins() - entity:OBBMaxs()
	self:DrawCapsuleOverlay(entity:GetPos(), ANGLE_ZERO, VECTOR_ORIGIN, Vector(0, 0, -bboxsize.z + bboxsize.y * 0.5), bboxsize.y, Either(SERVER, Color(0, 0, 255, 255), Color(255, 0, 0, 255)), 4)

	local intersection, hitPos, hitNormal  = self:IntersectRayWithCapsule(trace, entity:GetPos(), Angle(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, -bboxsize.z + bboxsize.y * 0.5), bboxsize.y)
	if not intersection then
		-- We didn't intersect with the hull capsule which contains the hitbox capsules, therefore it is not possible to hit the hitbox capsules, so don't bother doing any more intersections.
		return false
	end

	local rayStart = trace.StartPos
	local rayDelta = trace.HitPos - rayStart
	local rayLengthSqr = rayDelta:LengthSqr()
	local rayToCapsule = hitPos - rayStart

	if rayToCapsule:LengthSqr() > rayLengthSqr then
		-- We couldn't intersect with this capsule because it is too far away, abort the mission.
		return false
	end

	local shortestRayHitPos = trace.HitPos
	local shortestRayHitNormal = trace.HitNormal
	local shortestRayLengthSqr = rayLengthSqr
	local shortestRayBoneName = ""
	local shortestRayCapsuleId = 0

	local boneCount = entity:GetBoneCount()
	for bone = 0, boneCount - 1 do
		local boneName = entity:GetBoneName(bone)
		if not modelData[boneName] then
			continue
		end

		local matrix = entity:GetBoneMatrix(bone)
		if not matrix then
			continue
		end

		local translation = matrix:GetTranslation()
		local rotation = matrix:GetAngles()

		for idx, capsule in pairs(modelData[boneName]) do
			local capsulePos = LocalToWorld(capsule.Origin, ANGLE_ZERO, translation,rotation)

			self:DrawCapsuleOverlay(capsulePos, rotation, capsule.Mins, capsule.Maxs, capsule.Radius, Either(SERVER, Color(0, 0, 255, 255), Color(255, 0, 0, 255)), 4)

			intersection, hitPos, hitNormal = g_CapsuleHitboxes:IntersectRayWithCapsule(trace, capsulePos, rotation, capsule.Mins, capsule.Maxs, capsule.Radius)
			if not intersection then
				-- We didn't intersect with this capsule, no luck here...
				continue
			end

			local intersectRayLengthSqr = (hitPos - rayStart):LengthSqr()
			if intersectRayLengthSqr > shortestRayLengthSqr then
				-- Nope, too far, didn't intersect this one either...
				continue
			end

			shortestRayHitPos = hitPos
			shortestRayHitNormal = hitNormal
			shortestRayLengthSqr = intersectRayLengthSqr
			shortestRayBoneName = boneName
			shortestRayCapsuleId = idx
		end
	end

	if shortestRayCapsuleId == 0 then
		-- We didn't hit any capsule besides the hull.
		return false
	end

	local hitCapsule = modelData[shortestRayBoneName][shortestRayCapsuleId]

	-- We did our own intersection and changed the results, so let's fix up the trace data from the original Source trace.
	trace.Hit = true
	trace.HitSky = false
	trace.HitWorld = false
	trace.HitNonWorld = true
	trace.HitPos = shortestRayHitPos
	trace.HitNormal = shortestRayHitNormal
	trace.Entity = entity
	trace.Fraction = trace.Fraction * (shortestRayLengthSqr / rayDelta:LengthSqr())
	trace.HitGroup = hitCapsule.HitGroup

	local hitBoneId = entity:LookupBone(shortestRayBoneName)
	if hitBoneId then
		trace.SurfaceProps = util.GetSurfaceIndex(entity:GetBoneSurfaceProp(hitBoneId))
	end

	return true
end

function g_CapsuleHitboxes:IntersectRayWithEntities(trace, entities)
	for idx, entity in pairs(entities) do
		g_CapsuleHitboxes:IntersectRayWithEntity(entity, entity:GetModel(), trace)
	end
end

function g_CapsuleHitboxes:GetEntitiesWithCapsuleHitboxes(filter)
	local entities = {}
	-- TODO: Nextbot support
	for idx, entity in pairs(player.GetAll()) do
		if entity:IsDormant() or not entity:Alive() then
			continue
		end

		local model = entity:GetModel()
		if not self.ModelData[model] or entity == filter then
			continue
		end

		table.insert(entities, entity)
	end

	return entities
end

hook.Add("UpdateAnimation", "capsule_hitboxes", function(ply, velocity, maxSeqGroundSpeed)
	if g_hitbox_debug_positions:GetBool() then
		local model = ply:GetModel()
		local modelData = g_CapsuleHitboxes.ModelData
		if not modelData[model] then
			return false
		end

		ply:SetSequence(0)
		ply:SetCycle(0)

		local boneCount = ply:GetBoneCount()
		for bone = 0, boneCount - 1 do
			if not ply:BoneHasFlag(bone, BONE_USED_BY_HITBOX) then
				continue
			end

			local boneToWorld = ply:GetBoneMatrix(bone)
			if not boneToWorld then
				continue
			end

			local parent = ply:GetBoneParent(bone)
			if not parent or not ply:BoneHasFlag(parent, BONE_USED_BY_HITBOX) then
				continue
			end

			local parentToWorld = ply:GetBoneMatrix(parent)
			if not parentToWorld then
				continue
			end

			debugoverlay.Line(parentToWorld:GetTranslation(), boneToWorld:GetTranslation(), 0.05, Color(255, 255, 255 ), true)
			debugoverlay.Axis(boneToWorld:GetTranslation(), boneToWorld:GetAngles(), 3, 0.05, true)
			debugoverlay.EntityTextAtPosition(boneToWorld:GetTranslation(), 0, ply:GetBoneName(bone), 0.05, Color(255, 255, 255))
		end
	end
end)

-- hook.Add("HUDPaint", "test capsool", function()
-- 	local pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
-- 	local mins, maxs = Vector(0, 0, -8), Vector(0, 0, 8)
-- 	local radius = 12

-- 	local pointPos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 32
-- 	local trace = LocalPlayer():GetEyeTrace()

-- 	debugoverlay.Box(pointPos, Vector(-1, -1, -1), Vector(1, 1, 1), 0.05, Color(0, 255, 255, 10))

-- 	local intersect, hitpos, hitnormal, bsolid = g_CapsuleHitboxes:IntersectRayWithCapsule(trace, pos, ang, mins, maxs, radius)
-- 	local clr = Either(intersect, Color(84, 226, 55), Color(170, 16, 16))

-- 	if intersect then
-- 		debugoverlay.Cross(hitpos, 3, 0.05, Color( 255, 255, 255 ), false)
-- 		debugoverlay.Line(hitpos, hitpos + hitnormal * 8, 0.05, Color(0, 255, 255, 255), false)
-- 	end

-- 	g_CapsuleHitboxes:DrawCapsuleOverlay(pos, ang, mins, maxs, radius, clr, 0.05)
-- end)

g_CapsuleHitboxes:LoadModelData()
