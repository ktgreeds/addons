_addon.name = 'MonitoringSortie'
_addon.author = 'ktgreeds'
_addon.version = '1.0'
_addon.commands = {'ms'}

require('sets')
require('chat')

filter_mode_enemy = S {100,105,110,111,158}
windower.register_event("incoming text", function(original, modified, original_mode, modified_mode, blocked)
    if filter_mode_enemy:contains(original_mode) then
        if windower.wc_match(original, windower.to_shift_jis('*シュリーキングゲイル*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 土　弱点'))

        elseif windower.wc_match(original, windower.to_shift_jis('*アンジュレティングショックウェーブ*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 氷　弱点'))
        
        elseif windower.wc_match(original, windower.to_shift_jis('*フレミングキック*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 水　弱点'))
        
        elseif windower.wc_match(original, windower.to_shift_jis('*アイシーグラスプ*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 火　弱点'))
        
        elseif windower.wc_match(original, windower.to_shift_jis('*エローディングフレッシュ*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 風　弱点'))
        
        elseif windower.wc_match(original, windower.to_shift_jis('*ファルミナススマッシュ*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 土　弱点'))
        
        elseif windower.wc_match(original, windower.to_shift_jis('*フラッシュフラッド*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ 雷　弱点'))

        end
    end
end)

windower.register_event('addon command', function(...)                          
    local args = {...}
    local element = windower.from_shift_jis(args[1])  -- 氷、火、水など

    if not element then return end

    local target = windower.ffxi.get_mob_by_target('t')
    if not target then return end

    local name = target.name

    if name == 'Leshon' or name == 'Gartell'  then
        if element == "土" then
            --windower.send_command('input /p '..windower.to_shift_jis("シュリーキングゲイル → 弱点：土 <scall20>"))
        elseif element == "氷" then
            --windower.send_command('input /p '..windower.to_shift_jis("アンジュレティングショックウェーブ → 弱点：氷 <scall20>"))
        end
    elseif name == 'Degei' or name == 'Aita' then
        if element == "水" then
            windower.send_command('input /p '..windower.to_shift_jis("フレミングキック（　弱点：水　）<scall20>"))
        elseif element == "火" then
            windower.send_command('input /p '..windower.to_shift_jis("アイシーグラスプ（　弱点：火　）<scall20>"))
        elseif element == "風" then
            windower.send_command('input /p '..windower.to_shift_jis("エローディングフレッシュ（　弱点：風　）<scall20>"))
        elseif element == "土" then
            windower.send_command('input /p '..windower.to_shift_jis("ファルミナススマッシュ（ 弱点：土 ）<scall20>"))
        elseif element == "雷" then
            windower.send_command('input /p '..windower.to_shift_jis("フラッシュフラッド（ 弱点：雷 ）<scall20>"))
        end
    end
end)