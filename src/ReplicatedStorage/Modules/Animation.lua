local TweenService = game:GetService("TweenService")

local Animation = {}

function Animation.tween(instance, tweenInfo, props)
	local tween = TweenService:Create(instance, tweenInfo, props)
	tween:Play()
	return tween
end

function Animation.buttonHover(button)
	local baseSize = button:GetAttribute("BaseSize")
	if baseSize then
		return Animation.tween(
			button,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = baseSize + UDim2.fromOffset(6, 6),
				BackgroundTransparency = math.max(0, button.BackgroundTransparency - 0.05),
			}
		)
	end
	return Animation.tween(
		button,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = button.Size + UDim2.fromOffset(6, 6),
			BackgroundTransparency = math.max(0, button.BackgroundTransparency - 0.05),
		}
	)
end

function Animation.buttonPress(button)
	local baseSize = button:GetAttribute("BaseSize")
	if baseSize then
		return Animation.tween(
			button,
			TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = baseSize - UDim2.fromOffset(4, 4),
				BackgroundTransparency = math.min(1, button.BackgroundTransparency + 0.05),
			}
		)
	end
	return Animation.tween(
		button,
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = button.Size - UDim2.fromOffset(4, 4),
			BackgroundTransparency = math.min(1, button.BackgroundTransparency + 0.05),
		}
	)
end

function Animation.fade(instance, transparency, duration)
	return Animation.tween(
		instance,
		TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = transparency }
	)
end

function Animation.slide(instance, position, duration)
	return Animation.tween(
		instance,
		TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{ Position = position }
	)
end

function Animation.scale(instance, size, duration)
	return Animation.tween(
		instance,
		TweenInfo.new(duration or 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = size }
	)
end

function Animation.flash(frame)
	local original = frame.BackgroundTransparency
	Animation.tween(frame, TweenInfo.new(0.08), { BackgroundTransparency = 0 })
	task.delay(0.08, function()
		Animation.tween(frame, TweenInfo.new(0.15), { BackgroundTransparency = original })
	end)
end

function Animation.glowBurst(glowFrame)
	glowFrame.Visible = true
	glowFrame.Size = UDim2.fromScale(0.2, 0.2)
	glowFrame.BackgroundTransparency = 0.6
	Animation.tween(glowFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1.1, 1.1),
		BackgroundTransparency = 1,
	})
	task.delay(0.35, function()
		glowFrame.Visible = false
	end)
end

function Animation.screenShake(frame)
	local original = frame.Position
	for i = 1, 6 do
		Animation.tween(frame, TweenInfo.new(0.03), {
			Position = original + UDim2.fromOffset(math.random(-6, 6), math.random(-6, 6)),
		})
		task.wait(0.03)
	end
	Animation.tween(frame, TweenInfo.new(0.08), { Position = original })
end

function Animation.numberPopup(label)
	label.Visible = true
	label.TextTransparency = 0
	label.Position = label.Position + UDim2.fromOffset(0, 12)
	Animation.tween(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
		Position = label.Position - UDim2.fromOffset(0, 20),
	})
	task.delay(0.45, function()
		label.Visible = false
	end)
end

return Animation
