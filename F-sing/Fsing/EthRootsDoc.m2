doc ///
     Key
     	ascendIdeal
     Headline
        Finds the smallest phi-stable ideal containing a given ideal in a polynomial ring.
     Usage
     	 ascendIdeal(J, h, e)
     Inputs
     	 J:Ideal 
	h:RingElement
	e:ZZ
     Outputs
         :Ideal
     Description
	Text
	     Let phi be the p^(-e) linear map obtained by multiplying e-th Frobenius trace by h.  Then this function finds the smallest phi-stable ideal containing J.  The idea is to consider the ascending chain J, J+phi(J), J+phi(J)+phi^2(J), etc.  We return the stable value.  For instance, this can be used to compute the test ideal.  This method appared first in the work of Mordechai Katzman on star closure.
///

doc ///
     Key
     	ascendIdealSafe
     Headline
        Finds the smallest phi-stable ideal containing a given ideal in a polynomial ring.
     Usage
     	 ascendIdealSafe(J, h, a, e)
     Inputs
     	 J:Ideal 
	h:RingElement
	a:ZZ
	e:ZZ
     Outputs
         :Ideal
     Description
	Text
	     Let phi be the p^(-e) linear map obtained by multiplying e-th Frobenius trace by h^a.  Then this function finds the smallest phi-stable ideal containing J.  The idea is to consider the ascending chain J, J+phi(J), J+phi(J)+phi^2(J), etc.  We return the stable value.  For instance, this can be used to compute the test ideal.  This method appared first in the work of Mordechai Katzman on star closure.  It differs from ascendIdeal in that it minimizes the exponents that h is raised to, this can make it faster or slower depending on the circumstances.
///

doc ///
     Key
     	 ethRoot
     Headline
        Computes $I^{[1/p^e]}$ in a polynomial ring over a perfect field
     Usage
     	  ethRoot(I,e) 
     Inputs
     	 I:Ideal
         e:ZZ
     Outputs
        :Ideal
     Description
	Text
	     In a polynomial ring k[x1, ..., xn], I^{[1/p^e]} is the smallest ideal J such that J^{[p^e]} = FrobeniusPower(J,e) \supseteq I.  This function computes it.
///

doc ///
     Key
     	ethRootSafe
     Headline
        Computes (f^a*I)^{[1/p^e]} in such a way that we don not blow exponent buffers.
     Usage
     	 ethRootSafe(f, I, a, e)
     Inputs
     	 f:RingElement
	 I:Ideal
	 a:ZZ
	 e:ZZ
     Outputs
         :Ideal
     Description
	Text
	     Computes the 1/p^e-th root of (f^a*I).  It does it while trying to minimize the power that f gets raised to (in case a is a large number).  This can either be faster or slower than ethRoot.
///