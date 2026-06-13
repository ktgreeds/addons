_addon.name = 'JazeroPacketSwitch'
_addon.author = 'ktgreeds'
_addon.version = '1.0'
_addon.commands = {'sw','JazeroPacketSwitch'}

local switch = true

windower.register_event('addon command', function(...)
    if switch then
        windower.send_command('unload packetflow; unload jazero;')
        windower.add_to_chat(167,windower.to_shift_jis('■■■ アンロード JazeroPacketSwitch ■■■'))
    else
        
        windower.send_command('load packetflow; load jazero;')
        windower.add_to_chat(167,windower.to_shift_jis('■■■ ロード JazeroPacketSwitch ■■■'))
    end
    switch = not switch  -- 'not'演算子でブール値を反転させる
end)