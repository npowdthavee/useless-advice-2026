********************************************************************************
* WHEN TRANSPARENCY FAILS / USELESS ADVICE
* REFRAMED ANALYSIS FOR JOURNAL OF ECONOMIC PSYCHOLOGY
*
* Input:  AllSession_aftercleaning_final.dta
* Output: /Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/
*         REStat - with NICK POWDTHAVEE/2024 Project/Cleaning and Analysis/
*         New analysis
*
* Recommended invocation (place the cleaned data in the output folder):
*   do 4Analysis_JoEP_reframed.do
*
* To use a cleaned dataset with a different name or location:
*   do 4Analysis_JoEP_reframed.do "/full/path/to/cleaned_data.dta"
*
* Design principles implemented here
*   1. Treatment is assigned at the session level: all primary inference is
*      clustered by session.
*   2. Primary causal models use only randomized treatment indicators and
*      exogenous prediction-history categories. No post-treatment controls.
*   3. Within-treatment streak effects do NOT include treatment main effects.
*   4. H3 and H4 are evaluated with direct interaction/DiD tests.
*   5. Round 1, pooled dynamics, reliance, and mechanism analyses are clearly
*      separated into confirmatory, supporting, and exploratory sections.
*   6. Acquiring a prediction is a choice. Reliance and bet-size regressions
*      are descriptive associations, not causal effects of acquisition.
*
* Written for Stata 17 or later. Optional command: boottest (SSC).
********************************************************************************

version 17.0
clear all
set more off
set linesize 255
set scheme s1mono

* All outputs are written to this folder. Fail loudly if it is unavailable so
* Stata cannot silently save results in whichever directory was active before.
local analysis_dir "/Users/nattavudhpowdthavee/Library/CloudStorage/Dropbox/REStat - with NICK POWDTHAVEE/2024 Project/Cleaning and Analysis/New analysis"
cap cd `"`analysis_dir'"'
if _rc {
    display as error "Could not change directory to:"
    display as error `"`analysis_dir'"'
    display as error "No analysis was run and no outputs were saved elsewhere."
    exit 170
}

args datafile
if `"`datafile'"' == "" local datafile "AllSession_aftercleaning_final.dta"
local outdir `"`analysis_dir'"'

capture log close _all
log using `"`outdir'/JoEP_reframed_analysis.log"', replace text name(mainlog)

display as text "Input data:  `datafile'"
display as text "Output dir:  `outdir'"
use `"`datafile'"', clear

********************************************************************************
* 0. VALIDATION AND ANALYSIS VARIABLES
********************************************************************************

local required Agent InformationLevel Session Decision1 Decision2 Decision3 ///
    Decision4 Decision5 StreakTreat_R2 StreakTreat_R3 StreakTreat_R4 ///
    StreakTreat_R5 Pdc_Correct1 Pdc_Correct2 Pdc_Correct3 Pdc_Correct4 ///
    Pdt1 Pdt2 Pdt3 Pdt4 Pdt5 Coin1 Coin2 Coin3 Coin4 Coin5 ///
    Bet1 Bet2 Bet3 Bet4 Bet5 ///
    BetAmount1 BetAmount2 BetAmount3 BetAmount4 BetAmount5 ///
    betsame1 betsame2 betsame3 betsame4 betsame5 ///
    lgbetamount1 lgbetamount2 lgbetamount3 lgbetamount4 lgbetamount5 ///
    Head1 Head2 Head3 Head4 Tail1 Tail2 Tail3 Tail4 ///
    Gender Age statistics_score karma authority UnderstandingLevel

foreach v in `required' {
    capture confirm variable `v'
    if _rc {
        display as error "Required variable `v' is missing. Analysis stopped."
        exit 111
    }
}

assert inlist(Agent,1,2)
assert inlist(InformationLevel,1,2)
assert inlist(Decision1,0,1)

generate byte donation = (Agent==2)
generate byte fullinfo = (InformationLevel==2)
generate byte treatment = 1 + fullinfo + 2*donation

label define donation_lbl 0 "Purchase" 1 "Donation", replace
label values donation donation_lbl
label define info_lbl 0 "No information" 1 "Full information", replace
label values fullinfo info_lbl
label define treatment_lbl 1 "P-NI" 2 "P-FI" 3 "D-NI" 4 "D-FI", replace
label values treatment treatment_lbl

