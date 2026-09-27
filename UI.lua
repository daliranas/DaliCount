local _, DC = ...

local FRAME_WIDTH = 380
local HEADER_HEIGHT = 29
local ROW_HEIGHT = 24
local ROW_GAP = 1
local FOOTER_SPACE = 10
local CONTENT_TOP = -29
local BREAKDOWN_WIDTH = 380
local BREAKDOWN_HEADER = 56
local BREAKDOWN_ROW_HEIGHT = 23

local COLORS = {
    panel = { 0.015, 0.018, 0.025, 0.30 },
    panelAlt = { 0.040, 0.047, 0.060, 0.90 },
    gold = { 0.95, 0.70, 0.20, 1.00 },
    goldDim = { 0.35, 0.29, 0.17, 0.90 },
    border = { 0.12, 0.14, 0.18, 0.55 },
}

local function makeBackdrop(frame, alpha)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], alpha or COLORS.panel[4])
    frame:SetBackdropBorderColor(unpack(COLORS.border))
end

local function makeButton(parent, text, width)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(width, 20)
    b:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    b:SetBackdropColor(0.035, 0.041, 0.052, 0.06)
    b:SetBackdropBorderColor(0.10, 0.12, 0.15, 0)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.text:SetPoint("CENTER")
    b.text:SetText(text)
    b.text:SetTextColor(0.82, 0.82, 0.80)

    local highlight = b:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
    highlight:SetPoint("TOPLEFT", 1, -1)
    highlight:SetPoint("BOTTOMRIGHT", -1, 1)
    highlight:SetColorTexture(1, 0.82, 0, 0.08)

    local underline = b:CreateTexture(nil, "ARTWORK")
    underline:SetTexture("Interface\\Buttons\\WHITE8X8")
    underline:SetPoint("BOTTOMLEFT", 1, 1)
    underline:SetPoint("BOTTOMRIGHT", -1, 1)
    underline:SetHeight(1)
    underline:SetColorTexture(0.40, 0.34, 0.22, 0.45)
    b.underline = underline

    b:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.075, 0.066, 0.045, 0.42)
        self:SetBackdropBorderColor(0.25, 0.22, 0.15, 0)
        self.underline:SetColorTexture(unpack(COLORS.gold))
        self.text:SetTextColor(1, 0.93, 0.62)
    end)
    b:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.035, 0.041, 0.052, 0.06)
        self:SetBackdropBorderColor(0.10, 0.12, 0.15, 0)
        self.underline:SetColorTexture(unpack(COLORS.goldDim))
        self.text:SetTextColor(0.82, 0.82, 0.80)
    end)
    b:SetScript("OnMouseDown", function(self)
        self.text:SetPoint("CENTER", 1, -1)
    end)
    b:SetScript("OnMouseUp", function(self)
        self.text:SetPoint("CENTER", 0, 0)
    end)
    return b
end

