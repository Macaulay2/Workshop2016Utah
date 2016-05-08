newPackage(
	"RandomIdeal",
    	Version => "1.0", 
    	Date => "April 25, 2009",
    	Authors => {
	     {Name => "David Eisenbud", Email => "de@msri.org"}
	     },
    	HomePage => "http://www.msri.org/~de",
    	Headline => "a package for creating random ideals of various sorts",
	AuxiliaryFiles => false, -- set to true if package comes with auxiliary files,
    	DebuggingMode => false,	 -- set to true only during development
	Reload => true 
    	)

export {
     "randomIdeal",
     "randomMonomialIdeal",
     "randomSquareFreeMonomialIdeal",
     "randomSquareFreeStep",
     "randomBinomialIdeal",
     "randomPureBinomialIdeal",
     "randomSparseIdeal",
     "randomElementsFromIdeal",
     "randomMonomial",
     "squareFree",
     "regSeq",
     "AlexanderProbability",
        "randomAddition", 
	"randomChain",
        "idealFromShelling",
	"idealChainFromShelling",
        "isShelling",
	"randomShellableIdeal"
     }

randomMonomial = method(TypicalValue => RingElement)
randomMonomial(ZZ,Ring) := RingElement => (d,S) -> (
     m := basis(d,S);
     m_(0,random rank source m))

   
randomMonomialIdeal=method(TypicalValue => Ideal)

randomMonomialIdeal(Sequence, Ring) := Ideal => (L,S)-> 
     randomMonomialIdeal(toList L, S)

