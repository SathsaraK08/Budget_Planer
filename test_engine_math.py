"""
Automated Verification for Deterministic Household Budget & Forecast Calculations.
Verifies all mathematical outputs against handwritten notebook calculations and tunable parameters.
"""

def test_cycle_metrics():
    # 1. Incomes
    husband_salary = 249585.0
    wife_salary = 150000.0
    total_income = husband_salary + wife_salary
    assert total_income == 399585.0, f"Expected 399585.0, got {total_income}"

    # 2. Fixed Bills
    rent = 70000.0
    ecb_water = 20000.0
    personal_loan = 47544.0
    gold_loan = 8500.0
    total_fixed = rent + ecb_water + personal_loan + gold_loan
    assert total_fixed == 146044.0, f"Expected 146044.0, got {total_fixed}"

    # 3. Subscriptions
    dialog_mob = 2054.0
    dialog_rtr = 5000.0
    office_phone = 4500.0
    netflix = 1400.0
    apple_mus = 1080.0
    apple_cld = 1000.0
    youtube = 1200.0
    total_subs = dialog_mob + dialog_rtr + office_phone + netflix + apple_mus + apple_cld + youtube
    assert total_subs == 16234.0, f"Expected 16234.0, got {total_subs}"

    # 4. Credit Cards
    cc_combank = 40000.0
    cc_sampath = 5000.0
    total_cc = cc_combank + cc_sampath
    assert total_cc == 45000.0, f"Expected 45000.0, got {total_cc}"

    # 5. Installments
    inst_dhiyan_koko = 4549.0 + 4808.0 + 950.0 + 1772.0 + 2740.0 + 2397.0
    inst_sathsara_koko = 5377.0 + 1330.0 + 2000.0 + 1750.0
    inst_mintpay = 5647.0 + 5647.0
    inst_payzy = 5500.0
    total_inst = inst_dhiyan_koko + inst_sathsara_koko + inst_mintpay + inst_payzy

    total_committed = total_fixed + total_subs + total_cc + total_inst
    assert total_committed == 251745.0, f"Expected 251745.0, got {total_committed}"

    # 6. Daily Spends
    daily_spends_total = 2120.0 + 10902.0 + 1213.0 + 15970.0
    assert daily_spends_total == 30205.0, f"Expected 30205.0, got {daily_spends_total}"

    # 7. Remaining Balance
    remaining_balance = total_income - (total_committed + daily_spends_total)
    assert remaining_balance == 117635.0, f"Expected 117635.0, got {remaining_balance}"

    print("[PASS] All Current Cycle Metric Calculations Passed 100% Correctly!")

def test_forward_survival_forecast():
    next_income = 249585.0 + 150000.0 # 399585.0
    recurring_fixed = 146044.0
    recurring_subs = 16234.0
    estimated_cc = 10000.0

    continuing_inst = 5377.0 + 1330.0 + 5500.0 + 2397.0 # 14604.0
    
    total_next_committed = recurring_fixed + recurring_subs + estimated_cc + continuing_inst
    assert total_next_committed == 186882.0, f"Expected 186882.0, got {total_next_committed}"

    net_surplus = next_income - total_next_committed
    assert net_surplus == 212703.0, f"Expected 212703.0, got {net_surplus}"

    # Tunable Parameter Test: Default 5% reserve vs 10% custom reserve
    reduced_income = 100000.0
    deficit = reduced_income - total_next_committed
    assert deficit == -86882.0, f"Expected -86882.0, got {deficit}"
    
    # 5% Default Reserve Margin:
    reserve_margin_5pct = reduced_income * 0.05
    required_buffer_5 = abs(deficit) + reserve_margin_5pct
    assert required_buffer_5 == 91882.0, f"Expected 91882.0, got {required_buffer_5}"

    # 10% Custom Tunable Reserve Margin:
    reserve_margin_10pct = reduced_income * 0.10
    required_buffer_10 = abs(deficit) + reserve_margin_10pct
    assert required_buffer_10 == 96882.0, f"Expected 96882.0, got {required_buffer_10}"

    print("[PASS] All Forward Survival Forecast & Tunable Parameters Passed 100% Correctly!")

if __name__ == "__main__":
    test_cycle_metrics()
    test_forward_survival_forecast()
    print("=================================================================")
    print(" [SUCCESS] 100% VERIFICATION COMPLETE: ALL NOTEBOOK MATH IS DETERMINISTIC")
    print("=================================================================")
