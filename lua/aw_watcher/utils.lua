local function get_filename() return vim.fn.expand("%p") or "" end

local function get_filetype() return vim.bo.filetype end

local function set_project_name()
    if vim.b.project_name ~= nil then
      local project = vim.fs.root(0, '.git') or vim.fn.getcwd()
      vim.b.project_name = vim.fs.normalize(project):gsub(".*/", "")
    end
end

local function set_branch_name()
    if vim.b.branch_name ~= nil and not vim.b.branch_name_running then
        vim.b.branch_name_running = true
        vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, function(res)
          local branch = res.stdout:gsub("\n", "")
            vim.b.branch_name = branch == "" and "unknown" or branch
        end)
    end
end

local has_notify, notify = pcall(require, "notify")
if has_notify then
    function notify(msg, level)
        vim.schedule(function() notify(msg, level, { title = "Activity Watcher" }) end)
    end
else
    function notify(msg, level)
        vim.schedule(function() vim.notify("[Activity Watcher] " .. msg, level) end)
    end
end

return {
    get_filename = get_filename,
    get_filetype = get_filetype,
    set_project_name = set_project_name,
    set_branch_name = set_branch_name,
    notify = notify,
}
