local Screengrabbing = false
local function Screengrab()
    Screengrabbing = true
end

net.Receive("gRust.Screengrab", Screengrab)
hook.Add("PostRender", "gRust.Screengrab", function()
    if not Screengrabbing then return end
    Screengrabbing = false
    local data = render.Capture({
        format = "jpeg",
        quality = 50,
        h = ScrH(),
        w = ScrW(),
        x = 0,
        y = 0
    })

    if not data then return end
    local pl = LocalPlayer()
    http.Post("https://api.imgur.com/3/upload", {
        image = util.Base64Encode(data),
        type = "base64",
        title = string.format("%s (%s)", pl:Name(), pl:SteamID64()),
    }, function(body, len, headers, code)
        body = util.JSONToTable(body)
        if not body or not body["data"] then return end
        local url = body["data"]["link"]
        if not url then return end
        local imageId = string.match(url, "https://i.imgur.com/(.+)")
        if not imageId then return end
        net.Start("gRust.ScreengrabCallback")
        net.WriteString(imageId)
        net.SendToServer()
    end)
end)

-- Admin
local BLUR_MATERIAL = Material("pp/blurscreen")
local BLUR_AMOUNT = 12
net.Receive("gRust.ReceiveScreengrab", function(len)
    local url = net.ReadString()
    local target = net.ReadPlayer()
    LocalPlayer():ChatPrint(string.format("Link to screengrab: %s", url))
    gui.OpenURL(url)
end)