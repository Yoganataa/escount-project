-- MyTopbarSystem/Components/Menu.luau
local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").Fusion)
local OnyxUI = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").OnyxUI)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Util = OnyxUI.Util
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	-- Props expected: Name, Open (Value object), Size, AutomaticSize, Parent, Children
	local Name = Util.Fallback(Props.Name, "Menu")
	local Open = Util.Fallback(Props.Open, Value(Scope, false))
	local AnchorPoint = Util.Fallback(Props.AnchorPoint, Vector2.new(0.5, 0))
	local Position = Util.Fallback(
		Props.Position,
		Computed(Scope, function(Use)
			-- Mengambil posisi Y dari state Topbar jika ada, atau default
			local topbarYPos = Props.TopbarYPosition and Use(Props.TopbarYPosition) or 60 -- Default jika tidak ada state
			local yOffset = topbarYPos + 10 -- Jarak dari topbar
			if not Use(Open) then
				yOffset = yOffset - 15 -- Efek slide up saat tertutup
			end
			return UDim2.new(UDim.new(0.5, 0), UDim.new(0, yOffset))
		end)
	)
	local Size = Util.Fallback(Props.Size, UDim2.fromOffset(0, 0))
	local AutomaticSize = Util.Fallback(Props.AutomaticSize, Enum.AutomaticSize.Y)
	local ListFillDirection = Util.Fallback(Props.ListFillDirection, Enum.FillDirection.Vertical)
	local ListHorizontalFlex = Util.Fallback(Props.ListHorizontalFlex, Enum.UIFlexAlignment.None)
	local ListVerticalFlex = Util.Fallback(Props.ListVerticalFlex, Enum.UIFlexAlignment.None)
	local Padding = Util.Fallback(
		Props.Padding,
		Computed(Scope, function(Use)
			return UDim.new(0, Use(Theme.Spacing["1.5"]))
		end)
	)
	local ListPadding = Util.Fallback(
		Props.ListPadding,
		Computed(Scope, function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end)
	)
	local DisplayOrder = Util.Fallback(Props.DisplayOrder, 0)

	-- State untuk PreferredTransparency (contoh, bisa diambil dari state global jika perlu)
	local preferredTransparency = Value(Scope, 0.15) -- Ambil dari state jika perlu

	return Scope:New "ScreenGui" {
		Name = Name,
		Parent = Props.Parent,
		Enabled = Computed(Scope, function(Use) return Use(Open) end),
		ResetOnSpawn = false,
		DisplayOrder = DisplayOrder,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		[Children] = {
			Scope:MenuFrame {
				AnchorPoint = AnchorPoint,
				Position = Spring(Scope, Position, Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
				Size = Size,
				AutomaticSize = AutomaticSize,
				GroupTransparency = Spring(Scope, Computed(Scope, function(Use)
					return Use(Open) and 0 or 1
				end), Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
				BackgroundTransparency = Computed(Scope, function(Use) return Use(preferredTransparency) end),
				ListEnabled = true,
				ListFillDirection = ListFillDirection,
				ListHorizontalFlex = ListHorizontalFlex,
				ListVerticalFlex = ListVerticalFlex,
				ListPadding = ListPadding,
				Padding = Padding,

				[Children] = Props[Children],
			},
		},
	}
end