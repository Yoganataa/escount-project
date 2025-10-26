-- MyTopbarSystem/Menus/SettingsMenu.luau
local OnyxUI = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").OnyxUI)
local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").Fusion)

-- Komponen lokal
local Menu = require(script.Parent.Parent.Components.Menu)
local SettingToggle = require(script.Parent.Parent.Components.SettingToggle)
local Icons = require(script.Parent.Parent.Components.Icons) -- Opsional

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Util = OnyxUI.Util
local Value = Fusion.Value
local Computed = Fusion.Computed

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	-- Props expected: IsOpen (Value object), UserSettingsState (Value object), SetSettingCallback (function)
	local IsOpen = Util.Fallback(Props.IsOpen, Value(Scope, false))
	local UserSettingsState = Util.Fallback(Props.UserSettingsState, Value(Scope, { MuteMusic = false, HideUI = false }))
	local SetSettingCallback = Util.Fallback(Props.SetSettingCallback, function() end)

	-- Handler untuk toggle
	local function handleToggle(settingName, newState)
		local currentSettings = Fusion.peek(UserSettingsState)
		currentSettings[settingName] = newState
		SetSettingCallback(currentSettings) -- Panggil callback untuk update state utama
	end

	return Scope:Menu {
		Name = "SettingsMenu",
		Open = IsOpen,
		Parent = Props.Parent,
		Size = UDim2.fromOffset(305, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		TopbarYPosition = Props.TopbarYPosition, -- Teruskan state posisi Y topbar

		[Children] = {
			Scope:Scroller {
				Name = "SettingsList",
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)), -- Sesuaikan tinggi jika perlu
				AutomaticSize = Enum.AutomaticSize.None,
				ScrollBarThickness = Theme.StrokeThickness["1"],
				Padding = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.StrokeThickness["1"])) end),
				PaddingRight = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.Spacing["1"])) end),
				ListEnabled = true,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Frame { -- Kontainer untuk toggle settings
						ListEnabled = true,
						ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
						LayoutOrder = 1,

						[Children] = {
							Scope:SettingToggle {
								Label = "Mute music",
								Switched = Computed(Scope, function(Use) return Use(UserSettingsState).MuteMusic end),
								OnActivated = function(newState) handleToggle("MuteMusic", newState) end,
							},
							Scope:SettingToggle {
								Label = "Hide UI",
								Switched = Computed(Scope, function(Use) return Use(UserSettingsState).HideUI end),
								OnActivated = function(newState) handleToggle("HideUI", newState) end,
							},
						},
					},
					-- Divider (opsional, seperti di Rorooms)
					Scope:Divider{ LayoutOrder = 2 },

					-- Tombol About (atau versi seperti di Rorooms)
					Scope:Button {
						Name = "AboutButton", -- Ganti nama jika ini tombol About
						LayoutOrder = 3,
						Content = { "About My Project" }, -- Ganti teks
						-- Tambahkan OnActivated jika perlu
					},
					-- Tambahkan elemen lain jika perlu
				},
			},
		},
	}
end