local function makeCloseButton(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(22, 22)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    b.text:SetPoint("CENTER", 0, 1)
    b.text:SetText("×")
    b.text:SetTextColor(0.55, 0.57, 0.60)
    b:SetScript("OnEnter", function(self)
        self.text:SetTextColor(1, 0.35, 0.25)
    end)
    b:SetScript("OnLeave", function(self)
        self.text:SetTextColor(0.55, 0.57, 0.60)
    end)
    return b
end

local function makeResizeGrip(parent)
    local grip = CreateFrame("Button", nil, parent)
    grip:SetSize(12, 12)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetPoint("BOTTOMRIGHT", -1, 1)
    return grip
end

local function addTooltip(frame, title, description)
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(title, 0.29, 0.64, 1)
        if description then
            GameTooltip:AddLine(description, 0.82, 0.84, 0.90, true)
        end
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function DC:CreateUI()
    if self.frame then return end

    local frame = CreateFrame("Frame", "DaliCountFrame", UIParent, "BackdropTemplate")
    self.frame = frame
    frame:SetSize(FRAME_WIDTH, HEADER_HEIGHT + ROW_HEIGHT + FOOTER_SPACE)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(300, HEADER_HEIGHT + ROW_HEIGHT + FOOTER_SPACE, 650, HEADER_HEIGHT + 15 * (ROW_HEIGHT + ROW_GAP) + FOOTER_SPACE)
    else
        frame:SetMinResize(300, HEADER_HEIGHT + ROW_HEIGHT + FOOTER_SPACE)
        frame:SetMaxResize(650, HEADER_HEIGHT + 15 * (ROW_HEIGHT + ROW_GAP) + FOOTER_SPACE)
    end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    makeBackdrop(frame, (self.db and self.db.opacity) or COLORS.panel[4])

    local shadow = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow:SetTexture("Interface\\Buttons\\WHITE8X8")
    shadow:SetPoint("TOPLEFT", -4, 4)
    shadow:SetPoint("BOTTOMRIGHT", 4, -4)
    shadow:SetColorTexture(0, 0, 0, 0.48)

    frame:SetScript("OnDragStart", function(f)
        if not DC.db or DC.db.locked then return end
        f:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        if not DC.db then return end
        local point, _, relativePoint, x, y = f:GetPoint(1)
        DC.db.point = point or "CENTER"
        DC.db.relativePoint = relativePoint or point or "CENTER"
        DC.db.x = x or 0
        DC.db.y = y or 0
    end)
    frame:SetScript("OnSizeChanged", function()
        if DC.LayoutWidth then DC:LayoutWidth() end
    end)

    local header = frame:CreateTexture(nil, "BACKGROUND")
    header:SetTexture("Interface\\Buttons\\WHITE8X8")
    header:SetPoint("TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", -1, -1)
    header:SetHeight(27)
    header:SetColorTexture(0.025, 0.030, 0.040, 0.48)
    self.headerTexture = header

    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetTexture("Interface\\Buttons\\WHITE8X8")
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(1)
    accent:SetColorTexture(unpack(COLORS.gold))

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -7)
    title:SetText("|cfff2b333Dali|r|cffe8e8e8Count|r")
    self.title = title

    local version = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    version:SetPoint("LEFT", title, "RIGHT", 7, -1)
    version:SetText("v" .. self.version)
    version:SetTextColor(0.38, 0.40, 0.43)
    version:Hide()

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    status:SetPoint("TOPRIGHT", -31, -10)
    status:SetText("")
    status:SetTextColor(0.72, 0.72, 0.68)
    self.statusText = status
    status:Hide()

    local metricButton = makeButton(frame, "Dégâts", 100)
    metricButton:SetPoint("TOPLEFT", 82, -4)
    metricButton:SetScript("OnClick", function(_, button)
        DC:CycleMetric(button == "RightButton" and -1 or 1)
    end)
    metricButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    addTooltip(metricButton, "Type de données", "Clic gauche : suivant\nClic droit : précédent")
    self.metricButton = metricButton

    local sessionButton = makeButton(frame, "Combat", 70)
    sessionButton:SetPoint("LEFT", metricButton, "RIGHT", 3, 0)
    sessionButton:SetScript("OnClick", function() DC:CycleSession() end)
    addTooltip(sessionButton, "Période", "Basculer entre le combat actuel et la session globale.")
    self.sessionButton = sessionButton

    local resetButton = makeButton(frame, "R", 22)
    resetButton:SetPoint("TOPRIGHT", -27, -4)
    resetButton:SetScript("OnClick", function() DC:ResetMeter() end)
    addTooltip(resetButton, "Réinitialiser", "Efface toutes les sessions du compteur de combat.")
    self.resetButton = resetButton

    local shareButton = makeButton(frame, "P", 22)
    shareButton:SetPoint("TOPRIGHT", -51, -4)
    shareButton:SetScript("OnClick", function() DC:ToggleShareMenu() end)
    addTooltip(shareButton, "Partager", "Publier le classement dans le canal Groupe, Dire ou Raid.")
    self.shareButton = shareButton

    local closeButton = makeCloseButton(frame)
    closeButton:SetPoint("TOPRIGHT", -3, -4)
    closeButton:SetScript("OnClick", function() DC:Hide() end)
    addTooltip(closeButton, "Masquer", "Utilisez /dc pour réafficher DaliCount.")

    local resizeGrip = makeResizeGrip(frame)
    self.resizeGrip = resizeGrip
    resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or not DC.db or DC.db.locked then return end
        frame:StartSizing("RIGHT")
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        if not DC.db then return end
        local width = math.max(300, math.min(650, frame:GetWidth()))
        DC.db.width = width
        DC:LayoutRows()
    end)
    addTooltip(resizeGrip, "Redimensionner", "Faites glisser horizontalement pour modifier la largeur.")

    self.rows = {}
    for i = 1, 15 do
        local row = CreateFrame("Button", nil, frame, "BackdropTemplate")
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 7, CONTENT_TOP - (i - 1) * (ROW_HEIGHT + ROW_GAP))
        row:SetPoint("TOPRIGHT", -7, CONTENT_TOP - (i - 1) * (ROW_HEIGHT + ROW_GAP))
        row:RegisterForClicks("LeftButtonUp")
        row:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
        })
        if i % 2 == 0 then
            row:SetBackdropColor(COLORS.panelAlt[1], COLORS.panelAlt[2], COLORS.panelAlt[3], 0.12)
        else
            row:SetBackdropColor(0.028, 0.032, 0.042, 0.08)
        end

        local bar = CreateFrame("StatusBar", nil, row)
        bar:SetPoint("TOPLEFT", 1, -1)
        bar:SetPoint("BOTTOMRIGHT", -1, 1)
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(0)
        row.bar = bar

        local shade = bar:CreateTexture(nil, "OVERLAY")
        shade:SetTexture("Interface\\Buttons\\WHITE8X8")
        shade:SetPoint("TOPLEFT")
        shade:SetPoint("BOTTOMRIGHT")
        shade:SetColorTexture(0, 0, 0, 0.14)

        -- Child frames render above regions created directly on their parent.
        -- Keep all readable content on a dedicated layer above the StatusBar.
        local overlay = CreateFrame("Frame", nil, row)
        overlay:SetAllPoints(row)
        overlay:SetFrameLevel(bar:GetFrameLevel() + 1)
        row.overlay = overlay

        local glow = overlay:CreateTexture(nil, "ARTWORK")
        glow:SetTexture("Interface\\Buttons\\WHITE8X8")
        glow:SetPoint("TOPLEFT", 1, -1)
        glow:SetPoint("BOTTOMRIGHT", -1, 1)
        glow:SetColorTexture(1, 0.82, 0, 0.07)
        glow:Hide()
        row.glow = glow

        local rank = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        rank:SetPoint("LEFT", 5, 0)
        rank:SetWidth(18)
        rank:SetJustifyH("RIGHT")
        rank:SetTextColor(0.74, 0.72, 0.66)
        row.rank = rank

        local icon = overlay:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", rank, "RIGHT", 6, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:Hide()
        row.icon = icon

        local name = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", icon, "RIGHT", 7, 0)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        name:SetShadowColor(0, 0, 0, 1)
        name:SetShadowOffset(1, -1)
        name:SetTextColor(1, 1, 1)
        row.nameText = name

        local localPlayer = overlay:CreateTexture(nil, "OVERLAY")
        localPlayer:SetSize(2, ROW_HEIGHT - 4)
        localPlayer:SetPoint("LEFT", 2, 0)
        localPlayer:SetColorTexture(unpack(COLORS.gold))
        localPlayer:Hide()
        row.localPlayer = localPlayer

        local primary = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        primary:SetPoint("RIGHT", -7, 0)
        primary:SetWidth(52)
        primary:SetJustifyH("RIGHT")
        primary:SetShadowColor(0, 0, 0, 1)
        primary:SetShadowOffset(1, -1)
        primary:SetTextColor(1, 0.95, 0.78)
        row.primaryText = primary
        name:SetPoint("RIGHT", primary, "LEFT", -8, 0)

        local secondaryLabel = overlay:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        secondaryLabel:SetPoint("RIGHT", -7, 0)
        secondaryLabel:SetWidth(28)
        secondaryLabel:SetJustifyH("RIGHT")
        secondaryLabel:SetTextColor(0.82, 0.67, 0.34)
        row.secondaryLabel = secondaryLabel

        local secondary = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        secondary:SetPoint("RIGHT", secondaryLabel, "LEFT", -3, 0)
        secondary:SetWidth(32)
        secondary:SetJustifyH("RIGHT")
        secondary:SetShadowColor(0, 0, 0, 1)
        secondary:SetShadowOffset(1, -1)
        secondary:SetTextColor(0.92, 0.92, 0.90)
        row.secondaryText = secondary

        row:SetScript("OnEnter", function(self)
            self.rank:SetTextColor(1, 0.82, 0)
            self.glow:Show()
        end)
        row:SetScript("OnLeave", function(self)
            self.rank:SetTextColor(0.74, 0.72, 0.66)
            self.glow:Hide()
        end)
        row:SetScript("OnClick", function(self)
            DC:OpenBreakdownForRow(self)
        end)

        self.rows[i] = row
    end

    self:CreateBreakdownUI()
    self:CreateShareMenu()
    self:LayoutRows()

    self.refreshTicker = C_Timer.NewTicker(0.25, function()
        if DC.frame and DC.frame:IsShown() then
            DC:Refresh(false)
        end
    end)
