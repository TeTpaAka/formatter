local testform = formatter.create()

testform:set_size(1, .7)
testform:set_pos(0, .15)
testform:set_aspect(16,9)
testform:set_style("button_standard", "formatter_button_beige.png")
testform:set_style("button_pressed", "formatter_button_beige_pressed.png")
testform:set_style("inventory_background_color", "#D3BF8FFF")

testform:set_image("formatter_panel_brown_320x180.png")
testform:set_absolute_size(320, 180)
for i = 0,2 do
testform:button({
	x = 12,
	y = 10 + 24.5 * i,
	width = 95,
	height = 22.5,
	name = "test",
	text = "test_" ..  (i + 1)
})
end

local image = testform:image({
	x = 224,
	y = 4,
	width = 92,
	height = 78,
	image = "formatter_inlay_dark_beige_92x78.png"
})
image:set_style("text_align", "topleft")
local label = image:label({
	text = "This is a long text with automatic word wrapping. This is a long text with automatic word wrapping. This is a long text with automatic word wrapping."

})
label:set_margin(5, 5)

image = testform:image({
	x = 4,
	y = 82,
	width = 312,
	height = 94,
	image = "formatter_inlay_beige_312x94.png"
})

image:inventory({
	location = "current_player",
	list = "main",
	columns = 11,
	rows = 3,
	x = 4,
	y = 6,
	width = 304,
	height = 85
})

local formspec = testform:generate()

minetest.register_chatcommand("testform", {
	func = function(name, param)
		minetest.chat_send_player(name, formspec)
		print(formspec)
		minetest.show_formspec_new(name, "testform", formspec)
	end
})
