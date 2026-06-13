--[[
    ███████╗███████╗ ██████╗ ██╗  ██╗    ██╗   ██╗██╗    ██╗      ██╗██████╗ 
    ╚══███╔╝██╔════╝██╔═══██╗╚██╗██╔╝    ██║   ██║██║    ██║     ██╔╝╚════██╗
      ███╔╝ █████╗  ██║   ██║ ╚███╔╝     ██║   ██║██║    ██║    ██╔╝   ▄███╔╝
     ███╔╝  ██╔══╝  ██║   ██║ ██╔██╗     ██║   ██║██║    ██║   ██╔╝    ▀▀══╝ 
    ███████╗███████╗╚██████╔╝██╔╝ ██╗    ╚██████╔╝██║    ███████╗██╗   ██╗   
    ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝    ╚══════╝╚═╝   ╚═╝   
    
    ZEOX UI Library v1.0.1
    A Roblox UI Library inspired by ZEOX CLIENT
    
    Usage:
        local ZeoxLib = loadstring(...)()
        local Window = ZeoxLib:CreateWindow({ Title = "My App", Version = "v1.0.0" })
        local Tab = Window:AddTab({ Name = "HOME", Icon = "rbxassetid://7733960981" })
        local Section = Tab:AddSection({ Name = "FEATURES" })
        Section:AddToggle({ Name = "Auto-Farm", Default = false, Callback = function(val) end })
]]

local ZeoxLib = {}
ZeoxLib.__index = ZeoxLib

-- ============================================================
--  SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  THEME
-- ============================================================
local Theme = {
    Background       = Color3.fromRGB(15, 15, 20),
    Sidebar          = Color3.fromRGB(10, 10, 14),
    Panel            = Color3.fromRGB(20, 20, 28),
    Card             = Color3.fromRGB(25, 25, 35),
    Border           = Color3.fromRGB(45, 45, 60),
    Accent           = Color3.fromRGB(220, 30, 30),
    AccentDark       = Color3.fromRGB(160, 20, 20),
    AccentGlow       = Color3.fromRGB(255, 60, 60),
    Text             = Color3.fromRGB(240, 240, 240),
    TextDim          = Color3.fromRGB(160, 160, 180),
    TextMuted        = Color3.fromRGB(100, 100, 120),
    ToggleOn         = Color3.fromRGB(220, 30, 30),
    ToggleOff        = Color3.fromRGB(50, 50, 65),
    SliderFill       = Color3.fromRGB(220, 30, 30),
    SliderTrack      = Color3.fromRGB(40, 40, 55),
    StatusGreen      = Color3.fromRGB(50, 220, 100),
    StatusRed        = Color3.fromRGB(220, 50, 50),
    TabActive        = Color3.fromRGB(220, 30, 30),
    TabHover         = Color3.fromRGB(35, 35, 50),
    CodeBg           = Color3.fromRGB(12, 12, 18),
    CodeText         = Color3.fromRGB(200, 200, 220),
    CodeKeyword      = Color3.fromRGB(220, 30, 30),
    CodeComment      = Color3.fromRGB(100, 120, 100),
    CodeString       = Color3.fromRGB(150, 220, 120),
    ExecuteBtn       = Color3.fromRGB(220, 30, 30),
    ClearBtn         = Color3.fromRGB(30, 30, 42),
}

-- ============================================================
--  ICON ASSET IDs  (Roblox catalog / toolbox icons)
-- ============================================================
local Icons = {
    Home        = "rbxassetid://7733960981",   -- house icon
    Executor    = "rbxassetid://7734053495",   -- code / terminal icon
    Scripts     = "rbxassetid://7734045250",   -- document icon
    Settings    = "rbxassetid://7734036682",   -- gear icon
    Close       = "rbxassetid://7072725342",   -- X icon
    Minimize    = "rbxassetid://7072725640",   -- minus icon
    Maximize    = "rbxassetid://7072725852",   -- square icon
    Toggle      = "rbxassetid://7072718362",   -- circle dot
    Refresh     = "rbxassetid://7072720526",   -- refresh arrows
    Lightning   = "rbxassetid://7072722960",   -- bolt icon
    Arrow       = "rbxassetid://7072716400",   -- double chevron
    User        = "rbxassetid://7072724501",   -- person icon
    Gear        = "rbxassetid://7072721958",   -- settings cog
    Play        = "rbxassetid://7072719712",   -- play triangle
    Trash       = "rbxassetid://7072725052",   -- trash bin
    Run         = "rbxassetid://7072723416",   -- running figure
    Check       = "rbxassetid://7072716987",   -- checkmark
    ZLogo       = "rbxassetid://17929804958",  -- Z letter logo (replace with your own)
}

-- ============================================================
--  UTILITY HELPERS
-- ============================================================
local function Tween(obj, props, duration, easingStyle, easingDir)
    local info = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDir or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            dragStart  = input.Position
            startPos   = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function AddPadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 8)
    p.PaddingRight  = UDim.new(0, right  or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft   = UDim.new(0, left   or 8)
    p.Parent = parent
    return p
end

local function AddListLayout(parent, padding, dir, halign)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, padding or 6)
    l.FillDirection    = dir    or Enum.FillDirection.Vertical
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

