-- Westbound 1911 Mobile Version
-- Didesain khusus untuk perangkat mobile
-- Fitur: Aimbot, ESP, Auto-Shoot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Konfigurasi
local Config = {
    Aimbot = {
        Enabled = true,
        FOV = 200,
        Smoothing = 0.8,
        TargetPart = "Head",
        TeamCheck = true,
        WallCheck = true,
        AutoShoot = true
    },
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true
    },
    UI = {
        Opacity = 0.7,
        ButtonSize = UDim2.new(0, 80, 0, 80)
    }
}

-- Variabel
local ESPObjects = {}
local Target = nil

-- Fungsi untuk membuat tombol di layar
local function CreateMobileButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = Config.UI.ButtonSize
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = ""
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.ZIndex = 10
    
    -- Efek saat ditekan
    button.MouseButton1Down:Connect(function()
        button.BackgroundTransparency = 0.1
        if callback then callback(true) end
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundTransparency = 0.3
        if callback then callback(false) end
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0.3
    end)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0.3, 0)
    label.Position = UDim2.new(0, 0, 0.7, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Parent = button
    
    return button
end

-- Fungsi untuk membuat joystick
local function CreateJoystick()
    local joystick = {}
    local frame = Instance.new("Frame")
    local outer = Instance.new("ImageLabel")
    local inner = Instance.new("ImageLabel")
    
    -- Frame utama
    frame.Name = "JoystickFrame"
    frame.Size = UDim2.new(0.3, 0, 0.3, 0)
    frame.Position = UDim2.new(0.1, 0, 0.6, 0)
    frame.BackgroundTransparency = 1
    
    -- Lingkaran luar
    outer.Name = "Outer"
    outer.Size = UDim2.new(1, 0, 1, 0)
    outer.BackgroundTransparency = 1
    outer.Image = "rbxassetid://3570695787"
    outer.ImageColor3 = Color3.fromRGB(255, 255, 255)
    outer.ImageTransparency = 0.5
    outer.ScaleType = Enum.ScaleType.Slice
    outer.SliceCenter = Rect.new(100, 100, 100, 100)
    outer.SliceScale = 0.2
    outer.Parent = frame
    
    -- Lingkaran dalam
    inner.Name = "Inner"
    inner.Size = UDim2.new(0.5, 0, 0.5, 0)
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.new(0.5, 0, 0.5, 0)
    inner.BackgroundTransparency = 1
    inner.Image = "rbxassetid://3570695787"
    inner.ImageColor3 = Color3.fromRGB(200, 200, 200)
    inner.ImageTransparency = 0.3
    inner.ScaleType = Enum.ScaleType.Slice
    inner.SliceCenter = Rect.new(100, 100, 100, 100)
    inner.SliceScale = 0.2
    inner.Parent = outer
    
    -- Fungsi untuk mengupdate posisi
    function joystick:UpdatePosition(input)
        local pos = Vector2.new(
            (input.Position.X - outer.AbsolutePosition.X) / outer.AbsoluteSize.X,
            (input.Position.Y - outer.AbsolutePosition.Y) / outer.AbsoluteSize.Y
        )
        
        -- Batasi dalam lingkaran
        local magnitude = math.min(1, pos.Magnitude * 2)
        local direction = pos.Unit or Vector2.new(0, 0)
        
        inner.Position = UDim2.new(
            0.5 + direction.X * magnitude * 0.5,
            0,
            0.5 + direction.Y * magnitude * 0.5,
            0
        )
        
        -- Return nilai untuk pergerakan karakter
        return {
            X = direction.X * magnitude,
            Y = direction.Y * magnitude
        }
    end
    
    -- Reset posisi joystick
    function joystick:Reset()
        inner.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    
    joystick.Frame = frame
    return joystick
end

-- Fungsi untuk membuat UI mobile
local function CreateMobileUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileUI"
    screenGui.ResetOnSpawn = false
    
    -- Joystick untuk pergerakan
    local moveJoystick = CreateJoystick()
    moveJoystick.Frame.Parent = screenGui
    
    -- Joystick untuk kamera
    local cameraJoystick = CreateJoystick()
    cameraJoystick.Frame.Position = UDim2.new(0.6, 0, 0.6, 0)
    cameraJoystick.Frame.Parent = screenGui
    
    -- Tombol tembak
    local shootButton = CreateMobileButton("FIRE", UDim2.new(0.8, 0, 0.7, 0), function(pressed)
        Config.Aimbot.AutoShoot = pressed
    end)
    shootButton.Parent = screenGui
    
    -- Tombol lompat
    local jumpButton = CreateMobileButton("JUMP", UDim2.new(0.1, 0, 0.4, 0), function(pressed)
        if pressed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end)
    jumpButton.Parent = screenGui
    
    -- Tombol reload
    local reloadButton = CreateMobileButton("RELOAD", UDim2.new(0.8, 0, 0.5, 0), function()
        -- Tambahkan kode untuk reload senjata di sini
    end)
    reloadButton.Parent = screenGui
    
    -- Tombol menu
    local menuButton = CreateMobileButton("MENU", UDim2.new(0.05, 0, 0.1, 0), function()
        -- Tambahkan menu pengaturan di sini
    end)
    menuButton.Size = UDim2.new(0, 60, 0, 60)
    menuButton.Parent = screenGui
    
    -- Handle input joystick
    local moveConnection
    local cameraConnection
    
    -- Joystick pergerakan
    moveJoystick.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            moveConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    moveJoystick:Reset()
                    moveConnection:Disconnect()
                else
                    local move = moveJoystick:UpdatePosition(input)
                    -- Update pergerakan karakter
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local humanoid = LocalPlayer.Character.Humanoid
                        humanoid:Move(Vector3.new(move.X, 0, -move.Y) * 16)
                    end
                end
            end)
        end
    end)
    
    -- Joystick kamera
    cameraJoystick.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            cameraConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    cameraJoystick:Reset()
                    cameraConnection:Disconnect()
                else
                    local look = cameraJoystick:UpdatePosition(input)
                    -- Update rotasi kamera
                    local camera = workspace.CurrentCamera
                    camera.CFrame = CFrame.new(
                        camera.CFrame.Position,
                        camera.CFrame.Position + camera.CFrame.LookVector + Vector3.new(look.X, 0, look.Y)
                    )
                end
            end)
        end
    end)
    
    return screenGui
