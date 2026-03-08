--[[ 
    FahzHUB | Sambung Kata v2 - Modified by Lisa
    UI lebih besar, swipe down, tampilan premium
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local currentPage = 1
local wordList = {}
local usedWords = {}
local autoEnter = true
local typingSpeed = 0.12
local isDeleting = false
local startTime = tick()
local isDragging = false
local lastTouchPos = nil

-- GUI Setup dengan ukuran lebih besar
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FahzHUB_SambungKata_v2"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22) -- Darker premium look
mainFrame.Position = UDim2.new(0.5, -100, 0.4, -40) -- Adjusted for new size
mainFrame.Size = UDim2.new(0, 200, 0, 300) -- Lebih gede: 200x300
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Parent = mainFrame
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Image = "rbxassetid://6015897843"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = -1

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 1.5
uiStroke.Color = Color3.fromRGB(80, 80, 255) -- Premium blue stroke
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.ZIndex = 2

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "FahzHUB | Sambung Kata v2"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton")
closeButton.Parent = titleBar
closeButton.BackgroundTransparency = 1
closeButton.Position = UDim2.new(1, -30, 0, 7)
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Text = "−"
closeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold

-- Content container (bisa di-scroll)
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Name = "ContentContainer"
contentContainer.Parent = mainFrame
contentContainer.BackgroundTransparency = 1
contentContainer.Position = UDim2.new(0, 0, 0, 35)
contentContainer.Size = UDim2.new(1, 0, 1, -35)
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.ScrollBarThickness = 4
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 255)
contentContainer.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
contentContainer.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
contentContainer.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
contentContainer.ElasticBehavior = Enum.ElasticBehavior.Always
contentContainer.ScrollingDirection = Enum.ScrollingDirection.Y

-- Content frame (tempat semua elemen)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Parent = contentContainer
contentFrame.BackgroundTransparency = 1
contentFrame.Size = UDim2.new(1, 0, 1, 0)
contentFrame.Position = UDim2.new(0, 0, 0, 0)
contentFrame.ZIndex = 2

-- Fungsi buat bikin button (kode dirapihin)
local function createModernButton(text, position, size, color)
    local button = Instance.new("TextButton")
    button.Parent = contentFrame
    button.BackgroundColor3 = color or Color3.fromRGB(50, 50, 70)
    button.Position = position
    button.Size = size
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", button)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(100, 100, 255)
    stroke.Transparency = 0.7
    
    return button
end

-- Button bar
local buttonBar = Instance.new("Frame")
buttonBar.Name = "ButtonBar"
buttonBar.Parent = contentFrame
buttonBar.BackgroundTransparency = 1
buttonBar.Position = UDim2.new(0, 10, 0, 10)
buttonBar.Size = UDim2.new(1, -20, 0, 30)

-- Reset button
local resetButton = createModernButton("🌌", 
    UDim2.new(0, 0, 0, 0), 
    UDim2.new(0, 45, 0, 30),
    Color3.fromRGB(180, 70, 180)
)

-- Delete button
local deleteButton = createModernButton("✖", 
    UDim2.new(0, 50, 0, 0), 
    UDim2.new(0, 45, 0, 30),
    Color3.fromRGB(200, 80, 50)
)

-- Auto enter button
local autoEnterButton = createModernButton("✓ ON", 
    UDim2.new(0, 100, 0, 0), 
    UDim2.new(0, 70, 0, 30),
    Color3.fromRGB(40, 150, 80)
)

-- Search box
local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Parent = contentFrame
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
searchBox.Position = UDim2.new(0, 10, 0, 50)
searchBox.Size = UDim2.new(1, -20, 0, 35)
searchBox.PlaceholderText = "🔍  Cari kata..."
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.ClearTextOnFocus = false

local searchCorner = Instance.new("UICorner", searchBox)
searchCorner.CornerRadius = UDim.new(0, 8)

local searchStroke = Instance.new("UIStroke", searchBox)
searchStroke.Thickness = 1
searchStroke.Color = Color3.fromRGB(80, 80, 255)
searchStroke.Transparency = 0.5

-- Word list container (SCROLLING FRAME YANG BISA SWIPE)
local wordContainer = Instance.new("ScrollingFrame")
wordContainer.Name = "WordContainer"
wordContainer.Parent = contentFrame
wordContainer.BackgroundTransparency = 1
wordContainer.Position = UDim2.new(0, 10, 0, 95)
wordContainer.Size = UDim2.new(1, -20, 0, 140)
wordContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
wordContainer.ScrollBarThickness = 4
wordContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 255)
wordContainer.ElasticBehavior = Enum.ElasticBehavior.Always
wordContainer.ScrollingDirection = Enum.ScrollingDirection.Y

-- UIListLayout buat word list
local wordLayout = Instance.new("UIListLayout")
wordLayout.Parent = wordContainer
wordLayout.Padding = UDim.new(0, 5)
wordLayout.SortOrder = Enum.SortOrder.LayoutOrder
wordLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Load more button
local loadMoreButton = createModernButton("LOAD MORE KATA", 
    UDim2.new(0, 10, 0, 240), 
    UDim2.new(1, -20, 0, 30),
    Color3.fromRGB(40, 40, 60)
)

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Parent = contentFrame
statusBar.BackgroundTransparency = 1
statusBar.Position = UDim2.new(0, 10, 0, 275)
statusBar.Size = UDim2.new(1, -20, 0, 15)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Parent = statusBar
fpsLabel.Size = UDim2.new(0.5, 0, 1, 0)
fpsLabel.Text = "⚡ FPS: 60"
fpsLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 10
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

