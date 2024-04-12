# Launch Config

## Description

Small plugin to be able to add configuration for debugging to `.nvim/launch.json` as I don't use set `adapters` in `nvim-dap` configuration.

## Installation

- Vim-Plug `Plug 'MijikHna/launch-config.nvim'`
- Packer `use 'MijikHna/launch-config.nvim'`

## Usage

1. Use command `:LaunchConfig` to see all possible configurations
2. Select one from the list by prssing `s`
3. Eventually add or change some values in `.nvim\launch.json`

## Key Mappings

- `s` - select configuration
- `q` - close

## TODO

0. Add Windows
1. Add custom location for presets (currently it is `/data`)
2. add `setup` function to be able to change location of presets and key mappings
3. allow add new configuration
4. better UI (similar to Telescope)
