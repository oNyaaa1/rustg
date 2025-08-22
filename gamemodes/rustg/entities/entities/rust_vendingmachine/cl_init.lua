DEFINE_BASECLASS("rust_storage")

include("shared.lua")



ENT.InventorySlots 	= 30

ENT.InventoryName	= "VENDING MACHINE"



ENT.DisplayIcon = gRust.GetIcon("open")



local VendingMachinePanel = nil



function ENT:Initialize()

    self.GetDisplayName = self.Ov_GetDisplayName

    self.SellOrders = {}

end



local PosOffset = Vector(15, -3, 80)

local AngOffset = Angle(0, 90, 90)

local ScreenWidth, ScreenHeight = 210, 195

local ScreenMaterial = Material("ui/vending_machine_screen.png")

function ENT:Draw()

    self:DrawModel()



    cam.Start3D2D(self:LocalToWorld(PosOffset), self:LocalToWorldAngles(AngOffset), 0.1)

        surface.SetDrawColor(51, 255, 0)

        surface.SetMaterial(ScreenMaterial)

        surface.DrawTexturedRect(0, 0, ScreenWidth, ScreenHeight)



        if (self:GetVending()) then

            local padding = 30

            

            surface.SetDrawColor(106, 172, 0)

            surface.SetMaterial(gRust.GetIcon("vending"))

            surface.DrawTexturedRectRotated(ScreenWidth * 0.5, ScreenHeight * 0.5, ScreenHeight - padding * 2, ScreenHeight - padding * 2, CurTime() * -250)

        else

            draw.SimpleText(":D", "gRust.100px", ScreenWidth * 0.5, ScreenHeight * 0.5, Color(5, 160, 0), 1, 1)

        end

    cam.End3D2D()

end



function draw.RotatedBox( x, y, w, h, ang, color )

	draw.NoTexture()

	surface.SetDrawColor( color or color_white )

	surface.DrawTexturedRectRotated( x, y, w, h, ang )

end



function ENT:Ov_GetDisplayName()

    local dot = self:GetForward():Dot(self:GetPos() - LocalPlayer():GetPos())

    if (dot > 0) then

        self.DisplayIcon = gRust.GetIcon("open")

        return "OPEN"

    end



    self.DisplayIcon = gRust.GetIcon("store")

    return "SHOP"

end


function ENT:Interact(pl)

    local dot = self:GetForward():Dot(self:GetPos() - LocalPlayer():GetPos())


    pl:RequestInventory(self)

    pl:EmitSound("vending_machine.open")

    gRust.OpenInventory(self)



    if (dot < 0) then

        self:ConstructInventory(gRust.Inventory.RightPanel)

    end

end



function ENT:ConstructInventory(pnl, data, rows)

    if (self:GetForward():Dot(self:GetPos() - LocalPlayer():GetPos()) > 0) then

        BaseClass.ConstructInventory(self, pnl, data, rows)

    else

        self:RequestVendingOrders()

        local scrw, scrh = ScrW(), ScrH()

        local Container = pnl:Add("Panel")

        Container:Dock(BOTTOM)

        Container:SetTall(scrh * 0.8)

        Container:DockMargin(scrh * 0.02, 0, scrh * 0.075, scrh * 0.15)



        /*local InfoRow = Container:Add("Panel")

        InfoRow:Dock(BOTTOM)

        InfoRow:SetTall(scrh * 0.03)

        InfoRow:DockMargin(0, 0, 0, scrh * 0.05)

        InfoRow.Paint = function(me, w, h)

            surface.SetDrawColor(200, 200, 200)

            surface.DrawRect(0, 0, w, h)



            draw.SimpleText("SALE ITEM", "gRust.36px", w * 0.025, h * 0.5, color_white, 0, 1)

            draw.SimpleText("COST", "gRust.36px", w * 0.5 + w * 0.025, h * 0.5, color_white, 0, 1)

        end*/



        Container.RemoveSellOrders = function(me)

            for k, v in ipairs(Container:GetChildren()) do

                if (k == 1) then continue end

                v:Remove()

            end

        end



        Container.AddSellOrder = function(me, item1, amount1, item2, amount2, index, instock)

            local Item = Container:Add("Panel")

            Item:Dock(BOTTOM)

            Item:SetTall(scrh * 0.09)

            Item:DockMargin(0, scrh * 0.05, 0, 0)

            local Padding = scrh * 0.005

            Item:DockPadding(Padding, Padding, Padding, Padding)

            Item.Paint = function(me, w, h)

                surface.SetDrawColor(133, 130, 124, 25)

                surface.DrawRect(0, 0, w, h)

            end



            local SellItem = Item:Add("gRust.Inventory.Slot")

            SellItem:SetItem(gRust.CreateItem(item1, amount1))

            SellItem:Dock(LEFT)

            SellItem:SetPreview(true)

            SellItem:DockMargin(scrh * 0.01, 0, 0, 0)



            local ForItem = Item:Add("gRust.Inventory.Slot")

            ForItem:SetItem(gRust.CreateItem(item2, amount2))

            ForItem:Dock(LEFT)

            ForItem:SetPreview(true)

            ForItem:DockMargin(scrh * 0.15, 0, 0, 0)



            local ButtonContainer = Item:Add("Panel")

            ButtonContainer:Dock(RIGHT)

            ButtonContainer:SetWide(scrh * 0.125)



            local BuyButton = ButtonContainer:Add("gRust.Button")

            BuyButton:Dock(TOP)

            if (instock) then

                BuyButton:SetText("BUY")

                BuyButton:SetDefaultColor(Color(115, 141, 69))

                BuyButton:SetHoveredColor(Color(105, 141, 42))

                BuyButton:SetActiveColor(Color(134, 180, 55))

                BuyButton.DoClick = function()

                    net.Start("gRust.VendingBuy")

                        net.WriteEntity(self)

                        net.WriteUInt(index, 12)

                    net.SendToServer()

                end

            else

                BuyButton:SetText("OUT OF STOCK")

                BuyButton:SetDefaultColor(Color(205, 65, 43))

                BuyButton:SetHoveredColor(Color(202, 74, 54))

                BuyButton:SetActiveColor(Color(204, 84, 66))

            end



            Item.PerformLayout = function(me, w, h)

                SellItem:SetWide(h - Padding)

                ForItem:SetWide(h - Padding)

            end



            ButtonContainer.PerformLayout = function(me, w, h)

                BuyButton:SetTall(h * 0.5)

            end

        end



        VendingMachinePanel = Container

    end

