-- かばんの検索等に関するライブラリ

_utils = _utils or {}
_utils.bag = true
_utils.info = _utils.info or require 'libs/util/info'

util = util or {}
util.bag = {}

-- 指定したストレージからアイテムを検索する
-- augment_stringはオプション
-- 見つからなかった場合はnilを返す
function util.bag.find(bag_name, item_id, augment_string, index)
	index = index or 1

	local search_items = util.get('items')[bag_name]

	local _, f
	local count = 0
	_, f = table.find(search_items, function(search_item)
		if search_item.id == item_id then
			local found
			if augment_string then
				local search_item_augments_string = util.info.get_augments_string(search_item)
				found = search_item_augments_string == augment_string
			else
				found = true
			end
			if found then
				count = count + 1
			end
			return count == index
		end
	end)

	return f, f and f.slot or nil
end

-- 指定したストレージにアイテムを何スタック保持しているか返す
function util.bag.count(bag_name, item_id, augment_string)
	local search_items = util.get('items')[bag_name]

	local _, f
	local count = 0
	_, f = table.find(search_items, function(search_item)
		if search_item.id == item_id then
			local found
			if augment_string then
				local search_item_augments_string = util.info.get_augments_string(search_item)
				found = search_item_augments_string == augment_string
			else
				found = true
			end
			if found then
				count = count + 1
			end
		end
	end)
	return count
end