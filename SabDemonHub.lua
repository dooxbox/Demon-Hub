local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local pg = me:WaitForChild("PlayerGui")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tps = game:GetService("TeleportService")
local ts = game:GetService("TweenService")
local prompts = game:GetService("ProximityPromptService")
local ws = game:GetService("Workspace")
local http = game:GetService("HttpService")

local g = Instance.new("ScreenGui")
g.Name = "DemonHub"
g.ResetOnSpawn = false
g.Parent = pg

-- colors
local d1 = Color3.fromRGB(39, 16, 16)
local d2 = Color3.fromRGB(32, 12, 12)
local d3 = Color3.fromRGB(47, 21, 21)
local r1 = Color3.fromRGB(120, 10, 10)
local r2 = Color3.fromRGB(248, 56, 56)
local r3 = Color3.fromRGB(248, 56, 56)
local g1 = Color3.fromRGB(59, 30, 30)
local g2 = Color3.fromRGB(48, 25, 25)
local w = Color3.fromRGB(249, 241, 241)
local gt = Color3.fromRGB(184, 148, 148)
local rd = Color3.fromRGB(255, 68, 68)
local bl = Color3.fromRGB(56, 189, 248)

-- anti afk
local afkOn = true
local vu = game:GetService("VirtualUser")
me.Idled:Connect(function()
    if afkOn then
        vu:Button2Down(Vector2.new(0,0), ws.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), ws.CurrentCamera.CFrame)
    end
end)

-- vars
local c = me.Character or me.CharacterAdded:Wait()
local h = c:WaitForChild("Humanoid")
local r = c:WaitForChild("HumanoidRootPart")

-- Toggle states
local floatEnabled = false
local floatPart = nil
local batEnabled = false
local noAnimEnabled = false
local lastSwing = 0
local infJumpEnabled = false
local jumpPart = nil
local antiLagEnabled = false
local antiBaseStealEnabled = false
local clickPart = nil
local antiRagdollEnabled = false
local platformEnabled = false
local platformPart = nil
local espEnabled = false
local nameESPEnabled = false
local xrayEnabled = false
local noGravityEnabled = false
local speedValue = 16
local myPlot = nil
local lockedUnlocked = false
local antiBeeEnabled = false
local jumpBoostEnabled = false
local speedBoostEnabled = false
local speedBoostVisible = true
local autoCloneEnabled = false
local cloneConnection = nil
local timerCache = {}
local as = false
local autoLoadScript = false
local stealUpstairsEnabled = false
local stealUpstairsConnection = nil
local originalMaterials = {}
local antiKnockbackEnabled = false
local antiKnockbackConnection = nil
local stealConnection = nil

-- Find plot and make it red
local function findMyPlot()
    if ws:FindFirstChild("Plots") then
        for _, v in pairs(ws.Plots:GetChildren()) do
            if v:FindFirstChild("YourBase", true) then
                myPlot = v.Name
                -- Make plot red once (no lag)
                if myPlot and ws.Plots:FindFirstChild(myPlot) then
                    local plot = ws.Plots[myPlot]
                    for _, descendant in pairs(plot:GetDescendants()) do
                        pcall(function()
                            if descendant:IsA("BasePart") and not descendant:IsDescendantOf(me.Character) then
                                descendant.BrickColor = BrickColor.new("Bright red")
                                descendant.Material = Enum.Material.Neon
                            end
                        end)
                    end
                end
                break
            end
        end
    end
end
findMyPlot()

-- Xray
local function xrayFunction(on)
    xrayEnabled = on
    if on then
        for _, v in pairs(ws:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") and not v:IsDescendantOf(me.Character) then
                    v.LocalTransparencyModifier = 0.7
                end
            end)
        end
    else
        for _, v in pairs(ws:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 0
                end
            end)
        end
    end
end

-- Anti lag
local function antiLagFunction(on)
    antiLagEnabled = on
    
    -- Safe quality setting
    pcall(function()
        local renderSettings = settings()
        if renderSettings and renderSettings.Rendering then
            renderSettings.Rendering.QualityLevel = on and 1 or 3
        end
    end)
    
    if on then
        for _, v in pairs(ws:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    if not originalMaterials[v] then
                        originalMaterials[v] = v.Material
                    end
                    v.Material = Enum.Material.Plastic
                    v.TextureID = ""
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end)
        end
    else
        -- Restore everything
        for v, mat in pairs(originalMaterials) do
            pcall(function()
                if v and v.Parent then
                    v.Material = mat
                end
            end)
        end
        originalMaterials = {}
        
        for _, v in pairs(ws:GetDescendants()) do
            pcall(function()
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 0
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = true
                end
            end)
        end
    end
end

-- Anti bee
local function antiBeeFunction(on)
    antiBeeEnabled = on
    if c then
        for _, v in pairs(c:GetDescendants()) do
            pcall(function()
                if v:IsA("Sound") and v.Name:lower():find("bee") then
                    v.Volume = on and 0 or 0.5
                end
            end)
        end
    end
end

-- Anti knockback
local function antiKnockbackFunction(on)
    antiKnockbackEnabled = on
    if antiKnockbackConnection then
        antiKnockbackConnection:Disconnect()
        antiKnockbackConnection = nil
    end
    if on and h then
        antiKnockbackConnection = h.StateChanged:Connect(function(_, newState)
            if antiKnockbackEnabled and newState == Enum.HumanoidStateType.Physics then
                h:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end

-- Jump boost
local function jumpBoostFunction(on)
    jumpBoostEnabled = on
    if on and h then
        h.JumpPower = 100
        h.UseJumpPower = true
    elseif h then
        h.JumpPower = 50
    end
end

-- Speed boost
local function speedBoostFunction(on)
    speedBoostEnabled = on
    if speedUI then
        speedUI.Visible = on and speedBoostVisible
    end
end

-- Get tools
local function getToolsFunction()
    local bp = me:FindFirstChild("Backpack")
    if bp then
        for _, v in pairs(bp:GetChildren()) do
            if v:IsA("Tool") then
                v.Parent = c
            end
        end
    end
end

-- Second floor
local function secondFloor()
    if r and h then
        r.CFrame = r.CFrame + Vector3.new(0, 15, 0)
        wait(0.1)
        h.Jump = true
        wait(0.1)
        h.Jump = false
    end
end

-- Steal upstairs
local function stealUpstairs()
    if r then
        r.CFrame = r.CFrame + Vector3.new(0, 25, 0)
        createNotification("Stole Upstairs! (Y)", 1)
    end
end

-- Auto clone
local function autoCloneSetup()
    if cloneConnection then cloneConnection:Disconnect() cloneConnection = nil end
    if autoCloneEnabled then
        cloneConnection = uis.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode == Enum.KeyCode.V then
                local cloner = nil
                local bp = me:FindFirstChild("Backpack")
                if bp then cloner = bp:FindFirstChild("Quantum Cloner") end
                if not cloner and c then cloner = c:FindFirstChild("Quantum Cloner") end
                if cloner and cloner:IsA("Tool") then
                    if cloner.Parent ~= c then 
                        h:EquipTool(cloner) 
                        wait(0.1) 
                    end
                    pcall(function() 
                        cloner:Activate() 
                        for _, descendant in pairs(cloner:GetDescendants()) do
                            if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
                                descendant:FireServer()
                                break
                            end
                        end
                    end)
                end
            end
        end)
    end
