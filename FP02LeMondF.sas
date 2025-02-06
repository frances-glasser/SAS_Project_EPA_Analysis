*Frances LeMond, Final Project Part 2 "Reporting Results";
dm 'log; clear;';
ods trace on; 

*connect to library with dataset;
x 'cd L:\st445\Results\FinalProjectPhase1';
libname InputDS ".";

x 'cd S:\Final';
libname Final ".";

*macro variables; 
%let IdStamp = Output created by &SysUserID on &SysDate9 using &SysVLong;
%let TitleOpts = BOLD h=14pt;
%let SubTitleOpts = h=10pt;
%let FootOpts = ITALIC j=left h=8pt;

*Creation of PDF File;
ods noproctitle;
ods options nodate;
ods pdf file = "Final LeMond EPA TRI Preliminary Analysis.pdf" style= sapphire dpi=300 columns =2; *width=6in not necessary;

*___OUTPUT 1________________________________________________________;
title1 &subtitleopts "Output 1";
title2 &titleopts "Listing of Incidents Reported via Form R";
title3 &subtitleopts "Partial Output - Max of 25 Records for Federal Flag = Yes/No";
footnote &footopts "&IDSTAMP";

Proc Print data = InputDS.FP01DugginsTRI (obs=25) LABEL NOOBS;
	var Class HazAirFL CarcFL PFASFL;
	where FormType = "R" AND FederalFL = 'YES';
run;

Proc Print data = InputDS.FP01DugginsTRI (obs=25) LABEL NOOBS;
	var Class HazAirFL CarcFL PFASFL;
	where FormType = "R" AND FederalFL = 'NO';
run;
title;
footnote;

*__OUTPUT 2_______________________________________________________;
title1 &subtitleopts "Output 2";
title2 &titleopts "Selected Summary Statistics of Total Air Pollution and Total Steam Discharge";
footnote &footopts "&IDSTAMP";
ods select AirTotal.Moments AirTotal.basicmeasures DischargeTotal.Moments DischargeTotal.basicmeasures DischargeTotal.MissingValues;
Proc Univariate data = InputDS.FP01DugginsTRI;
	var AirTotal DischargeTotal;
run;
title;
footnote;

ods pdf columns=1;
*____OUTPUT 3________________________________________________________;
title1 &subtitleopts "Output 3";
title2 &titleopts "Frequency-Ordered Summary of Facility Locations (State)";
title3 &subtitleopts "Only Unique Locations Included";
footnote &footopts "&IDSTAMP";
PROC FREQ data = InputDS.fp01dugginsfacilities order= freq;
	table Facstate;
run;
title;
footnote;

*__OUTPUT 4____________________________________________________;
title1 &subtitleopts "Output 4";
title2 &titleopts "Frequency-Ordered Summary of Facility Locations (State)";
footnote &footopts "&IDSTAMP";
PROC FREQ data = InputDS.FP01DugginsTRI order = freq;
	table Facstate;
run;
title;
footnote;

ods pdf startpage = never;
*___OUTPUT 5______________________________________________________;
title1 &subtitleopts "Output 5";
title2 &titleopts "Frequency of Air Status for Each Chemical Classification";
footnote &footopts "&IDSTAMP";
proc SGPLOT data = InputDS.fp01dugginsclassbyhazair;
	styleattrs datacolors = (cxf6eff7 cxbdc9e1 cx67a9cf cx1c9099 cx016c59);
	vbar class / barwidth = 0.5 group = HazAirFL groupdisplay= stack response = rowpercent NOOUTLINE;
	keylegend / location = inside position = topright across = 1 opaque title= 'Hazard Air'; *used https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0xmbppzx71smbn1203aaif96z86.htm to find 'opaque'option;
	xaxis label = 'Chemical Compund Classification';
	yaxis label = '% of Compound Classification' grid values = (0 to 100 by 10);
run;
title;
footnote;

*__OUTPUT 6_______________________________________________________;
title1 &subtitleopts "Output 6";
title2 &titleopts "Frequency of Chemical Classification within Air Hazard Status";
footnote &footopts "&IDSTAMP";
proc SGPLOT data = InputDS.fp01dugginsclassbyhazair;
	 styleattrs datacolors = (cxf6eff7 cxbdc9e1 cx67a9cf cx1c9099 cx016c59);
	 hbar HazAirFL / group = class groupdisplay= cluster response=colpercent NOOUTLINE 
					 DATALABELFITPOLICY=NONE DATALABEL datalabelattrs=(size=14pt color=grey); *used https://blogs.sas.com/content/sgf/2017/09/15/proc-sgplot-theres-an-attrs-for-that/ to find out more about datalabelattrs;
	 keylegend / location = inside position = bottomright across = 1 opaque Title= 'Classification';
	 xaxis label = '% of Air Hazard Status' grid values = (0 to 100 by 10) max = 100; * used https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/n0n6uml63c6h8dn16phbd1arm9g9.htm to learn more about values and max displays in axis;
	 yaxis label = 'Air HAzard Status';
