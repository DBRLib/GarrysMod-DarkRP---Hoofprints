//-----------------------------------------------------------------------------------------------
//
//Client side script for hoofprint effects
//
//@author Deven Ronquillo
//@version
//-----------------------------------------------------------------------------------------------

AddCSLuaFile("cl_init_hoofprints.lua")


if SERVER then

	util.AddNetworkString("sn_hoofprints_status")
	CreateConVar("sv_hoofprints_status", 1, "Enables or dissable sn_hoofprints for clients." )


	function SendHoofprintStatus(ply)//Sends status of hoofprint to client

		net.Start("sn_hoofprints_status")

			net.WriteBool(GetConVar("sv_hoofprints_status"):GetBool())
		net.Send(ply)
	end
	hook.Add("PlayerInitialSpawn","SendSnHoofprintStatus", SendHoofprintStatus)
end

