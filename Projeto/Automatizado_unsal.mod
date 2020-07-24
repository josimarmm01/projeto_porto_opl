/*********************************************
 * OPL 12.8.0.0 Model
 * Author: josimar
 * Creation Date: 06/11/2019 at 16:13:03
 *********************************************/

main {

function roundTo(x, digits) {	
	x=x*Opl.pow(10,digits);
	x=Opl.round(x);
	x=x/Opl.pow(10,digits);
	return x;
}

var src = new IloOplModelSource("ModeloUnsal.mod");
var def = new IloOplModelDefinition(src);

var tempo = 21600; 				     
var gap = 0;

var i = 31;
var qtd_instancias = 40;

var folder = "saida/";
var folderEntrada = "entradaUnsal/";

var pasta = "4_3/";
//var pasta = "4_4/";

var ofile1 = new IloOplOutputFile(folder + pasta + i + "_TabelaTempo.txt");
var ofile3 = new IloOplOutputFile(folder + pasta + i + "_TabelaFo.txt");
    
    while(i <= qtd_instancias){
     
      // 4_ 4 15
      
      if (i != 36) {
            
    	var ofile2 = new IloOplOutputFile(folder + pasta + i + ".txt");
        				
        var opl = new IloOplModel(def,cplex);
        var data = new IloOplDataSource(folderEntrada + pasta + i + ".dat");
        opl.addDataSource(data);
        
        var details = opl.dataElements;
        opl.generate();
        
        cplex.tilim = tempo;
        cplex.epgap = gap;   
        
        if(cplex.solve()){
        	
        	writeln(cplex.getObjValue() + "	" + cplex.getBestObjValue() + "	" +
					cplex.getMIPRelativeGap()*100 + "	" + roundTo(cplex.getSolvedTime (), 2) + "	" +
					cplex.status + "	");
        	
        	ofile1.writeln( "$" + opl.nbVessel + "$ & $" + opl.nbTask + "$ & $" + i + "$ & $" + roundTo(cplex.getSolvedTime (), 2) + "$ & \\\\");
			ofile3.writeln("$" +opl.nbVessel + "$ & $" + opl.nbTask + "$ & $" + i + "$ & $" + cplex.getObjValue() + "$ & $" + cplex.getBestObjValue() + " & " + cplex.status + "$ \\\\");
			
			writeln(opl.nbVessel + " & " + opl.nbTask + " & " + i + " & " + roundTo(cplex.getSolvedTime (), 2) + " & \\\\");
			writeln(opl.nbVessel + " & " + opl.nbTask + " & " + i + " & " + cplex.getBestObjValue() + " & " + cplex.getObjValue()  + " " +  cplex.status + "\\\\");
			
					
			ofile2.writeln(cplex.getObjValue());
			ofile2.writeln(cplex.getBestObjValue());
			ofile2.writeln(cplex.getMIPRelativeGap()*100);
			ofile2.writeln(roundTo(cplex.getSolvedTime (), 2));
			ofile2.writeln(cplex.status);
			
			ofile2.writeln(opl.C);   //OK
			ofile2.writeln(opl.S);   //OK
			ofile2.writeln(opl.X);   //OK
			ofile2.writeln(opl.Y);   //OK
			ofile2.writeln(opl.Z);   //OK
			ofile2.writeln(opl.XR);  //OK
			ofile2.writeln(opl.REL); //OK
						
			ofile2.writeln(opl.distance);			//OK
			ofile2.writeln(opl.SR);  				//OK
			ofile2.writeln(opl.CR);  				//OK
			ofile2.writeln(opl.vessel2reclaimer);	//OK
			ofile2.writeln(opl.x);
			
			ofile2.writeln(opl.gama);	//OK		
			ofile2.writeln(opl.M);		//OK
			ofile2.writeln(opl.TT);		//OK
			ofile2.writeln(opl.MM);		//OK
									     	
        } else{
            ofile1.writeln(cplex.status);
        }
    	
    	i++;
    	ofile2.close();	
		
		}else { //fim if
			
			ofile1.writeln(" * & * & "+ i + " & * & \\\\");
			ofile3.writeln(" * & * & "+ i + " & * & *\\\\");
			writeln(" * & * & "+ i + " & * & \\\\");
			writeln(" * & * & "+ i + " & * & *\\\\");
				
			i++;		
		}
		
	}//fim wilhe
			
	ofile1.close();
	ofile3.close();
		
}	