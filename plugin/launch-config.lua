-- local dap_configurator = require('dap-launch-config')

vim.api.nvim_create_user_command(
  'LaunchConfig',
  function()
    require('launch-config').open_float_window()
  end,
  {
    force = true,
    desc = 'Add configuration to launch.json',
  }
)
