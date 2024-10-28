program stackedreg
		syntax, covs(str) grp(str) [controls(str) miss(str)]	
        set matsize 10000
        
		cap matrix drop stacked
		save temp.dta, replace
	
		gen id = _n
		local numtest : word count `covs' 
		
		* Expanding dataset for stacked regressions
		qui compress
		qui expand `numtest'
		bys id: gen order = _n
		gen outcome = .		

		* Creating variables for stacked regressions
		local i = 0
		gen constant = 1

		foreach var of local covs {
			local i = `i'+1
			replace outcome = `var' if (order == `i')
			gen Itreat_`i' = (`grp')*(order == `i') 
			gen constant_`i' = constant*(order == `i') 
			if "`controls'" !="" {
				foreach cont in `controls' `miss' {
					gen genC`i'`cont' = `cont'*(order==`i')
					local gen_controls_str = `" `gen_controls_str' genC`i'`cont' "' //"correct syntax highlighting
					}
				}
			else {
				local gen_controls_str ""
				}

		}	
		
		* Running stacked regressions and f-tests
		reg outcome Itreat_* constant_* `gen_controls_str', ///
			cluster(id) nocons
			* for check
			local i = 0
			foreach var of local covs {
				local i = `i'+1
				local `var'sb = round(_b[Itreat_`i'],0.001)
			}
		
		testparm Itreat_*
		
		matrix stacked = (r(F) , r(p), r(df_r), r(df))
		matrix colnames stacked = "f" "p" "df_r" "df"
		
		cap matrix drop stacked_beta 
		local i = 0
		local rowname = ""
		foreach var of local covs {
			local i = `i'+1
			qui reg `var' `grp' `control_`i'' if order == `i'
			matrix results=r(table)
			local `var'db = round(results[1,1],0.001)
			di "`var': simple reg: ``var'db', stacked: ``var'sb'"
			assert round(``var'db',0.01) == round(``var'sb',0.01)
			
			sum `var' if `grp' == 0 & order == `i'
			local mean_control = r(mean)
			sum `var' if `grp' == 1 & order == `i'
			local mean_treat = r(mean)
			matrix stacked_beta = (nullmat(stacked_beta)\(`mean_control', `mean_treat', (abs(min(-1*results[4,1],0)))))
			local rowname = "`rowname' `var'"
		}
		matrix rownames stacked_beta = `rowname'
		matrix colnames stacked_beta = "control" "treat" "p"
		
		di "Covariates: `covs'"
		di "Missing: `miss'"
		di "Controls: `controls'"
		matrix list stacked
		use temp.dta,clear
end
	