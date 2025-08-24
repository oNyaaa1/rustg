gRust.Attire = {}
gRust.CategoryItems = gRust.CategoryItems or {}
ATTIRE_FULLBODY = 0
ATTIRE_HEAD = 1
function gRust.RegisterAttire(id, data)
    util.PrecacheModel(data.model)
    gRust.Attire[id] = data
end

gRust.RegisterAttire("hazmatsuit", {
    type = ATTIRE_FULLBODY,
    model = "models/player/darky_m/rust/hazmat.mdl",
    hands = "models/player/darky_m/rust/hazmat_arms.mdl",
    body = 0.6,
    arms = 0.6,
    legs = 0.6,
})

gRust.RegisterAttire("hazmatsuit_scientist", {
    type = ATTIRE_FULLBODY,
    model = "models/player/darky_m/rust/scientist.mdl",
    hands = "models/player/darky_m/rust/hazmat_arms.mdl",
    head = 0.6,
    body = 0.6,
    legs = 0.6,
})

hook.Add("gRust.LoadedCore", "RegisterClothingItems", function()
    local hazmatsuit_scientist = gRust.ItemRegister("hazmatsuit_scientist")
    hazmatsuit_scientist:SetName("Scientist Suit")
    hazmatsuit_scientist:SetCategory("Clothing")
    hazmatsuit_scientist:SetAttire("hazmatsuit_scientist")
    hazmatsuit_scientist:SetStack(1)
    hazmatsuit_scientist:SetIcon("materials/items/clothing/scientist.png")
    gRust.RegisterItem(hazmatsuit_scientist)
    local hazmatsuit = gRust.ItemRegister("hazmatsuit")
    hazmatsuit:SetName("Hazmat Suit")
    hazmatsuit:SetCategory("Clothing")
    hazmatsuit:SetAttire("hazmatsuit")
    hazmatsuit:SetStack(1)
    hazmatsuit:SetIcon("materials/items/clothing/hazmat.png")
    hazmatsuit:SetBlueprint(125)
    hazmatsuit:SetCraft({
        {
            item = "tarp",
            amount = 5
        },
        {
            item = "sewing_kit",
            amount = 2
        },
        {
            item = "hq_metal",
            amount = 8
        }
    })

    gRust.RegisterItem(hazmatsuit)
end)

hook.Add("CalcView", "2iodsfkjds", function(pl, origin, ang)
    if true then return end
    return {
        origin = origin + pl:GetForward() * 50 + pl:GetUp() * -10,
        angles = ang + Angle(0, 180, 0),
        drawviewer = true
    }
end)