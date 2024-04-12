local M = {}

M._win = nil

M.open_float_window = function()
  local width = 50
  local height = 20

  local buf = vim.api.nvim_create_buf(false, true)

  local ui = vim.api.nvim_list_uis()[1]

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = (ui.height - height) / 2,
    col = (ui.width - width) / 2,
    anchor = 'NW',
    style = 'minimal',
  }

  local keys = {
    ['q'] = ":q<CR>",
    ['s'] = ":lua require('launch-config').select_conf()<CR>",
  }

  for key, cmd in pairs(keys) do
    vim.api.nvim_buf_set_keymap(buf, 'n', key, cmd, {
      noremap = true,
      silent = true,
      nowait = true,
    })
  end

  local conf_files = M.find_dap_conf_files()

  vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, conf_files)

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  M._win = vim.api.nvim_open_win(buf, true, opts)
end

M.find_dap_conf_files = function()
  local t = {}
  local data_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h") .. "/data/"

  local pfile = io.popen("ls -a '" .. data_dir .. "'")
  if pfile == nil then
    vim.notify("Directory with DAP configuration not found", vim.log.levels.ERROR, { title = "DAP Configurator" })
  end
  for filename in pfile:lines() do
    if filename ~= "." and filename ~= ".." then
      table.insert(t, filename)
    end
  end
  pfile:close()

  return t
end

M.select_conf = function()
  local cwd = vim.loop.cwd()
  local data_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h") .. "/data/"

  local selected_dap_config = vim.api.nvim_get_current_line()

  -- read dap configuration file
  local conf_file = io.open(data_dir .. selected_dap_config, "r")
  if conf_file == nil then
    vim.notify(
      "DAP configuration file not found",
      vim.log.levels.ERROR,
      { title = "DAP Configurator" }
    )
    return
  end
  -- local conf_file_content = conf_file:read("*a")
  local conf_file_content = {}
  for line in conf_file:lines() do
    table.insert(conf_file_content, "\t\t" .. line)
  end
  conf_file:close()

  -- prepare /.nvim/launch.json
  local launch_file = io.open(cwd .. "/.nvim/launch.json", "r")
  if launch_file == nil then
    vim.notify("launch.json will be created", vim.log.levels.INFO, { title = "DAP Configurator" })
    os.execute("mkdir '" .. cwd .. "/.nvim'")

    launch_file = io.open(cwd .. "/.nvim/launch.json", "w")
    if launch_file == nil then
      vim.notify("launch.json couldn't be created", vim.log.levels.ERROR, { title = "DAP Configurator" })
      return
    end

    launch_file:write("{\n\t\"version\": \"0.2.0\",\n\t\"configurations\": [\n\t]\n}")
    launch_file:close()
  end

  -- add configuration to launch.json
  launch_file = io.open(cwd .. "/.nvim/launch.json", "r")
  local launch_file_content = {}

  if launch_file == nil then
    vim.notify("launch.json couldn't be opened", vim.log.levels.ERROR, { title = "DAP Configurator" })
    return
  end


  for line in launch_file:lines() do
    table.insert(launch_file_content, line)
  end
  launch_file:close()

  if #launch_file_content > 5 then
    launch_file_content[#launch_file_content - 2] = launch_file_content[#launch_file_content - 2] .. ","
  end

  table.insert(launch_file_content, #launch_file_content - 1, table.concat(conf_file_content, "\n"))

  launch_file = io.open(cwd .. "/.nvim/launch.json", "w")
  if launch_file == nil then
    vim.notify("launch.json couldn't be opened", vim.log.levels.ERROR, { title = "DAP Configurator" })
    return
  end


  for _, line in ipairs(launch_file_content) do
    launch_file:write(line .. "\n")
  end
  launch_file:close()
  vim.api.nvim_win_close(M._win, true)
end

return M
