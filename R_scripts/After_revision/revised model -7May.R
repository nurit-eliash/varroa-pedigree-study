#assume single founder female, N(0)=1
n <- 2 #number of daughters per mother, r=n-1
C <- 200 #carrying capacity
p0 <- 0.1 #initial heterozygosity
f1 <- 0.1 #initial correlation between gametes
Tt <- 50 #total number of generations
K <- 100 #number of available blood cells

#p1 is heterozygosity under diploid arrhenotoky
#p2 is heterozygosity under haplo-diploidy
#p3 is heterozygosity under complete diploidy

#N is population size
#P is change of laying eggs in empty blood cells
#p1[-1]/p1[-Tt]-1 is relative loss rate in heterozygosity over a generation under diploid arrhenotoky
#p2[-1]/p2[-Tt]-1 is relative loss rate in heterozygosity over a generation under haplo-diploidy
#p3[-1]/p3[-Tt]-1 is relative loss rate in heterozygosity over a generation under complete diploidy
#effective population size is calculated by comparing relative loss rate in heterozygosity over a generation to the rate in random mating diploid population which is -1/2/N. So -1/loss rate gives the effective population size which is the size as if the population was random mating.
#-1/(p1[-1]/p1[-Tt]-1) is effective population size in each generation under diploid arrhenotoky
#-1/(p2[-1]/p2[-Tt]-1) is effective population size in each generation under haplo-diploidy
#-1/(p3[-1]/p3[-Tt]-1) is effective population size in each generation under complete diploidy

#haplo-diploidy assuming exact varroa life history
#initialize 
p1 <- rep(0,Tt)
N <- rep(0,Tt)
N[1] <- 1
for (t in 2:(Tt-1)) {
	N[t] <- round((1+(n-1)*(1-N[t-1]/C))*N[t-1]) #starting from t=0
}
P <- c(0,K/N*(1-(1-1/K)^N)) #starting from t=1

P1 <- rep(0,Tt) #starting from t=1
for (i in 3:(Tt+1)) {
	P1[i-1] <- 1/N[i-2]/n*sum(sapply(1:N[i-2], function (x) 1/x^2*choose(N[i-2]-1,x-1)/K^(x-1)*(1-1/K)^(N[i-2]-x)))
} 
P2 <- rep(0,Tt) #starting from t=1
for (i in 3:(Tt+1)) {
	P2[i-1] <- 1/N[i-2]*sum(sapply(1:N[i-2], function (x) 1/x*(1-1/x/n)*choose(N[i-2]-1,x-1)/K^(x-1)*(1-1/K)^(N[i-2]-x)))
} 
P3 <- rep(0,Tt) #starting from t=1
for (i in 3:(Tt+1)) {
	P3[i-1] <- 1/N[i-2]*sum(sapply(2:N[i-2], function (x) (1-1/x)/x/n*choose(N[i-2]-1,x-1)/K^(x-1)*(1-1/K)^(N[i-2]-x)))
} 

P4 <- 1-P1-P2-P3

p1[1] <- (1-f1)*p0
f2 <- (1/2+3/2*f1)/2
p1[2] <- (1-f2)*p0
ff2 <- (3+5*f1)/8/n+(1-1/n)/4*(1+3*f1)
f3 <- P[3]*(1/4+1/4*f1)+f2/2+(1-P[3])/2*ff2
p1[3] <- (1-f3)*p0
ff3 <- P1[3]/8*(3+4*f2+f1)+P2[3]/4*(1+2*f2+ff2)+P3[3]/4*(2*f2+f1+1/2+f1/2)+P4[3]/4*(2*f2+ff2+f1)
f4 <- P[4]*(1/4+1/4*f2)+f3/2+(1-P[4])/2*ff3
p1[4] <- (1-f4)*p0

#define coefficients
cal_coef <- function (P,P_,P__,P1,P2,P3) {
	c(P/4+(1-P)/2*(P1*3/8+P2/4+P3/4/2-(1-P1-P3)/2/(1-P_)/4*P_-(1-P1-P2)/2/(1-P__)/4*P__),
	  1/2+(1-P)/2*(1-P1-P3)/2/(1-P_), #c1
	  P/4+(1-P)/4-(1-P)/2*(1-P1-P3)/4/(1-P_)+(1-P)/2*(1-P1-P2)/2/(1-P__), #c2
	  (1-P)/2*(P1/8+P3/8-(1-P1-P3)*P_/8/(1-P_)-(1-P1-P2)/4/(1-P__)), #c3
	  -(1-P)/2*(1-P1-P2)*P__/8/(1-P__)) #c4	
}

for (t in 5:Tt) {
	c <- cal_coef(P[t],P[t-1],P[t-2],P1[t-1],P2[t-1],P3[t-1])
	#print(sum(c))
	p1[t] <- c[2]*p1[t-1]+c[3]*p1[t-2]+c[4]*p1[t-3]+c[5]*p1[t-4]
}


#plot loss rate of heterozygosity
plot(2:Tt,1-p1[-1]/p1[-Tt],type="l",col="red",xlim=c(5,30),ylim=c(0.025,0.2),ylab="Loss rate of heterozygosity",xlab="Generation")
abline(v=min(which(N==C)))

#plot effective population size
#plot(2:Tt,-1/2/(p1[-1]/p1[-Tt]-1),type="l",col="red",xlim=c(5,30),ylim=c(2,15),ylab="Effective population size",xlab="Generation")
#abline(v=min(which(N==C)))

#diploid arrhenotoky
#initialize 
p2 <- rep(0,Tt)

