local actCommands = {
    "act", "act_dance", "act_muscle", "act_cheer", "act_robot", 
    "act_zombie", "act_agree", "act_becon", "act_disagree",
    "act_salute", "act_wave", "act_forward", "act_halt", 
    "act_pers", "act_laugh", "act_bow", "actgroup"
}
for i, cmd in ipairs(actCommands) do
    concommand.Remove(cmd)
end 