-- パケット送信に関するライブラリ

_utils = _utils or {}
_utils.packet = true
_utils.get = _utils.get or require 'libs/util/get'

util = util or {}
util.packet = {}

-- 持っているアイテムをID/オーグメント指定で捨てる
-- カウント指定した場合は指定個数だけ捨てる
function util.packet.drop_item(item_id, augment_string, count)

	util.get('items', false)
	local item = util.find_item('inventory', item_id, augment_string)
	if item == nil then
		return false
	end

	count = count or item.count

	-- ToDO server_count
	local packet_data = string.char(
		0x28,  0x06,      0, 0,
		count, 0,         0, 0,
		0,     item.slot, 0, 0xC1)

	windower.packets.inject_outgoing(0x28, packet_data)
	return true
end
