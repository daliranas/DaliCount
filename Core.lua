local ADDON_NAME, DC = ...

_G.DaliCount = DC
DC.name = ADDON_NAME
DC.version = "0.9.0-beta"
DC.author = "Daliranas"

DC.metrics = {
    { key = "damage",      label = "Dégâts",          type = 0, primary = "totalAmount",     secondary = "amountPerSecond", secondaryLabel = "DPS" },
    { key = "dps",         label = "DPS",             type = 1, primary = "amountPerSecond" },
    { key = "healing",     label = "Soins",           type = 2, primary = "totalAmount",     secondary = "amountPerSecond", secondaryLabel = "HPS" },
    { key = "hps",         label = "HPS",             type = 3, primary = "amountPerSecond" },
    { key = "absorbs",     label = "Absorptions",     type = 4, primary = "totalAmount" },
    { key = "interrupts",  label = "Interruptions",   type = 5, primary = "totalAmount" },
    { key = "dispels",     label = "Dissipations",    type = 6, primary = "totalAmount" },
    { key = "taken",       label = "Dégâts subis",    type = 7, primary = "totalAmount",     secondary = "amountPerSecond", secondaryLabel = "/s" },
    { key = "avoidable",   label = "Dégâts évitables",type = 8, primary = "totalAmount" },
    { key = "deaths",      label = "Morts",           type = 9, primary = "totalAmount" },
}

DC.sessions = {
    { key = "current", label = "Combat",  type = 1 },
    { key = "overall", label = "Session", type = 0 },
}

local defaults = {
    metricIndex = 1,
    sessionIndex = 1,
    shown = true,
    locked = false,
    rows = 10,
    autoRows = true,
    width = 340,
    opacity = 0.16,
    point = "CENTER",
    relativePoint = "CENTER",
    x = 420,
    y = 40,
    scale = 1,
}

local validPoints = {
    TOP = true, TOPLEFT = true, TOPRIGHT = true,
    LEFT = true, CENTER = true, RIGHT = true,
    BOTTOM = true, BOTTOMLEFT = true, BOTTOMRIGHT = true,
}

local function clamp(value, minimum, maximum, fallback)
    value = tonumber(value)
    if not value then return fallback end
    return math.max(minimum, math.min(maximum, value))
end

