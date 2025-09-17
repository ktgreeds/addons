-- ���擾�Ɋւ��郉�C�u����
-- ����Ƃ�Ȃ����Ȃ��Ƃ����Ȃ����̂ŁA
-- �L���b�V��������Ӗ������Ȃ���������

_utils = _utils or {}
_utils.info = true

util = util or {}
util.info = {}

-- ���݃��O�C�����Ă��邩�ǂ�����Ԃ�
-- @return boolean
function util.info.is_login()
	local info  = windower.ffxi.get_info()
	return info and info.logged_in
end


-- �A�C�e���}�X�^����I�[�O�����g����������o��
-- @return mixed �擾�����I�[�O�����g������B���s����
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


-- ID�w��ŋ������|�����Ă��邩�𒲂ׂ�
-- @return boolean
function util.info._has_buff_by_id(buff_id)
	local p = windower.ffxi.get_player()
	if p == nil or type(p.buffs) ~= 'table' then
		return false
	end
	
	return T(p.buffs):contains(buff_id)
end


-- �������|�����Ă��邩���`�F�b�N����
-- @param  buff    �`�F�b�N����ID or ���O
--                 �����`�F�b�N����ꍇ�͔z���n��
-- @param  all     buff�ɔz���n�����ꍇ�A
--                 �S�Ċ|�����Ă���ꍇ��true��Ԃ����̔���
--                 false���w�肷��ƁA�����ꂩ1�ł��|�����Ă����
--                 true��ԋp
--                 �f�t�H���g��true
-- @return boolean
function util.info.has_buff(buff, all)
	if all == nil then
		all = true
	end
	
	if type(buff) == 'string' then
		-- �����񂪓n���ꂽ�ꍇ�A���\�[�X����ID����
		-- ID������������all = false�Ō�������
		-- (�w�C�X�g��2�����)
		local buff_info = res.buffs:ja(buff)
		if buff_info == nil then
			return false
		end
		buff = util.table_pluck(buff_info, 'id')
		return buff and util.has_buff(buff, false) or false
	end
	
	if type(buff) == 'number' then
		-- �����̏ꍇ��ID�Ƃ��Ă��̂܂܌���
		return util._has_buff_by_id(buff)
	elseif type(buff) == 'table' then
		-- �e�[�u���̏ꍇ��all���݂ă��[�v���܂킷
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





