//-----------------------------------------------------------------------------------------------
//
//Client side script for hoofprint effects.
//
//@author Deven Ronquillo
//@version
//-----------------------------------------------------------------------------------------------

HOOFPRINTS = {
	
	Material("materials/textures/sn_hoofprints/horseshoe.png"),
	Material("materials/textures/sn_hoofprints/horseshoe1.png"),
	Material("materials/textures/sn_hoofprints/horseshoe2.png"),
	Material("materials/textures/sn_hoofprints/horseshoe3.png")
}

MODELS = {

	"models/ppm/player_default_base.mdl",
	"models/ppm/player_default_base_new.mdl",
	"models/ppm/player_default_base_new_nj.mdl",
	"models/ppm/player_default_base_nj.mdl"
}

BONES = {}

BONES["models/ppm/player_default_base.mdl"] = {"Lrig_LEG_FR_FrontHoof", "Lrig_LEG_FL_FrontHoof", "Lrig_LEG_BR_RearHoof", "Lrig_LEG_BL_RearHoof"}
BONES["models/ppm/player_default_base_new.mdl"] = {"Lrig_LEG_FR_FrontHoof", "Lrig_LEG_FL_FrontHoof", "Lrig_LEG_BR_RearHoof", "Lrig_LEG_BL_RearHoof"}
BONES["models/ppm/player_default_base_new_nj.mdl"] = {"Lrig_LEG_FR_FrontHoof", "Lrig_LEG_FL_FrontHoof", "Lrig_LEG_BR_RearHoof", "Lrig_LEG_BL_RearHoof"}
BONES["models/ppm/player_default_base_nj.mdl"] = {"Lrig_LEG_FR_FrontHoof", "Lrig_LEG_FL_FrontHoof", "Lrig_LEG_BR_RearHoof", "Lrig_LEG_BL_RearHoof"}

TRACKDATA = {}

trackInterval = .25

decayTime = 1.5
decayInterval = 1/(decayTime/engine.TickInterval())

if CLIENT then





	

	local function StartHoofprints()

		timer.Create("hoofprintThinkTimer", trackInterval, 0, hoofprintThink)


		concommand.Add( "cl_hoofprints_stop", function( ply, cmd, args )

			timer.Stop("hoofprintThinkTimer")
		print( "Hoofprints stopped!" )
		end )

		concommand.Add( "cl_hoofprints_start", function( ply, cmd, args )

			timer.Start("hoofprintThinkTimer")
		print( "Hoofprints started!" )
		end )
	end










	function hoofprintThink()

		for plyIndex, ply in pairs(player.GetAll()) do

			//print("----GETTING PLAYER----")
			//print(ply)

			for modelKey, model in pairs( MODELS ) do

				//print("----GETTING MODEL INFO----")

				//print("MODEL: "..model)
				//print("PLAYER MODEL: "..ply:GetModel())
				//print("KEY PRESSED: ")
				//print(tostring(ply:KeyDown( IN_FORWARD ))..", "..tostring(ply:KeyDown( IN_MOVELEFT ))..", "..tostring(ply:KeyDown( IN_BACK ))..", "..tostring(ply:KeyDown( IN_MOVERIGHT )))

				if ply:GetModel() == model then

					local playerPos = ply:GetPos()

					if (ply != LocalPlayer() && LocalPlayer():GetPos():Distance(playerPos) <= 1000 && ply:GetVelocity():Length() >= 3 && ply:OnGround()) || (ply == LocalPlayer() && ply:OnGround() && (ply:KeyDown( IN_FORWARD ) || ply:KeyDown( IN_MOVELEFT ) || ply:KeyDown( IN_BACK ) || ply:KeyDown( IN_MOVERIGHT ))) then

						local tr = util.TraceLine({
													start = playerPos,
													endpos = playerPos + ply:GetAngles():Up()*-1000})

						if(tr.MatType != MAT_SNOW && tr.MatType != MAT_DIRT && tr.MatType != MAT_SAND && tr.MatType != MAT_GRASS) then return end

						//print("---MAKING TRACKS---")

						for boneKey, bone in pairs( BONES[model] ) do

							//print("GETTING BONE: "..bone)

							local pos = ply:GetBonePosition( ply:LookupBone( bone ) )
							pos.z = playerPos.z

							local ang = Angle(0, ply:GetAngles().y, 0)
							ang:RotateAroundAxis( ang:Up(), -90 )



							TRACKDATA[#TRACKDATA + 1] = {position = pos, angle = ang, decay = 1, texture = HOOFPRINTS[math.random(4)]}

							//print("CREATED DATA")	
						end	

						//print("---TRACKED DATA---")
						//PrintTable(TRACKDATA)
					end
				end
			end
		end
	end
	








	local function DrawHoofprints()

		for trackIndex, track in pairs(TRACKDATA) do

			if LocalPlayer():GetPos():Distance(track.position) <= 600 and track.decay > 0 then

		    	cam.Start3D2D(track.position, track.angle, .1)

		        	
					surface.SetDrawColor(255, 255, 255, 255*track.decay)
					surface.SetMaterial(track.texture)
					surface.DrawTexturedRect( 0, 0, 64, 64)
		     	cam.End3D2D()
		    end
		end  
	end
	hook.Add("PreDrawEffects", "DrawHoofprintsHook", DrawHoofprints)










	local function HoofprintDecay()

		for trackIndex, track in pairs(TRACKDATA) do

			if track.decay <= 0 then
				
				TRACKDATA[trackIndex] = nil
			else

				track.decay = track.decay - decayInterval
			end
		end
	end
	hook.Add("Tick", "DecayHoofprints", HoofprintDecay)


	/////////////////////////////RECIEVER////////////////////////////////////////////////

	local function RecieveHoofprintStatus(status)

		print("status: ")
		print(status)

		if status == true then

			print("Starting prints!")
			
			StartHoofprints()
		end
	end
	net.Receive("sn_hoofprints_status", function()

		local status = net.ReadBool()

		RecieveHoofprintStatus(status)
	end)
end