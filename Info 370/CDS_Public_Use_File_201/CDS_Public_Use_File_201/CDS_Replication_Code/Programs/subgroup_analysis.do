cap program drop main
cap program drop calc_percentile
cap program drop calc_TE
cap program drop overtime
cap program drop order_location
cap matrix drop N

program main
    matrix A = J(1,1,.)
    use ../../CDS_Data/prov_all_stats_sp, clear

    *Clean data
    keep if consent == 1
    drop provider_degree_CNM_q provider_degree_DPM_q
    order provider_degree_DO_q provider_degree_NP_q provider_degree_PA_q provider_degree_oth, after(provider_degree_MD_q)

    *Quartiles of targeted scans ordered in the quiet period
    calc_percentile, var(scan_bpa_new_q) nq(4)
    calc_TE, variable(scan_bpa_new) subgroup(ple_scan_bpa_new_q) mat(heterogeneity)

    *Targeted scans ordered within each quarter
    overtime, matname(overtime)

    *TE per scan order location
    order_location, matname(order_location) variables(scan_order_enc_loc_hosp scan_order_enc_loc_op scan_order_enc_loc_ed scan_order_enc_loc_oth)

    *TE by provider type
    calc_TE, variable(scan_bpa_new) subgroup(provider_degree) mat(provider_type) dummy

    *TE by provider age
    calc_TE, variable(scan_bpa_new) subgroup(prov_age_med) mat(prov_age_med) dummy
	
	foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }


    local n = colsof(heterogeneity)
    matrix Table_3_Subgroup_Analysis = heterogeneity \ J(2,`n',.) \ overtime \ J(2,`n',.) \ order_location \ J(2,`n',.) \ provider_type \ J(2,`n',.) \ prov_age_med \ (N, J(1,7,.))

    start_tables, mat(Table_3_Subgroup_Analysis) cellnum(C100) save_excel(../Output/cds_tables.xlsx)
end

    program calc_percentile
        syntax, var(str) nq(integer)

        cap drop ple* //for debugging
        _pctile `var', nq(`nq')
        local end = `nq' - 1
        forval i = 1/`end' {
            local p`i' = r(r`i')
            di "`p`i''"
            mat Cple_`var'= nullmat(Cple_`var') \ (`p`i'') 
        }
        mat Cple_`var'= nullmat(Cple_`var') \ . 
        gen ple_`var' = .
        if `p1' == 0 {
            replace ple_`var' = 1 if (`var' == `p1')
            count if (`var' < `p2') & (`var' > 0)
            if r(N) == 0 {
                replace ple_`var' = 2 if (`var' < `p2') ///
                    & (`var' >= 0)
                local last_row = `nq'*2
                matselrc Cple_`var' Cple_`var', r(3/`last_row')
            }
            else {
                replace ple_`var' = 2 if (`var' < `p2') ///
                    & (`var' > 0)
            }
        }
        else {
            replace ple_`var' = 1 if (`var' >= 0) & (`var' < `p1')
            replace ple_`var' = 2 if (`var' < `p2') ///
                & (`var' >= `p1')
        }
        forval i = 3/`end' {
            local j = `i' - 1
            if `p`j'' != `p`i'' {
                replace ple_`var'= `i' if (`var' < `p`i'') ///
                & (`var' >= `p`j'')
                di "Below `p`i'', equal to or above `p`j''"
            }
            else {
                replace ple_`var' = `j' if (`var' == `p`i'')
                di "Equal to `p`i''"
            }
        }
        replace ple_`var' = `nq' if (`var' >= `p`end'') & !mi(`var')
        assert !mi(ple_`var') if !mi(`var') & (`var' != -9999)
        assert mi(ple_`var') if mi(`var') | (`var' == -9999)

        gen mple_`var' = .
        levelsof ple_`var', loc(subgroup_levels)
        foreach l in `subgroup_levels' {
            di "Level: `l'"
            sum `var' if ple_`var' == `l'
            replace mple_`var' = r(mean) if ple_`var' == `l'
        }
        tab ple_`var' mple_`var', mi
    end

    program calc_TE
        syntax, variable(str) subgroup(str) mat(str) [DUMMY]
        if "`dummy'" != "" {
            foreach var of varlist *`subgroup'* {
                local level_list `level_list' `var'
                mat C`subgroup' = nullmat(C`subgroup') \ .
                count if `var' == 1 & control == 1
                mat N`var' = nullmat(N`var'), r(N)
                count if `var' == 1 & treated == 1
                mat N`var'= nullmat(N`var'), r(N)
                count if `var'== 1
                mat N`var' = nullmat(N`var'), r(N)
                mat N`subgroup' = nullmat(N`subgroup') \ N`var'
                mat drop N`var'
            }
        }
        else {
            levelsof `subgroup', loc(level_list)
            foreach l in `level_list' {
                di `l'
                local level_names `level_names' `subgroup'`l'
                count if `subgroup' == `l' & control == 1
                mat N`l' = nullmat(N`l'), r(N)
                count if `subgroup' == `l' & treated == 1
                mat N`l' = nullmat(N`l'), r(N)
                count if `subgroup' == `l'
                mat N`l' = nullmat(N`l'), r(N)
                mat N`subgroup' = nullmat(N`subgroup') \ N`l'
                mat drop N`l'
            }
        }
        di "Level list: `level_list'"
        di "Level names: `level_names'"
        mat li C`subgroup'
        mat li N`subgroup'

        foreach v in `variable' {
            foreach sg in `level_list' {
                if "`dummy'" != "" {
                    sum `v' if treated == 1 & `sg' == 1
                    mat t_mat = r(mean), r(sd)

                    sum `v' if control == 1 & `sg' == 1
                    mat c_mat = r(mean),  r(sd)

                    reg `v' treated `v'_q if `sg' == 1, r
                    mat temp_lg = r(table)
                    mat reg_mat = temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1], temp_lg[2,1]
                }
                else {
                    sum `v' if treated == 1 & `subgroup' == `sg'
                    mat t_mat = r(mean), r(sd)

                    sum `v' if control == 1 & `subgroup' == `sg'
                    mat c_mat = r(mean),  r(sd)

                    reg `v' treated `v'_q if `subgroup' == `sg', r
                    mat temp_lg = r(table)
                    mat reg_mat = temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1], temp_lg[2,1]
                }
                mat `v' = nullmat(`v') \ (t_mat, c_mat, reg_mat) 
                mat drop c_mat reg_mat 
            }
            mat `mat' = nullmat(`mat'), `v'
            mat drop `v'
        }
end

program overtime
    syntax, matname(str)
    forval q = 1/4 {
        sum scan_bpa_new`q' if treated == 1
        mat t_mat = r(mean), r(sd)
	
        sum scan_bpa_new`q' if control == 1
        mat c_mat = r(mean), r(sd)

        reg scan_bpa_new`q' treated scan_bpa_new_q, r
        mat temp_lg = r(table)
        mat reg_mat = temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1], temp_lg[2,1]

        mat `matname'`q' = t_mat, c_mat, reg_mat
        mat li `matname'`q'
      
        mat `matname' = nullmat(`matname') \ `matname'`q'
    }
end

program order_location
    syntax, matname(str) variables(str)
    cap mat drop c_mat reg_mat n_mat `matname'
    foreach v in `variables' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)

        reg `v' treated `v'_q, r
        mat temp_lg = r(table)
        mat reg_mat = temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1], temp_lg[2,1]

        mat `matname' = nullmat(`matname') \ (t_mat, c_mat, reg_mat) 
    }
end


main
