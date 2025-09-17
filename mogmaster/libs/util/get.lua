-- 各種データを取得するライブラリ
-- 変数にキャッシュするので2回目以降は高速に動作

-- 各種情報を取得
-- util.get(name, use_cache, param)
-- name       取得する情報。
--           'player', 'me', 'items', 'item_info' が利用可能
-- use_cache キャッシュの利用有無。省略時はtrue
-- param     取得する際の追加情報。
--           item_info: 取得するアイテムID or名称
--           その他の情報取得時は指定不要

-- player形式の自身の情報を取得
-- util.get('player')
-- util.get('player', false)

-- mob形式の自身の情報を取得
-- util.get('me')
-- util.get('me', false)

-- かばん配列をマスタ情報付きで取得
-- util.get('items')
-- util.get('items', false)

-- アイテムマスタの情報を取得
-- util.get('item_info', true, id_or_name)
-- util.get('item_info', false, id_or_name)

_utils = _utils or {}
_utils.get = true
_utils.const = _utils.const or require 'libs/util/const'
_utils.log = _utils.log or require 'libs/util/log'

util = util or {}


-- getライブラリが使うキャッシュ情報
util.get_cache = {

	-- get_player形式の自身のデータのキャッシュ
	player = nil,
		
	-- mob形式の自身のデータのキャッシュ
	me     = nil,
		
	-- かばんのキャッシュ
	items  = nil,
		
	-- アイテムマスタのキャッシュ
	_item_master  = T{}
}
-- 各種データを取得する
-- キャッシュされてあればキャッシュから取得する
-- 現状実装している項目名 'player', 'me', 'items'
function util.get(name, use_cache, param)
	if use_cache == nil then
		use_cache = true
	end
	
	if util.get_cache[name] == nil or use_cache == false then
		if type(util['load_' .. name]) == 'function' then
			return util['load_' .. name](param)
		else
			
		end
	end
	return param and util.get_cache[name][param] or util.get_cache[name]
end


-- 自身のプレイヤー情報を取得
function util.load_player()
	util.get_cache.player = windower.ffxi.get_player()
	return util.get_cache.player
end

-- mob形式での自身の情報を取得
function util.load_me()
	 util.get_cache.me = windower.ffxi.get_mob_by_target('me')
	 return util.get_cache.me
end

-- アイテム情報を取得
-- 取得時にマスタのデータも'info' のキーで入れておく
function util.load_items()
	local ffxi_items = windower.ffxi.get_items()
	
	-- 所持アイテムのキャッシュデータ初期化
	util.get_cache.items = T{}
	
	for bag_name, bag in pairs(util.const.bags) do
		-- 所持アイテムのキャッシュは検索とかも使いたいので、
		-- T-table形式で保存する
		-- http://dev.windower.net/doku.php?id=lua:writing_addons#tables
		util.get_cache.items[bag_name] = T{}
		
		local index, item
		for index, item in ipairs(ffxi_items[bag_name]) do
			
			if item.count > 0 and item.id ~= 0 and item.id ~= 65535 then
				util._set_item_master(item.id)

				item.info  = util.get_cache._item_master[item.id]
				if item.info then
					util.get_cache.items[bag_name]:append(item)
				end
				
			end
		end
	end
	
	return util.get_cache.items
end

-- アイテム情報を取得する
-- 名称で取得した場合は配列で返却
-- (1名称で複数IDが存在しうる為)
function util.load_item_info(item_id_or_name)
	local info = util.get_cache._item_master[item_id_or_name]

	if info == nil and util.get_cache.items == nil then
		-- キャッシュになかったら所持アイテムをリロードして再取得
		-- (いきなりマスタに行くと重い)
		util.load_items()
		info = util.get_cache._item_master[item_id_or_name]
	end

	if info == nil then
		-- 所持アイテムにも無かったらリソース検索してマスタ登録する
		util._set_item_master(item_id_or_name)
		info = util.get_cache._item_master[item_id_or_name]
	end
	return info
end

-- アイテムマスタをキャッシュ登録する
function util._set_item_master(item_id_or_name)

	-- キャッシュを持っていたら何もしない
	if util.get_cache._item_master[item_id_or_name] ~= nil then
		return
	end
	
	local item_info_data
	if type(item_id_or_name) == 'number' then
		-- 数値が渡されたらアイテムのマスタからそのまま取得
		item_info_data = T{
			[item_id_or_name] = res.items[item_id_or_name]
		}
	elseif type(item_id_or_name) == 'string' then
		item_info_data = res.items:ja(item_id_or_name)
	else
		util.error_log('[util.get(_set_item_master)] 不明な形式が渡されました')
	end
	
	if item_info_data:length() > 0 then

		local item_id, item_info
		for item_id, item_info in pairs(item_info_data) do

			-- idキーの情報をキャッシュに保存
			util.get_cache._item_master[item_id] = item_info
			
			-- 名称キーの情報をキャッシュに保存
			if util.get_cache._item_master[item_info.ja] == nil then
				util.get_cache._item_master[item_info.ja] = T{}
			end
			util.get_cache._item_master[item_info.ja][item_id] = item_info
		end
	else
		util.log.error('[util.get(_set_item_master)]"' .. item_id_or_name .. '" がマスタに見つかりません')
	end
end
