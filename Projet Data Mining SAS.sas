/*********************************************************************
+++ 		MISE EN PRATIQUE SUR LA REGRESSION LOGISTIQUE 		  +++
*********************************************************************/


LIBNAME FATIM "C:\Users\SAMS\Desktop\Pratique" ;

PROC DATASETS  
	LIBRARY= FATIM ;		/* Nom de la librairie d'origine */
	COPY IN= FATIM 			/* Librairie d'origine où se trouve la table à copier  */
	OUT=  SASUSER ;			/* Destination de répertoire */
	SELECT dataLog; 		/* Sélection des tables */
RUN;


PROC CONTENTS DATA = Sasuser.dataLog;
RUN;  

PROC MEANS DATA = Sasuser.dataLog NMISS;
RUN;  

/*****	TRANSFORMATION DE CERTAINES VARIABLES	******/
			/*****	VARIABLE CHURN  ******/


DATA Sasuser.dataLog1 ;
	SET Sasuser.dataLog ;
	Churn1 = PUT(Churn, 2.) ;
RUN;

			/*****	VARIABLE DataPlan ******/
DATA Sasuser.dataLog1 ;
	SET Sasuser.dataLog1 ;
	DataPlan1 = PUT(DataPlan, 1.) ;
RUN;
			/*****	VARIABLE DataPlan ******/

DATA Sasuser.dataLog1 ;
	SET Sasuser.dataLog1 ;
	ContractRenewal1 = PUT(ContractRenewal, 1.) ;
RUN;

PROC CONTENTS DATA = Sasuser.dataLog1;
RUN; 

DATA Sasuser.dataLog1 ;
	SET Sasuser.dataLog1 ;
	DROP Churn DataPlan ContractRenewal ;
	RENAME Churn1 = Churn 
		   ContractRenewal1 = ContractRenewal
		   DataPlan1 = DataPlan ;
RUN;

PROC MEANS DATA = Sasuser.dataLog1 ;
RUN;
PROC FREQ DATA= Sasuser.dataLog1;
TABLES CHURN ;
RUN; 
/*********************************************************************
+++ 		REGRESSION LOGISTIQUE SUR LA BASE GLOBALE		  	   +++
*********************************************************************/


PROC LOGISTIC DATA = Sasuser.dataLog1 ;
	CLASS ContractRenewal DataPlan ; /*	Variables explicatives de types qualitatives*/
	MODEL Churn =  AccountWeeks DataUsage CustServCalls DayMins DayCalls  /* Y = en fonction des X */       
                   MonthlyCharge OverageFee RoamMins ;
RUN;

/*********************************************************************
+++ 							ANALYSE DE CORRELATION		  	   +++
*********************************************************************/

PROC CORR DATA = Sasuser.dataLog1 ;
	VAR AccountWeeks DataUsage CustServCalls DayMins DayCalls      
        MonthlyCharge OverageFee RoamMins ;
RUN;


/*********************************************************************
+++ 							ECHANTILLONNAGE	  	   			   +++
*********************************************************************/

DATA  Sasuser.dataLog1 ;
	SET	Sasuser.dataLog1 ;
	Echantillon = 1 ;	/* Initialisation de la variable Echantillon indiquant les deux échantillons */
	IF RANUNI (123) >=0.7 THEN Echantillon = 2 ; 
RUN;


DATA Sasuser.dataLog1_Appr ; 	/*  Echantillon D'Apprentissage */
	SET	Sasuser.dataLog1 ;
	WHERE Echantillon = 1 ;
RUN;

DATA Sasuser.dataLog1_Val ; 	/*  Echantillon De Validation */
	SET	Sasuser.dataLog1 ;
	WHERE Echantillon = 2 ;
RUN;

PROC CONTENTS DATA = Sasuser.dataLog1_Appr ;
RUN; 

/*********************************************************************
+++ 							ESTIMATION DU MODELE	  	       +++
*********************************************************************/

PROC LOGISTIC DATA = Sasuser.dataLog1_Appr;
	CLASS ContractRenewal DataPlan ; /*	Variables explicatives de types qualitatives*/
	MODEL Churn (EVENT="1") =  AccountWeeks DataUsage CustServCalls DayMins DayCalls  /* Y = en fonction des X */       
                   MonthlyCharge OverageFee RoamMins / SELECTION= STEPWISE ;
RUN;

PROC LOGISTIC DATA = Sasuser.dataLog1_Appr OUTMODEL= Sasuser.Model_Churn   ;
	CLASS ContractRenewal DataPlan ; /*	Variables explicatives de types qualitatives*/
	MODEL Churn (EVENT="1") =  AccountWeeks DataUsage CustServCalls DayMins DayCalls  /* Y = en fonction des X */       
                   MonthlyCharge OverageFee RoamMins / SELECTION= STEPWISE ;
	OUTPUT OUT= Sasuser.Estimation PREDPROBS = I ;
RUN;

/*********************************************************************
+++ 							VALIDATION DU MODELE	  	       +++
*********************************************************************/
PROC LOGISTIC  INMODEL= Sasuser.Model_Churn ; /* BD contenant le modèle */
	SCORE DATA = Sasuser.dataLog1_Val  /* BD Validation */
	OUT =  Sasuser.Prevision 
	OUTROC= Sasuser.Performance_ROC ;
RUN;
