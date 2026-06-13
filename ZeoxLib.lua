--[[
    ZEOX UI Library v2.0
    Fixed: proper sizing, mobile touch support, clean tab system
]]

local ZeoxLib = {}

-- Services
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- THEME
-- ============================================================
local T = {
    BG       = Color3.fromRGB(13, 13, 18),
    Sidebar  = Color3.fromRGB(9, 9, 13),
    Panel    = Color3.fromRGB(20, 20, 28),
    Card     = Color3.fromRGB(26, 26, 36),
    Border   = Color3.fromRGB(40, 40, 55),
    Accent   = Color3.fromRGB(210, 25, 25),
    AccentHi = Color3.fromRGB(255, 55, 55),
    AccentLo = Color3.fromRGB(140, 15, 15),
    Text     = Color3.fromRGB(235, 235, 235),
    TextDim  = Color3.fromRGB(150, 150, 170),
    TextMute = Color3.fromRGB(90, 90, 110),
    Green    = Color3.fromRGB(45, 200, 90),
    Red      = Color3.fromRGB(200, 45, 45),
    OnColor  = Color3.fromRGB(210, 25, 25),
    OffColor = Color3.fromRGB(38, 38, 52),
    Track    = Color3.fromRGB(35, 35, 50),
    CodeBg   = Color3.fromRGB(10, 10, 16),
}

-- ============================================================
-- ICON ASSET IDs
-- ============================================================
local Icons = {
    Home     = "rbxassetid://7733960981",
    Code     = "rbxassetid://7734053495",
    File     = "rbxassetid://7734045250",
    Gear     = "rbxassetid://7734036682",
    Play     = "rbxassetid://7072719712",
    Trash    = "rbxassetid://7072725052",
    Refresh  = "rbxassetid://7072720526",
    Bolt     = "rbxassetid://7072722960",
    Arrow    = "rbxassetid://7072716400",
    Runner   = "rbxassetid://7072723416",
    User     = "rbxassetid://7072724501",
    Check    = "rbxassetid://7072716987",
    ZLogo    = "rbxassetid://17929804958",
}

