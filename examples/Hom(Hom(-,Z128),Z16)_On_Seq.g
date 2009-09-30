##  <#GAPDoc Label="HomHomZ128">
##  <Section Label="HomHomZ128">
##  <Heading>Hom(Hom(-,Z128),Z16)</Heading>
##    The following example is taken from Section 2 of <Cite Key="BREACA"/>. We localize at the maximal ideal in Z generated by 2. The starting sequence has the following form:
##  <P/><Alt Not="Text,HTML"><Math>0 \longrightarrow M\_=&ZZ;/2^2&ZZ; \stackrel{\alpha_1}{\longrightarrow} M=&ZZ;/2^5&ZZ; \stackrel{\alpha_2}{\longrightarrow} \_M=&ZZ;/2^3&ZZ; \longrightarrow 0</Math></Alt><Alt Only="Text,HTML"><M>0 -> M_=&ZZ;/2^2&ZZ; --alpha_1--> M=&ZZ;/2^5&ZZ; --alpha_2--> \_M=&ZZ;/2^3&ZZ; -> 0</M></Alt>
##  <P/>and we want to use the functor <M>Hom(Hom(-,&ZZ;/2^7&ZZ;),&ZZ;/2^4&ZZ;)</M>.
##  <Example>
##   <![CDATA[
##  gap> LoadPackage( "RingsForHomalg" );;
##  gap> LoadPackage( "LocalizeRingForHomalg" );;
##  gap> GlobalR := HomalgRingOfIntegersInExternalGAP(  );;
##  gap> R := LocalizeAt( GlobalR , [ 2 ] );
##  <A homalg local ring>
##  gap> M := LeftPresentation(\
##  >        HomalgLocalMatrix(\
##  >          HomalgMatrix( [ 2^5 ], GlobalR ),\
##  >        R )\
##  >      );
##  <A cyclic left module presented by an unknown number of relations for a cyclic\
##   generator>
##  gap> _M := LeftPresentation(\
##  >         HomalgLocalMatrix(\
##  >           HomalgMatrix( [ 2^3 ], GlobalR ),\
##  >         R ) \
##  >       );
##  <A cyclic left module presented by an unknown number of relations for a cyclic\
##   generator>
##  gap> alpha2 := HomalgMap(\
##  >             HomalgLocalMatrix( HomalgMatrix( [ 1 ], GlobalR ), R ),\
##  >             M,\
##  >             _M\
##  >           );
##  <A "homomorphism" of left modules>
##  gap> M_ := Kernel( alpha2 );
##  <A cyclic left module presented by an unknown number of relations for a cyclic\
##   generator>
##  gap> alpha1 := KernelEmb( alpha2 );
##  <A monomorphism of left modules>
##  gap> seq := HomalgComplex( alpha2 );
##  <A "complex" containing a single morphism of left modules at degrees
##  [ 0 .. 1 ]>
##  gap> Add( seq, alpha1 );
##  gap> IsShortExactSequence( seq );
##  true
##  gap> K := LeftPresentation(\
##  >        HomalgLocalMatrix(\
##  >          HomalgMatrix( [ 2^7 ], GlobalR ),
##  >        R )
##  >      );
##  <A cyclic left module presented by an unknown number of relations for a cyclic\
##   generator>
##  gap> L := RightPresentation(\
##  >        HomalgLocalMatrix(\
##  >          HomalgMatrix( [ 2^4 ], GlobalR ),\
##  >        R )\
##  >      );
##  <A cyclic right module on a cyclic generator satisfying an unknown number of r\
##  elations>
##  gap> triangle := LHomHom( 4, seq, K, L, "t" );
##  <An exact triangle containing 3 morphisms of left complexes at degrees
##  [ 1, 2, 3, 1 ]>
##  gap> lehs := LongSequence( triangle );
##  <A sequence containing 14 morphisms of left modules at degrees [ 0 .. 14 ]>
##  gap> ByASmallerPresentation( lehs );
##  <A non-zero sequence containing 14 morphisms of left modules at degrees
##  [ 0 .. 14 ]>
##  gap> IsExactSequence( lehs );
##  true
##  ]]></Example>
##  </Section>
##  <#/GAPDoc>
LoadPackage( "RingsForHomalg" );;
LoadPackage( "LocalizeRingForHomalg" );;
GlobalR := HomalgRingOfIntegersInExternalGAP(  );;
R := LocalizeAt( GlobalR , [ 2 ] );
M := LeftPresentation(\
       HomalgLocalMatrix(\
         HomalgMatrix( [ 2^5 ], GlobalR ),\
       R )\
     );
_M := LeftPresentation(\
        HomalgLocalMatrix(\
          HomalgMatrix( [ 2^3 ], GlobalR ),\
        R ) \
      );
alpha2 := HomalgMap(\
            HomalgLocalMatrix( HomalgMatrix( [ 1 ], GlobalR ), R ),\
            M,\
            _M\
          );
M_ := Kernel( alpha2 );
alpha1 := KernelEmb( alpha2 );
seq := HomalgComplex( alpha2 );
Add( seq, alpha1 );
IsShortExactSequence( seq );
K := LeftPresentation(\
       HomalgLocalMatrix(\
         HomalgMatrix( [ 2^7 ], GlobalR ),
       R )
     );
L := RightPresentation(\
       HomalgLocalMatrix(\
         HomalgMatrix( [ 2^4 ], GlobalR ),\
       R )\
     );
triangle := LHomHom( 4, seq, K, L, "t" );
lehs := LongSequence( triangle );
ByASmallerPresentation( lehs );
IsExactSequence( lehs );
