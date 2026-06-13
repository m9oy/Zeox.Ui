--[[
╔══════════════════════════════════════════╗
║   ZEOX UI Library  v3.0                  ║
║   Colors : Black / Dark-Grey / Red only  ║
║   Icons  : Roblox Asset IDs              ║
║   Layout : Sidebar + 2-column home tab   ║
╚══════════════════════════════════════════╝
]]

local ZeoxLib = {}

-- ── Services ─────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  PALETTE  (black / dark-grey / red only, no blue)
-- ═══════════════════════════════════════════════════════════
local C = {
    BG       = Color3.fromRGB(10,  10,  10),   -- window bg
    Sidebar  = Color3.fromRGB(15,  15,  15),   -- sidebar / title bar
    Panel    = Color3.fromRGB(22,  22,  22),   -- section card bg
    Card     = Color3.fromRGB(28,  28,  28),   -- card headers / buttons
    Border   = Color3.fromRGB(44,  44,  44),   -- subtle borders
    Accent   = Color3.fromRGB(204, 26,  26),   -- primary red
    AccentHi = Color3.fromRGB(232, 48,  48),   -- hover red
    AccentLo = Color3.fromRGB(90,  10,  10),   -- dark red
    Text     = Color3.fromRGB(232, 232, 232),  -- primary text
    TextDim  = Color3.fromRGB(136, 136, 136),  -- secondary
    TextMute = Color3.fromRGB(68,  68,  68),   -- muted
    Green    = Color3.fromRGB(34,  197, 94),   -- status green
    Track    = Color3.fromRGB(30,  30,  30),   -- slider / toggle off
    CodeBg   = Color3.fromRGB(8,   8,   8),    -- code editor bg
    LineNum  = Color3.fromRGB(51,  51,  51),   -- line number text
}

-- ═══════════════════════════════════════════════════════════
--  ROBLOX ICON ASSET IDs
--  (replace any ID with your own uploaded asset)
-- ═══════════════════════════════════════════════════════════
local Icon = {
    -- Z logo (large sidebar + title bar)
    ZLogo    = "rbxassetid://17929804958",

    -- Navigation
    Home     = "rbxassetid://7733960981",   -- house
    Terminal = "rbxassetid://7734053495",   -- code / terminal
    File     = "rbxassetid://7734045250",   -- document
    Gear     = "rbxassetid://7734036682",   -- settings cog

    -- Actions & features
    Refresh  = "rbxassetid://7072720526",   -- refresh arrows (Auto-Farm)
    Bolt     = "rbxassetid://7072722960",   -- lightning bolt (Speed Hack)
    Arrow2   = "rbxassetid://7072716400",   -- double chevron up (Infinite Jump)
    Runner   = "rbxassetid://7072723416",   -- running figure (Noclip)
    User     = "rbxassetid://7072724501",   -- person (Player Mods)
    Play     = "rbxassetid://7072719712",   -- play triangle (Execute / buttons)
    Trash    = "rbxassetid://7072725052",   -- trash bin (Clear)
    Check    = "rbxassetid://7072716987",   -- checkmark
    Close    = "rbxassetid://7072725342",   -- X (window close)
    Minimize = "rbxassetid://7072725640",   -- minus (window minimize)
    Maximize = "rbxassetid://7072725852",   -- square (window maximize)
    Info     = "rbxassetid://7072721342",   -- info circle (About)
}

-- ═══════════════════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════════════════
local function tw(obj, props, dur, es, ed)
    TweenService:Create(obj,
        TweenInfo.new(dur or .16, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out),
        props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color     = col or C.Border
    s.Thickness = th  or 1
    s.Parent    = p
    return s
end

local function pad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.Parent = p
end

local function listLayout(p, spacing, dir)
    local l = Instance.new("UIListLayout")
    l.Padding             = UDim.new(0, spacing or 6)
    l.FillDirection       = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Parent              = p
    return l
end

-- frame shorthand
local function F(props, parent)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k]=v end
    if parent then f.Parent = parent end
    return f
end

-- text label shorthand
local function L(props, parent)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    for k,v in pairs(props) do l[k]=v end
    if parent then l.Parent = parent end
    return l
end

-- image label shorthand
local function I(props, parent)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.BorderSizePixel        = 0
    for k,v in pairs(props) do i[k]=v end
    if parent then i.Parent = parent end
    return i
end

-- text button shorthand
local function B(props, parent)
    local b = Instance.new("TextButton")
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    for k,v in pairs(props) do b[k]=v end
    if parent then b.Parent = parent end
    return b
end

-- make draggable (mouse + touch)
local function draggable(root, handle)
    local drag, start, startPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; start = i.Position; startPos = root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                      startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════
