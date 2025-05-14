return {
	modes = { "auto", "książkę", "pismo", "stronę", "patent" },
	
	cite = { false, "book", "journal", "web", "patent" },
	
	COinS = {
		false,                          -- auto
		"info:ofi/fmt:kev:mtx:book",    -- książkę
		"info:ofi/fmt:kev:mtx:journal", -- pismo
		"info:ofi/fmt:kev:mtx:journal", -- stronę
		"info:ofi/fmt:kev:mtx:patent",  -- patent
	},

	categories = {
		check = "[[Kategoria:Szablon cytuj do sprawdzenia]]", -- domyślna kategoria problemów
		
		-- dla wyczyszczonych wywołań do sprzątania na bieżąco używaj domyślnej
		-- empty = "[[Kategoria:Szablon cytowania bez parametrów]]", 
		-- suspectedComma = "[[Kategoria:Szablon cytowania zawiera przecinek w polu z opisem autora]]",
		-- unusedUrl = "[[Kategoria:Szablon cytowania zawiera nieużywany URL]]",
		-- sameJournalAndPublished = "[[Kategoria:Szablon cytowania zawiera identyczne pola 'czasopismo' i 'opublikowany']]",
		-- rejectedUrl = "[[Kategoria:Szablon cytowania odrzucił URL]]",
		-- unknownAccess = "[[Kategoria:Szablon cytowania zawiera nieznany dostęp]]",
		-- badDate = "[[Kategoria:Szablon cytowania zawiera nieprawidłowy zapis daty]]",
		-- unusedPublished = "[[Kategoria:Szablon cytowania zawiera pola 'opublikowany' i 'wydawca']]",
		-- missingArg = "[[Kategoria:Szablon cytowania w trybie 'cytuj %s' bez obowiązkowych parametrów]]",

		undetermined = "[[Kategoria:Szablon cytowania bez określonego trybu]]",
		altAuthor = "[[Kategoria:Szablon cytowania zastosował alternatywną metodę analizy pola z opisem autora]]",
		altJournal = "[[Kategoria:Szablon cytowania zamienił nazwę czasopisma]]",
		wiki = "[[Kategoria:Szablon cytowania wskazuje na Wikipedię]]",
		etal = "[[Kategoria:Szablon cytowania nie zawiera wszystkich autorów]]",
		firewall = "[[Kategoria:Szablony cytowania – problemy – cytuj – %s]]",
		
		traceInvokeCustom = "[[Kategoria:Szablony cytowania bazujące na uniwersalnym]]",
	},
	
	--[[
	; name : name of the parameter used in the template
	; used : indicator whether the parameter is used in specific citation mode
		list of modes is declared in variable 'modes' at the top of the module
		the first entry is reserved for automatic full citation mode, which accepts all parameters
		; "!" : mandatory
		; false : not used
		; ''otherwise'' : optional
			; "+" : only in one mode, and written differently for easier notice
			; "*" : additional support in the code (in url and published for now)
	--]]
	params = {
		chapterauthor = {
			name = "autor r",
			used = { true, "+", false, false, false, },
		},
		chapter = {
			name = "rozdział",
			used = { true, "+", false, false, false, },
		},
		author = {
			name = "autor",
			used = { true, true, true, true, true, },
		},
		authorextra = {
			name = "autor-dodatek",
			used = { true, false, false, false, false, },
		},
		editor = {
			name = "redaktor",
			used = { true, true, true, true, false, },
		},
		url = {
			name = "url",
			used = { true, true, true, "*", true, },
		},
		urlstatus = {
			name = "url-status",
			used = { true, true, true, true, true },
		},
		title = {
			name = "tytuł",
			used = { true, "!", true, "!", true, },
		},
		patent = {
			name = "patent",
			used = { true, false, false, false, "+" },
		},
		format = {
			name = "format",
			used = { true, true, false, true, false, },
		},
		others = {
			name = "inni",
			used = { true, "+", false, false, true, },
		},
		work = {
			name = "praca",
			used = { true, false, false, "+", false, },
		},
		journal = {
			name = "czasopismo",
			used = { true, false, "!", false, false, },
		},
		mediatype = {
			name = "typ nośnika",
			used = { true, true, true, true, true, },
		},
		responsibility = {
			name = "odpowiedzialność",
			used = { true, false, "+", false, false, },
		},
		edition = {
			name = "wydanie",
			used = { true, true, true, false, false, },
		},
		volume = {
			name = "wolumin",
			used = { true, true, true, false, false, },
		},
		issue = {
			name = "numer",
			used = { true, false, "+", false, false, },
		},
		series = {
			name = "seria",
			used = { true, true, false, true, false, },
		},
		description = {
			name = "opis",
			used = { true, true, true, true, true, },
		},
		place = {
			name = "miejsce",
			used = { true, true, true, false, false, },
		},
		published = {
			name = "opublikowany",
			used = { true, "*", "*", "*", false, },
		},
		publisher = {
			name = "wydawca",
			used = { true, true, true, false, false, },
		},
		date = {
			name = "data",
			used = { true, true, true, true, true, },
		},
		p = {
			name = "s",
			used = { true, true, true, true, true, },
		},
		doi = {
			name = "doi",
			used = { true, true, true, false, true, },
			link = { "//dx.doi.org/", "//doi.org/", },
		},
		isbn = {
			name = "isbn",
			used = { true, "+", false, false, false, },
		},
		lccn = {
			name = "lccn",
			used = { true, "+", false, false, false, },
			link = "http://lccn.loc.gov/",
		},
		issn = {
			name = "issn",
			used = { true, true, true, false, false, },
			link = "http://worldcat.org/issn/",
		},
		pmid = {
			name = "pmid",
			used = { true, false, "+", false, false, },
			link = "http://www.ncbi.nlm.nih.gov/pubmed/",
		},
		pmc = {
			name = "pmc",
			used = { true, false, "+", false, false, },
			link = "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC",
		},
		bibcode = {
			name = "bibcode",
			used = { true, true, true, false, false, },
			link = "http://adsabs.harvard.edu/abs/",
		},
		oclc = {
			name = "oclc",
			used = { true, true, true, false, false, },
			link = { "http://worldcat.org/oclc/", "//www.worldcat.org/oclc/" },
		},
		arxiv = {
			name = "arxiv",
			used = { true, false, true, false, false, },
			link = "//arxiv.org/abs/",
		},
		jstor = {
			name = "jstor",
			used = { true, true, true, false, false, },
			link = { "//www.jstor.org/stable/", "http://www.jstor.org/stable/", "https://www.jstor.org/stable/" },
		},
		ol = {
			name = "ol",
			used = { true, true, false, false, false, },
			link = "https://openlibrary.org/works/OL",
		},
		id = {
			name = "id",
			used = { true, true, true, true, true, },
		},
		accessdate= {
			name = "data dostępu",
			used = { true, true, true, true, true, },
		},
		archive = {
			name = "archiwum",
			used = { true, true, true, true, true, },
		},
		archived = {
			name = "zarchiwizowano",
			used = { true, true, true, true, true, },
		},
		quotation = {
			name = "cytat",
			used = { true, true, true, true, true, },
		},
		lang = {
			name = "język",
			used = { true, true, true, true, true, },
		},
		odn = {
			name = "odn",
			used = { true, true, true, true, true, },
		},
		accessKind = {
			name = "dostęp",
			used = { true, true, true, true, true, },
		},
		fullStop = {
			name = "kropka",
			used = { true, true, true, true, true, },
		}
	},

	monthparser = {
		["styczeń"] = 1,      ["stycznia"] = 1,      ["sty"] = 1,  ["i"] = 1,
		["luty"] = 2,         ["lutego"] = 2,        ["lut"] = 2,  ["ii"] = 2,
		["marzec"] = 3,       ["marca"] = 3,         ["mar"] = 3,  ["iii"] = 3,
		["kwiecień"] = 4,     ["kwietnia"] = 4,      ["kwi"] = 4,  ["iv"] = 4,
		["maj"] = 5,          ["maja"] = 5,                        ["v"] = 5,
		["czerwiec"] = 6,     ["czerwca"] = 6,       ["cze"] = 6,  ["vi"] = 6,
		["lipiec"] = 7,       ["lipca"] = 7,         ["lip"] = 7,  ["vii"] = 7,
		["sierpień"] = 8,     ["sierpnia"] = 8,      ["sie"] = 8,  ["viii"] = 8,
		["wrzesień"] = 9,     ["września"] = 9,      ["wrz"] = 9,  ["ix"] = 9,
		["październik"] = 10, ["października"] = 10, ["paź"] = 10, ["x"] = 10,
		["listopad"] = 11,    ["listopada"] = 11,    ["lis"] = 11, ["xi"] = 11,
		["grudzień"] = 12,    ["grudnia"] = 12,      ["gru"] = 12, ["xii"] = 12,
	},

	months = {
		[1]  = { m="styczeń",     d="stycznia", },
		[2]  = { m="luty",        d="lutego", },
		[3]  = { m="marzec",      d="marca", },
		[4]  = { m="kwiecień",    d="kwietnia", },
		[5]  = { m="maj",         d="maja", },
		[6]  = { m="czerwiec",    d="czerwca", },
		[7]  = { m="lipiec",      d="lipca", },
		[8]  = { m="sierpień",    d="sierpnia", },
		[9]  = { m="wrzesień",    d="września", },
		[10] = { m="październik", d="października", },
		[11] = { m="listopad",    d="listopada", },
		[12] = { m="grudzień",    d="grudnia", },
	},
	
	exactAuthors = {
		["Praca zbiorowa"] = true,
		["praca zbiorowa"] = true,
		["[[Gall Anonim]]"] = true,
	},
	
	lastnamePrefixes = {
		["de"] = true,
		["d'"] = true,
		["d’"] = true,
		["van"] = true,
		["de "] = false,
		["von "] = true,
		["der "] = false,
		["van "] = false,
		["van der "] = false,
	},
	
	js = {
		{ ",? [Jj]r%.?$", "jr." },
		{ ",? [Ss]r%.?$", "sr." },
		{ ",? II$", "II" },
		{ ",? III$", "III" },
		{ ",? IV$", "IV" },
	},

	authorFunc = {
		{
			append = " (red. nauk.)",
			prefixes = { "red%. nauk%. ?", "redaktor naukowy", },
			suffixes = { "[%(%[]red%.? nauk%.?[%)%]]", "[%(%[]redaktor naukowy[%)%]]", },
		},
		{
			append = " (red.)",
			prefixes = { "red%.?", "redaktor", "pod red%.?", "pod redakcją", },
			suffixes = { "[%(%[]red%.?[%)%]]", "[%(%[]redaktor[%)%]]", },
		},
		{
			append = " (tłum.)",
			prefixes = { "tł%.?", "tłum%.?", "tłumacz", },
			suffixes = { "[%(%[]tłum%.?[%)%]]", "[%(%[]tłumacz[%)%]]", },
		},
		{
			append = " (ilustr.)",
			prefixes = { "il%.?", "ilus%.?", "ilustr%.?",  "ilustrator" },
			suffixes = { "[%(%[]il%.?[%)%]]", "[%(%[]ilus%.?[%)%]]", "[%(%[]ilustr%.?[%)%]]", "[%(%[]ilustrator[%)%]]", },
		},
		{
			append = " (oprac.)",
			prefixes = { "oprac%.?", "opracowała?", },
			suffixes = { "[%(%[]oprac%.?[%)%]]", "[%(%[]opracowała?[%)%]]", },
		},
		{
			append = " (reż.)",
			prefixes = { "reż%.?", "reżyser", },
			suffixes = { "[%(%[]reż%.?[%)%]]", "[%(%[]reżyser[%)%]]", },
		},
		{
			append = " (scen.)",
			prefixes = { "scen%.?", "scenariusz", "scenarzysta", },
			suffixes = { "[%(%[]scen%.?[%)%]]", "[%(%[]scenariusz[%)%]]", "[%(%[]scenarzysta[%)%]]", },
		},
		{
			append = " (muz.)",
			prefixes = { "muz%.?", "muzyka", "kompozytor", },
			suffixes = { "[%(%[]muz%.?[%)%]]", "[%(%[]muzyka[%)%]]", "[%(%[]kompozytor[%)%]]", },
		},
		{
			append = " (wyd.)",
			prefixes = { "wyd%.?", "wydawca" },
			suffixes = { "[%(%[]wyd%.?[%)%]]", "[%(%[]wydawca[%)%]]" },
		},
	},

	bibDates = {
		{
			hint  = false, -- zwykła data roczna
			show  = "%1",
			coins = "%1",
			odn   = "%1",
			patterns = {
				"^([12][0-9][0-9][0-9])$", -- data = 1954
			},
		},
		{
			hint  = "brak daty wydania",
			show  = "[b.r.]",
			coins = false,
			odn   = false,
			patterns = {
				"^b%.r%.$",     -- data = b.r.
				"^%[b%.r%.%]$", -- data = [b.r.]
				"^s%.a%.$",     -- data = s.a.
				"^%[s%.a%.%]$", -- data = [s.a.]
				"^n%.d%.$",     -- data = n.d.
				"^%[n%.d%.%]$", -- data = [n.d.]
			},
		},
		{
			hint  = "rok dystrybucji",
			show  = "[dystr. %1]",
			coins = "%1",
			odn   = "%1",
			patterns = {
				"^%[dystr%.?% ([12][0-9][0-9][0-9])%]$", -- data = [dystr. 1954]
				"^dystr%.? ([12][0-9][0-9][0-9])$",     -- data = dystr. 1954
				"^%[dystr%.?%] ([12][0-9][0-9][0-9])$", -- data = [dystr.] 1954
			},
		},
		{
			hint  = "rok copyright",
			show  = "[cop. %1]",
			coins = "%1",
			odn   = "%1",
			patterns = {
				"^%[cop.?% ([12][0-9][0-9][0-9])%]$", -- data = [cop. 1954]
				"^cop%.? ([12][0-9][0-9][0-9])$",     -- data = cop. 1954
				"^%[cop%.? ([12][0-9][0-9][0-9])%]$", -- data = [cop.] 1954
			},
		},
		{
			hint  = "data druku",
			show  = "[dr. %1]",
			coins = "%1",
			odn   = "%1",
			patterns = {
				"^%[dr.?% ([12][0-9][0-9][0-9])%]$", -- data = [dr. 1954]
				"^dr%.? ([12][0-9][0-9][0-9])$",     -- data = dr. 1954
				"^%[dr%.? ([12][0-9][0-9][0-9])%]$", -- data = [dr.] 1954
			},
		},
		{
			hint  = "data ustalona na podstawie informacji spoza dokumentu",
			show  = "[%1]",
			coins = "%1",
			odn   = "%1",
			patterns = {
				"^%[([12][0-9][0-9][0-9])%]$", -- data = [1954]
			},
		},
		{
			hint  = "rok przybliżony",
			show  = "[ok. %1]",
			coins = "%1",
			odn   = "%1",
			patterns = {
				"^%[ok%.? ([12][0-9][0-9][0-9])%]$", -- data = [ok. 1954]
				"^ok%.? ([12][0-9][0-9][0-9])$",     -- data = ok. 1954
				"^c%.? ([12][0-9][0-9][0-9])$",      -- data = c. 1954
			},
		},
		{
			hint  = "rok przypuszczalny",
			show  = "[%1?]",
			coins = "%1?",
			odn   = "%1",
			patterns = {
				"^%[([12][0-9][0-9][0-9])%?%]$", -- data = [1954?]
				"^([12][0-9][0-9][0-9])%?$",     -- data = 1954?
			},
		},
		{
			hint  = "ustalone dziesięciolecie",
			show  = "[%1–]",
			coins = "%1-",
			odn   = false,
			patterns = {
				"^%[([12][0-9][0-9])[%-–—]%]$",   -- data = [195-]
			},
		},
		{
			hint  = "przypuszczalne dziesięciolecie",
			show  = "[%1–?]",
			coins = "%1-?",
			odn   = false,
			patterns = {
				"^%[([12][0-9][0-9])[%-–—]%?%]$", -- data = [195-?]
			},
		},
		{
			hint  = false, -- dzieło wielotomowe ukazujące się przez kilka lat
			show  = "%1–%2",
			coins = false,
			odn   = "%1",
			patterns = {
				"^([12]%d%d%d)[%-–—]([12]%d%d%d)$", -- data = 1832-1836
			},
		},
		{
			hint  = "wielotomowe dzieło w trakcie wydawania",
			show  = "%1–",
			coins = false,
			odn   = "%1",
			patterns = {
				"^([12]%d%d%d)[%-–—]$", -- data = 2011-
			},
		},
		{
			hint  = false, -- data sezonowa
			show  = "%1 %2",
			coins = "%2",
			odn   = "%2",
			patterns = {
				"^([Ww]iosna) ([12][0-9][0-9][0-9])$",
				"^([Ll]ato) ([12][0-9][0-9][0-9])$",
				"^([Jj]esień) ([12][0-9][0-9][0-9])$",
				"^([Zz]ima) ([12][0-9][0-9][0-9])$",
			},
		},
		{
			hint  = false, -- wczesne lata naszej ery
			show  = "%1 n.e.",
			coins = false,
			odn   = "%1",
			patterns = {
				"^([1-9]%d?%d?) n%.e%.$",
			},
		},
		{
			hint  = false, -- daty przed naszą erą
			show  = "%1 p.n.e.",
			coins = false,
			odn   = "%1 p.n.e.",
			patterns = {
				"^([1-9]%d?%d?%d?) p%.n%.e%.$",
			},
		},
	},

	etalPatterns = {
		"(.-)( +et +al%.?)$",
		"(.-)( +i +inni)$",
		"(.-)( +i +in%.?)$",
	},

	abbrTitles = {
		["Op. cit."] = "[[Op. cit.|Dz. cyt.]]",
		["op. cit."] = "[[Op. cit.|dz. cyt.]]",
		["Op.cit."] = "[[Op. cit.|Dz. cyt.]]",
		["op.cit."] = "[[Op. cit.|dz. cyt.]]",
		["Dz. cyt."] = "[[Op. cit.|Dz. cyt.]]",
		["dz. cyt."] = "[[Op. cit.|dz. cyt.]]",
		["Dz.cyt."] = "[[Op. cit.|Dz. cyt.]]",
		["dz.cyt."] = "[[Op. cit.|dz. cyt.]]",
		["Ibidem"] = "[[Ibidem|Tamże]]",
		["ibidem"] = "[[Ibidem|tamże]]",
		["Ibid."] = "[[Ibidem|Tamże]]",
		["ibid."] = "[[Ibidem|tamże]]",
		["Ibid"] = "[[Ibidem|Tamże]]",
		["ibid"] = "[[Ibidem|tamże]]",
		["Tamże"] = "[[Ibidem|Tamże]]",
		["tamże"] = "[[Ibidem|tamże]]",
	},
	
	htmlEntities = {
		["&amp;"] = 38,
		["&lt;"] = 60,
		["&gt;"] = 62,
		["&nbsp;"] = 160,
		["&shy;"] = 173,
		["&minus;"] = 8722,
		["&ensp;"] = 8194,
		["&emsp;"] = 8195,
		["&thinsp;"] = 8201,
		["&zwnj;"] = 8204,
		["&zwj;"] = 8205,
		["&lrm;"] = 8206,
		["&rlm;"] = 8207,
		["&ndash;"] = 8211,
		["&mdash;"] = 8212,
	},

	patent = {
		[false] = "patent",
		[true] = "zgłoszenie patentowe",
		inventor = "wynalazca:",
	},

	supportedUriSchemas = {
		-- most used
		'http://', 'https://',  '//',
		
		-- possible
		'bitcoin:', 'ftp://', 'ftps://', 'geo:', 'git://', 'gopher://', 
		'irc://', 'ircs://', 'magnet:', 'mailto:', 'mms://', 'news:',
		'nntp://', 'redis://', 'sftp://', 'sip:', 'sips:', 'sms:', 'ssh://',
		'svn://', 'tel:', 'telnet://', 'urn:', 'worldwind://', 'xmpp:',
	},

	wikilinks = {
		-- uppercase file prefix
		files = {
			["FILE"] = true,
			["PLIK"] = true,
			["IMAGE"] = true,
			["GRAFIKA"] = true,
		},

		-- lowercase file extension
		extensions = {
			-- image
			["svg"] = true,
			["png"] = true,
			["jpg"] = true,
			["jpeg"] = true,
			["gif"] = true,
			["tiff"] = true,
			["webp"] = true,
			["xcf"] = true,
			-- audio
			["mp3"] = true,
			["mid"] = true,
			["xcf"] = true,
			["ogg"] = true,
			["oga"] = true,
			["webm"] = true,
			["flac"] = true,
			["wav"] = true,
			-- video
			["ogv"] = true,
			["webm"] = true,
			["mpg"] = true,
			["mpeg"] = true,
			-- text
			["djvu"] = true,
			["pdf"] = true,
		},
	},

	archiveDecoders = {
		hosts = {
			-- host -> service
			["web.archive.org"] = "archive.org",
			["webarchive.nationalarchives.gov.uk"] = "nationalarchives.gov.uk",
			["archive.today"] = "archive.today",
			["archive.is"] = "archive.is",
			["archive.vn"] = "archive.is",
			["archive.ph"] = "archive.is",
			["archive.li"] = "archive.is",
			["archive.fo"] = "archive.is",
			["archive.md"] = "archive.is",
		},
	
		decoders = {
			ymdl = { year = 1, month = 2, day = 3, link = 4, },
		},
		
		services = {
			["archive.org"] = {
				{ pattern="^/web/(%d%d%d%d)(%d%d)(%d%d)%d%d%d%d%d%d/(https?://.*)$", decoder="ymdl" },
			},
			["nationalarchives.gov.uk"] = {
				{ pattern="^/(%d%d%d%d)(%d%d)(%d%d)%d%d%d%d%d%d/(https?://.*)$", decoder="ymdl" },
			},
			["archive.today"] = {
				{ pattern="^/(%d%d%d%d)(%d%d)(%d%d)%d%d%d%d%d%d/(https?://.*)$", decoder="ymdl" },
				{ pattern="^/(%d%d%d%d)(%d%d)(%d%d)/(https?://.*)$", decoder="ymdl" },
				{ pattern="^/(%d%d%d%d)%.(%d%d)%.(%d%d)%-%d%d%d%d%d%d/(https?://.*)$", decoder="ymdl" },
			},
			["archive.is"] = {
				{ pattern="^/(%d%d%d%d)(%d%d)(%d%d)%d%d%d%d%d%d/(https?://.*)$", decoder="ymdl" },
				{ pattern="^/(%d%d%d%d)%.(%d%d)%.(%d%d)%-%d%d%d%d%d%d/(https?://.*)$", decoder="ymdl" },
			},
		},
	},
}
