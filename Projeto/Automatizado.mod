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

var src = new IloOplModelSource("Modelo.mod");
var def = new IloOplModelDefinition(src);

var tempo = 3600; 				     
var gap = 0;

var i = 1;
var qtd_instancias = 1;
var pasta = "4_4/";
//var pasta = "4_3/";

var ofile1 = new IloOplOutputFile("saida/" + pasta + i + "tabela01.txt");
var ofile3 = new IloOplOutputFile("saida/" + pasta + i + "tabela02.txt");
    
    while(i <= qtd_instancias){
     
      // 4_ 4 15
      
      if (i != 15) {
            
    	var ofile2 = new IloOplOutputFile("saida/" + pasta +"Dados0" + i + ".txt");
        				
        var opl = new IloOplModel(def,cplex);
        var data = new IloOplDataSource("entrada/" + pasta +"Dados0" + i + ".dat");
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
			
			ofile2.writeln(opl.C);
			ofile2.writeln(opl.S);
			ofile2.writeln(opl.X);
			ofile2.writeln(opl.Y);
			ofile2.writeln(opl.Z);
			
			ofile2.writeln(opl.Omega);
			ofile2.writeln(opl.XR);
			ofile2.writeln(opl.Beta);
			ofile2.writeln(opl.SR);
			ofile2.writeln(opl.CR);
			ofile2.writeln(opl.alfa);
			
			ofile2.writeln(opl.V1);
			ofile2.writeln(opl.V2);
			ofile2.writeln(opl.V3);
			ofile2.writeln(opl.V4);
									     	
        } else{
            ofile1.writeln(cplex.status);
        }
    	
    	i++;
    	ofile2.close();	
	
		
		}else { //fim if
			
			ofile1.writeln(" * & * & "+ i + " & * & \\\\");
			ofile3.writeln(" * & * & "+ i + " & * \\\\");
			writeln(" * & * & "+ i + " & * & \\\\");
			writeln(" * & * & "+ i + " & * \\\\");
				
			i++;		
		}
		
	}//fim wilhe
			
	ofile1.close();
	ofile3.close();
		
}	