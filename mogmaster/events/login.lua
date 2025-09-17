windower.register_event('login', function(name)
	--print('login')

	-- _setsと_mogディレクトリが存在しない場合、初期データを作成する
	local has_sets_dir = windower.dir_exists(windower.addon_path.. 'sets')
	local has_mog_dir  = windower.dir_exists(windower.addon_path.. 'mog')
	if has_sets_dir == false and has_mog_dir == false then
		util.log.info('sets/mogディレクトリがありません。20秒後に初期データを生成します...')
		files:create_path('mog')
		files:create_path('sets')
		windower.send_command('wait 20;lua i '.._addon.command..' init')
	end
end)