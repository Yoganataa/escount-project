-- MyTopbarSystem/init.client.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)

-- Komponen & Menu Lokal
local ComponentsFolder = script:WaitForChild("Components")
local MenusFolder = script:WaitForChild("Menus")
local Icons = require(ComponentsFolder.Icons) -- Opsional
local TopbarButton = require(ComponentsFolder.TopbarButton)
local SettingsMenu = require(MenusFolder.SettingsMenu)
local ShopMenu = require(MenusFolder.ShopMenu)
local AboutMenu = require(MenusFolder.AboutMenu)
local OnyxUITheme = require(script.OnyxUITheme) -- Opsional, jika kamu punya tema custom

local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local ForPairs = Fusion.ForPairs
local Spring = Fusion.Spring
local Themer = OnyxUI.Themer
local Util = OnyxUI.Util

-- Setup Tema OnyxUI
local AppScope = Fusion.scoped(Fusion)
local AppTheme = Themer.NewTheme(AppScope, OnyxUITheme or {}) -- Gunakan tema custom atau default

-- State Aplikasi
local CurrentMenu = Value(AppScope, nil) -- Nama menu yang sedang terbuka (string) atau nil
local TopbarVisible = Value(AppScope, true)
local TopbarYPosition = Value(AppScope, 0) -- Untuk posisi menu
local TopbarButtonsHeight = Value(AppScope, 45) -- Tinggi default tombol topbar
local UserSettings = Value(AppScope, {
	MuteMusic = false,
	HideUI = false,
})

-- Fungsi untuk update state
local function SetCurrentMenu(menuName)
	CurrentMenu:set(menuName)
end

local function SetUserSetting(newSettingsTable)
	UserSettings:set(newSettingsTable)
end

-- Konfigurasi Tombol Topbar
local buttonsConfig = {
	Shop = {
		MenuName = "ShopMenu",
		Icon = Icons.Topbar.Shop.Outlined, -- Ganti dengan ikonmu
		IconFilled = Icons.Topbar.Shop.Filled, -- Ganti dengan ikonmu
		LayoutOrder = 1,
	},
	Settings = {
		MenuName = "SettingsMenu",
		Icon = Icons.Topbar.Settings.Outlined,
		IconFilled = Icons.Topbar.Settings.Filled,
		LayoutOrder = 2,
	},
	About = {
		MenuName = "AboutMenu",
		Icon = Icons.Topbar.About.Outlined, -- Ganti dengan ikonmu
		IconFilled = Icons.Topbar.About.Filled, -- Ganti dengan ikonmu
		LayoutOrder = 3,
	},
}

-- Logika untuk Hide UI
Observer(AppScope, UserSettings):onChange(function()
	local hide = Fusion.peek(UserSettings).HideUI
	local coreGuisToToggle = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList } -- Sama seperti Rorooms

	for _, coreGuiType in ipairs(coreGuisToToggle) do
		StarterGui:SetCoreGuiEnabled(coreGuiType, not hide)
	end
	TopbarVisible:set(not hide)
	if hide then
		CurrentMenu:set(nil) -- Tutup menu saat UI disembunyikan
	end
end)

