cap program drop main
cap program drop control_order_type

program main
    global control_order_type_vars "scan_mr scan_ct scan_pet scan_nm scan_hc scan_xr scan_us scan_mm scan_fl scan_bd scan_lowcost scan_other scan"
    control_order_type, variables(${control_order_type_vars}) matname(Table_S2_Control_Order_Type)
    start_tables, mat(Table_S2_Control_Order_Type) cellnum(C100) save_excel(../Output/cds_tables.xlsx)
end

program control_order_type
    syntax, variables(str) matname(str)
    use ../../CDS_Data/prov_all_stats_sp, clear
    keep if control == 1
    foreach v in `variables' {
        sum `v'
        mat `matname'= nullmat(`matname') \ r(sum)
    }
end

main
