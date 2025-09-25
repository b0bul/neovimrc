## portable dev environment
This is written for me, it's my portable dev environment, so not expecting reuse. This is a mechanism I use to sync
changes across multiple machines and in and out my neovim config. The `Sync` module will be moved out of this into it's own lua plugin soon.

```
NVIM v0.11.4
KICKSTART 3338d39
```
to run as container either arm64 or amd64

```bash
# mount tmp 
nnn() { podman run -it --rm -v $PWD/$1:/tmp/$1 docker.io/maclighiche/dev-arm64:latest /bin/bash -c "nvim /tmp/$1"; }
# mount certificates if required
function nnn()
{
  lcerts=$HOME/.certs
  rcerts=/usr/local/share/ca-certificates
  image=docker.io/maclighiche/dev-amd64:latest
  ssh=$HOME/.ssh
  cmd=/tmp/$1
  path=$1

  cwd=$PWD/$path
  
  if [ "$path" = "update" ]; then
    podman pull ${image}
    ext=$? 
    return $ext
  fi
  
  if [[ "$path" =~ ^"r:" ]]; then
    path=$(echo $path | tr -d 'r:')
    # no need to pass leading /
    cmd="oil-ssh://<hostname>@<ip>/<somepathisrequired>/$path"
    podman run -it --rm \
          -v $lcerts:$rcerts:Z \
          -v $ssh:/root/.ssh:Z \
          $image /bin/bash -c "update-ca-certificates && nvim $cmd";
    ext=$? 
    return $ext
  fi
  
  echo mounting $cwd to /tmp/dev
  podman run -it --rm \
          -v $cwd:/tmp/dev:Z \ 
          -v $lcerts:$rcerts:Z \
          -v $ssh:/root/.ssh:Z \
          $image /bin/bash -c "update-ca-certificates && nvim $cmd";
  ext=$? 
  return $ext
}
```

usage
```console
# current dir local files
nnn .
# file
nnn main.c
# remote directory "dir" (oil-ssh inside if needed)
nnn r:dev
```
to push container environments with qemu based lima, `qemu-user-static` package required for multi-target compilation
```console
sudo apt install podman buildah qemu-user-static
podman login docker.io
# builds for amd64 and arm64
make all VERSION=vx.y.z
make push VERSION=vx.y.z
```
### everything else
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
