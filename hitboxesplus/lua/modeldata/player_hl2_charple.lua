local MODELDATA = {
	Models = {
		"models/player/charple.mdl"
	},
	Capsules = {
		["ValveBiped.Bip01_Pelvis"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(-2, 0, -1),
				Maxs = Vector(2, 0, -1),
				HitGroup = HITGROUP_STOMACH,
				Radius = 3
			}
		},
		["ValveBiped.Bip01_Spine"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 2, -1.5),
				Maxs = Vector(0, 2, 1.5),
				HitGroup = HITGROUP_STOMACH,
				Radius = 3
			}
		},
		["ValveBiped.Bip01_Spine1"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 2.5, -1.5),
				Maxs = Vector(0, 2.5, 1.5),
				HitGroup = HITGROUP_STOMACH,
				Radius = 3
			}
		},
		["ValveBiped.Bip01_Spine2"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0.5, 2, -2),
				Maxs = Vector(0.5, 2, 2),
				HitGroup = HITGROUP_CHEST,
				Radius = 3
			},
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(2.5, 2.25, -2),
				Maxs = Vector(2.5, 2.25, 2),
				HitGroup = HITGROUP_CHEST,
				Radius = 4
			}
		},
		["ValveBiped.Bip01_Spine4"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(-3, 2, -2.5),
				Maxs = Vector(-3, 2, 2.5),
				HitGroup = HITGROUP_CHEST,
				Radius = 3.5
			},
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0.65, 0.75, -4.5),
				Maxs = Vector(0.65, 0.75, 4.5),
				HitGroup = HITGROUP_CHEST,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_Neck1"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(-1, -1, 0),
				Maxs = Vector(3, 0, 0),
				HitGroup = HITGROUP_CHEST,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_Head1"]				= {
			{
				Origin = Vector(1, -0.5, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(2, 1, 0),
				HitGroup = HITGROUP_HEAD,
				Radius = 3
			}
		},
		["ValveBiped.Bip01_R_UpperArm"]			= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 1),
				Maxs = Vector(11.7, 0, 0),
				HitGroup = HITGROUP_RIGHTARM,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_R_Forearm"]			= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(10.5, 0, 0),
				HitGroup = HITGROUP_RIGHTARM,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_R_Hand"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(4, -1.5, 0),
				HitGroup = HITGROUP_RIGHTARM,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_L_UpperArm"]			= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, -1),
				Maxs = Vector(11.7, 0, 0),
				HitGroup = HITGROUP_LEFTARM,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_L_Forearm"]			= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(10.5, 0, 0),
				HitGroup = HITGROUP_LEFTARM,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_L_Hand"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(4, -1.5, 0),
				HitGroup = HITGROUP_LEFTARM,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_R_Thigh"]			= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(17.75, 0, 0),
				HitGroup = HITGROUP_RIGHTLEG,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_R_Calf"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(17.5, 0, 0),
				HitGroup = HITGROUP_RIGHTLEG,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_R_Foot"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(1, 1.75, 0),
				Maxs = Vector(7, -1.75, 0),
				HitGroup = HITGROUP_RIGHTLEG,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_L_Thigh"]			= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(17.75, 0, 0),
				HitGroup = HITGROUP_LEFTLEG,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_L_Calf"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(0, 0, 0),
				Maxs = Vector(17.5, 0, 0),
				HitGroup = HITGROUP_LEFTLEG,
				Radius = 2
			}
		},
		["ValveBiped.Bip01_L_Foot"]				= {
			{
				Origin = Vector(0, 0, 0),
				Mins = Vector(1, 1.75, 0),
				Maxs = Vector(7, -1.75, 0),
				HitGroup = HITGROUP_LEFTLEG,
				Radius = 2
			}
		}
	}
}

return MODELDATA