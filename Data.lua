local _, DC = ...

function DC:IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

function DC:CheckAvailability(verbose)
    if not C_DamageMeter or not C_DamageMeter.IsDamageMeterAvailable then
        self.available = false
        self.unavailableReason = "C_DamageMeter absent"
    else
        local ok, available, reason = pcall(C_DamageMeter.IsDamageMeterAvailable)
        self.available = ok and available == true
        self.unavailableReason = reason
    end

    if verbose and not self.available then
        self:Print("Compteur de dégâts indisponible" .. (self.unavailableReason and (" : " .. tostring(self.unavailableReason)) or "."))
    end

    return self.available
end

function DC:GetCurrentSessionData()
    if not self.available and not self:CheckAvailability(false) then
        return nil
    end

    local metric = self:GetMetric()
    local sessionDef = self:GetSession()
    if not metric or not sessionDef then return nil end
    if not C_DamageMeter or not C_DamageMeter.GetCombatSessionFromType then return nil end

    local ok, session = pcall(C_DamageMeter.GetCombatSessionFromType, sessionDef.type, metric.type)
    if not ok or type(session) ~= "table" then
        return nil
    end
    return session
end

function DC:GetBreakdown(metricType, sourceGUID, sourceCreatureID)
    if not C_DamageMeter then return nil end
    -- Never branch on a secret value. Check secrecy before nil/truth tests.
    if self:IsSecret(sourceGUID) or self:IsSecret(sourceCreatureID) then return nil end
    if sourceGUID == nil and sourceCreatureID == nil then return nil end

    local sessionDef = self:GetSession()
    if not sessionDef then return nil end
    local fn = C_DamageMeter.GetCombatSessionSourceFromType
    if not fn then return nil end

    local ok, source = pcall(fn, sessionDef.type, metricType, sourceGUID, sourceCreatureID)
    if not ok or type(source) ~= "table" then return nil end
    return source
end

local suffixes = {
    { 1000000000, "B" },
    { 1000000, "M" },
    { 1000, "K" },
}

function DC:FormatPlainNumber(value)
    local n = tonumber(value)
    if not n then return "0" end

    for _, entry in ipairs(suffixes) do
        local threshold, suffix = entry[1], entry[2]
        if math.abs(n) >= threshold then
            local scaled = n / threshold
            if scaled >= 100 then
                return string.format("%.0f%s", scaled, suffix)
            elseif scaled >= 10 then
                return string.format("%.1f%s", scaled, suffix)
            else
                return string.format("%.2f%s", scaled, suffix)
            end
        end
    end

    return string.format("%.0f", n)
end

function DC:SetNumberText(fontString, value)
    -- Secret values must go directly through Blizzard-safe/native formatting.
    if self:IsSecret(value) then
        if AbbreviateNumbers then
            fontString:SetText(AbbreviateNumbers(value))
        else
            fontString:SetText(value)
        end
        return
    end

    if value == nil then
        fontString:SetText("")
        return
    end

    fontString:SetText(self:FormatPlainNumber(value))
end

function DC:GetClassColor(classFilename)
    if self:IsSecret(classFilename) then
        return 0.30, 0.55, 0.95
    end
    local c = classFilename and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFilename]
    if c then return c.r, c.g, c.b end
    return 0.30, 0.55, 0.95
end

function DC:GetSpellInfoSafe(spellID)
    if self:IsSecret(spellID) then return nil, nil end
    if spellID == nil then return nil, nil end

    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            return info.name or ("Sort " .. tostring(spellID)), info.iconID
        end
    end

    if GetSpellInfo then
        local name, _, icon = GetSpellInfo(spellID)
        return name, icon
    end

    return "Sort " .. tostring(spellID), nil
end
