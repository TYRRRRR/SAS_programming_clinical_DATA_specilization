**** This is the code for LOCF, using sample data
**** SUBJECT = PATIENT NUMBER, SAMPDATE = LAB SAMPLE DATE,
**** HDL = HDL, LDL = LDL, AND TRIG = TRIGLYCERIDES.;
data chol;
input subject $ sampdate date9. hdl ldl trig;
datalines;
101 05SEP2003 48 188 108
101 06SEP2003 49 185 .
102 01OCT2003 54 200 350
102 02OCT2003 52 . 360
103 10NOV2003 . 240 900
103 11NOV2003 30 . 880
103 12NOV2003 32 . .
103 13NOV2003 35 289 930
;
run;

**** INPUT SAMPLE PILL DOSING DATA.
**** SUBJECT = PATIENT NUMBER, DOSEDATE = DRUG DOSING DATE.;
data dosing;
input subject $ dosedate date9.;
datalines;
101 07SEP2003
102 07OCT2003
103 13NOV2003
;
run;

**** Sort the data before merge.;
proc sort data = chol;
by subject sampdate;
run;

proc sort data = dosing;
by subject;
run;

**** define baseline, HDL, LDL, and trig variables;
data baseline;
merge chol dosing; 
by subject;
/*keep the column we need*/
keep subject b_hdl b_ldl b_trig;
/*set up arrays for data manipulation*/
array base {3} b_hdl b_ldl b_trig;
array chol {3} hdl ldl trig;
/*Retain new baseline*/
retain b_hdl b_ldl b_trig;
/*Initialize baseline to missing*/
if first.subect then 
do i = 1 to 3;
base{i} = .;
end;

**** IF LAB VALUE IS WITHIN 5 DAYS OF DOSING, RETAIN IT AS
**** A VALID BASELINE VALUE.;
if 1 <= (dosedate - sampdate) <= 5 then
do i = 1 to 3;
if chol{i} ne . then
base{i} = chol{i};
end;
**** KEEP LAST RECORD PER PATIENT HOLDING THE LOCF VALUES.;
if last.subject;
run;