run;
title;
footnote;

*____OUTPUT 7______________________________________________________;
title1 &subtitleopts "Output 7";
title2 &titleopts "Comparative Boxplots for Air Pollution";
title3 &subtitleopts "For Mid-Atlantic* and Reference* States";
footnote1 &footopts "&IDSTAMP";
footnote2 &footopts "Mid-Atlantic: MD, VA, NC, SC";
footnote3 &footopts "Reference: CA, OH, NY, TX";
proc SGPLOT data = InputDS.FP01DugginsTRI;
	where facstate = 'MD' OR facstate ='VA' OR facstate ='NC' OR facstate ='SC' OR facstate ='CA' OR facstate ='OH' OR facstate ='NY' OR facstate ='TX';
	vbox airtotal / group= facstate grouporder=ascending; *used https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/n1waawwbez01ppn15dn9ehmxzihf.htm to learn about group order;
	keylegend / location = inside position = topleft across = 1 opaque title='State';
	yaxis label = 'Total Air pollution' max = 5300000;
run;
title;
footnote;

ods startpage=now;
*___OUTPUT 8______________________________________________________;
title1 &subtitleopts "Output 8";
title2 &titleopts "Analysis of Air Pollution and Stream Discharge";
title3 &subtitleopts "Limited to Chemicals Classified as PBT";
title4 &subtitleopts "Excluding 2020";
footnote1 &footopts "&IDSTAMP";
proc Report data = InputDS.FP01DugginsTRI nowd;
	where ReportYear ne 2020 AND Class= 'PBT';
	column ReportYear HazAirFL CarcFL (AirTotal DischargeTotal), (Mean Std N); *used this link to learn more about multiple statisitcs for a single colum: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/proc/n0pvcjm1isi9q9n1pxziic5aq3fz.htm#n0pvcjm1isi9q9n1pxziic5aq3fz;
	define ReportYear / group descending 'Report Year';
	break after ReportYear/ summarize;
	define HazAirFL / group 'HazAir';
	define CarcFL / group 'Carc';
	*Analyze Var of Interest;
	define AirTotal / analysis 'Air Pollution';
	define DischargeTotal / analysis 'Stream Discharge';
	*Make stats pretty;
	define N / format = comma10. "Count";
	define Std / format = 10.2 "Std. Dev.";
	define Mean / format = 10.1 "Mean";
run;
title;
footnote;

*___OUTPUT 9________________________________________________________;
title1 &subtitleopts "Output 9";
title2 &titleopts "Analysis of Air Pollution and Stream Discharge";
title3 &subtitleopts "Limited to Chemicals Classified as PBT";
footnote1 &footopts "&IDSTAMP";
footnote2 &footopts "Alternative Display: Air Hazard displays on all non-summary rows";
proc Report data = InputDS.FP01DugginsTRI nowd;
	where ReportYear ne 2020 AND Class= 'PBT';
	column ReportYear HazAirFL CarcFL (AirTotal DischargeTotal), (Mean Std N);
	define ReportYear / group descending 'Report Year';
	break after ReportYear/ summarize;
	define HazAirFL / group 'HazAir'; * NOT DUMMY;
	*define HazAir_dummy / computed; *DUMMY;
	define CarcFL / group 'Carc';
	*Analyze Var of Interest;
	define AirTotal / analysis 'Air Pollution';
	define DischargeTotal / analysis 'Stream Discharge';
	*Make stats pretty;
	define N / format = comma10. "Count";
	define Std / format = 10.2 "Std. Dev.";
	define Mean / format = 10.1 "Mean";

/*	compute HazAirFL_dummy;*/
/*		Hazair_dummy = HazAirFL;*/
/*	endcomp;*/
run;
title;
footnote;

*___FORMATTING;
proc format library=final;
	value fmtA
	0  = "cxFF0000"
	1  <- 25 = "cxeff3ff"
	25 <- 50 = "cxbdd7e7"
	50 <- 100 = "cx6baed6"
	100 <- high = "cx2171b5";
	value fmtB
	0 = "cxFF0000"
	1  <- 25 = "cxfeedde"
	25 <- 50 = "cxfdbe85"
	50 <- 100 = "cxfd8d3c"
	100 <- high = "cxd94701";
run;