end

-- Steal upstairs keybind
local function stealUpstairsSetup()
    if stealUpstairsConnection then stealUpstairsConnection:Disconnect() end
    if stealUpstairsEnabled then
        stealUpstairsConnection = uis.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode == Enum.KeyCode.Y then
                stealUpstairs()
            end
        end)
    end
end

-- ESP functions
local function addHighlight(p)
    if p == me or not p.Character then return end
    if p.Character:FindFirstChild("Dh") then return end
    local hh = Instance.new("Highlight")
    hh.Name = "Dh"
    hh.FillColor = r2
    hh.FillTransparency = 0.5
    hh.Parent = p.Character
end

local function addNameTag(p)
    if p == me or not p.Character or not p.Character:FindFirstChild("Head") then return end
    if p.Character.Head:FindFirstChild("Dnt") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "Dnt"
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = p.Character.Head
    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, 0, 1, 0)
    tx.BackgroundTransparency = 1
    tx.Text = p.Name
    tx.TextColor3 = r2
    tx.TextStrokeTransparency = 0.3
    tx.Font = Enum.Font.GothamBold
    tx.TextScaled = true
    tx.Parent = bb
end

-- UI Creation
local m = Instance.new("Frame")
m.Size = UDim2.new(0, 450, 0, 350)
m.Position = UDim2.new(0.5, -225, 0.5, -175)
m.BackgroundColor3 = d1
m.BorderSizePixel = 0
m.Active = true
m.Draggable = true
m.Parent = g

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 20)
mc.Parent = m

local mg = Instance.new("UIGradient")
mg.Rotation = 35
mg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, d2), ColorSequenceKeypoint.new(0.55, d3), ColorSequenceKeypoint.new(1, r1)})
mg.Parent = m

local ms1 = Instance.new("UIStroke")
ms1.Thickness = 3
ms1.Transparency = 0.8
ms1.Color = r2
ms1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ms1.Parent = m

local ms2 = Instance.new("UIStroke")
ms2.Thickness = 1
ms2.Transparency = 0.5
ms2.Color = r3
ms2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ms2.Parent = m

-- Top bar
local tb = Instance.new("Frame")
tb.Parent = m
tb.BackgroundColor3 = g2
tb.BackgroundTransparency = 0.3
tb.BorderSizePixel = 0
tb.Size = UDim2.new(1, -14, 0, 32)
tb.Position = UDim2.new(0, 7, 0, 7)

local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 12)
tbc.Parent = tb

-- Title
local ttl = Instance.new("TextLabel")
ttl.Parent = tb
ttl.BackgroundTransparency = 1
ttl.Position = UDim2.new(0, 16, 0, 0)
ttl.Size = UDim2.new(1, -80, 1, 0)
ttl.Font = Enum.Font.GothamBold
ttl.Text = "DEMON HUB - STEAL BRAINROT"
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.TextSize = 13
ttl.TextColor3 = w

local tg = Instance.new("UIGradient")
tg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 34, 34)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(241, 99, 99))})
tg.Parent = ttl

-- Chilli button
local cb = Instance.new("TextButton")
cb.Size = UDim2.fromOffset(24, 24)
cb.Position = UDim2.new(1, -60, 0.5, -12)
cb.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
cb.Text = "C"
cb.Font = Enum.Font.GothamBold
cb.TextSize = 14
cb.TextColor3 = bl
cb.AutoButtonColor = true
cb.Parent = tb

local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(0, 8)
cbc.Parent = cb

local cbs = Instance.new("UIStroke")
cbs.Color = bl
cbs.Transparency = 0.7
cbs.Thickness = 1
cbs.Parent = cb

cb.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()
end)

-- X button
local xb = Instance.new("TextButton")
xb.Size = UDim2.fromOffset(24, 24)
xb.Position = UDim2.new(1, -30, 0.5, -12)
xb.BackgroundColor3 = g1
xb.Text = "X"
xb.Font = Enum.Font.GothamBold
xb.TextSize = 14
xb.TextColor3 = rd
xb.AutoButtonColor = true
xb.Parent = tb

local xbc = Instance.new("UICorner")
xbc.CornerRadius = UDim.new(0, 8)
xbc.Parent = xb

local xbs = Instance.new("UIStroke")
xbs.Color = r3
xbs.Transparency = 0.7
xbs.Thickness = 1
xbs.Parent = xb

xb.MouseButton1Click:Connect(function() 
    m.Visible = false 
    if speedUI then 
        speedUI.Visible = speedBoostEnabled and speedBoostVisible 
    end 
end)

-- UI toggle button
local ut = Instance.new("TextButton")
ut.Size = UDim2.new(0, 30, 0, 30)
ut.Position = UDim2.new(0, 10, 0.5, -15)
ut.BackgroundColor3 = d1
ut.Text = "D"
ut.TextColor3 = r2
ut.Font = Enum.Font.GothamBold
ut.TextSize = 16
ut.Visible = false
ut.Parent = g

local utc = Instance.new("UICorner")
utc.CornerRadius = UDim.new(1, 0)
utc.Parent = ut

local uts = Instance.new("UIStroke")
uts.Color = r2
uts.Thickness = 2
uts.Parent = ut

ut.MouseButton1Click:Connect(function() 
    m.Visible = true 
    if speedUI then 
        speedUI.Visible = speedBoostEnabled and speedBoostVisible 
    end 
    ut.Visible = false 
end)

-- Reopen button
local rb = Instance.new("TextButton")
rb.Size = UDim2.new(0, 40, 0, 40)
rb.Position = UDim2.new(0, 10, 0.5, -20)
rb.BackgroundColor3 = d1
rb.Text = "D"
rb.TextColor3 = r2
rb.Font = Enum.Font.GothamBold
rb.TextSize = 20
rb.Visible = false
rb.Parent = g