end

function DC:LayoutWidth()
    if not self.frame or not self.metricButton or not self.sessionButton or not self.resetButton then return end
    local innerWidth = math.max(138, self.frame:GetWidth() - 162)
    local metricWidth = math.floor(innerWidth * 0.58)
    local sessionWidth = innerWidth - metricWidth
    self.metricButton:SetWidth(metricWidth)
    self.sessionButton:SetWidth(sessionWidth)
    self.resetButton:SetWidth(22)
end

function DC:CreateShareMenu()
    if self.shareMenu then return end

    local menu = CreateFrame("Frame", "DaliCountShareMenu", self.frame, "BackdropTemplate")
    self.shareMenu = menu
    menu:SetSize(116, 82)
    menu:SetPoint("TOPRIGHT", self.frame, "BOTTOMRIGHT", -2, -2)
    menu:SetFrameStrata("DIALOG")
    menu:SetClampedToScreen(true)
    makeBackdrop(menu, 0.88)
    menu:Hide()

    local choices = {
        { label = "Groupe", target = "group" },
        { label = "Dire", target = "say" },
        { label = "Raid", target = "raid" },
    }

    for i, choice in ipairs(choices) do
        local button = makeButton(menu, choice.label, 102)
        local target = choice.target
        button:SetPoint("TOPLEFT", 7, -7 - (i - 1) * 24)
        button:SetScript("OnClick", function()
            menu:Hide()
            DC:Report(target, 5)
        end)
    end
