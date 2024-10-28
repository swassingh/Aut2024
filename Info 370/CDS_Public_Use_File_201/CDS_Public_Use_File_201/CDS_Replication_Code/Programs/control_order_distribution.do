cap program drop main
cap program drop control_order_dist

program main
    global control_order_dist_vars "scan_bpa_new scan_bpa_new_ct scan_bpa_new_mr scan_bpa_new_1_3 scan_bpa_new_4_6 scan_hc scan_lowcost"
    control_order_dist, variables(${control_order_dist_vars}) matname(Table_S1_Control_Order_Dist)
    start_tables, mat(Table_S1_Control_Order_Dist) cellnum(C100) save_excel(../Output/cds_tables.xlsx)
end

program control_order_dist
    syntax, variables(str) matname(str)
    use ../../CDS_Data/prov_all_stats_sp, clear
    keep if control == 1
    foreach v in `variables' {
        assert !mi(`v')
        sum `v', de
        mat mean_sd = r(mean), r(sd)
        mat pctle = r(p25), r(p50), r(p75), r(p90), r(p95), r(p99)
        assert r(N) == 1756
        count if `v' == 0
        local frac_0 = r(N)/1756
        matrix `matname' = nullmat(`matname') \  (mean_sd, `frac_0', pctle) \ J(1,9,.)
    }
end

main
