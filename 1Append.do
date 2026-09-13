********************************************************************************
*********************************** Data Append ********************************
********************************************************************************

version 17.0
clear all
set more off

** Working directory: raw Excel files, table_assign_2024.xlsx, and all outputs
local analysis_dir "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/REStat - with NICK POWDTHAVEE/2024 Project/Cleaning and Analysis/New analysis"
cap cd `"`analysis_dir'"'
if _rc {
    display as error "Could not change directory to:"
    display as error `"`analysis_dir'"'
    display as error "No files were created."
    exit 170
}

capture which ztree2stata
if _rc {
    display as error "The user-written command ztree2stata is not installed."
    display as error "Install it before running this replication script."
    exit 199
}

** import subjects dataset and merge
*1a
ztree2stata subjects using 240902_1219.xls, clear
gen Session = "1a"
tempfile temp1a
save `temp1a'

*1b
ztree2stata subjects using 240902_1357.xls, clear
gen Session = "1b"
tempfile temp1b
save `temp1b'

*1c
ztree2stata subjects using 240902_1537-2.xls, clear
gen Session = "1c"
tempfile temp1c
save `temp1c'

*2a
ztree2stata subjects using 240904_0918.xls, clear
gen Session = "2a"
tempfile temp2a
save `temp2a'


*2b
ztree2stata subjects using 240904_1031.xls, clear
gen Session = "2b"
tempfile temp2b
save `temp2b'

*2c
ztree2stata subjects using 240904_1225.xls, clear
gen Session = "2c"
tempfile temp2c
save `temp2c'

*2d
ztree2stata subjects using 240904_1346.xls, clear
gen Session = "2d"
tempfile temp2d
save `temp2d'

*2e
ztree2stata subjects using 240904_1601.xls, clear
gen Session = "2e"
tempfile temp2e
save `temp2e'

*2f
ztree2stata subjects using 240904_1703.xls, clear
gen Session = "2f"
tempfile temp2f
save `temp2f'

*3a
ztree2stata subjects using 240905_0853.xls, clear
gen Session = "3a"
tempfile temp3a
save `temp3a'

*3b
ztree2stata subjects using 240905_1029.xls, clear
gen Session = "3b"
tempfile temp3b
save `temp3b'

*3c
ztree2stata subjects using 240905_1221.xls, clear
gen Session = "3c"
tempfile temp3c
save `temp3c'

*3d
ztree2stata subjects using 240905_1357.xls, clear
gen Session = "3d"
tempfile temp3d
save `temp3d'

*3e
ztree2stata subjects using 240905_1531.xls, clear
gen Session = "3e"
tempfile temp3e
save `temp3e'

*3f
ztree2stata subjects using 240905_1648.xls, clear
gen Session = "3f"
tempfile temp3f
save `temp3f'

*4a
ztree2stata subjects using 240906_0859.xls, clear
gen Session = "4a"
tempfile temp4a
save `temp4a'

*4b
ztree2stata subjects using 240906_1023.xls, clear
gen Session = "4b"
tempfile temp4b
save `temp4b'

*4c
ztree2stata subjects using 240906_1218.xls, clear
gen Session = "4c"
tempfile temp4c
save `temp4c'

*4d
ztree2stata subjects using 240906_1345.xls, clear
gen Session = "4d"
tempfile temp4d
save `temp4d'

*4e
ztree2stata subjects using 240906_1519.xls, clear
gen Session = "4e"
tempfile temp4e
save `temp4e'

*4f
ztree2stata subjects using 240906_1657.xls, clear
gen Session = "4f"
tempfile temp4f
save `temp4f'

// second wave. In the experimental recruiment, we use 1a, 1b... 2a, 2b.. but for distinguish from the first wave, we replace them by 5a.. 6a and so on
*5a
ztree2stata subjects using 241009_1048.xls, clear
gen Session = "5a"
tempfile temp5a
save `temp5a'

*5b
ztree2stata subjects using 241009_1227.xls, clear
gen Session = "5b"
tempfile temp5b
save `temp5b'

*5c
ztree2stata subjects using 241009_1415.xls, clear
gen Session = "5c"
tempfile temp5c
save `temp5c'

