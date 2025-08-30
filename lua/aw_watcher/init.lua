local aw_client = require("aw_watcher.aw_client")
local utils = require("aw_watcher.utils")
local config = require("aw_watcher.config")

local START_HEARTBEAT_DELAY_MS = 1000

local M = {
    __private = {
        aw = nil, -- initialized aw client
        cached_cfg = nil, -- last config
    },
}

function M.heartbeat()
    if not M.__private.aw then
        utils.notify("Wasn't initialized. Check your spec or run setup() function.", vim.log.levels.WARN)
        return
    end
    M.__private.aw:heartbeat()
end

function M.bucket_start()
    if not M.__private.aw then
        utils.notify("Wasn't initialized. Check your spec or run setup() function.", vim.log.levels.WARN)
        return
    end
    M.__private.aw:create_bucket()
end

function M.connect_status()
    if not M.__private.aw then
        utils.notify("Wasn't initialized. Check your spec or run setup() function.", vim.log.levels.WARN)
        return
    end
    utils.notify(M.__private.aw.connected and "Connected" or "Disconnected", vim.log.levels.INFO)
end

local function create_autocommands()
    local augroup = vim.api.nvim_create_augroup("AcitivityWatch", { clear = true })

    local function make_heartbeat_cmd()
        vim.api.nvim_create_autocmd(
            { "CursorMoved", "BufLeave", "BufEnter", "CursorMovedI", "CmdlineEnter", "CmdlineChanged" },
            { group = augroup, callback = M.heartbeat }
        )
    end

    vim.defer_fn(make_heartbeat_cmd, START_HEARTBEAT_DELAY_MS)

    vim.api.nvim_create_autocmd("VimEnter", { group = augroup, callback = M.bucket_start })

    --vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "FocusGained" }, {
    --    group = augroup,
    --    callback = function()
    --        utils.set_branch_name()
    --        utils.set_project_name()
    --    end,
    --})
end

function M.setup(opts)
    local cfg = config.new(opts)

    M.__private.aw = aw_client.new(cfg.bucket, cfg.aw_server)
    M.__private.cached_cfg = cfg

    M.__private.aw:create_bucket()

    create_autocommands()
end

return M
