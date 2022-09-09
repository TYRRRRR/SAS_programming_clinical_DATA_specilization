**** INPUT SAMPLE NORMALIZED SYSTOLIC BLOOD PRESSURE VALUES.
**** SUBJECT = PATIENT NUMBER, VISIT = VISIT NUMBER,
**** SBP = SYSTOLIC BLOOD PRESSURE.;
data sbp;
input subject $ visit sbp;
datalines;
101 1 160
101 3 140
101 4 130
101 5 120
202 1 141
202 3 161
202 4 171
202 5 181
;
run;

**** SORT SBP VALUES BY SUBJECT.;
proc sort
data = sbp;
by subject;
run;
**** TRANSPOSE THE NORMALIZED SBP VALUES TO A FLAT STRUCTURE.;
data sbpflat;
set sbp;
by subject;
keep subject visit1-visit5;
retain visit1-visit5;
**** DEFINE ARRAY TO HOLD SBP VALUES FOR 5 VISITS.;
array sbps {5} visit1-visit5;
**** AT FIRST SUBJECT, INITIALIZE ARRAY TO MISSING.;
if first.subject then
do i = 1 to 5;
sbps{i} = .;
end;
*** AT EACH VISIT LOAD THE SBP VALUE INTO THE PROPER SLOT
**** IN THE ARRAY.;
sbps{visit} = sbp;

**** KEEP THE LAST OBSERVATION PER SUBJECT WITH 5 SBPS.;
if last.subject;
run;