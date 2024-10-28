cap program drop main
cap program drop sensitivity_analysis
cap program drop spec_OLS
cap program drop spec_NB
cap program drop spec_QP
cap program drop attrition
cap matrix drop N

program main
    global controls "prov_age_*_q provider_male_q provider_graduation_q provider_degree_MD_q provider_degree_DO_q provider_degree_DPM_q provider_degree_PA_q provider_degree_NP_q provider_degree_CNM_q provider_specialty_gen_med_q provider_specialty_specialist_q provider_specialty_student_q provider_specialty_nurse_q provider_specialty_assistant_q most_enc_ip_non_ed_q most_enc_op_q most_enc_ed_q"
    global miss_controls "provider_age_miss_q provider_male_miss_q provider_graduation_miss_q"

    use ../../CDS_Data/prov_all_stats_sp, clear
    sensitivity_analysis, matname(Table_S6_Sensitivity_Analysis)
    matrix Table_S6_Sensitivity_Analysis = OLS \ NB \ QP \ performed_scans \ old_logic \ attrition \ OLS_cluster \ OLS_fe \ (N,J(1,6,.))
    start_tables, mat(Table_S6_Sensitivity_Analysis) cellnum(C100) save_excel(../Output/cds_tables.xlsx)
end

    program sensitivity_analysis
        spec_OLS, var(scan_bpa_new) matname(OLS) 
        spec_NB, var(scan_bpa_new) matname(NB)
        spec_QP, var(scan_bpa_new) matname(QP)
        performed_scans, var(scan_bpa_new_performed) matname(performed_scans)
        old_logic, var(scan_bpa_old) matname(old_logic)
        attrition, var(scan_bpa_new) matname(attrition)
		spec_cluster, var(scan_bpa_new) matname(OLS_cluster)
		spec_fe, var(scan_bpa_new) matname(OLS_fe)

    end

program spec_OLS
    syntax, var(str) matname(str)

    cap mat drop `matname'
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)
        
        qui reg `v' treated `v'_q, r
        mat temp_lg = r(table)
        mat `v'_mat = t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]

        qui reg `v' treated, r
        mat temp = r(table)
        mat `v'_mat = `v'_mat \ (t_mat, c_mat, temp[1,1], temp[5,1], temp[6,1], temp[4,1])

        qui reg `v' treated `v'_q ${controls} ${miss_controls}, r
        mat temp_fc = r(table)
        mat `v'_mat = `v'_mat \ (t_mat, c_mat, temp_fc[1,1], temp_fc[5,1], temp_fc[6,1], temp_fc[4,1])

        mat `matname' = nullmat(`matname'), `v'_mat
        mat drop t_mat c_mat `v'_mat
    }

    foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }
end

program spec_NB
    syntax, var(str) matname(str)
	preserve
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_`v'_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_`v'_mat = r(mean), r(sd)
    }

    foreach v in `var' {
        replace `v'_q = ln(`v'_q)
    }
    
    cap mat drop `matname'
    foreach v in `var' {
        qui nbreg `v' treated `v'_q, iterate(10000)

        margins, dydx(treated)
        mat temp_lg = r(table)

        mat `matname' = nullmat(`matname'), t_`v'_mat, c_`v'_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]
        mat drop t_`v'_mat c_`v'_mat
    }
	restore
end

program spec_QP
    syntax, var(str) matname(str)
    
	preserve
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_`v'_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_`v'_mat = r(mean), r(sd)
    }

    foreach v in `var' {
        replace `v'_q = ln(`v'_q)
    }
    
    cap mat drop `matname'
    foreach v in `var' {
        qui poisson `v' treated `v'_q, vce(robust) iterate(10000)
        
        margins, dydx(treated)
        mat temp_lg = r(table)

        mat `matname' = nullmat(`matname'), t_`v'_mat, c_`v'_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]
        mat drop t_`v'_mat c_`v'_mat
    }
	restore
end

program performed_scans
    syntax, var(str) matname(str)
   
	preserve
    cap mat drop `matname'
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)

        qui reg `v' treated `v'_q, r
        mat temp_lg = r(table)

        mat `matname' = nullmat(`matname'), t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]
        mat drop t_mat c_mat
    }
	restore
end

program old_logic
    syntax, var(str) matname(str)
    preserve
    cap mat drop `matname'
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)
        
        qui reg `v' treated `v'_q, r
        mat temp_lg = r(table)

        mat `matname' = nullmat(`matname'), t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]
        mat drop t_mat c_mat
    }
	restore
end

program attrition
    syntax, var(str) matname(str)
	preserve
    assert quit_qtr > 4 if Iquit_sp == 0 & Iquit_qp == 0
    drop if Iquit_sp == 1 | Iquit_qp == 1
    
    cap mat drop `matname'
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)
        
        qui reg `v' treated `v'_q, r
        mat temp_lg = r(table)

        mat `matname' = nullmat(`matname'), t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]
        mat drop t_mat c_mat
    }
	restore
end

program spec_cluster
    syntax, var(str) matname(str)
	cap matrix drop N
    
    cap mat drop `matname'
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)
        
        qui reg `v' treated `v'_q, r cluster(primary_location_id)
        mat temp_lg = r(table)
        mat `v'_mat = t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]

        mat `matname' = nullmat(`matname'), `v'_mat
        mat drop t_mat c_mat `v'_mat
    }

    foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }
end

program spec_fe
    syntax, var(str) matname(str)
	cap matrix drop N
    cap mat drop `matname'
    foreach v in `var' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)
        
        qui reg `v' treated `v'_q i.primary_location_id, r cluster(primary_location_id)
        mat temp_lg = r(table)
        mat `v'_mat = t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1]

        mat `matname' = nullmat(`matname'), `v'_mat
        mat drop t_mat c_mat `v'_mat
    }

    foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }
end

main
