-- 情報取得に関するライブラリ
-- 毎回とりなおさないといけないもので、
-- キャッシュ化する意味が少ない物を扱う

_utils = _utils or {}
_utils.info = true

util = util or {}
util.info = {}

-- 現在ログインしているかどうかを返す
-- @return boolean
function util.info.is_login()
	local info  = windower.ffxi.get_info()
	return info and info.logged_in
end


-- アイテムマスタからオーグメント文字列を取り出す
-- @return mixed 取得したオーグメント文字列。失敗時は
function util.info.get_augments_string(item)
	local augments_string
	local augments = extdata.decode(item).augments
	if augments ~= nil then
		for i = 1, #augments do
			if augments[i] == 'none' then
				augments[i] = nil
			end
		end
		if #augments > 0 then
			augments_string = table.concat(augments, '/'):gsub('"', '')
		end
	end
	return augments_string
end


-- ID指定で強化が掛かっているかを調べる
-- @return boolean
function util.info._has_buff_by_id(buff_id)
	local p = windower.ffxi.get_player()
	if p == nil or type(p.buffs) ~= 'table' then
		return false
	end
	
	return T(p.buffs):contains(buff_id)
end


-- 強化が掛かっているかをチェックする
-- @param  buff    チェックするID or 名前
--                 複数チェックする場合は配列を渡す
-- @param  all     buffに配列を渡した場合、
--                 全て掛かっている場合にtrueを返すかの判定
--                 falseを指定すると、いずれか1つでも掛かっていれば
--                 trueを返却
--                 デフォルトはtrue
-- @return boolean
function util.info.has_buff(buff, all)
	if all == nil then
		all = true
	end
	
	if type(buff) == 'string' then
		-- 文字列が渡された場合、リソースからID検索
		-- IDが見つかったらall = falseで検索する
		-- (ヘイストが2個ある為)
		local buff_info = res.buffs:ja(buff)
		if buff_info == nil then
			return false
		end
		buff = util.table_pluck(buff_info, 'id')
		return buff and util.has_buff(buff, false) or false
	end
	
	if type(buff) == 'number' then
		-- 数字の場合はIDとしてそのまま検索
		return util._has_buff_by_id(buff)
	elseif type(buff) == 'table' then
		-- テーブルの場合はallをみてループをまわす
		local _, b
		for _, b in pairs(buff) do
			if all then
				if util.has_buff(b, all) == false then
					return false
				end
			else
				if util.has_buff(b, all) then
					return true
				end
			end
		end
		
		return all
	end
end