-- ============================================================
-- HELPERS
-- ============================================================
local function tw(obj, props, t, es, ed)
    TweenService:Create(obj, TweenInfo.new(t or .18, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out), props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = p; return c
end

local function stroke(p, col, th)
    local s = Instance.new("UIStroke"); s.Color = col or T.Border; s.Thickness = th or 1; s.Parent = p; return s
end

local function pad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.Parent = p; return u
end

local function listLayout(p, spacing, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end

local function newFrame(props, parent)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k, v in pairs(props) do f[k] = v end
    if parent then f.Parent = parent end
    return f
end

local function newLabel(props, parent)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    for k, v in pairs(props) do l[k] = v end
    if parent then l.Parent = parent end
    return l
end

local function newImage(props, parent)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.BorderSizePixel = 0
    for k, v in pairs(props) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function newBtn(props, parent)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    for k, v in pairs(props) do b[k] = v end
    if parent then b.Parent = parent end
    return b
end

-- Drag support for both mouse and touch
local function makeDraggable(root, handle)
    local dragging = false
    local dragStart, startPos

    local function beginDrag(pos)
        dragging = true
        dragStart = pos
        startPos = root.Position
    end
    local function updateDrag(pos)
        if not dragging then return end
        local delta = pos - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    local function endDrag()
        dragging = false
    end

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            beginDrag(i.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseMovement
        or  i.UserInputType == Enum.UserInputType.Touch) and dragging then
            updateDrag(i.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function ZeoxLib:CreateWindow(cfg)
    cfg = cfg or {}
    local title   = cfg.Title   or "ZEOX CLIENT"
    local version = cfg.Version or "v1.0.1"

    -- ── GUI ROOT ─────────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZeoxUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ── MAIN FRAME ───────────────────────────────────────────
    -- Fixed size, centered, NOT filling the screen
    local WIN_W, WIN_H = 700, 460
    local main = newFrame({
        Name            = "Main",
        Size            = UDim2.new(0, WIN_W, 0, WIN_H),
        Position        = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = T.BG,
    }, gui)
    corner(main, 10)
    stroke(main, T.Accent, 1)

    -- ── TITLE BAR (height=40) ────────────────────────────────
    local titleBar = newFrame({
        Name            = "TitleBar",
        Size            = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.Sidebar,
    }, main)
    corner(titleBar, 10)
    -- flatten bottom of titleBar
    newFrame({ Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = T.Sidebar }, titleBar)
    -- accent bottom line
    newFrame({ Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), BackgroundColor3 = T.Accent }, titleBar)

    -- Z logo icon
    newImage({ Size = UDim2.new(0,26,0,26), Position = UDim2.new(0,10,0.5,-13), Image = Icons.ZLogo, ImageColor3 = T.Accent }, titleBar)

    -- Title
    newLabel({
        Size = UDim2.new(0,160,1,0), Position = UDim2.new(0,42,0,0),
        Text = title, Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)

    -- Version badge
    local verBadge = newFrame({ Size = UDim2.new(0,64,0,18), Position = UDim2.new(0,196,0.5,-9), BackgroundColor3 = T.Card }, titleBar)
    corner(verBadge, 4)
    newLabel({ Size = UDim2.new(1,0,1,0), Text = version, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = T.TextDim }, verBadge)

    -- Window buttons
    local function winBtn(sym, xOff, accentCol, cb)
        local b = newBtn({
            Size = UDim2.new(0,22,0,22),
            Position = UDim2.new(1, xOff, 0.5, -11),
            BackgroundColor3 = T.Card,
            Text = sym, Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = accentCol or T.TextDim,
        }, titleBar)
        corner(b, 4)
        b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = accentCol or T.Border}) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = T.Card}) end)
        b.Activated:Connect(cb)
        return b
    end
    winBtn("✕", -8,  T.Accent,   function() tw(main, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}, .2, Enum.EasingStyle.Back, Enum.EasingDirection.In); task.delay(.25, function() gui:Destroy() end) end)
    winBtn("□", -36, T.TextDim,  function() end)
    winBtn("–", -64, T.TextDim,  function()
        local body = main:FindFirstChild("Body")
        if body then body.Visible = not body.Visible end
    end)

    makeDraggable(main, titleBar)

    -- ── BODY (below title bar) ────────────────────────────────
    local body = newFrame({
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
    }, main)

    -- ── SIDEBAR (width=150) ──────────────────────────────────
    local sidebar = newFrame({
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = T.Sidebar,
    }, body)
    -- right border
    newFrame({ Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BackgroundColor3=T.Border }, sidebar)

    -- Big Z icon in sidebar
    newImage({
        Size = UDim2.new(0,80,0,80),
        Position = UDim2.new(0.5,-40,0,10),
        Image = Icons.ZLogo, ImageColor3 = T.Accent,
    }, sidebar)

    -- Nav buttons container
    local navList = newFrame({
        Size = UDim2.new(1,0,1,-105),
        Position = UDim2.new(0,0,0,105),
        BackgroundTransparency = 1,
    }, sidebar)
    listLayout(navList, 0)

    -- Status bar
    local statusBar = newFrame({
        Size = UDim2.new(1,0,0,26), Position = UDim2.new(0,0,1,-26),
        BackgroundColor3 = T.BG,
    }, body)
    -- "STATUS:" label
    newLabel({
        Size=UDim2.new(0,55,1,0), Position=UDim2.new(0,10,0,0),
        Text="STATUS:", Font=Enum.Font.GothamBold, TextSize=10,
        TextColor3=T.TextMute, TextXAlignment=Enum.TextXAlignment.Left,
    }, statusBar)
    -- Status text
    local statusTxt = newLabel({
        Size=UDim2.new(0,80,1,0), Position=UDim2.new(0,68,0,0),
        Text="ATTACHED", Font=Enum.Font.GothamMedium, TextSize=10,
        TextColor3=T.Green, TextXAlignment=Enum.TextXAlignment.Left,
    }, statusBar)
    -- dot
    local statusDot = newFrame({ Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,62,0.5,-3), BackgroundColor3=T.Green }, statusBar)
    corner(statusDot, 99)
    -- welcome
    local playerName = LocalPlayer and LocalPlayer.Name or "USER"
    newLabel({
        Size=UDim2.new(0,180,1,0), Position=UDim2.new(1,-188,0,0),
        Text="WELCOME, ", Font=Enum.Font.GothamMedium, TextSize=10,
        TextColor3=T.TextMute, TextXAlignment=Enum.TextXAlignment.Right,
    }, statusBar)
    newLabel({
        Size=UDim2.new(0, #playerName*8+4, 1, 0), Position=UDim2.new(1, -8-#playerName*8, 0,0),
        Text=playerName, Font=Enum.Font.GothamBold, TextSize=10,
        TextColor3=T.Accent, TextXAlignment=Enum.TextXAlignment.Right,
    }, statusBar)

    -- ── CONTENT AREA ─────────────────────────────────────────
    local content = newFrame({
        Name = "Content",
        Size = UDim2.new(1, -150, 1, -26),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
    }, body)

    -- ── WINDOW OBJECT ────────────────────────────────────────
    local Win = {
        _gui=gui, _main=main, _navList=navList,
        _content=content, _tabs={}, _active=nil,
        statusTxt=statusTxt, statusDot=statusDot,
    }

    -- Entrance animation
    main.Size     = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0.5,0,0.5,0)
    tw(main, {Size=UDim2.new(0,WIN_W,0,WIN_H), Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)},
        .3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ── SetStatus ────────────────────────────────────────────
    function Win:SetStatus(text, ok2)
        statusTxt.Text = text or "ATTACHED"
        statusTxt.TextColor3 = ok2 ~= false and T.Green or T.Red
        statusDot.BackgroundColor3 = ok2 ~= false and T.Green or T.Red
    end

    -- ── Activate tab ─────────────────────────────────────────
    function Win:_activate(tab)
        if self._active then
            local p = self._active
            if p._page then p._page.Visible = false end
            if p._exec then p._exec.Visible = false end
            tw(p._btn, {BackgroundColor3 = T.Sidebar})
            tw(p._icon,{ImageColor3 = T.TextDim})
            tw(p._lbl, {TextColor3  = T.TextDim})
            p._bar.Visible = false
        end
        self._active = tab
        if tab._page then tab._page.Visible = true end
        if tab._exec then tab._exec.Visible = true end
        tw(tab._btn, {BackgroundColor3 = T.Card})
        tw(tab._icon,{ImageColor3 = T.Accent})
        tw(tab._lbl, {TextColor3  = T.Text})
        tab._bar.Visible = true
    end

    -- ── AddTab ───────────────────────────────────────────────
    function Win:AddTab(cfg2)
        cfg2 = cfg2 or {}
        local name = cfg2.Name or "TAB"
        local icon = cfg2.Icon or Icons.Home

        -- Nav button (fixed height 40)
        local btn = newBtn({
            Name=name.."_Btn", Size=UDim2.new(1,0,0,40),
            BackgroundColor3=T.Sidebar, Text="",
        }, navList)

        -- Active indicator bar
        local bar = newFrame({
            Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,0,0.2,0),
            BackgroundColor3=T.Accent, Visible=false,
        }, btn)
        corner(bar, 2)

        -- Icon
        local ico = newImage({
            Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,18,0.5,-8),
            Image=icon, ImageColor3=T.TextDim,
        }, btn)

        -- Label
        local lbl = newLabel({
            Size=UDim2.new(1,-44,1,0), Position=UDim2.new(0,40,0,0),
            Text=name, Font=Enum.Font.GothamSemibold, TextSize=11,
            TextColor3=T.TextDim, TextXAlignment=Enum.TextXAlignment.Left,
        }, btn)

        -- Tab page (scrolling)
        local page = Instance.new("ScrollingFrame")
        page.Name = name.."_Page"
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = T.Accent
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = content
        pad(page, 10, 10, 10, 10)
        listLayout(page, 8)

        local tab = {
            _win=self, _page=page, _btn=btn, _icon=ico, _lbl=lbl, _bar=bar,
            _exec=nil,
        }
        table.insert(self._tabs, tab)

        -- Auto-activate first tab
        if #self._tabs == 1 then self:_activate(tab) end

        btn.MouseEnter:Connect(function()
            if self._active ~= tab then tw(btn,{BackgroundColor3=T.Panel}) end
        end)
        btn.MouseLeave:Connect(function()
            if self._active ~= tab then tw(btn,{BackgroundColor3=T.Sidebar}) end
        end)
        btn.Activated:Connect(function() self:_activate(tab) end)

        -- ── AddSection ───────────────────────────────────────
        function tab:AddSection(sc)
            sc = sc or {}
            local sname = sc.Name or "SECTION"
            local sicon = sc.Icon or Icons.Gear

            -- Section container (auto-sizes to content)
            local card = newFrame({
                Name=sname.."_Card",
                Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=T.Panel,
            }, page)
            corner(card, 7)
            stroke(card, T.Border, 1)

            -- Header (fixed 32px)
            local hdr = newFrame({
                Size=UDim2.new(1,0,0,32),
                BackgroundColor3=T.Card,
            }, card)
            corner(hdr, 7)
            newFrame({Size=UDim2.new(1,0,0,7),Position=UDim2.new(0,0,1,-7),BackgroundColor3=T.Card},hdr)
            newFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border},hdr)
            newImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,10,0.5,-7),Image=sicon,ImageColor3=T.Accent},hdr)
            newLabel({
                Size=UDim2.new(1,-32,1,0),Position=UDim2.new(0,30,0,0),
                Text=sname,Font=Enum.Font.GothamBold,TextSize=10,
                TextColor3=T.Accent,TextXAlignment=Enum.TextXAlignment.Left,
            },hdr)

            -- Items list
            local items = newFrame({
                Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1,
            }, card)
            pad(items, 6, 10, 8, 10)
            listLayout(items, 6)

            local sec = {_card=card, _items=items}

            -- ── AddToggle ─────────────────────────────────────
            function sec:AddToggle(tc)
                tc = tc or {}
                local tname = tc.Name or "Toggle"
                local tdef  = tc.Default ~= nil and tc.Default or false
                local ticon = tc.Icon or Icons.Check
                local tcb   = tc.Callback or function() end
                local on = tdef

                local row = newFrame({Size=UDim2.new(1,0,0,34),BackgroundTransparency=1},items)
                newImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,0,0.5,-7),Image=ticon,ImageColor3=T.Accent},row)
                newLabel({
                    Size=UDim2.new(1,-62,1,0),Position=UDim2.new(0,20,0,0),
                    Text=tname,Font=Enum.Font.GothamMedium,TextSize=12,
                    TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,
                },row)

                -- Pill (44×22)
                local pill = newFrame({
                    Size=UDim2.new(0,44,0,22),
                    Position=UDim2.new(1,-44,0.5,-11),
                    BackgroundColor3=on and T.OnColor or T.OffColor,
                },row)
                corner(pill, 11)
                local pillLbl = newLabel({
                    Size=UDim2.new(1,0,1,0),
                    Text=on and "ON" or "OFF",
                    Font=Enum.Font.GothamBold,TextSize=8,TextColor3=T.Text,
                    TextXAlignment=on and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
                },pill)
                pad(pillLbl,0,4,0,4)
                local knob = newFrame({
                    Size=UDim2.new(0,16,0,16),
                    Position=UDim2.new(on and 1 or 0, on and -19 or 3, 0.5,-8),
                    BackgroundColor3=T.Text,
                },pill)
                corner(knob, 8)

                local hitbox = newBtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""},row)
                hitbox.Activated:Connect(function()
                    on = not on
                    tw(pill,{BackgroundColor3=on and T.OnColor or T.OffColor})
                    tw(knob,{Position=UDim2.new(on and 1 or 0, on and -19 or 3, 0.5,-8)})
                    pillLbl.Text = on and "ON" or "OFF"
                    pillLbl.TextXAlignment = on and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                    tcb(on)
                end)

                local obj = {}
                function obj:Set(v) on=v; tw(pill,{BackgroundColor3=v and T.OnColor or T.OffColor}); tw(knob,{Position=UDim2.new(v and 1 or 0,v and -19 or 3,0.5,-8)}); pillLbl.Text=v and "ON" or "OFF" end
                function obj:Get() return on end
                return obj
            end

            -- ── AddSlider ─────────────────────────────────────
            function sec:AddSlider(sc2)
                sc2 = sc2 or {}
                local sname2  = sc2.Name    or "Slider"
                local smin    = sc2.Min     or 0
                local smax    = sc2.Max     or 100
                local sdef    = math.clamp(sc2.Default or smin, smin, smax)
                local ssuf    = sc2.Suffix  or ""
                local scb     = sc2.Callback or function() end
                local val     = sdef

                local wrap = newFrame({Size=UDim2.new(1,0,0,50),BackgroundTransparency=1},items)

                -- Top row: name + value box
                local topRow = newFrame({Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},wrap)
                newLabel({Size=UDim2.new(1,-58,1,0),Text=sname2,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left},topRow)
                local valBox = newFrame({Size=UDim2.new(0,50,0,18),Position=UDim2.new(1,-50,0.5,-9),BackgroundColor3=T.Card},topRow)
                corner(valBox,4); stroke(valBox,T.Border,1)
                local valLbl = newLabel({Size=UDim2.new(1,0,1,0),Text=tostring(val)..ssuf,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=T.Text},valBox)

                -- Track
                local track = newFrame({
                    Size=UDim2.new(1,0,0,5),
                    Position=UDim2.new(0,0,0,28),
                    BackgroundColor3=T.Track,
                },wrap)
                corner(track,3)
                local fill = newFrame({
                    Size=UDim2.new((val-smin)/(smax-smin),0,1,0),
                    BackgroundColor3=T.Accent,
                },track)
                corner(fill,3)
                local knob = newFrame({
                    Size=UDim2.new(0,13,0,13),
                    Position=UDim2.new((val-smin)/(smax-smin),-6,0.5,-6),
                    BackgroundColor3=T.Text,
                },track)
                corner(knob,6); stroke(knob,T.Accent,2)

                -- min/max labels
                newLabel({Size=UDim2.new(0,30,0,12),Position=UDim2.new(0,0,0,38),Text=tostring(smin),Font=Enum.Font.Gotham,TextSize=9,TextColor3=T.TextMute,TextXAlignment=Enum.TextXAlignment.Left},wrap)
                newLabel({Size=UDim2.new(0,30,0,12),Position=UDim2.new(1,-30,0,38),Text=tostring(smax),Font=Enum.Font.Gotham,TextSize=9,TextColor3=T.TextMute,TextXAlignment=Enum.TextXAlignment.Right},wrap)

                local dragging = false
                local function updateVal(inputPos)
                    local tx  = track.AbsolutePosition.X
                    local tsz = track.AbsoluteSize.X
                    local rel = math.clamp((inputPos.X - tx)/tsz, 0, 1)
                    val = math.floor(smin + rel*(smax-smin) + .5)
                    tw(fill,  {Size=UDim2.new(rel,0,1,0)}, .04)
                    tw(knob,  {Position=UDim2.new(rel,-6,0.5,-6)}, .04)
                    valLbl.Text = tostring(val)..ssuf
                    scb(val)
                end

                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        dragging=true; updateVal(i.Position)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        updateVal(i.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=false
                    end
                end)

                local obj = {}
                function obj:Set(v)
                    val=math.clamp(v,smin,smax); local rel=(val-smin)/(smax-smin)
                    tw(fill,{Size=UDim2.new(rel,0,1,0)},.1); tw(knob,{Position=UDim2.new(rel,-6,0.5,-6)},.1)
                    valLbl.Text=tostring(val)..ssuf
                end
                function obj:Get() return val end
                return obj
            end

            -- ── AddButton ─────────────────────────────────────
            function sec:AddButton(bc)
                bc = bc or {}
                local bname = bc.Name or "Button"
                local bicon = bc.Icon or Icons.Play
                local bcb   = bc.Callback or function() end

                local btn2 = newBtn({
                    Size=UDim2.new(1,0,0,32),
                    BackgroundColor3=T.Card,Text="",
                },items)
                corner(btn2,6); stroke(btn2,T.Border,1)
                newImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,10,0.5,-7),Image=bicon,ImageColor3=T.Accent},btn2)
                newLabel({Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,30,0,0),Text=bname,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left},btn2)
                btn2.MouseEnter:Connect(function() tw(btn2,{BackgroundColor3=T.Panel}) end)
                btn2.MouseLeave:Connect(function() tw(btn2,{BackgroundColor3=T.Card}) end)
                btn2.Activated:Connect(function()
                    tw(btn2,{BackgroundColor3=T.AccentLo},.08)
                    task.delay(.12,function() tw(btn2,{BackgroundColor3=T.Card}) end)
                    bcb()
                end)
            end

            -- ── AddLabel ──────────────────────────────────────
            function sec:AddLabel(lc)
                lc = lc or {}
                local lbl2 = newLabel({
                    Size=UDim2.new(1,0,0,18),
                    Text=lc.Text or "",Font=Enum.Font.Gotham,TextSize=11,
                    TextColor3=lc.Color or T.TextDim,TextXAlignment=Enum.TextXAlignment.Left,
                },items)
                local obj={};function obj:Set(t) lbl2.Text=t end;return obj
            end

            -- ── AddTextBox ────────────────────────────────────
            function sec:AddTextBox(tbc)
                tbc = tbc or {}
                local tbname  = tbc.Name or "Input"
                local tbph    = tbc.Placeholder or "Type here..."
                local tbcb    = tbc.Callback or function() end

                local wrap2 = newFrame({Size=UDim2.new(1,0,0,50),BackgroundTransparency=1},items)
                newLabel({Size=UDim2.new(1,0,0,16),Text=tbname,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=T.TextDim,TextXAlignment=Enum.TextXAlignment.Left},wrap2)
                local inp = Instance.new("TextBox")
                inp.Size=UDim2.new(1,0,0,28); inp.Position=UDim2.new(0,0,0,18)
                inp.BackgroundColor3=T.Card; inp.Text=""
                inp.PlaceholderText=tbph; inp.PlaceholderColor3=T.TextMute
                inp.Font=Enum.Font.Gotham; inp.TextSize=12
                inp.TextColor3=T.Text; inp.TextXAlignment=Enum.TextXAlignment.Left
                inp.ClearTextOnFocus=false; inp.BorderSizePixel=0
                inp.Parent=wrap2
                corner(inp,5); stroke(inp,T.Border,1); pad(inp,0,8,0,8)
                inp.Focused:Connect(function() stroke(inp,T.Accent,1) end)
                inp.FocusLost:Connect(function(enter) stroke(inp,T.Border,1); if enter then tbcb(inp.Text) end end)
                local obj={};function obj:Get() return inp.Text end;function obj:Set(t) inp.Text=t end;return obj
            end

            return sec
        end

        -- ── AddExecutorPanel ─────────────────────────────────
        function tab:AddExecutorPanel(ec)
            ec = ec or {}
            local etitle = ec.Title    or "EXECUTOR"
            local edef   = ec.Default  or ""
            local ecb    = ec.Callback or function() end
            local eclr   = ec.OnClear  or function() end

            -- Hide the normal scroll page
            page.Visible = false

            -- Executor panel (fills content)
            local ep = newFrame({
                Name="ExecPanel",
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,
                Visible=false,
            }, content)
            tab._exec = ep
            tab._page = nil

            -- Header bar
            local ehdr = newFrame({Size=UDim2.new(1,0,0,32),BackgroundColor3=T.Card},ep)
            corner(ehdr,6)
            newImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,10,0.5,-7),Image=Icons.Code,ImageColor3=T.Accent},ehdr)
            newLabel({Size=UDim2.new(0,150,1,0),Position=UDim2.new(0,30,0,0),Text=etitle,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=T.Accent,TextXAlignment=Enum.TextXAlignment.Left},ehdr)
            -- READY indicator
            local rdot = newFrame({Size=UDim2.new(0,7,0,7),Position=UDim2.new(1,-80,0.5,-3),BackgroundColor3=T.Green},ehdr)
            corner(rdot,99)
            newLabel({Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-70,0,0),Text="READY",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=T.Green,TextXAlignment=Enum.TextXAlignment.Left},ehdr)

            -- Editor bg
            local ebg = newFrame({
                Size=UDim2.new(1,0,1,-86),
                Position=UDim2.new(0,0,0,36),
                BackgroundColor3=T.CodeBg,
            },ep)
            corner(ebg,7); stroke(ebg,T.Border,1)

            -- Line numbers
            local lineNums = Instance.new("ScrollingFrame")
            lineNums.Size=UDim2.new(0,28,1,-6); lineNums.Position=UDim2.new(0,2,0,3)
            lineNums.BackgroundTransparency=1; lineNums.BorderSizePixel=0
            lineNums.ScrollBarThickness=0; lineNums.CanvasSize=UDim2.new(0,0,0,0)
            lineNums.AutomaticCanvasSize=Enum.AutomaticSize.Y
            lineNums.Parent=ebg
            listLayout(lineNums,0)

            -- Code editor
            local codeBox = Instance.new("TextBox")
            codeBox.Size=UDim2.new(1,-32,1,-6); codeBox.Position=UDim2.new(0,30,0,3)
            codeBox.BackgroundTransparency=1; codeBox.BorderSizePixel=0
            codeBox.Text=edef; codeBox.PlaceholderText="-- Write your Lua here..."
            codeBox.PlaceholderColor3=T.TextMute; codeBox.Font=Enum.Font.Code
            codeBox.TextSize=12; codeBox.TextColor3=T.Text
            codeBox.TextXAlignment=Enum.TextXAlignment.Left
            codeBox.TextYAlignment=Enum.TextYAlignment.Top
            codeBox.MultiLine=true; codeBox.ClearTextOnFocus=false
            codeBox.Parent=ebg

            local function refreshLines()
                lineNums:ClearAllChildren()
                local n=1; for _ in codeBox.Text:gmatch("\n") do n=n+1 end
                for i=1,math.max(n,15) do
                    newLabel({Size=UDim2.new(1,0,0,17),Text=tostring(i),Font=Enum.Font.Code,TextSize=11,TextColor3=T.TextMute},lineNums)
                end
            end
            refreshLines()
            codeBox:GetPropertyChangedSignal("Text"):Connect(refreshLines)

            -- Buttons row
            local brow = newFrame({Size=UDim2.new(1,0,0,38),Position=UDim2.new(0,0,1,-42),BackgroundTransparency=1},ep)
            listLayout(brow,6,Enum.FillDirection.Horizontal)

            local execBtn = newBtn({Size=UDim2.new(0.55,-3,1,0),BackgroundColor3=T.Accent,Text=""},brow)
            corner(execBtn,7)
            newImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0.5,-40,0.5,-7),Image=Icons.Play,ImageColor3=T.Text},execBtn)
            newLabel({Size=UDim2.new(0,70,1,0),Position=UDim2.new(0.5,-18,0,0),Text="EXECUTE",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Text},execBtn)

            local clrBtn = newBtn({Size=UDim2.new(0.45,-3,1,0),BackgroundColor3=T.Card,Text=""},brow)
            corner(clrBtn,7); stroke(clrBtn,T.Border,1)
            newImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0.5,-36,0.5,-7),Image=Icons.Trash,ImageColor3=T.TextDim},clrBtn)
            newLabel({Size=UDim2.new(0,55,1,0),Position=UDim2.new(0.5,-16,0,0),Text="CLEAR",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.TextDim},clrBtn)

            execBtn.MouseEnter:Connect(function() tw(execBtn,{BackgroundColor3=T.AccentHi}) end)
            execBtn.MouseLeave:Connect(function() tw(execBtn,{BackgroundColor3=T.Accent}) end)
            execBtn.Activated:Connect(function()
                tw(execBtn,{BackgroundColor3=T.AccentLo},.08)
                task.delay(.12,function() tw(execBtn,{BackgroundColor3=T.Accent}) end)
                ecb(codeBox.Text)
            end)
            clrBtn.MouseEnter:Connect(function() tw(clrBtn,{BackgroundColor3=T.Panel}) end)
            clrBtn.MouseLeave:Connect(function() tw(clrBtn,{BackgroundColor3=T.Card}) end)
            clrBtn.Activated:Connect(function() codeBox.Text=""; refreshLines(); eclr() end)

            -- If first tab → also show executor
            if self._win._active == tab then
                ep.Visible = true
            end

            return {
                GetCode=function() return codeBox.Text end,
                SetCode=function(_,c) codeBox.Text=c or ""; refreshLines() end,
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
