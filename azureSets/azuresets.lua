--[[
Copyright (c) 2013, Ricky Gall
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of azureSets nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL The Addon's Contributors BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name = 'AzureSets'
_addon.version = '1.25J'
_addon.author = 'apo3(base:Nitrous)'
_addon.commands = {'aset', 'azuresets', 'asets'}

require('tables')
require('strings')
require('logger')
local config = require('config')
local res = require('resources')
local chat = require('chat')
local spells = res.spells:type('BlueMagic')

local spellinfo = require('res/spellinfo')
for id, fixes_spell in pairs(spellinfo) do
    local resource_spell = spells[id]
    if resource_spell and fixes_spell and fixes_spell.cost then
        resource_spell.blu_point_cost = fixes_spell.cost
    end
end

defaults = {}
defaults.setmode = 'PreserveTraits'
defaults.setspeed = 0.65
defaults.spellsets = {}
defaults.spellsets.default = T{}
defaults.spellsets.default1 = T{slot01='', slot02='', slot03='', slot04='',
slot05='', slot06='', slot07='', slot08='',slot09='', slot10=''
}
defaults.spellsets.default2 = T{slot01='', slot02='', slot03='', slot04='',
slot05='', slot06='', slot07='', slot08='', slot09='', slot10=''
}

local settings = config.load(defaults)
local BLU_JOB_ID = 16

local currentSpellSet = nil
local bluJobLevel = nil
local bluPointsMax = nil
local bluSlots = nil
local get_blu_job_data = nil

function initialize()
    update_blu_info()
    update_current_spellset()
end

windower.register_event('load', initialize:cond(function() return windower.ffxi.get_info().logged_in end))

windower.register_event('login', initialize)

windower.register_event('job change', initialize)

function update_blu_info(player)
    player = player or windower.ffxi.get_player()
    if player.main_job_id == BLU_JOB_ID then
        bluJobLevel = player.main_job_level

        if player.main_job_level > 70 then
            bluSlots = 20
        else
            bluSlots = (math.floor((player.sub_job_level + 9) / 10) * 2) + 4
        end
        
        --Noct用青魔法ポイント。組み合わせによって60～数字を調整する
        bluPointsMax = 60
        --以下一行オリジナルの計算式
        --bluPointsMax = (math.floor((player.main_job_level + 9) / 10) * 5) + 5
        if player.main_job_level >= 75 then
            bluPointsMax = bluPointsMax + player.merits.assimilation
            if player.main_job_level == 99 then
                bluPointsMax = bluPointsMax + player.job_points.blu.blue_magic_point_bonus
            end
        end

        get_blu_job_data = windower.ffxi.get_mjob_data
    elseif player.sub_job_id == BLU_JOB_ID then
        bluJobLevel = player.sub_job_level
        bluSlots = 20
        --Noct用青魔法ポイント。組み合わせによって55～数字を調整する
        bluPointsMax = 65
        --以下二行オリジナルの計算式
        --bluSlots = (math.floor((player.sub_job_level + 9) / 10) * 2) + 4
        --bluPointsMax = (math.floor((player.sub_job_level + 9) / 10) * 5) + 5
        get_blu_job_data = windower.ffxi.get_sjob_data
    else
        bluJobLevel = nil
        bluSlots = nil
        bluPointsMax = nil
        get_blu_job_data = nil
    end
end

function set_spells(spellset, setmode)
    if not bluJobLevel then
        error('You are not a Blue Mage.')
        return
    end
    if settings.spellsets[spellset] == nil then
        error('Set not defined: '..spellset)
        return
    end
    if is_spellset_equipped(settings.spellsets[spellset]) then
        log(spellset..' was already equipped.')
        return
    end

    log('Starting to set '..spellset..'.')
    if setmode:lower() == 'clearfirst' then
        remove_all_spells()
        set_spells_from_spellset:schedule(settings.setspeed, spellset, 'add')
    elseif setmode:lower() == 'preservetraits' then
        set_spells_from_spellset(spellset, 'remove')
    else
        error('Unexpected setmode: '..setmode)
    end
end

function is_spellset_equipped(spellset)
    return S(spellset):map(string.lower) == S(update_current_spellset())
end

function set_spells_from_spellset(spellset, setPhase)
    local setToSet = settings.spellsets[spellset]
    update_current_spellset()

    if setPhase == 'remove' then
        -- Remove Phase
        for k, v in pairs(currentSpellSet) do
            if not setToSet:contains(v:lower()) then
                setSlot = k
                local slotToRemove = tonumber(k:sub(5, k:len()))

                windower.ffxi.remove_blue_magic_spell(slotToRemove)
                set_spells_from_spellset:schedule(settings.setspeed, spellset, 'remove')
                return
            end
        end
    end
    -- Did not find spell to remove. Start set phase
    -- Find empty slot:
    local slotToSetTo
    for i = 1, 20 do
        local slotName = 'slot%02u':format(i)
        if currentSpellSet[slotName] == nil then
            slotToSetTo = i
            break
        end
    end

    if slotToSetTo ~= nil then
        -- We found an empty slot. Find a spell to set.
        for k, v in pairs(setToSet) do
            if not currentSpellSet:contains(v:lower()) then
                if v ~= nil then
                    local spellID = find_spell_id_by_name(v)
                    if spellID ~= nil then
                        local verified = verify_and_set_spell(spellID, tonumber(slotToSetTo))
                        if verified then
                            set_spells_from_spellset:schedule(settings.setspeed, spellset, 'add')
                        end
                        return
                    end
                end
            end
        end
    end

    -- Unable to find any spells to set. Must be complete.
    log(spellset..' has been equipped.')
    windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
end

function find_spell_id_by_name(spellname)
    for spell in spells:it() do
        if spell['japanese']:lower() == spellname:lower() then
            return spell['id']
        end
    end
    return nil
end

function set_single_spell(setspell, slot)
    if not bluJobLevel then return nil end

    update_current_spellset()
    for key, val in pairs(currentSpellSet) do
        if currentSpellSet[key]:lower() == setspell then
            error('That spell is already set.')
            return
        end
    end
    if tonumber(slot) < 10 then slot = '0'..slot end
    --insert spell add code here
    local spellId = find_spell_id_by_name(setspell)
    if spellId then
        local verified = verify_and_set_spell(spellId, tonumber(slot))
        if verified then
            windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
            currentSpellSet['slot'..slot] = setspell
        end
    end
end

function update_current_spellset(player)
    if not get_blu_job_data then
        currentSpellSet = nil
        return nil
    end

    currentSpellSet = T(get_blu_job_data().spells)
    -- Returns all values but 512
    :filter(function(id) return id ~= 512 end)
    -- Transforms them from IDs to lowercase japanese names
    :map(function(id) return spells[id].japanese:lower() end)
    -- Transform the keys from numeric x or xx to string 'slot0x' or 'slotxx'
    :key_map(function(slot) return 'slot%02u':format(slot) end)
    return currentSpellSet
end

function remove_all_spells(trigger)
    windower.ffxi.reset_blue_magic_spells()
    notice('All spells removed.')
end

function save_set(setname)
    if setname == 'default' then
        error('Please choose a name other than default.')
        return
    end
    update_current_spellset()
    settings.spellsets[setname] = currentSpellSet
    settings:save('all')
    notice('Set '..setname..' saved.')
end

function delete_set(setname)
    if settings.spellsets[setname] == nil then
        error('Please choose an existing spellset.')
        return
    end    
    settings.spellsets[setname] = nil
    settings:save('all')
    notice('Deleted '..setname..'.')
end

function get_spellset_list()
    log("Listing sets:")
    for key,_ in pairs(settings.spellsets) do
        if key ~= 'default' then
            local it = 0
            for i = 1, #settings.spellsets[key] do
                it = it + 1
            end
            log("\t"..key..' '..settings.spellsets[key]:length()..' spells.')
        end
    end
end

function get_spellset_content(spellset)
    log('Getting '..spellset..'\'s spell list:')
    settings.spellsets[spellset]:print()
end

function verify_and_set_spell(id, slot)
    local spell = spells[id]
    local errorMessage = nil
    if not spell then
        errorMessage = "spell not found"
    end
	--ジョブレベルチェック機能を削除
    --if bluJobLevel and spell.levels and spell.levels[BLU_JOB_ID] and spell.levels[BLU_JOB_ID] > bluJobLevel then
    --    errorMessage = "job level too low to set spell"
    --end

    --BluePointが足りない場合はエラーメッセージを出す
    if not have_enough_points_to_add_spell(id) then
        errorMessage = "cannot set spell, ran out of blue magic points"
    end
    if slot > bluSlots then
        errorMessage = "slot " .. tostring(slot) .. " unavailable"
    end

    if errorMessage then
        error(errorMessage)
        return false
    end

    windower.ffxi.set_blue_magic_spell(id, slot)
    return true
end

function have_enough_points_to_add_spell(spellId)
    local spell = spells[spellId]
    if not spell or not spell.blu_point_cost then
        return nil
    end
    return spell.blu_point_cost + current_total_points_spent() <= bluPointsMax
end

function current_total_points_spent()
    local total = 0
    for _, spellId in pairs(get_blu_job_data().spells) do
        local spell = spells[spellId]
        if spell and spell.blu_point_cost then
            total = total + spell.blu_point_cost
        end
    end
    return total
end

windower.register_event('addon command', function(...)
    if not bluJobLevel then
        error('You are not a Blue Mage.')
        return nil
    end
    local args = T{...}
    if args ~= nil then
        local comm = table.remove(args, 1):lower()
        if comm == 'removeall' then
            remove_all_spells('trigger')
        elseif comm == 'add' then
            if args[2] ~= nil then
                local slot = table.remove(args, 1)
                local spell = windower.from_shift_jis(args:sconcat())
                set_single_spell(spell:lower(), slot)
            end
        elseif comm == 'save' then
            if args[1] ~= nil then
                save_set(args[1])
            end
        elseif comm == 'delete' then
            if args[1] ~= nil then
                delete_set(args[1])
            end
        elseif comm == 'spellset' or comm == 'set' then
            if args[1] ~= nil then
                set_spells(args[1], args[2] or settings.setmode)
            end
        elseif comm == 'currentlist' then
            update_current_spellset():print()
        elseif comm == 'setlist' then
            get_spellset_list()
        elseif comm == 'spelllist' then
            if args[1] ~= nil then
                get_spellset_content(args[1])
            end
        elseif comm == 'help' then
            local helptext = [[AzureSets - Command List:')
1. removeall - セットされている青魔法を全て解除します。
    例：//aset removeall
2. spellset <setname> [ClearFirst|PreserveTraits] -- 登録済スペルセットを実行します。
    例1：//aset spellset rdm → スペルセット"rdm"をセットします。
    例2：//aset spellset rdm ClearFirst → 現在セットされている青魔法を全て解除してからスペルセット"rdm"をセットします。
    例3：//aset spellset rdm PreserveTraits → 現在セットされている青魔法と"rdm"の差分を入れ替えします。
    オプションコマンドを指定しない場合は差分入れ替えを実行します。
3. set <setname> (ClearFirst|PreserveTraits) -- spellsetと同義。略式です。
4. add <slot> <spell> -- 指定したスロットの青魔法を入れ替えます。
    例：//aset add 1 サイレントストーム
5. save <setname> -- 現在セットされている青魔法を保存します。
    例：//aset save rdm2
6. delete <setname> -- 保存済のスペルセットを削除します。
    例：//aset delete rdm2
7. currentlist -- 現在セットされている青魔法を表示します。
8. setlist -- 保存済のスペルセット一覧を表示します。
9. spelllist <setname> -- 保存済スペルセットに登録されている青魔法を表示します。
    例：//aset spelllist rdm
10. help --ヘルプメニューを表示します。]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.controls.reset)
            end
        end
    end
end)
