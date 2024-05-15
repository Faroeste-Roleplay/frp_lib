local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

API = Tunnel.getInterface("API")
cAPI = {}

Tunnel.bindInterface("API", cAPI)
Proxy.addInterface("API", cAPI)