*5d
ztree2stata subjects using 241009_1533.xls, clear
gen Session = "5d"
tempfile temp5d
save `temp5d'

*5e
ztree2stata subjects using 241009_1710.xls, clear
gen Session = "5e"
tempfile temp5e
save `temp5e'

*6a
ztree2stata subjects using 241010_1121.xls, clear
gen Session = "6a"
tempfile temp6a
save `temp6a'

*6b
ztree2stata subjects using 241010_1252.xls, clear
gen Session = "6b"
tempfile temp6b
save `temp6b'

*6c
ztree2stata subjects using 241010_1406.xls, clear
gen Session = "6c"
tempfile temp6c
save `temp6c'

*6d
ztree2stata subjects using 241010_1522.xls, clear
gen Session = "6d"
tempfile temp6d
save `temp6d'

*6e
ztree2stata subjects using 241010_1700.xls, clear
gen Session = "6e"
tempfile temp6e
save `temp6e'

*7a
ztree2stata subjects using 241011_1048.xls, clear
gen Session = "7a"
tempfile temp7a
save `temp7a'

*7b
ztree2stata subjects using 241011_1226.xls, clear
gen Session = "7b"
tempfile temp7b
save `temp7b'

*7c
ztree2stata subjects using 241011_1340.xls, clear
gen Session = "7c"
tempfile temp7c
save `temp7c'

*7d
ztree2stata subjects using 241011_1524.xls, clear
gen Session = "7d"
tempfile temp7d
save `temp7d'


// third wave. In the experimental recruiment, we use a, b, c, and d as we only conduct one day experiment. but for distinguish from the first two waves, we replace them by 8a, 8b, 8c, and 8d here.


*8a
ztree2stata subjects using 241104_1023.xls, clear
gen Session = "8a"
tempfile temp8a
save `temp8a'

*8b
ztree2stata subjects using 241104_1213.xls, clear
gen Session = "8b"
tempfile temp8b
save `temp8b'

*8c
ztree2stata subjects using 241104_1414.xls, clear
gen Session = "8c"
tempfile temp8c
save `temp8c'

*8d
ztree2stata subjects using 241104_1617.xls, clear
gen Session = "8d"
tempfile temp8d
save `temp8d'



** append subjects datasets
use `temp1a', clear
append using `temp1b' `temp1c' `temp2a' `temp2b' `temp2c' `temp2d' `temp2e' `temp2f' `temp3a' `temp3b' `temp3c' `temp3d' `temp3e' `temp3f'  `temp4a' `temp4b' `temp4c' `temp4d' `temp4e' `temp4f' `temp5a' `temp5b' `temp5c' `temp5d' `temp5e' `temp6a' `temp6b' `temp6c' `temp6d' `temp6e' `temp7a' `temp7b' `temp7c' `temp7d'  `temp8a'  `temp8b' `temp8c' `temp8d'

isid Session Subject Period
assert inrange(Period,1,5)

