title "Distribution of Blood Types";
pattern value=empty;
proc gchart data=learn.blood;
vbar BloodType;
run;
quit;


title "Creating a Pie Chart";
pattern value=pempty;
proc gchart data=learn.blood;
pie BloodType / noheading;
run;
quit;