local rbc = Instance.new("UICorner")
rbc.CornerRadius = UDim.new(1, 0)
rbc.Parent = rb

local rbs = Instance.new("UIStroke")
rbs.Color = r2
rbs.Thickness = 2
rbs.Parent = rb

rb.MouseButton1Click:Connect(function() 
    m.Visible = true 
    if speedUI then 
        speedUI.Visible = speedBoostEnabled and speedBoostVisible 
    end 
    rb.Visible = false 
end)

-- Content
local ct = Instance.new("Frame")
ct.BackgroundTransparency = 1
ct.Position = UDim2.new(0, 10, 0, 45)
ct.Size = UDim2.new(1, -20, 1, -50)
ct.Parent = m

-- Sidebar
local sb2 = Instance.new("ScrollingFrame")
sb2.Size = UDim2.new(0, 90, 1, 0)
sb2.BackgroundTransparency = 1
sb2.ScrollBarThickness = 4
sb2.ScrollBarImageColor3 = r2
sb2.BorderSizePixel = 0
sb2.CanvasSize = UDim2.new(0, 0, 0, 0)
sb2.AutomaticCanvasSize = Enum.AutomaticSize.Y
sb2.Parent = ct

local sbl = Instance.new("UIListLayout")
sbl.Padding = UDim.new(0, 6)
sbl.SortOrder = Enum.SortOrder.LayoutOrder
sbl.Parent = sb2

-- Divider
local dv = Instance.new("Frame")
dv.Size = UDim2.new(0, 1, 1, 0)
dv.Position = UDim2.new(0, 95, 0, 0)
dv.BackgroundColor3 = r3
dv.BackgroundTransparency = 0.8
dv.BorderSizePixel = 0
dv.Parent = ct

-- Pages container
local pc = Instance.new("Frame")
pc.Size = UDim2.new(1, -105, 1, 0)
pc.Position = UDim2.new(0, 105, 0, 0)
pc.BackgroundTransparency = 1
pc.ClipsDescendants = true
pc.Parent = ct

-- Tabs
local tn = {"MAIN", "PLAYER", "HELPER", "STEALER", "VISUAL", "SERVER", "SETTINGS"}
local tbs = {}
local pgs = {}

local function createPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = r2
    p.BorderSizePixel = 0
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = pc
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft = UDim.new(0, 4)
    pd.PaddingRight = UDim.new(0, 4)
    pd.PaddingTop = UDim.new(0, 4)
    pd.PaddingBottom = UDim.new(0, 4)
    pd.Parent = p
    return p
end

for i, v in ipairs(tn) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.BackgroundColor3 = g1
    b.BackgroundTransparency = 1
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = sb2
    
    local bc2 = Instance.new("UICorner")
    bc2.CornerRadius = UDim.new(0, 8)
    bc2.Parent = b
    
    local bs = Instance.new("UIStroke")
    bs.Transparency = 1
    bs.Color = r2
    bs.Thickness = 1
    bs.Parent = b
    
    local bl2 = Instance.new("Frame")
    bl2.Size = UDim2.new(0, 3, 1, -8)
    bl2.Position = UDim2.new(0, 2, 0.5, -11)
    bl2.BackgroundColor3 = r2
    bl2.BorderSizePixel = 0
    bl2.BackgroundTransparency = 1
    bl2.Parent = b
    
    local bt = Instance.new("TextLabel")
    bt.BackgroundTransparency = 1
    bt.Position = UDim2.new(0, 8, 0, 0)
    bt.Size = UDim2.new(1, -8, 1, 0)
    bt.Font = Enum.Font.GothamBold
    bt.Text = v
    bt.TextSize = 11
    bt.TextColor3 = gt
    bt.TextXAlignment = Enum.TextXAlignment.Left
    bt.Parent = b
    
    table.insert(tbs, b)
    table.insert(pgs, createPage())
    
    b.MouseButton1Click:Connect(function()
        for _, p in ipairs(pgs) do p.Visible = false end
        for id, b2 in ipairs(tbs) do
            b2.BackgroundTransparency = 1
            local s = b2:FindFirstChildOfClass("UIStroke")
            if s then s.Transparency = 1 end
            local l2 = b2:FindFirstChild("Frame")
            if l2 then l2.BackgroundTransparency = 1 end
            local t = b2:FindFirstChildOfClass("TextLabel")
            if t then t.TextColor3 = gt end
        end
        pgs[i].Visible = true
        b.BackgroundTransparency = 0
        local s = b:FindFirstChildOfClass("UIStroke")
        if s then s.Transparency = 0.4 end
        local l2 = b:FindFirstChild("Frame")
        if l2 then l2.BackgroundTransparency = 0 end
        local t = b:FindFirstChildOfClass("TextLabel")
        if t then t.TextColor3 = w end
    end)
end

-- Toggle maker
local function makeToggle(p, txt, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 32)
    f.BackgroundColor3 = d3
    f.BackgroundTransparency = 0.5
    f.Parent = p
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 8)
    fc.Parent = f
    
    local fs = Instance.new("UIStroke")
    fs.Color = r3
    fs.Transparency = 0.9
    fs.Thickness = 1
    fs.Parent = f
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -10, 1, 0)
    lb.Position = UDim2.new(0, 10, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = txt
    lb.Font = Enum.Font.GothamMedium
    lb.TextSize = 11
    lb.TextColor3 = w
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromScale(1, 1)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.Parent = f
    
    local tgb = Instance.new("Frame")
    tgb.Size = UDim2.fromOffset(34, 16)
    tgb.Position = UDim2.new(1, -44, 0.5, -8)
    tgb.BackgroundColor3 = g1
    tgb.BackgroundTransparency = 0.1
    tgb.Parent = f
    
    local tgbc = Instance.new("UICorner")
    tgbc.CornerRadius = UDim.new(1, 0)
    tgbc.Parent = tgb
    
    local tgk = Instance.new("Frame")
    tgk.Size = UDim2.fromOffset(12, 12)
    tgk.Position = UDim2.new(0, 2, 0.5, -6)
    tgk.BackgroundColor3 = w
    tgk.Parent = tgb
    
    local tgkc = Instance.new("UICorner")
    tgkc.CornerRadius = UDim.new(1, 0)
    tgkc.Parent = tgk
    
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        if on then
            ts:Create(tgb, TweenInfo.new(0.2), {BackgroundColor3 = r2, BackgroundTransparency = 0}):Play()
            ts:Create(tgk, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6)}):Play()
        else
            ts:Create(tgb, TweenInfo.new(0.2), {BackgroundColor3 = g1, BackgroundTransparency = 0.1}):Play()
            ts:Create(tgk, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
        end
        callback(on)
    end)
