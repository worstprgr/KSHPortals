-- This addon is using the GLWTS License. See the `LICENSE` file for more information.
-- s/o to ThePrimagen for this incredible license template

local KSHPortals, NS = ...

local portals = NS.portals
local portals_order = NS.portals_order
local KSHPortalsFrame = CreateFrame("Frame")

SLASH_KSHPORTALS1 = "/tp"

-- Portal confirm button
local confirm_button = CreateFrame("Button", "ksh_confirm", UIParent,
                         "SecureActionButtonTemplate")
local confirm_button_size = 48

confirm_button:SetSize(confirm_button_size, confirm_button_size)
confirm_button:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
confirm_button:GetHighlightTexture():SetAlpha(0.5)
confirm_button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
confirm_button:SetAttribute("type", "spell")


-- Creates a button, where the player has to confirm the teleport  
--
-- :param spell_id: (int) The spell id of the teleport spell
-- :return: None
local function confirm_command(spell_id)
    KSHPortalsFrame:RegisterEvent("GLOBAL_MOUSE_UP")
    local _, _, spell_icon_id = GetSpellInfo(spell_id)
    local scale, x, y = confirm_button:GetEffectiveScale(), GetCursorPosition()
    confirm_button:SetNormalTexture(spell_icon_id)
    confirm_button:SetPoint("CENTER", nil, "BOTTOMLEFT", x/scale, y/scale)
    confirm_button:Show()
    confirm_button:SetAttribute("spell", spell_id)
end


-- Text colors
local gold = "ffe8b948"
local light_blue = "ff48b5e8"


local function text_color(hex_color, msg)
    return "\124c" .. hex_color .. msg .. "\124r"
end


-- Checks, if the user input `/tp <input>` exists in the list of 
-- `portals.lua: NS.portals`  
-- Additionally, it checks, if the spell is even kown by the player.
--
-- :param command: (str) The user input after `/tp`
-- :return: (bool)
local function check_command(command)
    for _, key in ipairs(portals_order) do
        local order_value = portals[key]
        for abbrev, spell_pair in pairs(order_value[2]) do
            if abbrev == command and IsSpellKnown(spell_pair[2]) then
                return true
            end
        end
    end
    return false
end


-- Performs certain actions, depending on the player input `/tp <input>`  
-- If the input is empty or "help", it lists all teleports, that are kown 
-- to the player.  
-- If da input is valid, it will trigger the confirm button.  
--
-- :param chat_input: (str) The abbreviation of a teleport
-- :return: None
local function use_portal(chat_input)
    if chat_input == "" or chat_input == "help" then
        print(text_color(gold, "Available Portals"))

        for _, key in ipairs(portals_order) do
            local order_value = portals[key]
            print("  " .. text_color(gold, "- " .. order_value[1]))

            for abbrev, spell_pair in pairs(order_value[2]) do
                if IsSpellKnown(spell_pair[2]) then
                    print("        " .. text_color(gold, abbrev) .. ": "
                          .. text_color(light_blue, spell_pair[1]))
                end
            end
        end
        return
    end

    if not check_command(chat_input) then
        print(text_color(gold, "KSH Portals") ..
                         ": unkown command or spell not learned.")
        return
    end

    for _, key in ipairs(portals_order) do
        local order_value = portals[key]
        for abbrev, spell_pair in pairs(order_value[2]) do
            if abbrev == chat_input then
                confirm_command(spell_pair[2])
            end
        end
    end
end


SlashCmdList["KSHPORTALS"] = use_portal


KSHPortalsFrame:SetScript("OnEvent", function()
    if confirm_button:IsShown() then
        confirm_button:Hide()
        KSHPortalsFrame:UnregisterEvent("GLOBAL_MOUSE_UP")
    end
end)