-- ============================================================
--  MAIN LIBRARY – CreateWindow
-- ============================================================

function ZeoxLib:CreateWindow(config)
    config = config or {}
    local title   = config.Title   or "ZEOX CLIENT"
    local version = config.Version or "v1.0.1"

    -- ── ROOT GUI ──────────────────────────────────────────────
    local ScreenGui = Create("ScreenGui", {
        Name             = "ZeoxUI_" .. title,
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 999,
    })
    -- try CoreGui first (executors), fall back to PlayerGui
    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ── MAIN FRAME ───────────────────────────────────────────
    local MainFrame = Create("Frame", {
        Name              = "MainFrame",
        Size              = UDim2.new(0, 860, 0, 540),
        Position          = UDim2.new(0.5, -430, 0.5, -270),
        BackgroundColor3  = Theme.Background,
        BorderSizePixel   = 0,
        Parent            = ScreenGui,
    })
    AddCorner(MainFrame, 10)
    AddStroke(MainFrame, Theme.Accent, 1.5)

    -- subtle red glow on edges
    local Glow = Create("ImageLabel", {
        Name              = "Glow",
        Size              = UDim2.new(1, 40, 1, 40),
        Position          = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://5028857084",
        ImageColor3       = Theme.Accent,
        ImageTransparency = 0.85,
        ZIndex            = 0,
        Parent            = MainFrame,
    })

    -- ── TITLE BAR ────────────────────────────────────────────
    local TitleBar = Create("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = MainFrame,
    })
    -- top corners only via UICorner (rounded top, flat bottom via clip)
    AddCorner(TitleBar, 10)
    -- cover bottom corners with a sub-frame
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = TitleBar,
    })
    -- bottom border line
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = TitleBar,
    })

    -- Z logo
    local LogoFrame = Create("ImageLabel", {
        Name             = "Logo",
        Size             = UDim2.new(0, 30, 0, 30),
        Position         = UDim2.new(0, 12, 0.5, -15),
        BackgroundTransparency = 1,
        Image            = Icons.ZLogo,
        ImageColor3      = Theme.Accent,
        ZIndex           = 6,
        Parent           = TitleBar,
    })

    -- Title text
    local TitleLabel = Create("TextLabel", {
        Name             = "Title",
        Size             = UDim2.new(0, 300, 1, 0),
        Position         = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1,
        Text             = title .. "  ",
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        TextColor3       = Theme.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
        Parent           = TitleBar,
    })

    -- Version badge
    local VersionLabel = Create("TextLabel", {
        Name             = "Version",
        Size             = UDim2.new(0, 80, 0, 20),
        Position         = UDim2.new(0, 50 + 130, 0.5, -10),
        BackgroundColor3 = Theme.Card,
        Text             = version,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 11,
        TextColor3       = Theme.TextDim,
        ZIndex           = 6,
        Parent           = TitleBar,
    })
    AddCorner(VersionLabel, 4)

    -- Window control buttons (–  □  ✕)
    local function MakeWinBtn(symbol, xOffset, color, action)
        local btn = Create("TextButton", {
            Size             = UDim2.new(0, 24, 0, 24),
            Position         = UDim2.new(1, xOffset, 0.5, -12),
            BackgroundColor3 = Theme.Card,
            Text             = symbol,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextColor3       = color or Theme.TextDim,
            ZIndex           = 7,
            Parent           = TitleBar,
        })
        AddCorner(btn, 4)
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundColor3 = color or Theme.TextDim }, 0.15)
            Tween(btn, { TextColor3 = Theme.Text }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.Card }, 0.15)
            Tween(btn, { TextColor3 = color or Theme.TextDim }, 0.15)
        end)
        btn.Activated:Connect(action)
        return btn
    end

    MakeWinBtn("✕", -10, Theme.Accent, function()
        Tween(MainFrame, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,0,0.5,0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.3, function() ScreenGui:Destroy() end)
    end)
    MakeWinBtn("□", -40, Theme.TextDim, function() end)
    MakeWinBtn("–", -70, Theme.TextDim, function()
        local vis = not MainFrame.Visible
        -- just hide/show inner content (keep title bar)
    end)

    MakeDraggable(MainFrame, TitleBar)

    -- ── SIDEBAR ──────────────────────────────────────────────
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 170, 1, -44),
        Position         = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = MainFrame,
    })
    -- right border
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = Sidebar,
    })

    -- Big Z logo in sidebar
    local SidebarLogo = Create("ImageLabel", {
        Name             = "SidebarLogo",
        Size             = UDim2.new(0, 90, 0, 90),
        Position         = UDim2.new(0.5, -45, 0, 18),
        BackgroundTransparency = 1,
        Image            = Icons.ZLogo,
        ImageColor3      = Theme.Accent,
        ZIndex           = 5,
        Parent           = Sidebar,
    })

    -- Logo glow
    Create("ImageLabel", {
        Size             = UDim2.new(0, 120, 0, 120),
        Position         = UDim2.new(0.5, -60, 0, 3),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://5028857084",
        ImageColor3      = Theme.Accent,
        ImageTransparency = 0.7,
        ZIndex           = 4,
        Parent           = Sidebar,
    })

    -- Sidebar nav list
    local NavList = Create("Frame", {
        Name             = "NavList",
        Size             = UDim2.new(1, 0, 1, -120),
        Position         = UDim2.new(0, 0, 0, 120),
        BackgroundTransparency = 1,
        ZIndex           = 5,
        Parent           = Sidebar,
    })
    AddListLayout(NavList, 2)

    -- Status bar at bottom of sidebar
    local StatusBar = Create("Frame", {
        Name             = "StatusBar",
        Size             = UDim2.new(1, 0, 0, 28),
        Position         = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = MainFrame,
    })
    local StatusLabel = Create("TextLabel", {
        Size             = UDim2.new(0, 200, 1, 0),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text             = "STATUS: ATTACHED",
        Font             = Enum.Font.GothamMedium,
        TextSize         = 11,
        TextColor3       = Theme.TextMuted,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
        Parent           = StatusBar,
    })
    -- Status dot
    local StatusDot = Create("Frame", {
        Size             = UDim2.new(0, 7, 0, 7),
        Position         = UDim2.new(0, 95, 0.5, -3),
        BackgroundColor3 = Theme.StatusGreen,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = StatusBar,
    })
    AddCorner(StatusDot, 99)
    -- "STATUS:" in accent
    Create("TextLabel", {
        Size             = UDim2.new(0, 60, 1, 0),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text             = "STATUS:",
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextColor3       = Theme.TextMuted,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
        Parent           = StatusBar,
    })
    -- Welcome text
    local WelcomeLabel = Create("TextLabel", {
        Size             = UDim2.new(0, 250, 1, 0),
        Position         = UDim2.new(1, -260, 0, 0),
        BackgroundTransparency = 1,
        Text             = "WELCOME, " .. (LocalPlayer and LocalPlayer.Name or "USER"),
        Font             = Enum.Font.GothamMedium,
        TextSize         = 11,
        TextColor3       = Theme.TextMuted,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 6,
        Parent           = StatusBar,
    })
    -- username in accent
    Create("TextLabel", {
        Size             = UDim2.new(0, 120, 1, 0),
        Position         = UDim2.new(1, -128, 0, 0),
        BackgroundTransparency = 1,
        Text             = (LocalPlayer and LocalPlayer.Name or "USER"),
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextColor3       = Theme.Accent,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 7,
        Parent           = StatusBar,
    })

    -- ── CONTENT AREA ─────────────────────────────────────────
    local ContentArea = Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -170, 1, -72),
        Position         = UDim2.new(0, 170, 0, 44),
        BackgroundTransparency = 1,
        ZIndex           = 3,
        Parent           = MainFrame,
    })

    -- ── WINDOW OBJECT ────────────────────────────────────────
    local Window = {
        _gui        = ScreenGui,
        _main       = MainFrame,
        _sidebar    = Sidebar,
        _navList    = NavList,
        _content    = ContentArea,
        _tabs       = {},
        _activeTab  = nil,
        StatusLabel = StatusLabel,
        StatusDot   = StatusDot,
    }

    -- entrance animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(MainFrame, {
        Size     = UDim2.new(0, 860, 0, 540),
        Position = UDim2.new(0.5, -430, 0.5, -270),
    }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ── SetStatus ────────────────────────────────────────────
    function Window:SetStatus(text, attached)
        StatusLabel.Text = "STATUS: " .. (text or "ATTACHED")
        StatusDot.BackgroundColor3 = attached ~= false and Theme.StatusGreen or Theme.StatusRed
    end

    -- ── AddTab ───────────────────────────────────────────────
    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name    or "TAB"
        local tabIcon = tabConfig.Icon    or Icons.Home

        -- Sidebar button
        local NavBtn = Create("TextButton", {
            Name             = tabName .. "_NavBtn",
            Size             = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Theme.Sidebar,
            Text             = "",
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = self._navList,
        })

        -- Active left-edge indicator
        local ActiveBar = Create("Frame", {
            Size             = UDim2.new(0, 3, 0.7, 0),
            Position         = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            ZIndex           = 8,
            Visible          = false,
            Parent           = NavBtn,
        })
        AddCorner(ActiveBar, 2)

        -- Icon
        local NavIcon = Create("ImageLabel", {
            Size             = UDim2.new(0, 18, 0, 18),
            Position         = UDim2.new(0, 20, 0.5, -9),
            BackgroundTransparency = 1,
            Image            = tabIcon,
            ImageColor3      = Theme.TextDim,
            ZIndex           = 7,
            Parent           = NavBtn,
        })
        -- Label
        local NavLabel = Create("TextLabel", {
            Size             = UDim2.new(1, -50, 1, 0),
            Position         = UDim2.new(0, 46, 0, 0),
            BackgroundTransparency = 1,
            Text             = tabName,
            Font             = Enum.Font.GothamSemibold,
            TextSize          = 12,
            TextColor3       = Theme.TextDim,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LetterSpacing    = 2,
            ZIndex           = 7,
            Parent           = NavBtn,
        })

        -- Tab page (scroll frame)
        local TabPage = Create("ScrollingFrame", {
            Name                   = tabName .. "_Page",
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = Theme.Accent,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = false,
            ZIndex                 = 3,
            Parent                 = self._content,
        })
        AddPadding(TabPage, 12, 12, 12, 12)
        AddListLayout(TabPage, 10)

        local tab = {
            _window  = self,
            _page    = TabPage,
            _navBtn  = NavBtn,
            _navIcon = NavIcon,
            _navLbl  = NavLabel,
            _actBar  = ActiveBar,
        }
        table.insert(self._tabs, tab)

        -- First tab → auto-activate
        if #self._tabs == 1 then
            self:_ActivateTab(tab)
        end

        NavBtn.MouseEnter:Connect(function()
            if self._activeTab ~= tab then
                Tween(NavBtn,  { BackgroundColor3 = Theme.TabHover }, 0.15)
                Tween(NavIcon, { ImageColor3 = Theme.Text }, 0.15)
                Tween(NavLabel,{ TextColor3 = Theme.Text  }, 0.15)
            end
        end)
        NavBtn.MouseLeave:Connect(function()
            if self._activeTab ~= tab then
                Tween(NavBtn,  { BackgroundColor3 = Theme.Sidebar }, 0.15)
                Tween(NavIcon, { ImageColor3 = Theme.TextDim }, 0.15)
                Tween(NavLabel,{ TextColor3 = Theme.TextDim  }, 0.15)
            end
        end)
        NavBtn.Activated:Connect(function()
            self:_ActivateTab(tab)
        end)

        -- ── AddSection ───────────────────────────────────────
        function tab:AddSection(sConfig)
            sConfig = sConfig or {}
            local sName    = sConfig.Name    or "SECTION"
            local sIcon    = sConfig.Icon    or Icons.Gear
            local sColumns = sConfig.Columns or 1 -- 1 = full width, 2 = split

            -- Section card
            local SectionCard = Create("Frame", {
                Name             = sName .. "_Section",
                Size             = UDim2.new(1, 0, 0, 10),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = TabPage,
            })
            AddCorner(SectionCard, 8)
            AddStroke(SectionCard, Theme.Border, 1)

            -- Section header
            local SectionHeader = Create("Frame", {
                Name             = "Header",
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Theme.Card,
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = SectionCard,
            })
            AddCorner(SectionHeader, 8)
            -- cover bottom-left and bottom-right corners of header
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 8),
                Position         = UDim2.new(0, 0, 1, -8),
                BackgroundColor3 = Theme.Card,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = SectionHeader,
            })
            -- bottom border line under header
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel  = 0,
                ZIndex           = 6,
                Parent           = SectionHeader,
            })

            -- Section icon
            Create("ImageLabel", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new(0, 12, 0.5, -8),
                BackgroundTransparency = 1,
                Image            = sIcon,
                ImageColor3      = Theme.Accent,
                ZIndex           = 6,
                Parent           = SectionHeader,
            })
            -- Section title
            Create("TextLabel", {
                Size             = UDim2.new(1, -40, 1, 0),
                Position         = UDim2.new(0, 34, 0, 0),
                BackgroundTransparency = 1,
                Text             = sName,
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = Theme.Accent,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LetterSpacing    = 3,
                ZIndex           = 6,
                Parent           = SectionHeader,
            })

            -- Items container
            local ItemsFrame = Create("Frame", {
                Name             = "Items",
                Size             = UDim2.new(1, 0, 0, 10),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex           = 5,
                Parent           = SectionCard,
            })
            AddPadding(ItemsFrame, 6, 10, 10, 10)
            AddListLayout(ItemsFrame, 6)

            local section = { _card = SectionCard, _items = ItemsFrame }

            -- ── AddToggle ─────────────────────────────────────
            function section:AddToggle(tConfig)
                tConfig = tConfig or {}
                local tName     = tConfig.Name     or "Toggle"
                local tDefault  = tConfig.Default  ~= nil and tConfig.Default or false
                local tIcon     = tConfig.Icon      or Icons.Check
                local tCallback = tConfig.Callback  or function() end

                local enabled = tDefault

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    ZIndex           = 6,
                    Parent           = ItemsFrame,
                })

                -- Icon
                Create("ImageLabel", {
                    Size             = UDim2.new(0, 16, 0, 16),
                    Position         = UDim2.new(0, 0, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image            = tIcon,
                    ImageColor3      = Theme.Accent,
                    ZIndex           = 7,
                    Parent           = Row,
                })
                -- Name
                Create("TextLabel", {
                    Size             = UDim2.new(1, -70, 1, 0),
                    Position         = UDim2.new(0, 22, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = tName,
                    Font             = Enum.Font.GothamMedium,
                    TextSize         = 13,
                    TextColor3       = Theme.Text,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 7,
                    Parent           = Row,
                })

                -- Toggle pill
                local Pill = Create("Frame", {
                    Size             = UDim2.new(0, 48, 0, 24),
                    Position         = UDim2.new(1, -48, 0.5, -12),
                    BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                    Parent           = Row,
                })
                AddCorner(Pill, 12)
                -- Label ON/OFF
                local PillLabel = Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = enabled and "ON" or "OFF",
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 9,
                    TextColor3       = Theme.Text,
                    TextXAlignment   = enabled and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
                    ZIndex           = 8,
                    Parent           = Pill,
                })
                AddPadding(PillLabel, 0, 5, 0, 5)
                -- Knob
                local Knob = Create("Frame", {
                    Size             = UDim2.new(0, 18, 0, 18),
                    Position         = UDim2.new(enabled and 1 or 0, enabled and -21 or 3, 0.5, -9),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel  = 0,
                    ZIndex           = 9,
                    Parent           = Pill,
                })
                AddCorner(Knob, 9)

                -- click area
                local ToggleBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 10,
                    Parent           = Row,
                })
                ToggleBtn.Activated:Connect(function()
                    enabled = not enabled
                    Tween(Pill, { BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                    Tween(Knob, { Position = UDim2.new(enabled and 1 or 0, enabled and -21 or 3, 0.5, -9) }, 0.2)
                    PillLabel.Text = enabled and "ON" or "OFF"
                    PillLabel.TextXAlignment = enabled and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                    tCallback(enabled)
                end)

                local toggleObj = {}
                function toggleObj:Set(val)
                    enabled = val
                    Tween(Pill, { BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                    Tween(Knob, { Position = UDim2.new(enabled and 1 or 0, enabled and -21 or 3, 0.5, -9) }, 0.2)
                    PillLabel.Text = enabled and "ON" or "OFF"
                    PillLabel.TextXAlignment = enabled and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                end
                function toggleObj:Get() return enabled end
                return toggleObj
            end

            -- ── AddSlider ─────────────────────────────────────
            function section:AddSlider(sConfig)
                sConfig = sConfig or {}
                local sName     = sConfig.Name     or "Slider"
                local sMin      = sConfig.Min      or 0
                local sMax      = sConfig.Max      or 100
                local sDefault  = sConfig.Default  or sMin
                local sSuffix   = sConfig.Suffix   or ""
                local sCallback = sConfig.Callback or function() end

                local value = math.clamp(sDefault, sMin, sMax)

                local Wrapper = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 54),
                    BackgroundTransparency = 1,
                    ZIndex           = 6,
                    Parent           = ItemsFrame,
                })
                -- name + value row
                local LabelRow = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    ZIndex           = 7,
                    Parent           = Wrapper,
                })
                Create("TextLabel", {
                    Size             = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = sName,
                    Font             = Enum.Font.GothamMedium,
                    TextSize         = 13,
                    TextColor3       = Theme.Text,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 7,
                    Parent           = LabelRow,
                })
                local ValBox = Create("Frame", {
                    Size             = UDim2.new(0, 52, 0, 20),
                    Position         = UDim2.new(1, -52, 0.5, -10),
                    BackgroundColor3 = Theme.Card,
                    ZIndex           = 7,
                    Parent           = LabelRow,
                })
                AddCorner(ValBox, 4)
                AddStroke(ValBox, Theme.Border, 1)
                local ValLabel = Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = tostring(value) .. sSuffix,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 11,
                    TextColor3       = Theme.Text,
                    ZIndex           = 8,
                    Parent           = ValBox,
                })

                -- Track
                local Track = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                    Parent           = Wrapper,
                })
                AddCorner(Track, 3)
                local Fill = Create("Frame", {
                    Size             = UDim2.new((value - sMin)/(sMax - sMin), 0, 1, 0),
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel  = 0,
                    ZIndex           = 8,
                    Parent           = Track,
                })
                AddCorner(Fill, 3)
                local Knob = Create("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = UDim2.new((value - sMin)/(sMax - sMin), -7, 0.5, -7),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel  = 0,
                    ZIndex           = 9,
                    Parent           = Track,
                })
                AddCorner(Knob, 7)
                AddStroke(Knob, Theme.Accent, 2)

                -- min/max labels
                local function minMaxLabel(txt, xOff)
                    return Create("TextLabel", {
                        Size             = UDim2.new(0, 40, 0, 14),
                        Position         = UDim2.new(xOff, xOff == 0 and 0 or -40, 0, 40),
                        BackgroundTransparency = 1,
                        Text             = tostring(txt),
                        Font             = Enum.Font.Gotham,
                        TextSize         = 10,
                        TextColor3       = Theme.TextMuted,
                        TextXAlignment   = xOff == 0 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
                        ZIndex           = 7,
                        Parent           = Wrapper,
                    })
                end
                minMaxLabel(sMin, 0)
                minMaxLabel(sMax, 1)

                -- Drag logic
                local isDragging = false
                local function updateSlider(input)
                    local trackPos  = Track.AbsolutePosition.X
                    local trackSize = Track.AbsoluteSize.X
                    local relX      = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
                    local newVal    = math.floor(sMin + relX * (sMax - sMin) + 0.5)
                    value = newVal
                    Tween(Fill,  { Size     = UDim2.new(relX, 0, 1, 0) }, 0.05)
                    Tween(Knob,  { Position = UDim2.new(relX, -7, 0.5, -7) }, 0.05)
                    ValLabel.Text = tostring(value) .. sSuffix
                    sCallback(value)
                end
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        updateSlider(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)

                local sliderObj = {}
                function sliderObj:Set(val)
                    value = math.clamp(val, sMin, sMax)
                    local relX = (value - sMin)/(sMax - sMin)
                    Tween(Fill, { Size = UDim2.new(relX, 0, 1, 0) }, 0.1)
                    Tween(Knob, { Position = UDim2.new(relX, -7, 0.5, -7) }, 0.1)
                    ValLabel.Text = tostring(value) .. sSuffix
                end
                function sliderObj:Get() return value end
                return sliderObj
            end

            -- ── AddButton ─────────────────────────────────────
            function section:AddButton(bConfig)
                bConfig = bConfig or {}
                local bName     = bConfig.Name     or "Button"
                local bIcon     = bConfig.Icon      or Icons.Play
                local bCallback = bConfig.Callback  or function() end

                local Btn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.Card,
                    Text             = "",
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                    Parent           = ItemsFrame,
                })
                AddCorner(Btn, 6)
                AddStroke(Btn, Theme.Border, 1)

                Create("ImageLabel", {
                    Size             = UDim2.new(0, 16, 0, 16),
                    Position         = UDim2.new(0, 12, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image            = bIcon,
                    ImageColor3      = Theme.Accent,
                    ZIndex           = 8,
                    Parent           = Btn,
                })
                Create("TextLabel", {
                    Size             = UDim2.new(1, -40, 1, 0),
                    Position         = UDim2.new(0, 36, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = bName,
                    Font             = Enum.Font.GothamSemibold,
                    TextSize         = 13,
                    TextColor3       = Theme.Text,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 8,
                    Parent           = Btn,
                })

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, { BackgroundColor3 = Theme.TabHover }, 0.15)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, { BackgroundColor3 = Theme.Card }, 0.15)
                end)
                Btn.Activated:Connect(function()
                    Tween(Btn, { BackgroundColor3 = Theme.AccentDark }, 0.1)
                    task.delay(0.12, function()
                        Tween(Btn, { BackgroundColor3 = Theme.Card }, 0.15)
                    end)
                    bCallback()
                end)
            end

            -- ── AddLabel ──────────────────────────────────────
            function section:AddLabel(lConfig)
                lConfig = lConfig or {}
                local lText  = lConfig.Text  or ""
                local lColor = lConfig.Color or Theme.TextDim

                local lbl = Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Text             = lText,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = lColor,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 6,
                    Parent           = ItemsFrame,
                })
                local labelObj = {}
                function labelObj:Set(txt) lbl.Text = txt end
                return labelObj
            end

            -- ── AddTextBox ────────────────────────────────────
            function section:AddTextBox(tbConfig)
                tbConfig = tbConfig or {}
                local tbName      = tbConfig.Name        or "Input"
                local tbPlaceholder = tbConfig.Placeholder or "Enter text..."
                local tbCallback  = tbConfig.Callback    or function() end

                local Wrapper = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 54),
                    BackgroundTransparency = 1,
                    ZIndex           = 6,
                    Parent           = ItemsFrame,
                })
                Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text             = tbName,
                    Font             = Enum.Font.GothamMedium,
                    TextSize         = 12,
                    TextColor3       = Theme.TextDim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 7,
                    Parent           = Wrapper,
                })
                local InputBox = Create("TextBox", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    Position         = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Card,
                    Text             = "",
                    PlaceholderText  = tbPlaceholder,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 13,
                    TextColor3       = Theme.Text,
                    PlaceholderColor3 = Theme.TextMuted,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex           = 7,
                    Parent           = Wrapper,
                })
                AddCorner(InputBox, 6)
                AddStroke(InputBox, Theme.Border, 1)
                AddPadding(InputBox, 0, 8, 0, 10)
                InputBox.FocusLost:Connect(function(enter)
                    if enter then tbCallback(InputBox.Text) end
                end)
                InputBox.Focused:Connect(function()
                    Tween(InputBox, { BackgroundColor3 = Theme.TabHover }, 0.15)
                    AddStroke(InputBox, Theme.Accent, 1)
                end)
                InputBox.FocusLost:Connect(function()
                    Tween(InputBox, { BackgroundColor3 = Theme.Card }, 0.15)
                    AddStroke(InputBox, Theme.Border, 1)
                end)
                local tbObj = {}
                function tbObj:Get() return InputBox.Text end
                function tbObj:Set(txt) InputBox.Text = txt end
                return tbObj
            end

            return section
        end

        -- ── AddExecutorPanel ─────────────────────────────────
        -- Adds the right-side executor panel (code editor + run/clear)
        function tab:AddExecutorPanel(exConfig)
            exConfig = exConfig or {}
            local exTitle    = exConfig.Title    or "EXECUTOR"
            local exDefault  = exConfig.Default  or ""
            local exCallback = exConfig.Callback or function(code) end
            local exClear    = exConfig.OnClear  or function() end

            -- The executor panel replaces the tab page with a 2-column layout
            TabPage.Visible = false -- hide default scroll page

            local ExPanel = Create("Frame", {
                Name             = "ExecutorPanel",
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible          = false,
                ZIndex           = 3,
                Parent           = self._window._content,
            })

            -- Header
            local Header = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Theme.Card,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = ExPanel,
            })
            AddCorner(Header, 6)
            Create("ImageLabel", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new(0, 12, 0.5, -8),
                BackgroundTransparency = 1,
                Image            = Icons.Executor,
                ImageColor3      = Theme.Accent,
                ZIndex           = 5,
                Parent           = Header,
            })
            Create("TextLabel", {
                Size             = UDim2.new(0, 200, 1, 0),
                Position         = UDim2.new(0, 34, 0, 0),
                BackgroundTransparency = 1,
                Text             = exTitle,
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = Theme.Accent,
                TextXAlignment   = Enum.TextXAlignment.Left,
                LetterSpacing    = 3,
                ZIndex           = 5,
                Parent           = Header,
            })
            -- READY badge
            local ReadyFrame = Create("Frame", {
                Size             = UDim2.new(0, 70, 0, 20),
                Position         = UDim2.new(1, -80, 0.5, -10),
                BackgroundTransparency = 1,
                ZIndex           = 5,
                Parent           = Header,
            })
            Create("Frame", {
                Size             = UDim2.new(0, 8, 0, 8),
                Position         = UDim2.new(0, 0, 0.5, -4),
                BackgroundColor3 = Theme.StatusGreen,
                BorderSizePixel  = 0,
                ZIndex           = 6,
                Parent           = ReadyFrame,
            }).Parent = ReadyFrame
            local dot = Create("Frame", {
                Size             = UDim2.new(0, 8, 0, 8),
                Position         = UDim2.new(0, 0, 0.5, -4),
                BackgroundColor3 = Theme.StatusGreen,
                BorderSizePixel  = 0,
                ZIndex           = 6,
                Parent           = ReadyFrame,
            })
            AddCorner(dot, 4)
            Create("TextLabel", {
                Size             = UDim2.new(0, 60, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = "READY",
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = Theme.StatusGreen,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = ReadyFrame,
            })

            -- Code editor area
            local EditorBg = Create("Frame", {
                Size             = UDim2.new(1, 0, 1, -90),
                Position         = UDim2.new(0, 0, 0, 38),
                BackgroundColor3 = Theme.CodeBg,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = ExPanel,
            })
            AddCorner(EditorBg, 8)
            AddStroke(EditorBg, Theme.Border, 1)

            -- Line numbers column
            local LineNums = Create("ScrollingFrame", {
                Size                   = UDim2.new(0, 30, 1, -4),
                Position               = UDim2.new(0, 2, 0, 2),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                ScrollBarThickness     = 0,
                ZIndex                 = 5,
                Parent                 = EditorBg,
            })

            local CodeBox = Create("TextBox", {
                Size             = UDim2.new(1, -36, 1, -8),
                Position         = UDim2.new(0, 34, 0, 4),
                BackgroundTransparency = 1,
                Text             = exDefault,
                PlaceholderText  = "-- Write your script here...",
                Font             = Enum.Font.Code,
                TextSize         = 13,
                TextColor3       = Theme.CodeText,
                PlaceholderColor3 = Theme.TextMuted,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextYAlignment   = Enum.TextYAlignment.Top,
                MultiLine        = true,
                ClearTextOnFocus = false,
                ZIndex           = 6,
                Parent           = EditorBg,
            })

            -- update line numbers
            local function UpdateLineNumbers()
                LineNums:ClearAllChildren()
                local lines = 1
                for _ in CodeBox.Text:gmatch("\n") do lines = lines + 1 end
                for i = 1, math.max(lines, 20) do
                    Create("TextLabel", {
                        Size             = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text             = tostring(i),
                        Font             = Enum.Font.Code,
                        TextSize         = 12,
                        TextColor3       = Theme.TextMuted,
                        ZIndex           = 6,
                        Parent           = LineNums,
                    })
                end
                LineNums.CanvasSize = UDim2.new(0, 0, 0, lines * 18)
            end
            AddListLayout(LineNums, 0)
            UpdateLineNumbers()
            CodeBox:GetPropertyChangedSignal("Text"):Connect(UpdateLineNumbers)

            -- Buttons row
            local BtnRow = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 42),
                Position         = UDim2.new(0, 0, 1, -44),
                BackgroundTransparency = 1,
                ZIndex           = 4,
                Parent           = ExPanel,
            })
            AddListLayout(BtnRow, 6, Enum.FillDirection.Horizontal)

            local ExecBtn = Create("TextButton", {
                Size             = UDim2.new(0.55, -3, 1, 0),
                BackgroundColor3 = Theme.ExecuteBtn,
                Text             = "",
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = BtnRow,
            })
            AddCorner(ExecBtn, 8)
            Create("ImageLabel", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new(0.5, -42, 0.5, -8),
                BackgroundTransparency = 1,
                Image            = Icons.Play,
                ImageColor3      = Theme.Text,
                ZIndex           = 6,
                Parent           = ExecBtn,
            })
            Create("TextLabel", {
                Size             = UDim2.new(0, 80, 1, 0),
                Position         = UDim2.new(0.5, -22, 0, 0),
                BackgroundTransparency = 1,
                Text             = "EXECUTE",
                Font             = Enum.Font.GothamBold,
                TextSize         = 13,
                TextColor3       = Theme.Text,
                ZIndex           = 6,
                Parent           = ExecBtn,
            })

            local ClearBtn = Create("TextButton", {
                Size             = UDim2.new(0.45, -3, 1, 0),
                BackgroundColor3 = Theme.ClearBtn,
                Text             = "",
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = BtnRow,
            })
            AddCorner(ClearBtn, 8)
            AddStroke(ClearBtn, Theme.Border, 1)
            Create("ImageLabel", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new(0.5, -38, 0.5, -8),
                BackgroundTransparency = 1,
                Image            = Icons.Trash,
                ImageColor3      = Theme.TextDim,
                ZIndex           = 6,
                Parent           = ClearBtn,
            })
            Create("TextLabel", {
                Size             = UDim2.new(0, 60, 1, 0),
                Position         = UDim2.new(0.5, -18, 0, 0),
                BackgroundTransparency = 1,
                Text             = "CLEAR",
                Font             = Enum.Font.GothamBold,
                TextSize         = 13,
                TextColor3       = Theme.TextDim,
                ZIndex           = 6,
                Parent           = ClearBtn,
            })

            ExecBtn.MouseEnter:Connect(function()
                Tween(ExecBtn, { BackgroundColor3 = Theme.AccentGlow }, 0.15)
            end)
            ExecBtn.MouseLeave:Connect(function()
                Tween(ExecBtn, { BackgroundColor3 = Theme.ExecuteBtn }, 0.15)
            end)
            ExecBtn.Activated:Connect(function()
                Tween(ExecBtn, { BackgroundColor3 = Theme.AccentDark }, 0.1)
                task.delay(0.12, function()
                    Tween(ExecBtn, { BackgroundColor3 = Theme.ExecuteBtn }, 0.15)
                end)
                exCallback(CodeBox.Text)
            end)

            ClearBtn.MouseEnter:Connect(function()
                Tween(ClearBtn, { BackgroundColor3 = Theme.TabHover }, 0.15)
            end)
            ClearBtn.MouseLeave:Connect(function()
                Tween(ClearBtn, { BackgroundColor3 = Theme.ClearBtn }, 0.15)
            end)
            ClearBtn.Activated:Connect(function()
                CodeBox.Text = ""
                UpdateLineNumbers()
                exClear()
            end)

            -- hook into nav activation
            local originalPage = self._page
            local exTab = self
            -- store reference to executor panel
            exTab._execPanel = ExPanel

            return {
                GetCode = function() return CodeBox.Text end,
                SetCode = function(_, code)
                    CodeBox.Text = code or ""
                    UpdateLineNumbers()
                end,
            }
        end

        return tab
    end

    -- ── Internal tab activate ─────────────────────────────────
    function Window:_ActivateTab(tab)
        if self._activeTab then
            local prev = self._activeTab
            prev._page.Visible = false
            if prev._execPanel then prev._execPanel.Visible = false end
            Tween(prev._navBtn,  { BackgroundColor3 = Theme.Sidebar }, 0.2)
            Tween(prev._navIcon, { ImageColor3 = Theme.TextDim }, 0.2)
            Tween(prev._navLbl,  { TextColor3 = Theme.TextDim  }, 0.2)
            prev._actBar.Visible = false
        end
        self._activeTab = tab
        tab._page.Visible = true
        if tab._execPanel then tab._execPanel.Visible = true end
        Tween(tab._navBtn,  { BackgroundColor3 = Theme.TabHover }, 0.2)
        Tween(tab._navIcon, { ImageColor3 = Theme.Accent }, 0.2)
        Tween(tab._navLbl,  { TextColor3 = Theme.Text   }, 0.2)
        tab._actBar.Visible = true
    end

    -- ── Destroy / Cleanup ────────────────────────────────────
    function Window:Destroy()
        Tween(MainFrame, {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.3, function() ScreenGui:Destroy() end)
    end

    return Window
end

return ZeoxLib
