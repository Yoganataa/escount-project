-- MyTopbarSystem/Menus/ShopMenu.luau
local OnyxUI = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").OnyxUI)
local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages").Fusion)
local Menu = require(script.Parent.Parent.Components.Menu)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Util = OnyxUI.Util
local Value = Fusion.Value
local Computed = Fusion.Computed

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local IsOpen = Util.Fallback(Props.IsOpen, Value(Scope, false))

	return Scope:Menu {
		Name = "ShopMenu",
		Open = IsOpen,
		Parent = Props.Parent,
		Size = UDim2.fromOffset(300, 200), -- Ukuran contoh
		TopbarYPosition = Props.TopbarYPosition,

		[Children] = {
			Scope:Text { Text = "Shop Menu Placeholder" }
			-- Tambahkan elemen UI Shop di sini
		}
	}
end