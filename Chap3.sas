Data dat;
/*read data from the path of dataset*/
infile "Your file path/DBP.csv" delimiter="," firstobs=2;
input Subject TRT$ DBP1 DBP2 DBP3 DBP4 DBP5 Age Sex$;
/*create a column "diff"*/
diff= DBP5-DBP1;
RUN;

/*show the first 6 observations using proc print*/
PROC PRINT data=dat(obs=6); RUN;

/*Section 3.3.1.2*/
/*call two-side t-test with equal variance*/
PROC TTEST data=dat sides=2 alpha=0.05 h0=0;
/*specifies the title line of result*/
title "Two sample two side t-test";
/*defines the grouping variable*/
class TRT;
/*variable whose means will be compared*/
var diff;
RUN;

/*welch t-test with unequal variance*/
/*check the lines labeled "Satterthwaite" from above results*/
/*test the null hypothesis for equal variance*/
/*check the table named "Equality of Variance" from above
results*/
/*nonparametric t-test(Wilcoxon rank-sum test)*/
PROC NPAR1WAY wilcoxon data=dat;
title "Wilcoxon rank-sum test";
class TRT;
var diff;
exact wilcoxon; /*request for exact p-value*/

/*call one-side t-test */
/*alternative hypothesis: means(A)<means(B)*/
PROC TTEST data=dat sides=L alpha=0.05 h0=0;
title "Two sample one-side t-test";
class TRT;
var diff;
RUN;

/*bootstrap method*/
/*call bootstrap with 1000 replication*/
PROC SURVEYSELECT data=dat out=boot_samples seed=123
/* specify the type of random sampling */
method=urs
/* get a sample of the same size as original dataset */
samprate=1
/*give the times a record chosen*/
outhits /
* specify the number of bootstrap samples */
rep=1000;
/*bootstrapping by TRT without overlap*/
strata TRT / alloc = proportional;
RUN;

PROC MEANS data=boot_samples mean;
var diff;
class Replicate TRT;
/*output the results*/
output out=temp1(where=(_type_=3) drop= _freq_) Mean=mean;
RUN;

PROC TRANSPOSE data=temp1(drop=_type_) out=temp2(drop=_:);
id Trt;
var Mean;
by Replicate; RUN;

Data boot_diff;
set temp2;
mean_diff=A-B;
drop A B; RUN;

means time/ tukey cldiff; RUN;
/*test treatment "B"*/
DATA datB(where=(TRT='B'));
set Dat_L; RUN;
PROC ANOVA data= datB;
title "one-way ANOVA to test treatment 'B'";
class time;
model DBP= time;
means time / tukey cldiff; RUN;
/*determines the times at which DBP means are significantly
different*/
/*check the result from table named
"Tukey's Studentized Range (HSD) Test for DBP"*/
/*Section 3.3.1.5*/
/*two-way anova test the significance of interaction using glm*/
PROC GLM data= Dat_L;
title "two-way ANOVA test using glm";
class TRT time;
model DBP= TRT time TRT*time;
lsmeans TRT time TRT*time/ pdiff adjust= tukey;
RUN;

