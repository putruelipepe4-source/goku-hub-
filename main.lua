--[[
    farm de ALEXIS - Auto Pesca + Clicker + TP
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui", 10)

pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

local AutoPesca = false
local AutoClick = false
local lastClick = 0
local lastInGreen = false
local lastAutoClick = 0
local ClickDelay = 0.30
local SavedCFrame = nil

local function doClick(x, y)
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

local function getHRP()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getText()
    local ok, result = pcall(function()
        for _, g in pairs(PlayerGui:GetDescendants()) do
            if (g:IsA("TextLabel") or g:IsA("TextButton")) and g.Visible then
                local t = string.lower(tostring(g.Text or ""))
                if string.find(t, "hits left") or string.find(t, "tap when") or string.find(t, "green target") then
                    return g
                end
            end
        end
        return nil
    end)
    return ok and result or nil
end

local function getBar(textLabel)
    if not textLabel then return nil end
    local best, bestW = nil, 0
    local parents = {}
    if textLabel.Parent then
        table.insert(parents, textLabel.Parent)
        if textLabel.Parent.Parent then table.insert(parents, textLabel.Parent.Parent) end
    end
    for _, root in pairs(parents) do
        for _, g in pairs(root:GetDescendants()) do
            if (g:IsA("Frame") or g:IsA("ImageLabel")) and g.Visible then
                local sz = g.AbsoluteSize
                if sz.X > 180 and sz.Y >= 8 and sz.Y <= 40 and sz.X > bestW then
                    bestW = sz.X
                    best = g
                end
            end
        end
    end
    return best
end

local function readBar(bar)
    if not bar then return nil end
    local barPos, barSize = bar.AbsolutePosition, bar.AbsoluteSize
    if barSize.X < 50 then return nil end
    local g1, g2, needle = nil, nil, nil
    local roots = {bar}
    if bar.Parent then table.insert(roots, bar.Parent) end
    for _, root in pairs(roots) do
        for _, g in pairs(root:GetDescendants()) do
            if g:IsA("GuiObject") and g.Visible then
                local pos, sz, c = g.AbsolutePosition, g.AbsoluteSize, g.BackgroundColor3
                local name = string.lower(g.Name)
                local rel = ((pos.X + sz.X / 2) - barPos.X) / barSize.X
                if rel >= -0.05 and rel <= 1.05 then
                    if c.G > 0.5 and c.G > c.R + 0.2 and c.G > c.B + 0.15 and sz.X > 20 and sz.Y >= 4 then
                        g1 = math.clamp((pos.X - barPos.X) / barSize.X, 0, 1)
                        g2 = math.clamp((pos.X + sz.X - barPos.X) / barSize.X, 0, 1)
                    end
                    local thin = sz.X <= 10 and sz.Y >= 6
                    local white = c.R > 0.85 and c.G > 0.85 and c.B > 0.85
                    local named = string.find(name, "needle") or string.find(name, "marker") or string.find(name, "cursor") or string.find(name, "pointer") or string.find(name, "tick")
                    if named or (thin and white) or (thin and sz.Y >= barSize.Y * 0.5) then
                        needle = math.clamp(rel, 0, 1)
                    end
                end
            end
        end
    end
    if g1 and g2 and needle then
        return {
            inGreen = (needle >= g1 and needle <= g2),
            needle = needle,
            x = barPos.X + barSize.X / 2,
            y = barPos.Y + barSize.Y / 2
        }
    end
    return nil
end

local guiParent = game:GetService("CoreGui")
pcall(function()
    if gethui then guiParent = gethui() end
end)

local old = guiParent:FindFirstChild("Farm_ALEXIS")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "Farm_ALEXIS"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 270, 0, 310)
main.Position = UDim2.new(0.02, 0, 0.18, 0)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
main.Active = true
main.Draggable = true
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(10, 90, 40)
title.Text = "farm de ALEXIS"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local btn1 = Instance.new("TextButton")
btn1.Size = UDim2.new(0.9, 0, 0, 28)
btn1.Position = UDim2.new(0.05, 0, 0, 34)
btn1.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
btn1.Text = "Auto Minigame [OFF]"
btn1.TextColor3 = Color3.fromRGB(200, 200, 200)
btn1.Font = Enum.Font.GothamBold
btn1.TextSize = 12
btn1.Parent = main
Instance.new("UICorner", btn1).CornerRadius = UDim.new(0, 7)

local btn2 = Instance.new("TextButton")
btn2.Size = UDim2.new(0.9, 0, 0, 28)
btn2.Position = UDim2.new(0.05, 0, 0, 66)
btn2.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
btn2.Text = "Auto Click [OFF]"
btn2.TextColor3 = Color3.fromRGB(200, 200, 200)
btn2.Font = Enum.Font.GothamBold
btn2.TextSize = 12
btn2.Parent = main
Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 7)

