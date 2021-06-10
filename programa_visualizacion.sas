/**Poryecto visualización practica 2**/

proc import datafile="/SASUser/RIESGO/mdi/proyectos/rsl/COVID/20200921_Matricula_unica_2020_20200430_WEB.CSV"
   out=Matricula_unica_2020
   dbms=dlm
   replace;
   delimiter=';';
run;

proc sql;
	Create table work.homologa_1 as
		Select t1.*,
			t2.'Descripción'n as COD_ENSE_DESC
		From work.Matricula_unica_2020 t1 
		Left join work.HOMOLOGACIONES_0005 t2 on t1.COD_ENSE=t2.COD_ENSE;
quit;

proc sql;
	Create table work.homologa_2 as
		Select t1.*,
			t2.'Descripción'n as COD_ENSE2_DESC
		From work.homologa_1 t1 
		Left join WORK.Homologaciones t2 on t1.COD_ENSE2=t2.COD_ENSE2;
quit;

proc sql;
	Create table work.homologa_3 as
		Select t1.*,
			t2.'Descripción'n as COD_RAMA_DESC
		From work.homologa_2 t1 
		Left join WORK.HOMOLOGACIONES_0003 t2 on t1.COD_RAMA=t2.COD_RAMA;
quit;

proc sql;
	Create table work.homologa_4 as
		Select t1.*,
			t2.'Descripción'n as COD_REG_RBD_DESC,
			t2.'Nombre Abreviado'n
		From work.homologa_3 t1 
		Left join WORK.HOMOLOGACIONES_0004 t2 on t1.COD_REG_RBD=t2.COD_REG_RBD;
quit;

data work.transformaciones;
	format COD_JOR_DES COD_DEPE2_DES GEN_ALU_DES RURAL_RBD_DES COD_TIPO_EST $char50.;
	set work.homologa_4;
		select (COD_JOR);
			when (1)	COD_JOR_DES="Mañana";
			when (2)	COD_JOR_DES="Tarde";
			when (3)	COD_JOR_DES="Mañana y Tarde";
			when (4)	COD_JOR_DES="Vespertina/Nocturna";
			otherwise  COD_JOR_DES="Sin Información";
		end;
		select (COD_DEPE2);
			when (1)	COD_DEPE2_DES="Municipal";
			when (2)	COD_DEPE2_DES="Particular Subvencionado";
			when (3)	COD_DEPE2_DES="Particular Pagado";
			when (4)	COD_DEPE2_DES="Corporación de Administración";
			when (5)	COD_DEPE2_DES="Servicio Local de Educación";
			otherwise  COD_DEPE2_DES="Sin Información";
		end;
		if COD_DEPE2 in (2,3) then 
			COD_TIPO_EST="PAGADO";
		if COD_DEPE2 in (1) then 
			COD_TIPO_EST="NO PAGO";
		if COD_DEPE2 in (4,5) then 
			COD_TIPO_EST="CORPORACIÓN";

		select (GEN_ALU);
			when (1)	GEN_ALU_DES="Hombre";
			when (2)	GEN_ALU_DES="Mujer";
			otherwise  GEN_ALU_DES="Sin Información";
		end;
		select (RURAL_RBD);
			when (0)	RURAL_RBD_DES="Urbano";
			when (1)	RURAL_RBD_DES="Rural";
			otherwise  RURAL_RBD_DES="Sin Información";
		end;
run;

proc sql;
	Create table work.agrupado_data as
		Select COD_JOR_DES,
			GEN_ALU_DES,
			COD_TIPO_EST,
			COD_DEPE2_DES,
			RURAL_RBD_DES,
			EDAD_ALU,
			COD_ENSE_DESC,
			COD_ENSE2_DESC,
			COD_RAMA_DESC,
			COD_REG_RBD_DESC,
			'Nombre Abreviado'n,
			count(*) as num_registros
		From work.transformaciones
		Group by COD_JOR_DES,
			GEN_ALU_DES,
			COD_TIPO_EST,
			COD_DEPE2_DES,
			RURAL_RBD_DES,
			EDAD_ALU,
			COD_ENSE_DESC,
			COD_ENSE2_DESC,
			COD_RAMA_DESC,
			COD_REG_RBD_DESC,
			'Nombre Abreviado'n;
quit;