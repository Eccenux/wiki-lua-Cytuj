return {
	{
		-- uniwersalny
		pattern = "^(%u%u) +(%S+)$",
		application = false,
		country = "%1",
		number = "%2",
		url = "https://worldwide.espacenet.com/textdoc?DB=EPODOC&IDX=%1%2",
	},
	{
		-- uniwersalne zgłoszenie
		pattern = "^zgłoszenie +(%u%u) +(%S+)$",
		application = true,
		country = "%1",
		number = "%2",
		url = "https://worldwide.espacenet.com/textdoc?DB=EPODOC&IDX=%1%2",
	},
	-- bez spacji przez Google
	{
		pattern = "^(%u%u)(%d%S*)$",
		application = false,
		country = "%1",
		number = "%2",
		url = "https://patents.google.com/patent/%1%2",
	},
	{
		pattern = "^zgłoszenie (%u%u)(%d%S*)$",
		application = true,
		country = "%1",
		number = "%2",
		url = "https://patents.google.com/patent/%1%2",
	},
	{
		pattern = "^US(D%d%S*)$",
		application = false,
		country = "US",
		number = "%1",
		url = "https://patents.google.com/patent/US%1",
	},
	-- amerykański urząd patentowy?
	{
		pattern = "^USPTO (%S+)$",
		application = false,
		country = "US",
		number = "%1",
		url = "http://patft.uspto.gov/netacgi/nph-Parser?patentnumber=%1",
	},
	{
		pattern = "^zgłoszenie USPTO (%S+)$",
		application = true,
		country = "US",
		number = "%1",
		url = "http://patft.uspto.gov/netacgi/nph-Parser?patentnumber=%1",
	},

	ccinfo =
	{
		EP = "patent europejski",
		
		US = "patent amerykański",
		CA = "patent kanadyjski",
		PL = "patent polski",
		JA = "patent japoński",
	}
}