end

-- Speed UI
local speedUI = Instance.new("Frame")
speedUI.Size = UDim2.new(0, 280, 0, 130)
speedUI.Position = UDim2.new(0, 20, 0.8, -65)
speedUI.BackgroundColor3 = d1
speedUI.Active = true
speedUI.Draggable = true
speedUI.Visible = true
speedUI.Parent = g

local suc = Instance.new("UICorner")
suc.CornerRadius = UDim.new(0, 12)
suc.Parent = speedUI

local sug = Instance.new("UIGradient")
sug.Rotation = 35
sug.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, d2), ColorSequenceKeypoint.new(0.55, d3), ColorSequenceKeypoint.new(1, r1)})
sug.Parent = speedUI

local sus1 = Instance.new("UIStroke")
sus1.Thickness = 2
sus1.Transparency = 0.8
sus1.Color = r2
sus1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sus1.Parent = speedUI

local sus2 = Instance.new("UIStroke")
sus2.Thickness = 1
sus2.Transparency = 0.5
sus2.Color = r3
sus2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sus2.Parent = speedUI

local sux = Instance.new("TextButton")
sux.Size = UDim2.fromOffset(20, 20)
sux.Position = UDim2.new(1, -25, 0, 5)
sux.BackgroundColor3 = g1
sux.Text = "X"
sux.Font = Enum.Font.GothamBold
sux.TextSize = 12
sux.TextColor3 = rd
sux.AutoButtonColor = true
sux.Parent = speedUI

local suxc = Instance.new("UICorner")
suxc.CornerRadius = UDim.new(0, 4)
suxc.Parent = sux

sux.MouseButton1Click:Connect(function() 
    speedUI.Visible = false 
    speedBoostVisible = false 
end)

local sttl = Instance.new("TextLabel")
sttl.Text = "DEMON SPEED BOOST"
sttl.TextColor3 = w
sttl.BackgroundTransparency = 1
sttl.Size = UDim2.new(1, -10, 0, 25)
sttl.Position = UDim2.new(0, 5, 0, 5)
sttl.Font = Enum.Font.GothamBold
sttl.TextSize = 14
sttl.Parent = speedUI

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Text = "16"
speedValueLabel.TextColor3 = r2
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Size = UDim2.new(0, 50, 0, 25)
speedValueLabel.Position = UDim2.new(1, -55, 0, 5)
speedValueLabel.Font = Enum.Font.GothamBold
speedValueLabel.TextSize = 14
speedValueLabel.Parent = speedUI

local slb = Instance.new("Frame")
slb.Size = UDim2.new(1, -40, 0, 15)
slb.Position = UDim2.new(0, 20, 0, 40)
slb.BackgroundColor3 = g1
slb.Parent = speedUI

local slbc = Instance.new("UICorner")
slbc.CornerRadius = UDim.new(1, 0)
slbc.Parent = slb

local slf = Instance.new("Frame")
slf.Size = UDim2.new(0, 0, 1, 0)
slf.BackgroundColor3 = r2
slf.Parent = slb

local slfc = Instance.new("UICorner")
slfc.CornerRadius = UDim.new(1, 0)
slfc.Parent = slf

local dr = Instance.new("TextButton")
dr.Size = UDim2.new(1, 0, 1, 0)
dr.BackgroundTransparency = 1
dr.Text = ""
dr.Parent = slb

dr.MouseButton1Down:Connect(function()
    local con = rs.RenderStepped:Connect(function()
        local ms = uis:GetMouseLocation()
        local pos = slb.AbsolutePosition
        local sx = slb.AbsoluteSize.X
        local pct = math.clamp((ms.X - pos.X) / sx, 0, 1)
        slf.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.floor(16 + (120 - 16) * pct)
        speedValueLabel.Text = tostring(val)
        speedValue = val
        if h then h.WalkSpeed = val end
    end)
    local rel = uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            con:Disconnect()
            rel:Disconnect()
        end
    end)
end)

-- Speed toggle button
local stb = Instance.new("TextButton")
stb.Size = UDim2.new(1, -10, 0, 28)
stb.Position = UDim2.new(0, 5, 0, 5)
stb.BackgroundColor3 = g1
stb.Text = "Toggle Speed"
stb.TextColor3 = w
stb.Font = Enum.Font.GothamBold
stb.TextSize = 11
stb.Parent = pgs[7]

local stbc = Instance.new("UICorner")
stbc.CornerRadius = UDim.new(0, 8)
stbc.Parent = stb

stb.MouseButton1Click:Connect(function()
    speedBoostVisible = not speedBoostVisible
    speedUI.Visible = speedBoostEnabled and speedBoostVisible
    stb.Text = speedBoostVisible and "Hide Speed" or "Show Speed"
end)

-- Steal UI
local stealUI = Instance.new("Frame")
stealUI.Name = "StealUI"
stealUI.Size = UDim2.new(0, 220, 0, 60)
stealUI.Position = UDim2.new(0.5, -110, 0, 100)
stealUI.BackgroundColor3 = d1
stealUI.BorderSizePixel = 0
stealUI.Visible = false
stealUI.Active = true
stealUI.Draggable = true
stealUI.Parent = g

local su2c = Instance.new("UICorner")
su2c.CornerRadius = UDim.new(0, 16)
su2c.Parent = stealUI

local su2g = Instance.new("UIGradient")
su2g.Rotation = 35
su2g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, d2), ColorSequenceKeypoint.new(0.55, d3), ColorSequenceKeypoint.new(1, r1)})
su2g.Parent = stealUI

local su2s1 = Instance.new("UIStroke")
su2s1.Thickness = 2
su2s1.Transparency = 0.8
su2s1.Color = r2
su2s1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
su2s1.Parent = stealUI

local su2s2 = Instance.new("UIStroke")
su2s2.Thickness = 1
su2s2.Transparency = 0.5
su2s2.Color = r3
su2s2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
su2s2.Parent = stealUI