p2[1] <- (1-f1)*p0
f2 <- (1/2+3/2*f1)/2
p2[2] <- (1-f2)*p0
ff2 <- (1+3*f1)/4/n+(1+7*f1)/8*(1-1/n)
f3 <- P[3]*(1/4+1/4*f1)+f2/2+(1-P[3])/2*ff2
p2[3] <- (1-f3)*p0
ff3 <- P1[3]/4*(1+2*f2+f1/2+f1/2)+P2[3]/4*(1/2+2*f2+f1/2+ff2)+P3[3]/4*(2*f2+f1+1/2+f1/2)+P4[3]/4*(2*f2+ff2+f1)
f4 <- P[4]*(1/4+1/4*f2)+f3/2+(1-P[4])/2*ff3
p2[4] <- (1-f4)*p0


#define coefficients
cal_coef <- function (P,P_,P__,P1,P2,P3) {
	c(P/4+(1-P)/2*(P1/4+P2/8+P3/4/2-(1-P1-P3)/2/(1-P_)/4*P_-(1-P1-P2)/2/(1-P__)/4*P__),
	  1/2+(1-P)/2*(1-P1-P3)/2/(1-P_), #c1
	  P/4+(1-P)/4-(1-P)/2*(1-P1-P3)/4/(1-P_)+(1-P)/2*(1-P1-P2)/2/(1-P__), #c2
	  (1-P)/2*(P1/8+P3/8-(1-P1-P3)*P_/8/(1-P_)-(1-P1-P2)/4/(1-P__)), #c3
	  (1-P)/2*(P1/8+P2/8-(1-P1-P2)*P__/8/(1-P__))) #c4	
}

for (t in 5:Tt) {
	c <- cal_coef(P[t],P[t-1],P[t-2],P1[t-1],P2[t-1],P3[t-1])
	#print(sum(c))
	p2[t] <- c[2]*p2[t-1]+c[3]*p2[t-2]+c[4]*p2[t-3]+c[5]*p2[t-4]
}
#plot loss rate of heterozygosity
points(2:Tt,1-p2[-1]/p2[-Tt],type="l",col="blue")

#plot effective population size
#points(2:Tt,-1/2/(p2[-1]/p2[-Tt]-1),type="l",col="blue")

#complete-diploidy assuming exact varroa life history
#initialize 
p3 <- rep(0,Tt)

p3[1] <- (1-f1)*p0
f2 <- (1+3*f1)/4/n+(1+7*f1)/8*(1-1/n)
p3[2] <- (1-f2)*p0
fm2 <- (1/2+7/2*f1)/4
f3 <- P1[3]/4*(1+2*f2+f1)+P2[3]/4*(1/2+2*f2+f1/2+f2)+P3[3]/4*(2*f2+1/2+f1/2)+P4[3]/4*(2*f2+f2+fm2)
p3[3] <- (1-f3)*p0
if (N[t-2]>1) {
	fm3 <- f2/2+f2/4+P2[3]/(1-P1[3]-P3[3])/4*(1/2+f1/2)+P4[3]/(1-P1[3]-P3[3])/4*fm2
	f4 <- P1[4]/4*(1+2*f3+f2)+P2[4]/4*(1/2+2*f3+f2/2+f3)+P3[4]/4*(2*f3+1/2+f2/2)+P4[4]/4*(2*f3+f3+fm3)
} else {
	f4 <- P1[4]/4*(1+2*f3+f2)+P2[4]/4*(1/2+2*f3+f2/2+f3)
}
p3[4] <- (1-f4)*p0

#define coefficient
cal_coef <- function (P,P_,P1,P2,P3,P4,P1_,P2_,P3_,P4_) {
	c(P1/4+P2/8+P3/8+(1-P1-P2)/4*(P2_/(1-P1_-P3_)/8-P4_/(1-P1_-P3_)/(1-P1_-P2_)*(P1_/4+P2_/8+P3_/8)),
	  1/2+(1-P1-P3)/4+(1-P1-P2)/4*P4_/(1-P1_-P3_)/(1-P1_-P2_), #c1
	  P1/4+P2/8+P3/8+(1-P1-P2)/4*(3/4-P4_/(1-P1_-P2_)/(1-P1_-P3_)*(1/2+(1-P1_-P3_)/4)), #c2
	  (1-P1-P2)/4*(P2_/(1-P1_-P3_)/8-P4_/(1-P1_-P3_)/(1-P1_-P2_)*(P1_/4+P2_/8+P3_/8))) #c3	
}

for (t in 5:Tt) {
	if (N[t-2]>1) {
		c <- cal_coef(P[t],P[t-1],P1[t],P2[t],P3[t],P4[t],P1[t-1],P2[t-1],P3[t-1],P4[t-1])
		#print(sum(c))
		p3[t] <- c[2]*p3[t-1]+c[3]*p3[t-2]+c[4]*p3[t-3]
	} else {
		if (n>1) {
			c <- c(P1[t]/4+P2[t]/8,P1[t]/2+3*P2[t]/4,P1[t]/4+P2[t]/8)
			p3[t] <- c[2]*p3[t-1]+c[3]*p3[t-2]
		} else {
			c <- c(P1[t]/4,P1[t]/2,P1[t]/4)
			p3[t] <- c[2]*p3[t-1]+c[3]*p3[t-2]
		}
	}
}


#plot loss rate of heterozygosity
#points(2:Tt,p3[-1]/p3[-Tt]-1,type="l")

#plot effective population size
points(2:Tt,-1/2/(p3[-1]/p3[-Tt]-1),type="l")