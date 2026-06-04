_addon.name = 'WeakMonitoring'
_addon.author = 'ktgreeds'
_addon.version = '1.0'

require('sets')
require('chat')

filter_mode_enemy = S {191}
windower.register_event("incoming text", function(original, modified, original_mode, modified_mode, blocked)
    if filter_mode_enemy:contains(original_mode) then
        if windower.wc_match(original, windower.to_shift_jis('*魔法回避率ダウン*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ フラズル切れ'))

        --elseif windower.wc_match(original, windower.to_shift_jis('*バインド*')) then
        --    windower.add_to_chat(167,windower.to_shift_jis('★★★ バインド切れ'))

        end
    end
end)