end



function ENT:RequestVendingOrders()

    net.Start("gRust.RequestVendingOrders")

        net.WriteEntity(self)

    net.SendToServer()

end



function ENT:AdminMenu(pl)

    pl:RequestInventory(self)

    self:RequestVendingOrders()

    self.SellAmount = 1

    self.ForAmount = 1



    local scrw, scrh = ScrW(), ScrH()



    gui.EnableScreenClicker(true)

    local Frame = vgui.Create("EditablePanel")

    Frame:Dock(FILL)

    Frame.Paint = function(me, w, h)

		surface.SetDrawColor(26, 25, 22, 245)

		surface.DrawRect(0, 0, w, h)

		me:DrawBlur(6)

    end



    VendingMachinePanel = Frame

    

    local TopPanel = Frame:Add("Panel")

    TopPanel:Dock(TOP)

    TopPanel:SetTall(40)



     // Create a button that removes Frame

    local CloseButton = TopPanel:Add("DButton")

    CloseButton:Dock(RIGHT)

    CloseButton:SetWide(40)

    CloseButton:SetText("")

    CloseButton.Paint = function(me, w, h)

        surface.SetDrawColor(gRust.Colors.Primary)

        surface.DrawRect(0, 0, w, h)

        draw.SimpleText("X", "gRust.32px", w * 0.5, h * 0.5, Color(255, 255, 255, 255), 1, 1)

    end

    CloseButton.DoClick = function()

        Frame:Remove()

        gui.EnableScreenClicker(false)

    end



    local LeftPanel = Frame:Add("Panel")

    LeftPanel:Dock(LEFT)

    LeftPanel:SetWide(scrw * 0.175)

    LeftPanel:DockMargin(scrw * 0.05, 0, 0, 0)



    local Title = LeftPanel:Add("DLabel")

    Title:Dock(TOP)

    Title:SetText("Add Sell Order")

    Title:SetFont("gRust.50px")

    Title:SetTextColor(color_white)

    Title:SetTall(scrh * 0.03)

    Title:SetContentAlignment(5)



    local Items = LeftPanel:Add("Panel")

    Items:Dock(TOP)

    Items:SetTall(scrh * 0.15)



    local AddButton = LeftPanel:Add("gRust.BigButton")

    AddButton:Dock(TOP)

    AddButton:SetTall(scrh * 0.085)

    AddButton:DockMargin(scrh * 0.01, 0, scrh * 0.01, scrh * 0.01)

    AddButton:SetColor(gRust.Colors.Secondary)

    AddButton:SetIcon("icons/store.png")

    AddButton:SetTitle("Add Sell Order")

    AddButton:SetDescription("Players will be able to purchase this item if it exists in the Vending Machines inventory.")

    AddButton.DoClick = function(me)

        if (!self.SellItem) then return end

        if (!self.ForItem) then return end



        net.Start("gRust.AddSellOrder")

            net.WriteEntity(self)



            net.WriteString(self.SellItem)

            net.WriteUInt(self.SellAmount, 16)



            net.WriteString(self.ForItem)

            net.WriteUInt(self.ForAmount, 16)

        net.SendToServer()

    end



    local ItemList = LeftPanel:Add("Panel")

    ItemList:Dock(FILL)

    ItemList.SearchFor = function(me, str)

        str = string.lower(str)



        for k, v in ipairs(me:GetChildren()) do

            v:Remove()

        end



        if (str == "") then return end



        local nitems = 0

        for k, v in pairs(gRust.Items) do

            if (string.find(string.lower(v:GetName()), str)) then

                if (string.EndsWith(v:GetClass(), ".BP")) then continue end

                local item = me:Add("DButton")

                item:Dock(TOP)

                item:DockMargin(0, 0, 0, 2)

                item:SetTall(scrh * 0.06)

                item:SetColor(Color(125, 125, 125, 200))

                item.Paint = function(me, w, h)

                    surface.SetDrawColor(me:GetColor())

                    surface.DrawRect(0, 0, w, h)



                    surface.SetMaterial(Material(v:GetIcon()))

                    surface.SetDrawColor(255, 255, 255)

                    surface.DrawTexturedRect(0, 0, h, h)



                    draw.SimpleText(v.Name, "gRust.32px", h * 1.1, h * 0.5, color_white, 0, 1)

                    return true

                end

                item.OnCursorEntered = function(me)

                    me:ColorTo(Color(200, 200, 200, 200), 0.1)

                end

                item.OnCursorExited = function(me)

                    me:ColorTo(Color(125, 125, 125, 200), 0.1)

                end

                item.DoClick = function()

                    if (!self.LastType) then return end

                    local pnl = self[self.LastType.."ItemPanel"]

                    pnl.Item = v:GetClass()

                    self[self.LastType.."Item"] = v:GetClass()

                end

                

                nitems = nitems + 1

                if (nitems == 5) then

                    break

                end

            end

        end

    end



    for i = 1, 2 do

        local Str = i == 1 and "Sell" or "For"



        local ItemContainer = Items:Add("Panel")

        ItemContainer:Dock(LEFT)



        local ItemPanel = ItemContainer:Add("Panel")

        ItemPanel:Dock(TOP)

        ItemPanel:SetTall(scrh * 0.065)

        ItemPanel:DockMargin(0, 0, 0, scrh * 0.01)

        ItemPanel.Paint = function(me, w, h)

            draw.SimpleText(Str, "gRust.32px", 8, h * 0.5, color_white, 0, 1)

            surface.SetDrawColor(255, 255, 255, 50)

            surface.DrawRect(w * 0.5 - h * 0.5, 0, h, h)

            

            if (!me.Item) then return end

            surface.SetDrawColor(255, 255, 255)

            surface.SetMaterial(Material(gRust.Items[me.Item]:GetIcon(), "smooth"))

            surface.DrawTexturedRect(w * 0.5 - h * 0.5, 0, h, h)

        end



        local Text = ItemContainer:Add("gRust.Input")

        Text:Dock(TOP)

        Text:SetTall(scrh * 0.03)

		Text:SetPlaceholder("Search...")

        Text:SetFont("gRust.24px")

        Text:DockMargin(0, 0, 0, scrh * 0.005)

		Text.OnPressed = function(me)

			Frame:MakePopup()

            self.LastType = Str

		end

		Text.OnReleased = function(me)

			Frame:SetKeyboardInputEnabled(false)

		end

        Text.OnTextChanged = function(me, txt)

            ItemList:SearchFor(txt)

        end



        local Amount = ItemContainer:Add("Panel")

        Amount:Dock(TOP)

        Amount:SetTall(scrh * 0.035)

        

		local Dec = Amount:Add("gRust.Button")

		Dec:Dock(LEFT)

		Dec:SetIcon(gRust.GetIcon("subtract"))

		Dec.DoClick = function()

			self[Str.."Amount"] = math.max(self[Str.."Amount"] - 1, 1)

		end



        local Input = Amount:Add("gRust.Input")

        Input:Dock(FILL)

        Input:DockMargin(scrh * 0.005, 0, scrh * 0.005, 0)

        Input:SetFont("gRust.24px")

        Input.TextEntry:SetValue("1")

        local OThink = Input.Think

        Input.Think = function(me)

            OThink(me)

            if (tonumber(me:GetValue()) ~= self[Str.."Amount"]) then

                me.TextEntry:SetText(self[Str.."Amount"])

            end

        end

		Input.OnPressed = function(me)

			Frame:MakePopup()

		end

		Input.OnReleased = function(me)

			Frame:SetKeyboardInputEnabled(false)

		end

        Input.OnTextChanged = function(me, txt)

            self[Str.."Amount"] = math.max(tonumber(txt) or 1, 1)

        end

        

		local Inc = Amount:Add("gRust.Button")

		Inc:Dock(RIGHT)

		Inc:SetIcon(gRust.GetIcon("add"))

		Inc.DoClick = function()

			self[Str.."Amount"] = self[Str.."Amount"] + 1

		end



        Amount.PerformLayout = function(me, w, h)

            Dec:SetWide(h)

        end



        self[Str.."ItemPanel"] = ItemPanel

    end



    local margin = scrh * 0.02

    Items.PerformLayout = function(me, w, h)

        for k, v in ipairs(me:GetChildren()) do

            v:SetWide(w * 0.5)

            v:DockPadding(k == 1 and 0 or margin,

                        0,

                        k == 1 and margin or 0,

                        0)

        end

    end



    local SellOrders = Frame:Add("Panel")

    SellOrders:Dock(RIGHT)

    SellOrders:SetWide(scrw * 0.15)

    SellOrders:DockMargin(0, 0, scrw * 0.025, 0)



    local Title = SellOrders:Add("DLabel")

    Title:Dock(TOP)

    Title:SetText("Existing Sell Orders")

    Title:SetFont("gRust.52px")

    Title:SetColor(color_white)

    Title:SetContentAlignment(5)

    Title:SetTall(scrh * 0.035)



    Frame.RemoveSellOrders = function()

        for k, v in ipairs(SellOrders:GetChildren()) do

            if (k == 1) then continue end -- Title

            v:Remove()

        end

    end



    Frame.AddSellOrder = function(me, item1, amount1, item2, amount2, index)

        local Order = SellOrders:Add("Panel")

        Order:Dock(TOP)

        Order:NoClipping(true)

        Order:SetTall(scrh * 0.05)

        Order:DockMargin(scrh * 0.02, 0, scrh * 0.02, scrh * 0.01)

        Order:DockPadding(scrh * 0.035, 0, scrh * 0.035, 0)

        Order.Paint = function(me, w, h)

            surface.SetDrawColor(255, 255, 255, 50)

            surface.DrawRect(0, 0, w, h)



            draw.SimpleText("For", "gRust.32px", w * 0.5, h * 0.5, color_white, 1, 1)

        end



        local function PaintItem(me, w, h)

            surface.SetDrawColor(200, 200, 200, 200)

            surface.DrawRect(0, 0, w, h)



            surface.SetDrawColor(255, 255, 255)

            surface.SetMaterial(Material(gRust.Items[me.Item]:GetIcon(), "smooth"))

            surface.DrawTexturedRect(0, 0, w, h)



            draw.SimpleText(me.Amount .. "x", "gRust.24px", w * 0.9, h * 0.6, color_white, 2, 2)

        end



        local Item1 = Order:Add("Panel")

        Item1:Dock(LEFT)

        Item1.Item = item1

        Item1.Amount = amount1

        Item1.Paint = PaintItem



        local Item2 = Order:Add("Panel")

        Item2:Dock(RIGHT)

        Item2.Item = item2

        Item2.Amount = amount2

        Item2.Paint = PaintItem



        // Create a close button sticking out of the top right of the panel

        local Close = Order:Add("DButton")

        Close:SetSize(scrh * 0.02, scrh * 0.02)

        Close:NoClipping(true)

        Close.Paint = function(me, w, h)

            surface.SetDrawColor(gRust.Colors.Primary)

            surface.DrawRect(0, 0, w, h)



            surface.SetDrawColor(255, 255, 255)

            surface.SetMaterial(gRust.GetIcon("x"))

            surface.DrawTexturedRect(0, 0, w, h)



            return true

        end

        Close.DoClick = function()

            Order:Remove()

            net.Start("gRust.RemoveSellOrder")

                net.WriteEntity(self)

                net.WriteUInt(index, 14)

            net.SendToServer()

        end



        Order.PerformLayout = function(me, w, h)

            Item1:SetWide(h)

            Item2:SetWide(h)

            Close:SetPos(w - (Close:GetWide() * 0.75), -Close:GetTall() * 0.25)

        end

    end

end



net.Receive("gRust.SendSellOrders", function()

    VendingMachinePanel:RemoveSellOrders()



    local ent = net.ReadEntity()

    for i = 1, net.ReadUInt(12) do

        local Item1 = net.ReadString()

        local Amount1 = net.ReadUInt(16)

        local Item2 = net.ReadString()

        local Amount2 = net.ReadUInt(16)

        local InStock = net.ReadBool()



        -- ent.SellOrders[i] = {

        --     SellingItem = Item1,

        --     SellingAmount = Amount1,

        --     BuyingItem = Item2,

        --     BuyingAmount = Amount2,

        --     InStock = InStock

        -- }



        if (VendingMachinePanel) then

            VendingMachinePanel:AddSellOrder(Item1, Amount1, Item2, Amount2, i, InStock)

        end

    end

end)