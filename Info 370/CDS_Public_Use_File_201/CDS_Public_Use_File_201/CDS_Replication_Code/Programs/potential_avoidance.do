cap program drop main
cap program drop handoffs_and_encounters
cap matrix drop N

program main
    global handoff_vars "handoff_strategic_all handoff_strategic_not_rand handoff_strategic_con"
    global encounter_vars "encounter encounter_ip_non_ed encounter_op encounter_ed"

    use ../../CDS_Data/prov_all_stats_sp, clear
    handoffs_and_encounters, variables(${handoff_vars}) matname(handoffs)
    handoffs_and_encounters, variables(${encounter_vars}) matname(encounters)


    foreach group in treated control {
        count if `group' == 1
        matrix N = nullmat(N), r(N)
    }
	
    local n = colsof(handoffs)
    matrix Table_S7_Potential_Avoidance = handoffs \ J(2,`n',.) \ encounters \ (N,J(1,6,.))
    start_tables, mat(Table_S7_Potential_Avoidance) cellnum(C101) save_excel(../Output/cds_tables.xlsx)
end

program handoffs_and_encounters
    syntax, variables(str) matname(str)

    cap mat drop `matname'
    foreach v in `variables' {
        sum `v' if treated == 1
        mat t_mat = r(mean), r(sd)

        sum `v' if control == 1
        mat c_mat = r(mean), r(sd)

        reg `v' treated `v'_q, r
        mat temp_lg = r(table)

        mat `matname' = nullmat(`matname') \ (t_mat, c_mat, temp_lg[1,1], temp_lg[5,1], temp_lg[6,1], temp_lg[4,1])

        mat drop t_mat c_mat
    }
end

main
