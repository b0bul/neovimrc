## neovim kickstart customization
This is written for me, so not expecting reuse. This is a mechanism I use to sync
changes across multiple machines and in and out of kickstart. By default `Sync` tries from cwd and can be called
with empty args.

```
NVIM v0.11.3
KICKSTART 3338d39
```

Once deployed 
`<leader>cfg` syncs any new config from git, `<leader>ctg` syncs new edits into git

### dirs
- lua - plugins that extend capability
- after - custom functions and bindings that alter functionality
- plugin - lua loaded before neovim loads plugins 

### deploy 
```bash
sudo apt install git gh ansible -y
gh repo clone b0bul/neovimrc && cd neovimrc
ansible-playbook -c local -i 'localhost,' main.yaml -u $(whoami)
# initial sync -  move to keymaps after this
nvim --headless -c "luafile after/plugin/sync.lua" -c "lua Sync({})" -c "qa"
```
### reqs 
- `'nvim-tree/nvim-web-devicons'` is pre-installed by kickstart

### installed lsps
- bash-debug-adapter
- clangd
- cpptools
- go-debug-adapter
- goimports
- gopls
- json-lsp
- jsonls
- jsonlint
- jsonnetfmt
- lua-language-server
- lua-ls
- stylua
- terraform-ls
- terraformls
- tflint
