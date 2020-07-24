/*********************************************
 * OPL 12.8.0.0 Model
 * Author: josimar
 * Creation Date: 21/08/2019 at 14:29:17
 *********************************************/

//using CP;

int nbVessel    = ...;                 		// Quantidade de embarcações,
int nbSections  = ...;						// Quantidade de berços,
int nbReclaimer = ...;                  	// Quantidade de recuperadores,
int nbTask      = ...;                  	// Quantidade de tarefas.

int nbMare      =   3;						// Quantidade de periodos de maré alta,
int T			=  10;						// Tempo de planejamento de acordo com numero de embarcações.

int nbU			=   3;                   	// Numero total de blocos nos patios,
int nbA			=   2;                    	// Numero total de blocos nos patios,

range bercos   		= 1..nbSections;        // Percorer os berços,
range recuperadores = 1..nbReclaimer;		// Percorer os recuperadores.

range navios   		= 1..nbVessel;          // Percorer as embarcações,                    
range tarefas  		= 1..nbTask;			// Percorer as tarefas,

int weight[navios]              = ...;		// Pesso de cada embarcação,
int Ls[bercos] 					= ...;		// Conjunto de berços com seus repectivos tamanhos, 
int L[navios] 					= ...;		// Conjunto comprimento navios,
int ArrivalTime[navios]			= ...;		// Hora de chegada dos navios, 
int P[tarefas]					= ...;		// Tempo de recuperação das tarefas,
int AssVessel[tarefas] 			= ...;		// Indice do navio designado para cada tarefa, 
int dist[recuperadores][bercos] = ...;		// Matriz de distancia entre recuperadores e os berços,
int Q[recuperadores] 			= ...;		// Indice do trilho em que o recuperador esta atribuido, 
int len[tarefas] 				= ...;		// Largura que a tarefa ocupa no pátio.

int TotalLoadOfVessel[navios];              // Quantidade de tempo necessária para recuperar todas as tarefas do navio j
int AssignedTasksToVessel[navios][tarefas];


//Pré processamento, calcula TotalLoadOfVessel de cada embarcação e identifica parametros de cada instancia.
execute {
	
	// Calcular TotalLoadOfVessel embarcações j
	for(var j = 1; j <= nbVessel; j++) {
		for(var i = 1; i <= nbTask; i++) {
		   	
			if (AssVessel[i] == j) {
			write("Tarefa " + i + " Navio ");
				write(AssVessel[i]);			
				TotalLoadOfVessel[j] = TotalLoadOfVessel[j] + P[i];		
			}
			writeln();		
		}	
	}
	// Calcular AssignedTasksToVessel embarcações j
	for(var j = 1; j <= nbVessel; j++) {
		for(var i = 1; i <= nbTask; i++) {
			if (AssVessel[i] == j) {
	     		AssignedTasksToVessel[j][i] = 1;
	     	} else {
	     		AssignedTasksToVessel[j][i] = 0;
	     	}	
		}
		writeln();	
	}				
}		


range tempo			= 1..T;				   				// Percorer indice de tempo,
range mare     		= 1..nbMare;           				// Percorer maré alta,
range A				= 1..nbA;			   				// Percorer indices dos patios,
range U				= 1..nbU;			   				// Percorer posições de locação.	

int B[mare] = ...;                         				// Inicio da maré alta,          
int E[mare] = ...;                         				// Fim maré alta.

dvar int C[navios]   in 0..T;                   		// Dvar Hora de partida do navios,
dvar int S[navios]   in 0..T;                   		// Dvar Tempo de atarcação do navio j,
dvar int SR[tarefas] in 0..T;                    		// Dvar hora de início da recuperação do estoque i,
dvar int CR[tarefas] in 0..T;                     		// Dvar tempo de conclusão da recuperação de estoque i,

dvar boolean Y[bercos][navios];                    		// Dvar 1 se o navio j é atribuido ao berço m, 0 aso contrario, 
dvar boolean X[bercos][navios][navios];            		// Dvar 1 se navio j está atracado depois do navio j; 0 caso contrário,  
dvar boolean Z[navios][mare];                      		// Dvar 1 se navio j deixa na maré alta ; 0 caso contrário,
dvar boolean Omega[navios][recuperadores];         		// Dvar 1 se recuperador k é atribuído ao navio j; 0 caso contrário, 
dvar boolean XR[recuperadores][tarefas][tarefas];  		// Dvar 1 se o tarefa i' é recuperado pelo recuperador k depois da tarefa i; 0 caso contrário,
dvar boolean Beta[navios][recuperadores][bercos];  		// Dvar 1 se navio j é designado ao recuperador k no berço m,  0 caso contrário, 
dvar boolean alfa[navios][tempo];						// Dvar 1 se a recuperação da tarefa agregada do navio j começa no tempo t; 0 caso contrário.

