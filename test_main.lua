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
-- replace loader for pl-characters replacement
local originalLoadData = mw.loadData
local plToAscii = {
	["ą"] = "a", ["ć"] = "c", ["ę"] = "e", ["ł"] = "l",
	["ń"] = "n", ["ó"] = "o", ["ś"] = "s", ["ż"] = "z", ["ź"] = "z",
	["Ą"] = "A", ["Ć"] = "C", ["Ę"] = "E", ["Ł"] = "L",
	["Ń"] = "N", ["Ó"] = "O", ["Ś"] = "S", ["Ż"] = "Z", ["Ź"] = "Z"
}
local function replacePolishChars(str)
	return (str:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c)
		return plToAscii[c] or c
	end))
end
function mw.loadData(moduleName)
	moduleName = replacePolishChars(moduleName)
	return originalLoadData(moduleName)
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

local problems = {}
table.insert(problems, "typ? :: moze za \"duzo\" pol") -- test info z pytajnikiem; opis z cudzysłowem ang.
table.insert(problems, "pub. albo wyd. :: jednoczesne „opublikowany” oraz „wydawca”") -- test z kropkami
table.insert(problems, "test as-is: test") -- test bez opisu (np. raport z firewall)
mw.log(p.__priv.formatProblems(problems):gsub("span>,", "span>,\n"))

local s = "pub--albo--wyd"
s = s:gsub("%-%-+", "-")
print(s)