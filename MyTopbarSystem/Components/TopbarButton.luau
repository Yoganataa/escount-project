-- MyTopbarSystem/Components/TopbarButton.luau
local OnyxUI = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").OnyxUI)
local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").Fusion)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	-- Props expected: Name, MenuName, Icon, IconFilled, LayoutOrder, CurrentMenuState, SetCurrentMenuCallback
	local MenuName = Util.Fallback(Props.MenuName, "")
	local Icon = Util.Fallback(Props.Icon, "")
	local IconFilled = Util.Fallback(Props.IconFilled, "")
	local CurrentMenuState = Util.Fallback(Props.CurrentMenuState, Value(Scope, nil))
	local SetCurrentMenuCallback = Util.Fallback(Props.SetCurrentMenuCallback, function() end)

	local IsHovering = Value(Scope, false)
	local MenuOpen = Computed(Scope, function(Use)
		return Use(CurrentMenuState) == Use(MenuName)
	end)

	return Scope:BaseButton {
		Name = Props.Name or "TopbarButton",
		BackgroundColor3 = Theme.Colors.BaseContent.Main,
		BackgroundTransparency = Spring(Scope, Computed(Scope, function(Use)
			if Use(IsHovering) or Use(MenuOpen) then
				return 0.9
			else
				return 1
			end
		end), Theme.SpringSpeed["0.5"], Theme.SpringDampening["1"]), -- Menambah kecepatan spring
		Size = UDim2.fromOffset(45, 45),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Props.LayoutOrder or 0,
		CornerRadius = Computed(Scope, function(Use)
			return UDim.new(0, Use(Theme.CornerRadius.Full))
		end),

		IsHovering = IsHovering,
		OnActivated = function()
			if Fusion.peek(CurrentMenuState) == Fusion.peek(MenuName) then
				SetCurrentMenuCallback(nil) -- Tutup jika menu yang sama diklik
			else
				SetCurrentMenuCallback(Fusion.peek(MenuName)) -- Buka menu ini
			end
		end,

		[Children] = {
			Scope:Icon {
				Name = "Icon",
				Image = Computed(Scope, function(Use)
					return (Use(MenuOpen) and Use(IconFilled)) or Use(Icon) -- Gunakan IconFilled jika menu terbuka
				end),
				ImageColor3 = Theme.Colors.BaseContent.Main,
				Size = UDim2.fromOffset(30, 30),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			},
			-- Indikator (jika diperlukan nanti) bisa ditambahkan di sini
		},
	}
end