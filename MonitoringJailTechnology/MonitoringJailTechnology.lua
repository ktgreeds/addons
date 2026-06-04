
_addon.name = 'MonitoringSortieBossTechnique'
_addon.author = 'ktgreeds'
_addon.version = '1.0'

require('sets')
require('chat')

filter_mode_enemy = S {100,105,110,111,158}
windower.register_event("incoming text", function(original, modified, original_mode, modified_mode, blocked)
    if filter_mode_enemy:contains(original_mode) then
        if windower.wc_match(original, windower.to_shift_jis('*ボルケーノステーシス*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ ボルケーノステーシス → 再強化して！'))

        elseif windower.wc_match(original, windower.to_shift_jis('*シアリングセレイト*')) then
            windower.add_to_chat(167,windower.to_shift_jis('★★★ シアリングセレイト → パナケイアして！'))
        end
    end
end)