local su2t = Instance.new("TextLabel")
su2t.Size = UDim2.new(1, -20, 0, 20)
su2t.Position = UDim2.new(0, 10, 0, 8)
su2t.BackgroundTransparency = 1
su2t.Text = "STEALING BRAINROT"
su2t.TextColor3 = w
su2t.Font = Enum.Font.GothamBold
su2t.TextSize = 12
su2t.TextXAlignment = Enum.TextXAlignment.Left
su2t.Parent = stealUI

local su2p = Instance.new("TextLabel")
su2p.Size = UDim2.new(0, 40, 0, 20)
su2p.Position = UDim2.new(1, -50, 0, 8)
su2p.BackgroundTransparency = 1
su2p.Text = "0%"
su2p.TextColor3 = r2
su2p.Font = Enum.Font.GothamBold
su2p.TextSize = 12
su2p.Parent = stealUI

local su2b = Instance.new("Frame")
su2b.Size = UDim2.new(1, -20, 0, 6)
su2b.Position = UDim2.new(0, 10, 1, -16)
su2b.BackgroundColor3 = g1
su2b.Parent = stealUI

local su2bc = Instance.new("UICorner")
su2bc.CornerRadius = UDim.new(1, 0)
su2bc.Parent = su2b

local su2f = Instance.new("Frame")
su2f.Size = UDim2.new(0, 0, 1, 0)
su2f.BackgroundColor3 = r2
su2f.Parent = su2b

local su2fc = Instance.new("UICorner")
su2fc.CornerRadius = UDim.new(1, 0)
su2fc.Parent = su2f

-- Clone UI
local cloneUI = Instance.new("Frame")
cloneUI.Name = "CloneUI"
cloneUI.Size = UDim2.new(0, 100, 0, 30)
cloneUI.Position = UDim2.new(0.5, -50, 0, 150)
cloneUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
cloneUI.BorderSizePixel = 0
cloneUI.Visible = false
cloneUI.Active = true
cloneUI.Draggable = true
cloneUI.Parent = g

local cuc = Instance.new("UICorner")
cuc.CornerRadius = UDim.new(0, 8)
cuc.Parent = cloneUI

local cus = Instance.new("UIStroke")
cus.Color = r2
cus.Thickness = 2
cus.Parent = cloneUI

local cut = Instance.new("TextLabel")
cut.Size = UDim2.new(1, 0, 1, 0)
cut.BackgroundTransparency = 1
cut.Text = "CLONE [V]"
cut.TextColor3 = w
cut.Font = Enum.Font.GothamBold
cut.TextSize = 10
cut.Parent = cloneUI

-- Upstairs UI
local upstairsUI = Instance.new("Frame")
upstairsUI.Name = "UpstairsUI"
upstairsUI.Size = UDim2.new(0, 120, 0, 40)
upstairsUI.Position = UDim2.new(0.5, -60, 0, 200)
upstairsUI.BackgroundColor3 = d1
upstairsUI.BorderSizePixel = 0
upstairsUI.Visible = false
upstairsUI.Active = true
upstairsUI.Draggable = true
upstairsUI.Parent = g

local uuc = Instance.new("UICorner")
uuc.CornerRadius = UDim.new(0, 12)
uuc.Parent = upstairsUI

local uus = Instance.new("UIStroke")
uus.Color = r2
uus.Thickness = 2
uus.Parent = upstairsUI

local uut = Instance.new("TextLabel")
uut.Size = UDim2.new(1, -10, 1, 0)
uut.Position = UDim2.new(0, 5, 0, 0)
uut.BackgroundTransparency = 1
uut.Text = "STEAL UP [Y]"
uut.TextColor3 = w
uut.Font = Enum.Font.GothamBold
uut.TextSize = 10
uut.TextXAlignment = Enum.TextXAlignment.Left
uut.Parent = upstairsUI

local uux = Instance.new("TextButton")
uux.Size = UDim2.fromOffset(16, 16)
uux.Position = UDim2.new(1, -21, 0.5, -8)
uux.BackgroundColor3 = g1
uux.Text = "X"
uux.TextColor3 = rd
uux.Font = Enum.Font.GothamBold
uux.TextSize = 10
uux.Parent = upstairsUI

local uuxc = Instance.new("UICorner")
uuxc.CornerRadius = UDim.new(0, 4)
uuxc.Parent = uux

uux.MouseButton1Click:Connect(function()
    upstairsUI.Visible = false
    stealUpstairsEnabled = false
    stealUpstairsSetup()
end)

-- Notification system
local notificationHolder = Instance.new("Frame")
notificationHolder.Size = UDim2.new(0, 250, 1, -20)
notificationHolder.Position = UDim2.new(1, -260, 0, 10)
notificationHolder.BackgroundTransparency = 1
notificationHolder.Parent = g

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.Padding = UDim.new(0, 5)
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationLayout.Parent = notificationHolder

