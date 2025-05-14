return {
	choice = {
		["otwarty"] = "open",
		["o"] = "open",
		["zamknięty"] = "closed",
		["z"] = "closed",
		["rejestracja"] = "registration",
		["r"] = "registration",
		["częściowy"] = "limited",
		["c"] = "limited",
		
	},
	class = {
		open = "open-access",
		closed = "closed-access",
		registration = "registered-access",
		limited = "limited-access",
	},
	render = {
		closed = "[[Plik:Closed Access logo alternative.svg|8px|link=|Publikacja w płatnym dostępie – wymagana płatna rejestracja lub wykupienie subskrypcji]] ",
		open = "[[Plik:Open Access logo green alt2.svg|8px|link=otwarty dostęp|Publikacja w otwartym dostępie – możesz ją bezpłatnie przeczytać]] ",
		registration = "[[Plik:Lock-blue-alt-2.svg|8px|link=|Publikacja dostępna po bezpłatnej rejestracji]] ",
		limited = "[[Plik:Lock-blue-alt-2.svg|8px|link=|Publikacja dostępna w ograniczonym zakresie (np. w wersji próbnej lub dla określonej liczby wyświetleń)]] ",
	},

	doi = {
		["3998"] = "open", -- Arkivoc
		["3762"] = "open", -- Beilstein Journal of Organic Chemistry
		["1186"] = "open", -- BMC Biology
		["1248"] = "open", -- Chem Pharm Bull, Biol Pharm Bull, Pharm Bull, Yakugaku Zasshi 
		["5194"] ="open", -- Earth System Science Data
		["1289"] ="open", -- Environmental Health Perspectives
		["3390"] = "open", -- MDPI
		["15227"] = "open", -- Organic Syntheses
		["1371"] = "open", -- PLOS Biology
		["14708"] = "open", -- Polskie Towarzystwo Matematyczne
		["12740"] = "open", -- Psychiatria Polska
	},

	journals = {
		["Acta Palaeontologica Polonica"] = "open",
		["Analytical Sciences"] = "open",
		["arXiv"] = "open",
		["Arkivoc"] = "open",
		["Beilstein Journal of Organic Chemistry"] = "open",
		["Biological and Pharmaceutical Bulletin"] = "open",
		["bioRxiv"] = "open",
		["BMC Biology"] = "open",
		["Chemical and Pharmaceutical Bulletin"] = "open",
		["ChemRxiv"] = "open",
		["Dzieje Najnowsze"] = "open",
		["Dziennik Ustaw Rzeczypospolitej Polskiej"] = "open",
		["Earth System Science Data"] = "open",
		["Environmental Health Perspectives"] = "open", 
		["Genes"] = "open",
		["Guardian"] = "open",
		["Journal of Biological Chemistry"] = "open",
		["Kosmos"] = "open",
		["medRxiv"] = "open",
		["Molecules"] = "open",
		["Monitor Polski"] = "open",
		["Nauka"] = "open",
		["Nucleic Acids Research"] = "open",
		["Organic Syntheses"] = "open",
		["Pharmaceutical Bulletin"] = "open",
		["PLOS Biology"] = "open",
		["PLoS Biology"] = "open",
		["Pomeranian Journal of Life Sciences"] = "open",
		["Psychiatria Polska"] = "open",
		["Scientific Reports"] = "open",
		["The Guardian"] = "open",
		["Yakugaku Zasshi"] = "open",
	},
}