local function copyDefaults(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = value
        end
    end
end

local function sanitizeDatabase(db)
    if tonumber(db.uiRevision) ~= 5 then
        db.width = defaults.width
        db.opacity = defaults.opacity
        db.autoRows = true
        db.uiRevision = 5
    end
    db.metricIndex = math.floor(clamp(db.metricIndex, 1, #DC.metrics, defaults.metricIndex))
    db.sessionIndex = math.floor(clamp(db.sessionIndex, 1, #DC.sessions, defaults.sessionIndex))
    db.rows = math.floor(clamp(db.rows, 1, 15, defaults.rows))
    db.scale = clamp(db.scale, 0.75, 1.50, defaults.scale)
    db.width = clamp(db.width, 300, 650, defaults.width)
    db.opacity = clamp(db.opacity, 0.10, 1.00, defaults.opacity)
    db.x = clamp(db.x, -10000, 10000, defaults.x)
    db.y = clamp(db.y, -10000, 10000, defaults.y)
    db.point = validPoints[db.point] and db.point or defaults.point
    db.relativePoint = validPoints[db.relativePoint] and db.relativePoint or defaults.relativePoint
    db.shown = db.shown ~= false
    db.locked = db.locked == true
    db.autoRows = db.autoRows ~= false
end

function DC:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff4aa3ffDaliCount|r: " .. tostring(msg))
end

function DC:GetMetric()
    local idx = (self.db and self.db.metricIndex) or 1
    return self.metrics[idx] or self.metrics[1]
end

function DC:GetSession()
    local idx = (self.db and self.db.sessionIndex) or 1
    return self.sessions[idx] or self.sessions[1]
end

function DC:CycleMetric(step)
    if not self.db then return end
    local count = #self.metrics
    self.db.metricIndex = ((self.db.metricIndex - 1 + (step or 1)) % count) + 1
    if self.Refresh then self:Refresh(true) end
end

function DC:CycleSession()
    if not self.db then return end
    local count = #self.sessions
    self.db.sessionIndex = (self.db.sessionIndex % count) + 1
    if self.Refresh then self:Refresh(true) end
end

function DC:SetMetricByKey(key)
    key = string.lower(key or "")
    for i, metric in ipairs(self.metrics) do
        if metric.key == key then
            self.db.metricIndex = i
            if self.Refresh then self:Refresh(true) end
            return true
        end
    end
    return false
end

function DC:SetSessionByKey(key)
    key = string.lower(key or "")
    for i, session in ipairs(self.sessions) do
        if session.key == key then
            self.db.sessionIndex = i
            if self.Refresh then self:Refresh(true) end
            return true
        end
    end
    return false
end

function DC:SetScale(value)
    if not self.db then return end
    self.db.scale = clamp(value, 0.75, 1.50, defaults.scale)
    if self.ApplyScale then self:ApplyScale() end
    self:Print(string.format("Échelle : %d%%.", math.floor(self.db.scale * 100 + 0.5)))
end

function DC:SetOpacity(value)
    if not self.db then return end
    self.db.opacity = clamp(value, 0.10, 1.00, defaults.opacity)
    if self.ApplyOpacity then self:ApplyOpacity() end
    self:Print(string.format("Opacité du fond : %d%%.", math.floor(self.db.opacity * 100 + 0.5)))
end

function DC:ResetPosition()
    if not self.db then return end
    self.db.point = defaults.point
    self.db.relativePoint = defaults.relativePoint
    self.db.x = defaults.x
    self.db.y = defaults.y
    self.db.scale = defaults.scale
    self.db.width = defaults.width
    if self.ApplyDB then self:ApplyDB() end
    self:Print("Position, largeur et échelle réinitialisées.")
end

function DC:ResetMeter()
    if InCombatLockdown and InCombatLockdown() then
        self:Print("La réinitialisation est bloquée pendant le combat.")
        return
    end

    if C_DamageMeter and C_DamageMeter.ResetAllCombatSessions then
        local ok = pcall(C_DamageMeter.ResetAllCombatSessions)
        if ok then
            self:Print("Données de combat réinitialisées.")
        else
            self:Print("Impossible de réinitialiser C_DamageMeter.")
        end
    else
        self:Print("C_DamageMeter n'est pas disponible sur ce client.")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

local damageEventsRegistered = false

local function registerDamageMeterEvents()
    if damageEventsRegistered then return end
    local events = {
        "DAMAGE_METER_CURRENT_SESSION_UPDATED",
        "DAMAGE_METER_COMBAT_SESSION_UPDATED",
        "DAMAGE_METER_RESET",
    }
    for _, eventName in ipairs(events) do
        pcall(eventFrame.RegisterEvent, eventFrame, eventName)
    end
    damageEventsRegistered = true
end

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        DaliCountDB = DaliCountDB or {}
        copyDefaults(DaliCountDB, defaults)
        sanitizeDatabase(DaliCountDB)
        DC.db = DaliCountDB
        registerDamageMeterEvents()
        if DC.CreateUI then DC:CreateUI() end
        if DC.ApplyDB then DC:ApplyDB() end
        return
    end

    if event == "PLAYER_LOGIN" then
        registerDamageMeterEvents()
        if DC.CheckAvailability then DC:CheckAvailability(true) end
        if DC.Refresh then DC:Refresh(true) end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        if DC.Refresh then
            C_Timer.After(0.15, function() DC:Refresh(true) end)
        end
        return
    end

    if event == "PLAYER_REGEN_DISABLED" then
        if DC.Refresh then DC:Refresh(true) end
        return
    end

    if event == "DAMAGE_METER_CURRENT_SESSION_UPDATED"
        or event == "DAMAGE_METER_COMBAT_SESSION_UPDATED"
        or event == "DAMAGE_METER_RESET" then
        if DC.Refresh then DC:Refresh(false) end
    end
end)

SLASH_DALICOUNT1 = "/dalicount"
SLASH_DALICOUNT2 = "/dc"
SlashCmdList.DALICOUNT = function(msg)
    msg = msg or ""
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")
    rest = string.lower(rest or "")

    if command == "" or command == "toggle" then
        if DC.Toggle then DC:Toggle() end
    elseif command == "show" then
        if DC.Show then DC:Show() end
    elseif command == "hide" then
        if DC.Hide then DC:Hide() end
    elseif command == "reset" then
        DC:ResetMeter()
    elseif command == "metric" or command == "mode" then
        if rest == "" then
            DC:CycleMetric(1)
        elseif not DC:SetMetricByKey(rest) then
            DC:Print("Mode inconnu. damage, dps, healing, hps, absorbs, interrupts, dispels, taken, avoidable, deaths")
        end
    elseif command == "combat" or command == "current" then
        DC:SetSessionByKey("current")
    elseif command == "session" or command == "overall" then
        DC:SetSessionByKey("overall")
    elseif command == "lock" then
        DC.db.locked = true
        if DC.ApplyLock then DC:ApplyLock() end
        DC:Print("Fenêtre verrouillée.")
    elseif command == "unlock" then
        DC.db.locked = false
        if DC.ApplyLock then DC:ApplyLock() end
        DC:Print("Fenêtre déverrouillée.")
    elseif command == "rows" then
        local n = tonumber(rest)
        if n then
            DC.db.rows = math.max(1, math.min(15, math.floor(n)))
            if DC.LayoutRows then DC:LayoutRows() end
            if DC.Refresh then DC:Refresh(true) end
        else
            DC:Print("Usage : /dc rows 1-15")
        end
    elseif command == "auto" then
        if rest == "on" then
            DC.db.autoRows = true
        elseif rest == "off" then
            DC.db.autoRows = false
        else
            DC.db.autoRows = not DC.db.autoRows
        end
        if DC.LayoutRows then DC:LayoutRows() end
        if DC.Refresh then DC:Refresh(true) end
        DC:Print("Hauteur automatique : " .. (DC.db.autoRows and "activée." or "désactivée."))
    elseif command == "scale" then
        local n = tonumber(rest)
        if n then
            if n > 2 then n = n / 100 end
            DC:SetScale(n)
        else
            DC:Print("Usage : /dc scale 75-150")
        end
    elseif command == "opacity" or command == "alpha" then
        local n = tonumber(rest)
        if n then
            if n > 1 then n = n / 100 end
            DC:SetOpacity(n)
        else
            DC:Print("Usage : /dc opacity 10-100")
        end
    elseif command == "report" or command == "share" then
        local target, count = rest:match("^(%S*)%s*(%d*)$")
        target = target ~= "" and target or "group"
        if DC.Report then DC:Report(target, tonumber(count)) end
    elseif command == "position" then
        DC:ResetPosition()
    elseif command == "version" or command == "about" then
        DC:Print("Version " .. DC.version .. " — développé par " .. DC.author .. ".")
    elseif command == "help" then
        DC:Print("/dc - afficher/masquer")
        DC:Print("/dc mode <damage|dps|healing|hps|absorbs|interrupts|dispels|taken|avoidable|deaths>")
        DC:Print("/dc combat | /dc session | /dc reset | /dc lock | /dc unlock")
        DC:Print("/dc rows 1-15 | /dc auto on|off | /dc scale 75-150")
        DC:Print("/dc opacity 10-100 | /dc position | /dc version")
        DC:Print("/dc report <groupe|dire|raid> [1-10]")
    else
        DC:Print("Commande inconnue. /dc help")
    end
end