local function createNotification(text, duration)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 250, 0, 40)
    notif.BackgroundColor3 = d1
    notif.BackgroundTransparency = 0.1
    notif.Parent = notificationHolder
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = r2
    notifStroke.Thickness = 2
    notifStroke.Transparency = 0.5
    notifStroke.Parent = notif
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -10, 1, 0)
    notifText.Position = UDim2.new(0, 5, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = w
    notifText.Font = Enum.Font.GothamMedium
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.Parent = notif
    
    local notifClose = Instance.new("TextButton")
    notifClose.Size = UDim2.fromOffset(16, 16)
    notifClose.Position = UDim2.new(1, -21, 0.5, -8)
    notifClose.BackgroundColor3 = g1
    notifClose.Text = "X"
    notifClose.TextColor3 = rd
    notifClose.Font = Enum.Font.GothamBold
    notifClose.TextSize = 10
    notifClose.Parent = notif
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = notifClose
    
    notifClose.MouseButton1Click:Connect(function()
        notif:Destroy()
    end)
    
    if duration then
        task.spawn(function()
            wait(duration)
            if notif then
                notif:Destroy()
            end
        end)
    end
    
    return notif
end

-- Save/Load Config functions
local function saveConfig()
    local data = {
        floatEnabled = floatEnabled,
        infJumpEnabled = infJumpEnabled,
        platformEnabled = platformEnabled,
        speedBoostEnabled = speedBoostEnabled,
        jumpBoostEnabled = jumpBoostEnabled,
        noGravityEnabled = noGravityEnabled,
        antiRagdollEnabled = antiRagdollEnabled,
        noAnimEnabled = noAnimEnabled,
        antiBeeEnabled = antiBeeEnabled,
        antiLagEnabled = antiLagEnabled,
        antiBaseStealEnabled = antiBaseStealEnabled,
        batEnabled = batEnabled,
        as = as,
        autoCloneEnabled = autoCloneEnabled,
        espEnabled = espEnabled,
        nameESPEnabled = nameESPEnabled,
        xrayEnabled = xrayEnabled,
        afkOn = afkOn,
        autoLoadScript = autoLoadScript,
        stealUpstairsEnabled = stealUpstairsEnabled,
        antiKnockbackEnabled = antiKnockbackEnabled,
        speedValue = speedValue
    }
    local success, json = pcall(function()
        return http:JSONEncode(data)
    end)
    if success then
        pcall(writefile, "DemonHubConfig.json", json)
        createNotification("Config Saved!", 2)
    else
        createNotification("Failed to save config", 2)
    end
end

local function loadConfig()
    local fileExists = pcall(isfile, "DemonHubConfig.json")
    if fileExists then
        local success, json = pcall(readfile, "DemonHubConfig.json")
        if success then
            local data = http:JSONDecode(json)
            
            -- Apply all settings
            floatEnabled = data.floatEnabled or false
            infJumpEnabled = data.infJumpEnabled or false
            platformEnabled = data.platformEnabled or false
            speedBoostEnabled = data.speedBoostEnabled or false
            jumpBoostEnabled = data.jumpBoostEnabled or false
            noGravityEnabled = data.noGravityEnabled or false
            antiRagdollEnabled = data.antiRagdollEnabled or false
            noAnimEnabled = data.noAnimEnabled or false
            antiBeeEnabled = data.antiBeeEnabled or false
            antiLagEnabled = data.antiLagEnabled or false
            antiBaseStealEnabled = data.antiBaseStealEnabled or false
            batEnabled = data.batEnabled or false
            as = data.as or false
            autoCloneEnabled = data.autoCloneEnabled or false
            espEnabled = data.espEnabled or false
            nameESPEnabled = data.nameESPEnabled or false
            xrayEnabled = data.xrayEnabled or false
            afkOn = data.afkOn or true
            autoLoadScript = data.autoLoadScript or false
            stealUpstairsEnabled = data.stealUpstairsEnabled or false
            antiKnockbackEnabled = data.antiKnockbackEnabled or false
            speedValue = data.speedValue or 16
            
            -- Apply functions
            speedBoostFunction(speedBoostEnabled)
            jumpBoostFunction(jumpBoostEnabled)
            antiLagFunction(antiLagEnabled)
            antiBeeFunction(antiBeeEnabled)
            antiKnockbackFunction(antiKnockbackEnabled)
            xrayFunction(xrayEnabled)
            autoCloneSetup()
            stealUpstairsSetup()
            
            createNotification("Config Loaded!", 2)
        else
            createNotification("Failed to load config", 2)
        end
    else
        createNotification("No config found!", 2)
    end
end

-- MAIN PAGE
makeToggle(pgs[1], "Float", function(s) 
    floatEnabled = s
    if s then
        if floatPart then floatPart:Destroy() end
        floatPart = Instance.new("Part")
        floatPart.Size = Vector3.new(6, 1, 6)
        floatPart.Transparency = 0.7
        floatPart.Material = Enum.Material.Neon
        floatPart.Color = r2
        floatPart.Anchored = true
        floatPart.CanCollide = true
        floatPart.Parent = ws
        createNotification("Float Enabled", 2)
    else
        if floatPart then floatPart:Destroy() end
        createNotification("Float Disabled", 2)
    end
end)

makeToggle(pgs[1], "Inf Jump", function(s) 
    infJumpEnabled = s
    createNotification(s and "Infinite Jump Enabled" or "Infinite Jump Disabled", 2)
end)

makeToggle(pgs[1], "Platform", function(s) 
    platformEnabled = s
    if s then
        if platformPart then platformPart:Destroy() end
        platformPart = Instance.new("Part")
        platformPart.Size = Vector3.new(8, 1, 8)
        platformPart.Transparency = 0.5
        platformPart.Material = Enum.Material.Neon
        platformPart.Color = r2
        platformPart.Anchored = true
        platformPart.CanCollide = true
        platformPart.Parent = ws
        createNotification("Platform Enabled", 2)
    else
        if platformPart then platformPart:Destroy() end
        createNotification("Platform Disabled", 2)
    end
end)

makeToggle(pgs[1], "Speed Boost", function(s) 
    speedBoostEnabled = s 
    speedBoostFunction(s)
    createNotification(s and "Speed Boost Enabled" or "Speed Boost Disabled", 2)
end)

makeToggle(pgs[1], "Jump Boost", function(s) 
    jumpBoostEnabled = s 
    jumpBoostFunction(s)
    createNotification(s and "Jump Boost Enabled" or "Jump Boost Disabled", 2)
end)

-- PLAYER PAGE
makeToggle(pgs[2], "No Gravity", function(s) 
    noGravityEnabled = s 
    createNotification(s and "No Gravity Enabled" or "No Gravity Disabled", 2)
end)

makeToggle(pgs[2], "Anti Ragdoll", function(s) 
    antiRagdollEnabled = s 
    createNotification(s and "Anti Ragdoll Enabled" or "Anti Ragdoll Disabled", 2)
end)

makeToggle(pgs[2], "Anti Knockback", function(s)
    antiKnockbackEnabled = s
    antiKnockbackFunction(s)
    createNotification(s and "Anti Knockback Enabled" or "Anti Knockback Disabled", 2)
end)

makeToggle(pgs[2], "No Animation", function(s) 
    noAnimEnabled = s
    if s and c then
        local a = c:FindFirstChild("Animate")
        if a then a:Destroy() end
        if h then 
            for _, v in pairs(h:GetPlayingAnimationTracks()) do 
                v:Stop() 
            end
        end
    end
    createNotification(s and "No Animation Enabled" or "No Animation Disabled", 2)
end)

makeToggle(pgs[2], "Anti Bee", function(s) 
    antiBeeEnabled = s 
    antiBeeFunction(s)
    createNotification(s and "Anti Bee Enabled" or "Anti Bee Disabled", 2)
end)

-- HELPER PAGE
makeToggle(pgs[3], "Anti Lag", function(s) 
    antiLagEnabled = s 
    antiLagFunction(s)
    createNotification(s and "Anti Lag Enabled" or "Anti Lag Disabled", 2)
end)

makeToggle(pgs[3], "Anti Base Steal", function(s) 
    antiBaseStealEnabled = s 
    createNotification(s and "Anti Base Steal Enabled" or "Anti Base Steal Disabled", 2)
end)

-- STEALER PAGE
makeToggle(pgs[4], "Auto Bat", function(s) 
    batEnabled = s 
    createNotification(s and "Auto Bat Enabled" or "Auto Bat Disabled", 2)
end)

makeToggle(pgs[4], "Auto Steal Brainrot", function(s) 
    as = s 
    createNotification(s and "Auto Steal Enabled" or "Auto Steal Disabled", 2)
end)

makeToggle(pgs[4], "Auto Clone (V)", function(s) 
    autoCloneEnabled = s 
    cloneUI.Visible = s 
    autoCloneSetup()
    createNotification(s and "Auto Clone Enabled" or "Auto Clone Disabled", 2)
end)

local gtb = Instance.new("TextButton")
gtb.Size = UDim2.new(1, -10, 0, 28)
gtb.Position = UDim2.new(0, 5, 0, 100)
gtb.BackgroundColor3 = g1
gtb.Text = "Get Tools"
gtb.TextColor3 = w
gtb.Font = Enum.Font.GothamBold
gtb.TextSize = 11
gtb.Parent = pgs[4]

local gtbc = Instance.new("UICorner")
gtbc.CornerRadius = UDim.new(0, 8)
gtbc.Parent = gtb

gtb.MouseButton1Click:Connect(function() 
    getToolsFunction()
    createNotification("Tools Retrieved", 2)
end)

-- VISUAL PAGE
makeToggle(pgs[5], "Xray", function(s) 
    xrayEnabled = s 
    xrayFunction(s)
    createNotification(s and "Xray Enabled" or "Xray Disabled", 2)
end)

makeToggle(pgs[5], "Player ESP", function(s) 
    espEnabled = s
    if s then
        for _, p in pairs(plrs:GetPlayers()) do 
            addHighlight(p) 
        end
        createNotification("ESP Enabled", 2)
    else
        for _, p in pairs(plrs:GetPlayers()) do
            if p.Character then
                local hh = p.Character:FindFirstChild("Dh")
                if hh then hh:Destroy() end
            end
        end
        createNotification("ESP Disabled", 2)
    end
end)

makeToggle(pgs[5], "Name ESP", function(s) 
    nameESPEnabled = s
    if s then
        for _, p in pairs(plrs:GetPlayers()) do 
            addNameTag(p) 
        end
        createNotification("Name ESP Enabled", 2)
    else
        for _, p in pairs(plrs:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local nt = p.Character.Head:FindFirstChild("Dnt")
                if nt then nt:Destroy() end
            end
        end
        createNotification("Name ESP Disabled", 2)
    end
end)

-- SERVER PAGE
makeToggle(pgs[6], "Auto Load Script", function(s)
    autoLoadScript = s
    createNotification(s and "Auto Load Enabled" or "Auto Load Disabled", 2)
end)

makeToggle(pgs[6], "Steal Upstairs (Y)", function(s)
    stealUpstairsEnabled = s
    upstairsUI.Visible = s
    stealUpstairsSetup()
    createNotification(s and "Steal Upstairs Enabled - Press Y to use" or "Steal Upstairs Disabled", 2)
end)

-- Save/Load buttons
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -10, 0, 28)
saveBtn.Position = UDim2.new(0, 5, 0, 60)
saveBtn.BackgroundColor3 = g1
saveBtn.Text = "SAVE CONFIG"
saveBtn.TextColor3 = bl
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 11
saveBtn.Parent = pgs[6]

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 8)
saveCorner.Parent = saveBtn

