-- ���O�o�͂Ɋւ��郉�C�u����

_utils = _utils or {}
_utils.log = true

util = util or {}
util.log = {}

-- ��񃍃O���`���b�g�ɏo��
function util.log.info(message)
	windower.add_to_chat(55, windower.to_shift_jis(message))
end


-- �G���[���O���`���b�g�ɏo��
function util.log.error(message)
	if settings.display_error ~= false then
		windower.add_to_chat(123, windower.to_shift_jis(message))
	end
end
