cap program drop main
cap program drop impact_of_cds_scans
cap matrix drop N

program main
    global impact_of_cds_scans_vars "scan_bpa_new scan_bpa_new_ct scan_bpa_new_mr scan_bpa_new_1_3 scan_bpa_new_4_6 scan_hc scan_lowcost"
    impact_of_cds_scans, variables(${impact_of_cds_scans_vars}) matname(Table_2_Impact_of_CDS_Scans)
    start_tables, mat(Table_2_Impact_of_CDS_Scans) cellnum(C100) save_excel(../Output/cds_tables.xlsx)
end

program impact_of_cds_scans
    syntax, variables(str) matname(str)
    cap mat drop c_mat t_mat reg_mat n_mat `matname'
    foreach v in `variables' {
        use ../../CDS_Data/prov_all_stats_sp, clear
        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)
		sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        reg `v' treated `v'_q, r
        mat temp_lg = r(table)
        mat reg_mat = temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1], temp_lg[2,1]

        mat `matname' = nullmat(`matname') \ (t_mat, c_mat, reg_mat)
    }
    foreach group in treated control {
        count if `group' == 1
        matrix n_mat = nullmat(n_mat), r(N)
    }

    mat `matname' = `matname' \ (n_mat,J(1,7,.))

end

main