local pingLabel = Instance.new("TextLabel")
pingLabel.Parent = statusBar
pingLabel.Position = UDim2.new(0.5, 0, 0, 0)
pingLabel.Size = UDim2.new(0.5, 0, 1, 0)
pingLabel.Text = "📶 PING: 20ms"
pingLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
pingLabel.Font = Enum.Font.Code
pingLabel.TextSize = 10
pingLabel.BackgroundTransparency = 1
pingLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Tambahin padding biar rapi
local padding = Instance.new("UIPadding", contentFrame)
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)

-- Fungsi type word (sama kayak sebelumnya)
local function typeWord(word)
    local currentText = string.lower(searchBox.Text:gsub("%s+", ""))
    local remainingWord = string.sub(word, #currentText + 1)
    
    for i = 1, #remainingWord do
        local letter = string.upper(string.sub(remainingWord, i, i))
        local keyCode = Enum.KeyCode[letter]
        
        if keyCode then
            VirtualInput:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.015)
            VirtualInput:SendKeyEvent(false, keyCode, false, game)
            task.wait(typingSpeed)
        end
    end
    
    if autoEnter then
        task.wait(0.15)
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.02)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end
end

-- Update word list
local function updateWordList(reset)
    local searchText = string.lower(searchBox.Text:gsub("%s+", ""))
    
    for _, child in pairs(wordContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if searchText == "" then return end
    
    if reset then
        currentPage = 1
    end
    
    local maxButtons = 12
    local displayedCount = 0
    local startIndex = 1
    
    for index, word in ipairs(wordList) do
        if string.sub(word, 1, #searchText) == searchText then
            startIndex = startIndex + 1
            if startIndex >= currentPage then
                displayedCount = displayedCount + 1
                
                if displayedCount > maxButtons then break end
                
                local wordButton = Instance.new("TextButton")
                wordButton.Size = UDim2.new(1, -10, 0, 28)
                wordButton.BackgroundColor3 = (usedWords[word] and Color3.fromRGB(35, 35, 60)) or Color3.fromRGB(45, 45, 55)
                wordButton.Text = ((usedWords[word] and "✓ ") or "") .. string.upper(word)
                wordButton.TextColor3 = (usedWords[word] and Color3.fromRGB(100, 100, 255)) or Color3.new(1, 1, 1)
                wordButton.Font = Enum.Font.GothamBold
                wordButton.TextSize = 13
                wordButton.Parent = wordContainer
                wordButton.AutoButtonColor = false
                
                local corner = Instance.new("UICorner", wordButton)
                corner.CornerRadius = UDim.new(0, 6)
                
                wordButton.MouseButton1Click:Connect(function()
                    if not usedWords[word] then
                        usedWords[word] = true
                        typeWord(word)
                        wordButton.Text = "✓ " .. string.upper(word)
                        wordButton.TextColor3 = Color3.fromRGB(100, 100, 255)
                        wordButton.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
                    end
                end)
            end
        end
    end
    
    wordContainer.CanvasSize = UDim2.new(0, 0, 0, displayedCount * 33)
end

-- Fungsi buat swipe down (touch support)
local function onTouchMoved(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - lastTouchPos
        if math.abs(delta.Y) > 10 then
            isDragging = true
            wordContainer.CanvasPosition = Vector2.new(0, math.clamp(wordContainer.CanvasPosition.Y - delta.Y, 0, wordContainer.CanvasSize.Y.Offset))
        end
        lastTouchPos = input.Position
    end
end

-- Connect touch events
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        lastTouchPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(onTouchMoved)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Event handlers
resetButton.MouseButton1Click:Connect(function()
    usedWords = {}
    updateWordList(true)
end)

autoEnterButton.MouseButton1Click:Connect(function()
    autoEnter = not autoEnter
    autoEnterButton.Text = (autoEnter and "✓ ON") or "✗ OFF"
    autoEnterButton.BackgroundColor3 = (autoEnter and Color3.fromRGB(40, 150, 80)) or Color3.fromRGB(150, 60, 60)
end)

deleteButton.MouseButton1Down:Connect(function()
    isDeleting = true
    task.spawn(function()
        while isDeleting do
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
            task.wait(0.02)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
            task.wait(0.03)
        end
    end)
end)

deleteButton.MouseButton1Up:Connect(function()
    isDeleting = false
end)

-- Load word list
task.spawn(function()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ZenoScripter/Script/refs/heads/main/Sambung%20Kata%20(%20indo%20)/wordlist_kbbi.lua")
    end)
    
    if success then
        for line in string.gmatch(response, "[^\r\n]+") do
            local word = string.match(line, "([%a%-]+)")
            if word and (#word > 1) then
                table.insert(wordList, string.lower(word))
            end
        end
    end
end)

-- Search box event
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateWordList(true)
end)

-- Load more
loadMoreButton.MouseButton1Click:Connect(function()
    currentPage = currentPage + 10
    updateWordList(false)
end)

-- Animation and stats
RunService.RenderStepped:Connect(function()
    local fps = 1 / (tick() - startTime)
    startTime = tick()
    fpsLabel.Text = "⚡ FPS: " .. math.floor(fps)
    pingLabel.Text = "📶 PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
    
    -- Animated stroke color
    currentPage = (currentPage + 0.002) % 1
    local rainbowColor = Color3.fromHSV(currentPage, 0.8, 1)
    uiStroke.Color = rainbowColor
    searchStroke.Color = rainbowColor
end)

-- Minimize function
closeButton.MouseButton1Click:Connect(function()
    local isMinimized = mainFrame.Size == UDim2.new(0, 200, 0, 35)
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 200, 0, 300)
        contentContainer.Visible = true
        closeButton.Text = "−"
    else
        mainFrame.Size = UDim2.new(0, 200, 0, 35)
        contentContainer.Visible = false
        closeButton.Text = "+"
    end
end)

-- Set initial canvas size
wordContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
