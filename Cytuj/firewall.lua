return {
	
	url = {
		-- strony z serwisu filmpolski.pl zawierają property="og:url" z linkiem do strony głównej
		["https://www.filmpolski.pl/fp/index.php"] = "fp",
		["http://www.filmpolski.pl/fp/index.php"] = "fp",
		["//www.filmpolski.pl/fp/index.php"] = "fp",
		["https://filmpolski.pl/fp/index.php"] = "fp",
		["http://filmpolski.pl/fp/index.php"] = "fp",
		["//filmpolski.pl/fp/index.php"] = "fp",
	},
	
	host = {
		-- strony z serwisu fryderyki.pl zawierają property="og:url" z linkiem do fryderykfestiwal.pl
		["fryderykfestiwal.pl"] = "fryderyki",
		-- strony z commons mogą być przerobione na standardowy wikilink
		["commons.wikimedia.org"] = "commons",
	},
	
	path = {
		-- wszelkie strony główne serwisów na cenzurowanym
		[""] = "sg",
		["/"] = "sg",
		["/index"] = "sg",
		["/index.htm"] = "sg",
		["/index.html"] = "sg",
		["/index.php"] = "sg",
	},

	commonsFile = {
		["pdf"] = false,
		[true] = "plik",
	},

	reports = {
		["sg"] = {
			info = "strona główna serwisu",
			cat = "strona główna",
		},
		["fp"] = {
			info = "strona główna serwisu Film Polski",
			cat = "Film Polski"
		},
		["fryderyki"] = {
			info = "sprawdź czy link nie powinien prowadzić do serwisu fryderyki.pl",
			cat = "fryderykfestiwal.pl",
		},
		["commons"] = {
			info = "link zewnętrzny do Commons",
			cat = "commons",
		},
		["plik"] = {
			info = "plik z Commons jako źródło",
			cat = "plik z commons",
		},
	}	
}
