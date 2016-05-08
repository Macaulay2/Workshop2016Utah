
-- Authors: Alberto F. Boix and Mordechai Katzman.

-- Email addresses: alberto.fernandezb@upf.edu (A. F. Boix), M.Katzman@sheffield.ac.uk (M. Katzman).

-- Funding: A. F. Boix is currently partially supported by MTM2010-20279-C02-01.

-- M. Katzman is supported by EPSRC grant EP/I031405/1.

-- Website of A. F. Boix: http://atlas.mat.ub.edu/personals/aboix/

-- Website of M. Katzman: http://www.katzman.staff.shef.ac.uk/

-- It is worth mentioning that this package is still being tested.

-- So, please report any bug to any of the precedent mail addresses.

-- Package based on the implementation of the algorithm which is the main

-- result of the following journal article:

-- Alberto F. Boix and M. Katzman, An algorithm for producing F-pure ideals.

-- Arch. Math. 103 (2014), 421-433.

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or (at
--  your option) any later version.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


clearAll;

-- ethRoot the implementation of the I_e() operation as described in

-- various papers, e.g. 

-- M Katzman, Parameter test ideals of Cohen Macaulay rings,
-- Compos. Math. volume 144, no. 4, 933--948, 2008.

-- Also in: 
-- J. Alvarez-Montaner, M. Blickle and G. Lyubeznik, Generators of D-modules in positive characteristic.
-- Math. Res. Lett., 12 (4): 459-473, 2005. 

-- Input:
-- ideals A and B of the same polynomial ring R OVER A FINITE FIELD OF PRIME CHARACTERISTIC.
-- a positive integer e
-- a prime p which is the characteristic of R

-- Output:
-- the smallest ideal J of R containing B with the property that A is in J^{[p^e]}


-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------- F Pure stuff --------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

-- The goal of the next two procedures is to compute all the 1-codimensional

-- vector subspaces of a given finite-dimensional vector space.

-- Input: a FINITE coefficient field F and a non-negative integer d.

-- Output: the list of all 1-codimensional vector subspaces of F^d.

