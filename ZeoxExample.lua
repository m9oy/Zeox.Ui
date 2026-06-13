--[[
    ZeoxLib v2.0 — Example Script
    ==============================
    كيف تستخدم المكتبة:

    الطريقة 1 — من executor مباشرة:
        الصق محتوى ZeoxLib.lua في متغير أو استخدم loadstring

    الطريقة 2 — استضف الملف على GitHub وافعل:
        local ZeoxLib = loadstring(game:HttpGet("RAW_GITHUB_URL/ZeoxLib.lua"))()

    الطريقة 3 — داخل Roblox Studio:
        local ZeoxLib = require(script.Parent.ZeoxLib)
]]

-- تحميل المكتبة (عدّل المسار حسب طريقتك)
local ZeoxLib = loadstring(game:HttpGet("https://github.com/m9oy/Zeox.Ui/raw/refs/heads/main/ZeoxLib.lua"))()

-- Services
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local LocalPlayer     = Players.LocalPlayer

-- ============================================================
-- إنشاء النافذة
-- ============================================================
local Window = ZeoxLib:CreateWindow({
    Title   = "ZEOX CLIENT",
    Version = "v1.0.1",
})

-- Asset IDs للأيقونات
local Icons = {
    Home     = "rbxassetid://7733960981",
    Executor = "rbxassetid://7734053495",
    Scripts  = "rbxassetid://7734045250",
    Settings = "rbxassetid://7734036682",
    Refresh  = "rbxassetid://7072720526",
    Bolt     = "rbxassetid://7072722960",
    Arrow    = "rbxassetid://7072716400",
    Runner   = "rbxassetid://7072723416",
    User     = "rbxassetid://7072724501",
    Play     = "rbxassetid://7072719712",
    Trash    = "rbxassetid://7072725052",
    Check    = "rbxassetid://7072716987",
}

-- ============================================================
-- TAB 1: HOME
-- ============================================================
local HomeTab = Window:AddTab({ Name = "HOME", Icon = Icons.Home })

-- ----- قسم FEATURES -----
local Features = HomeTab:AddSection({ Name = "FEATURES", Icon = Icons.Bolt })

-- Auto-Farm
local afConn
local AutoFarm = Features:AddToggle({
    Name = "Auto-Farm", Default = false, Icon = Icons.Refresh,
    Callback = function(on)
        if on then
            afConn = RunService.Heartbeat:Connect(function()
                -- ضع هنا منطق الـ farm
                -- مثال: جمع العملات القريبة
            end)
            Window:SetStatus("AUTO-FARM ON", true)
        else
            if afConn then afConn:Disconnect() end
            Window:SetStatus("ATTACHED", true)
        end
    end,
})

-- Speed Hack
local SpeedHack = Features:AddToggle({
    Name = "Speed Hack", Default = false, Icon = Icons.Bolt,
    Callback = function(on)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = on and 100 or 16 end
        end
    end,
})

-- Infinite Jump
local ijConn
local InfJump = Features:AddToggle({
    Name = "Infinite Jump", Default = false, Icon = Icons.Arrow,
    Callback = function(on)
        if on then
            ijConn = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        else
            if ijConn then ijConn:Disconnect() end
        end
    end,
})

-- ----- قسم PLAYER MODS -----
local PlayerMods = HomeTab:AddSection({ Name = "PLAYER MODS", Icon = Icons.User })

-- WalkSpeed Slider
local WalkSlider = PlayerMods:AddSlider({
    Name = "WalkSpeed", Min = 16, Max = 500, Default = 16,
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end,
})

-- JumpPower Slider
local JumpSlider = PlayerMods:AddSlider({
    Name = "JumpPower", Min = 50, Max = 1000, Default = 50,
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end,
})

-- Noclip
local ncConn
local Noclip = PlayerMods:AddToggle({
    Name = "Noclip", Default = false, Icon = Icons.Runner,
    Callback = function(on)
        if on then
            ncConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if ncConn then ncConn:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
    end,
})

-- ----- قسم TELEPORT -----
local TpSection = HomeTab:AddSection({ Name = "TELEPORT", Icon = Icons.Arrow })

local TpInput = TpSection:AddTextBox({
    Name = "Player Name", Placeholder = "اسم اللاعب...",
})