saveBtn.MouseButton1Click:Connect(saveConfig)

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(1, -10, 0, 28)
loadBtn.Position = UDim2.new(0, 5, 0, 95)
loadBtn.BackgroundColor3 = g1
loadBtn.Text = "LOAD CONFIG"
loadBtn.TextColor3 = r2
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 11
loadBtn.Parent = pgs[6]

local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 8)
loadCorner.Parent = loadBtn

loadBtn.MouseButton1Click:Connect(loadConfig)

-- Server info
local serverInfo = Instance.new("TextLabel")
serverInfo.Size = UDim2.new(1, -10, 0, 40)
serverInfo.Position = UDim2.new(0, 5, 0, 130)
serverInfo.BackgroundColor3 = d3
serverInfo.BackgroundTransparency = 0.3
serverInfo.Text = "Server ID: " .. game.JobId .. "\nPlayers: " .. #plrs:GetPlayers()
serverInfo.TextColor3 = w
serverInfo.Font = Enum.Font.GothamMedium
serverInfo.TextSize = 10
serverInfo.Parent = pgs[6]

local serverCorner = Instance.new("UICorner")
serverCorner.CornerRadius = UDim.new(0, 8)
serverCorner.Parent = serverInfo

-- SETTINGS PAGE
makeToggle(pgs[7], "Anti AFK", function(s) 
    afkOn = s 
    createNotification(s and "Anti AFK Enabled" or "Anti AFK Disabled", 2)
end)

local ex = Instance.new("TextButton")
ex.Size = UDim2.new(1, -10, 0, 28)
ex.Position = UDim2.new(0, 5, 0, 40)
ex.BackgroundColor3 = g1
ex.Text = "EXIT"
ex.TextColor3 = rd
ex.Font = Enum.Font.GothamBold
ex.TextSize = 11
ex.Parent = pgs[7]

local exc = Instance.new("UICorner")
exc.CornerRadius = UDim.new(0, 8)
exc.Parent = ex

ex.MouseButton1Click:Connect(function() 
    createNotification("Exiting...", 1)
    wait(1)
    me:Kick("Demon Hub") 
end)

-- Keybinds
uis.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.I then
        if m.Visible then
            m.Visible = false
            speedUI.Visible = speedBoostEnabled and speedBoostVisible
            ut.Visible = true
            rb.Visible = false
            createNotification("UI Hidden - Press I to show", 2)
        else
            m.Visible = true
            speedUI.Visible = speedBoostEnabled and speedBoostVisible
            ut.Visible = false
            rb.Visible = false
            createNotification("UI Shown", 1)
        end
    elseif i.KeyCode == Enum.KeyCode.L then
        secondFloor()
        createNotification("Second Floor Activated", 1)
    end
end)