-- Komponen UI Utama
local function App(Scope)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, OnyxUI.Components)
	local Theme = Themer.Theme:now() -- Ambil tema saat ini

	-- State lokal untuk UI Dragger (jika ingin implementasi drag seperti Rorooms)
	local isDragging = Value(Scope, false)
	local dragStartY = Value(Scope, 0)

	-- Update posisi Y topbar untuk menu
	local topbarPullyRef = Value(Scope, nil)
	Observer(Scope, topbarPullyRef):onChange(function()
		local pully = Fusion.peek(topbarPullyRef)
		if pully then
			local function updateYPos()
				-- Hitung posisi bawah pully/dragger untuk posisi Y menu
				local bottomY = pully.AbsolutePosition.Y + pully.AbsoluteSize.Y
				TopbarYPosition:set(bottomY)
			end
			pully:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateYPos)
			pully:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateYPos)
			updateYPos() -- Panggil sekali saat inisialisasi
		end
	end)


	return Themer.Theme:is(AppTheme):during(function()
		return Scope:New "ScreenGui" {
			Name = "MyTopbarUI",
			Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

			[Children] = {
				-- Topbar Container (Mirip TopbarHUD di Rorooms)
				Scope:Frame {
					Name = "TopbarContainer",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = Spring(Scope, Computed(Scope, function(Use)
						local yOffset = 8 -- Jarak dari atas layar
						if not Use(TopbarVisible) then
							-- Geser ke atas saat disembunyikan
							yOffset = -Use(TopbarButtonsHeight) - 20 -- Sesuaikan nilai ini
						end
						return UDim2.new(0.5, 0, 0, yOffset)
					end), Theme.SpringSpeed["1"], Theme.SpringDampening["1"]),
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,

					[Children] = {
						-- Dragger Frame (Mirip Dragger di Rorooms)
						Scope:Frame {
							Name = "Dragger",
							BackgroundTransparency = 1,
							AutomaticSize = Enum.AutomaticSize.XY,
							ListEnabled = true,
							ListPadding = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.Spacing["0.5"])) end),
							ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.Spacing["0"])) end),
							PaddingBottom = Computed(Scope, function(Use)
								-- Beri padding lebih jika ada menu terbuka atau topbar tersembunyi
								if (Use(CurrentMenu) ~= nil) or (not Use(TopbarVisible)) or UserInputService.TouchEnabled then
									return UDim.new(0, Use(Theme.Spacing["3"]))
								else
									return UDim.new(0, Use(Theme.Spacing["1"]))
								end
							end),

							[Children] = {
								-- Frame untuk Tombol-Tombol
								Scope:Frame {
									Name = "TopbarButtonsFrame",
									BackgroundColor3 = Theme.Colors.Base.Main,
									BackgroundTransparency = Computed(Scope, function(Use) return Use(States.CoreGui.PreferredTransparency) end), -- Ambil dari state jika perlu
									AutomaticSize = Enum.AutomaticSize.XY,
									ListEnabled = true,
									ListPadding = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.Spacing["0.25"])) end),
									ListFillDirection = Enum.FillDirection.Horizontal,
									ListVerticalAlignment = Enum.VerticalAlignment.Center,
									CornerRadius = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.CornerRadius.Full)) end),
									Padding = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.Spacing["0.5"]) / 1.25) end),

									[Children] = ForPairs(buttonsConfig, function(Use, Scope, name, config)
										return name, Scope:TopbarButton {
											Name = name .. "Button",
											MenuName = config.MenuName,
											Icon = config.Icon,
											IconFilled = config.IconFilled,
											LayoutOrder = config.LayoutOrder,
											CurrentMenuState = CurrentMenu,
											SetCurrentMenuCallback = SetCurrentMenu,
										}
									end),
								},
								-- Pull Button (Mirip Rorooms)
								Scope:BaseButton {
									Name = "PullButton",
									[Fusion.Ref] = topbarPullyRef, -- Simpan referensi
									BackgroundTransparency = Computed(Scope, function(Use) return Use(States.CoreGui.PreferredTransparency) end), -- Ambil dari state jika perlu
									BackgroundColor3 = Theme.Colors.Base.Main,
									Visible = Computed(Scope, function(Use) return Use(CurrentMenu) == nil end), -- Sembunyikan jika menu terbuka
									TextSize = 0,
									Size = Computed(Scope, function(Use) return UDim2.fromOffset(Use(Theme.Spacing["8"]), 6) end),
									CornerRadius = Computed(Scope, function(Use) return UDim.new(0, Use(Theme.CornerRadius.Full)) end),
									StrokeColor = Theme.Colors.Neutral.Main,

									OnActivated = function()
										TopbarVisible:set(not Fusion.peek(TopbarVisible))
										CurrentMenu:set(nil) -- Tutup menu saat toggle visibility
									end,
								},
							},
						},
					},
				},

				-- Render Menu-menu
				Scope:ShopMenu {
					IsOpen = Computed(Scope, function(Use) return Use(CurrentMenu) == "ShopMenu" end),
					TopbarYPosition = TopbarYPosition,
					Parent = Fusion.Parent, -- Akan di-parent ke ScreenGui
				},
				Scope:SettingsMenu {
					IsOpen = Computed(Scope, function(Use) return Use(CurrentMenu) == "SettingsMenu" end),
					UserSettingsState = UserSettings,
					SetSettingCallback = SetUserSetting,
					TopbarYPosition = TopbarYPosition,
					Parent = Fusion.Parent,
				},
				Scope:AboutMenu {
					IsOpen = Computed(Scope, function(Use) return Use(CurrentMenu) == "AboutMenu" end),
					TopbarYPosition = TopbarYPosition,
					Parent = Fusion.Parent,
				},
			}
		}
	end)
end

-- Mount aplikasi
local appInstance = App(AppScope)

-- Cleanup saat script dihancurkan
script.Destroying:Connect(function()
	AppScope:doCleanup()
end)

print("Custom Topbar Initialized")