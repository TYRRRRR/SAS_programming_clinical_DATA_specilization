**** INPUT SAMPLE BLOOD PRESSURE VALUES WHERE
**** SUBJECT = PATIENT NUMBER, WEEK = WEEK OF STUDY, AND
**** TEST = SYSTOLIC (SBP) OR DIASTOLIC (DBP) BLOOD PRESSURE.;
data bp;
input subject $ week test $ value;
datalines;
101 0 DBP 160
101 0 SBP 90
101 1 DBP 140
101 1 SBP 87
101 2 DBP 130
101 2 SBP 85
101 3 DBP 120
101 3 SBP 80
202 0 DBP 141
202 0 SBP 75
202 1 DBP 161
202 1 SBP 80
202 2 DBP 171
202 2 SBP 85
202 3 DBP 181
202 3 SBP 90
;
run;

**** SORT DATA BY SUBJECT, TEST NAME, AND WEEK;
proc sort
data = bp;
by subject test week;
run;

**** CALCULATE CHANGE FROM BASELINE SBP AND DBP VALUES.;
data bp;
set bp;
by subject test week;
**** CARRY FORWARD BASELINE RESULTS.;
retain baseline;
if first.test then
baseline = .;

**** DETERMINE BASELINE OR CALCULATE CHANGES.;
if visit = 0 then
baseline = value;
else if visit > 0 then
do;
change = value - baseline;
pct_chg = ((value - baseline) /baseline )*100;
end;
run;
proc print
data = bp;
run;