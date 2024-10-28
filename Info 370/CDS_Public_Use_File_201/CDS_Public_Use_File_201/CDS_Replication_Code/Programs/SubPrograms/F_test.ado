program F_test
    syntax, covs(str) grp(str) [iter(str) samp(str) controls(str) miss(str)]
    
    save orig.dta, replace
    cap drop if `samp' != 1


    cap matrix drop sim_stacked
    cap matrix drop sim_mat
    set more off

    timer on 1
    stackedreg, covs(`covs') grp(`grp') controls(`controls') miss(`miss')
    timer off 1
    timer list 1

    local orig_f = stacked[1,1]
    local orig_p = stacked[1,2]

    keep `grp' `covs' `controls' `miss'
    save study.dta, replace

    qui count if `grp' ==1
    local treat = r(N)

    local it = 1500
    cap local it = `iter'
    local mat = `it'+1
    di "matsize: `mat'"
    set matsize 10000
    *simulation
    set seed 12345
    forval i = 1/`it' {
        use study.dta, clear
        gen simulated_r = runiform()
        sort simulated_r
        gen simulated_treat = (_n<=`treat')
        qui stackedreg, covs(`covs') grp(simulated_treat) controls(`controls')
        matrix sim_mat = nullmat(sim_mat) \ (stacked)
        drop simulated_treat simulated_r
    }
    matrix colnames sim_mat = "f" "p" "df" "hyp"

    *summarize matrix
    clear
    svmat sim_mat, names(col)
    qui sum f 
    matrix sim_stacked= (r(mean), r(sd))
    qui sum p
    matrix sim_stacked = (sim_stacked, r(mean))
    qui sum df
    matrix sim_stacked = (sim_stacked, r(mean))
    qui sum hyp
    matrix sim_stacked = (sim_stacked, r(mean))
    gen pval = (f >`orig_f')
    qui sum pval
    local p = r(mean)
    matrix sim_stacked = (`p', `orig_p', `orig_f', sim_stacked)
    matrix colnames sim_stacked = "sim_pvalue" "orig_pval" "orig_fstat" ///
        "mn_fstat" "mn_fstat_sd" "mn_fstat_p" "df_r" "df"
    matrix list sim_stacked

    *save sim data
    foreach var in `covs' {
        local covariates = `"`covariates'_`var'"' //"correct syntax hilighting
        }
    di "Covariates: `covariates'"
    save sim_stacked.dta, replace

    *load original dataset
    use orig.dta, clear
     
    *remove datasets
    rm temp.dta //from stacked_reg.ado
    rm orig.dta 
    rm study.dta 
    rm sim_stacked.dta 
	local covs ""
	local grp ""
	local samp ""
	local controls ""
	local miss ""
end
