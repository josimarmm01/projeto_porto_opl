//int T = 168; //10 a 15 navios
//int T = 252;   //20 navios
int T = 336;   //25 navios
//int PeriodoMare = 14; // 10 e 15 navios sao 14 perios de mare alta
//int PeriodoMare = 20; // 20 e 25 navios sao 20 perios de mare alta
int PeriodoMare = 27; //25 navios sao 27 periodos de mare alta

int nbVessel=...;

range period=1..PeriodoMare;
range vessel=1..nbVessel;
range vessel1=1..nbVessel;

int nbTask=...;
int nbSections=...;

range section=1..nbSections;
range period2=2..PeriodoMare;

int nbTimes = T;

range times=1..nbTimes;

int nbReclaimer=...;

range task=1..nbTask;
range  reclaimer=1..nbReclaimer;
range position=1..60;

int weight[vessel]=...;
int AssVessel[task]=...;

{int} vesselNeedTask[i in vessel]={k|k in task:AssVessel[k]==i};

int Q[reclaimer]=...;
int vertical[position]=...;
int len[task]=...;
int ArrivalTime[i in vessel]=...;
int L[i in vessel]=...;
int Ls[i in section]=...;
int B[period]=...;
int E[period]=...;    
int P[i in task]=...;

dvar int+ S[vessel];
dvar int+ C[vessel];
dvar boolean Y[section][vessel];
dvar boolean X[section][vessel][vessel1];
dvar boolean Z[vessel][period];
dvar boolean XR[reclaimer][task][task] ;
dvar boolean REL[task][times];

{int} unavailable[i in 1..26]= {t|t in (E[i]+1)..(B[i+1]-1)}; 
{int} unavALL = {r|k in 1..26,r in unavailable[k]};
{int} available[i in 1..27]= {t|t in (B[i])..(E[i])};
{int} avAll = {r| k in 1..27,r in available[k]};

int totalLoadOfVessel[i in vessel] = sum(j in vesselNeedTask[i])P[j];
int D[position]=...;
int noOfTasks[i in vessel] = card(vesselNeedTask[i]);
int Arr[i in task][t in times] = 0;

execute a6 {
   	for(var t in times) {
	   	for(var i in task) {
	   		if(ArrivalTime[AssVessel[i]] == t) {
	   	   		Arr[i][t] = 1;
	   		}   
    	}
   }    		   		
}   

int reclaimerUsesPosition[k in reclaimer][l in position]=0;
 
execute aa {
   for(var k in reclaimer)
   for(var l in position)
   if(Q[k]==D[l] || D[l]-Q[k]==1)
   reclaimerUsesPosition[k][l]=1;   
}   

int dist[i in reclaimer][j in section]=...;
dvar boolean distance[j in vessel][i in reclaimer][k in section];
dvar boolean vessel2reclaimer[vessel][reclaimer];

int minTimeOfVessel[j in vessel][t in times] = totalLoadOfVessel[j] + 1;

execute aaa {
 	for(var j in vessel)
   		for(var t in times)
   	for(var r in period2) {
   		if(t+totalLoadOfVessel[j]+1<B[r] && t+totalLoadOfVessel[j]+1>E[r-1])
   			minTimeOfVessel[j][t]=B[r]-t;
 	}   
}   

int dummy_S[i in vessel]=0;
int dummy_C[i in vessel]=0;
int dummy_CR[i in task]=0;
int dummy_SR[i in task]=0;
int dummy_lasttime[i in vessel]=0;
int dummy_assigned[i in vessel][k in reclaimer]=0;
int dummy_task2reclaimer[j in task][k in reclaimer]=0;
int dummy_AssVessel[i in task]=0;

dvar int+ CR[task];
dvar int+ SR[task];
dvar boolean x[task][times];
 
range stockpads=1..3;
range positions=1..20;

dvar boolean gama[task][stockpads][positions];
dvar boolean M[task][task];
dvar boolean TT[task][reclaimer][positions];
dvar boolean MM[task][task];

minimize sum(j in vessel)(weight[j]*C[j]);