*______OUTPUT 10__________________________________________;
title1 &subtitleopts "Output 10";
title2 &titleopts "Color-Coded Analysis of Air Pollution and Stream Discharge";
title3 &subtitleopts "Limited to Chemicals Classified as PBT";
footnote1 &footopts "&IDSTAMP";
footnote2 &footopts "Alternative Display: Air Hazard displays on all non-summary rows";
proc Report data = InputDS.FP01DugginsTRI nowd;
	where ReportYear ne 2020 AND Class= 'PBT';
	column ReportYear HazAirFL CarcFL (AirTotal DischargeTotal), (Mean Std N) air_mean; 
	define air_mean / computed noprint;
	define ReportYear / group descending 'Report Year';
	break after ReportYear/ summarize style=[backgroundcolor=greyD3];
	define HazAirFL / group 'HazAir';
	define CarcFL / group 'Carc';
	*Analyze Var of Interest;
	define AirTotal / analysis 'Air Pollution' style=[background=fmtA.];
	define DischargeTotal / analysis 'Stream Discharge';
	*Make stats pretty;
	define N / format = comma10. "Count";
	define Std / format = 10.2 "Std. Dev.";
	define Mean / format = 10.1 "Mean";
	*conditional coloring;
	compute air_mean;
		air_mean = airtotal.mean;
		if _break_ = '' then do;
			if air_mean = 0 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxFF0000]');
			else if air_mean <25 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxeff3ff]');
			else if 25<= air_mean <50 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxbdd7e7]');
			else if 50<= air_mean <100 then call define ('_c4_','style','style = [backgroundcolor=cx6baed6]');
			else if air_mean >100 then call define ('_c4_','style','style = [backgroundcolor=cx2171b5]');
		end;
	endcomp;
	compute after / style=[color=cxFFFFFF backgroundcolor= cx000000 just=right];
		line 'Air Pollutant Color-Coding:0, <25, 25-50, 50-100, >100';
	endcomp;
run;
title;
footnote;

*___________________OUTPUT 11_____________________________________;
title1 &subtitleopts "Output 11";
title2 &titleopts "Color-Coded* Analysis of Air Pollution and Stream Discharge";
title3 &subtitleopts "Limited to Chemicals Classified as PBT";
footnote1 &footopts "&IDSTAMP";
footnote2 &footopts "Alternative Display: Air Hazard displays on all non-summary rows";
footnote3 &footopts "Rows with CarcFL=Y and CarcFL=N use their respective cutoffs. Summary rows use CarcFL=N cutoffs";
proc Report data = InputDS.FP01DugginsTRI nowd;
	where ReportYear ne 2020 AND Class= 'PBT';
	column ReportYear HazAirFL CarcFL (AirTotal DischargeTotal), (Mean Std N) air_mean;
	define air_mean / computed noprint;
	define ReportYear / group descending 'Report Year';
	break after ReportYear/ summarize style=[backgroundcolor=greyD3];
	define HazAirFL / group 'HazAir';
	define CarcFL / group 'Carc';
	*Analyze Var of Interest;
	define AirTotal / analysis 'Air Pollution';
	define DischargeTotal / analysis 'Stream Discharge';
	*Make stats pretty;
	define N / format = comma10. "Count";
	define Std / format = 10.2 "Std. Dev.";
	define Mean / format = 10.1 "Mean";
	*conditional coloring;
	compute air_mean;
		air_mean = AirTotal.mean;
		if _break_ = '' AND CarcFL = 'YES' then do;
			if air_mean = 0 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxFF0000]');
			else if air_mean <25 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxfeedde]');
			else if 25<= air_mean <50 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxbdd7e7]');
			else if 50<= air_mean <100 then call define ('_c4_','style','style = [backgroundcolor=cx6baed6]');
			else if air_mean >100 then call define ('_c4_','style','style = [backgroundcolor=cx2171b5]');
		end;
		if _break_ = '' AND CarcFL = 'NO' then do;
			if air_mean = 0 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxFF0000]');
			else if air_mean <25 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxeff3ff]');
			else if 25<= air_mean <50 then call define ('_c4_', 'style', 'style=[backgroundcolor=cxfdbe85]');
			else if 50<= air_mean <100 then call define ('_c4_','style','style = [backgroundcolor=cxfd8d3c]');
			else if air_mean >100 then call define ('_c4_','style','style = [backgroundcolor=cxd94701]');
		end;
	endcomp;
	compute after / style=[color=cxFFFFFF backgroundcolor= cx000000 just=right];
		line 'CarcFL=N coloring:0, <25, 25-50, 50-100, >100';
		line 'CarcFL=Y coloring:0, <40, 40-80, 80-100, >100';
	endcomp;
run;
title;
footnote;

*Conclusion Code;
ods pdf close;
quit;
