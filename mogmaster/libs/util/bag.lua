-- ���΂�̌������Ɋւ��郉�C�u����

_utils = _utils or {}
_utils.bag = true
_utils.info = _utils.info or require 'libs/util/info'

util = util or {}
util.bag = {}

-- �w�肵���X�g���[�W����A�C�e������������
-- augment_string�̓I�v�V����
-- ������Ȃ������ꍇ��nil��Ԃ�
function util.bag.find(bag_name, item_id, augment_string, index)
	index = index or 1

	local search_items = util.get('items')[bag_name]

	local _, f
	local count = 0
	_, f = table.find(search_items, function(search_item)
		if search_item.id == item_id then
			local found
			if augment_string then
				local search_item_augments_string = util.info.get_augments_string(search_item)
				found = search_item_augments_string == augment_string
			else
				found = true
			end
			if found then
				count = count + 1
			end
			return count == index
		end
	end)

	return f, f and f.slot or nil
end

-- �w�肵���X�g���[�W�ɃA�C�e�������X�^�b�N�ێ����Ă��邩�Ԃ�
function util.bag.count(bag_name, item_id, augment_string)
	local search_items = util.get('items')[bag_name]

	local _, f
	local count = 0
	_, f = table.find(search_items, function(search_item)
		if search_item.id == item_id then
			local found
			if augment_string then
				local search_item_augments_string = util.info.get_augments_string(search_item)
				found = search_item_augments_string == augment_string
			else
				found = true
			end
			if found then
				count = count + 1
			end
		end
	end)
	return count
end