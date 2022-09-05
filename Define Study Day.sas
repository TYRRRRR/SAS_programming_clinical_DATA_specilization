**** Calculating a Continuous Study Day.;

study_day = event_date - intervention_date + 1;

**** Calculating a Study Day without Day Zero.;

if event_date < intervention_date then
study_day = event_date – intervention_date;
else if event_date >= intervention_date then
study_day = event_date – intervention_date + 1;