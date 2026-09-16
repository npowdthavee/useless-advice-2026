# Useless advice: 2026 replication files

Analysis code and cleaned data for the experiment by Nattavudh Powdthavee, Yohanes E. Riyanto and Xiaojie Zhang on demand for uninformative coin-toss predictions, disclosure and charitable giving.

The experiment contains 750 participants across 39 sessions. Participants bet on five fair coin tosses. The four conditions cross purchase versus donation with no information versus full disclosure of the random prediction process.

## Files

| File | Purpose |
| --- | --- |
| `AllSession_aftercleaning_final.csv` | Cleaned participant-level analysis data: 750 rows, 140 columns. |
| `data_dictionary.csv` | Original Stata variable labels and value-label mappings. The analysis CSV contains numeric codes, not value-label text. |
| `4Analysis_JoEP_reframed.do` | Main analysis: design checks, Round 1, round-specific hypotheses, Holm adjustments, pooled models, prediction use, and exploratory analyses. |
| `H4_verification.do` | Corrected H4, registered-form reconstruction, equal-session-weighted Round 1, and pooled sensitivity checks. |
| `1Append.do` | Original session-data import and append stage. Requires the raw session Excel files and `ztree2stata`. |
| `2Cleaning.do` | Original cleaning stage; creates `AllSession_aftercleaning_final.dta`. Requires the appended data and allocation workbook used by the original pipeline. |

## Run the analysis

Use Stata 17 or later. Download the repository, change Stata's working directory to the downloaded folder, and run:

```stata
cd "/path/to/useless-advice-2026"
do 4Analysis_JoEP_reframed.do
do H4_verification.do "AllSession_aftercleaning_final.csv" "."
```

The main script defaults to the supplied CSV and writes outputs into the working directory. Both analysis scripts also accept a cleaned `.dta` input. To use an existing output directory:

```stata
do 4Analysis_JoEP_reframed.do "AllSession_aftercleaning_final.csv" "/path/to/output"
do H4_verification.do "AllSession_aftercleaning_final.csv" "/path/to/output"
```

For wild-cluster-bootstrap checks, install `boottest` once:

```stata
ssc install boottest
```

Without `boottest`, the scripts run cluster-robust tests but skip bootstrap tests. Main outputs include CSV estimates, saved Stata results, PNG figures, and text logs. Outputs retain the earlier `JoEP` naming for compatibility; this is not a statement about publication status. Output files are overwritten on reruns.

The public cleaned CSV allows analysis without rerunning preprocessing. The 39 raw `.xls` session files and `table_assign_2024.xlsx` are not included. With those original inputs available, run `1Append.do` and then `2Cleaning.do` from the input folder, or pass that folder as their first argument. The older `3Analysis.do` is not required.

## Data and coding

One row represents one participant. `Session` retains anonymous experimental-session labels for clustered inference. `Agent`: 1 = purchase, 2 = donation. `InformationLevel`: 1 = no information, 2 = full information. `Decision1`–`Decision5`: 0 = no acquisition, 1 = acquisition. `StreakTreat_R2`–`StreakTreat_R5`: 1 = mixed, 2 = all correct, 3 = all incorrect; Round 2 has no mixed history. Empty numeric cells represent missing values. Consult the data dictionary for other codes.

The CSV was exported from the complete cleaned Stata dataset used in the manuscript checks. Numeric values and missingness were checked against that source. Participant/client labels, ethnicity, school, free-text responses and redundant merge/session variables were omitted from this public analysis export. Required analysis variables and session grouping are retained. The CSV does not preserve Stata display formats or embedded labels; labels are supplied separately.

## Interpretation and September 2026 correction

Treatment assignment is at the session level, so principal inference clusters by session. Round 1 is exploratory. Acquiring a prediction is chosen; comparisons of prediction use and bet size by acquisition status are descriptive.

H4 is the disclosure effect under donation minus the disclosure effect under purchase, evaluated **after success**. In the round-specific saturated model, it is the sum of the donation-by-information coefficient and the donation-by-information-by-success coefficient. The three-way coefficient alone tests a different contrast concerning history responsiveness. The main script now tests the corrected H4 and reports the three-way contrast separately. Earlier H4 output files must not be treated as corrected results or have their bootstrap p-values relabelled.

The separate verification script also reconstructs a restricted-sample registered-form specification. It documents the sign inconsistency and the included controls; it is a sensitivity analysis, not a claim of exact replication of an unspecified control vector.

## Verification and AI assistance

The CSV round-trip, sample size, session count and Round 1 treatment-cell rates were checked in Python. The updated Stata scripts were inspected but have not been executed in this environment, where Stata is unavailable. In particular, corrected H4 bootstrap results require a Stata run with `boottest` before being used in the manuscript.

OpenAI's ChatGPT assisted with manuscript prose and writing/debugging Stata code. Responsibility for reviewing the text, code and statistical results remains with the authors.
