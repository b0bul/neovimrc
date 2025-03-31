## neovim kickstart customization
this is written for me, so not expecting reuse. This is a mechanism I use to sync
changes across multiple machines. By default Sync tries from cwd and can be called
with empty args.

Once deployed 
`<leader>cfg` syncs config from git, `<leader>ctg` syncs config to git
### dirs
- custom - plugins extend capability
- after - loads custom functions and bindings that alter functionality

deploy this repo to nvim
```
gh repo clone b0bu/neovimrc
cd neovimrc
nvim --headless -c "luafile after/plugin/sync.lua" -c "lua Sync({})" -c "qa"
```

