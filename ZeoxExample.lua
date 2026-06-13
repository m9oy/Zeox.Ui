--[[
    ZeoxLib — Example Script
    ========================
    Copy both ZeoxLib.lua and this file into your executor.
    Run ZeoxLib.lua first, then run this file.

    OR use loadstring if you host the library online:

        local ZeoxLib = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

    For local testing inside Roblox Studio, use:
        local ZeoxLib = require(game.ServerScriptService.ZeoxLib)
]]

-- ────────────────────────────────────────────────────────────
--  LOAD THE LIBRARY  (adjust path / loadstring as needed)
-- ────────────────────────────────────────────────────────────
local ZeoxLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/ZeoxLib.lua"))()
-- For Studio / local file: local ZeoxLib = require(script.Parent.ZeoxLib)

-- ────────────────────────────────────────────────────────────
--  SERVICES
-- ────────────────────────────────────────────────────────────
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer
local Character    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid     = Character:WaitForChild("Humanoid")

-- ────────────────────────────────────────────────────────────
--  CREATE WINDOW
-- ────────────────────────────────────────────────────────────
local Window = ZeoxLib:CreateWindow({
    Title   = "ZEOX CLIENT",
    Version = "v1.0.1",
})

-- Icon IDs used for tabs and items
local Icons = {
    Home     = "rbxassetid://7733960981",
    Executor = "rbxassetid://7734053495",
    Scripts  = "rbxassetid://7734045250",
    Settings = "rbxassetid://7734036682",
    Refresh  = "rbxassetid://7072720526",
    Lightning= "rbxassetid://7072722960",
    Arrow    = "rbxassetid://7072716400",
    Run      = "rbxassetid://7072723416",
    User     = "rbxassetid://7072724501",
    Gear     = "rbxassetid://7072721958",
    Play     = "rbxassetid://7072719712",
    Trash    = "rbxassetid://7072725052",
    Check    = "rbxassetid://7072716987",
}

-- ============================================================
--  ░░░  TAB 1 — HOME  ░░░
-- ============================================================
local HomeTab = Window:AddTab({
    Name = "HOME",
    Icon = Icons.Home,
})

-- ── FEATURES section ─────────────────────────────────────────
local Features = HomeTab:AddSection({
    Name = "FEATURES",
    Icon = Icons.Refresh,
})

-- Auto-Farm Toggle
local autoFarmEnabled = false
local autoFarmLoop

local AutoFarm = Features:AddToggle({
    Name     = "Auto-Farm",
    Default  = false,
    Icon     = Icons.Refresh,
    Callback = function(state)
        autoFarmEnabled = state
        if state then
            -- simple auto-farm loop example
            autoFarmLoop = RunService.Heartbeat:Connect(function()
                if not autoFarmEnabled then
                    autoFarmLoop:Disconnect()
                    return
                end
                -- TODO: add your farming logic here
                -- e.g. walk to nearest coin and collect
            end)
            Window:SetStatus("AUTO-FARM ACTIVE", true)
        else
            if autoFarmLoop then autoFarmLoop:Disconnect() end
            Window:SetStatus("ATTACHED", true)
        end
    end,
})

-- Speed Hack Toggle
local SpeedHack = Features:AddToggle({
    Name     = "Speed Hack",
    Default  = false,
    Icon     = Icons.Lightning,
    Callback = function(state)
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state and 100 or 16
        end
    end,
})

-- Infinite Jump Toggle
local infiniteJump = false
local jumpConn

local InfiniteJump = Features:AddToggle({
    Name     = "Infinite Jump",
    Default  = false,
    Icon     = Icons.Arrow,
    Callback = function(state)
        infiniteJump = state
        if state then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                if infiniteJump then
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end)
        else
            if jumpConn then jumpConn:Disconnect() end
        end
    end,
})

-- ── PLAYER MODS section ──────────────────────────────────────
local PlayerMods = HomeTab:AddSection({
    Name = "PLAYER MODS",
    Icon = Icons.User,
})

-- WalkSpeed Slider
local WalkSpeedSlider = PlayerMods:AddSlider({
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 500,
    Default  = 16,
    Suffix   = "",
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end,
})

-- JumpPower Slider
local JumpPowerSlider = PlayerMods:AddSlider({
    Name     = "JumpPower",
    Min      = 50,
    Max      = 1000,
    Default  = 50,
    Suffix   = "",
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end,
})

-- Noclip Toggle
local noclipEnabled = false
local noclipConn

