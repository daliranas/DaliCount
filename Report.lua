local _, DC = ...

local reportAliases = {
    group = "group",
    groupe = "group",
    party = "group",
    say = "say",
    dire = "say",
    raid = "raid",
}

local chatPrefixes = {
    SAY = function() return SLASH_SAY1 or "/say" end,
    PARTY = function() return SLASH_PARTY1 or "/party" end,
    RAID = function() return SLASH_RAID1 or "/raid" end,
    INSTANCE_CHAT = function() return SLASH_INSTANCE_CHAT1 or "/instance" end,
}

local function compactReport(lines)
    local message = lines[1] or "DaliCount"
    for i = 2, #lines do
        local candidate = message .. " ; " .. lines[i]
        if string.len(candidate) > 230 then break end
        message = candidate
    end
    return message
end

function DC:PrepareReportInChat(channel, channelLabel, lines)
    if not ChatFrame_OpenChat then
        self:Print("Impossible d'ouvrir la zone de discussion.")
        return false
    end

    local getPrefix = chatPrefixes[channel]
    local prefix = getPrefix and getPrefix() or "/say"
    ChatFrame_OpenChat(prefix .. " " .. compactReport(lines))
    self:Print("Rapport préparé pour " .. channelLabel .. ". Appuyez sur Entrée pour l'envoyer.")
    return true
end

function DC:ResolveReportChannel(target)
    target = reportAliases[string.lower(target or "group")] or target

    if target == "say" then
        return "SAY", "Dire"
    end

    if target == "raid" then
        if not IsInRaid or not IsInRaid() then
            return nil, "Vous n'êtes pas dans un raid."
        end
        return "RAID", "Raid"
    end

    if target == "group" then
        if IsInRaid and IsInRaid() then
            return "RAID", "Raid"
        end
        if IsInGroup and LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            return "INSTANCE_CHAT", "Groupe d'instance"
        end
        if IsInGroup and IsInGroup() then
            return "PARTY", "Groupe"
        end
        return nil, "Vous n'êtes pas dans un groupe."
    end

    return nil, "Canal inconnu. Utilisez groupe, dire ou raid."
end

function DC:BuildReportLines(maxRows)
    local session = self:GetCurrentSessionData()
    if not session or type(session.combatSources) ~= "table" then
        return nil, "Aucune donnée de combat à partager."
    end

    local metric = self:GetMetric()
    local sessionDef = self:GetSession()
    local sources = session.combatSources
    local limit = math.max(1, math.min(10, math.floor(tonumber(maxRows) or 5)))
    local lines = {
        string.format("DaliCount - %s - %s", metric.label, sessionDef.label),
    }

    local added = 0
    for i = 1, math.min(#sources, limit) do
        local source = sources[i]
        if source then
            local name = source.name
            local primary = source[metric.primary]
            local secondary = metric.secondary and source[metric.secondary] or nil

            if not self:IsSecret(name) and not self:IsSecret(primary) and not self:IsSecret(secondary)
                and name ~= nil and primary ~= nil then
                local line = string.format("%d. %s - %s", i, tostring(name), self:FormatPlainNumber(primary))
                if metric.secondary and secondary ~= nil then
                    line = line .. string.format(" - %s %s", self:FormatPlainNumber(secondary), metric.secondaryLabel or "/s")
                end
                lines[#lines + 1] = string.sub(line, 1, 240)
                added = added + 1
            end
        end
    end

    if added == 0 then
        return nil, "Les données sont encore protégées. Réessayez hors combat."
    end

    return lines
end

function DC:Report(target, maxRows)
    if InCombatLockdown and InCombatLockdown() then
        self:Print("Le partage est disponible uniquement hors combat.")
        return false
    end

    local channel, channelLabel = self:ResolveReportChannel(target)
    if not channel then
        self:Print(channelLabel)
        return false
    end

    local lines, reason = self:BuildReportLines(maxRows)
    if not lines then
        self:Print(reason)
        return false
    end

    if not SendChatMessage then
        return self:PrepareReportInChat(channel, channelLabel, lines)
    end

    -- SAY is hardware protected on current clients. Preparing the message in
    -- the edit box lets the player explicitly confirm it with Enter.
    if channel == "SAY" then
        return self:PrepareReportInChat(channel, channelLabel, lines)
    end

    for _, line in ipairs(lines) do
        local ok = pcall(SendChatMessage, line, channel)
        if not ok then
            return self:PrepareReportInChat(channel, channelLabel, lines)
        end
    end

    self:Print("Rapport envoyé : " .. channelLabel .. ".")
    return true
end
