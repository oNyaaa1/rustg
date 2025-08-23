-- Hard block via the taunt gate (covers console "act", context menu, etc.)
hook.Add("PlayerShouldTaunt", "GM_DisableActs", function(ply, actid)
    return false
end)

-- Belt-and-suspenders: cancel the animation event the act command fires
hook.Add("DoAnimationEvent", "GM_BlockActGestures", function(ply, event, data)
    if event == PLAYERANIMEVENT_CUSTOM_GESTURE then
        return ACT_INVALID -- stop the gesture from playing
    end
end)
