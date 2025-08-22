gRust.TechTree = gRust.TechTree or {}

local function RegisterTechTreeItem(id, scrap)
    gRust.TechTree[id] = scrap
end

local Trees = {"rust_tier1", "rust_tier2", "rust_tier3"}

local LoadTree
LoadTree = function(tree)
    for k, v in ipairs(tree) do
        if (v.Branch) then
            LoadTree(v.Branch)
        end

        gRust.TechTree[v.Item] = v.Scrap
    end
end

hook.Add("InitPostEntity", "gRust.LoadTrees", function()
    for k, v in ipairs(Trees) do
        LoadTree(scripted_ents.Get(v).TechTree)
    end
end)