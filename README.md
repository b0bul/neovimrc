## neovim kickstart customization
This is written for me, so not expecting reuse. This is a mechanism I use to sync
changes across multiple machines and in and out of kickstart. By default `Sync` tries from cwd and can be called
with empty args.

```
NVIM v0.11.0
KICKSTART e947649
```

Once deployed 
`<leader>cfg` syncs any new config from git, `<leader>ctg` syncs new edits into git

### dirs
- lua - plugins that extend capability
- after - custom functions and bindings that alter functionality

### reqs 
uncomment `{ import = 'custom.plugin' },` in `~/.config/nvim/init.lua`

deploy to nvim, I'm doing this from my `~/dev` dir. It's hardcoded in `sync.lua`.
```bash
gh repo clone b0bu/neovimrc
cd neovimrc
./deps.sh
#initial sync, move to keymaps after this
nvim --headless -c "luafile after/plugin/sync.lua" -c "lua Sync({})" -c "qa"
```

