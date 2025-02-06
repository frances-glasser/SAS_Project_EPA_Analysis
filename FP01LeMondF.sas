*Frances LeMond Glasser, 
FINAL Fall 2024, 
Dr.Duggins Class ST 445;

dm 'log; clear;'; *Clearing the log so I only view the previous code's warnngs and errors;
ods trace on; *this allows me to view what is being put in the output via the log;
ods listing close; *closes output; 

x "cd L:\st445\Data\EPA TRI";
filename RawData "RawData"; * For RAW datasets, in this case text;
libname fmt "FormatCatalogs";

x "cd L:\st445\Data\EPA TRI\StructuredData";
libname SasData "."; * For SAS datasets, in this case text;

x "cd L:\st445\results";
libname Results "."; *results library with final data and reports;

x "cd S:\Final"; * Drive/Folder path;
libname final "."; *creating final folder libref;

*DATA #1--Data Step to bring in the Event Report 2023 Dataset;
DATA final.events;
attrib DateSigned format = yymmdd10.;
infile rawdata ("EventReports2023.txt");
input DateSigned yymmdd10.  NAICS $11-16 
	  CASNum $17-31         FormType $32       TRIFID $33-47
	  EntireFL $48-50       FederalFL $51-53   ControlNum $54-68 
	  ElementalFL $69-71    Class $72-77       Units $78-83 
	  HazAirFL $84-86       CarcFL $87-89      PfasFL $90-92 
	  MetalFL $93-95         FugAirTotal 96-125 StackAirTotal 126-155;
Run;

*DATA #2--Data Step to bring in the Facility Demographics 2023 Dataset;
DATA final.facility;
length TRIFID $15 FacName $75 FacStreet $100 FacCity $25 FacState $2 FacZip $9 FacCounty $50 BIAID $3 TribeName $100;
infile rawdata ("FacilityDemographics2023.txt") dlm ='09'x dsd;
input   TRIFID
	 #2 FacName
	 #3 FacStreet
	 #4 FacCity FacState FacZip
	 #5 FacCounty
	 #6 BIAID TribeName;
run;

*Data #3--Data Step to bring in Stream 2023 Dataset;
DATA final.Stream;
length ControlNum $15;
array stream [9] $75 StreamA StreamB StreamC StreamD StreamE StreamF StreamG StreamH StreamI;
array discharge[9] DischargeA DischargeB DischargeC DischargeD DischargeE DischargeF DischargeG DischargeH DischargeI;
infile rawdata ("StreamsData2023.txt") dlm ='09'x truncover;
input ControlNum $15.;
do i = 1 to 9;
	input stream[i] : $75. discharge[i];
	end;
drop i;
run;

*PROC #1--Sorting Stream + Events by ControlNum in order to match merge by ControlNum;
Proc Sort data = Final.Stream;
 by ControlNum;
run;
*PROC #2;
Proc Sort data = Final.Events;
 by ControlNum;
run;

*DATA #4--Data Step to match merge events and stream dataset;
Data final.eventstream;
merge Final.Events
	  Final.Stream;
by ControlNum;
run;

*PROC #3--Sorting EventStream dataset and facility demographic datasets in order to merge by TRIFID;
Proc Sort data = final.eventstream;
 by TRIFID;
run;

*DATA #5--Data step to right merge the facility information (based on TRIFID) in order to keep multiple observations from the same facility;
*Essentialy, this step is done to copy facility information into each observation with TRIFID by TRIFID number;
Data final.merged;
merge final.facility
	  final.eventstream(in=_inEventStream);
by TRIFID;
if _inEventStream = 1 then output final.merged;
run;

