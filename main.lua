-- SimpleGUI Library
local SimpleGUI = {}

-- Function to create a window
function SimpleGUI:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = config.Size or UDim2.new(0, 400, 0, 300)
    Frame.Position = config.Position or UDim2.new(0.5, -200, 0.5, -150)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- Make the GUI draggable
    local Draggable = Instance.new("TextLabel")
    Draggable.Size = UDim2.new(1, 0, 0, 30)
    Draggable.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Draggable.Text = config.Title or "SimpleGUI Window"
    Draggable.TextColor3 = Color3.new(1, 1, 1)
    Draggable.Font = Enum.Font.SourceSans
    Draggable.TextSize = 18
    Draggable.TextXAlignment = Enum.TextXAlignment.Left
    Draggable.Parent = Frame

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = Frame

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Dragging functionality
    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos

    Draggable.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    Draggable.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Tabs container
    local TabsHolder = Instance.new("Frame")
    TabsHolder.Size = UDim2.new(1, 0, 0, 30)
    TabsHolder.Position = UDim2.new(0, 0, 0, 30)
    TabsHolder.BackgroundTransparency = 1
    TabsHolder.Parent = Frame

    -- Tab content container (Scrollable)
    local TabsContent = Instance.new("Frame")
    TabsContent.Size = UDim2.new(1, 0, 1, -60)
    TabsContent.Position = UDim2.new(0, 0, 0, 60)
    TabsContent.BackgroundTransparency = 1
    TabsContent.Parent = Frame

    local Window = { Frame = Frame, TabsHolder = TabsHolder, TabsContent = TabsContent, ScreenGui = ScreenGui, Tabs = {} }
    setmetatable(Window, { __index = SimpleGUI })
    return Window
end

-- Function to add a tab
function SimpleGUI:AddTab(config)
    -- Ensure Tabs table exists
    if not self.Tabs then
        self.Tabs = {}
    end

    local TabButton = Instance.new("TextButton")
    TabButton.Text = config.Title or "Tab"
    TabButton.Size = UDim2.new(0, 80, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.SourceSans
    TabButton.TextSize = 16
    TabButton.Parent = self.TabsHolder

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, -30)
    TabFrame.Position = UDim2.new(0, 0, 0, 30)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = self.TabsContent

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Frame.Visible = false
        end
        TabFrame.Visible = true
    end)

    table.insert(self.Tabs, { Button = TabButton, Frame = TabFrame })
    return TabFrame
end

-- Function to add a button
function SimpleGUI:AddButton(tab, config)
    local Button = Instance.new("TextButton")
    Button.Text = config.Text or "Button"
    Button.Size = UDim2.new(0, 150, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, 10 + (#tab:GetChildren() - 1) * 50)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = tab

    Button.MouseButton1Click:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)

    return Button
end

-- Function to add a slider
function SimpleGUI:AddSlider(tab, config)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(0, 200, 0, 50)
    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Slider.Parent = tab

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 10)
    SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SliderBar.Position = UDim2.new(0, 0, 0.5, -5)
    SliderBar.Parent = Slider

    local SliderThumb = Instance.new("Frame")
    SliderThumb.Size = UDim2.new(0, 20, 1, 0)
    SliderThumb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    SliderThumb.Parent = SliderBar

    local Dragging = false
    local function updateSlider(input)
        if Dragging then
            local pos = math.clamp(input.Position.X - Slider.Position.X.Offset, 0, Slider.Size.X.Offset)
            SliderThumb.Position = UDim2.new(0, pos, 0, 0)
            local value = math.round(pos / Slider.Size.X.Offset * (config.Max - config.Min) + config.Min)
            if config.Callback then
                config.Callback(value)
            end
        end
    end

    SliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end)

    SliderThumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(updateSlider)

    return Slider
end

-- Function to add a toggle
function SimpleGUI:AddToggle(tab, config)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(0, 200, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Toggle.Parent = tab

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 80, 1, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ToggleButton.Text = "Off"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.TextSize = 16
    ToggleButton.Parent = Toggle

    ToggleButton.MouseButton1Click:Connect(function()
        if ToggleButton.Text == "Off" then
            ToggleButton.Text = "On"
            if config.Callback then
                config.Callback(true)
            end
        else
            ToggleButton.Text = "Off"
            if config.Callback then
                config.Callback(false)
            end
        end
    end)

    return Toggle
end

return SimpleGUI