-- VELOCIDAD
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.55, 0, 0, 18)
speedLabel.Position = UDim2.new(0.05, 0, 0, 100)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Velocidad: 0.30s"
speedLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = main

-- Caja para escribir el numero
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.32, 0, 0, 22)
speedBox.Position = UDim2.new(0.63, 0, 0, 98)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
speedBox.Text = "0.30"
speedBox.PlaceholderText = "ej: 2.5"
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.ClearTextOnFocus = false
speedBox.Parent = main
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(0.9, 0, 0, 14)
speedBar.Position = UDim2.new(0.05, 0, 0, 126)
speedBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
speedBar.Parent = main
Instance.new("UICorner", speedBar).CornerRadius = UDim.new(0, 8)

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.0125, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(0, 160, 70)
speedFill.Parent = speedBar
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0, 8)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, 0, 1, 0)
speedBtn.BackgroundTransparency = 1
speedBtn.Text = ""
speedBtn.Parent = speedBar

local MIN_D, MAX_D = 0.05, 20.00

local function applyDelay(val)
    val = tonumber(val)
    if not val then return end
    ClickDelay = math.clamp(val, MIN_D, MAX_D)
    local a = (ClickDelay - MIN_D) / (MAX_D - MIN_D)
    speedFill.Size = UDim2.new(a, 0, 1, 0)
    speedBox.Text = string.format("%.2f", ClickDelay)
    local txt
    if ClickDelay <= 0.08 then
        txt = string.format("Velocidad: %.2fs (ULTRA RAPIDO)", ClickDelay)
    elseif ClickDelay <= 0.15 then
        txt = string.format("Velocidad: %.2fs (muy rapido)", ClickDelay)
    elseif ClickDelay <= 0.30 then
        txt = string.format("Velocidad: %.2fs (rapido)", ClickDelay)
    elseif ClickDelay <= 0.50 then
        txt = string.format("Velocidad: %.2fs (normal)", ClickDelay)
    elseif ClickDelay <= 0.80 then
        txt = string.format("Velocidad: %.2fs (lento)", ClickDelay)
    elseif ClickDelay <= 1.20 then
        txt = string.format("Velocidad: %.2fs (muy lento)", ClickDelay)
    elseif ClickDelay <= 2.00 then
        txt = string.format("Velocidad: %.2fs (super lento)", ClickDelay)
    elseif ClickDelay <= 5.00 then
        txt = string.format("Velocidad: %.2fs (4-5s)", ClickDelay)
    elseif ClickDelay <= 10.00 then
        txt = string.format("Velocidad: %.2fs (6-10s)", ClickDelay)
    elseif ClickDelay <= 15.00 then
        txt = string.format("Velocidad: %.2fs (12-15s)", ClickDelay)
    else
        txt = string.format("Velocidad: %.2fs (20s MAX)", ClickDelay)
    end
    speedLabel.Text = txt
end

applyDelay(0.30)

local sliding = false
local function updateFromInput(input)
    local abs = speedBar.AbsolutePosition
    local size = speedBar.AbsoluteSize
    local x = math.clamp((input.Position.X - abs.X) / size.X, 0, 1)
    applyDelay(MIN_D + x * (MAX_D - MIN_D))
end

speedBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        updateFromInput(input)
    end
end)

speedBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateFromInput(input)
    end
end)

speedBox.FocusLost:Connect(function(enter)
    local n = tonumber(speedBox.Text)
    if n then
        applyDelay(n)
    else
        speedBox.Text = string.format("%.2f", ClickDelay)
    end
end)

-- TP
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.43, 0, 0, 28)
saveBtn.Position = UDim2.new(0.05, 0, 0, 150)
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
saveBtn.Text = "Guardar Pose"
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 11
saveBtn.Parent = main
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 7)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.43, 0, 0, 28)
tpBtn.Position = UDim2.new(0.52, 0, 0, 150)
tpBtn.BackgroundColor3 = Color3.fromRGB(30, 90, 140)
tpBtn.Text = "TP Pose"
tpBtn.TextColor3 = Color3.new(1, 1, 1)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 11
tpBtn.Parent = main
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 7)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 55)
status.Position = UDim2.new(0.05, 0, 0, 188)
status.BackgroundTransparency = 1
status.Text = "Arrastra el circulo / usa TP"
status.TextColor3 = Color3.fromRGB(160, 160, 160)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.Parent = main

