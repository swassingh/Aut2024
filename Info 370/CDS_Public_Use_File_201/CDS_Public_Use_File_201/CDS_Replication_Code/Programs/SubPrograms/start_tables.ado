program start_tables
		syntax, mat(str) save_excel(str) [cellnum(str)]
		foreach tab in `mat' {
			matrix list `tab'
			matrix_to_txt, saving(../Output/`tab'.txt) replace mat(`tab') ///
							format(%20.6f) title(<tab:`tab'>)
			insheet using ../Output/`tab'.txt, double clear
			if "`cellnum'" != "" {
				export excel _all using "`save_excel'", firstrow(var) cell(`cellnum') sheetmodify sheet(`tab')
			}
			else {
				export excel _all using "`save_excel'", firstrow(var) cell(C100) sheetmodify sheet(`tab')
			}
		}
end
