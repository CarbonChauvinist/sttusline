local copilot_status = ""

return {
	name = "copilot",
	user_event = {
		"CopilotStatusNormal",
		"CopilotStatusError",
		"CopilotStatusInProgress",
		"CopilotStatusWarning",
		"CopilotStatusUnknow",
	},
	configs = {
		icons = {
			normal = "",
			error = "",
			warning = "",
			inprogress = "",
		},
	},
	init = function()
		local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
		local schedule = vim.schedule
		vim.api.nvim_create_autocmd("InsertEnter", {
			once = true,
			desc = "Init copilot status",
			callback = function()
				local cp_api_ok, cp_api = pcall(require, "copilot.api")
				if cp_api_ok then
					cp_api.register_status_notification_handler(function(data)
						schedule(function()
							copilot_status = string.lower(data.status or "")
							if copilot_status == "normal" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusNormal", modeline = false })
							elseif copilot_status == "error" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusError", modeline = false })
							elseif copilot_status == "inprogress" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusInProgress", modeline = false })
							elseif copilot_status == "warning" then
								nvim_exec_autocmds("User", { pattern = "CopilotStatusWarning", modeline = false })
							else
								nvim_exec_autocmds("User", { pattern = "CopilotStatusUnknow", modeline = false })
							end
						end)
					end)
				end
			end,
		})
	end,
	update = function(configs)
		if package.loaded["copilot"] then
			local cp_client_ok, cp_client = pcall(require, "copilot.client")
			if not cp_client_ok then
				copilot_status = "error"
				require("sttusline.utils.notify").error("Cannot load copilot.client")
				return
			end

			local copilot_client = cp_client.get()

			if not copilot_client then
				copilot_status = "error"
				return
			end

			local cp_api_ok, cp_api = pcall(require, "copilot.api")
			if not cp_api_ok then
				copilot_status = "error"
				require("sttusline.utils.notify").error("Cannot load copilot.api")
				return
			end
			cp_api.check_status(copilot_client, {}, function(cserr, status)
				if cserr or not status.user or status.status ~= "OK" or not cp_client.buf_is_attached(0) then
					copilot_status = "error"
					return
				end
				-- if
				-- 	cserr
				-- 	or not status.user
				-- 	or status.status == "NoTelemetryConsent"
				-- 	or status.status == "NotAuthorized"
				--  or not cp_client.buf_is_attached(0)
				-- then
				-- 	copilot_status = "error"
				-- 	return
				-- end
			end)
		end
		return configs.icons[copilot_status] or copilot_status or ""
	end,
}
