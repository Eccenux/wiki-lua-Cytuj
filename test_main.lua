-- include this library
local mw = require("mw/mw")

-- Current page
mw.title.setCurrentTitleMock("Testowa", "")

-- replace require to support namespace removal
local originalRequire = require
function require(moduleName)
	moduleName = moduleName:gsub("Modu[^:]+:", "")
	return originalRequire(moduleName)
end

-- Load a copy of a module
-- Note that this loads "ISBN.lua" file (a local file).
local p = require('Module:Cytuj')

--[==[
print("\nNumer poprawny")
local isbn = '9788388147159'
local builder = mw.html.create()
local html = p.link(builder, isbn)
mw.logObject(html)
local html = p.opis(isbn)
mw.logObject(html)
]==]