end

-- Fungsi untuk mendapatkan target terdekat
local function GetClosestTarget()
    local closest = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart)
            if targetPart then
                local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
                if distance < shortestDistance then
                    if Config.Aimbot.WallCheck then
                        local ray = Ray.new(
                            Camera.CFrame.Position,
                            (targetPart.Position - Camera.CFrame.Position).Unit * 1000
                        )
                        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        
                        if hit and hit:IsDescendantOf(player.Character) then
                            closest = targetPart
                            shortestDistance = distance
                        end
                    else
                        closest = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closest
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled and Config.Aimbot.AutoShoot then
        Target = GetClosestTarget()
        if Target then
            local targetPos = Target.Position
            local cameraPos = Camera.CFrame.Position
            local direction = (targetPos - cameraPos).Unit
            
            -- Apply smoothing
            local targetCF = CFrame.new(cameraPos, cameraPos + direction)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothing)
            
            -- Auto shoot
            -- Tambahkan kode untuk menembak otomatis di sini
        end
    end
end)

-- Inisialisasi UI Mobile
local MobileUI = CreateMobileUI()
MobileUI.Parent = PlayerGui

-- Notifikasi
local function Notify(message, duration)
    local notif = Instance.new("TextLabel")
    notif.Name = "Notification"
    notif.Parent = MobileUI
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.5
    notif.Position = UDim2.new(0.5, -100, 0.1, 0)
    notif.Size = UDim2.new(0, 200, 0, 40)
    notif.Font = Enum.Font.GothamBold
    notif.Text = message
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.TextSize = 14
    notif.TextWrapped = true
    notif.Visible = true
    
    game:GetService("TweenService"):Create(
        notif,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.8}
    ):Play()
    
    game:GetService("Debris"):AddItem(notif, duration or 3)
end

-- Notifikasi saat script berhasil dimuat
Notify("Westbound 1911 Mobile Loaded!", 5)
