#############################################################################
##
##  LocalizeRingBasic.gi     LocalizeRingBasic package       Mohamed Barakat
##                                                    Markus Lange-Hegermann
##
##  Copyright 2009, Mohamed Barakat, Universität des Saarlandes
##           Markus Lange-Hegermann, RWTH-Aachen University
##
##  Implementation stuff for LocalizeRingForHomalg.
##
#############################################################################

####################################
#
# global variables:
#
####################################

InstallValue( CommonHomalgTableForLocalizedRingsBasic,
        
        rec(
               ## Must only then be provided by the RingPackage in case the default
               ## "service" function does not match the Ring
               
               BasisOfRowModule :=
                 function( M )

                   return HomalgLocalMatrix( Eval(M)[2] , AssociatedGlobalRing(M) );
                   
                 end,
               
               BasisOfColumnModule :=
                 function( M )
                   
                   return HomalgLocalMatrix( Eval(M)[2] , AssociatedGlobalRing(M) );
                   
                 end,
               
               BasisOfRowsCoeff :=
                 function( M, T )

                   T := homalgTable(HomalgRing( M ))!.IdentityMatrix( M );
                   
                   return M;
                   
                 end,
               
               BasisOfColumnsCoeff :=
                 function( M, T )
                   
                   T := homalgTable(HomalgRing( M ))!.IdentityMatrix( M );
                   
                   return M;
                   
                 end,
               
               DecideZeroRows :=
                 function( A, B )
                   local R, N, i, A2, B2;
                   
                   R := HomalgRing( A );
                   
                   N := HomalgVoidMatrix( 0, NrColumns( A ), R );
                   
                   for i from 1 to NrRows( A ) do
                     
                     B2 := UnionOfRows( CertainRows( A, [i]), B );
                     
                     A2 := CertainRows( A, [1]);
                     
                     B2 := CertainRows( A, [2..NrRows(B2)]);
                     
                   od;
                   
                   return N;
                   
                 end,
               
               DecideZeroColumns :=
                 function( A, B )
                   local R, N;
                   
                   R := HomalgRing( A );
                   
                   N := HomalgVoidMatrix( NrRows( A ), NrColumns( A ), R );
                   
                   #
                   
                   return N;
                   
                 end,
               
               DecideZeroRowsEffectively :=
                 function( A, B, T )
                   local R, N;
                   
                   R := HomalgRing( A );
                   
                   N := HomalgVoidMatrix( NrRows( A ), NrColumns( A ), R );
                   
                   #
                   
                   return N;
                   
                 end,
               
               DecideZeroColumnsEffectively :=
                 function( A, B, T )
                   local R, N;
                   
                   R := HomalgRing( A );
                   
                   N := HomalgVoidMatrix( NrRows( A ), NrColumns( A ), R );
                   
                   #
                   
                   return N;
                   
                 end,
               
               SyzygiesGeneratorsOfRows :=
                 function( arg )
                   local M, R, N, M2, M3;
                   
                   M := arg[1];
                   
                   R := HomalgRing( M );
                   
                   if Length( arg ) > 1 and IsHomalgMatrix( arg[2] ) then
                       
                       M2 := arg[2];
                       
                       M3 := UnionOfRows( M, M2 );
                       
                       M := CertainRows( M3, [1..NrRows(M)] );
                       
                       M2 := CertainRows( M3, [NrRows(M)+1..NrRows(M3)] );
                       
                       N := SyzygiesGeneratorsOfRows( Eval(M)[2], Eval(M2)[2] );
                       
                   else
                       
                       N := SyzygiesGeneratorsOfRows( Eval(M)[2] );
                       
                   fi;
                   
                   return HomalgLocalMatrix( N, R );
                   
                 end,
               
               SyzygiesGeneratorsOfColumns :=
                 function( arg )
                   local M, R, N, M2, M3;
                   
                   M := arg[1];
                   
                   R := HomalgRing( M );
                   
                   if Length( arg ) > 1 and IsHomalgMatrix( arg[2] ) then
                       
                       M2 := arg[2];
                       
                       M3 := UnionOfColumns( M, M2 );
                       
                       M := CertainColumns( M3, [1..NrColumns(M)] );
                       
                       M2 := CertainColumns( M3, [NrColumns(M)+1..NrColumns(M3)] );
                       
                       N := SyzygiesGeneratorsOfColumns( Eval(M)[2], Eval(M2)[2] );
                       
                   else
                       
                       N := SyzygiesGeneratorsOfColumns( Eval(M)[2] );
                       
                   fi;
                   
                   return HomalgLocalMatrix( N, R );
                   
                 end,
               
        )
 );
