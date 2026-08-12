-- Crear la interfaz gráfica (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GokuHubMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Crear el marco principal (El fondo del menú)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(240, 130, 40) -- Color naranja de Goku
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- Crear el título del menú
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "GOKU HUB LEGÍTIMO"
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 50, 150) -- Color azul del traje
titleLabel.Parent = mainFrame

-- Crear un botón de acción (Ejemplo: Lanzar energía)
local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0, 200, 0, 50)
actionButton.Position = UDim2.new(0.5, -100, 0.5, -10)
actionButton.Text = "Lanzar Ráfaga de Energía"
actionButton.TextSize = 16
actionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
actionButton.Parent = mainFrame

-- Función para que el botón haga algo en tu mapa
actionButton.MouseButton1Click:Connect(function()
    print("¡Kamehameha simulado con éxito en la consola!")
    -- Aquí podés programar que aparezcan partículas o sonidos legítimos de tu juego
end)
