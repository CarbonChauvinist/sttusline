local colors = require("sttusline.utils.color")

return {
	name = "pos-cursor",

	event = { "CursorMoved", "CursorMovedI" }, -- The component will be update when the event is triggered
	user_event = { "VeryLazy" },

	colors = { fg = colors.fg }, -- { fg = colors.black, bg = colors.white }

	update = function()
		local pos = vim.api.nvim_win_get_cursor(0)
		return string.format("%5i,%-4i", pos[1], pos[2])
	end,
}
