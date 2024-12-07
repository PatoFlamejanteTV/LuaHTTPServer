--[[
Simple Lua HTTP server
Based on the LuaSocket library
Author: PatoFlamejanteTV/UltiamteQuack
Date: 12/7/2024 (MM/DD/YYYY)
]]--

local socket = require("socket")
local http = require("socket.http")

local open = io.open
local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end
local fileContent = read_file("typecode.min.css");

local port = 8080

-- Create a server socket
local server = socket.tcp()
server:bind("*", port)
server:listen(5)

print("Server started on port", port)

local function getOS()
  local raw_os_name, raw_arch_name = '', ''

  -- LuaJIT shortcut
  if jit and jit.os and jit.arch then
    raw_os_name = jit.os
    raw_arch_name = jit.arch
  else
    -- is popen supported?
    local popen_status, popen_result = pcall(io.popen, "")
    if popen_status then
      popen_result:close()
      -- Unix-based OS
      raw_os_name = io.popen('uname -s','r'):read('*l')
      raw_arch_name = io.popen('uname -m','r'):read('*l')
    else
      -- Windows
      local env_OS = os.getenv('OS')
      local env_ARCH = os.getenv('PROCESSOR_ARCHITECTURE')
      if env_OS and env_ARCH then
        raw_os_name, raw_arch_name = env_OS, env_ARCH
      end
    end
  end

  raw_os_name = (raw_os_name):lower()
  raw_arch_name = (raw_arch_name):lower()

  local os_patterns = {
    ['windows'] = 'Windows',
    ['linux'] = 'Linux',
    ['mac'] = 'Mac',
    ['darwin'] = 'Mac',
    ['^mingw'] = 'Windows',
    ['^cygwin'] = 'Windows',
    ['bsd$'] = 'BSD',
    ['SunOS'] = 'Solaris',
  }

  local arch_patterns = {
    ['^x86$'] = 'x86',
    ['i[%d]86'] = 'x86',
    ['amd64'] = 'x86_64',
    ['x86_64'] = 'x86_64',
    ['Power Macintosh'] = 'powerpc',
    ['^arm'] = 'arm',
    ['^mips'] = 'mips',
  }

  local os_name, arch_name = 'unknown', 'unknown'

  for pattern, name in pairs(os_patterns) do
    if raw_os_name:match(pattern) then
      os_name = name
      break
    end
  end
  for pattern, name in pairs(arch_patterns) do
    if raw_arch_name:match(pattern) then
      arch_name = name
      break
    end
  end
  return os_name, arch_name
end

if select(1, ...) ~= 'os_name' then
  print(("%q %q"):format(getOS()))
else
  return {
    getOS = getOS,
  }
end

-- main
while true do
local client, addr = server:accept()
print("Client connected from", addr)

-- hello world
client:send("HTTP/1.1 200 OK\r\n")
client:send("Content-Type: text/html\r\n\r\n")

client:send("<style>"..fileContent.."</style>")

client:send("<h1>Hello, world!</h1><br>\r\n")

client:send(
    "<a><small><i>Running from "
    ..getOS()..
    ", "
    .._VERSION..
    "</i></small></a>\r\n"
  )

-- die :(
client:close()
end