randomMonomialIdeal(List, Ring) := Ideal => (L,S)->(
     --produces an ideal minimally generated 
     --by random monomials of degrees given in L,
     --unless the low degree terms generate all monomials 
     --in one of the higher degrees requested,
     --in which case the ideal fulfills as many of 
     --the conditions as possible (from lowest degree),
     --and produces a message.
     --
     --first produce a list in ascending order of degree, 
     --specifying how many elements are required from that degree
     Lu := sort unique L;
     Ls := apply(Lu, t -> #positions(L, s->(s==t)));
     --handle the initial degree
     M := flatten entries basis(Lu#0, S^1);
     if Ls#0 < #M then I := ideal((random M)_{0..Ls#0-1})
	  else (
	       I = ideal(M);
       	       <<"***** there are only " 
	       << binomial(Lu#0+numgens S-1,Lu#0)
	       <<" monomials of degree " 
	       << Lu#0 
	       <<endl;
	       return I
	       );
     --now the rest of the degrees, if any.
     for t from 1 to #Lu-1 do (
	  M = flatten entries compress (basis(Lu#t,S^1) % I);
	  if Ls#t < #M then I = I+ideal((random M)_{0..Ls#t-1})
	  else (
	       if #M=!=0 then I = I+ideal(M);
	       print("low degree gens generated everything"); 
	       break)
	  );
     I
     ) 
randomSquareFreeMonomialIdeal=method(TypicalValue => Ideal)

randomSquareFreeMonomialIdeal(Sequence, Ring) := Ideal => (L,S)-> 
     randomSquareFreeMonomialIdeal(toList L, S)

randomSquareFreeMonomialIdeal(List, Ring) := Ideal => (L,S)->(
     --L is a list of degrees desired, The routine
     --produces an ideal minimally generated by random 
     --square-free monomials of exactly the numbers and degrees given in L,
     --unless the low degree terms generate 
     --all monomials in one of the higher degrees requested,
     --in which case the ideal fulfills as 
     --many of the conditions as possible (from lowest degree).
--
     --first produce a list in ascending order of degree, specifying how many elements are required from that degree
     Lu := sort unique L;
     Ls := apply(Lu, t -> #positions(L, s->(s==t)));
     M := flatten entries gens squareFree(Lu#0, S);
     if Ls#0 < #M then I := ideal((random M)_{0..Ls#0-1})
	  else (I = ideal(M);
	       <<"***** there are only " <<binomial(numgens S,Lu#0)<<
		    " square-free monomials of degree " << Lu#0 <<endl;
	       return I
	       );
     for t from 1 to #Lu-1 do (
	  M=flatten entries compress (gens squareFree(Lu#t,S) % I);
	  if Ls#t < #M then I = I+ideal((random M)_{0..Ls#t-1})
	  else (if #M=!=0 then I = I+ideal(M);
	       print("low degree gens generated everything");
	       break
	       )
	  );
     I
     ) 


randomSquareFreeStep = method(Options=>{AlexanderProbability => .05})

soc = I -> (
     --I should be a MonomialIdeal
     p:=product gens ring I;
     apply(flatten entries gens dual I, m->p//m))

prepare= I->(
     --I should be a MonomialIdeal
     Igens := flatten entries gens I;
     ISocgens := soc I;
     {I,Igens,ISocgens})

randomSquareFreeStep(Ideal) := o -> (I) ->(
     if  isMonomialIdeal I then randomSquareFreeStep(monomialIdeal I, o)
     else error "ideal not generated by monomials")
randomSquareFreeStep(MonomialIdeal) := o -> (I) ->(
     if isSquareFree I then randomSquareFreeStep (prepare I, o)
     else error "ideal not square-free")
     
     
     
     

randomSquareFreeStep(List) := o -> (L) ->(
     I := L_0;
     S := ring I;
     mm := monomialIdeal vars S;
     mm2 := monomialIdeal apply (flatten entries vars S, p->p^2);
     --With probability given by the option AlexanderProbability (default .05),
     --the routine simply returns the Alexander dual of I. 
     if random RR <o.AlexanderProbability then return prepare dual I;
     --form a candidate step
     Igens := L_1;
     nI := #Igens;
     ISocgens := L_2;
     nSocI := #ISocgens;
     if random RR < nSocI/(nI+nSocI) then
	  J := I + monomialIdeal ISocgens_(random nSocI)
     else (
	  --p := random nI;
	  p := monomialIdeal Igens_(random nI);
--	  p' := select(toList(0..nI-1), j->j!=p);
	  p' := I-p; -- returns the ideal generated by all the gens but p
	  sqFreeMults := (mm*p)-mm2;
--  	  sqFreeMults := substitute(monomialIdeal(gens(mm*ideal(Igens_p))%mm2), S);
--	  J = trim (ideal(Igens_p')+sqFreeMults)
  	  J = p'+sqFreeMults
	  );
     --Decide whether to accept the step or not
     Jgens := flatten entries gens J;
     nJ := #Jgens;
     JSocgens := soc J;
     nSocJ := #JSocgens;
     --accept with probability P (if P<1) or unconditionally (P>=1):
     P := (nI+nSocI)/(nJ+nSocJ);
     if random RR < P then {J,Jgens,JSocgens} else {I,Igens,ISocgens}
     )


squareFree = method(TypicalValue => Ideal)

squareFree(ZZ,Ring) := Ideal => (d,S) ->
--returns the ideal generated by all square free monomials of degree d
ideal compress(basis(d,S^1) % ideal apply (flatten entries vars S, p -> p^2))

randomPureBinomialIdeal = method(TypicalValue => Ideal)
randomPureBinomialIdeal(Sequence, Ring) := Ideal => (L,S)->randomPureBinomialIdeal(toList L, S)
randomPureBinomialIdeal(List, Ring) := Ideal => (L,S)->(
     --L=list of degrees of the generators
     trim ideal apply(L, d->randomMonomial(d,S)-randomMonomial(d,S))
     )

randomBinomialIdeal = method(TypicalValue => Ideal)
randomBinomialIdeal(Sequence, Ring) := Ideal => (L,S)->randomPureBinomialIdeal(toList L, S)
randomBinomialIdeal(List, Ring) := Ideal => (L,S)->(
     --L=list of degrees of the generators
     kk:=ultimate (coefficientRing, S);
     trim ideal apply(L, d->randomMonomial(d,S)-random(kk)*randomMonomial(d,S))
     )

randomSparseIdeal = method(TypicalValue => Ideal)
randomSparseIdeal(Matrix, ZZ, ZZ) := Ideal => (B,s,n) -> (
     -- B is a 1xt matrix of monomials
     -- s is the size of each poly
     -- n is the number of polys
     S := ring B;
     t := rank source B;
     BB := (first entries B);
     kk := ultimate(coefficientRing, S);
     trim ideal apply(n, j -> 
     sum apply(s, i -> random kk * BB#(random t)))
     )

randomIdeal = method(TypicalValue => Ideal)
randomIdeal(Sequence,Matrix) := Ideal => (L,B) -> randomIdeal(toList L, B)
randomIdeal(List,Matrix) := Ideal => (L,B) -> (     
     -- B is a 1 x n matrix of homogeneous polynomials
     -- L is a list of degrees
     trim ideal(B * random(source B, (ring B)^(-L)))
     )

regSeq = method(TypicalValue => Ideal)
regSeq (Sequence, Ring) := Ideal => (L,S)-> regSeq(toList L, S)
regSeq (List, Ring) := Ideal => (L,S)->(
     --forms an ideal generated by powers of the variables.
     --L=list of NN. uses the initial subsequence of L as powers
     ideal for m to min(#L,rank source vars S)-1 list S_m^(L_m))

randomElementsFromIdeal =  method(TypicalValue => Ideal)
randomElementsFromIdeal(List, Ideal) := Ideal => (L,I)->(
trim ideal((gens I)*random(source gens I, (ring I)^(-L))))


----------From Shelling

testNewSimplex = method()
testNewSimplex(List, List) := (P, D) ->(
--given a pure, d-dimensional simplicial complex (sc) as a list of ordered lists of d+1 vertices in [n], and
--a simplex D as such a list, tests whether the intersection of D with P is a union of facets of D.
     d := #D-1; --dimension
     ints := apply(P, D' -> intersectLists(D',D));
     facets := apply(unique select(ints, E -> #E==d),set);
     antiFacets := apply(facets,F -> (D-F)#0);
     if facets == {} then return false;
     smalls := unique select(ints, E -> #E<d);
     all(smalls, e -> any(antiFacets, v -> not member(v,e)))
)

subsetList = (A,B) -> (
    --checks if A\subset B. requires that both lists be sorted
    lenA := #A;
    lenB := #B;
    a := 0;
    b := 0;
    while (lenA-a)<=(lenB-b) and a<lenA and b<lenB do (
        if A_a<B_b then return false;
        if A_a==B_b then a=a+1;
        b = b+1;
    );
    a==lenA
)

intersectLists = (D',D) -> D - set(D-set D')

randomSubset = (n,m) -> (
    L := new MutableList from toList (0..m-1);
    for i from m to n-1 do (
	j := random(i+1);
    	if j < m then L#j = i;
	);
    sort toList L
    )

randomAddition = method()
randomAddition(ZZ,ZZ,List) := (n,m,P) ->(
    if #P == 0 then return {randomSubset(n,m+1)};
    Plarge := select(P, D-> #D >= m); -- the facets big enough to be glued to
    if #Plarge == 0 then error "m is too large";
    t := false;
    D' := {null};
    D := Plarge#(random(#Plarge)); -- a random facet from Plarge
    compD := toList(0..n-1) - set D;
    count := 0;
    while not t and count < 20 do (
    	i := random (#compD);
    	J := randomSubset(#D,#D-m);
    	D' = sort(D - set apply(J, j->D_j) | {compD_i});
    	t = (testNewSimplex(P,D'));
	count = count+1);
    if count == 20 then return P;
    unique (P|{D'})
    )

randomAddition(Ring,ZZ,List) := (R,m,L) -> (
    P := monomialsToLists(L,R);
    listsToMonomials(randomAddition(numgens R,m,P),R)
    )

idealFromShelling = method()
idealFromShelling (Ring,List) := (S,P) -> (
    Delta := toList (0..numgens S - 1);
    V := vars S;
    intersect apply(P, D -> ideal(V_(Delta - set D)))
    )

idealFromShelling List := P -> (
    n := (max flatten P)+1;
    x := symbol x;
    S := QQ[x_0..x_(n-1)];
    idealFromShelling(S,P)
    )

idealChainFromShelling = method()
idealChainFromShelling(Ring,List) := (S,P) -> toList apply(#P,i->idealFromShelling(S,take(P,i+1)))
idealChainFromShelling List := P -> toList apply(#P,i->idealFromShelling(take(P,i+1)))

isShelling = method()
isShelling(List) := P -> all(#P, i-> i==0 or testNewSimplex(take(P,i),P#i))

randomChain = method()
-- random chain of shellable complexes on n vertices, with pure dim m, up to the complete m skeleton

randomChain(ZZ,ZZ) := (n,m) -> randomChain(n,m,binomial(n,m+1))
-- random chain of shellable complexes on n vertices, with pure dim m, and k facets

--Should we change the following to start with {{0..m}, {0..m-1,m} to diminish autos?
randomChain(ZZ,ZZ,ZZ) := (n,m,k) -> (
    if k > binomial(n,m+1) then error "k is too large";
    P := {};
    while #P < k do P = randomAddition(n,m,P);
    P
    )
randomShellableIdeal=method()
randomShellableIdeal(Ring,ZZ,ZZ) := (R,dimProj,deg) -> (
    idealFromShelling(R,randomChain(numgens R ,dimProj, deg))
    )

///
S = ZZ/101[x_0..x_5]
I = randomShellableIdeal(S,2,5)
dim I == 3
degree I == 5
///

randomChain(Ring,ZZ,ZZ) := (R,m,k) -> listsToMonomials(randomChain(numgens R,m,k),R)
randomChain(Ring,ZZ)    := (R,m)   -> listsToMonomials(randomChain(numgens R,m),R)

--this is NOT the Reisner association
listsToMonomials = (P,R) -> apply(P, D->product apply(D,d->R_d))
monomialsToLists = (L,R) -> apply(L, m->select(numgens ring m, i->((listForm m)#0#0#i > 0)))


------------------------------------------------------------
-- DOCUMENTATION randomChain
------------------------------------------------------------

doc ///
     Key
          randomChain
	  (randomChain,ZZ,ZZ)
	  (randomChain,ZZ,ZZ,ZZ)
	  (randomChain,Ring,ZZ)
	  (randomChain,Ring,ZZ,ZZ)
     Headline
          produces a random chain of shellable complexes
     Usage
          P=randomChain(n,m)
	  P=randomChain(n,m,k)
	  P=randomChain(R,m)
	  P=randomChain(R,m,k)
     Inputs
          n:ZZ
	       the number of vertices
	  R:Ring
	       a polynomial ring with a variable for each vertex
	  m:ZZ
	       the dimension of the facets
	  k:ZZ
	       the number of facets (if ommited, the number will be {\tt n} choose {\tt m+1})
	      
     Outputs
          P:List
	       A list of lists of integers.  Each list of integers is a facet of the complex and the order is a shelling.  If called with a Ring {\tt R} instead of an integer {\tt n}, each facet is represented by a square-free monomial instead of a list.
     Description
          Text
              The function produces a random chain of shellable complexes.  
          Example
               P = randomChain(6,3,10)
	       Q = randomChain(6,3)
     Caveat
	  No claim is made on the distribution of the random chain.
///


------------------------------------------------------------
-- DOCUMENTATION isShelling
------------------------------------------------------------
doc ///
     Key
          isShelling
	  (isShelling,List)
     Headline
          determines whether a list represents a shelling of a simplicial complex.
     Usage
          b = isShelling(P)
     Inputs
          P:List
	       A list of lists of integers.  Each list of integers is a facet of the complex and the order is a possible shelling.
     Outputs
          b:Boolean
	       true if and only if P is a shelling.
     Description
          Text
              Determines if a list of faces is a shelling order of the simplicial complex. 
          Example
	      P = {{1, 2, 3}, {1, 2, 5}};
	      isShelling(P)
	      Q = {{1,2,3},{3,4,5},{2,3,4}};
	      isShelling(Q)	     
///


------------------------------------------------------------
-- DOCUMENTATION randomAddition
------------------------------------------------------------
doc ///
     Key
          randomAddition
	  (randomAddition,ZZ,ZZ,List)
	  (randomAddition,Ring,ZZ,List)
     Headline
          Adds a random facet to a shellable complex
     Usage
          p=randomAddition(n,m,P)
	  p=randomAddition(R,m,P)
     Inputs
     	  n:ZZ
	       the number of vertices (if a ring is specified, {\tt n} is the number of variables. 
	  m:ZZ
	       the dimension of the new facet
          P:List
	       A list of lists of integers.  Each list of integers is a facet of the complex and the order is a shelling.
	  R:Ring
	      A polynomial ring. 
     Outputs
          p:List
	       A list of lists of integers.  Each list of integers is a facet of the complex and the order is a shelling.
     Description
          Text
            This function randomly chooses a facet of size m+1 and checks whether the facet can be shellably added to the shelling. 
	    If it can be shellably added to the shelling, it is added to the shelling and the new shelling is returned. 
	    Otherwise, the process repeats up to 20 times.  
          Example
            P={{1,2,3}}
	    L=randomAddition(6,3,P)
     Caveat
	  If the input is not a shellable simplicial complex, the new complex will not be shellable.
///


------------------------------------------------------------
-- DOCUMENTATION idealFromShelling
------------------------------------------------------------
doc ///
     Key
          idealFromShelling
	  (idealFromShelling,List)
	  (idealFromShelling,Ring,List)
     Headline
          Produces an ideal from a shelling
     Usage
          I = idealFromShelling(P)
	  I = idealFromShelling(S,P)
     Inputs
	  S:Ring
	      (If omitted, it will use {\tt S=QQ[x_0..x_(n-1)]} where {\tt n} is the maximum integer in the lists of {\tt P}.  
          P:List
	       A list of lists of integers.  Each list of integers is a facet of the complex and the order is a shelling.
     Outputs
          I:Ideal
	      generated by the monomials representing the minimal nonfaces of {\tt P}
     Description
          Text  
	      This gives the Stanley-Reisner ideal for the simplicial complex, that is the ideal generated by the monomials representing the minimal nonfaces of {\tt P}. 
          Example
	      S = QQ[x_0,x_1,x_2,x_3,x_4]
	      P =  {{1, 2, 4}, {0, 1, 4}, {0, 2, 4}, {0, 3, 4}};
	      idealFromShelling(S,P)
         
     
///


------------------------------------------------------------
-- DOCUMENTATION idealChainFromShelling
------------------------------------------------------------
doc ///
     Key
          idealChainFromShelling
	  (idealChainFromShelling,List)
	  (idealChainFromShelling,Ring,List)
     Headline
          Produces chains of ideals from a shelling.
     Usage
          L = idealChainFromShelling(P)
	  L = idealChainFromShelling(R,P)
     Inputs
     	  R:Ring
	      Polynomial ring
          P:List
	       A list of lists of integers.  Each list of integers is a facet of the complex and the order is a shelling.
     Outputs
          L:List
	      a list of ideals
     Description
          Text  
	     Outputs the Stanley-Reisner ideal for each successive simplicial complex formed by truncating the shelling. 
	  Example
	      P =  {{1, 2, 4}, {0, 1, 4}, {0, 2, 4}, {0, 3, 4}};
	      idealChainFromShelling(P)
         
     
///

------------------------------------------------------------
-- DOCUMENTATION randomShellableIdeal
------------------------------------------------------------
doc ///
     Key
          randomShellableIdeal
	  (randomShellableIdeal,Ring,ZZ,ZZ)
     Headline
          Produces a random ideal from a shellable simplicial complex
     Usage
          I = randomShellableIdeal(R,m,k)
     Inputs
          R:Ring
	      a polynomial ring
	  m:ZZ
	      dimension of facets in shellable complex
	  k:ZZ
	      the degree of the shellable simplicial complex
     Outputs
          I:Ideal
	      generated by the monomials representing the minimal nonfaces of a random shellable simplicial complex.
     Description
          Text  
          Example
///         

TEST///
assert(#randomChain(5,2,6)==6)
assert(#randomChain(5,2)==binomial(5,3))
R=QQ[x1,x2,x3,x4,x5];
assert(#randomChain(R,2,6)==6)
///


TEST///
assert(isShelling({}))
assert(isShelling({{1,2,3}}))
assert(isShelling({{1,2,3},{2,3,4}}))
assert(isShelling(randomChain(5,3,5)))
--non pure shellings
assert(isShelling({{1,2,3},{2,4}}))
assert(isShelling({{1},{2}}))
assert(not isShelling({{1,3},{2,4}}))
assert(isShelling({{1,2},{3}}))
assert(not isShelling({{3},{1,2}}))
///


TEST///
setRandomSeed(0);
assert(#randomAddition(6,3,{{1,2,3}})==2)
assert(#randomAddition(6,3,{{1,2,3,4}})==2)
///

TEST///
needsPackage "SimplicialComplexes"
needsPackage "SimplicialDecomposability"
R=QQ[x1,x2,x3,x4,x5];
assert(isShellable simplicialComplex randomChain(R,2,6))
///




beginDocumentation()


doc ///
Key 
     RandomIdeal
Headline 
     A package to construct various sorts of random ideals
Description
 Text
     This package can be used to make experiments, trying many ideals, perhaps
     over small fields. For example...what would you expect the regularities of
     "typical" monomial ideals with 10 generators of degree 3 in 6 variables to be?
     Try a bunch of examples -- it's fast.
     Here we do only 500 -- this takes about a second on a fast machine --
     but with a little patience, thousands can be done conveniently.
 Example
     setRandomSeed(currentTime())
     kk=ZZ/101;
     S=kk[vars(0..5)];
     time tally for n from 1 to 500 list regularity randomMonomialIdeal(10:3,S)
 Text
     How does this compare with the case of binomial ideals? or pure binomial ideals?
     We invite the reader to experiment, replacing "randomMonomialIdeal" above with
     "randomBinomialIdeal" or "randomPureBinomialIdeal", or taking larger numbers
     of examples. Click the link "Finding Extreme Examples" below to see
     some other, more elaborate ways to search. 
SeeAlso
     "Finding Extreme Examples"
     randomIdeal
     randomMonomialIdeal
     randomSquareFreeMonomialIdeal
     randomSquareFreeStep
     randomBinomialIdeal
     randomPureBinomialIdeal
     randomSparseIdeal
     randomElementsFromIdeal
     randomMonomial
     squareFree
     regSeq
///


doc ///
Key 
   randomMonomial
   (randomMonomial, ZZ, Ring)
Headline 
   Choose a random monomial of given degree in a given ring
Usage 
   m = randomMonomial(d,S)
Inputs 
   d: ZZ
       non-negative
   S: Ring
       polynomial ring
Outputs
   m: RingElement
       monomial of S
Description
 Text
    Chooses a random monomial.
 Example
    setRandomSeed(currentTime())
    kk=ZZ/101
    S=kk[a,b,c]
    randomMonomial(3,S)
SeeAlso
 randomMonomialIdeal
 randomSquareFreeMonomialIdeal
///


doc ///
Key
  randomSquareFreeMonomialIdeal
  (randomSquareFreeMonomialIdeal, List, Ring)
  (randomSquareFreeMonomialIdeal, Sequence, Ring)
Headline
  random square-free monomial ideal with given degree generators
Usage
  I = randomSquareFreeMonomialIdeal(L,S)
Inputs
  L:List
   or sequence of non-negative integers
  S:Ring
   Polynomial ring
Outputs
  I:Ideal
   square-free monomial ideal with generators of specified degrees
Description
 Text
  Choose a random square-free monomial
  ideal whose generators have the degrees 
  specified by the list or squence L.
 Example
  setRandomSeed(currentTime())
  kk=ZZ/101
  S=kk[a..e]
  L={3,5,7}
  randomSquareFreeMonomialIdeal(L, S)
  randomSquareFreeMonomialIdeal(5:2, S)
Caveat 
  The ideal is constructed degree by degree, starting from the lowest degree
  specified. If there are not enough monomials of the next specified degree that
  are not already in the ideal, the function prints a warning and returns an ideal
  containing all the generators of that degree.
SeeAlso
  randomMonomial
  randomMonomialIdeal
///

doc ///
Key
  randomSquareFreeStep
  (randomSquareFreeStep, MonomialIdeal) 
  (randomSquareFreeStep, Ideal) 
  (randomSquareFreeStep, List) 
  [randomSquareFreeStep,AlexanderProbability]
Headline
 A step in a random walk with uniform distribution over all monomomial ideals
Usage
  M = randomSquareFreeStep(I)
  M = randomSquareFreeStep(I, AlexanderProbability => p)  
  M = randomSquareFreeStep(L)
  M  = randomSquareFreeStep(L, AlexanderProbability => p)
Inputs
  I:Ideal
   square-free monomial Ideal or MonomialIdeal
  L:List
   {I,Igens,ISocgens} where I is a square-free MonomialIdeal,
   Igens is a List of its minimal generators,
   ISocgens is a List of the minimal generators of the socle mod I.
Outputs
  M:List
   {J,Jgens,JSocgens} where J is a square-free MonomialIdeal,
   Jgens is a List of its minimal generators,
   JSocgens is a List of the minimal generators of the socle mod J.
Description
  Text
   With probability p the routine takes the Alexander dual of I;
   the default value of p is .05, and it can be set with the option
   AlexanderProbility.
  
   Otherwise uses the Metropolis algorithm to produce a random walk on the space
   of square-free ideals. Note that there are a LOT of square-free ideals;
   these are the Dedekind numbers, and the sequence (with 1,2,3,4,5,6,7,8 variables) 
   begins
   3,6,20,168,7581, 7828354, 2414682040998, 56130437228687557907788.
   (see the Online Encyclopedia of Integer Sequences for more information).
   Given I in a polynomial ring S, we make a list
   ISocgens of the square-free minimal monomial generators of the socle of S/(squares+I)
   and a list of minimal generators Igens of I. A candidate "next" ideal J is formed as follows:
   We choose randomly from the 
   union of these lists; if a socle element is chosen, it's added to I; if
   a minimal generator is chosen, it's replaced by the square-free part of
   the maximal ideal times it.
   the chance of making the given move is then 1/(#ISocgens+#Igens), and
   the chance of making the move back would be the similar quantity for J,
   so we make the move or not depending on whether 
   random RR < (nJ+nSocJ)/(nI+nSocI) or not; here random RR is
   a random number in [0,1].
  Example
   setRandomSeed(currentTime())
   S=ZZ/2[vars(0..3)]
   J = monomialIdeal"ab,ad, bcd"
   randomSquareFreeStep J
  Text
   With 4 variables and 168 possible monomial ideals, a run of 5000
   takes less than 6 seconds on a reasonably fast machine. With
   10 variables a run of 1000 takes about 2 seconds.
  Example
   setRandomSeed(1)
   rsfs = randomSquareFreeStep
   J = monomialIdeal 0_S
   time T=tally for t from 1 to 5000 list first (J=rsfs(J,AlexanderProbability => .01));
   #T
   T
   J
///


doc ///
Key
  AlexanderProbability
Headline
  option to randomSquareFreeStep
Usage
  M = randomSquareFreeStep(L, AlexanderProbability => p)
Inputs
  p: RR
   real number between 0 and 1.
Description
 Text
  Controls how often the Alexander dual is taken
SeeAlso
  randomSquareFreeStep
///


doc ///
Key
  squareFree  
Headline
  ideal of all square-free monomials of given degree
Usage
  I = squareFree(d,S)
Inputs
  d:ZZ
   positive
  S:Ring
   Polynomial ring
Outputs
  I:Ideal
   all square-free monomials of degree d
Description
 Example
  kk=ZZ/101
  S=kk[a..e]
  squareFree(3, S)
SeeAlso
  randomSquareFreeMonomialIdeal
///

doc ///
Key
  (squareFree, ZZ, Ring)
Headline
  ideal of all square-free monomials of given degree
Usage
  I = squareFree(d,S)
Inputs
  d:ZZ
   positive
  S:Ring
   Polynomial ring
Outputs
  I:Ideal
   all square-free monomials of degree d
Description
 Example
  kk=ZZ/101
  S=kk[a..e]
  squareFree(3, S)
SeeAlso
  randomSquareFreeMonomialIdeal
///

doc ///
Key
  regSeq
  (regSeq, List, Ring)
  (regSeq, Sequence, Ring)  
Headline
  regular sequence of powers of the variables, in given degrees
Usage
  I = regSeq(L,S)
Inputs
  L:List
   or sequence of positive integers
  S:Ring
   Polynomial ring
Outputs
  I:Ideal
   generated by the given powers of the variables
Description
 Example
  kk=ZZ/101
  S=kk[a..e]
  regSeq((2,3,4),S)
Caveat
 If the number of elements of L differs from the number of
 variables in the ring, the length of the regular sequence
 will be the minimum of the two.
///

doc ///
Key
  randomIdeal
  (randomIdeal, List, Matrix)
  (randomIdeal, Sequence, Matrix)
Headline
  randomIdeal made from a given set of monomials
Usage
  I = randomIdeal(L,m)
Inputs
  L:List
   or sequence of positive integers
  m: Matrix
   1xn matrix of homogeneous polynomials in a ring S
Outputs
  I:Ideal
   generated by random linear combinations of degrees given by L of the given polynomials
Description
 Text
  This function composes m with a random map from a free module with degrees
  specified by L to the source of m.
 Example
  kk=ZZ/101
  S=kk[a..e]
  L={3,3,4,6}
  m = matrix{{a^3,b^4+c^4,d^5}}
  I=randomIdeal(L,m)
SeeAlso
 randomMonomialIdeal
 randomSquareFreeMonomialIdeal
 randomMonomial
 randomBinomialIdeal
 randomPureBinomialIdeal
 randomElementsFromIdeal
///

doc ///
Key
  randomBinomialIdeal
  (randomBinomialIdeal, List, Ring)
  (randomBinomialIdeal, Sequence, Ring)
Headline
  randomBinomialIdeal with binomials of given degrees
Usage
  I = randomBinomialIdeal(L,S)
Inputs
  L:List
   or sequence of positive integers
  S: Ring
   Polynomial ring
Outputs
  I:Ideal
   generated by random binomials of the given degrees
Description
 Example
  kk=ZZ/101
  S=kk[a..e]
  L={3,3,4,6}
  I=randomBinomialIdeal(L,S)
Caveat
  The binomials are generated one at a time, and there is no checking to
  see whether the ideal returned is minally generated by fewer elements,
  so the number of minimal generators may not be what you expect.
SeeAlso
 randomIdeal
 randomMonomialIdeal
 randomSquareFreeMonomialIdeal
 randomMonomial
 randomPureBinomialIdeal
 randomElementsFromIdeal
///

doc ///
Key
  randomPureBinomialIdeal
  (randomPureBinomialIdeal, List, Ring)
  (randomPureBinomialIdeal, Sequence, Ring)
Headline
  randomPureBinomialIdeal with binomials of given degrees
Usage
  I = randomPureBinomialIdeal(L,S)
Inputs
  L:List
   or sequence of positive integers
  S: Ring
   Polynomial ring
Outputs
  I:Ideal
   generated by random pure binomials (that is, differences of monomials without coefficients)  of the given degrees
Description
 Text
 Example
  kk=ZZ/101
  S=kk[a..e]
  L={3,3,4,6}
  I=randomPureBinomialIdeal(L,S)
Caveat
  The binomials are generated one at a time, and there is no checking to
  see whether the ideal returned is minally generated by fewer elements,
  so the number of minimal generators may not be what you expect.
SeeAlso
 randomIdeal
 randomMonomialIdeal
 randomSquareFreeMonomialIdeal
 randomMonomial
 randomBinomialIdeal
 randomElementsFromIdeal
///

doc ///
Key
  randomSparseIdeal
  (randomSparseIdeal, Matrix, ZZ, ZZ)
Headline
  randomSparseIdeal made from a given set of monomials
Usage
  I = randomSparseIdeal(B,s,n)
Inputs
  B:Matrix
   1xn matrix of monomials
  s: ZZ
   positive integer, the number of terms in the generators of I
  n: ZZ
   positive integer, the number of generators of I
Outputs
  I:Ideal
   generated by n polynomials, each a random linear combination of s monomials 
Description
 Text
  Each generator of I is formed by randomly choosing s (the sparsity) entries 
  of the matrix B and taking a random linear combinations with coefficients in
  the (ultimate) coefficient ring of S, the ring in which the monomials lie.
 Example
  kk=ZZ/101
  S=kk[a..e]
  L={3,3,4,6}
  B = matrix{{a^3,b^4,d^5,a*b*c,e}}
  I=randomSparseIdeal(B,3,2)
SeeAlso
 randomIdeal
 randomMonomialIdeal
 randomSquareFreeMonomialIdeal
 randomMonomial
 randomBinomialIdeal
 randomPureBinomialIdeal
 randomElementsFromIdeal
///


doc ///
Key
  randomElementsFromIdeal
  (randomElementsFromIdeal,List, Ideal)
Headline
  Chooses random elements of given degrees in a given ideal.
Usage
  I = randomElementsFromIdeal(L,I)
Inputs
  L:List
   of integers
  I:Ideal
   that should be homogeneous
Outputs
  I:Ideal
   generated by (at most) n homogeneous polynomials that are random linear combination of the
   generators of I, with degrees specified by the list L
Description
 Example
  kk=ZZ/101
  S=kk[a..c]
  L={3,3,4,6}
  I = ideal(a^3,b^3, c^3)
  J=randomElementsFromIdeal(L,I)
SeeAlso
 "Finding Extreme Examples"
 randomIdeal
 randomMonomialIdeal
 randomSquareFreeMonomialIdeal
 randomMonomial
 randomBinomialIdeal
 randomPureBinomialIdeal
///


doc ///
Key
  randomMonomialIdeal
  (randomMonomialIdeal, List, Ring)
  (randomMonomialIdeal, Sequence, Ring)
Headline
  random monomial ideal with given degree generators
Usage
  I = randomMonomialIdeal(L,S)
Inputs
  L:List
   or sequence of non-negative integers
  S:Ring
   Polynomial ring
Outputs
  I:Ideal
   monomial ideal with generators of specified degrees
Description
 Text
  Choose a random ideal whose generators have the degrees specified by the list or squence L.
 Example
  kk=ZZ/101
  S=kk[a..e]
  L={3,5,7}
  randomMonomialIdeal(L, S)
  randomMonomialIdeal(5:2, S)
Caveat 
  The ideal is constructed degree by degree, starting from the lowest degree
  specified. If there are not enough monomials of the next specified degree that
  are not already in the ideal, the function prints a warning and returns an ideal
  containing all the generators of that degree.
SeeAlso
  randomMonomial
  randomSquareFreeMonomialIdeal
///



doc ///
Key
  "Finding Extreme Examples"
Headline
  Ways to use random ideals to search for (counter)-examples
Description
 Text
  A common use of Macaulay2 is to look for extreme or particularly
  interesting examples. Here are some examples of how this may be done.
   
  Supposing first that some space of examples is finite; for
  example, we might be interested in monomial ideals with a certain
  number of generators of a certain degree d. Suppose, to be concrete,
  that we want to compare the
  maximum degree of a first syzygy with the regularity of the ideal,
  and also with the maximum degree of the last syzygy. (To make the 
  comparison interesting, it seems reasonable to subtract i from the maximum
  degree of an i-th syzygy.)
 Text
  We may have no idea where to look for extreme examples, and it seems
  that examples with small numbers of variables and generators may not
  show the range of phenomena that actually occur. In large degree there
  may be too many examples to search systematically; so instead we may
  choose many examples at random, and hope to see a pattern. 
   
  Here is a simple example
  First we tally the projective dimensions of 500
  random square-free monomial ideals (what's the average?), then 
  looking how big the difference between the regularity of R/I and the
  "relation degree"-2 can be. It turns out this the differences are rather
  small, only 1 in a typical run of 5000. So one might look for ideals with
  a difference of 2, as in the following (in a real run, one would make
  the number of iterations much bigger; here we keep it small so
  that Macaulay2 doesn't take too long to build it's documentation files.)
 Example
  kk=ZZ/101
  S=kk[vars(0..5)]
  L=for n from 1 to 100 list res randomSquareFreeMonomialIdeal(10:3,S);
  tally apply(L, F -> length F)
  tally apply(L, F -> regularity F - ((max flatten degrees F_2) - 2))
  L=for n from 1 to 500 list res randomSquareFreeMonomialIdeal(10:3,S);
  scan(L, F -> if 1<(regularity F - (max flatten degrees F_2) + 2) then print F.dd_1)
 Text
  A typical problem might be to find how high the regularity of R/I can
  be when R has reasonably few variables, and the degrees of the generators of
  I are reasonably small; despite the wild examples of Mayr-Mayer, we don't
  know how to make examples with large regularity without letting the
  number of variables become large. The following program computes
  "rep" examples of random ideals with monomial and binomial generators,
  and prints any whose regularity exceeds the number "bound"

    
  looper = (rep,bound, L1, L2) -> (for i from 1 to rep do (
  if i % 1000 == 0 then << "." << flush;
  J := randomMonomialIdeal(L1,S) + randomBinomialIdeal(L2,S);
  m := regularity coker gens J;
  if m >= bound then << "reg " << m << " " << toString J << endl;))


  For example:
  kk=ZZ/2
  S=kk[a,b,c,d]
  looper(30000,10,{4},{4,4}) -- finds examples with on monomial of degree 4
  and 2 binomials of degree 4. The largest largest regularity it has found
  (and the largest I know for an ideal in 4 variables of degree 4) is 14.
  Here is an example it found:
  ideal(a*b^3,a^4+b^4,b*c^3+a*d^3)
   
  Similarly:
  
  looper(30000,10,{4,4},{4}) -- looks for examples with
  2 monomials and 1 binomial of degree 4. Suggestively, the
  largest regularity it found was also 14:
  betti res ideal(c^4,b^4,a^3*c+b*d^3) -- reg 14
 Text   
  A more sophisticated and difficult situation arises when the space
  of examples is not necessarily finite (except over a finite field) but
  is a unirational
  variety (such as the space of ideals generated by (at most) a certain
  number of forms of certain given degrees, or the space of smooth curves
  of genus g for some g <= 14) one may be able to do a search for random
  examples, taking a rational parametrization of the space of examples
  and plugging in random inputs.
   
  If the "interesting" examples live in
  a subvariety whose codimension is small, then, working over a small field
  (say 2,3, or 5 elements) one might hope to see elements of the subvariety
  "not too rarely". This principle has been used to good effect for example
  by (Caviglia and Decker-Schreyer, ****--Schreyer). 
SeeAlso
  randomIdeal
  randomMonomialIdeal
  randomSquareFreeMonomialIdeal
  randomMonomial
  randomBinomialIdeal
  randomPureBinomialIdeal
///


TEST ///
S=ZZ/101[a..e]
setRandomSeed 123456
assert (randomMonomial(7,S)==a*b^3*c^3)
setRandomSeed 123456
assert(randomMonomialIdeal({3,4,5}, S)==ideal(a^2*d,a^2*c^2,b^2*c*d^2))
setRandomSeed 123456
assert(randomSquareFreeMonomialIdeal({6,4,4},S)==ideal(a*b*c*e,b*c*d*e))
setRandomSeed 123456
assert(ideal(8*a^2+5*a*b+4*b^2+35*b*c+3*b*d+36*b*e,29*a^2+22*a*b+32*b^2-44*b*c-6*b*d+40*b*e) == randomIdeal({2,2},matrix{{a^2,b}}))
setRandomSeed 123456
assert(ideal(-29*b^2+b*e,-4*a^2+b*c,45*a*d) == randomBinomialIdeal({2,2,2},S))
setRandomSeed 123456
assert(ideal(b*e-d*e,b^2-b*c,-a^2+a*e)== randomPureBinomialIdeal({2,2,2}, S))
setRandomSeed 123456
assert(randomSparseIdeal(matrix"a2,ab,b2", 2,2)==ideal(8*a*b+5*b^2,4*a^2+35*a*b))
assert(ideal(a*b,a*c,a*d,a*e,b*c,b*d,b*e,c*d,c*e,d*e)==squareFree(2,S))
assert( regSeq((1,2,3,4,5,6), S)==ideal(a,b^2,c^3,d^4,e^5))
setRandomSeed 123456
assert(degrees randomElementsFromIdeal({2,3,6},ideal"a2,ab,c5") == {{2}, {3}, {6}})
S=ZZ/2[a,b]
setRandomSeed 1
assert(prepare monomialIdeal(a^2, a*b)=={monomialIdeal (a^2 , a*b), {a^2 , a*b}, {0, 1}})
setRandomSeed 1
S=ZZ/2[vars(0..3)]
J = ideal"ab,ad, bcd"
assert( (randomSquareFreeStep J) === {monomialIdeal map((S)^1,(S)^{{-2},{-2}},{{a*b, a*d}}),{a*b,a*d},{b*c*d,a*c}} );
///




end--  
restart
--loadPackage "RandomIdeal"
uninstallPackage "RandomIdeal"
installPackage "RandomIdeal"
check "RandomIdeal"
viewHelp RandomIdeal


--temporary:

restart
loadPackage "RandomIdeal"
setRandomSeed(1)
S=ZZ/2[vars(0..3)]
rsfs = randomSquareFreeStep
J = monomialIdeal (a*b,a*c)
J = monomialIdeal 0_S
time L= apply(10000, j-> (J = rsfs(J,AlexanderProbability => .1))_0);
tally values tally L
tally ((unique L)/(J->numgens trim J))



restart
loadPackage "RandomIdeal"
S=ZZ/2[a..d]
setRandomSeed(1)
rsfs = randomSquareFreeStep
J = monomialIdeal 0_S
time T=tally for t from 1 to 10000 list J=rsfs(J,AlexanderProbability => .01);
first time, 14 sec; 10 sec after the first few times
around 1.8 sec for 1000

