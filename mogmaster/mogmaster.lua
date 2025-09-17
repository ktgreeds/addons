_addon.name		= 'mogmaster'
_addon.version	= '1.14.2'
_addon.author	= 'tama'
_addon.command	= 'mogmaster'

-- Windower内蔵libのロード
require 'luau'
files  = require('files')
extdata = require 'extdata'

-- コンフィグのロード
settings = config.load({
	export_extdata = true,	-- extdataの出力有無
	loop_wait      = 0.1,	-- アイテム移動処理を1回行う毎の待ち時間
	display_error  = false,	-- 	エラーの表示
})


-- その他ライブラリのロード
require 'libs/util/bag'
require 'libs/util/const'
require 'libs/util/file'
require 'libs/util/get'
require 'libs/util/info'
require 'libs/util/log'


-- ロジック実行ファイルのロード
export_item = require('libs/export_item')
set_item    = require('libs/set_item')


-- 各種イベント毎ファイルロード
require 'events/load'
require 'events/login'
require 'events/outgoing_text'


-- 現在のカバン状態を元にして初期化する
function init()
	export_item.init()
end


-- マイバッグのアイテムをスロット・カウント指定で預ける
function put_item(bag_name, slot, count)
	slot  = tonumber(slot)
	count = tonumber(count)
	windower.ffxi.put_item(util.const.bags[bag_name].id, slot, count)
end


-- モグに預けているアイテムをスロット・カウント指定で引き出す
function get_item(bag_name, slot, count)
	slot  = tonumber(slot)
	count = tonumber(count)
	windower.ffxi.get_item(util.const.bags[bag_name].id, slot, count)
end