TpSection:AddButton({
    Name = "Teleport to Player", Icon = Icons.Play,
    Callback = function()
        local name = TpInput:Get()
        local target = Players:FindFirstChild(name)
        if target and target.Character then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tr and mr then
                mr.CFrame = tr.CFrame + Vector3.new(3, 0, 0)
            end
        else
            warn("[Zeox] اللاعب غير موجود:", name)
        end
    end,
})

-- ============================================================
-- TAB 2: EXECUTOR
-- ============================================================
local ExecTab = Window:AddTab({ Name = "EXECUTOR", Icon = Icons.Executor })

local Executor = ExecTab:AddExecutorPanel({
    Title = "EXECUTOR",
    Default = [[-- Zeox Client — Sample Script

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Infinite Jump
local InfiniteJump = true
humanoid.Jumping:Connect(function()
    if InfiniteJump then
        humanoid:ChangeState("Jumping")
    end
end)

-- WalkSpeed
humanoid.WalkSpeed = 100

-- JumpPower
humanoid.JumpPower = 250
]],
    Callback = function(code)
        local fn, err = loadstring(code)
        if fn then
            local ok, runErr = pcall(fn)
            if not ok then warn("[Zeox Exec] Error:", runErr) end
        else
            warn("[Zeox Exec] Syntax error:", err)
        end
    end,
    OnClear = function()
        print("[Zeox] Editor cleared")
    end,
})

-- ============================================================
-- TAB 3: SCRIPTS
-- ============================================================
local ScriptsTab = Window:AddTab({ Name = "SCRIPTS", Icon = Icons.Scripts })

local ScriptLib = ScriptsTab:AddSection({ Name = "SCRIPT LIBRARY", Icon = Icons.Play })

local scripts = {
    { Name = "Max WalkSpeed",  Code = "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 500" },
    { Name = "God Mode",       Code = "local h=game.Players.LocalPlayer.Character.Humanoid; h.MaxHealth=math.huge; h.Health=math.huge" },
    { Name = "Rejoin",         Code = "game:GetService('TeleportService'):Teleport(game.PlaceId,game.Players.LocalPlayer)" },
    { Name = "Anti-AFK",       Code = "local vu=game:GetService('VirtualUser');game.Players.LocalPlayer.Idled:Connect(function()vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)task.wait(1)vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)end)" },
    { Name = "Print NPCs",     Code = "for _,v in pairs(workspace:GetDescendants()) do if v:IsA('Humanoid') then print(v.Parent.Name) end end" },
    { Name = "Remove Fog",     Code = "game.Lighting.FogEnd=100000;game.Lighting.FogStart=0" },
}

for _, s in ipairs(scripts) do
    ScriptLib:AddButton({
        Name = s.Name, Icon = Icons.Play,
        Callback = function()
            local fn, err = loadstring(s.Code)
            if fn then pcall(fn) else warn("[Zeox]", err) end
        end,
    })
end

-- ============================================================
-- TAB 4: SETTINGS
-- ============================================================
local SettingsTab = Window:AddTab({ Name = "SETTINGS", Icon = Icons.Settings })

local UISett = SettingsTab:AddSection({ Name = "UI SETTINGS", Icon = Icons.Check })

UISett:AddToggle({
    Name = "Blur Background", Default = false, Icon = Icons.Check,
    Callback = function(on)
        local b = game.Lighting:FindFirstChild("ZeoxBlur")
        if on then
            if not b then
                local bl = Instance.new("BlurEffect")
                bl.Name = "ZeoxBlur"; bl.Size = 18; bl.Parent = game.Lighting
            end
        else
            if b then b:Destroy() end
        end
    end,
})

local About = SettingsTab:AddSection({ Name = "ABOUT", Icon = Icons.Check })
About:AddLabel({ Text = "ZEOX CLIENT  v1.0.1",       Color = Color3.fromRGB(210,25,25) })
About:AddLabel({ Text = "UI Library — ZeoxLib v2.0", Color = Color3.fromRGB(150,150,170) })
About:AddLabel({ Text = "Press RightShift to toggle UI", Color = Color3.fromRGB(90,90,110) })
About:AddButton({
    Name = "Destroy UI", Icon = Icons.Trash,
    Callback = function() Window:Destroy() end,
})

-- ============================================================
-- مفتاح اختصار: RightShift لإظهار/إخفاء الـ UI
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        local m = Window._main
        if m then m.Visible = not m.Visible end
    end
end)

Window:SetStatus("ATTACHED", true)
print("[ZeoxLib] ✓ Loaded! Press RightShift to toggle.")