egen long session_id = group(Session), label
generate long participant_id = _n
isid participant_id

* Treatment and realized coin path must be constant within each session.
bysort session_id (Agent): assert Agent[1] == Agent[_N]
bysort session_id (InformationLevel): assert InformationLevel[1] == InformationLevel[_N]
forvalues r=1/5 {
    bysort session_id (Coin`r'): assert Coin`r'[1] == Coin`r'[_N]
}

quietly levelsof session_id, local(session_levels)
local n_sessions : word count `session_levels'
assert `n_sessions' == 39
display as result "Validated: " _N " participants nested in `n_sessions' sessions."

egen byte session_tag = tag(session_id)
tabulate treatment if session_tag, missing
tabulate treatment, missing

* Check that the supplied treatment variable, if present, agrees with design.
capture confirm variable treat
if !_rc {
    assert treat == treatment
}

* Optional wild-cluster bootstrap support. The do-file remains runnable without it.
capture which boottest
local have_boottest = (_rc==0)
if !`have_boottest' {
    display as text "NOTE: boottest not installed. Cluster-robust and Holm results will run;"
    display as text "      wild-cluster bootstrap checks will be skipped."
    display as text "      To add them, install once with: ssc install boottest"
}

********************************************************************************
* 1. DESIGN AND DESCRIPTIVE CHECKS
********************************************************************************

preserve
generate byte male = (Gender==1)
collapse (count) N=participant_id (mean) male Age ///
    statistics_score Decision1, by(treatment)
order treatment N male Age statistics_score Decision1
export delimited using `"`outdir'/descriptives_by_treatment.csv"', replace
restore

********************************************************************************
* 2. EXPLORATORY OPENING RESULT: ROUND 1
*
* Round 1 occurs before any prediction-performance history is observed. This
* analysis was not one of H1-H4 and must be described as exploratory unless the
* preregistration is verified to include it.
********************************************************************************

regress Decision1 i.donation##i.fullinfo, vce(cluster session_id)
estimates store round1_factorial

tempname round1post
tempfile round1results
postfile `round1post' str32 contrast double estimate se p lb ub ///
    using `round1results', replace

* Information effect in purchase context: P-FI minus P-NI.
lincom 1.fullinfo
post `round1post' ("P-FI minus P-NI") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

* Information effect in donation context: D-FI minus D-NI.
lincom 1.fullinfo + 1.donation#1.fullinfo
post `round1post' ("D-FI minus D-NI") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

* Difference in the information effect across contexts.
lincom 1.donation#1.fullinfo
post `round1post' ("Round-1 interaction") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

postclose `round1post'
preserve
use `round1results', clear
export delimited using `"`outdir'/round1_factorial_contrasts.csv"', replace
save `"`outdir'/round1_factorial_contrasts.dta"', replace
restore

if `have_boottest' {
    display as text "Wild-cluster bootstrap: Round-1 context x information interaction"
    boottest 1.donation#1.fullinfo, cluster(session_id) reps(9999) ///
        seed(20260913) nograph
}

* Four cell means and Figure 1.
regress Decision1 ib1.treatment, vce(cluster session_id)
margins treatment, saving(`"`outdir'/round1_margins.dta"', replace)
marginsplot, recast(bar) recastci(rcap) ///
    title("Demand before any performance history") ///
    ytitle("Proportion purchasing or donating") xtitle("") ///
    ylabel(0(.1).4, format(%3.1f)) name(round1fig, replace)
graph export `"`outdir'/Figure1_round1_demand.png"', replace width(2400)

********************************************************************************
* 3. CONFIRMATORY H1-H4: ROUND-SPECIFIC SUCCESS-STREAK MODELS
*
* Round 2: the comparison is all-correct (2) versus all-incorrect (3), because
*          no mixed history exists after one prediction.
* Rounds 3-5: the comparison is all-correct (2) versus mixed history (1).
*
* H1:  Success-streak effect in P-NI.
* H2a: Success-streak effect in D-NI.
* H2b: D-NI success-streak effect minus P-NI effect.
* H3:  P-FI success-streak effect minus P-NI effect (attenuation contrast).
* H4:  (D-FI-D-NI) minus (P-FI-P-NI) in success-streak responsiveness.
********************************************************************************

tempname hpost cpost
tempfile htests contrasts
postfile `hpost' str24 hypothesis byte round double estimate se p lb ub ///
    using `htests', replace
postfile `cpost' str32 contrast byte round double estimate se p lb ub ///
    using `contrasts', replace

* Short labels keep the four-panel figure readable.
label define history_short 1 "Mixed" 2 "All correct" 3 "All incorrect", replace
forvalues r=2/5 {
    label values StreakTreat_R`r' history_short
}

forvalues r=2/5 {
    local base = cond(`r'==2,3,1)
    display as text _newline "===== SUCCESS-STREAK MODEL: ROUND `r' ====="

    regress Decision`r' i.donation##i.fullinfo##ib`base'.StreakTreat_R`r', ///
        vce(cluster session_id)
    estimates store success_r`r'

    * P-NI within-cell success-streak effect.
    lincom 2.StreakTreat_R`r'
    post `hpost' ("H1_PNI") (`r') (r(estimate)) (r(se)) (r(p)) (r(lb)) (r(ub))
    post `cpost' ("P-NI success effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * P-FI within-cell success-streak effect.
    lincom 2.StreakTreat_R`r' + 1.fullinfo#2.StreakTreat_R`r'
    post `cpost' ("P-FI success effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * D-NI within-cell success-streak effect.
    lincom 2.StreakTreat_R`r' + 1.donation#2.StreakTreat_R`r'
    post `hpost' ("H2a_DNI") (`r') (r(estimate)) (r(se)) (r(p)) (r(lb)) (r(ub))
    post `cpost' ("D-NI success effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * D-FI within-cell success-streak effect.
    lincom 2.StreakTreat_R`r' + 1.fullinfo#2.StreakTreat_R`r' + ///
        1.donation#2.StreakTreat_R`r' + ///
        1.donation#1.fullinfo#2.StreakTreat_R`r'
    post `cpost' ("D-FI success effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * H2b: Does donation amplify the streak effect without information?
    lincom 1.donation#2.StreakTreat_R`r'
    post `hpost' ("H2b_DNI_minus_PNI") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))
    post `cpost' ("D-NI minus P-NI") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * H3: Information attenuation in purchase context.
    lincom 1.fullinfo#2.StreakTreat_R`r'
    post `hpost' ("H3_PFI_minus_PNI") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))
    post `cpost' ("P-FI minus P-NI") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * Information attenuation in donation context.
    lincom 1.fullinfo#2.StreakTreat_R`r' + ///
        1.donation#1.fullinfo#2.StreakTreat_R`r'
    post `cpost' ("D-FI minus D-NI") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * New headline comparison under identical full information.
    lincom 1.donation#2.StreakTreat_R`r' + ///
        1.donation#1.fullinfo#2.StreakTreat_R`r'
    post `cpost' ("D-FI minus P-FI") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    * H4: the actual difference-in-differences.
    lincom 1.donation#1.fullinfo#2.StreakTreat_R`r'
    post `hpost' ("H4_DID") (`r') (r(estimate)) (r(se)) (r(p)) (r(lb)) (r(ub))
    post `cpost' ("H4 difference-in-differences") (`r') (r(estimate)) ///
        (r(se)) (r(p)) (r(lb)) (r(ub))

    * Small-cluster sensitivity checks for the key direct tests.
    if `have_boottest' {
        display as text "Wild bootstrap H1, H2b, H3, and H4; Round `r'"
        boottest 2.StreakTreat_R`r', cluster(session_id) reps(9999) ///
            seed(`=20260913+`r'') nograph
        boottest 1.donation#2.StreakTreat_R`r', cluster(session_id) reps(9999) ///
            seed(`=20261013+`r'') nograph
        boottest 1.fullinfo#2.StreakTreat_R`r', cluster(session_id) reps(9999) ///
            seed(`=20261113+`r'') nograph
        boottest 1.donation#1.fullinfo#2.StreakTreat_R`r', ///
            cluster(session_id) reps(9999) seed(`=20261213+`r'') nograph
    }

    * Treatment-cell margins for the four-panel streak figure. Each panel is
    * one round; treatments are rows and prediction histories are markers.
    regress Decision`r' ib1.treatment##ib`base'.StreakTreat_R`r', ///
        vce(cluster session_id)
    margins treatment#StreakTreat_R`r', ///
        saving(`"`outdir'/round`r'_streak_margins.dta"', replace)

    if `r'==2 {
        marginsplot, xdimension(treatment) ///
            plotdimension(StreakTreat_R`r') horizontal ///
            recast(scatter) recastci(rcap) ///
            plot1opts(msymbol(D) mcolor(black)) ///
            ci1opts(lcolor(black)) ///
            plot2opts(msymbol(T) mcolor(gs8)) ///
            ci2opts(lcolor(gs8)) ///
            ytitle("") xtitle("Predicted probability of acquisition") ///
            xscale(range(0 1)) xlabel(0(.2)1, format(%3.1f)) ///
            title("Round `r'", size(medsmall)) ///
            legend(order(1 "All correct" 2 "All incorrect") ///
                rows(1) size(small)) ///
            graphregion(color(white)) plotregion(color(white)) ///
            name(streakfig`r', replace)
    }
    else {
        marginsplot, xdimension(treatment) ///
            plotdimension(StreakTreat_R`r') horizontal ///
            recast(scatter) recastci(rcap) ///
            plot1opts(msymbol(O) mcolor(gs5)) ///
            ci1opts(lcolor(gs5)) ///
            plot2opts(msymbol(D) mcolor(black)) ///
            ci2opts(lcolor(black)) ///
            plot3opts(msymbol(T) mcolor(gs10)) ///
            ci3opts(lcolor(gs10)) ///
            ytitle("") xtitle("Predicted probability of acquisition") ///
            xscale(range(0 1)) xlabel(0(.2)1, format(%3.1f)) ///
            title("Round `r'", size(medsmall)) ///
            legend(order(1 "Mixed" 2 "All correct" 3 "All incorrect") ///
                rows(1) size(small)) ///
            graphregion(color(white)) plotregion(color(white)) ///
            name(streakfig`r', replace)
    }
}

postclose `hpost'
postclose `cpost'

graph combine streakfig2 streakfig3 streakfig4 streakfig5, cols(2) ///
    ycommon xcommon imargin(tiny) graphregion(color(white)) ///
    title("Demand by prediction history and treatment", size(medium)) ///
    name(streak_combined, replace)
graph export `"`outdir'/Figure2_streak_dynamics.png"', replace width(3200)

preserve
use `contrasts', clear
sort round contrast
export delimited using `"`outdir'/round_success_streak_contrasts.csv"', replace
save `"`outdir'/round_success_streak_contrasts.dta"', replace
restore

********************************************************************************
* 4. MULTIPLE TESTING: HOLM WITHIN EACH PREREGISTERED HYPOTHESIS FAMILY
*
* Uses the two-sided session-clustered p-values above. H2 has two components,
* so the D-NI within-cell effect (H2a) and D-NI-minus-P-NI contrast (H2b) are
* retained as separate families. Adjustment is across Rounds 2-5 within family.
********************************************************************************

preserve
use `htests', clear
sort hypothesis p
by hypothesis: generate int family_size = _N
by hypothesis: generate int p_rank = _n
generate double p_holm = (family_size-p_rank+1)*p
by hypothesis (p): replace p_holm = max(p_holm,p_holm[_n-1]) if _n>1
replace p_holm = min(p_holm,1)
sort hypothesis round
order hypothesis round estimate se p p_holm lb ub
export delimited using `"`outdir'/H1_H4_clustered_Holm.csv"', replace
save `"`outdir'/H1_H4_clustered_Holm.dta"', replace
restore

********************************************************************************
* 5. SECONDARY RESULT: ALL-INCORRECT PREDICTION HISTORIES
*
* Available only in Rounds 3-5 with a mixed history as the reference category.
********************************************************************************

tempname fpost
tempfile failurecontrasts
postfile `fpost' str32 contrast byte round double estimate se p lb ub ///
    using `failurecontrasts', replace

forvalues r=3/5 {
    regress Decision`r' i.donation##i.fullinfo##ib1.StreakTreat_R`r', ///
        vce(cluster session_id)

    lincom 3.StreakTreat_R`r'
    post `fpost' ("P-NI failure effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    lincom 3.StreakTreat_R`r' + 1.fullinfo#3.StreakTreat_R`r'
    post `fpost' ("P-FI failure effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    lincom 3.StreakTreat_R`r' + 1.donation#3.StreakTreat_R`r'
    post `fpost' ("D-NI failure effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    lincom 3.StreakTreat_R`r' + 1.fullinfo#3.StreakTreat_R`r' + ///
        1.donation#3.StreakTreat_R`r' + ///
        1.donation#1.fullinfo#3.StreakTreat_R`r'
    post `fpost' ("D-FI failure effect") (`r') (r(estimate)) (r(se)) (r(p)) ///
        (r(lb)) (r(ub))

    lincom 1.donation#1.fullinfo#3.StreakTreat_R`r'
    post `fpost' ("Failure difference-in-differences") (`r') (r(estimate)) ///
        (r(se)) (r(p)) (r(lb)) (r(ub))
}
postclose `fpost'

preserve
use `failurecontrasts', clear
sort round contrast
export delimited using `"`outdir'/round_failure_streak_contrasts.csv"', replace
save `"`outdir'/round_failure_streak_contrasts.dta"', replace
restore

********************************************************************************
* 6. POOLED PERSON-ROUND MODEL (ROUNDS 2-5)
*
* Session clustering also absorbs all dependence among repeated decisions from
* the same participant because participants are nested within sessions.
********************************************************************************

preserve
keep participant_id session_id treatment donation fullinfo ///
    Decision2-Decision5 StreakTreat_R2-StreakTreat_R5 ///
    betsame2-betsame5 lgbetamount2-lgbetamount5 BetAmount2-BetAmount5

reshape long Decision StreakTreat_R betsame lgbetamount BetAmount, ///
    i(participant_id) j(round)

generate byte success = (StreakTreat_R==2)
generate byte failure = (StreakTreat_R==3)
label define history_lbl 0 "Mixed" 1 "All correct" 2 "All incorrect", replace
generate byte history = 0
replace history = 1 if success
replace history = 2 if failure
label values history history_lbl

* Keep a restorable copy of the long person-round data. Stata does not permit
* a second preserve while the original participant-level data are preserved.
tempfile personround
save `personround', replace

regress Decision i.round i.donation##i.fullinfo##(i.success i.failure), ///
    vce(cluster session_id)
estimates store pooled_r2_r5

tempname poolpost
tempfile poolresults
postfile `poolpost' str38 contrast double estimate se p lb ub ///
    using `poolresults', replace

lincom 1.success
post `poolpost' ("P-NI pooled success effect") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.success + 1.fullinfo#1.success
post `poolpost' ("P-FI pooled success effect") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.success + 1.donation#1.success
post `poolpost' ("D-NI pooled success effect") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.success + 1.fullinfo#1.success + 1.donation#1.success + ///
    1.donation#1.fullinfo#1.success
post `poolpost' ("D-FI pooled success effect") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.fullinfo#1.success
post `poolpost' ("P-FI minus P-NI") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.fullinfo#1.success + 1.donation#1.fullinfo#1.success
post `poolpost' ("D-FI minus D-NI") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.donation#1.success + 1.donation#1.fullinfo#1.success
post `poolpost' ("D-FI minus P-FI") (r(estimate)) (r(se)) (r(p)) ///
    (r(lb)) (r(ub))

lincom 1.donation#1.fullinfo#1.success
post `poolpost' ("Success difference-in-differences") (r(estimate)) ///
    (r(se)) (r(p)) (r(lb)) (r(ub))
postclose `poolpost'

if `have_boottest' {
    display as text "Wild bootstrap: pooled success DiD"
    boottest 1.donation#1.fullinfo#1.success, cluster(session_id) ///
        reps(9999) seed(20262026) nograph
}

use `poolresults', clear
export delimited using `"`outdir'/pooled_success_contrasts.csv"', replace
save `"`outdir'/pooled_success_contrasts.dta"', replace
use `personround', clear

* Robustness with a common mixed-history comparator: Rounds 3-5 only.
regress Decision i.round i.donation##i.fullinfo##(i.success i.failure) ///
    if round>=3, vce(cluster session_id)
estimates store pooled_r3_r5

********************************************************************************
* 7. SUPPORTING EVIDENCE: DID PEOPLE USE THE PREDICTION?
*
* These are descriptive/associational because Decision is endogenous.
********************************************************************************

* Intuitive D-FI comparison after a successful history.
tabulate Decision if donation==1 & fullinfo==1 & success==1
mean betsame if donation==1 & fullinfo==1 & success==1 & Decision==1
mean betsame if donation==1 & fullinfo==1 & success==1 & Decision==0

regress betsame i.Decision i.round if donation==1 & fullinfo==1 & success==1, ///
    vce(cluster session_id)
estimates store reliance_DFI_success

regress lgbetamount i.Decision i.round ///
    if donation==1 & fullinfo==1 & success==1, vce(cluster session_id)
estimates store betsize_DFI_success

* Export transparent cell counts and rates; these reproduce the 87.8% versus
* 48.4% comparison in D-FI and show its denominator.
keep if success==1
collapse (mean) follow_rate=betsame mean_log_bet=lgbetamount ///
    (count) N=betsame, by(treatment Decision)
sort treatment Decision
export delimited using `"`outdir'/prediction_use_after_success.csv"', replace
use `personround', clear

* Corrected round-specific association. The effect of acquisition among those
* with a successful history is Decision + Decision x Success; it does not
* include the main effect of the history category.
tempname usepost
tempfile useresults
postfile `usepost' byte round double estimate se p lb ub using `useresults', replace

forvalues r=2/5 {
    local base = cond(`r'==2,3,1)
    regress betsame i.Decision##ib`base'.StreakTreat_R i.treatment i.round ///
        if round==`r', vce(cluster session_id)
    lincom 1.Decision + 1.Decision#2.StreakTreat_R
    post `usepost' (`r') (r(estimate)) (r(se)) (r(p)) (r(lb)) (r(ub))
}
postclose `usepost'

use `useresults', clear
generate str48 contrast = "Acquirer minus non-acquirer after success"
order round contrast estimate se p lb ub
export delimited using `"`outdir'/prediction_reliance_association.csv"', replace
save `"`outdir'/prediction_reliance_association.dta"', replace
use `personround', clear

********************************************************************************
* 8. EXPLORATORY PSYCHOLOGICAL AND SEQUENCE ANALYSES
*
* Karma, locus of control, statistics performance, and UnderstandingLevel were
* elicited after the task. They are not mediators or causal controls. Results
* here are exploratory associations and should be described accordingly.
********************************************************************************

restore

egen double z_karma = std(karma)
egen double z_external = std(authority)
egen double z_statistics = std(statistics_score)

* Self-reported understanding is not a direct check that the split-prediction
* mechanism was understood; report it only as a limited descriptive measure.
regress UnderstandingLevel i.donation##i.fullinfo, vce(cluster session_id)
estimates store selfreported_understanding

* Participant-level karma comparison: any donation after any successful history.
generate byte any_success = 0
generate byte any_donate_after_success = 0
forvalues r=2/5 {
    replace any_success = 1 if StreakTreat_R`r'==2
    replace any_donate_after_success = 1 if ///
        StreakTreat_R`r'==2 & Decision`r'==1
}
regress z_karma i.any_donate_after_success if donation==1 & any_success==1, ///
    vce(cluster session_id)
estimates store karma_participant_level

* Sequence checks: same number of correct predictions, different ordering.
generate byte seq_r4 = .
replace seq_r4 = 1 if Pdc_Correct1==0 & Pdc_Correct2==1 & Pdc_Correct3==1
replace seq_r4 = 2 if Pdc_Correct1==1 & Pdc_Correct2==1 & Pdc_Correct3==0
replace seq_r4 = 3 if Pdc_Correct1==1 & Pdc_Correct2==1 & Pdc_Correct3==1
label define seq4_lbl 1 "FSS" 2 "SSF" 3 "SSS", replace
label values seq_r4 seq4_lbl

regress Decision4 ib1.seq_r4 i.treatment, vce(cluster session_id)
lincom 2.seq_r4
lincom 3.seq_r4
lincom 3.seq_r4 - 2.seq_r4
estimates store sequence_round4

generate byte seq_r5 = .
replace seq_r5 = 1 if Pdc_Correct1==0 & Pdc_Correct2==1 & ///
    Pdc_Correct3==1 & Pdc_Correct4==1
replace seq_r5 = 2 if Pdc_Correct1==1 & Pdc_Correct2==1 & ///
    Pdc_Correct3==1 & Pdc_Correct4==0
replace seq_r5 = 3 if Pdc_Correct1==1 & Pdc_Correct2==1 & ///
    Pdc_Correct3==1 & Pdc_Correct4==1
label define seq5_lbl 1 "FSSS" 2 "SSSF" 3 "SSSS", replace
label values seq_r5 seq5_lbl

regress Decision5 ib1.seq_r5 i.treatment, vce(cluster session_id)
lincom 2.seq_r5
lincom 3.seq_r5
lincom 3.seq_r5 - 2.seq_r5
estimates store sequence_round5

* Rebuild the person-round data for exploratory heterogeneity models.
preserve
keep participant_id session_id treatment donation fullinfo z_external ///
    z_statistics z_karma Decision2-Decision5 StreakTreat_R2-StreakTreat_R5
reshape long Decision StreakTreat_R, i(participant_id) j(round)
generate byte success = (StreakTreat_R==2)
generate byte failure = (StreakTreat_R==3)

regress Decision i.round i.treatment##i.success##c.z_external ///
    i.treatment##i.failure##c.z_external, vce(cluster session_id)
estimates store external_locus_exploratory

regress Decision i.round i.treatment##i.success##c.z_statistics ///
    i.treatment##i.failure##c.z_statistics, vce(cluster session_id)
estimates store statistics_exploratory
restore

********************************************************************************
* 9. APPENDIX: GAMBLER'S-FALLACY / HOT-HAND-OF-THE-COIN CHECKS
********************************************************************************

regress Bet3 i.Head2 i.Tail2 i.treatment, vce(cluster session_id)
estimates store coin_round3
regress Bet4 i.Head3 i.Tail3 i.treatment, vce(cluster session_id)
estimates store coin_round4
regress Bet5 i.Head4 i.Tail4 i.treatment, vce(cluster session_id)
estimates store coin_round5

********************************************************************************
* 10. OPTIONAL AUDIT: LEGACY ADJUSTED MODELS
*
* These reproduce the old adjustment strategy with corrected clustering and
* corrected within-treatment lincoms. They are NOT primary causal models.
* fixedbetting uses future choices, while lagged endowment, prior mistakes,
* betsame, karma, locus of control, IU, and risk_score are treatment-descendant
* or post-task variables. Set RUN_LEGACY to 0 to skip this section.
********************************************************************************

local RUN_LEGACY 1
if `RUN_LEGACY' {
    capture confirm variable fixedbetting
    local legacy_ok = (_rc==0)
    foreach v in iu risk_score Endowment_beforeR2 Endowment_beforeR3 ///
        Endowment_beforeR4 Endowment_beforeR5 madewrongbet1 madewrongbet2 ///
        madewrongbet3 madewrongbet4 {
        capture confirm variable `v'
        if _rc local legacy_ok = 0
    }

    if `legacy_ok' {
        forvalues r=2/5 {
            local lag = `r'-1
            local base = cond(`r'==2,3,1)
            regress Decision`r' ib1.treatment##ib`base'.StreakTreat_R`r' ///
                i.Gender Age statistics_score Endowment_beforeR`r' ///
                Head`lag' Tail`lag' i.madewrongbet`lag' fixedbetting ///
                i.betsame`lag' karma authority iu risk_score, ///
                vce(cluster session_id)
            estimates store legacy_r`r'

            * Correct within-treatment effects: no treatment main effect added.
            lincom 2.StreakTreat_R`r'
            lincom 2.StreakTreat_R`r' + 2.treatment#2.StreakTreat_R`r'
            lincom 2.StreakTreat_R`r' + 3.treatment#2.StreakTreat_R`r'
            lincom 2.StreakTreat_R`r' + 4.treatment#2.StreakTreat_R`r'
        }
    }
    else {
        display as text "Legacy audit skipped because one or more legacy variables are absent."
    }
}

********************************************************************************
* 11. SAVE A COMPACT INDEX OF STORED ESTIMATES (IF ESTTAB IS INSTALLED)
********************************************************************************

capture which esttab
if !_rc {
    esttab round1_factorial success_r2 success_r3 success_r4 success_r5 ///
        pooled_r2_r5 pooled_r3_r5 using `"`outdir'/model_index.csv"', ///
        replace se r2 ar2 nogaps compress
}
else {
    display as text "NOTE: esttab not installed; model_index.csv was not created."
    display as text "      All purpose-built contrast CSV files were still created."
}

display as result _newline "Analysis completed successfully."
display as result "See `outdir' for logs, contrast tables, saved margins, and figures."
log close mainlog

********************************************************************************
* END OF FILE
********************************************************************************