local Noclip = PlayerMods:AddToggle({
    Name     = "Noclip",
    Default  = false,
    Icon     = Icons.Run,
    Callback = function(state)
        noclipEnabled = state
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipEnabled then
                    noclipConn:Disconnect()
                    return
                end
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
            -- restore collision
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

-- ── TELEPORT section ──────────────────────────────────────────
local Teleport = HomeTab:AddSection({
    Name = "TELEPORT",
    Icon = Icons.Lightning,
})

local TpInput = Teleport:AddTextBox({
    Name        = "Player Name",
    Placeholder = "Enter player username...",
})

Teleport:AddButton({
    Name     = "Teleport to Player",
    Icon     = Icons.Play,
    Callback = function()
        local name = TpInput:Get()
        local target = Players:FindFirstChild(name)
        if target and target.Character then
            local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local myChar = LocalPlayer.Character
                if myChar then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.CFrame = rootPart.CFrame + Vector3.new(3, 0, 0)
                    end
                end
            end
        else
            warn("[ZeoxLib] Player not found:", name)
        end
    end,
})

-- ============================================================
--  ░░░  TAB 2 — EXECUTOR  ░░░
-- ============================================================
local ExecutorTab = Window:AddTab({
    Name = "EXECUTOR",
    Icon = Icons.Executor,
})

local Executor = ExecutorTab:AddExecutorPanel({
    Title   = "EXECUTOR",
    Default = [[-- Zeox Client - Sample Script
-- Made for Roblox

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
        -- Execute the code
        local fn, err = loadstring(code)
        if fn then
            local ok, runErr = pcall(fn)
            if not ok then
                warn("[ZeoxLib Executor] Runtime error:", runErr)
            end
        else
            warn("[ZeoxLib Executor] Syntax error:", err)
        end
    end,
    OnClear = function()
        print("[ZeoxLib] Editor cleared")
    end,
})

-- ============================================================
--  ░░░  TAB 3 — SCRIPTS  ░░░
-- ============================================================
local ScriptsTab = Window:AddTab({
    Name = "SCRIPTS",
    Icon = Icons.Scripts,
})

local ScriptLib = ScriptsTab:AddSection({
    Name = "SCRIPT LIBRARY",
    Icon = Icons.Scripts,
})

-- Pre-made script buttons
local scriptList = {
    { Name = "Kill All",        Script = "for _, v in pairs(game.Players:GetPlayers()) do if v ~= game.Players.LocalPlayer then v.Character.Humanoid.Health = 0 end end" },
    { Name = "Rejoin Game",     Script = "game:GetService('TeleportService'):Teleport(game.PlaceId, game.Players.LocalPlayer)" },
    { Name = "Print All NPCs",  Script = "for _, v in pairs(workspace:GetDescendants()) do if v:IsA('Humanoid') then print(v.Parent.Name) end end" },
    { Name = "Max WalkSpeed",   Script = "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 500" },
    { Name = "God Mode",        Script = "game.Players.LocalPlayer.Character.Humanoid.MaxHealth = math.huge; game.Players.LocalPlayer.Character.Humanoid.Health = math.huge" },
    { Name = "Anti-AFK",        Script = "local vrs = game:GetService('VirtualUser'); game:GetService('Players').LocalPlayer.Idled:Connect(function() vrs:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(1) vrs:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)" },
}

for _, s in ipairs(scriptList) do
    ScriptLib:AddButton({
        Name     = s.Name,
        Icon     = Icons.Play,
        Callback = function()
            local fn, err = loadstring(s.Script)
            if fn then pcall(fn) else warn("[ZeoxLib]", err) end
        end,
    })
end

-- ============================================================
--  ░░░  TAB 4 — SETTINGS  ░░░
-- ============================================================
local SettingsTab = Window:AddTab({
    Name = "SETTINGS",
    Icon = Icons.Settings,
})

local UISettings = SettingsTab:AddSection({
    Name = "UI SETTINGS",
    Icon = Icons.Gear,
})

UISettings:AddToggle({
    Name     = "Always On Top",
    Default  = true,
    Icon     = Icons.Check,
    Callback = function(state)
        print("[ZeoxLib] Always on top:", state)
    end,
})

UISettings:AddToggle({
    Name     = "Blur Background",
    Default  = false,
    Icon     = Icons.Check,
    Callback = function(state)
        local blur = game.Lighting:FindFirstChild("ZeoxBlur")
        if state then
            if not blur then
                local b = Instance.new("BlurEffect")
                b.Name = "ZeoxBlur"
                b.Size = 20
                b.Parent = game.Lighting
            end
        else
            if blur then blur:Destroy() end
        end
    end,
})

local PlayerSettings = SettingsTab:AddSection({
    Name = "PLAYER SETTINGS",
    Icon = Icons.User,
})

PlayerSettings:AddToggle({
    Name     = "Show FPS",
    Default  = false,
    Icon     = Icons.Check,
    Callback = function(state)
        -- toggle FPS counter (uses Roblox's built-in shift+F5)
        game:GetService("StarterGui"):SetCore("DevComputerMovementMode", Enum.DevComputerMovementMode.UserChoice)
        print("[ZeoxLib] FPS display:", state)
    end,
})

local About = SettingsTab:AddSection({
    Name = "ABOUT",
    Icon = Icons.Check,
})

About:AddLabel({ Text = "ZEOX CLIENT  v1.0.1",       Color = Color3.fromRGB(220, 30, 30) })
About:AddLabel({ Text = "UI Library by ZeoxLib",      Color = Color3.fromRGB(160, 160, 180) })
About:AddLabel({ Text = "Built for Roblox Executors", Color = Color3.fromRGB(100, 100, 120) })

About:AddButton({
    Name     = "Destroy UI",
    Icon     = Icons.Trash,
    Callback = function()
        Window:Destroy()
    end,
})

-- ────────────────────────────────────────────────────────────
--  KEYBIND  — Toggle UI visibility with RightShift
-- ────────────────────────────────────────────────────────────
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        local main = Window._main
        main.Visible = not main.Visible
    end
end)

-- set initial status
Window:SetStatus("ATTACHED", true)

print("[ZeoxLib] Zeox Client loaded successfully!")
print("[ZeoxLib] Press RightShift to toggle the UI")
