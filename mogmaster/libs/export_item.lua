-- /export_items コマンドに関する動作

local export_item = {}

local mog_categories = {
    'safe', 'safe2', 'storage', 'locker', 'satchel', 'sack', 'case', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4','wardrobe5','wardrobe6','wardrobe7','wardrobe8',
}

-- 初期化時のアイテムエクスポート
export_item.init = function()
	local p = util.get('player', false)

	util.log.info('現在のかばん/収納状態を元に初期ファイルを作成しています...')
	util.get('items', false)
	local name = p.name:lower()
	local job  = p.main_job:lower()

	-- マイバッグの中身をsets\<キャラ名>\<ジョブ名>.txtに書き出す
	export_item.output('inventory', 'sets/' .. name .. '/' .. job .. '.txt')

	-- 各種収納の中身ををmog\<キャラ名>\<収納名>.txtに書き出す
	local key, val
	for key, val in ipairs(mog_categories) do
		export_item.output(val, 'mog/' .. name .. '/' .. val .. '.txt')
	end
end

-- マイバッグの中身をexportディレクトリに出力する
export_item.output_sets = function()
	local job = util.get('player', false).main_job:lower()
	export_item.output('inventory', 'export/' .. job .. '.txt')
end

-- モグ収納の中身をexportディレクトリに出力する
export_item.output_mog = function()
	local key, val
	for key, val in ipairs(mog_categories) do
		export_item.output(val, 'export/' .. val .. '.txt')
	end
end

-- 指定したbag_nameの情報5ファイルに出力する
export_item.output = function(bag_name, filename)
	local items = util.get('items')[bag_name]

	-- 取得したアイテムをソート
	table.sort(items, function(a, b)
		local category_sort_num = {
			Usable    = 1,
			Maze      = 2,
			Weapon    = 3,
			Armor     = 4,
			Automaton = 5,
			General   = 6
		}
		
		if a.info == nil or b.info == nil then
			return false
		end
		local a_sort = 0
		local b_sort = 0
		local a_min_slot = a.info.slots and table.sum(table.keyset(a.info.slots)) or 99
		local b_min_slot = b.info.slots and table.sum(table.keyset(b.info.slots)) or 99
		if a.info.category ~= b.info.category then
			-- カテゴリ順ソート
			a_sort = category_sort_num[a.info.category] or 99
			b_sort = category_sort_num[b.info.category] or 99
		elseif a_min_slot ~= b_min_slot then
			-- 同一カテゴリの場合は装備スロット順
			-- 複数スロットに可能な場合はスロット番号を足す
			a_sort = a_min_slot
			b_sort = b_min_slot
		elseif a.info.skill ~= b.info.skill then
			-- 同一スロット or スロット定義なしのの合は対象武器スキル順
			a_sort = a.info.skill
			b_sort = b.info.skill
		elseif a.info.level ~= b.info.level then
			-- 同一武器スキル or 武器スキル定義なしの場合は対象レベル順
			-- 降順なのでaとbを逆に入れる
			a_sort = b.info.level
			b_sort = a.info.level
		elseif a.info.ja ~= b.info.ja then
			-- 同一レベル or レベル定義なしの場合は名前順
			a_sort, b_sort = a.info.ja, b.info.ja
		end
		return a_sort < b_sort
	end)

	-- 無視リストを取得
	local ignore_lists = util.file.list_by_text('data', 'ignore') or {}

	-- ShiftJISでファイルに書き出す
	local f = files.new(filename)
	f:create()
	local index, item
	for index, item in ipairs(items) do
		if table.find(ignore_lists, function(list)
			return list.id == item.id
		end) == nil then
			local line

			line = windower.to_shift_jis(item.info.ja)

			local augments_string = util.info.get_augments_string(item)
			if augments_string ~= nil and settings.export_extdata then
				line = line .. '@' .. augments_string
			end

			f:append(line .. '\n')
		end
	end
	util.log.info('アイテムリストを'..filename..'に書き出しました')
end
return export_item