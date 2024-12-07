{ pkgs }: {
  deps = [
    pkgs.luaPackages.luasocket
    pkgs.luajitPackages.luarocks
    pkgs.lua
    pkgs.lua-language-server
  ];
}