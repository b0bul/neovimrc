## neovim kickstart customization
This is written for me, so not expecting reuse. This is a mechanism I use to sync
changes across multiple machines and in and out of kickstart. By default `Sync` tries from cwd and can be called
with empty args.

```
NVIM v0.11.4
KICKSTART 3338d39
```
to run as container either arm64 or amd64
```
nnn() { podman run -it --rm -v $PWD/$1:/tmp/$1 docker.io/maclighiche/dev-arm64:latest /bin/bash -c "nvim /tmp/$1"; }
# mount certificates if required
nnn() { podman run -it --rm -v $PWD/certs:/usr/local/share//ca-certificates:Z docker.io/maclighiche/dev-amd64:latest /bin/bash -c "update-ca-certificates && nvim /tmp/$1"; }
```
usage
```
# current directly
nnn .
# file
nnn main.c

to push container environments
```
podman login docker.io
```
### everything else

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
# keyboard maps <Leader>cfg <Leader>ctg to sync 
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
