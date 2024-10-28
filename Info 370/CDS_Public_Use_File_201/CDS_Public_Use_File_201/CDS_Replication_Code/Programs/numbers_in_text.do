version 13
cap program drop main
cap program drop shut_off_and_performed indication_gaming_test

program main
    shut_off_and_performed
    indication_gaming_test
end

program shut_off_and_performed
    use ../../CDS_Data/prov_all_stats_sp, clear
    keep if control == 1

    foreach var in scan_hc scan_bpa_shut_off scan_performed scan {
        sum `var'
        local num_`var' = r(sum)
    }

    local perc_shut_off = (`num_scan_bpa_shut_off' / `num_scan_hc') * 100
    local perc_shut_off = round(`perc_shut_off', 0.01)
    di "% of control group study period HC scans scored 1-9 for which BPA was shut off: `perc_shut_off'"

    local perc_not_performed = ((`num_scan' - `num_scan_performed') / `num_scan') * 100
    local perc_not_performed = round(`perc_not_performed', 0.01)
    di "% of orders by control providers that don't result in a scan performed: `perc_not_performed'"
end

program indication_gaming_test
    use ../../CDS_Data/prov_ind_gaming_sp, clear
    global share_ind "sh_ind_abd_pain sh_ind_stroke sh_ind_lower_back sh_ind_ams sh_ind_mild_head sh_ind_lung_less_1 sh_ind_short_breath sh_ind_post_trauma sh_ind_dizziness sh_ind_abd_rlq sh_ind_flank_stone sh_ind_tobacco sh_ind_hematuria sh_ind_mod_head sh_ind_shoulder_rotator sh_ind_kidney_stone sh_ind_cspine_low sh_ind_neck_pain sh_ind_head_new sh_ind_chest_pain sh_ind_lung_geq_1 sh_ind_cspine_high sh_ind_confusion sh_ind_head_norm sh_ind_shoulder_pers sh_ind_head_thund sh_ind_el_ddimer sh_ind_sinusitis sh_ind_radiculopathy sh_ind_knee_pain sh_ind_other"
    F_test, covs(${share_ind}) grp(treated) iter(1000) samp(consent)
    mat results = sim_stacked
    local F_stat = round(`=results[1,3]', 0.01)
    local p_value = round(`=results[1,1]', 0.01)
    di "The F-statistic for the indication gaming test is `F_stat', the empirical p-value is `p_value'"
end

main