VECTORSPACES=new MutableHashTable; --Fix this!!!
findAllOneDimensionalSubspaces = (F,d) ->(
local i;
local j;
local L;
local V;
p:=char F;
if (VECTORSPACES#?(p,d)) then
{
	L=VECTORSPACES#(p,d);
}
else
{
	Felements:=set apply(0..(p-1), i->substitute(i,F));
	V=Felements^**(d-1);
	V=V**set(0_F,1_F);
	V=toSequence elements(V); V=apply(V,splice);
	M:=compress transpose matrix toList apply(V, v->toList(v));
	R0:=F[lv_1..lv_d];
	L=(vars(R0))*M;
	L=apply(first entries L, i->ideal i);
	L0:={};
	apply(L, i->
	{
		if (not any(L0,j -> j == i)) then L0=append(L0,i);
	});
	L=apply(L0, i->(coefficients(i_0, Monomials=>toList(lv_1..lv_d)))#1);
	VECTORSPACES#(p,d)=L;
};
L
);

----------------------------------------------------------------------------------------

findOrthogonalComplement = (v) ->(
substitute(gens kernel transpose v, coefficientRing(ring(v)))
)

-------------------- MAIN ALGORITHM-----------------------------------------

-- Our next aim is to produce the main algorithm of this package. Such

-- procedure computes all the F-pure ideals of a given polynomial ring

-- over a FINITE field with respect to a suitable ring element u.

-- For more theoretical details, the reader is encouraged to consult the following paper:
       
-- Alberto F. Boix and M. Katzman, An algorithm for producing F-pure ideals.

-- Arch. Math. 103 (2014), 421-433.

-- Input: a ring element u inside a polynomial ring R with FINITE ground field.

-- Output: the list of all F-pure ideals.

FPureIdeals=method();

-- Next procedure implements the 0th step of our algorithm.

FPureIdeals(RingElement) := (u) ->(
R:=ring(u);
local L;
local K;
K=boundLargestCompatible(ideal(1_R),u);
L={};
excludeList={};
FPureIdealsInnards (u,K,L)
)

-- Now, the recursive block of our method.

FPureIdealsInnards = (u,K,L) ->(
R:=ring(u);
local V;
local K0;
local K2;
local M;
local T;
local f;
local d;
local v;
local v1;
local I0;
local I1;
excludeList= unique append(excludeList,K);
if ((not any(L,T -> T == K))) then L=append(L,K);
-- print(last L);
-- print(" ");
-- print(#L);
-- print(" ");
K0=ideal(vars(R))*K;
M= (K/K0);
G:=mingens M;
d=rank source G;
if (d>0) then
{
         if (d>1) then
         {
                  V=findAllOneDimensionalSubspaces(coefficientRing(R),d);
                  V=apply(V, v->findOrthogonalComplement(v));
                  apply(V, v->
                  {
                           v1=G*v;
                           I0=ideal(v1)+K0;
                           I1=boundLargestCompatible( I0, u);
                           if ((not any(L,T-> T==I1))) then L=append(L,I1);
                           if (not any(excludeList,T -> T == I1)) then
                           {
                                   L=unique(L | FPureIdealsInnards (u,I1,L));
                           };
                  });
         }
         else
         {
             K2=boundLargestCompatible(K0,u);
             if (not any(excludeList,T -> T == K2)) then
             {
                     L=unique(L | FPureIdealsInnards (u,K2,L));
             };
         };
};
L
);

---------------------- MORE AUXILIAR METHODS --------------------------------


gauge=method();

-- The following procedure compute the infinity norm of the ideal I.

-- Input: ideal I inside a polynomial ring.

-- Output: the infinity norm of I; namely, the maximum infinity norm

-- over a set of minimal generators of I.

gauge(Ideal) := (I) ->(
local g;
local e;
local T;
local t;
G:=first entries mingens(I);
answer:=-1;
apply(G, g->
{
	T=terms(g);
	apply(T, t->
	{
		e=max flatten exponents (t);
		answer=max(answer,e);
	}); 	
});
answer
);

----------------------------------------------------------------------------------------

isFPure=method();

-- The following method tests whether a given ideal is F-pure or not.

isFPure(Ideal,RingElement) := (I,u) ->(
I1:=ideal(u)*I;
R:=ring(I);
I2:=ethRoot(I1,ideal(0_R),1);
(I2==I)
);

-- The input list must be a list of ideals.

-- Specially devoted for debugging purposes.

isFPure(List,RingElement) := (L,u) ->(
local i;
print(" ");
apply(L,i->
{
           print(i,isFPure(i,u));
           print(" ");
});
);

-- The input sequence must be a sequence of ideals.

-- Specially devoted for debugging purposes.

isFPure(Sequence,RingElement) := (L,u) ->( isFpure(toList L,u));

----------------------------------------------------------------------------------------

boundLargestCompatible=method();

-- The following procedure computes the so-called hash operation described in:

-- Alberto F. Boix and M. Katzman, "An algorithm for producing F-pure ideals".

-- Input: ideal P and polynomial u inside a common polynomial ring.

-- Output: the ideal P^{\#} defined in the precedent paper.

boundLargestCompatible(Ideal,RingElement) := (P,u) ->(
local answer;
local P1;
local P2;
R:=ring(P);
p:=char(R);
g:=max(gauge(ideal(u)),1); x1:=ceiling(g/(p-1))+1;
V:=first entries vars(R);
M:=gens ideal apply(V, v-> v^x1);
f:=true;
answer=P;
while (f) do
{
	P1=(frobeniusPower(1,answer)):u;
	P1=intersect(answer,P1);
	P2=ideal(u)*answer;
	P2=ethRoot(1,P2);
	P1=intersect(P1,P2);
	P1=compress((gens(P1))%M);
	P1=ideal(P1);
	if (isSubset(answer,P1)) then f=false;
	answer=P1;
};
answer
);

---------------------- SOME ADDITIONAL AUXILIAR METHODS -------------------

findAllFPurePrimes=method();

-- Input: a list L of ideals. The output is only the list of prime ideals

-- of the starting list L.

findAllFPurePrimes(List):= (L)->(
local M;
M={};
local i;
R:=ring(L#0);
apply(L,i->
{
           if (i!= ideal(0_R)) then
           {
                   if (isPrime i) then M=append(M,i);
           };
});
M
);

---------------------- EXAMPLES--------------------

exampleNCD=method();

-- The input d must be an strictly positive integer.

-- The input p must be a prime number.

-- The output turns out to be all the squarefree monomial ideals

-- of our current polynomial ring.

exampleNCD(ZZ,ZZ):= (d,p)->(
     F:=ZZ/p;
     R:=F[x_1..x_d];
     N:=p-1;
     vv:=first entries vars(R);
     local i;
     vv=toList apply(vv, i-> i^N);
     u:=product vv;
     L:=FPureIdeals(u);
     L
);

theMinor=method();

theMinor(ZZ,ZZ):=(i,j)->(x_i*y_j-x_j*y_i);

exampleMinor=method();

-- The input d must be an strictly positive integer and p must be a prime number.

-- The case d=3 and p=2 has been already analized in the following paper:
       
-- M. Katzman. "A non-finitely generated algebra of Frobenius maps",

-- Proc. Amer. Math. Soc. 138 (2010), no. 7, 2381-2383.

-- See Section 2

-- The case d=4 and p=2 has been already analized in the following manuscript:
       
-- M. Katzman and K. Schwede. "An algorithm for computing compatibly Frobenius split subvarieties",

-- J. Symbolic Comput. 47 (2012), no. 8, 996-1008.

-- See Example 7.4

exampleMinor(ZZ,ZZ):=(d,p)->(
     F:=ZZ/p;
     R:=F[x_1..x_d,y_1..y_d];
     local i;
     L:=apply(2..d,i->theMinor(1,i));
     u:=product toList L;
     N:=p-1;
     u=u^N;
     L=FPureIdeals(u);
     L
);

exampleFInjectiveFalse=method();

-- The input d must be an strictly positive integer.

-- The input p must be a prime number.

-- The most interesting case (from our point of view) is when d=3 and p=5.

-- In such case, the list of F-pure ideals of a non-F-injective ring is produced.

exampleFInjectiveFalse(ZZ,ZZ):=(d,p)->(
     F:=ZZ/p;
     R:=F[x_1..x_d];
     N:=p-1;
     vv:=first entries vars(R);
     local i;
     vv=apply(vv,i->i^N);
     u:=sum toList vv;
     u=u^N;
     L:=FPureIdeals(u);
     L
);

exampleKatzmanCompositio=method();

-- The input n may be any integer.

-- The following example has been already analized in several previous papers.

-- M. Katzman. "Parameter test ideals of Cohen-Macaulay rings",

-- Compos. Math. 144 (2008), no. 4, 933-948.

-- See Section 9.

-- M. Katzman and K. Schwede. "An algorithm for computing compatibly Frobenius split subvarieties",

-- J. Symbolic Comput. 47 (2012), no. 8, 996-1008.

-- See Example 7.2

exampleKatzmanCompositio(ZZ):= (n)->(
     p:=2;
     F:=ZZ/p;
     R:=F[x_1..x_5];
     A:=matrix{{x_1,x_2,x_2,x_5},{x_4,x_4,x_3,x_1}};
     I:=minors(2,A);
     J:=frobeniusPower(I,1);
     K:=quotient(J,I);
     L:=compress((gens K)%(gens J));
     L=first entries L;
     u:=L#2;
     L=FPureIdeals(u);
     L
);

exampleKatzmanSchwedeDismissed=method();

-- The input n may be any integer.

-- For more information about the interest of this example, the user

-- is encouraged to consult the following link:
      
-- http://www.katzman.staff.shef.ac.uk/FSplitting/interestingExample2.m2

exampleKatzmanSchwedeDismissed(ZZ):= (n)->(
p:=2;
F:=ZZ/p;
R:=F[y_1..y_7];
u:=y_1*y_3*y_4^2*y_5^3*y_6+y_2*y_3*y_4^3*y_6^3+y_1^2*y_4*y_5^4*y_7+y_2*y_3^2*y_4*y_5^2*y_6*y_7+y_1*y_2*y_4^2*y_5*y_6^2*y_7+y_1*y_2*y_3*y_5^3*y_7^2+y_2^2*y_3*y_4*y_6^2*y_7^2+y_1*y_2^2*y_5*y_6*y_7^3;
L:=FPureIdeals(u);
L
);

exampleParameter=method();

-- The input p must be a prime number.

-- We are mainly interested in case p=2.

exampleParameter(ZZ):= (p)->(
F:=ZZ/p;
R:=F[x_1..x_3];
u:=x_1^2 *x_2 *x_3 *(x_1 +1);
N:=p-1;
u=u^N;
L:=FPureIdeals(u);
L
);

exampleKatzmanSchwedeStarting=method();

-- The input p must be a prime number.

-- It is worth to mention that this example was already treated in the

-- following journal article:

-- M. Katzman and K. Schwede. "An algorithm for computing Frobenius split subvarieties",

-- J. Symbolic Comput. 47 (2012), no. 8, 996-1008.

-- See Example 7.1

exampleKatzmanSchwedeStarting(ZZ):= (p)->(
     F:=ZZ/p;
     R:=F[x_1..x_4];
     u:=x_1 +1;
     u=u*x_1;
     u=u*(x_4^2);
     u=u*((x_1^2)-(x_2 *x_3));
     u=u*((x_1^2)-(x_2 *x_3));
     L:=FPureIdeals(u);
     L
);

exampleSchubert=method();

-- The input n may be any integer.

-- It is worth to mention that this example was already treated in the

-- following journal article:

-- M. Katzman and K. Schwede. "An algorithm for computing Frobenius split subvarieties",

-- J. Symbolic Comput. 47 (2012), no. 8, 996-1008.

-- See Example 7.3

exampleSchubert(ZZ):=(n)->(
     p:=2;
     F:=ZZ/p;
     R:=F[x_(2,1),x_(3,1),x_(4,1),x_(3,2),x_(4,2),x_(4,3)];
     u:=x_(4,1);
     u=u*((x_(3,1)*x_(4,2))-(x_(4,1)*x_(3,2)));
     u=u*(x_(4,1)-(x_(2,1)*x_(4,2))-(x_(3,1)*x_(4,2))+(x_(2,1)*x_(3,2)*x_(4,3)));
     L:=FPureIdeals(u);
     L
);

exampleSchoenQuintic=method();

-- The input p must be a prime number.

exampleSchoenQuintic(ZZ):= (p)->(
F:=ZZ/p;
R:=F[x_0..x_4];
u:=x_0^5 +x_1^5 +x_2^5 +x_3^5 + x_4^5 -5*x_0 *x_1 *x_2 *x_3 *x_4;
N:=p-1;
u=u^N;
L:=FPureIdeals(u);
L
);

exampleKatzmanLondon=method();

-- The input p must be a prime number strictly greater than 3.

-- The reader should notice that such example was already analized

-- in the following journal article:

-- M. Katzman. "Frobenius maps on injective hulls and their applications to tight closure",

-- J. London Math. Soc. (2) 81 (2010), 589-607.

-- See Example 5.6.

exampleKatzmanLondon(ZZ):= (p)->(
F:=ZZ/p;
R:=F[a,b,c];
N:=p-1;
u:=b*(b-c)*(a-b);
u=u^N;
L:=FPureIdeals(u);
L
);

exampleKatzmanLondonStarting=method();

-- The input p must be a prime number.

-- The reader should notice that such example was already analized

-- in the following journal article:

-- M. Katzman. "Frobenius maps on injective hulls and their applications to tight closure",

-- J. London Math. Soc. (2) 81 (2010), 589-607.

-- See Example 3.6.

exampleKatzmanLondonStarting(ZZ):= (p)->(
F:=ZZ/p;
R:=F[a,b,c,d];
A:=matrix{{b*c,a^2 *d}, {a,d^2},{0,c+d}};
I:=minors(2,A);
J:=frobeniusPower(I,1);
K:=quotient(J,I);
L:=compress((gens K)%(gens J));
L=first entries L;
u:=last L;
L=FPureIdeals(u);
L
);

exampleJunLanceKazuma=method();

exampleJunLanceKazuma(ZZ):= (p)->(
F:=ZZ/p;
R:=F[x,y,z,w];
I:=ideal(x*y,x*w,w*(y-z^2));
J:=frobeniusPower(I,1);
K:=quotient(J,I);
L:=compress((gens K)%(gens J));
L=first entries L;
print L;
u:=last L;
L=FPureIdeals(u);
L
);

determinantalGenericExample=method();

determinantalGenericExample(ZZ,ZZ):=(d,p)->(
if (d<=0) then error("The first input must be an strictly positive integer.");
if(not isPrime(p)) then error("The second input must be a prime number.");
t:=d-1;
F:=ZZ/p;
n:=d*d;
R:=F[x_1..x_n];
M:=genericMatrix(R,d,d);
I:=minors(t,M);
J:=frobeniusPower(I,1);
K:=quotient(J,I);
L:=compress((gens K)%(gens J));
L=first entries L;
-- print L;
u:=last L;
L=FPureIdeals(u);
L
);

exampleBrennerMonsky=method();

exampleBrennerMonsky (ZZ):=(p)->(
F:=ZZ/p;
R:=F[x,y,z,t];
u:=z^2;
u=x*y+u;
u=u*z;
u=u+x^3+y^3;
u=u*z;
u=u+t*x^2*y^2;
I:=ideal(u);
J:=frobeniusPower(I,1);
K:=quotient(J,I);
L:=compress((gens K)%(gens J));
L=first entries L;
print L;
u=last L;
L=FPureIdeals(u);
L
);

exampleMarkovUpperClusterAlgebra=method();

exampleMarkovUpperClusterAlgebra(ZZ,ZZ):=(a,p)->(
F:=ZZ/p;
R:=F[x,y,z,t];
u:=x*y*z*t-x^a-y^a-z^a;
I:=ideal(u);
J:=frobeniusPower(I,1);
K:=quotient(J,I);
L:=compress((gens K)%(gens J));
L=first entries L;
u=last L;
L=FPureIdeals(u);
L
);
