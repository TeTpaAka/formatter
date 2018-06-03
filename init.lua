formatter = {}

-- localize global functions
local table_insert = table.insert
local table_concat = table.concat

-- helper functions

local function fix_absolute_rect(parent, child)
	if parent.absoluteWidth and parent.absoluteHeight then
		child.absoluteWidth = child.width
		child.absoluteHeight = child.height

		child.x = child.x / parent.absoluteWidth
		child.y = child.y / parent.absoluteHeight
		child.width = child.width / parent.absoluteWidth
		child.height = child.height / parent.absoluteHeight
	end

end

-- prototype defitintions
local gui_element = {}
--local container = {}
local window = {}
local button = {}
local input = {}
--local grid = {}
local inventory = {}

-- gui_element
gui_element.__index = gui_element

function gui_element:set_background_color(color)
	if type(color) == "string"  or color == nil then
		self.bgcolor = color
	end
end

function gui_element:set_image(image)
	if type(image) == "string"  or image == nil then
		self.img = image
	end
end

function gui_element:set_text(text)
	if type(text) == "text" or text == nil then
		self.text = text
	end
end

function gui_element:set_style(name, value)
	if not (type(name) == "string" and (type(value) == "string" or type(value) == "number")) then
		return
	end
	self.style = self.style or {}
	self.style[name] = value
end

function gui_element:visible()
	if self.style or self.bgcolor or self.img or self.text then
		return true
	else
		return false
	end
end

function gui_element:generate_style(element)
	if self.aspect then
		element.aspect = {
			x = self.aspect.x,
			y = self.aspect.y
		}
	end
	if self.style then
		element.style = {}
		for k,v in pairs(self.style) do
			element.style[k] = v
		end
	end
	if self.bgcolor then
		element.bgcolor = self.bgcolor
	end
	if self.img then
		element.image = self.img
	end
	if self.text then
		element.text = self.text
	end
end

function gui_element:generate_rect(element)
	local rect = {
		x0 = self.x,
		y0 = self.y,
		x1 = self.x + self.width,
		y1 = self.y + self.height
	}
	if self.margin then
		rect.x0 = rect.x0 + self.margin.x
		rect.y0 = rect.y0 + self.margin.y
		rect.x1 = rect.x1 - self.margin.x
		rect.y1 = rect.y1 - self.margin.y
	end
	self:generate_style(element)
	element.rect = rect;
end

function gui_element:generate(result, x, y, width, height)
	local element = {}
	self:generate_rect(element)
	if self.content then
		for _,c in pairs(self.content) do
			c:generate(element, x, y, width, height)
		end
	end
	result.children = result.children or {}
	table_insert(result.children, element)
end

function gui_element:set_pos(x, y) 
	self.x = x
	self.y = y
end

function gui_element:set_size(width, height) 
	self.width = width
	self.height = height
end

function gui_element:set_aspect(x, y)
	if not(x and y) then
		--reset
		self.aspect = nil
		return
	end
	self.aspect = {
		x = x,
		y = y or 1
	}
end

function gui_element:set_absolute_size(width, height)
	self.absoluteWidth = width
	self.absoluteHeight = height
end

function gui_element:set_margin(x, y)
	if not(x and y) then
		self.margin = nil
		return
	end
	self.margin = {
		x = x,
		y = y
	}
	if self.absoluteWidth and self.absoluteHeight then
		self.margin.x = self.margin.x / self.absoluteWidth
		self.margin.y = self.margin.y / self.absoluteHeight
	end
end

function gui_element:inventory(spec)
	self.content = self.content or {}
	local obj = {
		x = spec.x or 0,
		y = spec.y or 0,
		width = spec.width or self.absoluteWidth or 1,
		height = spec.height or self.absoluteHeight or 1,
		location = spec.location or "current_player",
		list = spec.list or "main",
		columns = spec.columns or 1,
		rows = spec.rows or 1,
	}
	fix_absolute_rect(self, obj)
	setmetatable(obj, inventory)

	table.insert(self.content, obj)
	return obj
end

function gui_element:button(spec)
	self.content = self.content or {}
	local obj = {
		x = spec.x or 0,
		y = spec.y or 0,
		width = spec.width or self.absoluteWidth or 1,
		height = spec.height or self.absoluteHeight or 1,
		text = spec.text,
		name = spec.name or ""
	}
	fix_absolute_rect(self, obj)
	setmetatable(obj, button)

	table.insert(self.content, obj)
	return obj
end

function gui_element:input(spec)
	self.content = self.content or {}
	local obj = {
		x = spec.x or 0,
		y = spec.y or 0,
		width = spec.width or self.absoluteWidth or 1,
		height = spec.height or self.absoluteHeight or 1,
		text = spec.text,
		name = spec.name or ""
	}
	fix_absolute_rect(self, obj)
	setmetatable(obj, input)

	table.insert(self.content, obj)
	return obj
end

function gui_element:image(spec)
	self.content = self.content or {}
	local obj = {
		x = spec.x or 0,
		y = spec.y or 0,
		width = spec.width or self.absoluteWidth or 1,
		height = spec.height or self.absoluteHeight or 1,
		img = spec.image
	}
	fix_absolute_rect(self, obj)
	setmetatable(obj, gui_element)

	table.insert(self.content, obj)
	return obj
end

function gui_element:label(spec)
	self.content = self.content or {}
	local obj = {
		x = spec.x or 0,
		y = spec.y or 0,
		width = spec.width or self.absoluteWidth or 1,
		height = spec.height or self.absoluteHeight or 1,
		text = spec.text
	}
	fix_absolute_rect(self, obj)
	setmetatable(obj, gui_element)

	table.insert(self.content, obj)
	return obj
end

-- window
window.__index = window
setmetatable(window, gui_element)

function window:generate()
	local result = {}
	gui_element.generate(self, result, self.x, self.y, self.width, self.height)
	return minetest.write_json(result.children[1])
end

-- button
button.__index = button
setmetatable(button, gui_element)

function button:generate(result, x, y, width, height)
	local element = {}
	self:generate_rect(element)
	element.type = "button"
	result.children = result.children or {}
	table_insert(result.children, element)
end

-- input
input.__index = input
setmetatable(input, gui_element)

function input:generate(result, x, y, width, height)
	local element = {}
	self:generate_rect(element)
	element.type = "input"
	result.children = result.children or {}
	table_insert(result.children, element)
end

-- grid
--[[
grid.__index = grid
setmetatable(grid, gui_element)

function grid:insert()
	self.content = self.content or {}
	local element = {}
	setmetatable(element, container)
	table_insert(self.content, element)
	return element
end

function grid:generate(result, x, y, width, height)
	if not self.content then
		return
	end
	local self_x = self.x
	local self_y = self.y
	local child_width = width / self_x
	local child_height = height / self_y
	for i = 0, self_y - 1 do
		for j = 0, self_x - 1 do
			local element = self.content[i * self_x + j + 1]
			print(i * self_x + j + 1)
			if element then
				element:generate(result, x + j * child_width, y + i * child_height, child_width, child_height)
			end
		end
	end
end
--]]

-- inventory

inventory.__index = inventory
setmetatable(inventory, gui_element)

function inventory:generate(result)
	local element = {}
	self:generate_rect(element)
	element.type = "inventory"
	element.rows = self.rows
	element.columns = self.columns
	result.children = result.children or {}
	table_insert(result.children, element)
end

-- api functions
function formatter.create()
	local form = { x = 0, y = 1, width = 1, height = 1}
	setmetatable(form, window)
	return form
end

dofile(minetest.get_modpath("formatter").."/test.lua")
