-- ファイル操作に関するライブラリ

_utils = _utils or {}
_utils.file = true
_utils.get = _utils.get or require 'libs/util/get'
_utils.log = _utils.log or require 'libs/util/log'

util = util or {}
util.file = {}


-- アイテムリストのファイルから
-- ID・オーグメント情報の配列を生成する
function util.file.list_by_text(dir, name)

	local player_name = util.get('me', false).name:lower()
	local filename = dir .. '/' .. player_name .. '/' .. name
	
	-- <dir>\<プレイヤー名>\<name>
	-- <dir>\<プレイヤー名>\<name>.txt
	-- <dir>\<name>
	-- <dir>\<name>.txt の順でファイル検索する
	if files.exists(filename) == false then
		filename = filename .. '.txt'
	end
	if files.exists(filename) == false then
		filename = dir .. '/' .. name
	end
	if files.exists(filename) == false then
		filename = filename .. '.txt'
	end
	if files.exists(filename) == false then
		return nil
	end
	
	local lines = files.readlines(filename)
	local ids = T{}
	local index, line
	
	for index, line in ipairs(lines) do
		-- アイテム名でIDが見つかったら追加する
		line = windower.from_shift_jis(line)
		
		if line:find('^#') == nil and line:find('^$') == nil then

			-- ToDO extdata対応
			local item_name = line
			local pos = item_name:find('@')
			local item_augment_string = nil
			if pos then
				item_name    = line:sub(1, pos - 1)
				item_augment_string = line:sub(pos + 1)
			end
			
			local items = util.get('item_info', true, item_name)

			if items ~= nil then
				for _, item in pairs(items) do
					ids[#ids+1] = {
						id       = item.id,
						augments = item_augment_string
					}
				end
			else
				local find = res.items:ja(item_name):length() > 0
				if find then
					util.log.info(filename .. ':' .. index .. ' [' .. item_name .. '] 未所持の為スキップ');
				else
					util.log.error(filename .. ':' .. index .. ' [' .. item_name .. '] 対応するIDが存在しません');
				end
			end
		end
	end
	
	return ids
end
