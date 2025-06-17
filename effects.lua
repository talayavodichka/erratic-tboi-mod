local game = Game()

local effects = {
    function(player)
        player:AddCacheFlags(CacheFlag.CACHE_SIZE)
        player:EvaluateItems()
        player.SpriteScale = Vector(3, 3)
    end,

    function(player)
        player:AddCacheFlags(CacheFlag.CACHE_SIZE)
        player:EvaluateItems()
        player.SpriteScale = Vector(0.5, 0.5)
    end,

    function(player)
        player.MoveSpeed = math.random() * 2 + 0.5
    end,

    function(player)
        player.Velocity = Vector(0, -20)
    end,

    function(player)
        player.TearColor = Color(math.random(), math.random(), math.random(), 1, 0, 0, 0)
        player.TearFlags = math.random(1, 1000)
    end,

    function(player)
        player:AddCollectible(math.random(1, 500), 0, false)
    end,

    function(player)
        local entities = Isaac.GetRoomEntities()
        for i = 1, #entities do
            local entity = entities[i]
            if entity and entity:Exists() and entity:IsVulnerableEnemy() then
                local dist = entity.Position:Distance(player.Position)
                if dist < 100 then
                    entity:Kill()
                    player:AddHearts(1)
                    break
                end
            end
        end
    end
}

return effects
