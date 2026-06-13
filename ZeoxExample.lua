--[[
╔══════════════════════════════════════════════════════════════╗
║   ZeoxClient — Example Script                                ║
║   Uses ZeoxLib v3.0                                          ║
║                                                              ║
║   كيفية استخدام الشعار:                                      ║
║   1. ارفع ملف ZeoxLogo.png على Roblox:                       ║
║      Creator Dashboard → Development Items → Decals          ║
║      → Upload Image                                          ║
║   2. انسخ رقم الـ Asset ID الظاهر بعد الرفع                  ║
║   3. ضع الرقم في المتغير LOGO_ASSET_ID أدناه                 ║
║      مثال: "rbxassetid://123456789"                          ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ── تحميل المكتبة ──────────────────────────────────────────────
-- الطريقة أ: loadstring من executor
local ZeoxLib = loadstring(game:HttpGet("https://github.com/m9oy/Zeox.Ui/raw/refs/heads/main/ZeoxLib.lua"))()

-- الطريقة ب: require إذا وضعت المكتبة داخل اللعبة
-- local ZeoxLib = require(game.ReplicatedStorage.ZeoxLib)

-- ─────────────────────────────────────────────────────────────
--  ⭐  ضع هنا Asset ID الخاص بشعارك بعد رفعه على Roblox
--  ارفع ملف ZeoxLogo.png ← انسخ الـ ID ← الصقه هنا
-- ─────────────────────────────────────────────────────────────
local LOGO_ASSET_ID = "rbxassetid://101956991637378"
-- مثال بعد الرفع:
-- local LOGO_ASSET_ID = "rbxassetid://17929804958"

-- تطبيق شعارك المرفوع على المكتبة
ZeoxLib.Icon.ZLogo = LOGO_ASSET_ID

-- ══════════════════════════════════════════════════════════════
--  إنشاء النافذة
-- ══════════════════════════════════════════════════════════════
local win = ZeoxLib:CreateWindow({
    Title   = "ZEOX CLIENT",
    Version = "v1.0.1",
})

-- ══════════════════════════════════════════════════════════════
--  تاب HOME — تخطيط عمودين (أقسام يسار + executor يمين)
-- ══════════════════════════════════════════════════════════════
local homeTab = win:AddTab({
    Name = "HOME",
    Icon = ZeoxLib.Icon.Home,
})

homeTab:AddSplitLayout({ LeftWidth = 0.54 })

-- ── العمود الأيسر: قسم FEATURES ───────────────────────────
local featSec = homeTab:AddLeftSection({
    Name = "FEATURES",
    Icon = ZeoxLib.Icon.Bolt,
})

featSec:AddToggle({
    Name     = "Auto-Farm",
    Icon     = ZeoxLib.Icon.Refresh,
    Default  = true,
    Callback = function(on)
        print("[Zeox] Auto-Farm:", on)
    end,
})

featSec:AddToggle({
    Name     = "Speed Hack",
    Icon     = ZeoxLib.Icon.Bolt,
    Default  = true,
    Callback = function(on)
        local hum = game.Players.LocalPlayer.Character
                    and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = on and 100 or 16 end
    end,
})

featSec:AddToggle({
    Name     = "Infinite Jump",
    Icon     = ZeoxLib.Icon.Arrow2,
    Default  = true,
    Callback = function(on)
        print("[Zeox] Infinite Jump:", on)
    end,
})

-- ── العمود الأيسر: قسم PLAYER MODS ───────────────────────
local playerSec = homeTab:AddLeftSection({
    Name = "PLAYER MODS",
    Icon = ZeoxLib.Icon.User,
})

playerSec:AddSlider({
    Name     = "WalkSpeed",
    Min      = 16, Max = 500, Default = 100,
    Callback = function(val)
        local hum = game.Players.LocalPlayer.Character
                    and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val end
    end,
})

playerSec:AddSlider({
    Name     = "JumpPower",
    Min      = 50, Max = 1000, Default = 250,
    Callback = function(val)
        local hum = game.Players.LocalPlayer.Character
                    and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = val end
    end,
})

playerSec:AddToggle({
    Name     = "Noclip",
    Icon     = ZeoxLib.Icon.Runner,
    Default  = false,
    Callback = function(on) print("[Zeox] Noclip:", on) end,
})

-- ── العمود الأيمن: Executor ───────────────────────────────
homeTab:SetupExecutor({
    Title   = "EXECUTOR",
    Default = [[-- ZeoxClient | Auto-Farm Script
-- Version: 1.0.1  | discord.gg/zeox

local ZeoxClient = {}
ZeoxClient.__index = ZeoxClient

function ZeoxClient.new(player)
    local self = setmetatable({}, ZeoxClient)
    self.Player   = player
    self.Speed    = 100
    self.JumpPow  = 250
    self.AutoFarm = true
    return self
end

function ZeoxClient:Start()
    local hum = self.Player
        .Character.Humanoid
    hum.WalkSpeed = self.Speed
    hum.JumpPower = self.JumpPow
end]],
    Callback = function(code)
        local fn, err = loadstring(code)
        if fn then
            local ok, runErr = pcall(fn)
            if not ok then warn("[Zeox] Error:", runErr) end
        else
            warn("[Zeox] Syntax error:", err)
        end
    end,
    OnClear = function() print("[Zeox] Editor cleared") end,
})

-- ══════════════════════════════════════════════════════════════
--  تاب EXECUTOR — executor بعرض كامل
-- ══════════════════════════════════════════════════════════════
local execTab = win:AddTab({
    Name = "EXECUTOR",
    Icon = ZeoxLib.Icon.Terminal,
})

execTab:AddExecutorPanel({
    Title    = "EXECUTOR",
    Default  = "-- Write your Lua script here...",
    Callback = function(code)
        local fn, err = loadstring(code)
        if fn then pcall(fn) else warn(err) end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  تاب SCRIPTS
-- ══════════════════════════════════════════════════════════════
local scriptsTab = win:AddTab({
    Name = "SCRIPTS",
    Icon = ZeoxLib.Icon.File,
})

local scriptLib = scriptsTab:AddSection({
    Name = "SCRIPT LIBRARY",
    Icon = ZeoxLib.Icon.File,
})

local scripts = {
    { name = "ZeoxClient AutoFarm",  code = "print('AutoFarm')" },
    { name = "Max WalkSpeed",         code = "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed=500" },
    { name = "God Mode",              code = "game.Players.LocalPlayer.Character.Humanoid.MaxHealth=math.huge" },
    { name = "Infinite Jump",         code = "print('InfJump')" },
    { name = "Anti-AFK",              code = "print('AntiAFK')" },
    { name = "Remove Fog",            code = "game.Lighting.FogEnd=100000" },
}

for _, s in ipairs(scripts) do
    scriptLib:AddButton({
        Name     = s.name,
        Icon     = ZeoxLib.Icon.Play,
        Callback = function()
            local fn, err = loadstring(s.code)
            if fn then pcall(fn) else warn(err) end
        end,
    })
end

-- ══════════════════════════════════════════════════════════════
--  تاب SETTINGS
-- ══════════════════════════════════════════════════════════════
local settingsTab = win:AddTab({
    Name = "SETTINGS",
    Icon = ZeoxLib.Icon.Gear,
})

local uiSec = settingsTab:AddSection({
    Name = "UI SETTINGS",
    Icon = ZeoxLib.Icon.Gear,
})

uiSec:AddToggle({ Name = "Blur Background", Icon = ZeoxLib.Icon.Check, Default = false, Callback = function() end })
uiSec:AddToggle({ Name = "Always On Top",   Icon = ZeoxLib.Icon.Check, Default = true,  Callback = function() end })

local aboutSec = settingsTab:AddSection({
    Name = "ABOUT",
    Icon = ZeoxLib.Icon.Info,
})

aboutSec:AddLabel({ Text = "ZEOX CLIENT v1.0.1",    Color = Color3.fromRGB(204,26,26) })
aboutSec:AddLabel({ Text = "UI Library — ZeoxLib v3.0" })
aboutSec:AddLabel({ Text = "Press RightShift to toggle UI" })
aboutSec:AddButton({
    Name     = "Destroy UI",
    Icon     = ZeoxLib.Icon.Trash,
    Callback = function() win:Destroy() end,
})

-- ── زر RightShift لإظهار/إخفاء الـ UI ──────────────────────
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        local gui = game:GetService("CoreGui"):FindFirstChild("ZeoxUI")
                 or game.Players.LocalPlayer.PlayerGui:FindFirstChild("ZeoxUI")
        if gui then gui.Enabled = not gui.Enabled end
    end
end)

win:SetStatus("ATTACHED", true)
