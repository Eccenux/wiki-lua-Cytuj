local resources = mw.loadData("Moduł:Cytuj/dane")
local access = mw.loadData("Moduł:Cytuj/dostęp")

local function createCategories()
	local result = {}
	local mt = {
		__index = function(t,k)
			return resources.categories[k]
				or resources.categories.check
		end,
		__newindex = function(t,k,v)
			error("Kategorie są tylko do odczytu")
		end,
	}
	setmetatable(result, mt)
	return result
end

local categories = createCategories()

local function killLinkInterwiki(value)
	-- usuń z treści wikilinki generowane przez szablon link-interwiki
	-- szablon oznacza jako podejrzane wartości z tekstem "Wikipedia"
	local result, count = string.gsub(value, "%[%[:d:Q[0-9]+#sitelinks%-wikipedia|%(inne języki%)%]%]", "")
	return result
end

local function checkUri(uri)
	local urilen = #uri
	for _,v in ipairs(resources.supportedUriSchemas) do
		if (#v < urilen) and (string.lower(string.sub(uri,1, #v)) == v) then
			return not string.match(uri, '%s')
		end
	end
end

local function softNoWiki(text)
	local result, count = string.gsub(text, "['%[%]{|}\"]", { ["\""] = "&#x22;", ["'"] = "&#x27;", ["["] = "&#x5B;", ["]"] = "&#x5D;", ["{"] = "&#x7B;", ["|"] = "&#x7C;", ["}"] = "&#x7D;"})
	-- przywróc [[szablon:J]] z kursywą tak/nie
	result, count = string.gsub(result, "<span +style=&#x22;font%-style: ?([a-z]+);?&#x22; +lang=&#x22;([a-z%-]+)&#x22; *>", "<span style=\"font-style: %1;\" lang=\"%2\">")
	-- przywróc [[szablon:J]] goły
	result, count = string.gsub(result, "<span +lang=&#x22;([a-z%-]+)&#x22; *>", "<span lang=\"%1\">")
	-- przywróć nowiki
	result, count = string.gsub(result, "\127&#x27;&#x22;`UNIQ%-%-(nowiki%-[0-9A-F]+)%-QINU`&#x22;&#x27;\127", "\127'\"`UNIQ--%1-QINU`\"'\127")
	return result
end

local function escapeUrl(url)
	local result, count = string.gsub(url, "[ '%[%]\"]", { [" "] = "%20", ["'"] = "%27", ["["] = "%5B", ["]"] = "%5D", ["\""] = "%22"})
	return result
end

local function plainText(text)
	local result, count = string.gsub(text, "</?[Ss][Pp][Aa][Nn][^>]*>", "")
	return result
end

local function first(data)
	return type(data) == "table" and data[1] or data
end

local function determineMode(p)
	local detector = {}
	local count = 0
	for i, v in ipairs(resources.modes) do
		detector[i] = v
		count = count + 1
	end
	
	detector[1] = false -- skip 'auto'
	count = count - 1
	for k, v in pairs(resources.params) do
		local arg = p.args[v.name]
		for i, w in ipairs(v.used) do
			if not w and arg then
				-- unexpected argument
				if detector[i] then
					detector[i] = false
					count = count - 1
					if count == 0 then
						-- the mode cannot be determined
						break
					end
				end
			end
		end
		if count == 0 then
			-- the mode cannot be determined
			break
		end
	end
	
	if count == 1 then
		for i, v in ipairs(detector) do
			if detector[i] then
				return i, resources.COinS[i]
			end
		end
	end
	
	if detector[4] -- web?
	and p.args[resources.params.url.name]
	then
		-- promote to web but without COinS
		return 4, false
	end
	
	for i, v in ipairs(detector) do
		if detector[i] then
			-- if type is determined more than once
			-- use only the first one without COinS
			return i, false
		end
	end

	-- in case nothing is selected
	-- use the auto mode as default fallback
	return 1
end

local authorMetatable = {}
local authorMethodtable = {}

authorMetatable.__index = authorMethodtable

local function checkPatterns(author, prefixes, suffixes)
	if author.exact then
		return false
	end
	
	if author.prefix and prefixes then
		for _, v in ipairs(prefixes) do
			if mw.ustring.match(author.prefix, v) then
				return true
			end
		end
	end
	
	if author.suffix and suffixes then
		for _, v in ipairs(suffixes) do
			if mw.ustring.match(author.suffix, v) then
				return true
			end
		end
	end

	return false
end

authorMethodtable.format = function(data, namefirst)
	if data.exact then
		return data.exact
	end

	if namefirst and data.familynamefirst then
		namefirst = false
	end
	
	local builder = mw.html.create()
	local name = data.name and (#data.name > 0)
	local initials = data.nameinitials and (#data.nameinitials > 0)
	local namehint = nil
	if name and initials and (data.name ~= data.nameinitials) then
		namehint = data.name
	end
	
	if not data.familynamefirst and (name or initials) then
		local before = namefirst and builder or builder:tag("span"):addClass("cite-name-before")
		if name then
			before:tag("span"):addClass("cite-name-full"):wikitext(softNoWiki(data.name))
		end
		if initials then
			before:tag("span"):css("display", "none"):addClass("cite-name-initials"):attr("title", namehint):wikitext(softNoWiki(data.nameinitials))
		end
		before:wikitext("&nbsp;")
	end

	builder:tag("span"):addClass("cite-lastname"):wikitext(softNoWiki(data.lastname))

	if not namefirst and (name or initials) then
		local after = data.familynamefirst and builder or builder:tag("span"):css("display", "none"):addClass("cite-name-after")
		after:wikitext("&nbsp;")
		if name then
			after:tag("span"):addClass("cite-name-full"):wikitext(softNoWiki(data.name))
		end
		if initials then
			after:tag("span"):addClass("cite-name-initials"):attr("title", namehint):wikitext(softNoWiki(data.nameinitials))
		end
		if data.js then
			after:wikitext(",")
		end
	end
	
	if data.js then
		builder:wikitext("&nbsp;", data.js)
	end
	
	return tostring(builder)
end

authorMethodtable.towiki = function(data)
	if data.exact then
		return data.exact
	end

	local result = {}
	local name = data.name and (#data.name > 0)
	if not data.familynamefirst and name then
		table.insert(result,softNoWiki(data.name))
		table.insert(result, " ")
	end
	
	table.insert(result, softNoWiki(data.lastname))

	if data.familynamefirst and name then
		table.insert(result, " ")
		table.insert(result, softNoWiki(data.name))
	end

	return table.concat(result)
end

local function makeInitials(name)
	local nameinitials = mw.ustring.gsub(name, "(%w[Hh]?)[%w]*%.?([%s%-–—]?)%s*", "%1. ") -- zostaw początki słów (jedna litera + opcjonalne następujące 'h')
	nameinitials = mw.ustring.gsub(nameinitials, "%f[%w]%l%.%s", "")               -- usuń inicjały z małych liter
	nameinitials = mw.ustring.gsub(nameinitials, "([^C%W])[Hh]%.?%s", "%1. ")      -- usuń drugie 'h' jeśli nie zaczyna się na 'C'
	nameinitials = mw.ustring.gsub(nameinitials, "(%u[Hh]?)[%.%s]*", "%1.")        -- dodaj brakujące kropki i usuń zbędne spacje
	return mw.text.trim(nameinitials)
end

local function fixInitials(name)
	local result, _ = mw.ustring.gsub(name, "^(%uh?)%.?%s+(%uh?)%.", "%1.%2.") -- popraw inicjały na początku
	result, _ = mw.ustring.gsub(result, "%f[%a](%uh?)%.%s+(%uh?)%.", "%1.%2.") -- popraw inicjały w środku
	result, _ = mw.ustring.gsub(result, "%f[%a](%uh?)%.%s+(%uh?)%.", "%1.%2.") -- popraw kolejne inicjały w środku
	return result
end

local function isInQuotes(text)
	if (string.len(text) < 2) then
		return false;
	end
	local tstart = text:sub(1, 1);
	if (tstart ~= '"') then
		return false;
	end
	local tend = text:sub(-1);
	if (tend ~= '"') then
		return false;
	end
	return true;  
end

local function parseAuthor(author)
	
	local result = {}
	
	if string.match(author, "\127") then -- wpisy z <nowiki> nie są analizowane
		result.exact = author
		setmetatable(result, authorMetatable)
		return result
	end
	
	local author = mw.text.trim(author)
	
	local a = string.gsub(author, "\\[\\%.:]", { ["\\\\"]="\\", ["\\."]=",", ["\\:"]=";", })
	if a ~= author then
		result.exact = a
		setmetatable(result, authorMetatable)
		return result
	end

	if resources.exactAuthors[author] then
		result.exact = author
		setmetatable(result, authorMetatable)
		return result
	end

	local exactName = mw.ustring.match(author, "^%s*%*%s*(.*)$")
	if exactName then
		result.exact = mw.text.trim(exactName)
		if #result.exact == 0 then
			return nil
		end
		
		setmetatable(result, authorMetatable)
		return result
	end

	local prefix0, link, description, suffix0 = mw.ustring.match(author, "^(.-)%[%[(.-)%|(.-)%]%](.*)$")
	if prefix0 then
		result.link = link
		author = description
	else
		prefix0, link, suffix0 = mw.ustring.match(author, "^(.-)%[%[(.-)%]%](.*)$")
		if prefix0 then
			author = link
			result.link = link
		else
			prefix0 = ""
			suffix0 = ""
		end
	end

	local prefix1, rest = mw.ustring.match(author, "^([%l%p%s]+)(.+)$")
	if not prefix1 then
		rest = author
		prefix1 = ""
	end

	local prefix = mw.text.trim(prefix0.." "..prefix1)
	if #prefix > 0 then
		if mw.ustring.sub(prefix, -1) == "#" then
			result.familynamefirst = true
			prefix = mw.text.trim(mw.ustring.match(prefix, "^(.-)#$"))
		end
		if #prefix > 0 then
			result.prefix = mw.ustring.gsub(prefix, "%s+", " ") -- collapse spaces
		end
	end

	local rest2, suffix = mw.ustring.match(rest, "^([%w%-%.%s]-)%s([%l%p%s]-)$")
	if not suffix then
		rest2 = rest
		suffix = ""
	end
	
	suffix = mw.text.trim(suffix.." "..suffix0)
	if #suffix > 0 then
		result.suffix = mw.ustring.gsub(suffix, "%s+", " ") -- collapse spaces
		suffix = " "..result.suffix
		for i, v in ipairs(resources.js) do
			if mw.ustring.match(suffix, v[1]) then
				result.suffix = mw.text.trim(mw.ustring.gsub(suffix, v[1], ""))
				result.js = v[2]
				break
			end
		end
	else
		for i, v in ipairs(resources.js) do
			if mw.ustring.match(rest2, v[1]) then
				rest2 = mw.text.trim(mw.ustring.gsub(rest2, v[1], ""))
				result.js = v[2]
				break
			end
		end
	end

	local lastname, name = mw.ustring.match(rest2, "%s*([^,]-)%s*,%s*(.-)%s*$")
	if not lastname then
		if result.familynamefirst then
			lastname, name = mw.ustring.match(rest2, "%s*(%u[%l%d%p]*)%s+(.-)%s*$")
		else
			local prefix2
			name, lastname, prefix2 = mw.ustring.match(rest2, "%s*(.-)%s+((%l[%l%p]%l?)%u[%w%p]-)%s*$")
			if not resources.lastnamePrefixes[prefix2] then
				name, lastname = mw.ustring.match(rest2, "%s*(.-)%s+(%u[%w%p]-)%s*$")
			end
		end
	elseif resources.lastnamePrefixes[prefix1] then
		lastname = prefix1 .. lastname
	elseif resources.lastnamePrefixes[prefix1] == false then
		name = name.." "..mw.text.trim(prefix1)
	end
	
	if not lastname then
		result.lastname = mw.text.trim(rest2)
	else
		result.name = fixInitials(name)
		result.lastname = lastname
		result.nameinitials = makeInitials(name)
	end
	
	if #result.lastname == 0 then
		return nil
	end
	
	setmetatable(result, authorMetatable)
	return result
end

local function parseDate(date, month, year, patch)
	local result = {}
	
	-- parse full date
	local y, m, d = false, false, false
	y, m, d = mw.ustring.match(date, "(%d%d%d%d)[%-%s%./](%d%d?)[%-%s%./](%d%d?)")
	
	if y and patch and (date == (y.."-01-01")) then
		result.year = tonumber(y)
		result.month = false
		result.day = false
		return result, true
	end
	
	if not y then
		d, m, y = mw.ustring.match(date, "(%d%d?)[%-%s%.](%d%d?)[%-%s%.](%d%d%d%d)")
		if not y then
			y, m, d = mw.ustring.match(date, "(%d%d%d%d)%s*(%w+)%s*(%d%d?)")
			if not y then
				d, m, y = mw.ustring.match(date, "(%d%d?)%s*(%w+)%s*(%d%d%d%d)")
			end
			if m then
				m = resources.monthparser[mw.ustring.lower(m)]
				if not m then
					y = false
					m = false
					d = false
				end
			end
		end
	end

	if y then
		y = tonumber(y)
		m = tonumber(m)
		d = tonumber(d)
	end
	if y and ((d > 31) or (m > 12) or (d < 1) or (m < 1)) then 
		y = false
		m = false
		d = false
	elseif y then
		result.year = y
		result.month = m
		result.day = d
		return result, false
	end
	
	-- parse year and month
	y, m = mw.ustring.match(date, "(%d%d%d%d)[%-%s%./](%d%d?)")
	if not y then
		m, y = mw.ustring.match(date, "(%d%d?)[%-%s%./](%d%d%d%d)")
		if not y then
			y, m = mw.ustring.match(date, "(%d%d%d%d)%s*(%w+)")
			if not y then
				m, y = mw.ustring.match(date, "(%w+)%s*(%d%d%d%d)")
			end
			if m then
				m = resources.monthparser[mw.ustring.lower(m)]
				if not m then
					y = false
					m = false
				end
			end
		end
	end
	if y then
		y = tonumber(y)
		m = tonumber(m)
	end
	if y and ((m > 12) or (m < 1)) then 
		y = false
		m = false
	elseif y then
		result.year = y
		result.month = m
		return result, false
	end
	
	-- try any method to extract year or month
	if not y then
		y = mw.ustring.match(date, "[%s%p%-–]?(%d%d%d%d)[%s%p%-–]?")
		if y then
			y = tonumber(y)
		end
		if y then
			result.year = y
		end
	end

	if y then
		if not m then
			m = mw.ustring.match(date, "[%s%p%-–]?(%w+)[%s%p%-–]?")
			if m then
				m = resources.monthparser[mw.ustring.lower(m)]
			end
			if m then
				result.month = m
			end
		end
	else
		-- reset only month
		result.month = nil
	end
	
	if y then
		return result, false
	end
end

local function collectAuthors(author, checkForAltFormat)
	if not author then
		return
	end
	
	-- Obsługa cudzysłowów w autorach (treat quoted authors as-is)
	if (isInQuotes(mw.text.trim(author))) then
		local strippedAuthor = mw.text.trim(author, '"\t\r\n\f ')
		return { items = {strippedAuthor}, more=false, comma=false, etal=false, separator="" }
	end
	
	
	function findUtf8CharAt(text, at)
		local back = false
		if at < 0 then
			at = #text + at + 1
			back = true
		end
		
		while at > 1 do
			local b = string.byte(text, at, at)
			if (b < 128) or (b >= 192) then
				break
			end
			
			at = at - 1
		end
		
		return back and at - #text - 1 or at
	end
	
	local etal = false
	local authorTail = #author <= 50 and author or string.sub(author, findUtf8CharAt(author, -50))
	for i, p in ipairs(resources.etalPatterns) do
		local a, e = string.match(authorTail, p)
		if a then
			author = string.sub(author, 1, #author-#e)
			etal = e
			break
		end
	end
	
	function decodeEntity(s)
		local result = nil
		local hex = string.match(s, "^&#[xX]([0-9A-Fa-f]+);$")
		if hex then
			result = mw.ustring.char(tonumber(hex, 16))
		else
			local dec = string.match(s, "^&#([0-9]+);$")
			if dec then
				result = mw.ustring.char(tonumber(dec, 10))
			elseif resources.htmlEntities[s] then
				result = mw.ustring.char(resources.htmlEntities[s])
			else
				return string.gsub(s, ";", "\\:")
			end
		end
		
		if result == ";" then
			return "\\:"
		elseif result == "," then
			return "\\."
		elseif result == "\\" then
			return "\\\\"
		else
			return result
		end
	end
	
	local authorHead = #author <= 500 and author or string.sub(author, 1, findUtf8CharAt(author, 500) - 1)
	local result = {}
	local esc1 = string.gsub(authorHead, "\\", "\\\\")
	local esc2 = string.gsub(esc1, "&#?[a-zA-Z0-9]+;", decodeEntity)
	local splitter = string.match(esc2, ";") and ";" or ","
	local authors = mw.text.split(esc2, splitter.."%s*", false)
	local nth = false
	local count = #authors
	if (#authorHead < #author) and (count > 4) then
		if count > 5 then
			table.remove(authors, count)
			count = count - 1
		end
		
		local at, _ = string.find(authorHead, authors[count], 1, true)
		nth = string.sub(author, at)
		table.remove(authors, count)
		count = count - 1
	end
	
	local alt = false
	if (splitter == ",") and checkForAltFormat then
		local altAuthors = {}
		alt = true
		for i, v in ipairs(authors) do
			local n0 = ""
			local s, n = mw.ustring.match(v, "^(%u%l+)%s(%u+)%.?$")
			if not s then
				s, n = mw.ustring.match(v, "^(%u%l+[%s%-–]%u%l+)%s(%u+)%.?$")
			end
			if not s then
				n0, s, n = mw.ustring.match(v, "^(%l%l%l?)%s(%u%l+)%s(%u+)%.?$") -- de, von, van, der etc.
			end
			if not s then
				alt = false
				break
			end
			local initials, _ = mw.ustring.gsub(n, "(%u)", "%1.")
			if #n0 > 0 then
				n0 = " "..n0
			end
			table.insert(altAuthors, s..", "..initials..n0)
		end
		
		if alt then
			authors = altAuthors
			splitter = ";"
		end
	end
	
	for i, v in ipairs(authors) do
		local author = parseAuthor(v)
		if author then
			table.insert(result, author)
		end
	end

	if #result == 0 then
		return
	end
	
	local check = false
	if alt then
		check = "alt"
	elseif (#result == 2) and (splitter == ",") then
		check = not result[1].link and not result[1].exact and not result[1].name
			or	not result[2].link and not result[2].exact and not result[2].name
		if check then
			if result[1].lastname and not result[1].name and not result[2].exact
			and not mw.ustring.match(result[1].lastname, "%S%s+%S") then
				local oneAuthor = parseAuthor(author)
				if oneAuthor then
					table.remove(result,2)
					result[1] = oneAuthor
					check = false
				end
			end
		end
		if check then
			mw.logObject(result,"przecinek u autora")
		end
	end
	
	return { items = result, more=nth, comma = check, etal = etal, separator=splitter.." " }
end
	
local function formatAuthors(authors, useDecorations, nextgroup, etalForm)
	local count = #authors.items
	if count == 0 then
		return nil, false
	end
	
	local suffix = function(author)
		if useDecorations then
			for _, v in ipairs(resources.authorFunc) do
				if checkPatterns(author, v.prefixes, v.suffixes) then
					return v.append
				end
			end
		end
		
		return ""
	end
	
	local formatter = function(author)
		local a = author:format(nextgroup)
		local r = author.link and ("[["..author.link.."|"..a.."]]") or a
		return r..suffix(author)
	end
	
	if count == 1 then
		local a1 = formatter(authors.items[1])
		local etal = authors.etal and (etalForm or " i inni") or ""
		return a1..etal, false
	end
	
	local result = {}
	table.insert(result, formatter(authors.items[1]))
	if not authors.etal and (count <= 3) then
		table.insert(result, ", ");
		table.insert(result, formatter(authors.items[2]))
		if count == 3 then
			table.insert(result, ", ");
			table.insert(result, formatter(authors.items[3]))
		end
		
		return table.concat(result, ""), false
	end

	local title = {}
	for i = 1, count do
		table.insert(title, authors.items[i]:towiki()..suffix(authors.items[i]))
	end
	if authors.more then
		table.insert(title, authors.more)
	end
	
	table.insert(result, "<span class=\"cite-at-al\" title=\"")
	table.insert(result, table.concat(title, authors.separator))
	if authors.etal then
		table.insert(result, etalForm or " i inni")
	end
	table.insert(result, "\">")
	table.insert(result, etalForm or " i inni")
	table.insert(result, "</span>")
	return table.concat(result, ""), true
end

local function collectLanguages(value)
	if value then
		local result = {}
		local values = mw.text.split(value, "%s+")
		for _, v in ipairs(values) do
			if #v > 0 then
				table.insert(result, v)
			end
		end
	
		if #result > 0 then
			return result
		end
	end

	return nil
end

local function splitFileLink(link)
	local linkTitle = string.match(link, "^:(.+)$")
	if not linkTitle then
		return link, false
	end
	
	local title = mw.title.new(link)
	if not title then
		return link, false
	end
	
	mw.logObject(title.text, "splitFileLink - title.text")
	if title.namespace == 6 then
		local name, ext = mw.ustring.match(title.text, "(.-)%.(%a+)$")
		if ext and resources.wikilinks.extensions[mw.ustring.lower(ext)] then
			return name, ext
		end
	elseif #title.interwiki > 0 then
		local prefix, name, ext = mw.ustring.match(title.text, "(%a+):(.-)%.(%a+)$")
		if prefix and resources.wikilinks.files[mw.ustring.upper(prefix)] and ext and resources.wikilinks.extensions[mw.ustring.lower(ext)] then
			return name, ext
		end
	end
	
	return link, false
end

local function splitWikiLink(text)
	local link, description = mw.ustring.match(text, "^%[%[(.-)%|(.-)%]%]$")
	if link then
		local name, ext = splitFileLink(link)
		return description, link, false, ext
	end
	
	local link = mw.ustring.match(text, "^%[%[(.-)%]%]$")
	if link then
		local name, ext = splitFileLink(link)
		return name or link, link, false, ext
	end
	
	local link, description = mw.ustring.match(text, "^%[(%S*)%s+(.-)%]$")
	if link and checkUri(link) then
		return description, false, link, false
	end
	
	return text, false, false, false
end

local function detectArchive(url)
	local uri = mw.uri.new(url)
	local detectors = resources.archiveDecoders.services[resources.archiveDecoders.hosts[uri.host]]
	if detectors then
		--mw.logObject(uri.host,"detectArchive uri.host")
		--mw.logObject(uri.relativePath,"detectArchive uri.relativePath")
		--mw.logObject(resources.archiveDecoders.hosts[uri.host],"detectArchive service")
		for i, v in ipairs(detectors) do
			local pattern = v.pattern
			local decoder = resources.archiveDecoders.decoders[v.decoder]
			if pattern and decoder then
				local items = { mw.ustring.match(uri.relativePath, pattern) }
				if #items > 0 then
					--mw.logObject(items[decoder.link],"detectArchive link")
					--mw.logObject(items[decoder.year].."-"..items[decoder.month].."-"..items[decoder.day],"detectArchive date")
					return items[decoder.link], items[decoder.year].."-"..items[decoder.month].."-"..items[decoder.day]
				end
			end
		end
	end

	return false, false
end

local function isAutoGeneratedUrl(url)
	local address = string.gsub(url, "^https?:", "")
	for k, v in pairs(resources.params) do
		if v.link then
			local links = type(v.link) == "table" and v.link or { v.link }
			for _, vlink in ipairs(links) do
				local prefix = string.gsub(vlink, "^https?:", "")
				if (#address > #prefix) and (string.sub(address, 1, #prefix) == prefix) then
					return v.name
				end
			end
		end
	end

	return false
end

local function loadCitation(frame, mode)
	local result = {}

	-- map parameters based on: Moduł:Cytuj/dane
	for k, v in pairs(resources.params) do
		if v.used[mode] then
			local value = frame.args[v.name]
			if value then
				value = mw.text.trim(value)
				if #value > 0 then
					result[k] = value
				end
			end
		
			if (v.used[mode] == "!") and not result[k] then
				-- simulate missing mandatory parameter
				result[k] = "{{{"..v.name.."}}}"
				if not result.missing then
					result.missing = v.name
				end
			end
		end
	end
	
	-- check url argument
	if result.url == "nie" then
		result.url = false
	elseif result.url then
		if not checkUri(result.url) then
			local unstrip = mw.text.unstripNoWiki( result.url )
			result.url = false
			if unstrip then
				result.urlnowiki = checkUri(unstrip)
			end
		end
	end

	-- translate some parameters
	local altAuthorParser = false
	if result.journal and result.pmid and result.author and not result.chapterauthor and not result.editor and not result.others then
		altAuthorParser = true
	end
	
	result.chapterauthor = collectAuthors(result.chapterauthor, false)
	result.author = collectAuthors(result.author, altAuthorParser)
	result.lang = collectLanguages(result.lang)
	result.editor = collectAuthors(result.editor, false)
	result.others = collectAuthors(result.others, false)

	-- parse main bibliographic date
	if result.date then
		local bibDate = false
		local bibDateHint = false
		local coinsDate = false
		local odnDate = false
		for _, v in ipairs(resources.bibDates) do
			for _, p in ipairs(v.patterns) do
				local bib, c = mw.ustring.gsub(result.date, p, v.show)
				if bib and (c > 0) then
					bibDate = bib
					bibDateHint = v.hint
					if v.coins then
						local cd, cc = mw.ustring.gsub(result.date, p, v.coins)
						if cd and (cc > 0) then
							coinsDate = cd
						end
					end

					if v.odn then
						local od, oc = mw.ustring.gsub(result.date, p, v.odn)
						if od and (oc > 0) then
							odnDate = od
						end
					end
					
					break
				end
				
				if bibDate then
					break
				end
			end
		end

		if bibDate then
			result.date = { bib = bibDate, hint = bibDateHint, coins = coinsDate, odn = odnDate }
		else
			local date, patch = parseDate(result.date or "", false, false, true)
			if date then
				date.coins = (patch and date.year)
					or (date.day and string.format("%04d-%02d-%02d", date.year, date.month, date.day)) 
					or (date.month and string.format("%04d-%02d", date.year, date.month))
					or date.year
				date.odn = date.year
			elseif result.date then
				result.badDate = true
			end
			
			result.date = date
			result.patchCitoidDate = patch
		end
	end

	-- fix other dates
	if result.accessdate then
		result.accessdate = parseDate(result.accessdate or "", false, false, false)
		if result.accessdate and not result.accessdate.day then
			result.badAccessDate = true
			result.accessdate = nil
		elseif not result.accessdate then
			result.badAccessDate = true
		end
	end

	-- allow more ISBN numbers
	if result.isbn then
		-- TODO allow "(info)" for custom description followed each identifier
		result.isbn = mw.text.split(result.isbn, "%s+")
	end
	
	if result.title then
		local url
		result.title, result.titlelink, url, result.titleext = splitWikiLink(result.title)
		if url or result.titlelink then
			if result.url and (#result.url > 0) and (result.url ~= "{{{url}}}") then
				result.urlWarning = true
			end
			
			result.url = url
		end
	end
	if result.chapter then
		result.chapter, result.chapterlink, result.chapterurl, result.chapterext = splitWikiLink(result.chapter)
	end
	if result.journal then
		local journalAbbr, _ = mw.ustring.gsub(result.journal, "[%.%s]+", " ")
		mw.logObject(journalAbbr, "journalAbbr")
		if mw.ustring.match(journalAbbr, "^[%a%s&-]+[,:]?[%a%s&-]+%d?$") -- kandydat na skrót powinien mieć tylko litery z opcjonalnymi odstępami i co najwyżej jednym dwukropkiem lub przecinkiem
		or mw.ustring.match(journalAbbr, "^[%a%s&-]+%([%a%s&-,:]+%d*%)$") then -- opcjonalnie jakieś dookreślenie w nawiasie
			local expandedJournal = mw.loadData("Moduł:Cytuj/czasopisma")[mw.text.trim(journalAbbr)]
			if expandedJournal then
				result.originalJournal = result.journal
				result.journal = expandedJournal
			end
		end
		result.journal, result.journallink, result.journalurl, result.journalext = splitWikiLink(result.journal)
	end
	if result.journal and not result.journallink and not result.journalurl and not result.title and result.url then
		result.journalurl = result.url
		result.url = false
	end

	if result.url then
		local n = isAutoGeneratedUrl(result.url)
		if n then
			result.rejectedurl = true
			if result[n] then
				result.url = false
			end
		end
	end
	if result.chapterurl then
		local n = isAutoGeneratedUrl(result.chapterurl)
		if n then
			result.rejectedurl = true
			if result[n] then
				result.chapterurl = false
			end
		end
	end
	if result.journalurl then
		local n = isAutoGeneratedUrl(result.journalurl)
		if n then
			result.rejectedurl = true
			if result[n] then
				result.journalurl = false
			end
		end
	end

	if not result.archive and result.url then
		local al, ad = detectArchive(result.url)
		if al then
			result.archiveurl = true
			result.archive = result.url
			result.url = al
			if ad then result.archived = ad end
		end
	elseif not result.archive and result.chapterurl then
		local al, ad = detectArchive(result.chapterurl)
		if al then
			result.archivechapter = true
			result.archive = result.chapterurl
			result.chapterurl = al
			if ad then result.archived = ad end
		end
	elseif not result.archive and result.journalurl then
		local al, ad = detectArchive(result.journalurl)
		if al then
			result.archivejournal = true
			result.archive = result.journalurl
			result.journalurl = al
			if ad then result.archived = ad end
		end
	elseif result.archive and not result.archived then
		local al, ad = detectArchive(result.archive)
		if ad and not result.archived then result.archived = ad	end
	end
	
	if result.archive then
		if result.chapterurl and not result.url then
			result.archivechapter = true
		elseif result.title then
			result.archiveurl = true
		elseif result.journal then
			result.archivejournal = true
		end
	end

	if result.archived then
		result.archived = parseDate(result.archived or "", false, false, false)
		if result.archived and not result.archived.day then
			result.badArchivedDate = true
			result.archived = null
		elseif not result.archived then
			result.badArchivedDate = true
		end
	end

	if result.edition and result.journal and not result.volume and not result.issue then
		local volume, issue = mw.ustring.match(result.edition, "^%s*([^%(]+)%s+%((.-)%)%s*$");
		if volume then
			result.volume = volume
			result.issue = issue
			result.edition = nil
		end
	end

	if result.pmc and (#result.pmc > 3) and (mw.ustring.sub(result.pmc, 1, 3) == "PMC") then
		result.pmc = mw.ustring.sub(result.pmc, 4, #result.pmc)
	end

	if result.accessKind then
		result.accessKind = access.choice[result.accessKind]
		result.unknownAccess = not result.accessKind
	else
		result.accessKind = (result.pmc and "open")
			or access.doi[doiPrefix]
			or access.journals[result.journal]
	end

	if result.doi then
		result.doi = mw.text.split(result.doi, '%s+', false)
		for i, v in ipairs(result.doi) do
			local doiPrefix
			local doiSuffix
			doiPrefix, doiSuffix = mw.ustring.match(v, "^10%.([^/]+)/(.+)$")
			if (doiPrefix == "2307") and not result.jstor then
				result.jstor = doiSuffix
			end
			if not result.accessKind and not result.unknownAccess then
				result.accessKind = access.doi[doiPrefix]
			end
		end
	end
	
	if result.patent then
		mw.logObject(result.patent,"input:patent")
		local patentPatterns = mw.loadData("Moduł:Cytuj/patent")
		local patent = nil
		for _, v in ipairs(patentPatterns) do
			if string.match(result.patent, v.pattern) then
				local patentNumber, _ = string.gsub(result.patent, v.pattern, v.number or "%1")
				local patentCountry, _ = string.gsub(result.patent, v.pattern, v.country)
				local patentInfo = v.info or patentPatterns.ccinfo[patentCountry]
				if (result.url == nil) and v.url then
					local url, _ = string.gsub(result.patent, v.pattern, v.url)
					if checkUri(url) then
						result.url = url
					end
				end
				
				local patentTitle
				if v.title then
					patentTitle, _ = string.gsub(result.patent, v.pattern, v.title)
				elseif patentInfo then
					patentTitle =  string.format('<span title="%s">%s %s</span>', patentInfo, patentCountry, patentNumber)
				else
					patentTitle =  patentCountry.." "..patentNumber
				end

				patent = {
					number = patentNumber,
					application = v.application,
					country = patentCountry,
					title = patentTitle,
				}
				
				break
			end
		end
		
		result.patent = patent
		mw.logObject(result.patent,"parsed:patent")
	end

	-- return collected parameters if there is any	
	for k, v in pairs(result) do
		return result
	end
	
	-- there are no supported parameters
	return nil
end

local function prepareOdnIdentifier(data)
	if not data.odn or (#data.odn == 0) or (data.odn == "nie") then
		return nil
	end

	data.diferentiator = mw.ustring.match(data.odn, "^([a-z])$") or false
	if data.odn ~= "tak" and not data.diferentiator then
		-- TODO return only CITEREF...
		return data.odn
	end
	
	local authors = data.chapterauthor or data.author or data.editor
	if not authors then
		-- required custom identifier
		return nil
	end
	
	return "CITEREF"
		.. (authors.items[1] and (authors.items[1].lastname or authors.items[1].exact) or "")
		.. (authors.items[2] and (authors.items[2].lastname or authors.items[2].exact) or "")
		.. (authors.items[3] and (authors.items[3].lastname or authors.items[3].exact) or "")
		.. (authors.items[4] and (authors.items[4].lastname or authors.items[4].exact) or "")
		.. (data.date and data.date.odn or "")
		.. (data.diferentiator or "")
end

local function bookCOinS(data)
	local authors = data.chapterauthor or data.author
	local result = {}
	result["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:book"
	if data.chapter and (#data.chapter > 0) then
		result["rft.gengre"] = "bookitem"
		result["rft.atitle"] = plainText(data.chapter)
		result["rft.btitle"] = plainText(data.title)
	elseif data.work and (#data.work > 0) then
		result["rft.gengre"] = "bookitem"
		result["rft.atitle"] = plainText(data.title)
		result["rft.btitle"] = plainText(data.work)
	else
		result["rft.btitle"] = plainText(data.title)
		result["rft.gengre"] = "book"
	end
	if authors then
		if authors.items[1].lastname then result["rft.aulast"] = authors.items[1].lastname end
		if authors.items[1].name then result["rft.aufirst"] = authors.items[1].name end
		if authors.items[1].exact then result["rft.au"] = authors.items[1].exact end
	end
	if data.date and data.date.coins then
		result["rft.date"] = data.date.coins
	end
	if data.series then result["rft.series"] = data.series end
	if data.edition then result["rft.edition"] = data.edition end
	if data.publisher then result["rft.pub"] = data.publisher end
	if data.place then result["rft.place"] = data.place end
	if data.pages then result["rft.pages"] = data.pages end
	if data.isbn then result["rft.isbn"] = data.isbn[1] end
	if data.issn then result["rft.issn"] = data.issn end
	
	local params = {
		"ctx_ver=Z39.88-2004",
		mw.uri.buildQueryString(result),
	}

	if data.oclc then table.insert(params, mw.uri.buildQueryString( {rft_id = "info:oclcnum/"..data.oclc})) end
	if data.doi then
		for _, v in ipairs(data.doi) do
			table.insert(params, mw.uri.buildQueryString( {rft_id = "info:doi/"..v}))
		end
	end
	if data.url then table.insert(params, mw.uri.buildQueryString( {rft_id = data.url})) end
	if data.pmid then table.insert(params, mw.uri.buildQueryString( {rft_id = "info:pmid/"..data.pmid})) end
	if data.lccn then table.insert(params, mw.uri.buildQueryString( {rft_id = "info:lccn/"..data.lccn})) end
		
	local coinsData = table.concat(params, "&")
	return coinsData;
end

local function journalCOinS(data)
	local result = {}
	result["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
	local gengre = (data.arxiv and (#data.arxiv > 0)) and "preprint" or "article"
	result["rft.gengre"] = data.title and gengre or "journal"
	if data.title then result["rft.atitle"] = plainText(data.title) end
	result["rft.jtitle"] = plainText(data.journal)
	if data.chapter then result["rft.atitle"] = plainText(data.chapter) end
	if data.date and data.date.coins then
		result["rft.date"] = data.date.coins
	end
	if data.title and author then
		if author[1].lastname then result["rft.aulast"] = author[1].lastname end
		if author[1].name then result["rft.aufirst"] = author[1].name end
		if author[1].exact then result["rft.au"] = author[1].exact end
	end
	if data.volume then result["rft.volume"] = data.volume end
	if data.issue then result["rft.edition"] = data.issue end
	if data.publisher then result["rft.pub"] = data.publisher end
	if data.place then result["rft.place"] = data.place end
	if data.pages then result["rft.pages"] = data.pages end
	if data.issn then result["rft.issn"] = data.issn end
	
	local params = {
		"ctx_ver=Z39.88-2004",
		mw.uri.buildQueryString(result),
	}

	if data.pmid then table.insert(params, mw.uri.buildQueryString( {rft_id = "info:pmid/"..data.pmid})) end
	if data.pmc then table.insert(params, mw.uri.buildQueryString( {rft_id = "info:pmc/"..data.pmc})) end
	if data.doi then
		for _, v in ipairs(data.doi) do
			table.insert(params, mw.uri.buildQueryString( {rft_id = "info:doi/"..v}))
		end
	end
	if data.url then table.insert(params, mw.uri.buildQueryString( {rft_id = data.url})) end
		
	local coinsData = table.concat(params, "&")
	return coinsData;
end

local function webCOinS(data)
	local result = {}
	result["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
	result["rft.gengre"] = "unknown"
	if data.title then result["rft.atitle"] = plainText(data.title) end
	result["rft.jtitle"] = plainText(data.published)
	if data.date and data.date.coins then
		result["rft.date"] = data.date.coins
	end
	if data.title and author then
		if author[1].lastname then result["rft.aulast"] = author[1].lastname end
		if author[1].name then result["rft.aufirst"] = author[1].name end
		if author[1].exact then result["rft.au"] = author[1].exact end
	end
	local params = {
		"ctx_ver=Z39.88-2004",
		mw.uri.buildQueryString(result),
	}

	if data.url then table.insert(params, mw.uri.buildQueryString( {rft_id = data.url})) end
		
	local coinsData = table.concat(params, "&")
	return coinsData;
end

local function patentCOinS(data)
	local result = {}
	result["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
	if data.title then result["rft.title"] = plainText(data.title) end
	result[data.patent.application and "rft.applnumber" or "rft.number"] = data.patent.number
	result["rft.cc"] = data.patent.country
	if data.date and data.date.coins then
		result[data.patent.application and "rft.appldate" or "rft.date"] = data.date.coins
	end
	if author then
		if author[1].lastname then result["rft.aulast"] = author[1].lastname end
		if author[1].name then result["rft.aufirst"] = author[1].name end
		if author[1].exact then result["rft.au"] = author[1].exact end
	end
	-- rft.assignee = author (wszyscy?)
	-- rft.inventor = others (wszyscy?)
	local params = {
		"ctx_ver=Z39.88-2004",
		mw.uri.buildQueryString(result),
	}

	if data.url then table.insert(params, mw.uri.buildQueryString( {rft_id = data.url})) end
		
	local coinsData = table.concat(params, "&")
	return coinsData;
end


local function COinS(data, coinsFormat)
	if resources.abbrTitles[data.title] then
		-- full citation is elsewhere
		return false
	elseif (coinsFormat == "info:ofi/fmt:kev:mtx:book") and data.title and (#data.title > 0) then
		-- title is mandatory element for books
		return bookCOinS(data)
	elseif coinsFormat == "info:ofi/fmt:kev:mtx:journal" and data.journal and (#data.journal > 0) and (not data.published or (data.journal ~= data.published)) then
		-- journal title is mandatory element for journals
		return journalCOinS(data)
	elseif coinsFormat == "info:ofi/fmt:kev:mtx:journal" and data.published and (#data.published > 0) then
		return webCOinS(data)
	elseif coinsFormat == "info:ofi/fmt:kev:mtx:patent" and data.patent then
		return patentCOinS(data)
	elseif data.title and (#data.title > 0) then
		-- treat web or unrecognized citations as book
		return bookCOinS(data)
	else
		return false
	end
end

--[[
	Format edition (number or marc 250$a).
	Different for journal.
	Tests: Wikipedysta:Nux/test Cytuj wydanie
--]]
local function formatEdition(edition, journal)
  local prefix = false
  if not journal then
    prefix = true
    if string.find(edition, "[Ww]yd[a. ]") then
      prefix = false
    elseif string.find(edition, "[Ee]dition") then
      prefix = false
    end
  end
  return (prefix and "wyd. " or "") .. edition
end

--[[
	Main.
--]]
local function Cite(p, mode, appendText, firewall)
	-- debug helper
	if p.args[3] then mw.log(p.args[3]) end
	local customMode = mode

	-- try to determine type basing on passed parameters
	local coinsFormat = resources.COinS[mode]
	if not mode then
		mode, coinsFormat = determineMode(p)
	end
	
	local data = loadCitation(p, mode)
	if not data then
	 	local result = mw.html.create("span")
	 		:addClass("problemy")
			:attr("aria-hidden", "true")
			:attr("data-nosnippet", "")
			:attr("data-problemy", "Brak wyników w szablonie cytowania")
	 	if mw.title.getCurrentTitle().namespace == 0 then
	 		result:wikitext(categories.empty)
	 	end
	 	result:wikitext("&#8201;") -- thin space
	 	return tostring(result)
	end
	
	-- convert web page to book for old date
	if (mode == 4) and data.date and data.date.odn then
		local year = tonumber(data.date.odn)
		if year and (year < 1990) then
			mode = 2
		end
	end

	if data.missing then
		-- do not produce any COiNS info
		-- if some mandatory argument is missing
		coinsFormat = false
	end

	local builder = mw.html.create("cite")
	builder
		:addClass("citation")
		:addClass(resources.cite[mode] or nil)
		:addClass(access.class[data.accessKind])
		:attr("id", prepareOdnIdentifier(data))
		--:wikitext(access.render[data.accessKind], ' ')

	local needDot = false
	local nextAuthorGroup = false
	if data.title or data.patent then
		
		if data.chapter then
			local authors = data.editor and data.author or data.chapterauthor
			if authors then
				local list, etal = formatAuthors(authors, false, nextAuthorGroup, nil)
				builder:wikitext(list, ", ")
				nextAuthorGroup = true
			end
			
			local title = softNoWiki(data.chapter)

			if data.urlstatus == "ukryj" then
				if data.archivechapter and data.archive then
					builder:wikitext("[", escapeUrl(data.archive), " ''", title, "'']")
				else
					builder:wikitext("''", title, "''")
				end
			elseif data.chapterurl then
				builder:wikitext("[", escapeUrl(data.archivechapter and data.archive or data.chapterurl), " ''", title, "'']")
			elseif data.chapterlink then
				builder:wikitext("[[", data.chapterlink, "|''", title, "'']]")
			else
				builder:wikitext("''", title, "''")
			end
			
			if data.format then
				builder:wikitext(" &#x5B;", data.format, "&#x5D;")
			end

			builder:wikitext(", [w:] ")
		end

		local authors = false
		local editor = false
		if not data.chapter and data.author then
			authors = data.author
		else
			authors = data.editor or data.author
			editor = data.editor
		end
		if authors then
			local list, etal = formatAuthors(authors, not (editor or false), nextAuthorGroup, editor and " i inni red." or nil)
			builder:wikitext(list)
			nextAuthorGroup = true
			if editor and not etal and not authors.etal then
				builder:wikitext(" (red.)")
			end
			builder:wikitext(", ")
		end
		if customMode and data.authorextra then
			builder:wikitext(data.authorextra, ", ")
		end
		
		if resources.abbrTitles[data.title] then
			local title = resources.abbrTitles[data.title]
			builder:wikitext(title)
			needDot = not mw.ustring.match(title, "%.%]%]$")
				and not mw.ustring.match(title, "%.$")
		elseif data.title then
			local title = softNoWiki(data.title)
			if data.urlstatus == "ukryj" then
				if data.archiveurl and data.archive then
					builder:wikitext("[", escapeUrl(data.archive), " ''", title, "'']")
				else
					builder:wikitext("''", title, "''")
				end
			elseif data.url or data.archiveurl then
				builder:wikitext("[", escapeUrl(data.archiveurl and data.archive or data.url), " ''", title, "'']")
			elseif data.titlelink then
				builder:wikitext("[[", data.titlelink, "|''", title, "'']]")
			else
				builder:wikitext("''", title, "''")
			end
			if not data.chapter and data.format then
				builder:wikitext(" &#x5B;", data.format, "&#x5D;")
				needDot = true
			elseif not mw.ustring.match(plainText(title), "[%.,!?]$") then
				needDot = true
			end
	
			local showmediatype = data.mediatype and (#data.mediatype > 0)
			if showmediatype then
				builder:wikitext(" &#x5B;", data.mediatype, "&#x5D;")
				needDot = true
			end
		end

		if not editor and data.editor then
			local list, etal = formatAuthors(data.editor, false, true, " i inni red.")
			builder:wikitext(needDot and ", " or " ", list, (etal or data.editor.etal) and "" or " (red.)")
			needDot = true
		end
		
		if data.others then
			local list, etal = formatAuthors(data.others, true, true, nil)
			builder:wikitext(needDot and ", " or " ", data.patent and resources.patent.inventor.." " or "", list)
			needDot = true
		end

		if data.patent then
			local title = (not data.title and data.url) and string.format("[%s %s]", escapeUrl(data.url), data.patent.title) or data.patent.title
			builder:wikitext(needDot and ", " or " ", resources.patent[data.patent.application], " ", title)
			needDot = true
		end
	elseif data.journal and data.author then
		local list, etal = formatAuthors(data.author, false, false, nil)
		builder:wikitext(list, ", ")
	end

	if data.work then
		builder:wikitext((data.title or data.patent) and ", " or "", "[w:] ", data.work)
		needDot = true
	end
	-- web -> [online]
	if (mode == 4) and not data.mediatype then
		builder:wikitext(" [online]")
	end

	if data.journal and (not data.published or (data.journal ~= data.published)) then
		builder:wikitext((data.title or data.work) and ", " or "")
		local title = softNoWiki(data.journal)
		if data.urlstatus == "ukryj" then
			if data.archivejournal and data.archive then
				builder:wikitext("[", escapeUrl(data.archive), "  „", title, "”]")
			else
				builder:wikitext("„", title, "”")
			end
		elseif data.journalurl or data.archivejournal then
			builder:wikitext("[", escapeUrl(data.archivejournal and data.archive or data.journalurl), " „", title, "”]")
		elseif data.journallink then
			builder:wikitext("„[[", data.journallink, "|", title, "]]”")
		else
			builder:wikitext("„", title, "”")
		end
		needDot = true
	end

	if data.responsibility then
		builder:wikitext(", ", data.responsibility)
		needDot = true
	end

	if data.edition then
		builder:wikitext(", ", formatEdition(data.edition, data.journal))
		needDot = true
	end
	
	if data.volume then
		builder:wikitext(data.journal and ", " or ", t. ", data.volume)
		needDot = true
	end
	
	if data.journal and data.issue then
		builder:wikitext(" (", data.issue, ")")
		needDot = true
	end

	if data.description and (#data.description > 0) then
		builder:wikitext(", ", data.description)
		needDot = true
	end

	if data.published and not data.publisher then
		builder:wikitext(", ", data.published)
		needDot = true
	end

	local place = false
	if data.place then
		builder:wikitext(", ", data.place)
		needDot = true
		place = true
	end
	if data.publisher then
		builder:wikitext(place and ": " or ", ", data.publisher)
		needDot = true
		place = false
	end
	if data.date then
		local shortDate = data.journal and (data.doi or data.pmid or data.pmc)
		if data.date.bib and data.date.hint then
			builder:wikitext(place and " " or ", "):tag("span"):attr("title", data.date.hint):wikitext(data.date.bib)
		elseif data.date.bib  then
			builder:wikitext(place and " " or ", ", data.date.bib)
		elseif data.date.day and shortDate then
			builder:wikitext(place and " " or ", "):tag("span"):attr("title", tostring(data.date.day).." "..resources.months[data.date.month].d.." "..tostring(data.date.year)):wikitext(data.date.year)
		elseif data.date.month and shortDate then
			builder:wikitext(place and " " or ", "):tag("span"):attr("title", resources.months[data.date.month].m.." "..tostring(data.date.year)):wikitext(data.date.year)
		elseif data.date.day then
			builder:wikitext(", ", tostring(data.date.day), " ", resources.months[data.date.month].d, " ", tostring(data.date.year))
		elseif data.date.month then
			builder:wikitext(", ", resources.months[data.date.month].m, " ", tostring(data.date.year))
		else
			builder:wikitext(place and " " or ", ", data.date.year)
		end
		builder:wikitext(data.diferentiator or "")
		needDot = true
	end

	if not data.journal and (data.series or data.issue) then
		builder:wikitext(" (", data.series or "", (data.series and data.issue) and "; " or "", data.issue or "", ")")
		needDot = true
	elseif data.journal and data.series then
		builder:wikitext(" (", data.series, ")")
		needDot = true
	end
	
	if data.p and #data.p > 0 then
		local isNonStandardPageNumber = mw.ustring.match(data.p, "[^%s0-9,%-–]")
		builder:wikitext(isNonStandardPageNumber and ", " or ", s.\194\160", data.p)
		needDot = true
	end
	
	if data.doi then
		local separator = "&nbsp;"
		builder:addClass("doi"):wikitext(", [[DOI (identyfikator cyfrowy)|DOI]]:")
		local doiLink = first(resources.params.doi.link)
		for _, v in ipairs(data.doi) do
			builder:wikitext(separator, "[", doiLink, mw.uri.encode(v), " ", softNoWiki(v), "]")
			separator = ", "
		end
		needDot = true
	end
	
	if data.isbn then
		for i,v in ipairs(data.isbn) do
			builder:wikitext(", ")
			require("Moduł:ISBN").link(builder, v)
		end

		needDot = true
	end

	if data.lccn then
		builder:wikitext(", [[Biblioteka Kongresu|LCCN]] [", first(resources.params.lccn.link), mw.uri.encode(data.lccn), " ", data.lccn, "]")
		needDot = true
	end
	
	if data.issn then
		builder:tag("span"):addClass("issn"):wikitext(", [[International Standard Serial Number|ISSN]] [", first(resources.params.issn.link), data.issn, " ", data.issn, "]")
		needDot = true
	end
	
	if data.pmid then
		builder:addClass("pmid"):wikitext(", [[PMID]]:&nbsp;[", first(resources.params.pmid.link), data.pmid, " ", data.pmid, "]")
		needDot = true
	end
	
	if data.pmc then
		builder:addClass("pmc"):wikitext(", [[PMCID]]:&nbsp;[", first(resources.params.pmc.link), data.pmc, "/ PMC", data.pmc, "]")
		needDot = true
	end
	
	if data.bibcode then
		builder:wikitext(", [[Bibcode]]:&nbsp;[", first(resources.params.bibcode.link), data.bibcode, " ", data.bibcode, "]")
		needDot = true
	end
	
	if data.oclc then
		builder:wikitext(", [[Online Computer Library Center|OCLC]]&nbsp;[", first(resources.params.oclc.link), mw.uri.encode(data.oclc), " ", data.oclc, "]")
		needDot = true
	end
	
	if data.arxiv then
		builder:wikitext(", [[arXiv]]:")
		local eprint, class = mw.ustring.match(data.arxiv, "^(%S+)%s+%[([^%[%]]+)%]$")
		if eprint then
			builder:wikitext("[", first(resources.params.arxiv.link), eprint, " ", eprint, "] &#x5B;[//arxiv.org/archive/", class, " ", class, "]&#x5D;" )
		else
			builder:wikitext("[", first(resources.params.arxiv.link), data.arxiv, " ", data.arxiv, "]" )
		end
		needDot = true
	end
	
	if data.jstor then
		builder:tag("span"):addClass("jstor"):wikitext(", [[JSTOR]]:&nbsp;[", first(resources.params.jstor.link), data.jstor, " ", data.jstor, "]")
		needDot = true
	end
	
	if data.ol then
		builder:tag("span"):addClass("open-library"):wikitext(", [[Open Library|OL]]:&nbsp;[", first(resources.params.ol.link), data.ol, " ", data.ol, "]")
		needDot = true
	end
	
	if data.id then
		builder:wikitext(", ", data.id)
		needDot = true
	end
	
	if data.accessdate then
		builder:tag("span"):addClass("accessdate"):wikitext(" [dostęp ", string.format("%04d-%02d-%02d", data.accessdate.year, data.accessdate.month, data.accessdate.day), "]")
		needDot = true
	end
	
	if data.archive then
		builder:wikitext(" [zarchiwizowane")
		if data.urlstatus ~= "ukryj" then
			local url = data.archiveurl and data.url or (data.archivechapter and data.chapterurl or data.journalurl)
			if url then
				builder:wikitext(" z [", escapeUrl(url), " adresu]")
			end
		end
		if data.archived and data.archived.day then
			builder:wikitext(" ", string.format("%04d-%02d-%02d", data.archived.year, data.archived.month, data.archived.day))
		end
		builder:wikitext("]")
		needDot = true
	end
	
	if data.quotation then
		builder:wikitext(", Cytat: ", data.quotation)
		needDot = true
	end

	local coinsData = COinS(data, coinsFormat)
	if coinsData then
		builder:tag("span"):addClass("Z3988"):attr("title",coinsData):css("display","none"):wikitext("&nbsp;")
	end
	
	if data.lang then
		local languages = require("Moduł:Lang").lang({args = data.lang})
		builder:wikitext(" ", languages)
		needDot = true
	end
	
	if data.fullStop then
		if not mw.ustring.match(data.fullStop, "^[%.!?,;:]") then
			builder:wikitext(", ")
		end
		builder:wikitext(data.fullStop)
		needDot = mw.ustring.match(data.fullStop, "[%.!?,;:]$") == nil
	end

	if needDot then
		builder:wikitext(".")
	end

	if appendText then
		builder:wikitext(appendText)
	end
	
	-- categories
	local addCategories = mw.title.getCurrentTitle().namespace == 0
	local problems = {}
	if not customMode and (mode == 1) then
		builder:wikitext(categories.undetermined)
		table.insert(problems, "???")
	end
	if data.publisher and data.published then
		table.insert(problems, "p?")
		if addCategories then
			table.insert(problems, categories.unusedPublished)
		end
	end
	if data.journal and data.published and (data.journal == data.published) then
		table.insert(problems, "j?")
		if addCategories then
			table.insert(problems, categories.sameJournalAndPublished)
		end
	end
	
	if (not data.url and not data.chapterurl) or (not data.title and not data.journalurl) then
		builder:addClass(data.urlnowiki and "urlnowiki" or "nourl")
	end
	
	local missing = false
	local needurl = ((resources.params.published.used[mode] == "*") and data.published) or (resources.params.url.used[mode] == "*")
	if data.missing then
		-- usually missing title, this is the first check for mandatory arguments
		table.insert(problems, data.missing)
		missing = true
	elseif needurl and not data.url and not data.chapterurl and not data.arxiv and not data.archive then
		-- build in support for missing external link for page citation
		table.insert(problems, resources.params.url.name)
		missing = true
	else
		-- any other missing value (first catch)
		for k, v in pairs(resources.params) do
			if (v.used[mode] == "!") and (not data[k] or (#data[k] == 0)) then
				table.insert(problems, v.name)
				missing = true
				break
			end
		end
	end

	if missing and addCategories then
		builder:wikitext(string.format(categories.missingArg or categories.check, resources.modes[mode]))
	end
	if (data.chapterauthor and data.chapterauthor.comma)
	or (data.author and (data.author.comma == true))
	or (data.editor and data.editor.comma)
	or (data.others and data.others.comma) then
		table.insert(problems, "!!!")
		if addCategories then
			builder:wikitext(categories.suspectedComma)
		end
	end
	if data.author and (data.author.comma == "alt") then
		table.insert(problems, "a?")
		if addCategories then
			builder:wikitext(categories.altAuthor)
		end
	end
	if data.originalJournal then
		builder:addClass("c") -- CSS dla lokalizacji w treści
		if addCategories then
			builder:wikitext(categories.altJournal)
		end
	end
	
	local citewiki = (data.url and mw.ustring.match(data.url, "%.wikipedia%.org"))
		or (data.journal and mw.ustring.match(killLinkInterwiki(data.journal), "[Ww]ikipedia"))
		or (data.publisher and mw.ustring.match(killLinkInterwiki(data.publisher), "[Ww]ikipedia"))
		or (data.published and mw.ustring.match(killLinkInterwiki(data.published), "[Ww]ikipedia"))
	if citewiki then
		local justification = false
		local acceptedLinks = mw.loadData("Moduł:Cytuj/wiki")[mw.wikibase.getEntityIdForCurrentPage()] or {}
		for i, v in ipairs(acceptedLinks) do
			justification = (v == data.url) or (v == data.archive)
			if justification then
				break
			end
		end

		if not justification then
			table.insert(problems, "wiki?")
			if addCategories then
				builder:wikitext(categories.wiki)
			end
		end
	end
	if data.unknownAccess then
		table.insert(problems, "dostęp?")
		if addCategories then
			builder:wikitext(categories.unknownAccess)
		end
	end
	if data.rejectedurl then
		table.insert(problems, "<s>url</s>")
		if addCategories then
			builder:wikitext(categories.rejectedUrl)
		end
	end
	if data.urlWarning then
		table.insert(problems, "Url")
		if addCategories then
			builder:wikitext(categories.unusedUrl)
		end
	end
	if data.patchCitoidDate then
		table.insert(problems, "1 stycznia")
	end
	if data.badDate then
		table.insert(problems, "data?")
	end
	if data.badAccessDate then
		table.insert(problems, "data dostępu?")
	end
	if data.badArchivedDate then
		table.insert(problems, "zarchiwizowano?")
	end
	if addCategories and (data.badDate or data.badAccessDate or data.badArchiveDate) then
		builder:wikitext(categories.badDate)
	end
	if (data.author and data.author.etal)
	or (data.chapterauthor and data.chapterauthor.etal)
	or (data.editor and data.editor.etal)
	or (data.others and data.others.etal) then
		table.insert(problems, "i inni")
		if addCategories then
			builder:wikitext(categories.etal)
		end
	end
	if firewall then
		
		local reportFirewall = function(report)
			if report then
				table.insert(problems, report.info)
				if addCategories and report.cat then
					local cat = mw.ustring.format(categories.firewall, report.cat)
					builder:wikitext(cat)
				end
			end
		end
		
		local reportCommonsFile = function(ext)
			mw.logObject(ext, "ext")
			if ext and (firewall.commonsFile[ext] ~= false) then
				local issue = firewall.commonsFile[ext] or firewall.commonsFile[true]
				reportFirewall(firewall.reports[issue])
			end
		end
		
		if data.url and firewall.url[data.url] ~= false then
			local uri = mw.uri.new(data.url)
			local issue = firewall.url[data.url]
				or firewall.host[uri.host]
				or firewall.path[uri.relativePath]
			reportFirewall(firewall.reports[issue])
		end
		
		reportCommonsFile(data.chapterext)
		reportCommonsFile(data.titleext)
		reportCommonsFile(data.journalext)
	end

	if #problems > 0 then
		local info = builder:tag("span")
			:addClass("problemy")
			:addClass("problemy-w-cytuj")
			:attr("aria-hidden", "true")
			:attr("data-nosnippet", "")
		info:wikitext(table.concat(problems,", "))
	end
	
	return builder:done()
end

return {
	
auto = function(frame)
	return Cite(frame:getParent(), nil, nil, mw.loadData("Moduł:Cytuj/firewall"))
end,

custom = function(frame)
	local traceCategory = false
	local pagename = mw.title.getCurrentTitle()
	if (pagename.namespace == 10) and frame.getParent then
		local template = mw.title.new( frame:getParent():getTitle(), "Szablon" )
		if mw.title.compare(template, pagename) == 0 then
			traceCategory = categories.traceInvokeCustom
		end
	end
	
	local customMode = frame.args[1]
	local mode = 1
	if customMode then
		customMode = mw.text.trim(customMode)
		for i, v in ipairs(resources.modes) do
			if customMode == v then
				mode = i
				break
			end
		end
	end

	return Cite(frame, mode, traceCategory, null)
end,

}