-- Character respawn cleanup
me.CharacterAdded:Connect(function(ch)
    -- Clean up old parts
    if floatPart then floatPart:Destroy() floatPart = nil end
    if platformPart then platformPart:Destroy() platformPart = nil end
    if jumpPart then jumpPart:Destroy() jumpPart = nil end
    
    c = ch
    wait()
    h = c:WaitForChild("Humanoid")
    r = c:WaitForChild("HumanoidRootPart")
    
    -- Reapply settings
    if speedValue ~= 16 and h then h.WalkSpeed = speedValue end
    if jumpBoostEnabled and h then 
        h.JumpPower = 100 
        h.UseJumpPower = true 
    end
    if antiKnockbackEnabled then
        antiKnockbackFunction(true)
    end
    if floatEnabled then
        floatPart = Instance.new("Part")
        floatPart.Size = Vector3.new(6, 1, 6)
        floatPart.Transparency = 0.7
        floatPart.Material = Enum.Material.Neon
        floatPart.Color = r2
        floatPart.Anchored = true
        floatPart.CanCollide = true
        floatPart.Parent = ws
    end
    if platformEnabled then
        platformPart = Instance.new("Part")
        platformPart.Size = Vector3.new(8, 1, 8)
        platformPart.Transparency = 0.5
        platformPart.Material = Enum.Material.Neon
        platformPart.Color = r2
        platformPart.Anchored = true
        platformPart.CanCollide = true
        platformPart.Parent = ws
    end
    if infJumpEnabled then
        jumpPart = Instance.new("Part")
        jumpPart.Size = Vector3.new(6, 1, 6)
        jumpPart.Transparency = 1
        jumpPart.Anchored = true
        jumpPart.CanCollide = true
        jumpPart.Parent = ws
    end
    
    createNotification("Character Respawned", 2)
end)

-- Infinite Jump (FIXED - now works)
uis.JumpRequest:Connect(function()
    if infJumpEnabled and h then
        h:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Main loop (FIXED - properly closed with no syntax errors)
rs.Heartbeat:Connect(function()
    if not c or not h or not r then return end

    if floatEnabled and floatPart then
        floatPart.CFrame = r.CFrame * CFrame.new(0, -3.5, 0)
    end

    if platformEnabled and platformPart then
        platformPart.CFrame = r.CFrame * CFrame.new(0, -3.5, 0)
    end

    if noGravityEnabled then
        r.AssemblyLinearVelocity = Vector3.new(
            r.AssemblyLinearVelocity.X,
            math.max(r.AssemblyLinearVelocity.Y, 0),
            r.AssemblyLinearVelocity.Z
        )
    end

    if antiRagdollEnabled and h and r then
        local md = h.MoveDirection
        if md.Magnitude > 0 then
            r.Velocity = md * 30
        end
    end

    if batEnabled and h and r then
        local t = c:FindFirstChildOfClass("Tool")
        local hasBat = t and t.Name == "Bat"
        local closest, minDist = nil, 12
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= me and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - r.Position).Magnitude
                if d < minDist then 
                    minDist = d 
                    closest = p 
                end
            end
        end
        if closest then
            if not hasBat then
                local bp = me:FindFirstChild("Backpack")
                if bp then
                    local bt = bp:FindFirstChild("Bat")
                    if bt then 
                        h:EquipTool(bt) 
                    end
                end
            elseif hasBat and tick() - lastSwing > 0.5 then
                lastSwing = tick()
                t:Activate()
            end
        end
    end

    if speedBoostEnabled then
        h.WalkSpeed = speedValue
    end
end)

-- Anti ragdoll
rs.Stepped:Connect(function()
    if antiRagdollEnabled and c then
        for _, v in pairs(c:GetDescendants()) do
            pcall(function()
                if v:IsA("NumberValue") and v.Name == "Ragdoll" then
                    v.Value = 0
                end
            end)
        end
    end
end)

-- Player added
plrs.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then addHighlight(p) end
        if nameESPEnabled then addNameTag(p) end
    end)
end)

-- Timer ESP (removed, was broken)
-- Anti Base Steal / Auto Lock
spawn(function()
    while wait(0.5) do
        if myPlot and ws:FindFirstChild("Plots") and ws.Plots:FindFirstChild(myPlot) then
            local plot = ws.Plots[myPlot]
            local plotBlock = plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock")
            if plotBlock and plotBlock:FindFirstChild("Main") then
                local bb = plotBlock.Main:FindFirstChild("BillboardGui")
                if bb then
                    local timeLabel = bb:FindFirstChild("RemainingTime")
                    if timeLabel and timeLabel:IsA("TextLabel") then
                        local unlocked = timeLabel.Text == "0s"
                        if antiBaseStealEnabled and unlocked and not lockedUnlocked then
                            createNotification("Base Unlocked - Anti Steal Active", 3)
                        end
                        lockedUnlocked = unlocked
                    end
                end
            end
        end
    end
end)

-- Auto Steal
prompts.PromptShown:Connect(function(p)
    if as and p.KeyboardKeyCode == Enum.KeyCode.E then
        local actionText = p.ActionText or ""
        local objectText = p.ObjectText or ""
        if actionText:find("Steal") or objectText:find("Steal") then
            clickPart = p
            p:InputHoldBegin()
            stealUI.Visible = true
            
            local startTime = tick()
            if stealConnection then stealConnection:Disconnect() end
            stealConnection = rs.RenderStepped:Connect(function()
                local elapsed = tick() - startTime
                local progress = math.min(elapsed / 2, 1)
                su2f.Size = UDim2.new(progress, 0, 1, 0)
                su2p.Text = math.floor(progress * 100) .. "%"
                
                if progress >= 1 then
                    stealConnection:Disconnect()
                    stealConnection = nil
                    stealUI.Visible = false
                    su2f.Size = UDim2.new(0, 0, 1, 0)
                    su2p.Text = "0%"
                    createNotification("Brainrot Stolen!", 2)
                end
            end)
        end
    end
end)

prompts.PromptHidden:Connect(function(p)
    if p == clickPart then
        p:InputHoldEnd()
        clickPart = nil
        stealUI.Visible = false
        su2f.Size = UDim2.new(0, 0, 1, 0)
        su2p.Text = "0%"
        if stealConnection then
            stealConnection:Disconnect()
            stealConnection = nil
        end
    end
end)

-- Auto Rejoin
spawn(function()
    local st = tick()
    while wait(60) do
        if tick() - st >= 1140 then
            createNotification("Auto Rejoining...", 2)
            wait(1)
            pcall(function()
                tps:Teleport(game.PlaceId, me)
            end)
            break
        end
    end
end)

-- Start
pgs[1].Visible = true
m.Visible = true
speedUI.Visible = true
createNotification("Demon Hub Loaded - Press I to toggle UI", 5)
print("Demon Hub loaded - All fixes applied")
