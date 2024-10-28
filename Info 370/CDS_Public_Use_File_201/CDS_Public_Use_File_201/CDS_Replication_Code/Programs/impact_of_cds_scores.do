cap program drop main
cap program drop impact_of_cds_scores
cap matrix drop N

program main
    global impact_of_cds_scores_vars "scan_hc scan_scored_cds scan_scored_imp scan_unscored_all scan_unscored_handoff_worker scan_unscored_custom_ind scan_unscored_ind_nonc scan_unscored_ind_onc scan_unscored_rlst scan_unscored_fltr scan_unscored_medi scan_unscored_smartset scan_unscored_sys scan_unscored_external scan_unscored_other"
    impact_of_cds_scores, variables(${impact_of_cds_scores_vars}) matname(Table_S5_Impact_of_CDS_Scores)
    start_tables, mat(Table_S5_Impact_of_CDS_Scores) cellnum(C101) save_excel(../Output/cds_tables.xlsx)
end

program impact_of_cds_scores
    syntax, variables(str) matname(str)
    cap mat drop c_mat t_mat reg_mat `matname'
    use ../../CDS_Data/prov_all_stats_sp, clear
    foreach v in `variables' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)
		
        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)

        reg `v' treated `v'_q, r
        mat temp_lg = r(table)
        mat reg_mat = temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]
        
        mat `matname' = nullmat(`matname') \ (t_mat, c_mat, reg_mat) 
    }
	
	foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }

    mat `matname' = `matname' \ (N,J(1,6,.))
end

main
