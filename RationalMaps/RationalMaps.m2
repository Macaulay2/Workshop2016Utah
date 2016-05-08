newPackage( "RationalMaps",
Version => "0.1", Date => "May 7th, 2016", Authors => {
     {Name => "Karl Schwede",
     Email=> "kschwede@gmail.com",
     HomePage=> "http://www.math.utah.edu/~schwede"
     },
     {Name => "Daniel Smolkin",
     Email=> "smolkin@math.utah.edu",
     HomePage=> "http://www.math.utah.edu/~smolkin"
     },

}, --this file is in the public domain
Headline => "A package for working with Weil divisors.", DebuggingMode => true, Reload=>true)
export{
	"isBirationalMap",
	"imageOfMap",
	"baseLocusOfMap",
	"dimImage",
	"isRegular",
	"invertMap",
	"isEmbedding"
}

----------------------------------------------------------------
--************************************************************--
--Structure of our divisor objects and their display------------
--************************************************************--
----------------------------------------------------------------

imageOfMap = method();
imageOfMap(Matrix,Ideal,Ideal) := (f,a,b) -> (
	h := map((ring a)/a,(ring b)/b,f);
	-- the image of f is the same as the kernel of its pullback on the 
	-- coordinate rings. h is this pullback
	im := ker h;
	im
	);

dimImage = method();
dimImage(Matrix,Ideal,Ideal) := (f,a,b) ->(
	I := imageOfMap(f,a,b);
	dim I - 1
	-- substract 1 from the dimension of the image since in projective space
	);

baseLocusOfMap = method();

baseLocusOfMap(Matrix) := (L1) -> ( --L1 is a row matrix
    M:= gens ker transpose presentation image L1;
    -- this matrix gives all the "equivalent"
    -- ways to write the map in question (e.g. (xy : xz) is 
    -- equivalent to (y : z) ). So we do this to get the 
    -- representation of our map that's defined on the biggest
    -- set of points (e.g. (y : z) extends (xy : xz) to the locus where
    -- x is zero). C.f. proposition 1.1 of the paper
    -- "Cremona Transformations and some Related Algebras" by Aron Simis, 
    -- J. Algebra 280 (2004)
    
    
    L:= apply(entries M, ll->ideal(ll));
    saturate fold(L, plus)
    -- these two commands create an ideal for the base 
    -- locus from the information
    -- given in the matrix above. We take the saturation to get
    -- the biggest ideal that gives the same variety. 
    
);

--****************************************************--
--*****************Documentation**********************--
--****************************************************--

beginDocumentation();

doc /// 
	 Key
		RationalMaps
     Headline
     	A package for computations with rational maps.
     Description
    	Text   
    	 A package for computations with rational maps.
///

doc ///
	Key 
		imageOfMap
	Headline
		Finds defining equations for the image of a rational map
	Usage
		image = imageOfMap(f,a,b)
	Inputs
		f:Matrix
			projective rational map given by polynomial represenative
		a:Ideal
			defining equations for X
		b:Ideal
			defining equations for Y
	Outputs
		im:Ideal
			defining equations for the image of f
	Description
		Text
			Defines the pullback map on the coordinate rings of X and Y. The kernel of this pullback map gives the image of the original map f
		Example
			S = QQ[x,y,z]
			a = ideal(x^2+y^2+z^2)
			T = QQ[u,v]
			b = ideal(u^2+v^2)
			f = matrix{{x*y,y*z}}
			imageOfMap(f,a,b)
///
			
doc ///
        Key
                dimImage
        Headline
                Computes dimension of image of rational map of projective varieties
        Usage
                dim = dimImage(f,a,b)
        Inputs
                f: Matrix
                        a rational map between 2 projective varieties, f: X -> Y
                        assumed that f is given by a polynomial representation
                a: Ideal
                        defining equations for X
                b: Ideal
                        defining equations for Y
        Outputs
                dim:ZZ
			dimension of image
///

doc ///
    Key
        baseLocusOfMap
    Headline
        Computes base locus of a map from a projective variety to projective space
    Usage
        I = baseLocusOfMap(L)
    Inputs
        L: Matrix
            Row matrix whose entries correspond to the coordinates of your map to projective space.
    Outputs
        I: Ideal
            The saturated defining ideal of the baselocus
///

TEST ///
	------------------------------------
	------- Tests for imageOfMap -------
	------------------------------------   

	S = QQ[x,y,z]
        a = ideal(x^2+y^2+z^2)
        T = QQ[u,v]
        b = ideal(u^2+v^2)
        f = matrix{{x*y,y*z}}
        image = imageOfMap(f,a,b)  
	assert(image == ideal(v^4,u*v^3))

	-------------------------------------
	-- Tests for baseLocusOfMap ---------
	-------------------------------------

    R = QQ[x,y,z]	
	M = matrix{{x^2*y, x^2*z, x*y*z}}
	I = ideal(x*y, y*z, x*z)
	assert(I == baseLocusOfMap(M))
	
/// 
----FUTURE PLANS------