* Construct endowments without relying on a nonexistent Period 0 observation.
generate double Endowment_beforeR1 = 300
forvalues i = 1/5 {
    bysort Session Subject: egen double Endowment_afterR`i' = ///
        max(cond(Period==`i',Endowment,.))
    assert !missing(Endowment_afterR`i')

    if `i' > 1 {
        local previous = `i'-1
        bysort Session Subject: egen double Endowment_beforeR`i' = ///
            max(cond(Period==`previous',Endowment,.))
        assert !missing(Endowment_beforeR`i')
        assert Endowment_beforeR`i' == Endowment_afterR`previous'
    }
}

keep if Period == 5
isid Session Subject

keep Subject Session Endowment_afterR* Endowment_beforeR* A1-IUS12
save PostQ.dta, replace

** import clients dataset and merge
*1a
ztree2stata clients using 240902_1219.xls, clear
gen Session = "1a"
tempfile temp1a
save `temp1a'

*1b
ztree2stata clients using 240902_1357.xls, clear
gen Session = "1b"
tempfile temp1b
save `temp1b'

*1c
ztree2stata clients using 240902_1537-2.xls, clear
gen Session = "1c"
tempfile temp1c
save `temp1c'

*2a
ztree2stata clients using 240904_0918.xls, clear
gen Session = "2a"
tempfile temp2a
save `temp2a'


*2b
ztree2stata clients using 240904_1031.xls, clear
gen Session = "2b"
tempfile temp2b
save `temp2b'

*2c
ztree2stata clients using 240904_1225.xls, clear
gen Session = "2c"
tempfile temp2c
save `temp2c'

*2d
ztree2stata clients using 240904_1346.xls, clear
gen Session = "2d"
tempfile temp2d
save `temp2d'

*2e
ztree2stata clients using 240904_1601.xls, clear
gen Session = "2e"
tempfile temp2e
save `temp2e'

*2f
ztree2stata clients using 240904_1703.xls, clear
gen Session = "2f"
tempfile temp2f
save `temp2f'

*3a
ztree2stata clients using 240905_0853.xls, clear
gen Session = "3a"
tempfile temp3a
save `temp3a'

*3b
ztree2stata clients using 240905_1029.xls, clear
gen Session = "3b"
tempfile temp3b
save `temp3b'


*3c
ztree2stata clients using 240905_1221.xls, clear
gen Session = "3c"
tempfile temp3c
save `temp3c'

*3d
ztree2stata clients using 240905_1357.xls, clear
gen Session = "3d"
tempfile temp3d
save `temp3d'

*3e
ztree2stata clients using 240905_1531.xls, clear
gen Session = "3e"
tempfile temp3e
save `temp3e'

*3f
ztree2stata clients using 240905_1648.xls, clear
gen Session = "3f"
tempfile temp3f
save `temp3f'

*4a
ztree2stata clients using 240906_0859.xls, clear
gen Session = "4a"
tempfile temp4a
save `temp4a'

*4b
ztree2stata clients using 240906_1023.xls, clear
gen Session = "4b"
tempfile temp4b
save `temp4b'

*4c
ztree2stata clients using 240906_1218.xls, clear
gen Session = "4c"
tempfile temp4c
save `temp4c'

*4d
ztree2stata clients using 240906_1345.xls, clear
gen Session = "4d"
tempfile temp4d
save `temp4d'

*4e
ztree2stata clients using 240906_1519.xls, clear
gen Session = "4e"
tempfile temp4e
save `temp4e'

*4f
ztree2stata clients using 240906_1657.xls, clear
gen Session = "4f"
tempfile temp4f
save `temp4f'

// second wave. In the experimental recruiment, we use 1a, 1b... 2a, 2b.. but for distinguish from the first wave, we replace them by 5a.. 6a and so on
*5a
ztree2stata clients using 241009_1048.xls, clear
gen Session = "5a"
tempfile temp5a
save `temp5a'

*5b
ztree2stata clients using 241009_1227.xls, clear
gen Session = "5b"
tempfile temp5b
save `temp5b'

*5c
ztree2stata clients using 241009_1415.xls, clear
gen Session = "5c"
tempfile temp5c
save `temp5c'

*5d
ztree2stata clients using 241009_1533.xls, clear
gen Session = "5d"
tempfile temp5d
save `temp5d'

*5e
ztree2stata clients using 241009_1710.xls, clear
gen Session = "5e"
tempfile temp5e
save `temp5e'

*6a
ztree2stata clients using 241010_1121.xls, clear
gen Session = "6a"
tempfile temp6a
save `temp6a'

*6b
ztree2stata clients using 241010_1252.xls, clear
gen Session = "6b"
tempfile temp6b
save `temp6b'

*6c
ztree2stata clients using 241010_1406.xls, clear
gen Session = "6c"
tempfile temp6c
save `temp6c'

*6d
ztree2stata clients using 241010_1522.xls, clear
gen Session = "6d"
tempfile temp6d
save `temp6d'

*6e
ztree2stata clients using 241010_1700.xls, clear
gen Session = "6e"
tempfile temp6e
save `temp6e'

*7a
ztree2stata clients using 241011_1048.xls, clear
gen Session = "7a"
tempfile temp7a
save `temp7a'

*7b
ztree2stata clients using 241011_1226.xls, clear
gen Session = "7b"
tempfile temp7b
save `temp7b'

*7c
ztree2stata clients using 241011_1340.xls, clear
gen Session = "7c"
tempfile temp7c
save `temp7c'

*7d
ztree2stata clients using 241011_1524.xls, clear
gen Session = "7d"
tempfile temp7d
save `temp7d'


// third wave. In the experimental recruiment, we use a, b, c, and d as we only conduct one day experiment. but for distinguish from the first two waves, we replace them by 8a, 8b, 8c, and 8d here.


*8a
ztree2stata clients using 241104_1023.xls, clear
gen Session = "8a"
tempfile temp8a
save `temp8a'

*8b
ztree2stata clients using 241104_1213.xls, clear
gen Session = "8b"
tempfile temp8b
save `temp8b'

*8c
ztree2stata clients using 241104_1414.xls, clear
gen Session = "8c"
tempfile temp8c
save `temp8c'

*8d
ztree2stata clients using 241104_1617.xls, clear
gen Session = "8d"
tempfile temp8d
save `temp8d'



** merge dataset
use `temp1a', clear
append using `temp1b' `temp1c' `temp2a' `temp2b' `temp2c' `temp2d' `temp2e' `temp2f' `temp3a' `temp3b' `temp3c' `temp3d' `temp3e' `temp3f'  `temp4a' `temp4b' `temp4c' `temp4d' `temp4e' `temp4f' `temp5a' `temp5b' `temp5c' `temp5d' `temp5e' `temp6a' `temp6b' `temp6c' `temp6d' `temp6e' `temp7a' `temp7b' `temp7c' `temp7d' `temp8a' `temp8b' `temp8c' `temp8d'

keep Session ClientName Subject
isid Session Subject
isid Session ClientName
save ClientName.dta, replace

** Merge client identifiers with subject/post-questionnaire records.
merge 1:1 Subject Session using PostQ.dta
assert _merge == 3
drop _merge
save PostQ1.dta, replace


** import output dataset and merge
*1a
ztree2stata output using 240902_1219.xls, clear
gen Session = "1a"
tempfile temp1a
save `temp1a'

*1b
ztree2stata output using 240902_1357.xls, clear
gen Session = "1b"
tempfile temp1b
save `temp1b'

*1c
ztree2stata output using 240902_1537-2.xls, clear
gen Session = "1c"
tempfile temp1c
save `temp1c'

*2a
ztree2stata output using 240904_0918.xls, clear
gen Session = "2a"
tempfile temp2a
save `temp2a'


*2b
ztree2stata output using 240904_1031.xls, clear
gen Session = "2b"
tempfile temp2b
save `temp2b'

*2c
ztree2stata output using 240904_1225.xls, clear
gen Session = "2c"
tempfile temp2c
save `temp2c'

*2d
ztree2stata output using 240904_1346.xls, clear
gen Session = "2d"
tempfile temp2d
save `temp2d'

*2e
ztree2stata output using 240904_1601.xls, clear
gen Session = "2e"
tempfile temp2e
save `temp2e'

*2f
ztree2stata output using 240904_1703.xls, clear
gen Session = "2f"
tempfile temp2f
save `temp2f'

*3a
ztree2stata output using 240905_0853.xls, clear
gen Session = "3a"
tempfile temp3a
save `temp3a'

*3b
ztree2stata output using 240905_1029.xls, clear
gen Session = "3b"
tempfile temp3b
save `temp3b'


*3c
ztree2stata output using 240905_1221.xls, clear
gen Session = "3c"
tempfile temp3c
save `temp3c'

*3d
ztree2stata output using 240905_1357.xls, clear
gen Session = "3d"
tempfile temp3d
save `temp3d'

*3e
ztree2stata output using 240905_1531.xls, clear
gen Session = "3e"
tempfile temp3e
save `temp3e'

*3f
ztree2stata output using 240905_1648.xls, clear
gen Session = "3f"
tempfile temp3f
save `temp3f'

*4a
ztree2stata output using 240906_0859.xls, clear
gen Session = "4a"
tempfile temp4a
save `temp4a'

*4b
ztree2stata output using 240906_1023.xls, clear
gen Session = "4b"
tempfile temp4b
save `temp4b'

*4c
ztree2stata output using 240906_1218.xls, clear
gen Session = "4c"
tempfile temp4c
save `temp4c'

*4d
ztree2stata output using 240906_1345.xls, clear
gen Session = "4d"
tempfile temp4d
save `temp4d'

*4e
ztree2stata output using 240906_1519.xls, clear
gen Session = "4e"
tempfile temp4e
save `temp4e'

*4f
ztree2stata output using 240906_1657.xls, clear
gen Session = "4f"
tempfile temp4f
save `temp4f'

// second wave. In the experimental recruiment, we use 1a, 1b... 2a, 2b.. but for distinguish from the first wave, we replace them by 5a.. 6a and so on
*5a
ztree2stata output using 241009_1048.xls, clear
gen Session = "5a"
tempfile temp5a
save `temp5a'

*5b
ztree2stata output using 241009_1227.xls, clear
gen Session = "5b"
tempfile temp5b
save `temp5b'

*5c
ztree2stata output using 241009_1415.xls, clear
gen Session = "5c"
tempfile temp5c
save `temp5c'

*5d
ztree2stata output using 241009_1533.xls, clear
gen Session = "5d"
tempfile temp5d
save `temp5d'

*5e
ztree2stata output using 241009_1710.xls, clear
gen Session = "5e"
tempfile temp5e
save `temp5e'

*6a
ztree2stata output using 241010_1121.xls, clear
gen Session = "6a"
tempfile temp6a
save `temp6a'

*6b
ztree2stata output using 241010_1252.xls, clear
gen Session = "6b"
tempfile temp6b
save `temp6b'

*6c
ztree2stata output using 241010_1406.xls, clear
gen Session = "6c"
tempfile temp6c
save `temp6c'

*6d
ztree2stata output using 241010_1522.xls, clear
gen Session = "6d"
tempfile temp6d
save `temp6d'

*6e
ztree2stata output using 241010_1700.xls, clear
gen Session = "6e"
tempfile temp6e
save `temp6e'

*7a
ztree2stata output using 241011_1048.xls, clear
gen Session = "7a"
tempfile temp7a
save `temp7a'

*7b
ztree2stata output using 241011_1226.xls, clear
gen Session = "7b"
tempfile temp7b
save `temp7b'

*7c
ztree2stata output using 241011_1340.xls, clear
gen Session = "7c"
tempfile temp7c
save `temp7c'

*7d
ztree2stata output using 241011_1524.xls, clear
gen Session = "7d"
tempfile temp7d
save `temp7d'


// third wave. In the experimental recruiment, we use a, b, c, and d as we only conduct one day experiment. but for distinguish from the first two waves, we replace them by 8a, 8b, 8c, and 8d here.


*8a
ztree2stata output using 241104_1023.xls, clear
gen Session = "8a"
tempfile temp8a
save `temp8a'

*8b
ztree2stata output using 241104_1213.xls, clear
gen Session = "8b"
tempfile temp8b
save `temp8b'

*8c
ztree2stata output using 241104_1414.xls, clear
gen Session = "8c"
tempfile temp8c
save `temp8c'

*8d
ztree2stata output using 241104_1617.xls, clear
gen Session = "8d"
tempfile temp8d
save `temp8d'


** append output datasets
use `temp1a', clear
append using `temp1b' `temp1c' `temp2a' `temp2b' `temp2c' `temp2d' `temp2e' `temp2f' `temp3a' `temp3b' `temp3c' `temp3d' `temp3e' `temp3f'  `temp4a' `temp4b' `temp4c' `temp4d' `temp4e' `temp4f' `temp5a' `temp5b' `temp5c' `temp5d' `temp5e' `temp6a' `temp6b' `temp6c' `temp6d' `temp6e' `temp7a' `temp7b' `temp7c' `temp7d' `temp8a' `temp8b' `temp8c' `temp8d'
isid Session Subject
save OutputData.dta, replace



** Merge experimental output with subject-level questionnaire records.
merge 1:1 Subject Session using PostQ1.dta
assert _merge == 3
drop _merge
capture drop treatment tables
order Agent InformationLevel
save OutputData1.dta, replace


*** add prediction content
import excel table_assign_2024.xlsx, sheet("Sheet1") firstrow clear
isid ClientName
save Pdt.dta, replace

* merge dataset
use OutputData1.dta, clear
merge m:1 ClientName using Pdt.dta
assert _merge == 3 if ClientName != "SSSCAT31"
drop if _merge == 2
drop _merge

* One row per experimental client within session.
isid Session ClientName
save AllSession.dta, replace

display as result "1Append.do completed: AllSession.dta created successfully."
