--
print("Loading Trees sv")
local function BackwardsEnums(enumname)
    local backenums = {}
    for k, v in pairs(_G) do
        if isstring(k) and string.find(k, "^" .. enumname) then backenums[v] = k end
    end
    return backenums
end

hook.Add("EntityTakeDamage", "EntityDamageExample", function(ent, dmginfo)
    local MAT = BackwardsEnums("MAT_")
    local ply = dmginfo:GetAttacker()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if MAT[ent:GetMaterialType()] == "MAT_WOOD" then
        timer.Simple(0, function()
            if IsValid(ply) then
                ply:SyncInventory()
                ply:GiveItem("wood", math.random(13,20))
            end
        end)
    end

    if ent:GetClass() == "rust_ore" and ent:GetSkin() == 1 then ply:GiveItem("metal.ore", math.random(10,15)) end
    if ent:GetClass() == "rust_ore" and ent:GetSkin() == 2 then ply:GiveItem("sulfur.ore", math.random(10,15)) end
    if ent:GetClass() == "rust_ore" and ent:GetSkin() == 3 then ply:GiveItem("stone", math.random(10,15)) end 
end)

local Rocks = {Vector(-3792.029785, -13264.387695, 65.724213), Vector(-4732.778809, -12192.792969, 64.281883), Vector(-6023.077637, -11482.048828, 64.471962), Vector(-6175.088379, -8771.442383, 64.318481), Vector(-8370.460938, -8906.120117, 64.314789), Vector(-7750.162598, -8850.724609, 64.325745), Vector(-6746.119629, -6735.162109, 380.331543), Vector(-7906.496094, -7104.460449, 378.431458), Vector(-12137.454102, -8889.194336, 64.000000), Vector(-13335.008789, -9066.532227, 64.000000), Vector(-13982.030273, -7890.173340, 64.463791), Vector(-13345.028320, -5918.994141, 35.097015), Vector(-12744.553711, -5142.339844, -76.042664), Vector(-11933.133789, -4659.244141, 74.814331), Vector(-11952.909180, -3372.570068, 829.525818), Vector(-11843.196289, -2357.978271, 1290.089355), Vector(-12466.872070, -2715.189941, 966.382324), Vector(-13598.750977, -2917.436279, -36.283661), Vector(-13749.448242, -784.154480, 75.134445), Vector(-13833.723633, 188.831635, 78.870346), Vector(-12736.406250, 84.946991, 214.518463), Vector(-12124.357422, 972.153015, 109.831573), Vector(-11559.940430, 1670.888184, 580.784851), Vector(-11341.621094, 1510.524048, 571.431030), Vector(-11509.252930, 1989.509155, 553.785034), Vector(-12053.763672, 2110.306396, 466.886292), Vector(-13337.833008, 2182.638428, 373.732788), Vector(-13698.062500, 2232.120850, 346.850006), Vector(-13552.906250, 4259.112793, 198.381378), Vector(-13298.310547, 3599.663574, 47.413574), Vector(-11518.709961, 5186.253906, 653.307861), Vector(-11021.034180, 5118.391113, 636.657532), Vector(-11380.618164, 6983.821289, 121.168274), Vector(-11149.829102, 7065.470703, 120.310913), Vector(-10918.248047, 6832.576172, 146.922333), Vector(-11276.931641, 6732.702637, 147.424255), Vector(-13752.251953, 6995.145020, 54.102722), Vector(-12860.452148, 7662.895020, 64.000000), Vector(-12412.913086, 9323.971680, 66.117065), Vector(-13072.476563, 10471.338867, 137.365601), Vector(-12256.421875, 10701.719727, 172.460083), Vector(-12505.175781, 12077.799805, 329.833984), Vector(-12020.638672, 13352.511719, 296.025879), Vector(-12947.544922, 13109.598633, 306.036133), Vector(-13005.170898, 13190.652344, 304.226318), Vector(-13475.166016, 13144.341797, 309.927979), Vector(-10158.509766, 13041.804688, 301.397461), Vector(-9756.407227, 11388.702148, 281.751831), Vector(-9710.455078, 11602.249023, 285.597656), Vector(-8665.368164, 12799.264648, 270.393799), Vector(-7471.099609, 12740.222656, 294.491211), Vector(-7274.795898, 11857.035156, 274.667480), Vector(-6397.540039, 12973.703125, 338.349609), Vector(-5508.079102, 9679.667969, 1016.264282), Vector(-4308.176270, 10948.097656, 928.120850), Vector(-3109.807129, 12161.245117, 43.228271), Vector(616.483032, 13069.073242, -84.261475), Vector(1900.366943, 14126.562500, 2.662720), Vector(4186.648926, 13136.594727, -177.090576), Vector(5168.194336, 13222.214844, -41.343994), Vector(5758.153320, 13245.737305, 20.605713), Vector(3676.581787, 12119.033203, -250.824097), Vector(2816.996094, 10366.689453, -160.387817), Vector(2068.279541, 8406.601563, 269.866211), Vector(1664.959106, 4170.344238, 343.465820), Vector(900.118286, 4511.813477, 434.998535), Vector(-824.082764, 4549.255859, 460.692261), Vector(-938.046265, 3112.515869, 346.073364), Vector(-1389.783203, 2402.519287, 371.245850), Vector(-932.081421, 2264.290771, 402.416138), Vector(-1068.246460, 2746.209961, 376.329712), Vector(-1787.427002, -6188.718262, 518.310059), Vector(-2192.178223, -4340.336914, 453.588623), Vector(2489.278076, -11912.118164, 1177.813232), Vector(1601.207153, -12110.789063, 1064.248169), Vector(890.053101, -11856.150391, 1072.020996), Vector(-1280.326538, -12059.571289, 381.525391), Vector(-2627.217529, -12274.012695, 387.006836), Vector(-4866.550293, -12597.089844, 56.148926), Vector(731.321777, -8660.633789, 1176.302002), Vector(413.713043, -8707.464844, 1093.942627), Vector(88.274612, -8813.232422, 1068.673584),}
hook.Add("InitPostEntity", "SpawnRockyss", function()
    timer.Simple(5, function()
        if game.GetMap() == "rust_highland_v1_3a" then
            for k, v in pairs(Rocks) do
                if not isvector(v) then continue end
                local ent = ents.Create("rust_ore")
                if not IsValid(ent) then continue end
                ent:SetPos(v)
                ent:Spawn()
                ent:Activate()
                print("Spawned Rock as Pos: " .. tostring(v))
            end

            for i = 1, 20 do
                local rnd = ents.FindByClass("prop_dynamic")[math.random(1, #ents.FindByClass("prop_dynamic"))]
                if IsValid(rnd) then
                    local ent = ents.Create("npc_vj_felt_chicken")
                    /*if not IsValid(ent) then continue end
                    ent:SetPos(Vector(rnd:GetPos().x, rnd:GetPos().y + math.random(100, 200), rnd:GetPos().z + 300))
                    ent:Spawn()
                    ent:Activate()
                    ent:DropToFloor()*/
                    print("Spawned Chicken as Pos: " .. tostring(rnd:GetPos()))
                end

                local rnd2 = ents.FindByClass("prop_dynamic")[math.random(1, #ents.FindByClass("prop_dynamic"))]
                if IsValid(rnd2) then
                    --/local ent2 = ents.Create("models/props_zaza/hemp.mdl")
                    --/ent2:SetPos(rnd2:GetPos())
                    --/ent2:Spawn()
                    -- ent2:Activate()
                    print("Spawned Hemp as Pos: " .. tostring(rnd2:GetPos()))
                end
            end
        end
    end)

    if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end
end)
