********************************************************************************
* USELESS ADVICE: CLEANING AND ANALYSIS-DATA PREPARATION
*
* Input:  AllSession.dta (created by 1Append.do)
* Output: AllSession_aftercleaning_final.dta
*
* After this file completes, run 4Analysis_JoEP_reframed.do directly.
********************************************************************************

version 17.0
clear all
set more off

args analysis_dir
if `"`analysis_dir'"' == "" local analysis_dir `"`c(pwd)'"'
cap cd `"`analysis_dir'"'
if _rc {
    display as error "Could not change directory to:"
    display as error `"`analysis_dir'"'
    display as error "No files were created."
    exit 170
}

use AllSession.dta, clear

********************************************************************************
* 1. INPUT VALIDATION AND EXCLUSION
********************************************************************************

local required Agent InformationLevel Session ClientName Pdt1 Pdt2 Pdt3 Pdt4 ///
    Pdt5 Coin1 Coin2 Coin3 Coin4 Coin5 Decision1 Decision2 Decision3 ///
    Decision4 Decision5 Bet1 Bet2 Bet3 Bet4 Bet5 BetAmount1 BetAmount2 ///
    BetAmount3 BetAmount4 BetAmount5 Endowment_beforeR1 ///
    Endowment_beforeR2 Endowment_beforeR3 Endowment_beforeR4 ///
    Endowment_beforeR5 Endowment_afterR1 Endowment_afterR2 ///
    Endowment_afterR3 Endowment_afterR4 Endowment_afterR5 CorrectNum ///
    WrongNum BlankNum Earning2 ///
    Choice1 Choice2 Choice3 Choice4 Choice5 Choice6 Choice7 Choice8 ///
    Choice9 Choice10 Gender Year Age UnderstandingLevel ///
    KarmaBelief1 KarmaBelief2 KarmaBelief3 Authority1 Authority2 ///
    Authority3 Authority4 Authority5 Authority6 Authority7 ///
    IUS1 IUS2 IUS3 IUS4 IUS5 IUS6 IUS7 IUS8 IUS9 IUS10 IUS11 IUS12

foreach v in `required' {
    capture confirm variable `v'
    if _rc {
        display as error "Required input variable `v' is missing."
        exit 111
    }
}

isid Session ClientName

* Remove the experimenter's terminal used to enter the observed coin outcomes.
count if ClientName == "SSSCAT31"
assert r(N) == 1
drop if ClientName == "SSSCAT31"

assert _N == 750
assert inlist(Agent,1,2)
assert inlist(InformationLevel,1,2)

