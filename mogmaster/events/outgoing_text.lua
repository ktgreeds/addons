-- テキストコマンド入力時のイベント
windower.register_event('outgoing text', function(original, modified)

	local cmd, detail
	-- コマンド部をcmd、引数をdetailに格納する
	cmd, detail = modified:match("^/(.-)% (.+)")
	
	-- 引数がない場合、コマンドのみかどうかを再チェック
	-- コマンドとしての文字列も見つからない場合は何もしない
	if cmd == nil then
		cmd = modified:match("^/(.+)")
		if cmd == nil then
			return modified
		end
	end
	
	if (cmd == 'setitems' or cmd == 'si') and detail ~= nil then
		
		-- /si アイテム移動を実行する
		set_item.exec(detail)
		
	elseif cmd == 'exportitems' or cmd == 'ei' then
		
		-- アイテムをリロード
		util.get('items', false)
		
		-- /ei アイテムをファイル出力する
		export_item.output_sets()
		
		if detail ~= '0' then
			export_item.output_mog()
		end
	end
	
	return modified
end)