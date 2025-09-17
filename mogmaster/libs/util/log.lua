-- ログ出力に関するライブラリ

_utils = _utils or {}
_utils.log = true

util = util or {}
util.log = {}

-- 情報ログをチャットに出力
function util.log.info(message)
	windower.add_to_chat(55, windower.to_shift_jis(message))
end


-- エラーログをチャットに出力
function util.log.error(message)
	if settings.display_error ~= false then
		windower.add_to_chat(123, windower.to_shift_jis(message))
	end
end