foreach stem in Pdt Coin Bet Decision {
    forvalues r=1/5 {
        assert inlist(`stem'`r',0,1)
    }
}

* Treatment and coin outcomes were assigned/realized at session level.
bysort Session (Agent): assert Agent[1] == Agent[_N]
bysort Session (InformationLevel): ///
    assert InformationLevel[1] == InformationLevel[_N]
forvalues r=1/5 {
    bysort Session (Coin`r'): assert Coin`r'[1] == Coin`r'[_N]
    bysort ClientName (Pdt`r'): assert Pdt`r'[1] == Pdt`r'[_N]
}

egen byte session_tag = tag(Session)
count if session_tag
assert r(N) == 39
drop session_tag

* Confirm the four treatment-cell sample sizes reported in the manuscript.
count if Agent==1 & InformationLevel==1
assert r(N)==187
count if Agent==1 & InformationLevel==2
assert r(N)==200
count if Agent==2 & InformationLevel==1
assert r(N)==175
count if Agent==2 & InformationLevel==2
assert r(N)==188

* Confirm endowment accounting carried forward correctly from 1Append.do.
assert Endowment_beforeR1 == 300
forvalues r=2/5 {
    local previous = `r'-1
    assert Endowment_beforeR`r' == Endowment_afterR`previous'
}

capture drop Subject session _merge

********************************************************************************
* 2. LABELS
********************************************************************************

label define CoinSide 0 "Tail" 1 "Head", replace
label values Coin1-Coin5 Bet1-Bet5 Pdt1-Pdt5 CoinSide

label define Agenttype 1 "Expert" 2 "Charity", replace
label values Agent Agenttype

label define InformationLeveltype 1 "No information" ///
    2 "Full information", replace
label values InformationLevel InformationLeveltype

label define Decision_lbl 0 "Did not purchase/donate" ///
    1 "Purchased/donated", replace
label values Decision1-Decision5 Decision_lbl

forvalues r=1/5 {
    label variable Pdt`r' "Prediction in Round `r'"
}

label define Gender_lbl 1 "Male" 2 "Female" ///
    3 "Prefer not to say", replace
label values Gender Gender_lbl

label define Year_lbl 1 "Year 1" 2 "Year 2" 3 "Year 3" 4 "Year 4" ///
    5 "Year 5" 6 "Postgraduate", replace
label values Year Year_lbl

label define Understanding_lbl 1 "Do not understand at all" ///
    2 "Barely understand" 3 "Average understanding" ///
    4 "Mostly understand" 5 "Completely understand", replace
label values UnderstandingLevel Understanding_lbl

label variable CorrectNum "Correct answers in probability test"
label variable WrongNum "Incorrect answers in probability test"
label variable BlankNum "Unanswered questions in probability test"
label variable Earning2 "Earnings in probability test"

label define Authority_lbl 1 "Strongly disagree" 2 "Disagree" ///
    3 "Slightly disagree" 4 "Neutral" 5 "Slightly agree" ///
    6 "Agree" 7 "Strongly agree", replace
label values Authority1-Authority7 Authority_lbl

label define IUS_lbl 1 "Not at all characteristic" ///
    2 "Slightly characteristic" 3 "Somewhat characteristic" ///
    4 "Mostly characteristic" 5 "Entirely characteristic", replace
label values IUS1-IUS12 IUS_lbl

label define Karma_lbl 1 "Strongly disagree" 2 "Slightly disagree" ///
    3 "Neutral" 4 "Slightly agree" 5 "Strongly agree", replace
label values KarmaBelief1-KarmaBelief3 Karma_lbl

label define Choice_lbl 1 "Sure $1" 2 "Risky option", replace
label values Choice1-Choice10 Choice_lbl

********************************************************************************
* 3. PREDICTION ACCURACY AND HISTORY CATEGORIES
********************************************************************************

forvalues r=1/5 {
    generate byte Pdc_Correct`r' = (Pdt`r'==Coin`r')
    assert inlist(Pdc_Correct`r',0,1)
}

* Category 1 = mixed history, 2 = all correct, 3 = all incorrect.
generate byte StreakTreat_R2 = cond(Pdc_Correct1==1,2,3)

forvalues r=3/5 {
    local previous = `r'-1
    generate byte StreakTreat_R`r' = 1

    tempvar all_correct all_incorrect
    generate byte `all_correct' = 1
    generate byte `all_incorrect' = 1
    forvalues k=1/`previous' {
        replace `all_correct' = 0 if Pdc_Correct`k' != 1
        replace `all_incorrect' = 0 if Pdc_Correct`k' != 0
    }
    replace StreakTreat_R`r' = 2 if `all_correct'
    replace StreakTreat_R`r' = 3 if `all_incorrect'
}

label define Streak_lbl 1 "Mixed previous predictions" ///
    2 "All previous predictions correct" ///
    3 "All previous predictions incorrect", replace
label values StreakTreat_R2-StreakTreat_R5 Streak_lbl

* Recheck every generated history category against its underlying sequence.
assert StreakTreat_R2==2 if Pdc_Correct1==1
assert StreakTreat_R2==3 if Pdc_Correct1==0
forvalues r=3/5 {
    local previous = `r'-1
    tempvar sum_correct
    egen byte `sum_correct' = rowtotal(Pdc_Correct1-Pdc_Correct`previous')
    assert StreakTreat_R`r'==2 if `sum_correct'==`previous'
    assert StreakTreat_R`r'==3 if `sum_correct'==0
    assert StreakTreat_R`r'==1 if inrange(`sum_correct',1,`previous'-1)
}