end

function DC:ToggleShareMenu()
    if not self.shareMenu then return end
    if self.shareMenu:IsShown() then
        self.shareMenu:Hide()
    else
        self.shareMenu:Show()
    end
end

function DC:LayoutValueColumns(metric)
    if not self.rows then return end
    local hasSecondary = metric and metric.secondary ~= nil
    for _, row in ipairs(self.rows) do
        if row.hasSecondaryLayout ~= hasSecondary then
            row.hasSecondaryLayout = hasSecondary
            row.primaryText:ClearAllPoints()
            row.secondaryText:ClearAllPoints()
            row.secondaryLabel:ClearAllPoints()
            if hasSecondary then
                row.secondaryLabel:SetPoint("RIGHT", -7, 0)
                row.secondaryText:SetPoint("RIGHT", row.secondaryLabel, "LEFT", -3, 0)
                row.primaryText:SetPoint("RIGHT", row.secondaryText, "LEFT", -8, 0)
            else
                row.primaryText:SetPoint("RIGHT", -7, 0)
                row.secondaryLabel:SetPoint("RIGHT", -7, 0)
                row.secondaryText:SetPoint("RIGHT", row.secondaryLabel, "LEFT", -3, 0)
            end
        end
    end
end

function DC:CreateBreakdownUI()
    if self.breakdownFrame then return end

    local f = CreateFrame("Frame", "DaliCountBreakdownFrame", UIParent, "BackdropTemplate")
    self.breakdownFrame = f
    f:SetSize(BREAKDOWN_WIDTH, BREAKDOWN_HEADER + BREAKDOWN_ROW_HEIGHT + 10)
    f:SetPoint("CENTER", 120, 0)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    makeBackdrop(f, (self.db and self.db.opacity) or COLORS.panel[4])
    f:Hide()

    local shadow = f:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow:SetTexture("Interface\\Buttons\\WHITE8X8")
    shadow:SetPoint("TOPLEFT", -4, 4)
    shadow:SetPoint("BOTTOMRIGHT", 4, -4)
    shadow:SetColorTexture(0, 0, 0, 0.48)

    local accent = f:CreateTexture(nil, "ARTWORK")
    accent:SetTexture("Interface\\Buttons\\WHITE8X8")
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(1)
    accent:SetColorTexture(unpack(COLORS.gold))

    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -6)
    title:SetPoint("TOPRIGHT", -31, -6)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    title:SetText("Détails")
    title:SetTextColor(unpack(COLORS.gold))
    f.title = title

    local subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subtitle:SetPoint("TOPLEFT", 10, -25)
    subtitle:SetPoint("TOPRIGHT", -31, -25)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetWordWrap(false)
    subtitle:SetText("")
    subtitle:SetTextColor(0.68, 0.66, 0.60)
    f.subtitle = subtitle

    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetTexture("Interface\\Buttons\\WHITE8X8")
    divider:SetPoint("TOPLEFT", 9, -39)
    divider:SetPoint("TOPRIGHT", -9, -39)
    divider:SetHeight(1)
    divider:SetColorTexture(0.58, 0.45, 0.08, 0.75)

    local close = makeCloseButton(f)
    close:SetPoint("TOPRIGHT", -3, -3)
    close:SetScript("OnClick", function() f:Hide() end)

    local spellHeader = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    spellHeader:SetPoint("TOPLEFT", 39, -42)
    spellHeader:SetText("SORT")
    spellHeader:SetTextColor(0.48, 0.50, 0.54)

    local rateHeader = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    rateHeader:SetPoint("TOPRIGHT", -75, -42)
    rateHeader:SetWidth(55)
    rateHeader:SetJustifyH("RIGHT")
    rateHeader:SetText("DPS")
    rateHeader:SetTextColor(0.48, 0.50, 0.54)
    f.rateHeader = rateHeader

    local amountHeader = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    amountHeader:SetPoint("TOPRIGHT", -7, -42)
    amountHeader:SetWidth(60)
    amountHeader:SetJustifyH("RIGHT")
    amountHeader:SetText("TOTAL")
    amountHeader:SetTextColor(0.48, 0.50, 0.54)

    f.spellRows = {}
    for i = 1, 12 do
        local row = CreateFrame("Frame", nil, f, "BackdropTemplate")
        row:SetHeight(BREAKDOWN_ROW_HEIGHT - 1)
        row:SetPoint("TOPLEFT", 10, -BREAKDOWN_HEADER - (i - 1) * BREAKDOWN_ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", -10, -BREAKDOWN_HEADER - (i - 1) * BREAKDOWN_ROW_HEIGHT)
        row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        row:SetBackdropColor(0.035, 0.042, 0.055, i % 2 == 0 and 0.62 or 0.38)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(21, 21)
        icon:SetPoint("LEFT", 2, 0)
        icon:SetTexture(134400)
        row.icon = icon

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("LEFT", icon, "RIGHT", 7, 0)
        name:SetPoint("RIGHT", row, "RIGHT", -132, 0)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        row.nameText = name

        local rate = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        rate:SetPoint("RIGHT", -76, 0)
        rate:SetWidth(55)
        rate:SetJustifyH("RIGHT")
        row.rateText = rate

        local amount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        amount:SetPoint("RIGHT", -7, 0)
        amount:SetWidth(60)
        amount:SetJustifyH("RIGHT")
        row.amountText = amount

        row:Hide()
        f.spellRows[i] = row
    end
end

function DC:ApplyDB()
    if not self.frame or not self.db then return end
    self.frame:SetWidth(self.db.width or FRAME_WIDTH)
    self:LayoutWidth()
    self.frame:ClearAllPoints()
    self.frame:SetPoint(self.db.point or "CENTER", UIParent, self.db.relativePoint or "CENTER", self.db.x or 0, self.db.y or 0)
    self:ApplyScale()
    self:ApplyOpacity()
    self:ApplyLock()
    self:LayoutRows()
    if self.db.shown then self.frame:Show() else self.frame:Hide() end
    self:Refresh(true)
end

function DC:ApplyOpacity()
    if not self.frame or not self.db then return end
    local opacity = self.db.opacity or COLORS.panel[4]
    self.frame:SetBackdropColor(COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], opacity)
    if self.headerTexture then
        self.headerTexture:SetAlpha(opacity)
    end
    if self.rows then
        for i, row in ipairs(self.rows) do
            if i % 2 == 0 then
                row:SetBackdropColor(COLORS.panelAlt[1], COLORS.panelAlt[2], COLORS.panelAlt[3], 0.26 * opacity)
            else
                row:SetBackdropColor(0.028, 0.032, 0.042, 0.20 * opacity)
            end
        end
    end
    if self.breakdownFrame then
        self.breakdownFrame:SetBackdropColor(COLORS.panel[1], COLORS.panel[2], COLORS.panel[3], opacity)
        if self.breakdownFrame.spellRows then
            for i, row in ipairs(self.breakdownFrame.spellRows) do
                row:SetBackdropColor(0.035, 0.042, 0.055, (i % 2 == 0 and 0.30 or 0.20) * opacity)
            end
        end
    end