options fmtsearch = (fmt); *retrieve the NAICS format for description;
*DATA #6--Dataset to merge all years of data;
Data final.FP01LeMondFrancesTRI;
 attrib ReportYear label = 'Report Year' 
		TRIFID length = $15 label = 'TRI Federal ID'
		FacName length = $75 label = 'Facility Name' 
		FacStreet length = $100 label = 'Facility Street'
		FacCity length = $25 label = 'Facility City' 
		FacCounty length = $50 label = 'Facility County' 
		FacState length = $2 label = 'Facility State' 
		FacZip length = $9 label = 'Facility ZIP Code'
		BIAID length = $3 label ='Bureau of Indian Affairs (BIA) code indicating the tribal land on which the facility is located' 
		TribeName length = $100 label = 'Name of the tribe on whose land the reporting facility is located' 
		NAICS length = $6 label = ' 6-Digit NAICS Code' 
		NAICSDescription length = $150 label = 'Six-Digit NAICS Description' 
		NAICS2 length = $2 label = '2-Digit NAICS Code' 
		NAICS3 length = $3 label = '3-Digit NAICS Code'
		NAICS4 length = $4 label = '4-Digit NAICS Code'
		NAICS5 length = $5 label = '5-Digit NAICS Code'
		ControlNum length = $15 label = 'Case Control #'
		FormType length = $1 label = 'Reporting Form'
		DateSigned format = YYMMDD10. label = 'Form Signature Date'
		EntireFL length = $3 label = ' Entire Facility Flag'
		FederalFL length = $3 label= 'Federal Facility Flag'
		CASNum length = $15 label = 'Chemical Abstract Service #'
		TRIChemID length = $15 label = 'TRI Chemical ID' 
		ElementalFL length = $3 label = 'Combined Metal Report Flag'
		Class length = $6 label = 'Chemical Classification' 
		Units length = $6 label = 'Units of Measure'
		HazAirFL length = $3 label= 'Hazardous Air Pollutant'
		CarcFL length = $3 label = 'Carcinogen Flag' 
		PFASFL length = $3 label = 'PFAS Flag'  
		MetalFL length= $3 label ='TRI Metal Flag'
		FugAirTotal label = 'Total Fugitive Air Emissions' 
		StackAirTotal label ='Total Stack (Point Source) Air Emissions' 
		AirTotal label= 'Total Air Emissions'
		StreamA length = $75 label = 'Stream A Name'
		StreamB length = $75 label = 'Stream B Name'
		StreamC length = $75 label = 'Stream C Name'
		StreamD length = $75 label = 'Stream D Name'
		StreamE length = $75 label = 'Stream E Name'
		StreamF length = $75 label = 'Stream F Name'
		StreamG length = $75 label = 'Stream G Name'
		StreamH length = $75 label = 'Stream H Name'
		StreamI length = $75 label = 'Stream I Name'
		DischargeA label = 'Stream A Discharge'
		DischargeB label = 'Stream B Discharge'
		DischargeC label = 'Stream C Discharge'
		DischargeD label = 'Stream D Discharge'
		DischargeE label = 'Stream E Discharge'
		DischargeF label = 'Stream F Discharge'
		DischargeG label = 'Stream G Discharge'
		DischargeH label = 'Stream H Discharge'
		DischargeI label = 'Stream I Discharge'
		StreamCount label = '# of Affected Streams'
		DischargeTotal label = 'Total Discharge';
set sasdata.tri2018 (in= _18) sasdata.tri2019 (in=_19) sasdata.tri2020 (in=_20) sasdata.tri2021 (in=_21) sasdata.tri2022 (in=_22) final.merged (in=_23);
*#Creating Report Year Variable;
if _23 then ReportYear = 2023;
else if _22 then ReportYear = 2022;
else if _21 then ReportYear = 2021;
else if _20 then ReportYear = 2020;
else if _19 then ReportYear = 2019;
else if _18 then ReportYear = 2018;
*Creating TRIChemID;
if upcase(CASNum) = 'MIXTURE' then TRIChemID = 'MIXTURE';
else if upcase(CASNum) = 'TRD SECRT' then TRIChemID = 'TRD SECRT';
else if find(CASNum, "N") then TRIChemID = CASNum; * using like, find, and where in if conditionals sas documentation: https://support.sas.com/kb/43/303.html;
else if find(CASNum, '-') then do; *REVIEWING THE USE OF COMPRESS, https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lefunctionsref/n0fcshr0ir3h73n1b845c4aq58hz.htm;
	_casenumber = input(compress(CASNum, '-'), 10.);
	TRIChemID = put(_casenumber, z10.);
	end;
drop _casenumber;
*Creating Air Total varibale;
AirTotal = sum(FugAirTotal, StackAirTotal);
*Creating stream count and discharge count;
array missing[9] StreamA--StreamI;
StreamCount = 9 - (cmiss(of missing[*])); *source: https://blogs.sas.com/content/iml/2012/04/02/count-missing-values-in-observations.html LEARNING WHAT CMISS IS;
*Creating sum of dishcarge from stream pollution;
DischargeTotal = sum(of DischargeA--DischargeI);
*Population the Nvar array to caontain NAICS values;
array narray[4] NAICS2 NAICS3 NAICS4 NAICS5;
if NAICS then do;
	do i=1 to 4;
	narray[i] = substr(NAICS,1,i+1); *https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lefunctionsref/p0uev77ebdwy90n1rsd7hwjd2qc3.htm REVIEWING HOW TO USE SUBSTRING TO EXTRACT CHARACTERS BY POSITION;
	end;
drop i;
end;
*applying format to the NAICS code to produce the description;
NAICSDescription = NAICS;
format NAICSDescription naics.;
run;

*PROC #4 Creating the Facility State and TRIFID Dataset;
proc sort data = final.FP01LeMondFrancesTRI out = final.FP01LeMondFrancesFacilities (keep = TRIFID FacState) nodupkey;
by TRIFID;
run;

ods listing;
ods output CrossTabFreqs = final.FP01LeMondFrancesClassByHazAir (keep = Class HazAirFL _TYPE_ RowPercent ColPercent) ;
*PROC #5 Creating the Frequency Analysis Dataset with Class by HazAirFL;
proc freq data = final.FP01LeMondFrancesTRI;
tables Class*HazAirFL;
run;

Quit;