********************************************************************************
* 4. TREATMENT AND QUESTIONNAIRE SCORES
********************************************************************************

generate byte treat = 1 if Agent==1 & InformationLevel==1
replace treat = 2 if Agent==1 & InformationLevel==2
replace treat = 3 if Agent==2 & InformationLevel==1
replace treat = 4 if Agent==2 & InformationLevel==2
assert inrange(treat,1,4)

label define treat_lbl 1 "P-NI" 2 "P-FI" 3 "D-NI" 4 "D-FI", replace
label values treat treat_lbl
label variable treat "Experimental treatment"

rename CorrectNum statistics_score
label variable statistics_score "Correct answers in probability test"

* One-factor scores. Orient them so that higher values mean stronger karma,
* more external locus of control, and greater intolerance of uncertainty.
factor KarmaBelief1-KarmaBelief3, factors(1)
predict double karma
quietly correlate karma KarmaBelief2
if r(rho)<0 replace karma = -karma
label variable karma "Karma-belief factor score"

factor Authority1-Authority7, factors(1)
predict double authority
quietly correlate authority Authority1
if r(rho)<0 replace authority = -authority
label variable authority "External-locus-of-control factor score"

factor IUS1-IUS12, factors(1)
predict double iu
quietly correlate iu IUS1
if r(rho)<0 replace iu = -iu
label variable iu "Intolerance-of-uncertainty factor score"

********************************************************************************
* 5. RISK PREFERENCES
********************************************************************************

forvalues i=1/10 {
    assert inlist(Choice`i',1,2)
}

* Verify the single-switching property: nobody returns to the sure option
* after having selected the risky option.
generate byte nonmonotonic_choice = 0
forvalues i=1/9 {
    local next = `i'+1
    replace nonmonotonic_choice = 1 if Choice`i'==2 & Choice`next'==1
}
assert nonmonotonic_choice==0
drop nonmonotonic_choice

generate byte switching_point = .
forvalues i=1/10 {
    replace switching_point=`i' if missing(switching_point) & Choice`i'==2
}
replace switching_point=11 if missing(switching_point)
label variable switching_point "First risky choice; 11=always chose sure $1"

* A risk-neutral decision-maker chooses the risky option from Choice 5
* (p=.40; expected value=$1.20), not Choice 4 (p=.30; EV=$0.90).
generate byte risk_score = .
replace risk_score = -2 if switching_point<=3
replace risk_score = -1 if switching_point==4
replace risk_score =  0 if switching_point==5
replace risk_score =  1 if switching_point==6
replace risk_score =  2 if switching_point>=7
assert !missing(risk_score)
label define risk_lbl -2 "Strongly risk seeking" -1 "Risk seeking" ///
    0 "Approximately risk neutral" 1 "Moderately risk averse" ///
    2 "More risk averse", replace
label values risk_score risk_lbl

********************************************************************************
* 6. ROUND-SPECIFIC ANALYSIS VARIABLES
********************************************************************************

* Streaks in the realized coin outcomes.
forvalues r=1/4 {
    generate byte Head`r' = 1
    generate byte Tail`r' = 1
    forvalues k=1/`r' {
        replace Head`r' = 0 if Coin`k'!=1
        replace Tail`r' = 0 if Coin`k'!=0
    }
}

* Incorrect bet, prediction following, and log bet amount.
forvalues r=1/5 {
    generate byte madewrongbet`r' = (Bet`r'!=Coin`r')
    generate byte betsame`r' = (Bet`r'==Pdt`r')
    assert BetAmount`r'>0
    generate double lgbetamount`r' = ln(BetAmount`r')
}

* Fixed direction across all five bets. Retained only for legacy audit models;
* it must not be used as a control in primary causal analyses.
generate byte fixedbetting = ///
    (Bet1==1 & Bet2==1 & Bet3==1 & Bet4==1 & Bet5==1) | ///
    (Bet1==0 & Bet2==0 & Bet3==0 & Bet4==0 & Bet5==0)

