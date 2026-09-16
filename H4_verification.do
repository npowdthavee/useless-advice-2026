* Corrected H4 and referee checks. Stata 17+.
* Run: do H4_verification.do "/full/path/AllSession_aftercleaning_final.dta" "/existing/output/folder"
* No installation or change to the source data is performed.
version 17
clear all
set more off
args datafile outdir
if `"`datafile'"' == "" | `"`outdir'"' == "" {
    di as error "Supply the cleaned data path and an existing output folder."
    exit 198
}
if regexm(lower(`"`datafile'"'), "[.]csv$") {
    import delimited using `"`datafile'"', clear varnames(1) case(preserve) asdouble
}
else {
    use `"`datafile'"', clear
}
assert _N == 750
gen byte donation = Agent==2
gen byte fullinfo = InformationLevel==2
egen long session_id = group(Session)
gen long participant_id = _n
bys session_id: assert donation==donation[1] & fullinfo==fullinfo[1]
capture log close h4log
log using `"`outdir'/H4_verification.log"', replace text name(h4log)
capture which boottest
local have_boot = (_rc==0)
if !`have_boot' di as error "boottest unavailable: bootstrap results will be missing; clustered tests still run."
tempname posth
tempfile hresults
postfile `posth' byte round double estimate se p lb ub p_wild using `hresults'
forvalues r=2/5 {
    local base = cond(`r'==2,3,1)
    regress Decision`r' i.donation##i.fullinfo##ib`base'.StreakTreat_R`r', vce(cluster session_id)
    estimates store H4_r`r'
    * Verbal registered H4: disclosure effect under donation minus purchase,
    * evaluated AFTER SUCCESS. Positive = the verbal prediction.
    lincom 1.donation#1.fullinfo + 1.donation#1.fullinfo#2.StreakTreat_R`r'
    local b = r(estimate)
    local se = r(se)
    local p = r(p)
    local lo = r(lb)
    local hi = r(ub)
    local pw = .
    if `have_boot' {
        boottest 1.donation#1.fullinfo + 1.donation#1.fullinfo#2.StreakTreat_R`r' = 0, ///
          cluster(session_id) reps(9999) seed(`=20260914+`r'') nograph
        local pw = r(p)
    }
    post `posth' (`r') (`b') (`se') (`p') (`lo') (`hi') (`pw')
    * Distinct supplementary three-way contrast, NOT H4.
    lincom 1.donation#1.fullinfo#2.StreakTreat_R`r'
}
postclose `posth'
preserve
use `hresults', clear
sort p
gen p_holm = min(1,(5-_n)*p)
replace p_holm = max(p_holm,p_holm[_n-1]) if _n>1
sort round
export delimited using `"`outdir'/H4_corrected_Stata.csv"', replace
restore
* Registered-form reconstruction: openly documented, not a claim of exact
* replication of the registration's open-ended control vector.
* The written sign phi6<0 conflicts with the verbal positive prediction.
* Gender has two categories; i.Gender is equivalent to a linear indicator.
forvalues r=2/5 {
    gen byte success`r' = StreakTreat_R`r'==2
    gen byte failure`r' = StreakTreat_R`r'==3
    local lag = `r'-1
    local extra ""
    if `r'>2 local extra "failure`r' Decision`lag'"
    regress Decision`r' i.donation##i.fullinfo i.success`r' ///
       i.donation#i.success`r' i.fullinfo#i.success`r' `extra' ///
       i.Gender Age risk_score iu authority if Decision1==0, vce(cluster session_id)
    lincom 1.donation#1.fullinfo
}
* Equal weighting of 39 session means, HC1 and residual df=35.
preserve
collapse (mean) Decision1, by(session_id donation fullinfo)
regress Decision1 i.donation##i.fullinfo, vce(robust)
lincom 1.donation#1.fullinfo
restore
* Pooled verification. Both models are full rank.
preserve
keep participant_id session_id donation fullinfo Decision2-Decision5 StreakTreat_R2-StreakTreat_R5
reshape long Decision StreakTreat_R, i(participant_id) j(round)
gen byte success = StreakTreat_R==2
gen byte failure = StreakTreat_R==3
forvalues start=2/3 {
    regress Decision i.round i.donation##i.fullinfo##(i.success i.failure) ///
      if round>=`start', vce(cluster session_id)
    lincom 1.success
    lincom 1.success + 1.fullinfo#1.success
    lincom 1.success + 1.donation#1.success
    lincom 1.success + 1.fullinfo#1.success + 1.donation#1.success + 1.donation#1.fullinfo#1.success
    lincom 1.donation#1.fullinfo#1.success
}
restore
log close h4log
