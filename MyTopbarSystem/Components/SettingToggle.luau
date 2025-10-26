-- MyTopbarSystem/Components/SettingToggle.luau
local OnyxUI = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").OnyxUI)
local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").Fusion)

local Themer = OnyxUI.Themer
local Children = Fusion.Children
local Util = OnyxUI.Util
local Computed = Fusion.Computed
local Value = Fusion.Value -- Tambahkan ini

local DISABLED_TRANSPARENCY = 0.5

-- Ambil SwitchGroup dari OnyxUI
local SwitchGroup = OnyxUI.Components.SwitchGroup -- Asumsi path ini benar

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	-- Props expected: Label, Switched (Value object), Disabled (optional, boolean), OnActivated (optional, function)
	local SwitchedValue = Util.Fallback(Props.Switched, Value(Scope, false)) -- Harus berupa Value object
	local Disabled = Util.Fallback(Props.Disabled, false)
	local OnActivated = Util.Fallback(Props.OnActivated, function() end)

	return Scope:SwitchGroup {
		Name = Props.Name or "SettingToggle",
		AutomaticSize = Enum.AutomaticSize.Y,
		Switched = SwitchedValue,
		Disabled = Disabled,
		LayoutOrder = Props.LayoutOrder or 0,

		-- Tambahkan OnActivated untuk menangani klik pada seluruh area
		OnActivated = function(newSwitchedState)
			-- Update state jika tidak disabled
			if not Fusion.peek(Disabled) then
				SwitchedValue:set(newSwitchedState)
				OnActivated(newSwitchedState) -- Panggil callback dari props jika ada
			end
		end,

		[Children] = {
			Scope:Text {
				Name = "Label",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Text = Props.Label or "Setting Label",
				TextColor3 = Theme.Colors.BaseContent.Main,
				TextTransparency = Computed(Scope, function(Use)
					return Use(Disabled) and DISABLED_TRANSPARENCY or 0
				end),
				TextWrapped = false,
				TextXAlignment = Enum.TextXAlignment.Left, -- Pastikan teks rata kiri
				Size = UDim2.new(1, -50, 0, 20), -- Beri ruang untuk switch input
				AutomaticSize = Enum.AutomaticSize.None,
			},
			Scope:SwitchInput {
				Name = "Switch",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Switched = SwitchedValue,
				Disabled = Disabled,
				Selectable = false,
			},
		},
	}
end