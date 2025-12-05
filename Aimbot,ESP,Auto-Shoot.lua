--========================================================--
-- POTATO HUB | ESP BOX + TRACER + AIMBOT SUAVE + FOV RGB
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

--========================================================--
-- CONFIG
--========================================================--
local AimbotOn = false
local ESPOn = false
local FOVRadius = 150
local AimSmooth = 0.3  -- Diperbesar untuk pergerakan lebih cepat (nilai lebih besar = lebih cepat)
local MaxAimDistance = 500  -- Jarak maksimum target aimbot
local WallCheck = true      -- Cek tembok
local PredictionTime = 0.08  -- Diperkecil untuk prediksi lebih responsif

--========================================================--
-- GUI
--========================================================--
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PotatoHub"

local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0, 200, 0, 250)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "POTATO HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- BOTÃO MINIMIZAR
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
local minimized = false

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, v in pairs(Main:GetChildren()) do
        if v ~= Title and v ~= MinBtn then
            v.Visible = not minimized
        end
    end
    if minimized then
        MinBtn.Text = "+"
        Main.Size = UDim2.new(0, 200, 0, 25)
    else
        MinBtn.Text = "-"
        Main.Size = UDim2.new(0, 200, 0, 250)
    end
end)

-- ARRASTAR GUI
local dragging = false
local dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--========================================================--
-- BOTÕES
--========================================================--
local function NewBtn(txt, y)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(1, -20, 0, 25)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    Instance.new("UICorner", b)
    return b
end

local btnAimbot = NewBtn("Aimbot: OFF", 30)
local btnESP = NewBtn("ESP: OFF", 60)

btnAimbot.MouseButton1Click:Connect(function()
    AimbotOn = not AimbotOn
    btnAimbot.Text = "Aimbot: " .. (AimbotOn and "ON" or "OFF")
end)

btnESP.MouseButton1Click:Connect(function()
    ESPOn = not ESPOn
    btnESP.Text = "ESP: " .. (ESPOn and "ON" or "OFF")
end)

--========================================================--
-- FOV SLIDER
--========================================================--
local FOVLabel = Instance.new("TextLabel", Main)
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 0, 0, 90)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.Text = "Tamanho FOV: " .. FOVRadius

local FOVBox = Instance.new("TextBox", Main)
FOVBox.Size = UDim2.new(1, -20, 0, 25)
FOVBox.Position = UDim2.new(0, 10, 0, 110)
FOVBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVBox.TextColor3 = Color3.new(1, 1, 1)
FOVBox.PlaceholderText = "Digite FOV"
Instance.new("UICorner", FOVBox)

FOVBox.FocusLost:Connect(function()
    local n = tonumber(FOVBox.Text)
    if n and n >= 20 and n <= 1000 then
        FOVRadius = n
        FOVLabel.Text = "Tamanho FOV: " .. n
        FOVCircle.Radius = n
    end
end)

--========================================================--
-- FOV RGB
--========================================================--
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.NumSides = 90
FOVCircle.Radius = FOVRadius

local hue = 0

--========================================================--
-- ESP COM BOX + TRACER
--========================================================--
local ESPObjects = {}

local function AddESP(plr)
    if plr == LP then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(0, 200, 255)

    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(0, 200, 255)

    ESPObjects[plr] = { Box = box, Line = line }
end

local function RemoveESP(plr)
    if ESPObjects[plr] then
        ESPObjects[plr].Box:Remove()
        ESPObjects[plr].Line:Remove()
        ESPObjects[plr] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

--========================================================--
-- FUNÇÃO DE BUSCA DO ALVO MAIS PRÓXIMO
--========================================================--
local function IsVisible(target)
    -- Cek apakah target terlihat (tidak terhalang tembok)
    if not WallCheck then return true end
    
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (target.Position - origin).Unit * 500
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LP.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    -- Jika tidak ada yang kena raycast, atau yang kena adalah bagian dari karakter target
    return not raycastResult or raycastResult.Instance:IsDescendantOf(target.Parent)
