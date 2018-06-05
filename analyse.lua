function string:gsplit(sep, plain)
    local r = {}
    for w in self:gsplitf(sep, plain) do
        table.insert(r, w)
    end
    return r
end

function string:gsplitf(sep, plain)
	local start = 1
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = self:sub(start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return self:sub(start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return self end
		return pass(self:find(sep, start, plain))
	end
end

function find_title(line) 
	local f = "<cite>.*</cite>"
	local name = string.sub(line, string.find(line, f))
	if(nil == string.find(line, f)) then
		print(line)
	end
	return string.sub(name, 7, #name - 7)
end

function find_level(line) 
	local f = "<em .*/em>"
	local l = string.sub(line, string.find(line, f))
	local level = ''
	if nil ~= string.find(l, 'dangci_no') then
		level = '无评级'
	elseif nil ~= string.find(l, 'dangci') then
		local a = '<em title="去哪儿网用户评定为舒适型酒店" class="sort dangci">'
		level = string.sub(l, #a+1, #l-5)
	elseif nil ~= string.find(l, 'star') then
		local a = '<em class="star star30" title="国家旅游局评定为'
		level = string.sub(l, #a+1, #l-7)
	else 
		print(line)
	end
	return level
end

function find_price(line)
	local price = ''
	if nil ~= string.find(line, '¥') then
		local a = '<b>.*</b>'
		local l = string.sub(line, string.find(line, a))
		price = string.sub(l, 4, #l - 4)
	elseif nil ~= string.find(line, 'no_price') then
		local a = '<p class="no_price">.*</p>'
		local l = string.sub(line, string.find(line, a))
		local b = '<p class="no_price">'
		price = string.sub(l, #b + 1, #l - 4 )
	elseif nil ~= string.find(line, '参考价') then
		local a = '>参考价：.*元</a>'
		local l = string.sub(line, string.find(line, a))
		price = string.sub(l, #'>参考价：' + 1, #l - #'元</a>')
	else 
		print(line)
	end
	return price
end

function analyse(h) 
	local flag = false
	local s = "精确酒店名命中 start"
	local e = "精确酒店名命中 end"
	local t = '<span class="hotel_num js_hotel_num">1</span>'
	local m = '<div class="js_list_price"'
	local name = nil
	local level = nil
	local price = nil
	while true do
		local line = h:read('*l')
		if nil == line then break end
		if flag then
			local tp = string.find(line, t)
			if nil ~= tp then
				name = find_title(line)
				level = find_level(line)
			end
			local mp = string.find(line, m)
			if nil ~= mp then
				price = find_price(line)
			end
		end
		if not flag then 
			local sp = string.find(line, s)
			if sp ~= nil then 
				flag = true
			end
		end
		local ep = string.find(line, e)
		if ep ~= nil then 
			break
		end
	end
	return name, level, price
end

local uf = io.open('uf.txt', 'w')
local hf = io.open('./hotel.txt', 'r')
while true do
	local line = hf:read('*l')
	if nil == line then break end
	local l = line:gsplit('\t')
	local th = io.open('./html/'..l[2]..'.html')
	if nil == th then
		uf:write(line..'\n')
	else
		local name, level, price = analyse(th)
		if nil ~= name then
			print(l[2]..'\t'..name..'\t'..level..'\t'..price)
		end
		th:close()	
	end
end
hf.close()
uf.close()
