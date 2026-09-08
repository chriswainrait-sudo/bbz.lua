
local base="https://raw.githubusercontent.com/chriswainrait-sudo/bbz.lua/main/PRIME-GUI-Updated"
local names={"UI","Gameplay","Other","Extensions"}
assert(type(loadstring)=="function" and type(setfenv)=="function","Nexus: loadstring/setfenv unavailable")

local parent=getfenv()
local declared,ctx,modules={},{},{}
setmetatable(ctx,{__index=function(_,k)
    if declared[k] then return nil end
    return parent[k]
end})
local function read(name)
    return game:HttpGet(base:gsub("/+$","").."/modules/"..name..".lua")

end
local sources,failures,done={},{},0
for _,name in ipairs(names) do
    task.spawn(function()
        local ok,src=pcall(read,name)
        if ok and type(src)=="string" and #src>0 then sources[name]=src else failures[name]=tostring(src) end
        done+=1
    end)
end
local deadline=os.clock()+30
while done<#names and os.clock()<deadline do task.wait() end
assert(done==#names,"Module download timed out")
for _,name in ipairs(names) do
    assert(not failures[name],"Cannot download "..name..": "..tostring(failures[name]))
    local src=sources[name]
    local chunk,err=loadstring(src,"@7f3a9c2e/modules/"..name..".lua")
    assert(chunk,"Nexus: "..name..": "..tostring(err))
    local success,m=pcall(chunk)
    assert(success and type(m)=="table" and type(m.Init)=="function","Nexus: invalid module "..name..": "..tostring(m))
    for _,k in ipairs(m.Exports or {}) do declared[k]=true end
    setfenv(m.Init,ctx)
    modules[name]=m
end
local globals=type(getgenv)=="function" and getgenv() or _G
local previous=globals.__NexusBasketballZeroModules
if type(previous)=="table" and type(previous.Destroy)=="function" then previous.Destroy() end
local app={Modules=modules,Context=ctx,Loaded={}}
function app.Destroy()
    if app.Closed then return end
    app.Closed=true
    if ctx.Window and type(ctx.Window.Destroy)=="function" then pcall(ctx.Window.Destroy,ctx.Window)
    elseif ctx.NexusUI and type(ctx.NexusUI.UnloadFeatures)=="function" then pcall(ctx.NexusUI.UnloadFeatures,ctx.NexusUI) end
    if globals.__NexusBasketballZeroModules==app then globals.__NexusBasketballZeroModules=nil end
end
globals.__NexusBasketballZeroModules=app
for _,name in ipairs(names) do
    local ok,err=pcall(modules[name].Init)
    if not ok then app.Destroy(); error("Nexus: initialization failed in "..name..": "..tostring(err),0) end
    app.Loaded[#app.Loaded+1]=name
end
return app