end

local function GetBestTarget()
    local bestTarget = nil
    local shortestDistance = math.huge
    local centerScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                -- Cari bagian tubuh yang tersedia (prioritaskan Head)
                local targetPart = character:FindFirstChild("Head") or humanoidRootPart
                
                -- Hitung jarak ke pemain
                local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
                
                -- Cek apakah target dalam jangkauan maksimum
                if distance <= MaxAimDistance then
                    -- Cek apakah target terlihat di layar
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        -- Hitung jarak dari tengah layar ke target
                        local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distanceToCenter = (screenPos - centerScreen).Magnitude
                        
                        -- Cek apakah target dalam jangkauan FOV dan lebih dekat dari target sebelumnya
                        if distanceToCenter < FOVRadius and distanceToCenter < shortestDistance then
                            -- Cek apakah target terlihat (tidak terhalang tembok)
                            if IsVisible(targetPart) then
                                shortestDistance = distanceToCenter
                                bestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

--========================================================--
-- LOOP PRINCIPAL
--========================================================--
RunService.RenderStepped:Connect(function()
    -- FOV RGB (TETAP DI TENGAH LAYAR)
    hue = (hue + 1) % 360
    FOVCircle.Color = Color3.fromHSV(hue / 360, 1, 1)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- AIMBOT CEPAT
    if AimbotOn then
        local target = GetBestTarget()
        if target then
            -- Dapatkan posisi target
            local targetPos = target.Position
            
            -- Pastikan target adalah kepala
            local targetHead = target
            if target.Name ~= "Head" and target.Parent:FindFirstChild("Head") then
                targetHead = target.Parent.Head
                targetPos = targetHead.Position
            end
            
            -- Dapatkan kecepatan target
            local vel = targetHead.Velocity
            
            -- Prediksi posisi target dengan mempertimbangkan kecepatan
            local predictedPos = targetPos + (vel * PredictionTime)
            
            -- Hitung arah yang diperlukan untuk melihat ke target
            local camera = workspace.CurrentCamera
            local cameraPos = camera.CFrame.Position
            local direction = (predictedPos - cameraPos).Unit
            
            -- Buat CFrame baru yang mengarah ke target
            local targetCF = CFrame.new(cameraPos, cameraPos + direction)
            
            -- Terapkan dengan smoothing untuk lock-on yang lebih baik
            camera.CFrame = camera.CFrame:Lerp(targetCF, 0.98) -- Diperhalus untuk pergerakan yang lebih natural
        end
    end

    -- ESP
    for plr, objs in pairs(ESPObjects) do
        local char = plr.Character
        if ESPOn and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local top = root.Position + Vector3.new(0, 3, 0)
            local bottom = root.Position - Vector3.new(0, 3, 0)

            local topPos = Camera:WorldToViewportPoint(top)
            local botPos = Camera:WorldToViewportPoint(bottom)

            if topPos.Z > 0 and botPos.Z > 0 then
                local sizeY = topPos.Y - botPos.Y
                local sizeX = sizeY / 1.5

                -- BOX
                objs.Box.Size = Vector2.new(sizeX, sizeY)
                objs.Box.Position = Vector2.new(topPos.X - sizeX/2, botPos.Y)
                objs.Box.Visible = true

                -- LINE (tracer)
                objs.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                objs.Line.To = Vector2.new(topPos.X, botPos.Y + sizeY/2)
                objs.Line.Visible = true
            else
                objs.Box.Visible = false
                objs.Line.Visible = false
            end
        else
            objs.Box.Visible = false
            objs.Line.Visible = false
        end
    end
end)

--========================================================--
-- HOTKEYS
--========================================================--
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.F1 then
            ESPOn = not ESPOn
            btnESP.Text = "ESP: " .. (ESPOn and "ON" or "OFF")
        elseif input.KeyCode == Enum.KeyCode.F2 then
            AimbotOn = not AimbotOn
            btnAimbot.Text = "Aimbot: " .. (AimbotOn and "ON" or "OFF")
        end
    end
end)