local tip = Instance.new("TextLabel")
tip.Size = UDim2.new(0.9, 0, 0, 40)
tip.Position = UDim2.new(0.05, 0, 0, 250)
tip.BackgroundTransparency = 1
tip.Text = "Escribe el numero en la caja o usa la barra (0.05 - 20s)"
tip.TextColor3 = Color3.fromRGB(120, 120, 130)
tip.Font = Enum.Font.Gotham
tip.TextSize = 10
tip.TextWrapped = true
tip.Parent = main

btn1.MouseButton1Click:Connect(function()
    AutoPesca = not AutoPesca
    btn1.Text = AutoPesca and "Auto Minigame [ON]" or "Auto Minigame [OFF]"
    btn1.BackgroundColor3 = AutoPesca and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(40, 40, 48)
end)

btn2.MouseButton1Click:Connect(function()
    AutoClick = not AutoClick
    btn2.Text = AutoClick and "Auto Click [ON]" or "Auto Click [OFF]"
    btn2.BackgroundColor3 = AutoClick and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(40, 40, 48)
end)

saveBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp then
        SavedCFrame = hrp.CFrame
        status.Text = "Pose guardada ✓"
        status.TextColor3 = Color3.fromRGB(0, 255, 120)
        saveBtn.Text = "Guardada!"
        task.delay(1, function() saveBtn.Text = "Guardar Pose" end)
    else
        status.Text = "No hay personaje"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if not SavedCFrame then
        status.Text = "Primero guarda una pose"
        status.TextColor3 = Color3.fromRGB(255, 180, 50)
        return
    end
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = SavedCFrame
        status.Text = "TP listo ✓"
        status.TextColor3 = Color3.fromRGB(80, 180, 255)
    else
        status.Text = "No hay personaje"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

-- Marcador movible
local marker = Instance.new("TextButton")
marker.Name = "ClickMarker"
marker.Size = UDim2.new(0, 48, 0, 48)
marker.Position = UDim2.new(0.85, 0, 0.45, 0)
marker.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
marker.BackgroundTransparency = 0.25
marker.Text = "👆"
marker.TextSize = 22
marker.Font = Enum.Font.GothamBold
marker.TextColor3 = Color3.new(1, 1, 1)
marker.BorderSizePixel = 0
marker.ZIndex = 50
marker.Parent = sg
Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)

local ring = Instance.new("UIStroke")
ring.Color = Color3.fromRGB(255, 255, 255)
ring.Thickness = 2
ring.Parent = marker

local dragging = false
local dragOffset = Vector2.new()

marker.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local pos = UIS:GetMouseLocation()
        dragOffset = Vector2.new(pos.X - marker.AbsolutePosition.X, pos.Y - marker.AbsolutePosition.Y)
    end
end)

marker.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = UIS:GetMouseLocation()
        marker.Position = UDim2.new(0, pos.X - dragOffset.X, 0, pos.Y - dragOffset.Y)
    end
end)

RunService.RenderStepped:Connect(function()
    if AutoClick then
        if tick() - lastAutoClick >= ClickDelay then
            lastAutoClick = tick()
            local mx = marker.AbsolutePosition.X + marker.AbsoluteSize.X / 2
            local my = marker.AbsolutePosition.Y + marker.AbsoluteSize.Y / 2
            doClick(mx, my)
            status.Text = string.format("Click cada %.2fs", ClickDelay)
            status.TextColor3 = Color3.fromRGB(0, 255, 120)
        end
    end

    if not AutoPesca then return end

    local textLbl = getText()
    if textLbl then
        local info = readBar(getBar(textLbl))
        if info then
            local pct = math.floor(info.needle * 100)
            if info.inGreen then
                status.Text = "EN VERDE " .. pct .. "%"
                status.TextColor3 = Color3.fromRGB(0, 255, 100)
                if not lastInGreen and tick() - lastClick > 0.15 then
                    lastClick = tick()
                    doClick(info.x, info.y)
                    status.Text = "CLICK minijuego " .. pct .. "%"
                end
                lastInGreen = true
            else
                lastInGreen = false
                status.Text = "Aguja " .. pct .. "% esperando..."
                status.TextColor3 = Color3.fromRGB(255, 180, 50)
            end
        else
            status.Text = "Minijuego - buscando..."
            status.TextColor3 = Color3.fromRGB(255, 200, 80)
        end
    else
        lastInGreen = false
        if not AutoClick then
            status.Text = "Esperando minijuego..."
            status.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
    end
end)

print("farm de ALEXIS cargado")