end

function DC:ApplyScale()
    if not self.frame or not self.db then return end
    self.frame:SetScale(self.db.scale or 1)
end

function DC:ApplyLock()
    if not self.frame or not self.db then return end
    if self.db.locked then
        self.frame:SetBackdropBorderColor(0.20, 0.19, 0.16, 0.95)
        if self.resizeGrip then self.resizeGrip:Hide() end
    else
        self.frame:SetBackdropBorderColor(unpack(COLORS.border))
        if self.resizeGrip then self.resizeGrip:Show() end
    end
end

function DC:LayoutRows()
    if not self.frame or not self.rows or not self.db then return end
    local configured = math.max(1, math.min(15, self.db.rows or 10))
    local count = configured
    if self.db.autoRows then
        count = math.max(1, math.min(configured, self.visibleSourceCount or 1))
    end
    self.visibleRows = count
    local height = HEADER_HEIGHT + count * (ROW_HEIGHT + ROW_GAP) + FOOTER_SPACE
    self.frame:SetHeight(height)
    for i, row in ipairs(self.rows) do
        if i <= count then row:Show() else row:Hide() end
    end
end

function DC:Show()
    if not self.frame then return end
    self.db.shown = true
    self.frame:Show()
    self:Refresh(true)
end

function DC:Hide()
    if not self.frame then return end
    self.db.shown = false
    self.frame:Hide()