dvar boolean V1[tarefas][recuperadores][U];				// Dvar 1 se o tarefa i for atribuído ao recuperador k e posição de estoque p; 0 caso contrário,
dvar boolean V2[tarefas][tarefas];						// Dvar 1 se o tarefa i1 for recuperado antes do tarefa i2; 0 caso contrário,
dvar boolean V3[tarefas][A][U];							// Dvar 1 se o tarefa i for atribuído ao pátio s e a posição de locação p; 0 caso contrário,
dvar boolean V4[tarefas][tarefas];						// Dvar 1 se as tarefa i1 e i2 forem alocados no pátio de estocagem, de modo que compartilhem pelo menos uma posição de estocagem, e i1 seja recuperado antes da chegada do estoque i2; 0 caso contrário.

minimize  	
	sum (j in navios) (weight[j] * C[j]);
  	
  	//3328
  	
  	subject to {
  	  	
  		// OK Restrições 1 e 2 garantem que cada embarcação deve ser atribuída a um dos berços que seu tamanho permitir
	    n01:forall (j in navios) {
	    	sum (m in bercos) Y[m][j] == 1;
        }
        
        // OK	      
	    n02:forall (m in bercos, j in navios: Ls[m] < L[j]) {
	    	Y[m][j] == 0;
        }
        
		// OK Restrição 3 simplesmente garante que um navio não possa atracar antes de sua chegada
		n03:forall(j in navios) {
			S[j] >= ArrivalTime[j];
        }
        			
		// OK Restrição 4 garante há não sobreposição de embarcações que usam o mesmo berço	
		n04:forall (m in bercos, j in navios, jl in navios: j != jl) {				
			S[jl] >= C[j] - T * (1 - X[m][j][jl]);			
		}
		
		// OK Restrições 5 e 6 determinar a ordem de atracação dos navios que são atribuídos ao mesmo berço
		n05:forall (m in bercos, j in navios, jl in navios: j != jl) {
			X[m][j][jl] + X[m][jl][j] <= Y[m][j];		
		}
		
		// OK
		n06:forall (m in bercos, j in navios, jl in navios: j != jl) {
			X[m][j][jl] + X[m][jl][j] >= Y[m][j] + Y[m][jl] - 1;			
		}
		
		// OK Restrições 7, 8, 9, juntas impõem os efeitos das janelas do tempo das marés nas alocações dos berços
		n07:forall(j in navios) {
			sum(r in mare) Z[j][r] == 1;		
		}
		
		// OK 
		n08:forall(j in navios) {
			C[j] >= sum(r in mare)B[r]*Z[j][r];	
		}
		
		// OK
		n09:forall(j in navios) {
			C[j] <= sum(r in mare)E[r]*Z[j][r];
		}
		
		// OK Restrição 10 atribui uma embarcação apenas a um recuperador para executar a recuperação dos estoques
		n10:forall(j in navios) {
				sum(k in recuperadores) Omega[j][k] == 1;
		}
		
		// OK Restrições 11 e 12 determinam a ordem de processamento das tarefas nos recuperadores, semelhantes a do problema de alocação do berço
		n11:forall(k in recuperadores, i in tarefas, il in tarefas: i != il) {
			XR[k][i][il] + XR[k][il][i] <= Omega[AssVessel[i]][k];
		}
		// OK 
		n12:forall(k in recuperadores, i in tarefas, il in tarefas: i != il) {
			XR[k][i][il] + XR[k][il][i] >= Omega[AssVessel[i]][k] + Omega[AssVessel[il]][k] - 1;
		}
		
		// OK Restrição 13 determina que as tarefas atribuídas ao mesmo recuperador não podem ser recuperadas simultaneamente
		n13:forall(k in recuperadores, i in tarefas, il in tarefas: i != il) {
			SR[il] >= CR[i] - T * (1 - XR[k][i][il]);		
		}
		
		// OK Restrição 14 afirma que a recuperação de um estoque requer uma quantidade fixa de tempo e deve ser realizada de forma não preventiva
		n14:forall(i in tarefas) {
			SR[i] + P[i] == CR[i];			
		}
		
		// OK Restrição 15 garante que o recuperador deve executar tarefas de recuperação do mesmo navio. 
		n15:forall(k in recuperadores, i in tarefas, il in tarefas, ill in tarefas:
					(AssVessel[i] == AssVessel[il]) && (AssVessel[i] != AssVessel[ill])) {
			XR[k][i][ill] + XR[k][ill][il] <= 1;
		}
			
		// OK Restrição 16 indica que os recuperadores não podem começar a recuperar um estoque antes que o navio associado atraque
		n16:forall(i in tarefas) {
			SR[i] >= S[AssVessel[i]];		
		}
		
		// OK Restrição 17 calcula o tempo mais cedo em que uma embarcação pode deixar o terminal, considerando o tempo de recuperação de cada estoque, bem como a distância entre o berço e o recuperador
		n17:forall(j in navios, i in tarefas) {
			if (AssignedTasksToVessel[j][i] == 1){
				C[j] >= CR[i] + sum(m in bercos, k in recuperadores) dist[m][k]*Beta[j][k][m];	
			}
		}		
			
		// OK Restrições 18 e 19 determinam, para cada embarcação, a distância entre o berço e o recuperador a que está atribuído.
		n18:forall(j in navios) {
			sum(k in recuperadores, m in bercos) Beta[j][k][m] == 1;		
		}
		
		// OK
		n19:forall(j in navios, m in bercos, k in recuperadores: Ls[m] >= L[j]) {
			Y[m][j] + Omega[j][k] <= Beta[j][k][m] + 1;	
		}
		
		// OK Variavel de relaxação
		n20:forall(j in navios) {
			C[j] >= sum(t in tempo) (t + TotalLoadOfVessel[j]) * alfa[j][t];			
		}
		
		// OK 
		n21:forall(j in navios) {
			sum(t in tempo: t >= ArrivalTime[j]) alfa[j][t] == 1;
		}
		
		// OK
		n22:forall(j in navios) {
			sum(t in tempo: t < ArrivalTime[j]) alfa[j][t] == 0;
		}
		
		// OK
		n23:forall(t in tempo) {
			sum(j in navios, s in tempo: (s >= maxl(1, t - TotalLoadOfVessel[j]))
			   && (s <= t)) alfa[j][s] <= nbReclaimer;
		}
		
		
		
		// Subproblema
		
		//As restrições a1, a2, a3, a4 juntas garantem que os recuperadores que operam no mesmo trilho não se cruzem
		nA01:forall(i in tarefas) {
			sum (k in recuperadores, p in U) V1[i][k][p] == 1;	
		}
			
		nA02:forall(i in tarefas, k in recuperadores, s in A, p in U) {
				V1[i][k][p] + 1 >= V3[i][s][p] + Omega[AssVessel[i], k];	
		}
		
		//nA03:forall(i1 in tarefas, i2 in tarefas, k1 in recuperadores, k2 in recuperadores,
		// s in A, p in U: (i1 != i2) && (k1 < k2) && (Q[k1] == Q[k2]) && (p + len[i1] <= nbU)) {
		 	
		 	
		nA03:forall(i1 in tarefas, i2 in tarefas, k1 in recuperadores, k2 in recuperadores,
		 p in U: (i1 != i2) && (k1 < k2) && (Q[k1] == Q[k2]) && (p + len[i1] <= nbU)) {
			V2[i1][i2] + V2[i2][i1] >= V1[i1][k1][p] + sum(p1 in U: p1 > p) V1[i2][k2][p1] - 1;			
		}
		
		nA04:forall(i1 in tarefas, i2 in tarefas: i1 != i2) {

			CR[i1] <= SR[i2] + T * (1 - V2[i1][i2]);					
			
		}
		
		//As retrições n05 á n10, afirma que se dois estoques forem alocados ao pátio de estocagem, compartilhado pelo menos uma posição de estagaem, elas nao podem ser armazendas no patio simultaneamente.
		nA05:forall(i in tarefas) {
			sum(p in U, s in A) V3[i][s][p] == 1;	
		}
		
		nA06:forall(i in tarefas, s in A, p in U: p + len[i] - 1 > nbU) {
			V3[i][s][p] == 0;
		}
	    
		nA07:forall(i in tarefas, k in recuperadores) {
			(1 - sum(p in U, s in A: (Q[k] > s) || (s - Q[k] > 1) ) V3[i][s][p]) >= Omega[AssVessel[i]][k];			
		}
		
		nA08:forall(i1 in tarefas, i2 in tarefas: i1 != i2) {
			V4[i1][i2] + V4[i2][i1] <= 1;
		}
		
		nA09:forall(i1 in tarefas, i2 in tarefas, s in A, p in U: i1 != i2 && p + len[i1] - 1 <= nbU){
			V4[i1][i2] + V4[i2][i1] >= V3[i1][s][p] + sum (p1 in U: p1 >= maxl(1, (p - len[i2] + 1)) && 
			p1 <= (p + len[i1] - 1)) V3[i2][s][p1] - 1;				
		}
		
		nA10:forall(i1 in tarefas, i2 in tarefas: i1 != i2) {
			CR[i1] <= ArrivalTime[AssVessel[i2]] + T * (1 - V4[i1][i2]);
		}		
		
 }	    		