if CLIENT then return end
		
easylua_manager = {}
easylua_manager.access_manager = {}
easylua_manager.access_manager.access_list = {}
	
easylua_manager.access_manager.add = function(userinfo, caller)
	
	if not userinfo._steam64 then return "[EASYLUA ERROR]: Need SteamID64" end
	if #userinfo._steam64 ~= 17 then return "[EASYLUA ERROR]: Length of SteamID64 must have 17 symbols" end
	if easylua_manager.access_manager.access_list["STEAM:"..userinfo._steam64] then return "[EASYLUA ERROR]: User alredy exists" end
	
	if not userinfo._name then 
					
		for _, o in pairs(player.GetAll()) do
			
			if o:SteamID64() == userinfo._steam64 then
				
				userinfo._name = o:Nick()
				userinfo._ip = o:IPAddress()
				
			end
			
		end				
		
		if not userinfo._name then 
			
			userinfo._name = "Unknown"
			userinfo._ip = "Unknown"
			
		end
		
	end
		
	easylua_manager.access_manager.access_list["STEAM:"..userinfo._steam64] = 
	{
		_steam64 = "STEAM:"..userinfo._steam64, 
		_name = userinfo._name, 
		_ip = userinfo._ip,
		_caller = IsValid(caller) and
		{
			_steam64 = "STEAM:"..caller:SteamID64(), 
			_name = caller:Nick(), 
			_ip = caller:IPAddress()
		} or {}
	}
		
	if _name == "Unknown" then return "[EASYLUA WARNING]: Player not found, name set to Unknown, access granted for "..userinfo._steam64 end
	
	return "[EASYLUA]: Access granted for "..userinfo._name
		
end
	
easylua_manager.access_manager.del = function(steamid64)

	if not steamid64 then return "[EASYLUA ERROR]: Need SteamID64" end
	if #steamid64 ~= 17 then return "[EASYLUA ERROR]: Length of SteamID64 must have 17 symbols" end
	if not easylua_manager.access_manager.access_list["STEAM:"..steamid64] then return "[EASYLUA ERROR]: User not exists" end

	easylua_manager.access_manager.access_list["STEAM:"..steamid64] = nil
	
	return "[EASYLUA]: Remove "..steamid64
	
end

easylua_manager.access_manager.file_update = function(isload)
	
	if isload then
		
		if file.Exists("whitelist_gcompute.txt","DATA") then
			
			local l = util.JSONToTable(file.Read("whitelist_gcompute.txt","DATA"))
			
			easylua_manager.access_manager.access_list = l or {}
			
		else
			
			file.Write("whitelist_gcompute.txt",util.TableToJSON({}))
			
			easylua_manager.access_manager.file_update(isload)
			
		end
			
	else
	
		file.Write("whitelist_gcompute.txt",util.TableToJSON(easylua_manager.access_manager.access_list))
	
	end

end

easylua_manager.access_manager.update_access = function()
	
	easylua_manager.access_manager.file_update(true)			
		
	for _, o in pairs(player.GetAll()) do
		
		if easylua_manager.access_manager.access_list["STEAM:"..o:SteamID64()] then
			
			o:SetNWBool("glua_access", true)
 
		else
		
			o:SetNWBool("glua_access", false)

		end
		
	end
	
end

concommand.Add("lua_access", function(ply, cmd, args)
	
	if not IsValid(ply) or not ply:IsAdmin() then return end
	
	local act  = args[1]
	 
	if act == "add" then
		
		print(easylua_manager.access_manager.add({_steam64 = args[2]}, ply))
			
	elseif act == "del" then
		
		print(easylua_manager.access_manager.del(args[2]))
		
	elseif act == "show" then
		
		for _, o in pairs(easylua_manager.access_manager.access_list) do
		
			print("[EASYLUA] Have access:",o._name, _, o._ip)
		
		end
		
	end
	
	easylua_manager.access_manager.file_update(false)
	easylua_manager.access_manager.update_access()
	
end,nil,nil,FCVAR_USERINFO)

easylua_manager.access_manager.update_access()
