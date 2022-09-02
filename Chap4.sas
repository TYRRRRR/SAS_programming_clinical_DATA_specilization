/*read data from the path of dataset*/
Data dat;
infile "Your data path/DBP.csv" delimiter="," firstobs=2;
input Subject TRT$ DBP1 DBP2 DBP3 DBP4 DBP5 Age Sex$;
/*create a column diff*/
diff= DBP5-DBP1; RUN;

/***********************************************
Section 4.3.1.1
************************************************/
/*test whether the DBP means are different*/
PROC TTEST data= dat;
title "Two sample two sided t-test";
class Trt;
var DBP1; RUN;
/*make 2 by 2 table using variable "Sex"*/
PROC FREQ data= dat;
tables Trt*Sex / out= freqs ; RUN;
PROC TRANSPOSE data= freqs out= SexbyTrt(drop=_:);
id Sex;
var count;
by Trt;
RUN;

/*print the table*/
PROC PRINT data= SexbyTrt; RUN;
/*test equality of proportions of 2 treatment groups
using Pearson's Chi squares*/
PROC FREQ data= freqs;
weight count;
tables Trt*Sex/ chisq; RUN;

PROC GLM data= dat;
class Sex(ref="F");
model DBP1= Sex Age / solution;
RUN;

/*stepwise model selection */
PROC GLMSELECT data= dat;
class Trt Sex;
model diff= Trt|Sex|Age
/ selection= stepwise(select= AIC) stats= all;
RUN;

/*fit the reduced model*/
PROC GLM data= dat;
class TRT(ref="A");
model diff= Age Trt / solution;
RUN;

/******************************
Section 4.3.1.3: MACNOVA for Treatment Difference
*************************************/
/* create the data*/
data mdat;
set dat;
diff2to1 = DBP2-DBP1;
diff3to1 = DBP3-DBP1;
diff4to1 = DBP4-DBP1;
diff5to1 = DBP5-DBP1;
run;
/* manova using glm*/
PROC glm data= mdat;
class TRT;
model diff2to1 diff3to1 diff4to1 diff5to1= TRT Age/ss3;
contrast '1 vs 2' TRT 1 -1;
manova h=_all_;
RUN;