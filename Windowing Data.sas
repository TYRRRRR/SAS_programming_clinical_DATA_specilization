**** INPUT SAMPLE LAB DATA.
**** SUBJECT = PATIENT NUMBER, LAB_TEST = LABORATORY TEST NAME,
**** LAB_DATE = LAB COLLECTION DATE, LAB_RESULT = LAB VALUE.;
data labs;
input subject $ lab_test $ lab_date lab_result;
datalines;
101 HGB 999 1.0
101 HGB 1000 1.1
101 HGB 1011 1.2
101 HGB 1029 1.3
101 HGB 1030 1.4
101 HGB 1031 1.5
101 HGB 1058 1.6
101 HGB 1064 1.7
101 HGB 1725 1.8
101 HGB 1735 1.9
;
run;

**** INPUT SAMPLE DOSING DATE.
**** SUBJECT = PATIENT NUMBER, DOSE_DATE = DATE OF DOSING.;
data dosing;
input subject $ dose_date;
datalines;
101 1001
;
run;
**** SORT LAB DATA FOR MERGE WITH DOSING;
proc sort
data = labs;
by subject;
run;
**** SORT DOSING DATA FOR MERGE WITH LABS.;
proc sort
data = dosing;
by subject;
run;
**** MERGE LAB DATA WITH DOSING DATE. CALCULATE STUDY DAY AND
**** DEFINE VISIT WINDOWS BASED ON STUDY DAY.;
data labs;
merge labs(in = inlab)
dosing(keep = subject dose_date);
by subject;
**** KEEP RECORD IF IN LAB AND RESULT IS NOT MISSING.;
if inlab and lab_result ne .;
**** CALCULATE STUDY DAY.;
if lab_date < dose_date then
study_day = lab_date - dose_date;
else if lab_date >= dose_date then
study_day = lab_date - dose_date + 1;
**** SET VISIT WINDOWS AND TARGET DAY AS THE MIDDLE OF THE
**** WINDOW.;
if . < study_day < 0 then
target = 0;
else if 25 <= study_day <= 35 then
target = 30;
else if 55 <= study_day <= 65 then
target = 60;
else if 350 <= study_day <= 380 then
target = 365;

else if 715 <= study_day <= 745 then
target = 730;
**** CALCULATE OBSERVATION DISTANCE FROM TARGET AND
**** ABSOLUTE VALUE OF THAT DIFFERENCE.;
difference = study_day - target;
absdifference = abs(difference);
run;
**** SORT DATA BY DECREASING ABSOLUTE DIFFERENCE AND ACTUAL
**** DIFFERENCE WITHIN A VISIT WINDOW.;
proc sort
data=labs;
by subject lab_test target absdifference difference;
run;
**** SELECT THE RECORD CLOSEST TO THE TARGET AS THE VISIT.
**** CHOOSE THE EARLIER OF THE TWO OBSERVATIONS IN THE EVENT OF
**** A TIE ON BOTH SIDES OF THE TARGET.;
data labs;
set labs;
by subject lab_test target absdifference difference;
if first.target and target ne . then
visit_number = target;
run;