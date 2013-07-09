include( "shared.lua" )
--net stiff
net.Receive("HitScaleSender", function( length, client )
       hitscale = net.ReadFloat()
       print(length)
   end)


--HUD
local function hud()
	mx = ScrW()*.5
	my = ScrH()*.5
	draw.SimpleText( "You hit with "..hitscale.."% force", "Trebuchet18", mx, my, Color(0,0,0), 1)
end

hook.Add("HUDPaint", "drawstuff", hud)

--Derma
local mx = ScrW()*.5
local my = ScrH()*.5

local sx = 1000
local sy = 750
local pmodels = {
	"models/player/alyx.mdl",
	"models/player/breen.mdl",
	"models/player/barney.mdl",
	"models/player/eli.mdl",
	"models/player/gman_high.mdl",
	"models/player/kleiner.mdl",
	"models/player/monk.mdl",
	"models/player/odessa.mdl",
	"models/player/magnusson.mdl",
	"models/player/Police.mdl",
	"models/player/Combine_Soldier.mdl",
	"models/player/Combine_Soldier_PrisonGuard.mdl",
	"models/Combine_Super_Soldier.mdl",

}
local function UpdateModelDisplay(model)
	--ModelDisplay:SetModel(model)
	print(ModelDisplay:SetModel(model))
end

local plmodel = LocalPlayer():GetModel()



local function sendmodel()
	net.Start("ModelSender")
	net.WriteString(LocalPlayer():GetPData("PlModel", "undefined"))
	net.SendToServer()
end

local function SetUpMenu()
	local setupmenu = vgui.Create("DFrame")
	setupmenu:SetPos(mx-sx*.5,my-sy*.5)
	setupmenu:SetSize(sx,sy)
	setupmenu:SetTitle("Initial Setup")
	setupmenu:SetVisible(true)
	setupmenu:SetDraggable(true)
	setupmenu:ShowCloseButton(true)
	setupmenu:SetDeleteOnClose(true)
	setupmenu:MakePopup()

		local ModelPanel = vgui.Create( "DPanel", setupmenu )
		ModelPanel:SetPos(10,30)
		ModelPanel:SetSize(300,710)
		ModelPanel:SetBackgroundColor(Color(255,255,255,100))

			local mptext = vgui.Create("DLabel", ModelPanel)
			mptext:SetPos(5,5)
			mptext:SetSize(300,10)
			mptext:SetText("Please select a model:")
			mptext:SetDark(true)

			local ModelList = vgui.Create("DListView", ModelPanel)
			ModelList:SetPos(5,25)
			ModelList:SetSize(290,680)
			ModelList:SetMultiSelect(false)
			ModelList:AddColumn("Model")
			for k, v in pairs(pmodels) do
				ModelList:AddLine(v)
			end
			ModelList.OnClickLine = function(parent, line, selected)
				UpdateModelDisplay(line:GetValue(1))
				plmodel = line:GetValue(1)
			end

		local SelectionPanel = vgui.Create("DPanel", setupmenu)
		SelectionPanel:SetPos(320, 30)
		SelectionPanel:SetSize(670, 710)
		SelectionPanel:SetBackgroundColor(Color(255,255,255,100))
		SelectionPanel.Paint = function()
			draw.SimpleText("You can always change your playermodel with the f2 menu in the models tab.", "Trebuchet18", 335 ,640, Color(0,255,0) ,TEXT_ALIGN_CENTER)
		end

			ModelDisplay = vgui.Create("DModelPanel", SelectionPanel)
			ModelDisplay:SetPos(5,5)
			ModelDisplay:SetSize(660,500)
			function ModelDisplay:LayoutEntity( Entity ) return end
			ModelDisplay:SetModel(LocalPlayer():GetModel())

			local SelectButton = vgui.Create("DButton", SelectionPanel)
			SelectButton:SetPos(5,505)
			SelectButton:SetSize(660,100)
			SelectButton:SetText("Select")
			SelectButton.DoClick = function()
				LocalPlayer():SetPData("PlModel", plmodel)
				print(LocalPlayer():GetPData("PlModel", "undefined" ))
				sendmodel()
				end
			
end




concommand.Add("SetUpMenu", SetUpMenu)




function GM:PostDrawViewModel( vm, ply, weapon )

  if ( weapon.UseHands || !weapon:IsScripted() ) then
    local hands = LocalPlayer():GetHands()
    if ( IsValid( hands ) ) then hands:DrawModel() end

  end

end




--IGNORE :Dis()

