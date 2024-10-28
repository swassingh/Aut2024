version 13
cap program drop main
cap program drop provider_characteristics

program main
    global provider_characteristics_vars "provider_age provider_male provider_graduation provider_graduation_miss provider_degree_MD provider_degree_DO provider_degree_DPM provider_degree_NP provider_degree_PA provider_degree_CNM most_enc_ip_non_ed most_enc_op most_enc_ed scan_bpa_eligible_annualized scan_hc_annualized pat_table_age pat_table_male"
    provider_characteristics, variable(${provider_characteristics_vars}) matname(Table_1_Provider_Char)
    start_tables, mat(Table_1_Provider_Char) cellnum(C100) save_excel(../Output/cds_tables.xlsx)
end

program provider_characteristics
    syntax, variable(str) matname(str)
    mat drop _all
    use ../../CDS_Data/prov_all_stats_qp.dta, clear

    foreach v in `variable' {
        if inlist("`v'", "provider_age", "scan_bpa_eligible_annualized", "scan_hc_annualized", "provider_graduation", "pat_table_age", "pat_table_male") {
            sum `v' if treated == 1
            mat t`v' = r(mean), r(sd)
            sum `v' if control == 1
            mat c`v' = r(mean), r(sd)
            matrix `v'm = (t`v', c`v')
        }
        else {
            *Number and percent of treatment and control groups
            sum `v' if treated == 1
            mat t`v' = r(sum), r(mean)*100
            sum `v' if control == 1
            mat c`v' = r(sum), r(mean)*100
            matrix `v'm = (t`v', c`v')
        }

        *P-values
        reg `v' treated, r
        matrix pval = r(table)
        count if !mi(`v') & consent == 1
        local `v'n = r(N)
        mat `v'nmi = ``v'n'
        matrix `v'm = `v'm , pval[4 ,1], `v'nmi
        mat drop pval

        matrix `matname' = nullmat(`matname') \ `v'm
        di "`v'"
    }
    F_test, covs(`variable') grp(treated) iter(1000) samp(consent)
    mat F_p_value = (.,.,sim_stacked[1,3],J(1,3,.)) \ (.,.,sim_stacked[1,1],J(1,3,.))
    *mat F_p_value = J(2,6,.)

    foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }

    matrix `matname' = nullmat(`matname') \ (N, J(1,4,.)) \ F_p_value
end

main