end

function DC:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then self:Hide() else self:Show() end
end

function DC:Refresh(force)
    if not self.frame or not self.frame:IsShown() or not self.db then return end

    local metric = self:GetMetric()
    local sessionDef = self:GetSession()
    self:LayoutValueColumns(metric)
    self.metricButton.text:SetText(metric.label)
    self.sessionButton.text:SetText(sessionDef.label)

    local session = self:GetCurrentSessionData()

    if not session or type(session.combatSources) ~= "table" then
        self.visibleSourceCount = 1
        self:LayoutRows()
        local maxRows = self.visibleRows or 1
        self.statusText:SetText(self.available == false and "API indisponible" or "En attente")
        for i = 1, maxRows do
            local row = self.rows[i]
            row.source = nil
            row.rank:SetText("")
            row.nameText:SetText(i == 1 and "Aucune donnée de combat" or "")
            row.icon:Hide()
            row.localPlayer:Hide()
            row.primaryText:SetText("")
            row.secondaryText:SetText("")
            row.secondaryLabel:SetText("")
            row.bar:SetMinMaxValues(0, 1)
            row.bar:SetValue(0)
            row.bar:SetStatusBarColor(0.18, 0.28, 0.45, 0.45)
        end
        return
    end

    local sources = session.combatSources
    local sourceCount = #sources
    self.visibleSourceCount = math.max(1, sourceCount)
    self:LayoutRows()
    local maxRows = self.visibleRows or 1
    self.statusText:SetText(sourceCount > 0 and (tostring(sourceCount) .. (sourceCount > 1 and " entrées" or " entrée")) or "En attente")

    local maxAmount = session.maxAmount
    if not self:IsSecret(maxAmount) and maxAmount == nil then
        maxAmount = 1
    end

    for i = 1, maxRows do
        local row = self.rows[i]
        local source = sources[i]
        if source then
            row.source = source
            row.rank:SetText(tostring(i))
            -- source.name can be a ConditionalSecret in combat: send it directly to the native FontString.
            row.nameText:SetText(source.name)

            -- specIconID and isLocalPlayer are NeverSecret fields in DamageMeterCombatSource.
            if source.specIconID and source.specIconID > 0 then
                row.icon:SetTexture(source.specIconID)
                row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                row.icon:Show()
            elseif source.classFilename and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[source.classFilename] then
                local coords = CLASS_ICON_TCOORDS[source.classFilename]
                row.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
                row.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
                row.icon:Show()
            else
                row.icon:Hide()
            end
            if source.isLocalPlayer then
                row.localPlayer:Show()
            else
                row.localPlayer:Hide()
            end

            local r, g, b = self:GetClassColor(source.classFilename)
            row.bar:SetStatusBarColor(r, g, b, source.isLocalPlayer and 0.95 or 0.78)

            -- maxAmount and the primary value may be SecretValues. StatusBar accepts them natively.
            row.bar:SetMinMaxValues(0, maxAmount)
            local primaryValue = source[metric.primary]
            row.bar:SetValue(primaryValue)
            self:SetNumberText(row.primaryText, primaryValue)

            if metric.secondary then
                row.secondaryLabel:SetText(metric.secondaryLabel or "")
                local secondaryValue = source[metric.secondary]
                if self:IsSecret(secondaryValue) then
                    self:SetNumberText(row.secondaryText, secondaryValue)
                elseif secondaryValue ~= nil then
                    self:SetNumberText(row.secondaryText, secondaryValue)
                else
                    row.secondaryText:SetText("")
                end
            else
                row.secondaryText:SetText("")
                row.secondaryLabel:SetText("")
            end
        else
            row.source = nil
            row.rank:SetText("")
            row.nameText:SetText(i == 1 and sourceCount == 0 and "Aucune donnée de combat" or "")
            row.icon:Hide()
            row.localPlayer:Hide()
            row.primaryText:SetText("")
            row.secondaryText:SetText("")
            row.secondaryLabel:SetText("")
            row.bar:SetMinMaxValues(0, 1)
            row.bar:SetValue(0)
            row.bar:SetStatusBarColor(0.12, 0.16, 0.24, 0.30)
        end
    end
