-- /set_items コマンドに関する動作

local set_item = {}

local task = T{}

-- setの入れ替えを実行する
function set_item.exec(set_name)
	
	if task.current then
		-- 実行中に再実行した場合、task変数を空にしてwait + 1秒後に実行
		-- (wait秒後にmainloopが走ってtaskが空なのでループ終了 → 1秒後に再実行)
		util.log.info('実行中のアイテム移動を停止しています...')
		task = {}
		windower.send_command('wait ' .. (settings.loop_wait + 1) ..';lua i '.._addon.command..' set_item_exec ' .. set_name)
		return
	end

	-- タスクリセット
	task = {}

	-- キャッシュしなおす為、アイテムをリロードする
	util.get('items', false)
	
	-- set定義テキストのID/extdata一覧を取得
	local to_inventory_items = util.file.list_by_text('sets', set_name)
	if to_inventory_items == nil then
		util.log.error('sets[' .. set_name .. ']が見つかりません')
		return
	end
	-- 6Ym以内にNomad Moogleがいるか判定する
    local function check_nomad_moogle()
        for _, mob in pairs(windower.ffxi.get_mob_array()) do
            if mob.name == 'Nomad Moogle' and math.sqrt(mob.distance) < 6 then
                return true
            end
        end

        return false
    end
	-- 利用する収納を判定
    local mog_list
    if windower.ffxi.get_info().mog_house then
        util.log.info('mog_house=true 全ての収納を使用します')
        mog_list = {'safe', 'safe2', 'storage', 'locker', 'satchel', 'sack', 'case',}
    elseif check_nomad_moogle() then    -- Nomad Moogleの条件を追加
        util.log.info('Nomad Moogle：モグ金庫・モグ金庫2・モグロッカー・サッチェル・サック・ケースを使用するクポ！')
        mog_list = {'safe', 'safe2', 'locker','satchel', 'sack', 'case',}
    else
        util.log.info('mog_house=false サッチェル・サック・ケースのみ使用します')
        mog_list = {'satchel', 'sack', 'case',}
    end
	
	-- 利用する収納の定義テキストからID/extdata一覧を取得
	-- ループカウンタも同時に更新しておく
	local max_loop = #to_inventory_items
	local mog_items = {}
	local _, bag_name
	for _, bag_name in ipairs(mog_list) do
		local ids = util.file.list_by_text('mog', bag_name)
		if ids ~= nil then
			mog_items[bag_name] = ids
			max_loop = math.max(max_loop, #ids)
		end
	end
	
	-- アイテムごとに、マイバッグの残り在庫を管理する配列
	local inventory_stock = {}
	
	-- マイバッグ⇔収納の検索インデックスを管理する配列
	local search_index = {
		inventory = {}
	}
	
	-- 残り必要な個数を管理する配列
	local need_count = {
		inventory = {}
	}

	local i, search_item
	
	-- タスク生成部分メインループ
	-- safe, safe2, storage, locker, satchel, sack, case, inventory の順に
	-- 1行ずつタスク追加する処理
	for i = 1, max_loop do

		-- マイバッグ → 各種収納へ
		for _, bag_name in ipairs(mog_list) do
			
			if mog_items[bag_name] and mog_items[bag_name][i] then
				search_item = mog_items[bag_name][i]
			else
				search_item = nil
			end
			
			if search_item then
			
				-- マイバッグの残り在庫数を取得
				local item_key = search_item.augments
					and search_item.id .. '-' .. search_item.augments
					or search_item.id
				if inventory_stock[item_key] == nil then
					-- 在庫未取得の場合は計算する
					-- (バッグに持っている個数 - setに定義してある行数) が初期在庫
					-- ただし0未満になる場合は0とする
					local first_stock = util.bag.count('inventory', search_item.id, search_item.augments)
						- to_inventory_items:count(function(item)
							if item.augments and search_item.augments then
								return item.id == search_item.id and item.augments == search_item.augments
							else
								return item.id == search_item.id
							end
						end)

					inventory_stock[item_key] = first_stock > 0 and first_stock or 0
				end
				
				-- search_itemをマイバッグのいくつ目から検索するかを取得。初期値は1
				search_index.inventory = search_index.inventory or {}
				search_index.inventory[item_key] = search_index.inventory[item_key] or 1
				
				need_count[bag_name] = need_count[bag_name] or {}
				if need_count[bag_name][item_key] == nil then
					
					local first_need_count = mog_items[bag_name]:count(function(item)
							if item.augments and search_item.augments then
								return item.id == search_item.id and item.augments == search_item.augments
							else
								return item.id == search_item.id
							end
						end) - util.bag.count(bag_name, search_item.id, search_item.augments)

					need_count[bag_name][item_key] = first_need_count > 0 and first_need_count or 0

				end
				
				-- 在庫あればタスクに追加したあと
				-- 在庫を1つ減らして、indexを1進める
				if inventory_stock[item_key] > 0 and need_count[bag_name][item_key] > 0 then
					local result = util.bag.find('inventory', search_item.id, search_item.augments, search_index.inventory[item_key])
					if result ~= nil  then

						task[#task+1] = {
							cmd  = 'lua i ' .. _addon.command ..' put_item '
									.. bag_name .. ' ' .. result.slot .. ' ' .. result.count,
							text = util.get('item_info', true, search_item.id).ja .. (search_item.augments and '@' .. search_item.augments or '')
									..' → '
									.. util.const.bags[bag_name].ja
						}
						inventory_stock[item_key] = inventory_stock[item_key] - 1
						need_count[bag_name][item_key] = need_count[bag_name][item_key] - 1
						search_index.inventory[item_key] = search_index.inventory[item_key] + 1
					end
				end
				
			end
		end

		-- 各種収納 → マイバッグへ
		-- ToDO すでに持っている場合は移動しない
		search_item = to_inventory_items[i]
		if search_item then

			-- 収納から探せたかどうかを保存するフラグ
			local is_found = false

			local item_key = search_item.augments
				and search_item.id .. '-' .. search_item.augments
				or search_item.id

			for _, bag_name in ipairs(mog_list) do
				
				-- 現在の検索インデックスを取得
				search_index[bag_name] = search_index[bag_name] or {}
				search_index[bag_name][item_key] = search_index[bag_name][item_key] or 1
				
				if need_count.inventory[item_key] == nil then
					-- マイバッグへの移動必要数が未取得だったら計算する
					need_count.inventory[item_key] = to_inventory_items:count(function(item)
							if item.augments and search_item.augments then
								return item.id == search_item.id and item.augments == search_item.augments
							else
								return item.id == search_item.id
							end
							
						end) - util.bag.count('inventory', search_item.id, search_item.augments)
					
					if need_count.inventory[item_key] < 0 then
						need_count.inventory[item_key] = 0
					end
				end
				
				-- マイバッグにまだ移動必要であれば、収納から検索
				if need_count.inventory[item_key] > 0 then

					local result = util.bag.find(bag_name, search_item.id, search_item.augments, search_index[bag_name][item_key])
					
					if result ~= nil then
					
						-- 必要個数の残があればタスク追加する
						-- 同一収納・同一アイテムの検索インデックスを1進める
						task[#task+1] = {
							cmd  = 'lua i ' .. _addon.command ..' get_item '
									.. bag_name .. ' ' .. result.slot .. ' ' .. result.count,
							text = util.const.bags[bag_name].ja
									.. ' → '
									.. util.get('item_info', true, search_item.id).ja .. (search_item.augments and '@' .. search_item.augments or '')
						}
						
						need_count.inventory[item_key] = need_count.inventory[item_key] - 1
						search_index[bag_name][item_key] = search_index[bag_name][item_key] + 1
						is_found = true
					end
				end
			end
			
			if is_found == false and need_count.inventory[item_key] > 0 then
				util.log.error('"' .. util.get('item_info', true, search_item.id).ja .. '" が収納に見つからない為、スキップしました')
			end
			
		end
	end

	-- 登録されたタスクがあれば実行する
	if #task > 0 then
		task.current = 1
		task.end_num = #task
		util.log.info('セット['..set_name..']の実行スタート:'.. task.end_num..'件')
		set_item_mainloop()
	else
		util.log.info('セット['..set_name..']は完了しています')
	end
	
end



-- 以下invokeで使う関数

-- タスクを実行する
-- 実行中の再実行でやり直す場合に呼び出す
function set_item_exec(set_name)
	set_item.exec(set_name)
end

-- メインループ
function set_item_mainloop()
	local current_task = task[task.current]
	
	-- 再実行等で配列が無くなっている場合は何もせず終了
	if current_task == nil then
		return
	end

	util.log.info('[' .. task.current .. '/' .. task.end_num .. ']' .. current_task.text)
	windower.send_command(current_task.cmd)

	-- ループ完了時
	if task.current == task.end_num then
		task = {}
		return
	end
	task.current = task.current + 1

	windower.send_command('wait ' .. settings.loop_wait ..';lua i '.._addon.command..' set_item_mainloop')
end

return set_item