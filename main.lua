local mod = RegisterMod("Chaos Carnival", 1)
local game = Game()
local music = MusicManager()

-- TODO: add configurations and music

--[[
mod.CUSTOM_MUSIC = {
    MAIN = Isaac.GetMusicIdByName("ChaosCarnival"),
    BOSS = Isaac.GetMusicIdByName("ChaosBoss"),
    SECRET = Isaac.GetMusicIdByName("ChaosSecret")
}

function mod:playRandomMusic()
    local tracks = {
        Music.MUSIC_BASEMENT,
        Music.MUSIC_CAVES,
        Music.MUSIC_DEPTHS,
        Music.MUSIC_SHEOL,
        Music.MUSIC_CATHEDRAL,
        Music.MUSIC_CHEST,
        Music.MUSIC_DARK_ROOM,
        mod.CUSTOM_MUSIC.MAIN,
        mod.CUSTOM_MUSIC.MAIN,
        mod.CUSTOM_MUSIC.MAIN
    }

    local track = tracks[math.random(#tracks)]
    music:Play(track, 1.0)
end

function mod:onNewRoom()
    self:playRandomMusic()

    local room = game:GetRoom()
    local roomType = room:GetType()

    if roomType == RoomType.ROOM_BOSS then
        if math.random() < 0.7 then
            music:Play(mod.CUSTOM_MUSIC.BOSS, 1.0)
        end
    elseif roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_ULTRASECRET then
        if math.random() < 0.5 then
            music:Play(mod.CUSTOM_MUSIC.SECRET, 1.0)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

function mod:onBossDeath(entity)
    if entity:IsBoss() then
        music:Play(Music.MUSIC_JINGLE_BOSS_OVER, 1.0)
        Isaac.CreateTimer(function()
            self:playRandomMusic()
        end, 60, 1, false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onBossDeath, EntityType.ENTITY_EFFECT)

function mod:onMusicUpdate()
    if not music:IsPlaying() then
        self:playRandomMusic()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onMusicUpdate)
]] --

local effects = require('effects')

function mod:onNewRoom()
    local player = Isaac.GetPlayer(0)
    if not player then return end

    local entities = Isaac.GetRoomEntities()
    local enemiesToReplace = 0

    for i = 1, #entities do
        local entity = entities[i]
        if entity and entity:Exists() and entity:IsVulnerableEnemy() and not entity:IsBoss() then
            enemiesToReplace = enemiesToReplace + 1
            entity:Remove()
        end
    end

    for i = 1, enemiesToReplace / 2 do
        local enemy = Isaac.Spawn(math.random(10, 90), 0, 0, Isaac.GetRandomPosition(), Vector(0, 0), nil)
    end

    local effect = effects[math.random(#effects)]
    if effect then
        effect(player)
    end
    local status = math.random(1, 10)

    if status == 1 then
        player:AddPoison(EntityRef(player), 100, 1)
    elseif status == 2 then
        player:AddConfusion(EntityRef(player), 100, false)
    elseif status == 3 then
        player:AddCharmed(EntityRef(player), 150)
    elseif status == 4 then
        player:AddFear(EntityRef(player), 120)
    end

    if math.random() < 0.1 then
        player.TearFlags = math.random(1, 1000)
        player.TearColor = Color(math.random(), math.random(), math.random(), 1, 0, 0, 0)
    end

    if math.random() < 0.1 then
        player.MoveSpeed = math.random() * 2 + 0.3
    end

    if math.random() < 0.1 then
        Isaac.Explode(player.Position, player, 50)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

function mod:onUpdate()
    local player = Isaac.GetPlayer(0)

    if game:GetFrameCount() % 5 == 0 and math.random() < 0.005 then
        effects[math.random(#effects)](player)
    end

    if math.random() < 0.01 then
        player:FireTear(player.Position, Vector.FromAngle(math.random(360)):Resized(15), false, false, false)
    end

    if math.random() < 0.001 then
        player.SpriteScale = Vector(math.random() + 0.5, math.random() + 0.5)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)

function mod:onDamage(target, amount, flags, source)
    if not target then return end

    local player = Isaac.GetPlayer(0)
    if not player then return end

    if target:ToPlayer() and math.random() < 0.3 then
        return false
    end

    if target:ToPlayer() and source and source.Entity and source.Entity:Exists() then
        if math.random() < 0.2 then
            source.Entity:TakeDamage(amount, flags, EntityRef(player), 0)
            return false
        end
    end

    if target:IsVulnerableEnemy() and math.random() < 0.1 then
        target:Morph(EntityType.ENTITY_CHARGER, 0, 0, -1)
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onDamage)

function mod:onKill(entity)
    if not entity then return end

    if entity:IsVulnerableEnemy() then
        if math.random() < 0.1 then
            Isaac.Explode(entity.Position, entity, 50)
        end

        if math.random() < 0.05 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
                math.random(1, 700), entity.Position, Vector(0, 0), nil)
        end

        if math.random() < 0.07 and entity.CanDropTrinket then
            entity:TryDropTrinket(true, true)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.onKill)