end

function DC:OpenBreakdownForRow(row)
    if not row or not row.source then return end
    if InCombatLockdown and InCombatLockdown() then
        self:Print("Le détail par sort est disponible après le combat (valeurs protégées par Forever).")
        return
    end

    local source = row.source
    local guid = source.sourceGUID
    local creatureID = source.sourceCreatureID
    if self:IsSecret(guid) or self:IsSecret(creatureID) then
        self:Print("Le détail de ce joueur n'est pas encore lisible. Réessayez après le combat.")
        return
    end

    local metric = self:GetMetric()
    local details = self:GetBreakdown(metric.type, guid, creatureID)
    if not details or type(details.combatSpells) ~= "table" then
        self:Print("Aucun détail de sort disponible pour cette entrée.")
        return
    end

    local f = self.breakdownFrame
    local visibleCount = math.min(12, #details.combatSpells)
    if visibleCount == 0 then
        self:Print("Aucun sort disponible pour cette entrée.")
        return
    end

    f:SetWidth(math.max(300, math.min(480, self.db.width or BREAKDOWN_WIDTH)))
    f:SetHeight(BREAKDOWN_HEADER + visibleCount * BREAKDOWN_ROW_HEIGHT + 10)
    f.title:SetText(source.name)
    local r, g, b = self:GetClassColor(source.classFilename)
    f.title:SetTextColor(r, g, b)
    f.subtitle:SetText(metric.label .. "  •  " .. self:GetSession().label)
    if metric.key == "healing" or metric.key == "hps" then
        f.rateHeader:SetText("HPS")
    elseif metric.key == "damage" or metric.key == "dps" then
        f.rateHeader:SetText("DPS")
    else
        f.rateHeader:SetText("/S")
    end

    for i = 1, 12 do
        local spellRow = f.spellRows[i]
        local spell = details.combatSpells[i]
        if spell then
            local spellName, spellIcon = self:GetSpellInfoSafe(spell.spellID)
            spellRow.icon:SetTexture(spellIcon or 134400)
            spellRow.nameText:SetText(spellName or "Sort inconnu")
            self:SetNumberText(spellRow.amountText, spell.totalAmount)
            self:SetNumberText(spellRow.rateText, spell.amountPerSecond)
            spellRow:Show()
        else
            spellRow:Hide()
        end
    end

    f:Show()
end
