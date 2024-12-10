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
    TabsHolder.Size = UDim2.new(1, 0, 1, -30)
    TabsHolder.Position = UDim2.new(0, 0, 0, 30)
    TabsHolder.BackgroundTransparency = 1
    TabsHolder.Parent = Frame

    local Window = { Frame = Frame, TabsHolder = TabsHolder, ScreenGui = ScreenGui, Tabs = {} }
    setmetatable(Window, { __index = SimpleGUI })
    return Window
end

-- Function to add a tab
function SimpleGUI:AddTab(config)
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
    TabFrame.Parent = self.TabsHolder

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
    Button.Position = config.Position or UDim2.new(0, 0, 0.1 * (#tab:GetChildren() + 1), 0)
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
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 200, 0, 40)
    SliderFrame.Position = config.Position or UDim2.new(0, 0, 0.1 * (#tab:GetChildren() + 1), 0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderFrame.Parent = tab

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(0.8, 0, 0.3, 0)
    SliderBar.Position = UDim2.new(0.1, 0, 0.5, -5)
    SliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderBar.Parent = SliderFrame

    local SliderButton = Instance.new("Frame")
    SliderButton.Size = UDim2.new(0, 10, 1, 0)
    SliderButton.Position = UDim2.new(0, 0, 0, 0)
    SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderButton.Parent = SliderBar

    local value = config.Min or 0

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moveConnection
            local releaseConnection

            local function update(input)
                local deltaX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                SliderButton.Position = UDim2.new(deltaX / SliderBar.AbsoluteSize.X, 0, 0, 0)
                value = math.floor((deltaX / SliderBar.AbsoluteSize.X) * (config.Max - config.Min) + config.Min)
                if config.Callback then
                    config.Callback(value)
                end
            end

            moveConnection = game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)

            releaseConnection = game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConnection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)

    return SliderFrame
end

-- Function to add a toggle
function SimpleGUI:AddToggle(tab, config)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0, 200, 0, 40)
    ToggleFrame.Position = config.Position or UDim2.new(0, 0, 0.1 * (#tab:GetChildren() + 1), 0)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleFrame.Parent = tab

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
    ToggleButton.Position = UDim2.new(0.85, 0, 0.5, -20)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    ToggleButton.Text = "Off"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.TextSize = 16
    ToggleButton.Parent = ToggleFrame

    local toggled = false
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            ToggleButton.Text = "On"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            ToggleButton.Text = "Off"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
        if config.Callback then
            config.Callback(toggled)
        end
    end)

    return ToggleFrame
end

return SimpleGUI