subject to {

//C1:
    forall (j in vessel)
         sum(m in section)Y[m][j]==1;


//C2:
        forall (m in section,j in vessel:Ls[m]<L[j])
        Y[m][j]==0;


//C3:
    forall (j in vessel)
         S[j]>=ArrivalTime[j];

//C4:
    forall (m in section,j in vessel,k in vessel1: j!=k)
        S[k]>=C[j]-(nbTimes-ArrivalTime[k])*(1-X[m][j][k]);

//C5:
  forall (m in section,j in vessel,k in vessel1: j!=k)
        X[m][j][k]+X[m][k][j]<=Y[m][j]; 
 
//C6:        
    forall (m in section,j in vessel,k in vessel1: j!=k)  
        X[m][j][k]+X[m][k][j]>=Y[m][j]+Y[m][k]-1;  
       
            //forall (m in section,j in vessel)
             //    X[m][j][j]==0;

//C7:
    forall (j in vessel)
       sum(i in period)Z[j][i]==1;

//C8:
    forall (j in vessel)
        C[j]>= sum(i in period)B[i]*Z[j][i];

//C9:
    forall (j in vessel)
         C[j]<= sum(i in period)E[i]*Z[j][i];

//C10:
   forall(i in vessel)
     sum(j in reclaimer)vessel2reclaimer[i][j]==1;

//C11:
	forall (m in reclaimer,j in task, k in task: j!=k)
        XR[m][j][k]+XR[m][k][j]<=vessel2reclaimer[AssVessel[j]][m]; 
        
	//C12:
	forall (m in reclaimer,j in task,k in task: j!=k)  
  XR[m][j][k]+XR[m][k][j]>=vessel2reclaimer[AssVessel[k]][m]+vessel2reclaimer[AssVessel[j]][m]-1;  
    
//  forall (m in reclaimer,j in task)
 //     XR[m][j][j]==0;
         
//C13:
    forall (m in reclaimer,j in task,k in task: j!=k )
        SR[k]>=CR[j]-(336-ArrivalTime[AssVessel[k]])*(1-XR[m][j][k]);
         
//C14:
    forall (j in task )
    	SR[j]+P[j]==CR[j];

//C15:
  forall (m in reclaimer,i in task,j in task,k in task: i!=k && j!=k && i!=j && AssVessel[i]==AssVessel[j] && AssVessel[k]!=AssVessel[j] )
        XR[m][i][k]+XR[m][k][j]<=1;

//C16:
   forall(i in vessel,j in vesselNeedTask[i])
   		S[i]<=SR[j];

//C17:
            forall (j in vessel,i in vesselNeedTask[j])
         C[j]>=  CR[i] + sum(k in reclaimer, r in section)dist[k][r]*distance[j][k][r];

//C18:
    forall(i in vessel)
sum(j in reclaimer, m in section) distance[i][j][m]==1;
 
//C19: 
         forall (m in section,k in reclaimer,j in vessel:Ls[m]>=L[j])
              Y[m][j] + vessel2reclaimer[j][k]<= distance[j][k][m] + 1 ;

//C20:
    //domains of variables

//C21:
    forall(j in vessel)
    C[j] >=sum(t in times)(t+totalLoadOfVessel[j]+1)*x[j][t];

//C22:
        forall(j in vessel)
c666:    sum(t in times: t >= ArrivalTime[j])x[j][t]==1;

//C23:
         forall(j in vessel)
c667:    sum(t in times: t <= (ArrivalTime[j]-1))x[j][t]==0;

//C24:
     forall(t in times)
    sum(j in vessel,s in maxl(1,t-totalLoadOfVessel[j]+1)..t)x[j][s]<= nbReclaimer;
    
//C25:
  //domain of a variable x[j][t]

//C26:
forall(t in times)
sum(i in task,s in times: s<=t-P[i] && s>= maxl(1,minl(ArrivalTime[AssVessel[i]],t-P[i])) && ArrivalTime[AssVessel[i]]<=t-P[i])(len[i]*(Arr[i][s] - REL[i][s])) + sum(i in task,sss in times: sss>=maxl(1,t-P[i]+1) && sss<=t)len[i]*Arr[i][sss]<=60;
   
//A1:
forall(i in task)
sum(k in reclaimer, p in positions)TT[i][k][p] == 1;

//A2:
forall(i in task,s in stockpads,p in positions,k in reclaimer)
TT[i][k][p] + 1 >=  gama[i][s][p] + vessel2reclaimer[AssVessel[i]][k];

//A3:
forall(k1 in reclaimer,k2 in reclaimer, s in stockpads,p in positions, i1 in task, i2 in task:i1!=i2 && p+len[i1]<=20 && Q[k1]==Q[k2] && k1<k2)
MM[i1][i2]+MM[i2][i1]>= TT[i1][k1][p]+ sum(p1 in positions:p1>p)TT[i2][k2][p1] - 1;

//A4:
forall(i1 in task, i2 in task:i1!=i2)
CR[i1]<=SR[i2] + T * (1-MM[i1][i2]);

//A5:
forall(i in task)
sum(p in positions, s in stockpads)gama[i][s][p]==1;

//A6:
forall(i in task,s in stockpads,p in positions: p+len[i]-1>20)
gama[i][s][p]==0;  

//A7:
forall(i in task, k in reclaimer)
1-sum(p in positions, s in stockpads: Q[k]>s || s-Q[k]>1)gama[i][s][p]>=vessel2reclaimer[AssVessel[i]][k];

//A8:
forall(i1 in task, i2 in task:i1!=i2)
M[i1][i2]+M[i2][i1]<=1;

//A9:
forall(s in stockpads,p in positions, i1 in task, i2 in task:i1!=i2 && p+len[i1]-1<=20)
M[i1][i2]+M[i2][i1]>= gama[i1][s][p]+ sum(p1 in maxl(1,(p-len[i2]+1))..(p+len[i1]-1) )gama[i2][s][p1] - 1;

//A10:
forall(i1 in task, i2 in task:i1!=i2)
CR[i1]<=ArrivalTime[AssVessel[i2]] + T *(1-M[i1][i2]);
}
//A11:
  //domains of additional variables