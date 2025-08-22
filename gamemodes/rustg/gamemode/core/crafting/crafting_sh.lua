local PLAYER = FindMetaTable("Player")



function PLAYER:CanCraft(itemdata, amount)

    amount = amount or 1

    local CanCraft = true



    for k, v in ipairs(itemdata:GetCraft()) do

        if (!self:HasItem(v.item, v.amount * amount)) then

            CanCraft = false

        end

    end



    return CanCraft and self:HasBlueprint(itemdata:GetClass()) and self:HasPurchasableItem(itemdata:GetClass())

end

function PLAYER:HasPurchasableItem(class)

    if (!gRust.Items[class]:GetPurchasable()) then

        return true

    end



    return self.PurchasedItems and self.PurchasedItems[class]

end