* Consistent gambler-history coding: 0=mixed, 1=head streak, 2=tail streak.
forvalues r=1/4 {
    generate byte gambler`r' = 0
    replace gambler`r' = 1 if Head`r'==1
    replace gambler`r' = 2 if Tail`r'==1
}
label define gambler_lbl 0 "Mixed outcomes" 1 "Streak of heads" ///
    2 "Streak of tails", replace
label values gambler1-gambler4 gambler_lbl

encode Session, generate(session)
label variable session "Numeric session identifier"

********************************************************************************
* 7. LIMITED TEXT/DEMOGRAPHIC CLEANING
*
* Preserve raw responses. The main analysis does not use school, ethnicity, or
* open-text reason categories, so no broad or order-dependent recoding is used.
********************************************************************************

capture confirm string variable School
if !_rc replace School = strtrim(itrim(School))
capture confirm string variable Ethnicity
if !_rc replace Ethnicity = strtrim(itrim(Ethnicity))

capture confirm string variable PayingReason
if !_rc {
    generate str80 PayingReason1 = ""
    replace PayingReason1 = "Curiosity/check prediction" ///
        if regexm(lower(PayingReason),"curious|curiosity|see if|correlation|authentic")
    replace PayingReason1 = "Delegate decision making" ///
        if PayingReason1=="" & ///
        regexm(lower(PayingReason),"guide|confidence|safer|secure|reaffirm|by myself")
    replace PayingReason1 = "Cold-hand reasoning" ///
        if PayingReason1=="" & regexm(lower(PayingReason),"opposit")
    replace PayingReason1 = "Hot-hand reasoning" ///
        if PayingReason1=="" & ///
        regexm(lower(PayingReason),"rounds? (is|were|was)? ?correct|predictions? (is|were|was)? ?correct")
    replace PayingReason1 = "Fun" ///
        if PayingReason1=="" & regexm(lower(PayingReason),"fun")
    replace PayingReason1 = "Understand the prediction process" ///
        if PayingReason1=="" & regexm(lower(PayingReason),"understand")
    replace PayingReason1 = "Expected useful information" ///
        if PayingReason1=="" & regexm(lower(PayingReason),"hint|accurate")
}

* Remove z-Tree/interface variables not needed in the replication dataset.
capture drop A1-A10 CorrectA* height width NQNS i temp1 temp2 store1 store2

********************************************************************************
* 8. FINAL VALIDATION AND SAVE
********************************************************************************

local analysis_required Agent InformationLevel Session treat Decision1 ///
    Decision2 Decision3 Decision4 Decision5 StreakTreat_R2 ///
    StreakTreat_R3 StreakTreat_R4 StreakTreat_R5 ///
    Pdc_Correct1 Pdc_Correct2 Pdc_Correct3 Pdc_Correct4 Pdc_Correct5 ///
    Pdt1 Pdt2 Pdt3 Pdt4 Pdt5 Coin1 Coin2 Coin3 Coin4 Coin5 ///
    Bet1 Bet2 Bet3 Bet4 Bet5 BetAmount1 BetAmount2 BetAmount3 ///
    BetAmount4 BetAmount5 betsame1 betsame2 betsame3 betsame4 betsame5 ///
    lgbetamount1 lgbetamount2 lgbetamount3 lgbetamount4 lgbetamount5 ///
    Head1 Head2 Head3 Head4 Tail1 Tail2 Tail3 Tail4 Gender Age ///
    statistics_score karma authority iu risk_score session

foreach v in `analysis_required' {
    capture confirm variable `v'
    if _rc {
        display as error "Analysis variable `v' was not created."
        exit 111
    }
}

assert _N==750
compress
order Agent InformationLevel treat Pdc_Correct1-Pdc_Correct5 ///
    Pdt1-Pdt5 Coin1-Coin5 Decision1-Decision5

save AllSession_aftercleaning_final.dta, replace
display as result ///
    "2Cleaning.do completed: AllSession_aftercleaning_final.dta created."
display as result ///
    "The data are ready for 4Analysis_JoEP_reframed.do."

********************************************************************************
* END OF FILE
********************************************************************************
