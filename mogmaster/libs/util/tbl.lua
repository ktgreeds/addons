-- テーブル操作に関するライブラリ

_utils = _utils or {}
_utils.tbl = true

util = util or {}
util.tbl = {}

-- テーブルのキー一覧を返す
-- t ピックアップするテーブル
function util.tbl.keys(t)
	if type(t) ~= 'table' then
		return nil
	end
	local key, keys
	keys = T{}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	return #keys > 0 and keys or nil
end

-- テーブルから値をピックアップする
-- t     ピックアップするテーブル
-- key   テーブルからピックアップするキー
-- index 返り値のキーに入れる値(オプション)
function util.tbl.pluck(t, key, index)
	if type(t) ~= 'table' then
		return nil
	end

	local _, v, plucked

	for _, v in pairs(t) do
		if type(v) == 'table' then
			if index then
				local subkey = v[index]
				if subkey then
					plucked = plucked or T{}
					plucked[subkey] = v[key]
				end
			else
				plucked = plucked or T{}
				table.insert(plucked, v[key])
			end
		end
	end

	return plucked
end
