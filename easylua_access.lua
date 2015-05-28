if SERVER then
	
	local white_list_access = util.JSONToTable(file.Read("whitelist_gcompute.txt","DATA"))
	
	local function update_access()
		
		white_list_access = util.JSONToTable(file.Read("whitelist_gcompute.txt","DATA"))
		
		local valid_players = {}
		
		for _, o in pairs(player.GetAll()) do
			
			for __, oo in pairs(white_list_access) do
				
				if oo._steam64 == o:SteamID64() then
									
					valid_players[o:SteamID64()] = o
		
					break
					
				end
				
			end
		
		end
				
		for _, o in pairs(player.GetAll()) do
			
			if valid_players[o:SteamID64()] then
				
				o:SetNWBool("glua_access", true)

			else
			
				o:SetNWBool("glua_access", false)

			end
			
		end
		
	end
	
	concommand.Add("lua_access", function(ply, cmd, args)
		
		if not ply:IsAdmin() then return end
		
		local data = util.JSONToTable(file.Read("whitelist_gcompute.txt","DATA"))
		local act = args[1]
		local steamid = args[2] or " "
		local name = " "
		
		if #steamid > 1 and act == "add" then
			
			for _, o in pairs(player.GetAll()) do 
				
				if o:SteamID64() == steamid and o:SteamID64() == steamid then name = o:Nick() break end 
				
			end		
			
			if #name > 1 then
				
				table.insert(data,{_steam64 = steamid, _name = name})
				
				print("[EASYLUA] Add:",steamid, name)
				
			end
			
		elseif #steamid > 1 and act == "del" and data then
		
			for _ = 1, #data do
				
				local o = data[_]
				
				if o._steam64 == steamid then
					
					print("[EASYLUA] Del:",steamid, o._name)
					
					data[_] = nil
					
					break
					
				end
				
			end
					
		end
		
		file.Write("whitelist_gcompute.txt", util.TableToJSON(data))
		
		update_access()
			
	end,nil,nil,FCVAR_USERINFO)
	
	concommand.Add("lua_accesslist",function(ply, cmd, args)
		
		local data = util.JSONToTable(file.Read("whitelist_gcompute.txt","DATA"))
		
		for _, o in pairs(data) do
			
			print("[EASYLUA] Have access:",o._name, o._steam64)
			
		end
		
	end,nil,nil,FCVAR_USERINFO)
	update_access()
	
end