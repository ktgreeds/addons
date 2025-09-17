windower.register_event('load', function()
	-- リソースライブラリとマスタをキャッシュさせる為にアイテムを一度検索しておく
	print('loading item master..')
	res.items:id(1)
	util.get('items', false)

	-- _setsと_mogディレクトリが存在しない場合、初期データを作成する
	if util.info.is_login() then
		local has_sets_dir = windower.dir_exists(windower.addon_path.. 'sets')
		local has_mog_dir  = windower.dir_exists(windower.addon_path.. 'mog')
		if has_sets_dir == false and has_mog_dir == false then
			windower.send_command('lua i '.._addon.command..' init')
		end
	end
	print('mogmaster ready.')

end)