function ZeoxLib:CreateWindow(cfg)
    cfg = cfg or {}
    local title   = cfg.Title   or "ZEOX CLIENT"
    local version = cfg.Version or "v1.0.1"

    local W, H = 800, 500   -- window size (matches mockup)

    -- ── ScreenGui ──────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name           = "ZeoxUI"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.DisplayOrder   = 999
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ── Main frame ─────────────────────────────────────────
    local main = F({
        Name             = "Main",
        Size             = UDim2.new(0, W, 0, H),
        Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = C.BG,
    }, gui)
    corner(main, 12)
    stroke(main, C.Accent, 1)

    -- ── Title bar (h=42) ───────────────────────────────────
    local titleBar = F({ Size=UDim2.new(1,0,0,42), BackgroundColor3=C.Sidebar }, main)
    corner(titleBar, 12)
    -- flatten bottom corners of title bar
    F({ Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,1,-12), BackgroundColor3=C.Sidebar }, titleBar)
    -- bottom accent line
    F({ Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.Border }, titleBar)

    -- Z logo (asset ID) in title bar
    I({
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,10,0.5,-13),
        Image=Icon.ZLogo, ImageColor3=C.Accent,
    }, titleBar)
    -- fallback background for logo
    local logoBg = F({
        Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,9,0.5,-14),
        BackgroundColor3=C.AccentLo, ZIndex=1,
    }, titleBar)
    corner(logoBg, 6)
    stroke(logoBg, C.Accent, 1)
    I({
        Size=UDim2.new(1,0,1,0), Image=Icon.ZLogo, ImageColor3=C.Accent, ZIndex=2,
    }, logoBg)

    -- Title text
    L({
        Size=UDim2.new(0,80,1,0), Position=UDim2.new(0,44,0,0),
        Text=title:match("^%S+") or title,
        Font=Enum.Font.GothamBold, TextSize=14, TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, titleBar)
    L({
        Size=UDim2.new(0,80,1,0), Position=UDim2.new(0,44+50,0,0),
        Text=title:match("%s(.+)$") or "",
        Font=Enum.Font.Gotham, TextSize=13, TextColor3=C.TextDim,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, titleBar)

    -- Version badge
    local verBadge = F({ Size=UDim2.new(0,48,0,18), Position=UDim2.new(0,155,0.5,-9), BackgroundColor3=C.Card }, titleBar)
    corner(verBadge, 4); stroke(verBadge, C.Border, 1)
    L({ Size=UDim2.new(1,0,1,0), Text=version, Font=Enum.Font.GothamMedium, TextSize=9, TextColor3=C.TextDim }, verBadge)

    -- Window control buttons
    local function winBtn(iconId, xOff, isClose, cb)
        local bg = F({ Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,xOff,0.5,-11),
            BackgroundColor3=isClose and C.AccentLo or C.Card }, titleBar)
        corner(bg, 5)
        stroke(bg, isClose and C.Accent or C.Border, 1)
        I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0.5,-6,0.5,-6),
            Image=iconId, ImageColor3=isClose and C.Accent or C.TextDim }, bg)
        local hit = B({ Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="" }, bg)
        hit.MouseEnter:Connect(function() tw(bg, {BackgroundColor3=isClose and C.Accent or C.Border}) end)
        hit.MouseLeave:Connect(function() tw(bg, {BackgroundColor3=isClose and C.AccentLo or C.Card}) end)
        hit.Activated:Connect(cb)
        return bg
    end
    winBtn(Icon.Close,    -10, true,  function()
        tw(main, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}, .2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(.25, function() gui:Destroy() end)
    end)
    winBtn(Icon.Maximize, -38, false, function() end)
    winBtn(Icon.Minimize, -66, false, function()
        local body = main:FindFirstChild("Body")
        if body then body.Visible = not body.Visible end
    end)

    draggable(main, titleBar)

    -- ── Body (below title bar) ─────────────────────────────
    local body = F({ Name="Body", Size=UDim2.new(1,0,1,-42), Position=UDim2.new(0,0,0,42), BackgroundTransparency=1 }, main)

    -- ── Sidebar (w=158) ────────────────────────────────────
    local sidebar = F({ Size=UDim2.new(0,158,1,0), BackgroundColor3=C.Sidebar }, body)
    -- right border
    F({ Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BackgroundColor3=C.Border }, sidebar)

    -- Large Z logo in sidebar
    local zBg = F({ Size=UDim2.new(0,68,0,68), Position=UDim2.new(0.5,-34,0,15), BackgroundColor3=C.AccentLo }, sidebar)
    corner(zBg, 10); stroke(zBg, C.AccentLo, 1)
    I({ Size=UDim2.new(1,0,1,0), Image=Icon.ZLogo, ImageColor3=C.Accent }, zBg)

    -- Nav list container
    local navList = F({ Size=UDim2.new(1,0,1,-100), Position=UDim2.new(0,0,0,100), BackgroundTransparency=1 }, sidebar)
    listLayout(navList, 0)

    -- ── Status bar (h=26) ──────────────────────────────────
    local statusBar = F({ Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,1,-26), BackgroundColor3=C.Sidebar }, body)
    F({ Size=UDim2.new(1,0,0,1), BackgroundColor3=C.Border }, statusBar)
    L({ Size=UDim2.new(0,58,1,0), Position=UDim2.new(0,12,0,0), Text="STATUS:", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.TextMute, TextXAlignment=Enum.TextXAlignment.Left }, statusBar)
    local statusTxt = L({ Size=UDim2.new(0,80,1,0), Position=UDim2.new(0,70,0,0), Text="ATTACHED", Font=Enum.Font.GothamMedium, TextSize=9, TextColor3=C.TextDim, TextXAlignment=Enum.TextXAlignment.Left }, statusBar)
    local statusDot = F({ Size=UDim2.new(0,5,0,5), Position=UDim2.new(0,65,0.5,-2), BackgroundColor3=C.Green }, statusBar)
    corner(statusDot, 99)
    -- welcome right side
    local pName = LocalPlayer and LocalPlayer.Name or "USER"
    L({ Size=UDim2.new(0,120,1,0), Position=UDim2.new(1,-130,0,0), Text="WELCOME,", Font=Enum.Font.GothamMedium, TextSize=9, TextColor3=C.TextMute, TextXAlignment=Enum.TextXAlignment.Right }, statusBar)
    L({ Size=UDim2.new(0,80,1,0), Position=UDim2.new(1,-8-#pName*7,0,0), Text=pName, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Accent, TextXAlignment=Enum.TextXAlignment.Right }, statusBar)

    -- ── Content area ───────────────────────────────────────
    local content = F({ Name="Content", Size=UDim2.new(1,-158,1,-26), Position=UDim2.new(0,158,0,0), BackgroundTransparency=1 }, body)

    -- ── Window object ──────────────────────────────────────
    local Win = {
        _gui=gui, _main=main, _sidebar=sidebar, _navList=navList,
        _content=content, _tabs={}, _active=nil,
        _statusTxt=statusTxt, _statusDot=statusDot,
    }

    -- Entrance animation
    main.Size     = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0.5,0,0.5,0)
    tw(main, { Size=UDim2.new(0,W,0,H), Position=UDim2.new(0.5,-W/2,0.5,-H/2) },
        .3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ── SetStatus ──────────────────────────────────────────
    function Win:SetStatus(text, isOk)
        statusTxt.Text = text or "ATTACHED"
        local col = isOk ~= false and C.Green or C.Accent
        statusTxt.TextColor3 = col
        statusDot.BackgroundColor3 = col
    end

    -- ── _activateTab ───────────────────────────────────────
    function Win:_activateTab(tab)
        if self._active then
            local p = self._active
            if p._page  then p._page.Visible  = false end
            if p._split then p._split.Visible = false end
            if p._exec  then p._exec.Visible  = false end
            tw(p._btn,  {BackgroundColor3=C.Sidebar})
            tw(p._icon, {ImageColor3=C.TextDim})
            tw(p._lbl,  {TextColor3=C.TextDim})
            p._bar.Visible = false
        end
        self._active = tab
        if tab._page  then tab._page.Visible  = true end
        if tab._split then tab._split.Visible = true end
        if tab._exec  then tab._exec.Visible  = true end
        tw(tab._btn,  {BackgroundColor3=C.Card})
        tw(tab._icon, {ImageColor3=C.Accent})
        tw(tab._lbl,  {TextColor3=C.Text})
        tab._bar.Visible = true
    end

    -- ╔══════════════════════════════════════════╗
    -- ║  AddTab                                  ║
    -- ╚══════════════════════════════════════════╝
    function Win:AddTab(cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "TAB"
        local iconId = cfg2.Icon or Icon.Home

        -- Nav button
        local btn = B({ Name=name.."_Btn", Size=UDim2.new(1,0,0,40), BackgroundColor3=C.Sidebar, Text="" }, navList)

        -- Active left bar
        local bar = F({ Size=UDim2.new(0,2,0.56,0), Position=UDim2.new(0,0,0.22,0), BackgroundColor3=C.Accent, Visible=false }, btn)
        corner(bar, 2)

        -- Icon
        local ico = I({ Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,16,0.5,-7), Image=iconId, ImageColor3=C.TextDim }, btn)

        -- Label
        local lbl = L({ Size=UDim2.new(1,-38,1,0), Position=UDim2.new(0,36,0,0), Text=name, Font=Enum.Font.GothamSemibold, TextSize=10, TextColor3=C.TextDim, TextXAlignment=Enum.TextXAlignment.Left }, btn)

        -- Normal scroll page (for standard tabs)
        local page = Instance.new("ScrollingFrame")
        page.Name                 = name.."_Page"
        page.Size                 = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel      = 0
        page.ScrollBarThickness   = 2
        page.ScrollBarImageColor3 = C.Accent
        page.CanvasSize           = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize  = Enum.AutomaticSize.Y
        page.Visible              = false
        page.Parent               = content
        pad(page, 10, 10, 10, 10)
        listLayout(page, 8)

        local tab = { _win=self, _page=page, _btn=btn, _icon=ico, _lbl=lbl, _bar=bar, _split=nil, _exec=nil }
        table.insert(self._tabs, tab)
        if #self._tabs == 1 then self:_activateTab(tab) end

        btn.MouseEnter:Connect(function()
            if self._active ~= tab then tw(btn,{BackgroundColor3=C.Panel}) end
        end)
        btn.MouseLeave:Connect(function()
            if self._active ~= tab then tw(btn,{BackgroundColor3=C.Sidebar}) end
        end)
        btn.Activated:Connect(function() self:_activateTab(tab) end)

        -- ──────────────────────────────────────────────────
        --  SECTION BUILDER  (shared helper)
        -- ──────────────────────────────────────────────────
        local function buildSection(sName, sIcon, parentFrame)
            -- Section card
            local card = F({ Name=sName.."_Card", Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=C.Panel }, parentFrame)
            corner(card, 8); stroke(card, C.Border, 1)

            -- Header
            local hdr = F({ Size=UDim2.new(1,0,0,30), BackgroundColor3=C.Card }, card)
            corner(hdr, 8)
            F({ Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,1,-8), BackgroundColor3=C.Card }, hdr)
            F({ Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.Border }, hdr)
            I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,10,0.5,-6), Image=sIcon, ImageColor3=C.Accent }, hdr)
            L({ Size=UDim2.new(1,-30,1,0), Position=UDim2.new(0,28,0,0), Text=sName, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Accent, TextXAlignment=Enum.TextXAlignment.Left }, hdr)

            -- Items frame
            local items = F({ Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1 }, card)
            pad(items, 8, 10, 10, 10)
            listLayout(items, 8)

            local sec = { _items=items }

            -- ── AddToggle ─────────────────────────────────
            function sec:AddToggle(tc)
                tc = tc or {}
                local tName = tc.Name or "Toggle"
                local tIcon = tc.Icon or Icon.Check
                local tDef  = tc.Default ~= nil and tc.Default or false
                local tCb   = tc.Callback or function() end
                local on    = tDef

                local row = F({ Size=UDim2.new(1,0,0,28), BackgroundTransparency=1 }, items)
                I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,0,0.5,-6), Image=tIcon, ImageColor3=C.Accent }, row)
                L({ Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,18,0,0), Text=tName, Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=C.Text, TextXAlignment=Enum.TextXAlignment.Left }, row)

                -- Pill (46×24)
                local pill = F({ Size=UDim2.new(0,46,0,24), Position=UDim2.new(1,-46,0.5,-12), BackgroundColor3=on and C.Accent or C.Track }, row)
                corner(pill, 12)
                stroke(pill, on and C.AccentLo or C.Border, 1)

                local pillLbl = L({ Size=UDim2.new(1,0,1,0), Text=on and "ON" or "OFF", Font=Enum.Font.GothamBold, TextSize=7, TextColor3=C.Text, TextXAlignment=on and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right }, pill)
                pad(pillLbl, 0, 4, 0, 4)

                local knob = F({ Size=UDim2.new(0,18,0,18), Position=UDim2.new(on and 1 or 0, on and -21 or 2, 0.5,-9), BackgroundColor3=Color3.new(1,1,1) }, pill)
                corner(knob, 9)

                local hit = B({ Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="" }, row)
                hit.Activated:Connect(function()
                    on = not on
                    tw(pill,{BackgroundColor3=on and C.Accent or C.Track})
                    stroke(pill, on and C.AccentLo or C.Border, 1)
                    tw(knob,{Position=UDim2.new(on and 1 or 0, on and -21 or 2, 0.5,-9)})
                    pillLbl.Text = on and "ON" or "OFF"
                    pillLbl.TextXAlignment = on and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                    tCb(on)
                end)

                local obj = {}
                function obj:Set(v)
                    on=v; tw(pill,{BackgroundColor3=v and C.Accent or C.Track})
                    tw(knob,{Position=UDim2.new(v and 1 or 0,v and -21 or 2,0.5,-9)})
                    pillLbl.Text=v and "ON" or "OFF"
                    pillLbl.TextXAlignment=v and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                end
                function obj:Get() return on end
                return obj
            end

            -- ── AddSlider ─────────────────────────────────
            function sec:AddSlider(sc)
                sc = sc or {}
                local sName = sc.Name    or "Slider"
                local sMin  = sc.Min     or 0
                local sMax  = sc.Max     or 100
                local sVal  = math.clamp(sc.Default or sMin, sMin, sMax)
                local sSuf  = sc.Suffix  or ""
                local sCb   = sc.Callback or function() end
                local val   = sVal

                local wrap = F({ Size=UDim2.new(1,0,0,50), BackgroundTransparency=1 }, items)

                -- Top row: name + value box
                local topRow = F({ Size=UDim2.new(1,0,0,20), BackgroundTransparency=1 }, wrap)
                L({ Size=UDim2.new(1,-56,1,0), Text=sName, Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=C.Text, TextXAlignment=Enum.TextXAlignment.Left }, topRow)
                local vbox = F({ Size=UDim2.new(0,50,0,18), Position=UDim2.new(1,-50,0.5,-9), BackgroundColor3=C.Card }, topRow)
                corner(vbox,4); stroke(vbox,C.Border,1)
                local vLbl = L({ Size=UDim2.new(1,0,1,0), Text=tostring(val)..sSuf, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Text }, vbox)

                -- Track
                local track = F({ Size=UDim2.new(1,0,0,5), Position=UDim2.new(0,0,0,26), BackgroundColor3=C.Track }, wrap)
                corner(track,3)
                local fill = F({ Size=UDim2.new((val-sMin)/(sMax-sMin),0,1,0), BackgroundColor3=C.Accent }, track)
                corner(fill,3)
                local knob = F({ Size=UDim2.new(0,13,0,13), Position=UDim2.new((val-sMin)/(sMax-sMin),-6,0.5,-6), BackgroundColor3=Color3.new(0.91,0.91,0.91) }, track)
                corner(knob,7); stroke(knob,C.Accent,2)

                L({ Size=UDim2.new(0,28,0,12), Position=UDim2.new(0,0,0,36), Text=tostring(sMin), Font=Enum.Font.Gotham, TextSize=9, TextColor3=C.TextMute, TextXAlignment=Enum.TextXAlignment.Left }, wrap)
                L({ Size=UDim2.new(0,28,0,12), Position=UDim2.new(1,-28,0,36), Text=tostring(sMax), Font=Enum.Font.Gotham, TextSize=9, TextColor3=C.TextMute, TextXAlignment=Enum.TextXAlignment.Right }, wrap)

                local dragging = false
                local function upd(pos)
                    local rel = math.clamp((pos.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                    val = math.floor(sMin + rel*(sMax-sMin)+.5)
                    tw(fill,{Size=UDim2.new(rel,0,1,0)},.04)
                    tw(knob,{Position=UDim2.new(rel,-6,0.5,-6)},.04)
                    vLbl.Text = tostring(val)..sSuf
                    sCb(val)
                end
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; upd(i.Position) end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
                end)

                local obj = {}
                function obj:Set(v)
                    val=math.clamp(v,sMin,sMax); local rel=(val-sMin)/(sMax-sMin)
                    tw(fill,{Size=UDim2.new(rel,0,1,0)}); tw(knob,{Position=UDim2.new(rel,-6,0.5,-6)})
                    vLbl.Text=tostring(val)..sSuf
                end
                function obj:Get() return val end
                return obj
            end

            -- ── AddButton ─────────────────────────────────
            function sec:AddButton(bc)
                bc = bc or {}
                local bName = bc.Name or "Button"
                local bIcon = bc.Icon or Icon.Play
                local bCb   = bc.Callback or function() end

                local btn2 = B({ Size=UDim2.new(1,0,0,30), BackgroundColor3=C.Card, Text="" }, items)
                corner(btn2,6); stroke(btn2,C.Border,1)
                I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,10,0.5,-6), Image=bIcon, ImageColor3=C.Accent }, btn2)
                L({ Size=UDim2.new(1,-32,1,0), Position=UDim2.new(0,28,0,0), Text=bName, Font=Enum.Font.GothamSemibold, TextSize=11, TextColor3=C.Text, TextXAlignment=Enum.TextXAlignment.Left }, btn2)
                btn2.MouseEnter:Connect(function() tw(btn2,{BackgroundColor3=C.Panel}) end)
                btn2.MouseLeave:Connect(function() tw(btn2,{BackgroundColor3=C.Card}) end)
                btn2.Activated:Connect(function()
                    tw(btn2,{BackgroundColor3=C.AccentLo},.08)
                    task.delay(.1,function() tw(btn2,{BackgroundColor3=C.Card}) end)
                    bCb()
                end)
            end

            -- ── AddLabel ──────────────────────────────────
            function sec:AddLabel(lc)
                lc = lc or {}
                local lbl2 = L({ Size=UDim2.new(1,0,0,16), Text=lc.Text or "", Font=Enum.Font.Gotham, TextSize=11, TextColor3=lc.Color or C.TextDim, TextXAlignment=Enum.TextXAlignment.Left }, items)
                local obj={}; function obj:Set(t) lbl2.Text=t end; return obj
            end

            -- ── AddTextBox ────────────────────────────────
            function sec:AddTextBox(tbc)
                tbc = tbc or {}
                local tbName = tbc.Name or "Input"
                local tbPh   = tbc.Placeholder or "Type here..."
                local tbCb   = tbc.Callback or function() end

                local wrap2 = F({ Size=UDim2.new(1,0,0,46), BackgroundTransparency=1 }, items)
                L({ Size=UDim2.new(1,0,0,14), Text=tbName, Font=Enum.Font.GothamMedium, TextSize=10, TextColor3=C.TextDim, TextXAlignment=Enum.TextXAlignment.Left }, wrap2)
                local inp = Instance.new("TextBox")
                inp.Size=UDim2.new(1,0,0,26); inp.Position=UDim2.new(0,0,0,16)
                inp.BackgroundColor3=C.Card; inp.Text=""; inp.PlaceholderText=tbPh
                inp.PlaceholderColor3=C.TextMute; inp.Font=Enum.Font.Gotham
                inp.TextSize=11; inp.TextColor3=C.Text
                inp.TextXAlignment=Enum.TextXAlignment.Left
                inp.ClearTextOnFocus=false; inp.BorderSizePixel=0
                inp.Parent=wrap2
                corner(inp,6); stroke(inp,C.Border,1); pad(inp,0,8,0,8)
                inp.Focused:Connect(function() stroke(inp,C.Accent,1) end)
                inp.FocusLost:Connect(function(enter) stroke(inp,C.Border,1); if enter then tbCb(inp.Text) end end)
                local obj={}; function obj:Get() return inp.Text end; function obj:Set(t) inp.Text=t end; return obj
            end

            return sec
        end

        -- ── AddSection (standard tab) ──────────────────────
        function tab:AddSection(sc)
            sc = sc or {}
            return buildSection(sc.Name or "SECTION", sc.Icon or Icon.Gear, page)
        end

        -- ╔══════════════════════════════════════════╗
        -- ║  AddSplitLayout                          ║
        -- ║  Creates a 2-column layout (like HOME):  ║
        -- ║  Left = sections, Right = executor       ║
        -- ╚══════════════════════════════════════════╝
        function tab:AddSplitLayout(slc)
            slc = slc or {}
            local leftW  = slc.LeftWidth  or 0.55  -- fraction of content width

            -- hide normal page
            page.Visible = false; tab._page = nil

            local split = F({ Name="Split", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false }, content)
            tab._split = split

            -- Left scroll column
            local leftScroll = Instance.new("ScrollingFrame")
            leftScroll.Size                = UDim2.new(leftW,-6,1,-4)
            leftScroll.Position            = UDim2.new(0,0,0,2)
            leftScroll.BackgroundTransparency = 1
            leftScroll.BorderSizePixel     = 0
            leftScroll.ScrollBarThickness  = 2
            leftScroll.ScrollBarImageColor3= C.Accent
            leftScroll.CanvasSize          = UDim2.new(0,0,0,0)
            leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            leftScroll.Parent              = split
            pad(leftScroll,10,8,10,10)
            listLayout(leftScroll,8)

            -- Right panel (executor)
            local rightPanel = F({
                Name="RightPanel",
                Size=UDim2.new(1-leftW,-6,1,-4),
                Position=UDim2.new(leftW,6,0,2),
                BackgroundColor3=C.Panel,
            }, split)
            corner(rightPanel,8); stroke(rightPanel,C.Border,1)

            -- First activate
            if self._win._active == tab then
                split.Visible = true
            end

            -- Helper: add section in left column
            function tab:AddLeftSection(sc2)
                sc2 = sc2 or {}
                return buildSection(sc2.Name or "SECTION", sc2.Icon or Icon.Gear, leftScroll)
            end

            -- Helper: set up executor in right column
            function tab:SetupExecutor(ec)
                ec = ec or {}
                local eTitle = ec.Title    or "EXECUTOR"
                local eDef   = ec.Default  or ""
                local eCb    = ec.Callback or function() end
                local eClr   = ec.OnClear  or function() end

                -- Header
                local hdr = F({ Size=UDim2.new(1,0,0,30), BackgroundColor3=C.Card }, rightPanel)
                corner(hdr,8)
                F({ Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,1,-8), BackgroundColor3=C.Card }, hdr)
                F({ Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.Border }, hdr)
                I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,10,0.5,-6), Image=Icon.Terminal, ImageColor3=C.Accent }, hdr)
                L({ Size=UDim2.new(0,100,1,0), Position=UDim2.new(0,28,0,0), Text=eTitle, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Accent, TextXAlignment=Enum.TextXAlignment.Left }, hdr)
                -- READY badge
                local rdot = F({ Size=UDim2.new(0,5,0,5), Position=UDim2.new(1,-70,0.5,-2), BackgroundColor3=C.Green }, hdr)
                corner(rdot,99)
                L({ Size=UDim2.new(0,55,1,0), Position=UDim2.new(1,-62,0,0), Text="READY", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Green, TextXAlignment=Enum.TextXAlignment.Left }, hdr)

                -- Code editor bg
                local edBg = F({ Size=UDim2.new(1,0,1,-80), Position=UDim2.new(0,0,0,32), BackgroundColor3=C.CodeBg }, rightPanel)
                corner(edBg,0); stroke(edBg,C.Border,1)

                -- Line numbers scroll
                local lineNums = Instance.new("ScrollingFrame")
                lineNums.Size=UDim2.new(0,26,1,-4); lineNums.Position=UDim2.new(0,2,0,2)
                lineNums.BackgroundTransparency=1; lineNums.BorderSizePixel=0
                lineNums.ScrollBarThickness=0; lineNums.CanvasSize=UDim2.new(0,0,0,0)
                lineNums.AutomaticCanvasSize=Enum.AutomaticSize.Y
                lineNums.Parent=edBg
                listLayout(lineNums,0)

                -- Code textbox
                local code = Instance.new("TextBox")
                code.Size=UDim2.new(1,-30,1,-4); code.Position=UDim2.new(0,28,0,2)
                code.BackgroundTransparency=1; code.BorderSizePixel=0
                code.Text=eDef; code.PlaceholderText="-- Write your Lua here..."
                code.PlaceholderColor3=C.TextMute; code.Font=Enum.Font.Code
                code.TextSize=11; code.TextColor3=C.Text
                code.TextXAlignment=Enum.TextXAlignment.Left
                code.TextYAlignment=Enum.TextYAlignment.Top
                code.MultiLine=true; code.ClearTextOnFocus=false
                code.Parent=edBg

                local function refreshNums()
                    lineNums:ClearAllChildren()
                    local n=1; for _ in code.Text:gmatch("\n") do n=n+1 end
                    for i=1,math.max(n,14) do
                        L({ Size=UDim2.new(1,0,0,16), Text=tostring(i), Font=Enum.Font.Code, TextSize=10, TextColor3=C.LineNum }, lineNums)
                    end
                end
                refreshNums()
                code:GetPropertyChangedSignal("Text"):Connect(refreshNums)

                -- Buttons row
                local bRow = F({ Size=UDim2.new(1,0,0,38), Position=UDim2.new(0,0,1,-42), BackgroundTransparency=1 }, rightPanel)
                pad(bRow,6,8,6,8)
                listLayout(bRow,6,Enum.FillDirection.Horizontal)

                local execBtn = B({ Size=UDim2.new(0.58,-3,1,0), BackgroundColor3=C.Accent, Text="" }, bRow)
                corner(execBtn,7)
                I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0.5,-38,0.5,-6), Image=Icon.Play, ImageColor3=C.Text }, execBtn)
                L({ Size=UDim2.new(0,70,1,0), Position=UDim2.new(0.5,-16,0,0), Text="EXECUTE", Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.Text }, execBtn)

                local clrBtn = B({ Size=UDim2.new(0.42,-3,1,0), BackgroundColor3=C.Card, Text="" }, bRow)
                corner(clrBtn,7); stroke(clrBtn,C.Border,1)
                I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0.5,-32,0.5,-6), Image=Icon.Trash, ImageColor3=C.TextDim }, clrBtn)
                L({ Size=UDim2.new(0,56,1,0), Position=UDim2.new(0.5,-14,0,0), Text="CLEAR", Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.TextDim }, clrBtn)

                execBtn.MouseEnter:Connect(function() tw(execBtn,{BackgroundColor3=C.AccentHi}) end)
                execBtn.MouseLeave:Connect(function() tw(execBtn,{BackgroundColor3=C.Accent}) end)
                execBtn.Activated:Connect(function()
                    tw(execBtn,{BackgroundColor3=C.AccentLo},.08)
                    task.delay(.1,function() tw(execBtn,{BackgroundColor3=C.Accent}) end)
                    eCb(code.Text)
                end)
                clrBtn.MouseEnter:Connect(function() tw(clrBtn,{BackgroundColor3=C.Panel}) end)
                clrBtn.MouseLeave:Connect(function() tw(clrBtn,{BackgroundColor3=C.Card}) end)
                clrBtn.Activated:Connect(function() code.Text=""; refreshNums(); eClr() end)

                return {
                    GetCode=function() return code.Text end,
                    SetCode=function(_,c) code.Text=c or ""; refreshNums() end,
                }
            end

            return split
        end

        -- ── AddExecutorPanel (full-tab executor) ───────────
        function tab:AddExecutorPanel(ec)
            ec = ec or {}
            page.Visible=false; tab._page=nil

            local ep = F({ Name="ExecPanel", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false }, content)
            tab._exec = ep

            local hdr = F({ Size=UDim2.new(1,0,0,30), BackgroundColor3=C.Card }, ep)
            corner(hdr,8)
            F({ Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,1,-8), BackgroundColor3=C.Card }, hdr)
            F({ Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.Border }, hdr)
            I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,10,0.5,-6), Image=Icon.Terminal, ImageColor3=C.Accent }, hdr)
            L({ Size=UDim2.new(0,120,1,0), Position=UDim2.new(0,28,0,0), Text=ec.Title or "EXECUTOR", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Accent, TextXAlignment=Enum.TextXAlignment.Left }, hdr)
            local rd = F({ Size=UDim2.new(0,5,0,5), Position=UDim2.new(1,-72,0.5,-2), BackgroundColor3=C.Green }, hdr)
            corner(rd,99)
            L({ Size=UDim2.new(0,58,1,0), Position=UDim2.new(1,-64,0,0), Text="READY", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.Green, TextXAlignment=Enum.TextXAlignment.Left }, hdr)

            local edBg = F({ Size=UDim2.new(1,0,1,-82), Position=UDim2.new(0,0,0,34), BackgroundColor3=C.CodeBg }, ep)
            stroke(edBg,C.Border,1)

            local lineNums = Instance.new("ScrollingFrame")
            lineNums.Size=UDim2.new(0,26,1,-4); lineNums.Position=UDim2.new(0,2,0,2)
            lineNums.BackgroundTransparency=1; lineNums.BorderSizePixel=0
            lineNums.ScrollBarThickness=0; lineNums.CanvasSize=UDim2.new(0,0,0,0)
            lineNums.AutomaticCanvasSize=Enum.AutomaticSize.Y
            lineNums.Parent=edBg; listLayout(lineNums,0)

            local code = Instance.new("TextBox")
            code.Size=UDim2.new(1,-30,1,-4); code.Position=UDim2.new(0,28,0,2)
            code.BackgroundTransparency=1; code.BorderSizePixel=0
            code.Text=ec.Default or ""; code.PlaceholderText="-- Write your Lua here..."
            code.PlaceholderColor3=C.TextMute; code.Font=Enum.Font.Code
            code.TextSize=11; code.TextColor3=C.Text
            code.TextXAlignment=Enum.TextXAlignment.Left; code.TextYAlignment=Enum.TextYAlignment.Top
            code.MultiLine=true; code.ClearTextOnFocus=false; code.Parent=edBg

            local function refreshNums()
                lineNums:ClearAllChildren(); local n=1
                for _ in code.Text:gmatch("\n") do n=n+1 end
                for i=1,math.max(n,14) do L({ Size=UDim2.new(1,0,0,16), Text=tostring(i), Font=Enum.Font.Code, TextSize=10, TextColor3=C.LineNum }, lineNums) end
            end
            refreshNums(); code:GetPropertyChangedSignal("Text"):Connect(refreshNums)

            local bRow = F({ Size=UDim2.new(1,0,0,38), Position=UDim2.new(0,0,1,-42), BackgroundTransparency=1 }, ep)
            pad(bRow,6,8,6,8); listLayout(bRow,6,Enum.FillDirection.Horizontal)

            local execBtn = B({ Size=UDim2.new(0.58,-3,1,0), BackgroundColor3=C.Accent, Text="" }, bRow)
            corner(execBtn,7)
            I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0.5,-38,0.5,-6), Image=Icon.Play, ImageColor3=C.Text }, execBtn)
            L({ Size=UDim2.new(0,70,1,0), Position=UDim2.new(0.5,-16,0,0), Text="EXECUTE", Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.Text }, execBtn)

            local clrBtn = B({ Size=UDim2.new(0.42,-3,1,0), BackgroundColor3=C.Card, Text="" }, bRow)
            corner(clrBtn,7); stroke(clrBtn,C.Border,1)
            I({ Size=UDim2.new(0,12,0,12), Position=UDim2.new(0.5,-32,0.5,-6), Image=Icon.Trash, ImageColor3=C.TextDim }, clrBtn)
            L({ Size=UDim2.new(0,56,1,0), Position=UDim2.new(0.5,-14,0,0), Text="CLEAR", Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.TextDim }, clrBtn)

            execBtn.MouseEnter:Connect(function() tw(execBtn,{BackgroundColor3=C.AccentHi}) end)
            execBtn.MouseLeave:Connect(function() tw(execBtn,{BackgroundColor3=C.Accent}) end)
            execBtn.Activated:Connect(function()
                tw(execBtn,{BackgroundColor3=C.AccentLo},.08)
                task.delay(.1,function() tw(execBtn,{BackgroundColor3=C.Accent}) end)
                ;(ec.Callback or function() end)(code.Text)
            end)
            clrBtn.MouseEnter:Connect(function() tw(clrBtn,{BackgroundColor3=C.Panel}) end)
            clrBtn.MouseLeave:Connect(function() tw(clrBtn,{BackgroundColor3=C.Card}) end)
            clrBtn.Activated:Connect(function() code.Text=""; refreshNums(); (ec.OnClear or function()end)() end)

            if self._win._active == tab then ep.Visible=true end

            return {
                GetCode=function() return code.Text end,
                SetCode=function(_,c) code.Text=c or ""; refreshNums() end,
            }
        end

        return tab
    end

    function Win:Destroy()
        tw(main,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},.2,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.delay(.25,function() gui:Destroy() end)
    end

    return Win
end

return ZeoxLib
