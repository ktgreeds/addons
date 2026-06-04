_addon.name = 'MonitoringSortie'
_addon.author = 'ktgreeds'
_addon.version = '1.0'

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