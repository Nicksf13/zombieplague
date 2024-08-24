EntityManager = {
    EntitiesOfInteress = {},
    NextClick = CurTime()
}
EntityManager.EntitiesList = {
    {Entity = "info_player_start", Model = "models/player.mdl"},
    {Entity = "ent_pointofinteress", Model = "models/player/zombie_fast.mdl"},
    {Entity = "info_player_counterterrorist", Model = "models/player/Group01/male_01.mdl"},
    {Entity = "info_player_terrorist", Model = "models/player/combine_super_soldier.mdl"}
}
EntityManager.SelectedEntity = 1


net.Receive("StartEditing", function()
    EntityManager.EntitiesOfInteress = net.ReadTable()

    for K, Ent in pairs(EntityManager.EntitiesOfInteress) do
        local FalseEntity = ClientsideModel("models/player.mdl")

        FalseEntity:SetPos(Ent.Pos)
        FalseEntity:SetAngles(Ent.Angles)
    end

    hook.Add("HUDPaint", "RenderPreviewModel", function()
        if !IsValid(EntityManager.PreviewModel) then
            EntityManager.PreviewModel = ClientsideModel("models/player.mdl", RENDER_GROUP_OPAQUE_ENTITY)
        end

        EntityManager.PreviewModel:SetModel(EntityManager.EntitiesList[EntityManager.SelectedEntity + 1].Model)

        local Trace = util.TraceLine({
            start = LocalPlayer():GetShootPos(),
            endpos = LocalPlayer():GetShootPos() + (LocalPlayer():GetAimVector() * 10000),
            filter = LocalPlayer()
        })

        EntityManager.PreviewModel:SetPos(Trace.HitPos)
    end)

    hook.Add("PlayerButtonDown", "DetectPlayerButtonDown", function(Ply, Button)
        if CurTime() >= EntityManager.NextClick then
            local TableSize = table.Count(EntityManager.EntitiesList)
            if Button == 112 then
                EntityManager.SelectedEntity = (EntityManager.SelectedEntity + 1) % TableSize

                notification.AddLegacy("You've Selected: '" .. EntityManager.EntitiesList[EntityManager.SelectedEntity + 1].Entity .. "'", NOTIFY_GENERIC, 5)
            elseif Button == 113 then
                EntityManager.SelectedEntity = (EntityManager.SelectedEntity + TableSize - 1) % TableSize

                notification.AddLegacy("You've Selected: '" .. EntityManager.EntitiesList[EntityManager.SelectedEntity + 1].Entity .. "'", NOTIFY_GENERIC, 5)
            end

            EntityManager.NextClick = CurTime() + 0.01
        end
    end)
end)