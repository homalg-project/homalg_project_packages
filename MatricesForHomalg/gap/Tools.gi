# SPDX-License-Identifier: GPL-2.0-or-later
# MatricesForHomalg: Matrices for the homalg project
#
# Implementations
#

####################################
#
# methods for operations (you MUST replace for an external CAS):
#
####################################

################################
##
## operations for ring elements:
##
################################

##
InstallMethod( Zero,
        "for homalg rings",
        [ IsHomalgRing ], 10001,
        
  function( R )
    local RP;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Zero) then
        if IsFunction( RP!.Zero ) then
            return RP!.Zero( R );
        else
            return RP!.Zero;
        fi;
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( One,
        "for homalg rings",
        [ IsHomalgRing ], 1001,
        
  function( R )
    local RP;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.One) then
        if IsFunction( RP!.One ) then
            return RP!.One( R );
        else
            return RP!.One;
        fi;
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( MinusOne,
        "for homalg rings",
        [ IsHomalgRing ],
        
  function( R )
    local RP;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.MinusOne) then
        if IsFunction( RP!.MinusOne ) then
            return RP!.MinusOne( R );
        else
            return RP!.MinusOne;
        fi;
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( IsZero,
        "for homalg ring elements",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, RP;
    
    R := HomalgRing( r );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IsZero) then
        return RP!.IsZero( r );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( IsOne,
        "for homalg ring elements",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, RP;
    
    R := HomalgRing( r );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IsOne) then
        return RP!.IsOne( r );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( IsMinusOne,
        "for ring elements",
        [ IsRingElement ],
        
  function( r )
    
    return IsZero( r + One( r ) );
    
end );

## a synonym of `-<elm>':
InstallMethod( AdditiveInverseMutable,
        "for homalg rings elements",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, RP;
    
    R := HomalgRing( r );
    
    if not HasRingElementConstructor( R ) then
        Error( "no ring element constructor found in the ring\n" );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Minus) and IsBound(RP!.Zero) and HasRingElementConstructor( R ) then
        return RingElementConstructor( R )( RP!.Minus( Zero( R ), r ), R );
    fi;
    
    ## never fall back to:
    ## return Zero( r ) - r;
    ## this will cause an infinite loop with a method for \- in LIRNG.gi
    
    TryNextMethod( );
    
end );

##
InstallMethod( \/,
        "for homalg ring elements",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( a, u )
    local R, RP, au;
    
    R := HomalgRing( a );
    
    if not HasRingElementConstructor( R ) then
        Error( "no ring element constructor found in the ring\n" );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.DivideByUnit) and IsUnit( u ) then
        au := RP!.DivideByUnit( a, u );
        if au = fail then
            return fail;
        fi;
        return RingElementConstructor( R )( au, R );
    fi;
    
    au := RightDivide( HomalgMatrix( [ a ], 1, 1, R ), HomalgMatrix( [ u ], 1, 1, R ) );
    
    if not IsHomalgMatrix( au ) then
        return fail;
    fi;
    
    return au[ 1, 1 ];
    
end );

###########################
##
## operations for matrices:
##
###########################

##  <#GAPDoc Label="IsZeroMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M" Name="IsZeroMatrix" Label="homalgTable entry"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>IsZeroMatrix</C> is bound then the standard method
##      for the property <Ref Prop="IsZero" Label="for matrices"/> shown below returns
##      <M>RP</M>!.<C>IsZeroMatrix</C><M>( <A>M</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( IsZero,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IsZeroMatrix) then
        ## CAUTION: the external system must be able
        ## to check zero modulo possible ring relations!
        
        return RP!.IsZeroMatrix( M ); ## with this, \= can fall back to IsZero
    fi;
    
    #=====# the fallback method #=====#
    
    ## from the GAP4 documentation: ?Zero
    ## `ZeroSameMutability( <obj> )' is equivalent to `0 * <obj>'.
    
    return M = 0 * M; ## hence, by default, IsZero falls back to \= (see below)
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##----------------------
## the methods for Eval:
##----------------------

##  <#GAPDoc Label="Eval:IsInitialMatrix">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with HomalgInitialMatrix"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix <A>C</A> was created using
##      <Ref Meth="HomalgInitialMatrix" Label="constructor for initial matrices filled with zeros"/>
##      then the filter <C>IsInitialMatrix</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      (&see; <Ref Meth="InitialMatrix" Label="homalgTable entry for initial matrices"/>)
##      will be used to set the attribute <C>Eval</C> and resets the filter <C>IsInitialMatrix</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (IsInitialMatrix)",
        [ IsHomalgMatrix and IsInitialMatrix and
          HasNumberRows and HasNumberColumns ],
        
  function( C )
    local R, RP, z, zz;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.InitialMatrix ) then
        ResetFilterObj( C, IsInitialMatrix );
        SetEval( C, RP!.InitialMatrix( C ) );
        return Eval( C );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called InitialMatrix in the ",
               "homalgTable to evaluate a non-internal initial matrix\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    z := Zero( HomalgRing( C ) );
    
    ResetFilterObj( C, IsInitialMatrix );
    
    zz := ListWithIdenticalEntries( NumberColumns( C ), z );
    
    SetEval( C, homalgInternalMatrixHull( List( [ 1 .. NumberRows( C ) ], i -> ShallowCopy( zz ) ) ) );
    
    return Eval( C );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="InitialMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="InitialMatrix" Label="homalgTable entry for initial matrices"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>InitialMatrix</C> is bound then the method
##      <Ref Meth="Eval" Label="for matrices created with HomalgInitialMatrix"/>
##      resets the filter <C>IsInitialMatrix</C> and returns <M>RP</M>!.<C>InitialMatrix</C><M>( <A>C</A> )</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:IsInitialIdentityMatrix">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with HomalgInitialIdentityMatrix"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix <A>C</A> was created using
##      <Ref Meth="HomalgInitialIdentityMatrix" Label="constructor for initial quadratic matrices with ones on the diagonal"/>
##      then the filter <C>IsInitialIdentityMatrix</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      (&see; <Ref Meth="InitialIdentityMatrix" Label="homalgTable entry for initial identity matrices"/>)
##      will be used to set the attribute <C>Eval</C> and resets the filter <C>IsInitialIdentityMatrix</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (IsInitialIdentityMatrix)",
        [ IsHomalgMatrix and IsInitialIdentityMatrix and
          HasNumberRows and HasNumberColumns ],
        
  function( C )
    local R, RP, o, z, zz, id;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.InitialIdentityMatrix ) then
        ResetFilterObj( C, IsInitialIdentityMatrix );
        SetEval( C, RP!.InitialIdentityMatrix( C ) );
        return Eval( C );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called InitialIdentityMatrix in the ",
               "homalgTable to evaluate a non-internal initial identity matrix\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    z := Zero( HomalgRing( C ) );
    o := One( HomalgRing( C ) );
    
    ResetFilterObj( C, IsInitialIdentityMatrix );
    
    zz := ListWithIdenticalEntries( NumberColumns( C ), z );
    
    id := List( [ 1 .. NumberRows( C ) ],
                function(i)
                  local z;
                  z := ShallowCopy( zz ); z[i] := o; return z;
                end );
    
    SetEval( C, homalgInternalMatrixHull( id ) );
    
    return Eval( C );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="InitialIdentityMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="InitialIdentityMatrix" Label="homalgTable entry for initial identity matrices"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>InitialIdentityMatrix</C> is bound then the method
##      <Ref Meth="Eval" Label="for matrices created with HomalgInitialIdentityMatrix"/>
##      resets the filter <C>IsInitialIdentityMatrix</C> and returns <M>RP</M>!.<C>InitialIdentityMatrix</C><M>( <A>C</A> )</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##
InstallMethod( Eval,
        "for homalg matrices (HasEvalMatrixOperation)",
        [ IsHomalgMatrix and HasEvalMatrixOperation ],
        
  function( C )
    local func_arg;
    
    func_arg := EvalMatrixOperation( C );
    
    ResetFilterObj( C, HasEvalMatrixOperation );
    
    ## delete the component which was left over by GAP
    Unbind( C!.EvalMatrixOperation );
    
    return CallFuncList( func_arg[1], func_arg[2] );
    
end );

##  <#GAPDoc Label="Eval:HasEvalInvolution">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with Involution"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="Involution" Label="for matrices"/>
##      then the filter <C>HasEvalInvolution</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="Involution" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalInvolution)",
        [ IsHomalgMatrix and HasEvalInvolution ],
        
  function( C )
    local R, RP, M;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    M :=  EvalInvolution( C );
    
    if IsBound(RP!.Involution) then
        return RP!.Involution( M );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called Involution ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return homalgInternalMatrixHull( TransposedMat( Eval( M )!.matrix ) );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Involution:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M" Name="Involution" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>Involution</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with Involution"/> returns
##      <M>RP</M>!.<C>Involution</C> applied to the content of the attribute <C>EvalInvolution</C><M>( <A>C</A> ) = <A>M</A></M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalTransposedMatrix">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with TransposedMatrix"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="TransposedMatrix" Label="for matrices"/>
##      then the filter <C>HasEvalTransposedMatrix</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="TransposedMatrix" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalTransposedMatrix)",
        [ IsHomalgMatrix and HasEvalTransposedMatrix ],
        
  function( C )
    local R, RP, M;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    M :=  EvalTransposedMatrix( C );
    
    if IsBound(RP!.TransposedMatrix) then
        return RP!.TransposedMatrix( M );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called TransposedMatrix ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return homalgInternalMatrixHull( TransposedMat( Eval( M )!.matrix ) );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="TransposedMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M" Name="TransposedMatrix" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>TransposedMatrix</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with TransposedMatrix"/> returns
##      <M>RP</M>!.<C>TransposedMatrix</C> applied to the content of the attribute <C>EvalTransposedMatrix</C><M>( <A>C</A> ) = <A>M</A></M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalCoercedMatrix">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with CoercedMatrix"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="CoercedMatrix" Label="copy a matrix over a different ring"/>
##      then the filter <C>HasEvalCoercedMatrix</C> for <A>C</A> is set to true and the <C>Eval</C> value
##      of a copy of <C>EvalCoercedMatrix(</C><A>C</A><C>)</C> in <C>HomalgRing(</C><A>C</A><C>)</C>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalCoercedMatrix)",
        [ IsHomalgMatrix and HasEvalCoercedMatrix ],
        
  function( C )
    local R, RP, m;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    m := EvalCoercedMatrix( C );
    
    # delegate to the non-lazy coercening
    return Eval( R * m );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalCertainRows">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with CertainRows"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="CertainRows" Label="for matrices"/>
##      then the filter <C>HasEvalCertainRows</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="CertainRows" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalCertainRows)",
        [ IsHomalgMatrix and HasEvalCertainRows ],
        
  function( C )
    local R, RP, e, M, plist;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalCertainRows( C );
    
    M := e[1];
    plist := e[2];
    
    ResetFilterObj( C, HasEvalCertainRows );
    
    ## delete the component which was left over by GAP
    Unbind( C!.EvalCertainRows );
    
    if IsBound(RP!.CertainRows) then
        return RP!.CertainRows( M, plist );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called CertainRows ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return homalgInternalMatrixHull( Eval( M )!.matrix{ plist } );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="CertainRows:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, plist" Name="CertainRows" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>CertainRows</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with CertainRows"/> returns
##      <M>RP</M>!.<C>CertainRows</C> applied to the content of the attribute
##      <C>EvalCertainRows</C><M>( <A>C</A> ) = [ <A>M</A>, <A>plist</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalCertainColumns">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with CertainColumns"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="CertainColumns" Label="for matrices"/>
##      then the filter <C>HasEvalCertainColumns</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="CertainColumns" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalCertainColumns)",
        [ IsHomalgMatrix and HasEvalCertainColumns ],
        
  function( C )
    local R, RP, e, M, plist;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalCertainColumns( C );
    
    M := e[1];
    plist := e[2];
    
    ResetFilterObj( C, HasEvalCertainColumns );
    
    ## delete the component which was left over by GAP
    Unbind( C!.EvalCertainColumns );
    
    if IsBound(RP!.CertainColumns) then
        return RP!.CertainColumns( M, plist );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called CertainColumns ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return homalgInternalMatrixHull(
                   Eval( M )!.matrix{[ 1 .. NumberRows( M ) ]}{plist} );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="CertainColumns:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, plist" Name="CertainColumns" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>CertainColumns</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with CertainColumns"/> returns
##      <M>RP</M>!.<C>CertainColumns</C> applied to the content of the attribute
##      <C>EvalCertainColumns</C><M>( <A>C</A> ) = [ <A>M</A>, <A>plist</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalUnionOfRows">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with UnionOfRows"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Func="UnionOfRows" Label="for a homalg ring, an integer and a list of homalg matrices"/>
##      then the filter <C>HasEvalUnionOfRows</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="UnionOfRows" Label="homalgTable entry"/> or the <C>homalgTable</C> function
##      <Ref Meth="UnionOfRowsPair" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalUnionOfRows)",
        [ IsHomalgMatrix and HasEvalUnionOfRows ],
        
  function( C )
    local R, RP, e, i, combine;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    # Make it mutable
    e := ShallowCopy( EvalUnionOfRows( C ) );
    
    # In case of nested UnionOfRows, we try to avoid
    # recursion, since the gap stack is rather small
    # additionally unpack PreEvals
    i := 1;
    while i <= Length( e ) do
        
        if HasPreEval( e[i] ) and not HasEval( e[i] ) then
            
            e[i] := PreEval( e[i] );
            
        elif HasEvalUnionOfRows( e[i] ) and not HasEval( e[i] ) then
            
            e := Concatenation( e{[ 1 .. (i-1) ]}, EvalUnionOfRows( e[i] ), e{[ (i+1) .. Length( e ) ]}  );
            
        else
            
            i := i + 1;
            
        fi;
        
    od;
    
    # Combine zero matrices
    i := 1;
    while i + 1 <= Length( e ) do
        
        if HasIsZero( e[i] ) and IsZero( e[i] ) and HasIsZero( e[i+1] ) and IsZero( e[i+1] ) then
            
            e[i] := HomalgZeroMatrix( NumberRows( e[i] ) + NumberRows( e[i+1] ), NumberColumns( e[i] ), HomalgRing( e[i] ) );
            
            Remove( e, i + 1 );
            
        else
            
            i := i + 1;
            
        fi;
        
    od;
    
    # After combining zero matrices only a single one might be left
    if Length( e ) = 1 then
        
        return e[1];
        
    fi;
    
    # Use RP!.UnionOfRows if available
    if IsBound(RP!.UnionOfRows) then
        
        return RP!.UnionOfRows( e );
        
    fi;
    
    # Fall back to RP!.UnionOfRowsPair or manual fallback for internal matrices
    # Combine the matrices
    # Use a balanced binary tree to keep the sizes small (heuristically)
    # to avoid a huge memory footprint
    
    if not IsBound(RP!.UnionOfRowsPair) and not IsHomalgInternalMatrixRep( C ) then
        Error( "could neither find a procedure called UnionOfRows ",
               "nor a procedure called UnionOfRowsPair ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    combine := function( A, B )
      local result, U;
        
        if IsBound(RP!.UnionOfRowsPair) then
            
            result := RP!.UnionOfRowsPair( A, B );
            
        else
            
            #=====# can only work for homalg internal matrices #=====#
            
            U := ShallowCopy( Eval( A )!.matrix );
            
            U{ [ NumberRows( A ) + 1 .. NumberRows( A ) + NumberRows( B ) ] } := Eval( B )!.matrix;
            
            result := homalgInternalMatrixHull( U );
            
        fi;
        
        return HomalgMatrixWithAttributes( [
                    Eval, result,
                    EvalUnionOfRows, [ A, B ],
                    NumberRows, NumberRows( A ) + NumberRows( B ),
                    NumberColumns, NumberColumns( A ),
                    ], R );
        
    end;
    
    while Length( e ) > 1 do
        
        for i in [ 1 .. Int( Length( e ) / 2 ) ] do
            
            e[ 2 * i - 1 ] := combine( e[ 2 * i - 1 ], e[ 2 * i ] );
            Unbind( e[ 2 * i ] );
            
        od;
        
        e := Compacted( e );
        
    od;
    
    return Eval( e[1] );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="UnionOfRows:homalgTable_entry">
##  <ManSection>
##    <Func Arg="L" Name="UnionOfRows" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>UnionOfRows</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with UnionOfRows"/> returns
##      <M>RP</M>!.<C>UnionOfRows</C> applied to the content of the attribute
##      <C>EvalUnionOfRows</C><M>( <A>C</A> ) = <A>L</A></M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="UnionOfRowsPair:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="UnionOfRowsPair" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>UnionOfRowsPair</C> is bound
##      and the <C>homalgTable</C> component <M>RP</M>!.<C>UnionOfRows</C> is not bound then
##      the method <Ref Meth="Eval" Label="for matrices created with UnionOfRows"/> returns
##      <M>RP</M>!.<C>UnionOfRowsPair</C> applied recursively to a balanced binary tree created from
##      the content of the attribute <C>EvalUnionOfRows</C><M>( <A>C</A> )</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalUnionOfColumns">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with UnionOfColumns"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Func="UnionOfColumns" Label="for a homalg ring, an integer and a list of homalg matrices"/>
##      then the filter <C>HasEvalUnionOfColumns</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="UnionOfColumns" Label="homalgTable entry"/> or the <C>homalgTable</C> function
##      <Ref Meth="UnionOfColumnsPair" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalUnionOfColumns)",
        [ IsHomalgMatrix and HasEvalUnionOfColumns ],
        
  function( C )
    local R, RP, e, i, combine;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    # Make it mutable
    e := ShallowCopy( EvalUnionOfColumns( C ) );
    
    # In case of nested UnionOfColumns, we try to avoid
    # recursion, since the gap stack is rather small
    # additionally unpack PreEvals
    i := 1;
    while i <= Length( e ) do
        
        if HasPreEval( e[i] ) and not HasEval( e[i] ) then
            
            e[i] := PreEval( e[i] );
            
        elif HasEvalUnionOfColumns( e[i] ) and not HasEval( e[i] ) then
            
            e := Concatenation( e{[ 1 .. (i-1) ]}, EvalUnionOfColumns( e[i] ), e{[ (i+1) .. Length( e ) ]}  );
            
        else
            
            i := i + 1;
            
        fi;
        
    od;
    
    # Combine zero matrices
    i := 1;
    while i + 1 <= Length( e ) do
        
        if HasIsZero( e[i] ) and IsZero( e[i] ) and HasIsZero( e[i+1] ) and IsZero( e[i+1] ) then
            
            e[i] := HomalgZeroMatrix( NumberRows( e[i] ), NumberColumns( e[i] ) + NumberColumns( e[i+1] ), HomalgRing( e[i] ) );
            
            Remove( e, i + 1 );
            
        else
            
            i := i + 1;
            
        fi;
        
    od;
    
    # After combining zero matrices only a single one might be left
    if Length( e ) = 1 then
        
        return e[1];
        
    fi;
    
    # Use RP!.UnionOfColumns if available
    if IsBound(RP!.UnionOfColumns) then
        
        return RP!.UnionOfColumns( e );
        
    fi;
    
    # Fall back to RP!.UnionOfColumnsPair or manual fallback for internal matrices
    # Combine the matrices
    # Use a balanced binary tree to keep the sizes small (heuristically)
    # to avoid a huge memory footprint
    
    if not IsBound(RP!.UnionOfColumnsPair) and not IsHomalgInternalMatrixRep( C ) then
        Error( "could neither find a procedure called UnionOfColumns ",
               "nor a procedure called UnionOfColumnsPair ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    combine := function( A, B )
      local result, U;
        
        if IsBound(RP!.UnionOfColumnsPair) then
            
            result := RP!.UnionOfColumnsPair( A, B );
            
        else
            
            #=====# can only work for homalg internal matrices #=====#
            
            U := List( Eval( A )!.matrix, ShallowCopy );
            
            U{ [ 1 .. NumberRows( A ) ] }
              { [ NumberColumns( A ) + 1 .. NumberColumns( A ) + NumberColumns( B ) ] }
              := Eval( B )!.matrix;
            
            result := homalgInternalMatrixHull( U );
            
        fi;
        
        return HomalgMatrixWithAttributes( [
                    Eval, result,
                    EvalUnionOfColumns, [ A, B ],
                    NumberRows, NumberRows( A ),
                    NumberColumns, NumberColumns( A ) + NumberColumns( B )
                    ], R );
        
    end;
    
    while Length( e ) > 1 do
        
        for i in [ 1 .. Int( Length( e ) / 2 ) ] do
            
            e[ 2 * i - 1 ] := combine( e[ 2 * i - 1 ], e[ 2 * i ] );
            Unbind( e[ 2 * i ] );
            
        od;
        
        e := Compacted( e );
        
    od;
    
    return Eval( e[1] );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="UnionOfColumns:homalgTable_entry">
##  <ManSection>
##    <Func Arg="L" Name="UnionOfColumns" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>UnionOfColumns</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with UnionOfColumns"/> returns
##      <M>RP</M>!.<C>UnionOfColumns</C> applied to the content of the attribute
##      <C>EvalUnionOfColumns</C><M>( <A>C</A> ) = <A>L</A></M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="UnionOfColumnsPair:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="UnionOfColumnsPair" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>UnionOfColumnsPair</C> is bound
##      and the <C>homalgTable</C> component <M>RP</M>!.<C>UnionOfColumns</C> is not bound then
##      the method <Ref Meth="Eval" Label="for matrices created with UnionOfColumns"/> returns
##      <M>RP</M>!.<C>UnionOfColumnsPair</C> applied recursively to a balanced binary tree created from
##      the content of the attribute <C>EvalUnionOfRows</C><M>( <A>C</A> )</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalDiagMat">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with DiagMat"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="DiagMat" Label="for a homalg ring and a list of homalg matrices"/>
##      then the filter <C>HasEvalDiagMat</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="DiagMat" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalDiagMat)",
        [ IsHomalgMatrix and HasEvalDiagMat ],
        
  function( C )
    local R, RP, e, l, z, m, n, diag, mat;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalDiagMat( C );
    
    if IsBound(RP!.DiagMat) then
        return RP!.DiagMat( e );
    fi;
    
    l := Length( e );
    
    if not IsHomalgInternalMatrixRep( C ) then
        return UnionOfRows(
                       List( [ 1 .. l ],
                             i -> UnionOfColumns(
                                     List( [ 1 .. l ],
                                           function( j )
                                             if i = j then
                                                 return e[i];
                                             fi;
                                             return HomalgZeroMatrix( NumberRows( e[i] ), NumberColumns( e[j] ), R );
                                           end )
                                     )
                             )
                       );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    z := Zero( R );
    
    m := Sum( List( e, NumberRows ) );
    n := Sum( List( e, NumberColumns ) );
    
    diag := List( [ 1 .. m ], a -> List( [ 1 .. n ], b -> z ) );
    
    m := 0;
    n := 0;
    
    for mat in e do
        diag{ [ m + 1 .. m + NumberRows( mat ) ] }{ [ n + 1 .. n + NumberColumns( mat ) ] }
          := Eval( mat )!.matrix;
        
        m := m + NumberRows( mat );
        n := n + NumberColumns( mat );
    od;
    
    return homalgInternalMatrixHull( diag );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="DiagMat:homalgTable_entry">
##  <ManSection>
##    <Func Arg="e" Name="DiagMat" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>DiagMat</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with DiagMat"/> returns
##      <M>RP</M>!.<C>DiagMat</C> applied to the content of the attribute
##      <C>EvalDiagMat</C><M>( <A>C</A> ) = <A>e</A></M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalKroneckerMat">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with KroneckerMat"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="KroneckerMat" Label="for matrices"/>
##      then the filter <C>HasEvalKroneckerMat</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="KroneckerMat" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalKroneckerMat)",
        [ IsHomalgMatrix and HasEvalKroneckerMat ],
        
  function( C )
    local R, RP, A, B;
    
    R := HomalgRing( C );
    
    if ( HasIsCommutative( R ) and not IsCommutative( R ) ) and
       ( HasIsSuperCommutative( R ) and not IsSuperCommutative( R ) ) then
        Info( InfoWarning, 1, "\033[01m\033[5;31;47m",
              "the Kronecker product is only defined for (super) commutative rings!",
              "\033[0m" );
    fi;
    
    RP := homalgTable( R );
    
    A :=  EvalKroneckerMat( C )[1];
    B :=  EvalKroneckerMat( C )[2];
    
    if IsBound(RP!.KroneckerMat) then
        return RP!.KroneckerMat( A, B );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called KroneckerMat ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return homalgInternalMatrixHull(
                   KroneckerProduct( Eval( A )!.matrix, Eval( B )!.matrix ) );
    ## this was easy, thanks GAP :)
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="KroneckerMat:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="KroneckerMat" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>KroneckerMat</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with KroneckerMat"/> returns
##      <M>RP</M>!.<C>KroneckerMat</C> applied to the content of the attribute
##      <C>EvalKroneckerMat</C><M>( <A>C</A> ) = [ <A>A</A>, <A>B</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalDualKroneckerMat">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with DualKroneckerMat"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="DualKroneckerMat" Label="for matrices"/>
##      then the filter <C>HasEvalDualKroneckerMat</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="DualKroneckerMat" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalDualKroneckerMat)",
        [ IsHomalgMatrix and HasEvalDualKroneckerMat ],
        
  function( C )
    local R, RP, A, B;
    
    R := HomalgRing( C );
    
    if ( HasIsCommutative( R ) and not IsCommutative( R ) ) and
       ( HasIsSuperCommutative( R ) and not IsSuperCommutative( R ) ) then
        Info( InfoWarning, 1, "\033[01m\033[5;31;47m",
              "the dual Kronecker product is only defined for (super) commutative rings!",
              "\033[0m" );
    fi;
    
    RP := homalgTable( R );
    
    A :=  EvalDualKroneckerMat( C )[1];
    B :=  EvalDualKroneckerMat( C )[2];
    
    # work around errors in Singular when taking the opposite ring of a ring with ordering lp
    # https://github.com/Singular/Singular/issues/1011
    # fixed in version 4.2.0
    if IsBound(RP!.DualKroneckerMat) and not (
        IsBound( R!.ring ) and
        IsBound( R!.ring!.stream ) and
        IsBound( R!.ring!.stream.cas ) and R!.ring!.stream.cas = "singular" and
        ( not IsBound( R!.ring!.stream.version ) or R!.ring!.stream.version < 4200 ) and
        IsBound( R!.order ) and IsString( R!.order ) and StartsWith( R!.order, "lex" )
    ) then
        
        return RP!.DualKroneckerMat( A, B );
        
    fi;
    
    if HasIsCommutative( R ) and IsCommutative( R ) then
        
        return Eval( KroneckerMat( B, A ) );
        
    else
        
        return Eval(
            TransposedMatrix( Involution(
                KroneckerMat( TransposedMatrix( Involution( B ) ), TransposedMatrix( Involution( A ) ) )
            ) )
        );
        
    fi;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="DualKroneckerMat:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="DualKroneckerMat" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>DualKroneckerMat</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with DualKroneckerMat"/> returns
##      <M>RP</M>!.<C>DualKroneckerMat</C> applied to the content of the attribute
##      <C>EvalDualKroneckerMat</C><M>( <A>C</A> ) = [ <A>A</A>, <A>B</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalMulMat">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with MulMat"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="\*" Label="for ring elements and matrices"/>
##      then the filter <C>HasEvalMulMat</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="MulMat" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalMulMat)",
        [ IsHomalgMatrix and HasEvalMulMat ],
        
  function( C )
    local R, RP, e, a, A;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalMulMat( C );
    
    a := e[1];
    A := e[2];
    
    if IsBound(RP!.MulMat) then
        return RP!.MulMat( a, A );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called MulMat ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return a * Eval( A );
    
end );

InstallMethod( Eval,
        "for homalg matrices (HasEvalMulMatRight)",
        [ IsHomalgMatrix and HasEvalMulMatRight ],
        
  function( C )
    local R, RP, e, A, a;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalMulMatRight( C );
    
    A := e[1];
    a := e[2];
    
    if IsBound(RP!.MulMatRight) then
        return RP!.MulMatRight( A, a );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called MulMatRight ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Eval( A ) * a;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="MulMat:homalgTable_entry">
##  <ManSection>
##    <Func Arg="a, A" Name="MulMat" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>MulMat</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with MulMat"/> returns
##      <M>RP</M>!.<C>MulMat</C> applied to the content of the attribute
##      <C>EvalMulMat</C><M>( <A>C</A> ) = [ <A>a</A>, <A>A</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalAddMat">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with AddMat"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="\+" Label="for matrices"/>
##      then the filter <C>HasEvalAddMat</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="AddMat" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalAddMat)",
        [ IsHomalgMatrix and HasEvalAddMat ],
        
  function( C )
    local R, RP, e, A, B;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalAddMat( C );
    
    A := e[1];
    B := e[2];
    
    ResetFilterObj( C, HasEvalAddMat );
    
    ## delete the component which was left over by GAP
    Unbind( C!.EvalAddMat );
    
    if IsBound(RP!.AddMat) then
        return RP!.AddMat( A, B );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called AddMat ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Eval( A ) + Eval( B );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="AddMat:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="AddMat" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>AddMat</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with AddMat"/> returns
##      <M>RP</M>!.<C>AddMat</C> applied to the content of the attribute
##      <C>EvalAddMat</C><M>( <A>C</A> ) = [ <A>A</A>, <A>B</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalSubMat">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with SubMat"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="\-" Label="for matrices"/>
##      then the filter <C>HasEvalSubMat</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="SubMat" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalSubMat)",
        [ IsHomalgMatrix and HasEvalSubMat ],
        
  function( C )
    local R, RP, e, A, B;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalSubMat( C );
    
    A := e[1];
    B := e[2];
    
    ResetFilterObj( C, HasEvalSubMat );
    
    ## delete the component which was left over by GAP
    Unbind( C!.EvalSubMat );
    
    if IsBound(RP!.SubMat) then
        return RP!.SubMat( A, B );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called SubMat ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Eval( A ) - Eval( B );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="SubMat:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="SubMat" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>SubMat</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with SubMat"/> returns
##      <M>RP</M>!.<C>SubMat</C> applied to the content of the attribute
##      <C>EvalSubMat</C><M>( <A>C</A> ) = [ <A>A</A>, <A>B</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:HasEvalCompose">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with Compose"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Meth="\*" Label="for composable matrices"/>
##      then the filter <C>HasEvalCompose</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      <Ref Meth="Compose" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalCompose)",
        [ IsHomalgMatrix and HasEvalCompose ],
        
  function( C )
    local R, RP, e, A, B;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  EvalCompose( C );
    
    A := e[1];
    B := e[2];
    
    ResetFilterObj( C, HasEvalCompose );
    
    ## delete the component which was left over by GAP
    Unbind( C!.EvalCompose );
    
    if IsBound(RP!.Compose) then
        return RP!.Compose( A, B );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called Compose ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Eval( A ) * Eval( B );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Compose:homalgTable_entry">
##  <ManSection>
##    <Func Arg="A, B" Name="Compose" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>Compose</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with Compose"/> returns
##      <M>RP</M>!.<C>Compose</C> applied to the content of the attribute
##      <C>EvalCompose</C><M>( <A>C</A> ) = [ <A>A</A>, <A>B</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:IsIdentityMatrix">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with HomalgIdentityMatrix"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix <A>C</A> was created using
##      <Ref Meth="HomalgIdentityMatrix" Label="constructor for identity matrices"/>
##      then the filter <C>IsOne</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      (&see; <Ref Meth="IdentityMatrix" Label="homalgTable entry"/>)
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (IsOne)",
        [ IsHomalgMatrix and IsOne and HasNumberRows and HasNumberColumns ], 10,
        
  function( C )
    local R, id, RP, o, z, zz;
    
    R := HomalgRing( C );
    
    if IsBound( R!.IdentityMatrices ) then
        id := ElmWPObj( R!.IdentityMatrices!.weak_pointers, NumberColumns( C ) );
        if id <> fail then
            R!.IdentityMatrices!.cache_hits := R!.IdentityMatrices!.cache_hits + 1;
            return id;
        fi;
        ## we do not count cache_misses as it is equivalent to counter
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.IdentityMatrix ) then
        id := RP!.IdentityMatrix( C );
        SetElmWPObj( R!.IdentityMatrices!.weak_pointers, NumberColumns( C ), id );
        R!.IdentityMatrices!.counter := R!.IdentityMatrices!.counter + 1;
        return id;
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called IdentityMatrix ",
               "homalgTable to evaluate a non-internal identity matrix\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    z := Zero( HomalgRing( C ) );
    o := One( HomalgRing( C ) );
    
    zz := ListWithIdenticalEntries( NumberColumns( C ), z );
    
    id := List( [ 1 .. NumberRows( C ) ],
                function(i)
                  local z;
                  z := ShallowCopy( zz ); z[i] := o; return z;
                end );
    
    id := homalgInternalMatrixHull( id );
    
    SetElmWPObj( R!.IdentityMatrices!.weak_pointers, NumberColumns( C ), id );
    
    return id;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="IdentityMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="IdentityMatrix" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>IdentityMatrix</C> is bound then the method
##      <Ref Meth="Eval" Label="for matrices created with HomalgIdentityMatrix"/> returns
##      <M>RP</M>!.<C>IdentityMatrix</C><M>( <A>C</A> )</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Eval:IsZeroMatrix">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with HomalgZeroMatrix"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix <A>C</A> was created using
##      <Ref Meth="HomalgZeroMatrix" Label="constructor for zero matrices"/>
##      then the filter <C>IsZeroMatrix</C> for <A>C</A> is set to true and the <C>homalgTable</C> function
##      (&see; <Ref Meth="ZeroMatrix" Label="homalgTable entry"/>)
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (IsZero)",
        [ IsHomalgMatrix and IsZero and HasNumberRows and HasNumberColumns ], 40,
        
  function( C )
    local R, RP, z;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if ( NumberRows( C ) = 0 or NumberColumns( C ) = 0 ) and
       not ( IsBound( R!.SafeToEvaluateEmptyMatrices ) and
             R!.SafeToEvaluateEmptyMatrices = true ) then
        Info( InfoWarning, 1, "\033[01m\033[5;31;47m",
              "an empty matrix is about to get evaluated!",
              "\033[0m" );
    fi;
    
    if IsBound( RP!.ZeroMatrix ) then
        return RP!.ZeroMatrix( C );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called ZeroMatrix ",
               "homalgTable to evaluate a non-internal zero matrix\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    z := Zero( HomalgRing( C ) );
    
    ## copying the rows saves memory;
    ## we assume that the entries are never modified!!!
    return homalgInternalMatrixHull(
                   ListWithIdenticalEntries( NumberRows( C ),
                           ListWithIdenticalEntries( NumberColumns( C ), z ) ) );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="ZeroMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="ZeroMatrix" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>ZeroMatrix</C> is bound then the method
##      <Ref Meth="Eval" Label="for matrices created with HomalgZeroMatrix"/> returns
##      <M>RP</M>!.<C>ZeroMatrix</C><M>( <A>C</A> )</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="NumberRows:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="NumberRows" Label="homalgTable entry"/>
##    <Returns>a nonnegative integer</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>NumberRows</C> is bound then the standard method
##      for the attribute <Ref Attr="NumberRows"/> shown below returns
##      <M>RP</M>!.<C>NumberRows</C><M>( <A>C</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( NumberRows,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.NumberRows) then
        return RP!.NumberRows( C );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called NumberRows ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Length( Eval( C )!.matrix );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="NumberColumns:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="NumberColumns" Label="homalgTable entry"/>
##    <Returns>a nonnegative integer</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>NumberColumns</C> is bound then the standard method
##      for the attribute <Ref Attr="NumberColumns"/> shown below returns
##      <M>RP</M>!.<C>NumberColumns</C><M>( <A>C</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( NumberColumns,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.NumberColumns) then
        return RP!.NumberColumns( C );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called NumberColumns ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Length( Eval( C )!.matrix[ 1 ] );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="Determinant:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="Determinant" Label="homalgTable entry"/>
##    <Returns>a ring element</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>Determinant</C> is bound then the standard method
##      for the attribute <Ref Attr="DeterminantMat"/> shown below returns
##      <M>RP</M>!.<C>Determinant</C><M>( <A>C</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( DeterminantMat,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if NumberRows( C ) <> NumberColumns( C ) then
        Error( "the matrix is not a square matrix\n" );
    fi;
    
    if IsEmptyMatrix( C ) then
        return One( R );
    elif IsZero( C ) then
        return Zero( R );
    fi;
    
    if IsBound(RP!.Determinant) then
        return RingElementConstructor( R )( RP!.Determinant( C ), R );
    fi;
    
    if not IsHomalgInternalMatrixRep( C ) then
        Error( "could not find a procedure called Determinant ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    #=====# can only work for homalg internal matrices #=====#
    
    return Determinant( Eval( C )!.matrix );
    
end );

##
InstallMethod( Determinant,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    
    return DeterminantMat( C );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

####################################
#
# methods for operations (you probably want to replace for an external CAS):
#
####################################

##
InstallMethod( IsUnit,
        "for homalg ring elements",
        [ IsHomalgRing, IsRingElement ], 100,
        
  function( R, r )
    local RP;
    
    if HasIsZero( r ) and IsZero( r ) then
        return false;
    elif HasIsOne( r ) and IsOne( r ) then
        return true;
    fi;
    
    return not IsBool( LeftInverse( HomalgMatrix( [ r ], 1, 1, R ) ) );
    
end );

##
InstallMethod( IsUnit,
        "for homalg ring elements",
        [ IsHomalgRing, IsHomalgRingElement ], 100,
        
  function( R, r )
    local RP;
    
    if HasIsZero( r ) and IsZero( r ) then
        return false;
    elif HasIsOne( r ) and IsOne( r ) then
        return true;
    elif HasIsMinusOne( r ) and IsMinusOne( r ) then
        return true;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IsUnit) then
        return RP!.IsUnit( R, r );
    fi;
    
    #=====# the fallback method #=====#
    
    return not IsBool( LeftInverse( HomalgMatrix( [ r ], 1, 1, R ) ) );
    
end );

##
InstallMethod( IsUnit,
        "for homalg ring elements",
        [ IsHomalgInternalRingRep, IsRingElement ], 100,
        
  function( R, r )
    
    return IsUnit( R!.ring, r );
    
end );

##
InstallMethod( IsUnit,
        "for homalg ring elements",
        [ IsHomalgRingElement ],
        
  function( r )
    
    if HasIsZero( r ) and IsZero( r ) then
        return false;
    elif HasIsOne( r ) and IsOne( r ) then
        return true;
    elif HasIsMinusOne( r ) and IsMinusOne( r ) then
        return true;
    fi;
    
    if not IsBound( r!.IsUnit ) then
        r!.IsUnit := IsUnit( HomalgRing( r ), r );
    fi;
    
    return r!.IsUnit;
    
end );

##  <#GAPDoc Label="ZeroRows:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="ZeroRows" Label="homalgTable entry"/>
##    <Returns>a (possibly empty) list of positive integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>ZeroRows</C> is bound then the standard method
##      of the attribute <Ref Attr="ZeroRows"/> shown below returns
##      <M>RP</M>!.<C>ZeroRows</C><M>( <A>C</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( ZeroRows,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP, z;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ZeroRows) then
        return RP!.ZeroRows( C );
    fi;
    
    #=====# the fallback method #=====#
    
    z := HomalgZeroMatrix( 1, NumberColumns( C ), R );
    
    return Filtered( [ 1 .. NumberRows( C ) ], a -> CertainRows( C, [ a ] ) = z );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="ZeroColumns:homalgTable_entry">
##  <ManSection>
##    <Func Arg="C" Name="ZeroColumns" Label="homalgTable entry"/>
##    <Returns>a (possibly empty) list of positive integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>ZeroColumns</C> is bound then the standard method
##      of the attribute <Ref Attr="ZeroColumns"/> shown below returns
##      <M>RP</M>!.<C>ZeroColumns</C><M>( <A>C</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( ZeroColumns,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP, z;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ZeroColumns) then
        return RP!.ZeroColumns( C );
    fi;
    
    #=====# the fallback method #=====#
    
    z := HomalgZeroMatrix( NumberRows( C ), 1, R );
    
    return Filtered( [ 1 .. NumberColumns( C ) ], a -> CertainColumns( C, [ a ] ) = z );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##
InstallMethod( GetRidOfObsoleteRows,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP, M;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.GetRidOfObsoleteRows) then
        M := HomalgMatrix( RP!.GetRidOfObsoleteRows( C ), R );
        if HasNumberColumns( C ) then
            SetNumberColumns( M, NumberColumns( C ) );
        fi;
        SetZeroRows( M, [ ] );
        return M;
    fi;
    
    #=====# the fallback method #=====#
    
    ## get rid of zero rows
    ## (e.g. those rows containing the ring relations)
    
    M := CertainRows( C, NonZeroRows( C ) );
    
    SetZeroRows( M, [ ] );
    
    ## forgetting C may save memory
    if HasEvalCertainRows( M ) then
        if not IsEmptyMatrix( M ) then
            Eval( M );
        fi;
        ResetFilterObj( M, HasEvalCertainRows );
        Unbind( M!.EvalCertainRows );
    fi;
    
    return M;
    
end );

##
InstallMethod( GetRidOfObsoleteColumns,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( C )
    local R, RP, M;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.GetRidOfObsoleteColumns) then
        M := HomalgMatrix( RP!.GetRidOfObsoleteColumns( C ), R );
        if HasNumberRows( C ) then
            SetNumberRows( M, NumberRows( C ) );
        fi;
        SetZeroColumns( M, [ ] );
        return M;
    fi;
    
    #=====# the fallback method #=====#
    
    ## get rid of zero columns
    ## (e.g. those columns containing the ring relations)
    
    M := CertainColumns( C, NonZeroColumns( C ) );
    
    SetZeroColumns( M, [ ] );
    
    ## forgetting C may save memory
    if HasEvalCertainColumns( M ) then
        if not IsEmptyMatrix( M ) then
            Eval( M );
        fi;
        ResetFilterObj( M, HasEvalCertainColumns );
        Unbind( M!.EvalCertainColumns );
    fi;
    
    return M;
    
end );

##  <#GAPDoc Label="AreEqualMatrices:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M1,M2" Name="AreEqualMatrices" Label="homalgTable entry"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M1</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>AreEqualMatrices</C> is bound then the standard method
##      for the operation <Ref Oper="\=" Label="for matrices"/> shown below returns
##      <M>RP</M>!.<C>AreEqualMatrices</C><M>( <A>M1</A>, <A>M2</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( \=,
        "for homalg comparable matrices",
        [ IsHomalgMatrix, IsHomalgMatrix ],
        
  function( M1, M2 )
    local R, RP, are_equal;
    
    ## do not touch mutable matrices
    if not ( IsMutable( M1 ) or IsMutable( M2 ) ) then
        
        if IsBound( M1!.AreEqual ) then
            are_equal := _ElmWPObj_ForHomalg( M1!.AreEqual, M2, fail );
            if are_equal <> fail then
                return are_equal;
            fi;
        else
            M1!.AreEqual :=
              ContainerForWeakPointers(
                      TheTypeContainerForWeakPointersOnComputedValues,
                      [ "operation", "AreEqual" ] );
        fi;
        
        if IsBound( M2!.AreEqual ) then
            are_equal := _ElmWPObj_ForHomalg( M2!.AreEqual, M1, fail );
            if are_equal <> fail then
                return are_equal;
            fi;
        fi;
        ## do not store things symmetrically below to ``save'' memory
        
    fi;
    
    R := HomalgRing( M1 );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.AreEqualMatrices) then
        ## CAUTION: the external system must be able to check equality
        ## modulo possible ring relations (known to the external system)!
        are_equal := RP!.AreEqualMatrices( M1, M2 );
    elif IsBound(RP!.Equal) then
        ## CAUTION: the external system must be able to check equality
        ## modulo possible ring relations (known to the external system)!
        are_equal := RP!.Equal( M1, M2 );
    elif IsBound(RP!.IsZeroMatrix) then   ## ensuring this avoids infinite loops
        are_equal := IsZero( M1 - M2 );
    fi;
    
    if IsBound( are_equal ) then
        
        ## do not touch mutable matrices
        if not ( IsMutable( M1 ) or IsMutable( M2 ) ) then
            
            if are_equal then
                MatchPropertiesAndAttributes( M1, M2,
                        LIMAT.intrinsic_properties,
                        LIMAT.intrinsic_attributes,
                        LIMAT.intrinsic_components,
                        LIMAT.intrinsic_attributes_do_not_check_their_equality
                        );
            fi;
            
            ## do not store things symmetrically to ``save'' memory
            _AddTwoElmWPObj_ForHomalg( M1!.AreEqual, M2, are_equal );
            
        fi;
        
        return are_equal;
    fi;
    
    TryNextMethod( );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="IsIdentityMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M" Name="IsIdentityMatrix" Label="homalgTable entry"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>IsIdentityMatrix</C> is bound then the standard method
##      for the property <Ref Prop="IsOne"/> shown below returns
##      <M>RP</M>!.<C>IsIdentityMatrix</C><M>( <A>M</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( IsOne,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP;
    
    if NumberRows( M ) <> NumberColumns( M ) then
        return false;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IsIdentityMatrix) then
        return RP!.IsIdentityMatrix( M );
    fi;
    
    #=====# the fallback method #=====#
    
    return M = HomalgIdentityMatrix( NumberRows( M ), HomalgRing( M ) );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="IsDiagonalMatrix:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M" Name="IsDiagonalMatrix" Label="homalgTable entry"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>IsDiagonalMatrix</C> is bound then the standard method
##      for the property <Ref Meth="IsDiagonalMatrix"/> shown below returns
##      <M>RP</M>!.<C>IsDiagonalMatrix</C><M>( <A>M</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( IsDiagonalMatrix,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, diag;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IsDiagonalMatrix) then
        return RP!.IsDiagonalMatrix( M );
    fi;
    
    #=====# the fallback method #=====#
    
    diag := DiagonalEntries( M );
    
    return M = HomalgDiagonalMatrix( diag, NumberRows( M ), NumberColumns( M ), R );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="GetColumnIndependentUnitPositions">
##  <ManSection>
##    <Oper Arg="A, poslist" Name="GetColumnIndependentUnitPositions" Label="for matrices"/>
##    <Returns>a (possibly empty) list of pairs of positive integers</Returns>
##    <Description>
##      The list of column independet unit position of the matrix <A>A</A>.
##      We say that a unit <A>A</A><M>[i,k]</M> is column independet from the unit <A>A</A><M>[l,j]</M>
##      if <M>i>l</M> and <A>A</A><M>[l,k]=0</M>.
##      The rows are scanned from top to bottom and within each row the columns are
##      scanned from right to left searching for new units, column independent from the preceding ones.
##      If <A>A</A><M>[i,k]</M> is a new column independent unit then <M>[i,k]</M> is added to the
##      output list. If <A>A</A> has no units the empty list is returned.<P/>
##      (for the installed standard method see <Ref Meth="GetColumnIndependentUnitPositions" Label="homalgTable entry"/>)
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="GetColumnIndependentUnitPositions:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, poslist" Name="GetColumnIndependentUnitPositions" Label="homalgTable entry"/>
##    <Returns>a (possibly empty) list of pairs of positive integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>GetColumnIndependentUnitPositions</C> is bound then the standard method
##      of the operation <Ref Meth="GetColumnIndependentUnitPositions" Label="for matrices"/> shown below returns
##      <M>RP</M>!.<C>GetColumnIndependentUnitPositions</C><M>( <A>M</A>, <A>poslist</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( GetColumnIndependentUnitPositions,
        "for homalg matrices",
        [ IsHomalgMatrix, IsHomogeneousList ],
        
  function( M, poslist )
    local cache, R, RP, rest, pos, i, j, k;
    
    if IsBound( M!.GetColumnIndependentUnitPositions ) then
        cache := M!.GetColumnIndependentUnitPositions;
        if IsBound( cache.(String( poslist )) ) then
            return cache.(String( poslist ));
        fi;
    else
        cache := rec( );
        M!.GetColumnIndependentUnitPositions := cache;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.GetColumnIndependentUnitPositions) then
        pos := RP!.GetColumnIndependentUnitPositions( M, poslist );
        if pos <> [ ] then
            SetIsZero( M, false );
        fi;
        cache.(String( poslist )) := pos;
        return pos;
    fi;
    
    #=====# the fallback method #=====#
    
    rest := [ 1 .. NumberColumns( M ) ];
    
    pos := [ ];
    
    for i in [ 1 .. NumberRows( M ) ] do
        for k in Reversed( rest ) do
            if not [ i, k ] in poslist and
               IsUnit( R, M[ i, k ] ) then
                Add( pos, [ i, k ] );
                rest := Filtered( rest,
                                a -> IsZero( M[ i, a ] ) );
                break;
            fi;
        od;
    od;
    
    if pos <> [ ] then
        SetIsZero( M, false );
    fi;
    
    cache.(String( poslist )) := pos;
    
    return pos;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="GetRowIndependentUnitPositions">
##  <ManSection>
##    <Oper Arg="A, poslist" Name="GetRowIndependentUnitPositions" Label="for matrices"/>
##    <Returns>a (possibly empty) list of pairs of positive integers</Returns>
##    <Description>
##      The list of row independet unit position of the matrix <A>A</A>.
##      We say that a unit <A>A</A><M>[k,j]</M> is row independet from the unit <A>A</A><M>[i,l]</M>
##      if <M>j>l</M> and <A>A</A><M>[k,l]=0</M>.
##      The columns are scanned from left to right and within each column the rows are
##      scanned from bottom to top searching for new units, row independent from the preceding ones.
##      If <A>A</A><M>[k,j]</M> is a new row independent unit then <M>[j,k]</M> (yes <M>[j,k]</M>) is added to the
##      output list. If <A>A</A> has no units the empty list is returned.<P/>
##      (for the installed standard method see <Ref Meth="GetRowIndependentUnitPositions" Label="homalgTable entry"/>)
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="GetRowIndependentUnitPositions:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, poslist" Name="GetRowIndependentUnitPositions" Label="homalgTable entry"/>
##    <Returns>a (possibly empty) list of pairs of positive integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>GetRowIndependentUnitPositions</C> is bound then the standard method
##      of the operation <Ref Meth="GetRowIndependentUnitPositions" Label="for matrices"/> shown below returns
##      <M>RP</M>!.<C>GetRowIndependentUnitPositions</C><M>( <A>M</A>, <A>poslist</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( GetRowIndependentUnitPositions,
        "for homalg matrices",
        [ IsHomalgMatrix, IsHomogeneousList ],
        
  function( M, poslist )
    local cache, R, RP, rest, pos, j, i, k;
    
    if IsBound( M!.GetRowIndependentUnitPositions ) then
        cache := M!.GetRowIndependentUnitPositions;
        if IsBound( cache.(String( poslist )) ) then
            return cache.(String( poslist ));
        fi;
    else
        cache := rec( );
        M!.GetRowIndependentUnitPositions := cache;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.GetRowIndependentUnitPositions) then
        pos := RP!.GetRowIndependentUnitPositions( M, poslist );
        if pos <> [ ] then
            SetIsZero( M, false );
        fi;
        cache.( String( poslist ) ) := pos;
        return pos;
    fi;
    
    #=====# the fallback method #=====#
    
    rest := [ 1 .. NumberRows( M ) ];
    
    pos := [ ];
    
    for j in [ 1 .. NumberColumns( M ) ] do
        for k in Reversed( rest ) do
            if not [ j, k ] in poslist and
               IsUnit( R, M[ k, j ] ) then
                Add( pos, [ j, k ] );
                rest := Filtered( rest,
                                a -> IsZero( M[ a, j ] ) );
                break;
            fi;
        od;
    od;
    
    if pos <> [ ] then
        SetIsZero( M, false );
    fi;
    
    cache.( String( poslist ) ) := pos;
    
    return pos;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="GetUnitPosition">
##  <ManSection>
##    <Oper Arg="A, poslist" Name="GetUnitPosition" Label="for matrices"/>
##    <Returns>a (possibly empty) list of pairs of positive integers</Returns>
##    <Description>
##      The position <M>[i,j]</M> of the first unit <A>A</A><M>[i,j]</M> in the matrix <A>A</A>, where
##      the rows are scanned from top to bottom and within each row the columns are
##      scanned from left to right. If <A>A</A><M>[i,j]</M> is the first occurrence of a unit
##      then the position pair <M>[i,j]</M> is returned. Otherwise <C>fail</C> is returned.<P/>
##      (for the installed standard method see <Ref Meth="GetUnitPosition" Label="homalgTable entry"/>)
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="GetUnitPosition:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, poslist" Name="GetUnitPosition" Label="homalgTable entry"/>
##    <Returns>a (possibly empty) list of pairs of positive integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>GetUnitPosition</C> is bound then the standard method
##      of the operation <Ref Meth="GetUnitPosition" Label="for matrices"/> shown below returns
##      <M>RP</M>!.<C>GetUnitPosition</C><M>( <A>M</A>, <A>poslist</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( GetUnitPosition,
        "for homalg matrices",
        [ IsHomalgMatrix, IsHomogeneousList ],
        
  function( M, poslist )
    local R, RP, pos, m, n, i, j;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.GetUnitPosition) then
        pos := RP!.GetUnitPosition( M, poslist );
        if IsList( pos ) and IsPosInt( pos[1] ) and IsPosInt( pos[2] ) then
            SetIsZero( M, false );
        fi;
        return pos;
    fi;
    
    #=====# the fallback method #=====#
    
    m := NumberRows( M );
    n := NumberColumns( M );
    
    for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do
            if not [ i, j ] in poslist and not j in poslist and
               IsUnit( R, M[ i, j ] ) then
                SetIsZero( M, false );
                return [ i, j ];
            fi;
        od;
    od;
    
    return fail;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="PositionOfFirstNonZeroEntryPerRow:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, poslist" Name="PositionOfFirstNonZeroEntryPerRow" Label="homalgTable entry"/>
##    <Returns>a list of nonnegative integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>PositionOfFirstNonZeroEntryPerRow</C> is bound then the standard method
##      of the attribute <Ref Attr="PositionOfFirstNonZeroEntryPerRow"/> shown below returns
##      <M>RP</M>!.<C>PositionOfFirstNonZeroEntryPerRow</C><M>( <A>M</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( PositionOfFirstNonZeroEntryPerRow,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, pos, entries, r, c, i, k, j;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.PositionOfFirstNonZeroEntryPerRow) then
        return RP!.PositionOfFirstNonZeroEntryPerRow( M );
    elif IsBound(RP!.PositionOfFirstNonZeroEntryPerColumn) then
        return PositionOfFirstNonZeroEntryPerColumn( Involution( M ) );
    fi;
    
    #=====# the fallback method #=====#
    
    entries := EntriesOfHomalgMatrix( M );
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    pos := ListWithIdenticalEntries( r, 0 );
    
    for i in [ 1 .. r ] do
        k := (i - 1) * c;
        for j in [ 1 .. c ] do
            if not IsZero( entries[k + j] ) then
                pos[i] := j;
                break;
            fi;
        od;
    od;
    
    return pos;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="PositionOfFirstNonZeroEntryPerColumn:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, poslist" Name="PositionOfFirstNonZeroEntryPerColumn" Label="homalgTable entry"/>
##    <Returns>a list of nonnegative integers</Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>M</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>PositionOfFirstNonZeroEntryPerColumn</C> is bound then the standard method
##      of the attribute <Ref Attr="PositionOfFirstNonZeroEntryPerColumn"/> shown below returns
##      <M>RP</M>!.<C>PositionOfFirstNonZeroEntryPerColumn</C><M>( <A>M</A> )</M>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( PositionOfFirstNonZeroEntryPerColumn,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, pos, entries, r, c, j, i, k;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.PositionOfFirstNonZeroEntryPerColumn) then
        return RP!.PositionOfFirstNonZeroEntryPerColumn( M );
    elif IsBound(RP!.PositionOfFirstNonZeroEntryPerRow) then
        return PositionOfFirstNonZeroEntryPerRow( Involution( M ) );
    fi;
    
    #=====# the fallback method #=====#
    
    entries := EntriesOfHomalgMatrix( M );
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    pos := ListWithIdenticalEntries( c, 0 );
    
    for j in [ 1 .. c ] do
        for i in [ 1 .. r ] do
            k := (i - 1) * c;
            if not IsZero( entries[k + j] ) then
                pos[j] := i;
                break;
            fi;
        od;
    od;
    
    return pos;
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##
InstallMethod( DivideEntryByUnit,
        "for homalg matrices",
        [ IsHomalgMatrix, IsPosInt, IsPosInt, IsRingElement ],
        
  function( M, i, j, u )
    local R, RP;
    
    if IsEmptyMatrix( M ) then
        return;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.DivideEntryByUnit) then
        RP!.DivideEntryByUnit( M, i, j, u );
    else
        M[ i, j ] := M[ i, j ] / u;
    fi;
    
    ## caution: we deliberately do not return a new hull for Eval( M )
    
end );
    
##
InstallMethod( DivideRowByUnit,
        "for homalg matrices",
        [ IsHomalgMatrix, IsPosInt, IsRingElement, IsInt ],
        
  function( M, i, u, j )
    local R, RP, a, mat;
    
    if IsEmptyMatrix( M ) then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.DivideRowByUnit) then
        RP!.DivideRowByUnit( M, i, u, j );
    else
        
        #=====# the fallback method #=====#
        
        if j > 0 then
            ## the two for's avoid creating non-dense lists:
            for a in [ 1 .. j - 1 ] do
                DivideEntryByUnit( M, i, a, u );
            od;
            for a in [ j + 1 .. NumberColumns( M ) ] do
                DivideEntryByUnit( M, i, a, u );
            od;
            M[ i, j ] := One( R );
        else
            for a in [ 1 .. NumberColumns( M ) ] do
                DivideEntryByUnit( M, i, a, u );
            od;
        fi;
        
    fi;
    
    ## since all what we did had a side effect on Eval( M ) ignoring
    ## possible other Eval's, e.g. EvalCompose, we want to return
    ## a new homalg matrix object only containing Eval( M )
    mat := HomalgMatrixWithAttributes( [
                   Eval, Eval( M ),
                   NumberRows, NumberRows( M ),
                   NumberColumns, NumberColumns( M ),
                   ], R );
    
    if HasIsZero( M ) and not IsZero( M ) then
        SetIsZero( mat, false );
    fi;
    
    return mat;
    
end );

##
InstallMethod( DivideColumnByUnit,
        "for homalg matrices",
        [ IsHomalgMatrix, IsPosInt, IsRingElement, IsInt ],
        
  function( M, j, u, i )
    local R, RP, a, mat;
    
    if IsEmptyMatrix( M ) then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.DivideColumnByUnit) then
        RP!.DivideColumnByUnit( M, j, u, i );
    else
        
        #=====# the fallback method #=====#
        
        if i > 0 then
            ## the two for's avoid creating non-dense lists:
            for a in [ 1 .. i - 1 ] do
                DivideEntryByUnit( M, a, j, u );
            od;
            for a in [ i + 1 .. NumberRows( M ) ] do
                DivideEntryByUnit( M, a, j, u );
            od;
            M[ i, j ] := One( R );
        else
            for a in [ 1 .. NumberRows( M ) ] do
                DivideEntryByUnit( M, a, j, u );
            od;
        fi;
        
    fi;
    
    ## since all what we did had a side effect on Eval( M ) ignoring
    ## possible other Eval's, e.g. EvalCompose, we want to return
    ## a new homalg matrix object only containing Eval( M )
    mat := HomalgMatrixWithAttributes( [
                   Eval, Eval( M ),
                   NumberRows, NumberRows( M ),
                   NumberColumns, NumberColumns( M ),
                   ], R );
    
    if HasIsZero( M ) and not IsZero( M ) then
        SetIsZero( mat, false );
    fi;
    
    return mat;
    
end );

##
InstallMethod( CopyRowToIdentityMatrix,
        "for homalg matrices",
        [ IsHomalgMatrix, IsPosInt, IsList, IsPosInt ],
        
  function( M, i, L, j )
    local R, RP, v, vi, l, r;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.CopyRowToIdentityMatrix) then
        RP!.CopyRowToIdentityMatrix( M, i, L, j );
    else
        
        #=====# the fallback method #=====#
        
        if Length( L ) > 0 and IsHomalgMatrix( L[1] ) then
            v := L[1];
        fi;
        
        if Length( L ) > 1 and IsHomalgMatrix( L[2] ) then
            vi := L[2];
        fi;
        
        if IsBound( v ) and IsBound( vi ) then
            ## the two for's avoid creating non-dense lists:
            for l in [ 1 .. j - 1 ] do
                r := M[ i, l ];
                if not IsZero( r ) then
                    v[ j, l ] := -r;
                    vi[ j, l ] := r;
                fi;
            od;
            for l in [ j + 1 .. NumberColumns( M ) ] do
                r := M[ i, l ];
                if not IsZero( r ) then
                    v[ j, l ] := -r;
                    vi[ j, l ] := r;
                fi;
            od;
        elif IsBound( v ) then
            ## the two for's avoid creating non-dense lists:
            for l in [ 1 .. j - 1 ] do
                r := M[ i, l ];
                v[ j, l ] := -r;
            od;
            for l in [ j + 1 .. NumberColumns( M ) ] do
                r := M[ i, l ];
                v[ j, l ] := -r;
            od;
        elif IsBound( vi ) then
            ## the two for's avoid creating non-dense lists:
            for l in [ 1 .. j - 1 ] do
                r := M[ i, l ];
                vi[ j, l ] := r;
            od;
            for l in [ j + 1 .. NumberColumns( M ) ] do
                r := M[ i, l ];
                vi[ j, l ] := r;
            od;
        fi;
        
    fi;
    
end );

##
InstallMethod( CopyColumnToIdentityMatrix,
        "for homalg matrices",
        [ IsHomalgMatrix, IsPosInt, IsList, IsPosInt ],
        
  function( M, j, L, i )
    local R, RP, u, ui, m, k, r;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.CopyColumnToIdentityMatrix) then
        RP!.CopyColumnToIdentityMatrix( M, j, L, i );
    else
        
        #=====# the fallback method #=====#
        
        if Length( L ) > 0 and IsHomalgMatrix( L[1] ) then
            u := L[1];
        fi;
        
        if Length( L ) > 1 and IsHomalgMatrix( L[2] ) then
            ui := L[2];
        fi;
        
        if IsBound( u ) and IsBound( ui ) then
            ## the two for's avoid creating non-dense lists:
            for k in [ 1 .. i - 1 ] do
                r := M[ k, j ];
                if not IsZero( r ) then
                    u[ k, i ] := -r;
                    ui[ k, i ] := r;
                fi;
            od;
            for k in [ i + 1 .. NumberRows( M ) ] do
                r := M[ k, j ];
                if not IsZero( r ) then
                    u[ k, i ] := -r;
                    ui[ k, i ] := r;
                fi;
            od;
        elif IsBound( u ) then
            ## the two for's avoid creating non-dense lists:
            for k in [ 1 .. i - 1 ] do
                r := M[ k, j ];
                u[ k, i ] := -r;
            od;
            for k in [ i + 1 .. NumberRows( M ) ] do
                r := M[ k, j ];
                u[ k, i ] := -r;
            od;
        elif IsBound( ui ) then
            ## the two for's avoid creating non-dense lists:
            for k in [ 1 .. i - 1 ] do
                r := M[ k, j ];
                ui[ k, i ] := r;
            od;
            for k in [ i + 1 .. NumberRows( M ) ] do
                r := M[ k, j ];
                ui[ k, i ] := r;
            od;
        fi;
        
    fi;
    
end );

##
InstallMethod( SetColumnToZero,
        "for homalg matrices",
        [ IsHomalgMatrix, IsPosInt, IsPosInt ],
        
  function( M, i, j )
    local R, RP, zero, k;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.SetColumnToZero) then
        RP!.SetColumnToZero( M, i, j );
    else
        
        #=====# the fallback method #=====#
        
        zero := Zero( R );
        
        ## the two for's avoid creating non-dense lists:
        for k in [ 1 .. i - 1 ] do
            M[ k, j ] := zero;
        od;
        
        for k in [ i + 1 .. NumberRows( M ) ] do
            M[ k, j ] := zero;
        od;
        
    fi;
    
    ## since all what we did had a side effect on Eval( M ) ignoring
    ## possible other Eval's, e.g. EvalCompose, we want to return
    ## a new homalg matrix object only containing Eval( M )
    return HomalgMatrixWithAttributes( [
                 Eval, Eval( M ),
                 NumberRows, NumberRows( M ),
                 NumberColumns, NumberColumns( M ),
                 ], R );
    
end );

##
InstallMethod( GetCleanRowsPositions,
        "for homalg matrices",
        [ IsHomalgMatrix, IsHomogeneousList ],
        
  function( M, clean_columns )
    local R, RP, one, clean_rows, m, j, i;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.GetCleanRowsPositions) then
        return RP!.GetCleanRowsPositions( M, clean_columns );
    fi;
    
    one := One( R );
    
    #=====# the fallback method #=====#
    
    clean_rows := [ ];
    
    m := NumberRows( M );
    
    for j in clean_columns do
        for i in [ 1 .. m ] do
            if IsOne( M[ i, j ] ) then
                Add( clean_rows, i );
                break;
            fi;
        od;
    od;
    
    return clean_rows;
    
end );

##
InstallMethod( Eval,
        "for homalg matrices",
        [ IsHomalgMatrix and HasEvalConvertRowToMatrix ],
        
  function( C )
    local e, M, r, c, R, RP;
    
    e := EvalConvertRowToMatrix( C );
    M := e[1];
    r := e[2];
    c := e[3];
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertRowToMatrix) then
        return RP!.ConvertRowToMatrix( M, r, c );
    elif IsBound(RP!.ConvertRowToTransposedMatrix) then
        return Eval( TransposedMatrix( ConvertRowToTransposedMatrix( M, c, r ) ) );
    elif IsBound(RP!.ConvertColumnToMatrix) then
        return Eval( TransposedMatrix( ConvertColumnToMatrix( TransposedMatrix( M ), c, r ) ) );
    fi;
    
    if IsHomalgInternalMatrixRep( M ) and IsInternalMatrixHull( Eval( M ) ) then
        return Eval( HomalgMatrix( ListToListList( Eval( M )!.matrix[1], r, c ), r, c, R ) );
    fi;
    
    #=====# the fallback method #=====#
        
    return Eval( UnionOfRows(
                   List( [ 0 .. r - 1 ], i -> CertainColumns( M, [ 1 + i*c .. c + i*c ] ) ) ) );
    
end );

##
InstallMethod( Eval,
        "for homalg matrices",
        [ IsHomalgMatrix and HasEvalConvertColumnToMatrix ],
        
  function( C )
    local e, M, r, c, R, RP;
    
    e := EvalConvertColumnToMatrix( C );
    M := e[1];
    r := e[2];
    c := e[3];
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertColumnToMatrix) then
        return RP!.ConvertColumnToMatrix( M, r, c );
    elif IsBound(RP!.ConvertColumnToTransposedMatrix) then
        return Eval( TransposedMatrix( ConvertColumnToTransposedMatrix( M, c, r ) ) );
    elif IsBound(RP!.ConvertRowToMatrix) then
        return Eval( TransposedMatrix( ConvertRowToMatrix( TransposedMatrix( M ), c, r ) ) );
    fi;
    
    if IsHomalgInternalMatrixRep( M ) and IsInternalMatrixHull( Eval( M ) ) then
        return Eval( HomalgMatrix( TransposedMat( ListToListList( Flat( Eval( M )!.matrix ), c, r ) ), r, c, R ) );
    fi;
    
    #=====# the fallback method #=====#
    
    return Eval( UnionOfColumns(
                   List( [ 0 .. c - 1 ], i -> CertainRows( M, [ 1 + i*r .. r + i*r ] ) ) ) );
    
end );

##
InstallMethod( Eval,
        "for homalg matrices",
        [ IsHomalgMatrix and HasEvalConvertMatrixToRow ],
        
  function( C )
    local M, r, c, R, RP;
    
    M := EvalConvertMatrixToRow( C );
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertMatrixToRow) then
        return RP!.ConvertMatrixToRow( M );
    elif IsBound(RP!.ConvertTransposedMatrixToRow) then
        return Eval( ConvertTransposedMatrixToRow( TransposedMatrix( M ) ) );
    elif IsBound(RP!.ConvertMatrixToColumn) then
        return Eval( TransposedMatrix( ConvertMatrixToColumn( TransposedMatrix( M ) ) ) );
    fi;
    
    if IsHomalgInternalMatrixRep( M ) and IsInternalMatrixHull( Eval( M ) ) then
        return Eval( HomalgMatrix( Concatenation( Eval( M )!.matrix ), 1, r * c, R ) );
    fi;
    
    #=====# the fallback method #=====#
    
    return Eval( UnionOfColumns( List( [ 1 .. r ], i -> CertainRows( M, [ i ] ) ) ) );
    
end );

##
InstallMethod( Eval,
        "for homalg matrices",
        [ IsHomalgMatrix and HasEvalConvertMatrixToColumn ],
        
  function( C )
    local M, r, c, R, RP;
    
    M := EvalConvertMatrixToColumn( C );
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertMatrixToColumn) then
        return RP!.ConvertMatrixToColumn( M );
    elif IsBound(RP!.ConvertTransposedMatrixToColumn) then
        return Eval( ConvertTransposedMatrixToColumn( TransposedMatrix( M ) ) );
    elif IsBound(RP!.ConvertMatrixToRow) then
        return Eval( TransposedMatrix( ConvertMatrixToRow( TransposedMatrix( M ) ) ) );
    fi;
    
    if IsHomalgInternalMatrixRep( M ) and IsInternalMatrixHull( Eval( M ) ) then
        return Eval( HomalgMatrix( Concatenation( TransposedMat( Eval( M )!.matrix ) ), r * c, 1, R ) );
    fi;
    
    #=====# the fallback method #=====#
    
    return Eval( UnionOfRows( List( [ 1 .. c ], j -> CertainColumns( M, [ j ] ) ) ) );
    
end );

##
InstallMethod( ConvertRowToTransposedMatrix,
        "for homalg matrices",
        [ IsHomalgMatrix, IsInt, IsInt ],
        
  function( M, r, c )
    local R, RP, ext_obj, l, j;
    
    if NumberRows( M ) <> 1 then
        Error( "expecting a single row matrix as a first argument\n" );
    fi;
    
    if r = 1 then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertRowToTransposedMatrix) then
        ext_obj := RP!.ConvertRowToTransposedMatrix( M, r, c );
        return HomalgMatrix( ext_obj, r, c, R );
    elif IsBound(RP!.ConvertRowToMatrix) then
        ext_obj := RP!.ConvertRowToMatrix( M, c, r );
        return TransposedMatrix( HomalgMatrix( ext_obj, c, r, R ) );
    fi;
    
    #=====# the fallback method #=====#
    
    ## to use
    ## CreateHomalgMatrixFromString( GetListOfHomalgMatrixAsString( M ), c, r, R )
    ## we would need a transpose afterwards,
    ## which differs from Involution in general:
    
    l := List( [ 1 .. c ], j -> CertainColumns( M, [ (j-1) * r + 1 .. j * r ] ) );
    l := List( l, GetListOfHomalgMatrixAsString );
    l := List( l, a -> CreateHomalgMatrixFromString( a, r, 1, R ) );
    
    return UnionOfColumns( l );
    
end );

##
InstallMethod( ConvertColumnToTransposedMatrix,
        "for homalg matrices",
        [ IsHomalgMatrix, IsInt, IsInt ],
        
  function( M, r, c )
    local R, RP, ext_obj;
    
    if NumberColumns( M ) <> 1 then
        Error( "expecting a single column matrix as a first argument\n" );
    fi;
    
    if c = 1 then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertColumnToTransposedMatrix) then
        ext_obj := RP!.ConvertColumnToTransposedMatrix( M, r, c );
        return HomalgMatrix( ext_obj, r, c, R );
    elif IsBound(RP!.ConvertColumnToMatrix) then
        ext_obj := RP!.ConvertColumnToMatrix( M, c, r );
        return TransposedMatrix( HomalgMatrix( ext_obj, c, r, R ) );
    fi;
    
    #=====# the fallback method #=====#
    
    return CreateHomalgMatrixFromString( GetListOfHomalgMatrixAsString( M ), r, c, R ); ## delicate
    
end );

##
InstallMethod( ConvertTransposedMatrixToRow,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, ext_obj, r, c, l, j;
    
    if NumberRows( M ) = 1 then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        return HomalgZeroMatrix( 1, NumberRows( M ) * NumberColumns( M ), R );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertTransposedMatrixToRow) then
        ext_obj := RP!.ConvertTransposedMatrixToRow( M );
        return HomalgMatrix( ext_obj, 1, NumberRows( M ) * NumberColumns( M ), R );
    fi;
    
    #=====# the fallback method #=====#
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    ## CreateHomalgMatrixFromString( GetListOfHomalgMatrixAsString( "Transpose"( M ) ), 1, r * c, R )
    ## would require a Transpose operation,
    ## which differs from Involution in general:
    
    l := List( [ 1 .. c ], j -> CertainColumns( M, [ j ] ) );
    l := List( l, GetListOfHomalgMatrixAsString );
    l := List( l, a -> CreateHomalgMatrixFromString( a, 1, r, R ) );
    
    return UnionOfColumns( l );
    
end );

##
InstallMethod( ConvertTransposedMatrixToColumn,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, ext_obj;
    
    if NumberColumns( M ) = 1 then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        return HomalgZeroMatrix( NumberRows( M ) * NumberColumns( M ), 1, R );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.ConvertTransposedMatrixToColumn) then
        ext_obj := RP!.ConvertTransposedMatrixToColumn( M );
        return HomalgMatrix( ext_obj, NumberColumns( M ) * NumberRows( M ), 1, R );
    fi;
    
    #=====# the fallback method #=====#
    
    return CreateHomalgMatrixFromString( GetListOfHomalgMatrixAsString( M ), NumberColumns( M ) * NumberRows( M ), 1, R ); ## delicate
    
end );

##
InstallMethod( Eval,
        "for homalg matrices (HasPreEval)",
        [ IsHomalgMatrix and HasPreEval ],
        
  function( C )
    local R, RP, e;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );
    
    e :=  PreEval( C );
    
    ResetFilterObj( C, HasPreEval );
    
    ## delete the component which was left over by GAP
    Unbind( C!.PreEval );
    
    if IsBound(RP!.PreEval) then
        return RP!.PreEval( e );
    fi;
    
    #=====# the fallback method #=====#
    
    return Eval( e );
    
end );

##
InstallMethod( MaxDimensionalRadicalSubobjectOp,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, rad;
    
    if IsBound( M!.MaxDimensionalRadicalSubobjectOp ) then
        return M!.MaxDimensionalRadicalSubobjectOp;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        return HomalgZeroMatrix( 0, 1, R );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.MaxDimensionalRadicalSubobject) then
        rad := RP!.MaxDimensionalRadicalSubobject( M ); ## the external object
        rad := HomalgMatrix( rad, R );
        if IsZero( rad ) then
            return HomalgZeroMatrix( 0, 1, R );
        fi;
        SetNumberColumns( rad, 1 );
        NumberRows( rad );
        IsOne( rad );
        M!.MaxDimensionalRadicalSubobjectOp := rad;
        rad!.MaxDimensionalRadicalSubobjectOp := rad;
        return rad;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called MaxDimensionalRadicalSubobject ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( RadicalSubobjectOp,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, rad;
    
    if IsBound( M!.RadicalSubobjectOp ) then
        return M!.RadicalSubobjectOp;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        return HomalgZeroMatrix( 0, 1, R );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.RadicalSubobject) then
        rad := RP!.RadicalSubobject( M ); ## the external object
        rad := HomalgMatrix( rad, R );
        if IsZero( rad ) then
            rad := HomalgZeroMatrix( 0, 1, R );
        fi;
        SetNumberColumns( rad, 1 );
        NumberRows( rad );
        IsOne( rad );
        if rad = M then
            rad := M;
        fi;
        M!.RadicalSubobjectOp := rad;
        rad!.RadicalSubobjectOp := rad;
        return rad;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called RadicalSubobject ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( RadicalDecompositionOp,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, triv;
    
    if IsBound( M!.RadicalDecomposition ) then
        return M!.RadicalDecomposition;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        if NumberColumns( M ) = 0 then
            triv := HomalgZeroMatrix( 0, 0, R );
        else
            triv := HomalgZeroMatrix( 0, 1, R );
        fi;
        M!.RadicalDecomposition := [ triv ];
        return M!.RadicalDecomposition;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.RadicalDecomposition ) then
        M!.RadicalDecomposition := RP!.RadicalDecomposition( M );
        return M!.RadicalDecomposition;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called RadicalDecomposition ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( EquiDimensionalDecompositionOp,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, triv;
    
    if IsBound( M!.EquiDimensionalDecomposition ) then
        return M!.EquiDimensionalDecomposition;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        if NumberColumns( M ) = 0 then
            triv := HomalgZeroMatrix( 0, 0, R );
        else
            triv := HomalgZeroMatrix( 0, 1, R );
        fi;
        M!.EquiDimensionalDecomposition := [ triv ];
        return M!.EquiDimensionalDecomposition;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.EquiDimensionalDecomposition ) then
        M!.EquiDimensionalDecomposition := RP!.EquiDimensionalDecomposition( M );
        return M!.EquiDimensionalDecomposition;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called EquiDimensionalDecomposition ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( MaxDimensionalSubobjectOp,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, max;
    
    if IsBound( M!.MaxDimensionalSubobjectOp ) then
        return M!.MaxDimensionalSubobjectOp;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        return HomalgZeroMatrix( 0, 1, R );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.MaxDimensionalSubobject) then
        max := RP!.MaxDimensionalSubobject( M ); ## the external object
        max := HomalgMatrix( max, R );
        if IsZero( max ) then
            return HomalgZeroMatrix( 0, 1, R );
        fi;
        SetNumberColumns( max, 1 );
        NumberRows( max );
        IsOne( max );
        M!.MaxDimensionalSubobjectOp := max;
        max!.MaxDimensionalSubobjectOp := max;
        return max;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called MaxDimensionalSubobject ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( PrimaryDecompositionOp,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, triv;
    
    if IsBound( M!.PrimaryDecomposition ) then
        return M!.PrimaryDecomposition;
    fi;
    
    R := HomalgRing( M );
    
    if IsZero( M ) then
        if NumberColumns( M ) = 0 then
            triv := HomalgZeroMatrix( 0, 0, R );
        else
            triv := HomalgZeroMatrix( 0, 1, R );
        fi;
        M!.PrimaryDecomposition := [ [ triv, triv ] ];
        return M!.PrimaryDecomposition;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.PrimaryDecomposition ) then
        M!.PrimaryDecomposition := RP!.PrimaryDecomposition( M );
        return M!.PrimaryDecomposition;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called PrimaryDecomposition ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##  <#GAPDoc Label="Eliminate">
##  <ManSection>
##    <Oper Arg="rel, indets" Name="Eliminate"/>
##    <Returns>a &homalg; matrix</Returns>
##    <Description>
##      Eliminate the independents <A>indets</A> from the matrix (or list of ring elements) <A>rel</A>,
##      i.e. compute a generating set
##      of the ideal defined as the intersection of the ideal generated by the entries of the list <A>rel</A>
##      with the subring generated by all indeterminates except those in <A>indets</A>.
##      by the list of indeterminates <A>indets</A>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( Eliminate,
        "for a homalg matrix and list of homalg ring elements",
        [ IsHomalgMatrix, IsList ],
        
  function( rel, indets )
    local R, RP, elim;
    
    R := HomalgRing( rel );
    
    if IsZero( rel ) then
        return HomalgZeroMatrix( 0, 1, R );
    fi;
    
    rel := EntriesOfHomalgMatrix( rel );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Eliminate) then
        elim := RP!.Eliminate( rel, indets, R ); ## the external object
        elim := HomalgMatrix( elim, R );
        if IsZero( elim ) then
            return HomalgZeroMatrix( 0, 1, R );
        fi;
        SetNumberColumns( elim, 1 );
        NumberRows( elim );
        return elim;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called Eliminate ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( Eliminate,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( rel )
    local R, indets, B;
    
    R := HomalgRing( rel );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
        B := BaseRing( R );
    else
        indets := Indeterminates( R );
        B := CoefficientsRing( R );
    fi;
    
    return B * Eliminate( rel, indets );
    
end );

##
InstallMethod( Eliminate,
        "for two lists of ring elements and a homalg ring",
        [ IsList, IsList, IsHomalgRing ],
        
  function( rel, indets, R )
    
    rel := HomalgMatrix( rel, Length( rel ), 1, R );
    
    return Eliminate( rel, indets );
    
end );

##
InstallMethod( Eliminate,
        "for two lists of ring elements",
        [ IsList, IsList ],
        
  function( rel, indets )
    local R;
    
    if not rel = [ ] then
        R := HomalgRing( rel[1] );
    elif not indets = [ ] then
        R := HomalgRing( indets[1] );
    else
        Error( "cannot extract ring out of two empty input lists\n" );
    fi;
    
    return Eliminate( rel, indets, R );
    
end );

##
InstallMethod( Eliminate,
        "for a homalg matrix and ring element",
        [ IsHomalgMatrix, IsHomalgRingElement ],
        
  function( rel, v )
    
    return Eliminate( rel, [ v ] );
    
end );

##
InstallMethod( Eliminate,
        "for a list and ring element",
        [ IsList, IsHomalgRingElement ],
        
  function( rel, v )
    
    return Eliminate( rel, [ v ] );
    
end );

##
InstallMethod( Coefficients,
        "for a ring element and a list of indeterminates",
        [ IsHomalgRingElement, IsList ],
        
  function( poly, var )
    local R, RP, both, monomials, coeffs;
    
    R := HomalgRing( poly );
    
    if IsZero( poly ) then
        coeffs := HomalgZeroMatrix( 1, 0, R );
        coeffs!.monomials := MakeImmutable( [ ] );
        return coeffs;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Coefficients) then
        both := RP!.Coefficients( poly, var ); ## the pair of external objects
        monomials := HomalgMatrix( both[1], R );
        monomials := EntriesOfHomalgMatrix( monomials );
        coeffs := HomalgMatrix( both[2], Length( monomials ), 1, R );
        coeffs!.monomials := MakeImmutable( monomials );
        return coeffs;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called Coefficients ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( Coefficients,
        "for a ring element and an indeterminate",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( poly, var )
    
    return Coefficients( poly, [ var ] );
    
end );

##
InstallMethod( Coefficients,
        "for a homalg ring element and a string",
        [ IsHomalgRingElement, IsString and IsStringRep ],
        
  function( poly, var_name )
    
    return Coefficients( poly, var_name / HomalgRing( poly ) );
    
end );

##
InstallMethod( Coefficients,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( poly )
    local R, indets, coeffs;
    
    R := HomalgRing( poly );
    
    if IsBound( poly!.Coefficients ) then
        return poly!.Coefficients;
    fi;
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
    elif HasRelativeIndeterminateAntiCommutingVariablesOfExteriorRing( R ) then
        indets := RelativeIndeterminateAntiCommutingVariablesOfExteriorRing( R );
    elif HasIndeterminateAntiCommutingVariablesOfExteriorRing( R ) then
        indets := IndeterminateAntiCommutingVariablesOfExteriorRing( R );
    elif HasIndeterminateShiftsOfShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfShiftAlgebra( R );
    elif HasIndeterminateShiftsOfPseudoDoubleShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfPseudoDoubleShiftAlgebra( R );
    elif HasIndeterminateShiftsOfDoubleShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfDoubleShiftAlgebra( R );
    elif HasIndeterminateShiftsOfBiasedDoubleShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfBiasedDoubleShiftAlgebra( R );
    elif HasIsFieldForHomalg( R ) and IsFieldForHomalg( R ) then
        indets := [ ];
    else
        TryNextMethod( );
    fi;
    
    coeffs := Coefficients( poly, indets );
    
    poly!.Coefficients := coeffs;
    
    return coeffs;
    
end );

##
InstallMethod( Coefficients,
        "for a homalg matrix and a list of indeterminates",
        [ IsHomalgMatrix, IsList ],
        
  function( matrix, var )
    local R, RP, both, monomials, coeffs;
    
    R := HomalgRing( matrix );
    
    if IsZero( matrix ) then
        coeffs := HomalgZeroMatrix( 1, 0, R );
        coeffs!.monomials := MakeImmutable( [ ] );
        return coeffs;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.CoefficientsMatrix) then
        both := RP!.CoefficientsMatrix( matrix, var ); ## the pair of external objects
        monomials := HomalgMatrix( both[1], R );
        monomials := EntriesOfHomalgMatrix( monomials );
        coeffs := HomalgMatrix( both[2], Length( monomials ), NumberRows( matrix ), R );
        coeffs!.monomials := MakeImmutable( monomials );
        return coeffs;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called Coefficients ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( Coefficients,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( matrix )
    local R, indets, coeffs;
    
    R := HomalgRing( matrix );
    
    if IsBound( matrix!.Coefficients ) then
        return matrix!.Coefficients;
    fi;
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
    elif HasRelativeIndeterminateAntiCommutingVariablesOfExteriorRing( R ) then
        indets := RelativeIndeterminateAntiCommutingVariablesOfExteriorRing( R );
    elif HasIndeterminateAntiCommutingVariablesOfExteriorRing( R ) then
        indets := IndeterminateAntiCommutingVariablesOfExteriorRing( R );
    elif HasIndeterminateShiftsOfShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfShiftAlgebra( R );
    elif HasIndeterminateShiftsOfPseudoDoubleShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfPseudoDoubleShiftAlgebra( R );
    elif HasIndeterminateShiftsOfDoubleShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfDoubleShiftAlgebra( R );
    elif HasIndeterminateShiftsOfBiasedDoubleShiftAlgebra( R ) then
        indets := IndeterminateShiftsOfBiasedDoubleShiftAlgebra( R );
    elif HasIsFieldForHomalg( R ) and IsFieldForHomalg( R ) then
        indets := [ ];
    else
        TryNextMethod( );
    fi;
    
    coeffs := Coefficients( matrix, indets );
    
    matrix!.Coefficients := coeffs;
    
    return coeffs;
    
end );

##
InstallMethod( DecomposeInMonomials,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( poly )
    local coeffs, monoms;
    
    coeffs := Coefficients( poly );
    monoms := coeffs!.monomials;
    coeffs := EntriesOfHomalgMatrix( coeffs );
    
    return ListN( coeffs, monoms, {a,b} -> [ a, b ] );
    
end );

##  <#GAPDoc Label="Eval:HasEvalCoefficientsWithGivenMonomials">
##  <ManSection>
##    <Meth Arg="C" Name="Eval" Label="for matrices created with CoefficientsWithGivenMonomials"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      In case the matrix was created using
##      <Ref Func="CoefficientsWithGivenMonomials" Label="for two homalg matrices"/>
##      then the filter <C>HasEvalCoefficientsWithGivenMonomials</C> for <A>C</A> is set to true and
##      the <C>homalgTable</C> function <Ref Meth="CoefficientsWithGivenMonomials" Label="homalgTable entry"/>
##      will be used to set the attribute <C>Eval</C>.
##    <Listing Type="Code"><![CDATA[
InstallMethod( Eval,
        "for homalg matrices (HasEvalCoefficientsWithGivenMonomials)",
        [ IsHomalgMatrix and HasEvalCoefficientsWithGivenMonomials ],
        
  function( C )
    local R, RP, pair, M, monomials;
    
    R := HomalgRing( C );
    
    RP := homalgTable( R );

    pair := EvalCoefficientsWithGivenMonomials( C );

    M := pair[1];
    monomials := pair[2];
    
    if IsBound( RP!.CoefficientsWithGivenMonomials ) then
        
        return RP!.CoefficientsWithGivenMonomials( M, monomials );
        
    fi;

    Error( "could not find a procedure called CoefficientsWithGivenMonomials ",
            "in the homalgTable of the ring\n" );
    
end );
##  ]]></Listing>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##  <#GAPDoc Label="CoefficientsWithGivenMonomials:homalgTable_entry">
##  <ManSection>
##    <Func Arg="M, monomials" Name="CoefficientsWithGivenMonomials" Label="homalgTable entry"/>
##    <Returns>the <C>Eval</C> value of a &homalg; matrix <A>C</A></Returns>
##    <Description>
##      Let <M>R :=</M> <C>HomalgRing</C><M>( <A>C</A> )</M> and <M>RP :=</M> <C>homalgTable</C><M>( R )</M>.
##      If the <C>homalgTable</C> component <M>RP</M>!.<C>CoefficientsWithGivenMonomials</C> is bound then
##      the method <Ref Meth="Eval" Label="for matrices created with CoefficientsWithGivenMonomials"/> returns
##      <M>RP</M>!.<C>CoefficientsWithGivenMonomials</C> applied to the content of the attribute
##      <C>EvalCoefficientsWithGivenMonomials</C><M>( <A>C</A> ) = [ <A>M</A>, <A>monomials</A> ]</M>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>

##
InstallMethod( CoefficientsOfUnivariatePolynomial,
        "for two homalg ring elements",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( r, var )
    local R, RP, ext_obj;
    
    if IsZero( r ) then
        return HomalgZeroMatrix( 1, 0, R );
    fi;
    
    R := HomalgRing( r );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.CoefficientsOfUnivariatePolynomial) then
        ext_obj := RP!.CoefficientsOfUnivariatePolynomial( r, var );
        return HomalgMatrix( ext_obj, 1, "unknown_number_of_columns", R );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( CoefficientsOfUnivariatePolynomial,
        "for a homalg ring element and a string",
        [ IsHomalgRingElement, IsString ],
        
  function( r, var_name )
    
    return CoefficientsOfUnivariatePolynomial( r, var_name / HomalgRing( r ) );
    
end );

## for univariate polynomials over arbitrary base rings
InstallMethod( CoefficientsOfUnivariatePolynomial,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, indets;
    
    R := HomalgRing( r );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
    fi;
    
    if not Length( indets ) = 1 then
        TryNextMethod( );
    fi;
    
    return CoefficientsOfUnivariatePolynomial( r, indets[1] );
    
end );

## for univariate polynomials over arbitrary base rings
InstallMethod( CoefficientOfUnivariatePolynomial,
        "for a homalg ring element and an integer",
        [ IsHomalgRingElement, IsInt ],
        
  function( r, j )
    local coeffs;
    
    coeffs := CoefficientsOfUnivariatePolynomial( r );
    coeffs := EntriesOfHomalgMatrix( coeffs );
    
    if j > Length( coeffs ) - 1 then
        return Zero( r );
    fi;
    
    return coeffs[j + 1];
    
end );

##
InstallMethod( LeadingCoefficient,
        "for lists of ring elements",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( poly, var )
    
    return MatElm( Coefficients( poly, var ), 1, 1 );
    
end );

##
InstallMethod( LeadingCoefficient,
        "for a homalg ring element and a string",
        [ IsHomalgRingElement, IsString ],
        
  function( r, var_name )
    
    return LeadingCoefficient( r, var_name / HomalgRing( r ) );
    
end );

##
InstallMethod( LeadingCoefficient,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( poly )
    local lc;
    
    if IsBound( poly!.LeadingCoefficient ) then
        return poly!.LeadingCoefficient;
    fi;
    
    lc := MatElm( Coefficients( poly ), 1, 1 );
    
    poly!.LeadingCoefficient := lc;
    
    return lc;
    
end );

## FIXME: make this a fallback method
InstallMethod( LeadingMonomial,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( poly )
    local lm;
    
    if IsBound( poly!.LeadingMonomial ) then
        return poly!.LeadingMonomial;
    fi;
    
    if IsZero( poly ) then
        lm := poly;
    else
        lm := Coefficients( poly )!.monomials[1];
    fi;
    
    poly!.LeadingMonomial := lm;
    
    return lm;

end );

##
InstallMethod( IndicatorMatrixOfNonZeroEntries,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( mat )
    local R, RP, result, r, c, i, j;
    
    R := HomalgRing( mat );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.IndicatorMatrixOfNonZeroEntries) then
        return RP!.IndicatorMatrixOfNonZeroEntries( mat );
    fi;
    
    r := NumberRows( mat );
    c := NumberColumns( mat );
    
    result := List( [ 1 .. r ], a -> ListWithIdenticalEntries( c, 0 ) );
    
    for i in [ 1 .. r ] do
        for j in [ 1 .. c ] do
            if not IsZero( mat[ i, j ] ) then
                result[i][j] := 1;
            fi;
        od;
    od;
    
    return result;
    
end );

##
InstallMethod( Pullback,
        "for homalg rings",
        [ IsHomalgRingMap, IsHomalgMatrix ],
        
  function( phi, M )
    local R, S, T, r, c, RP;
    
    R := HomalgRing( M );
    
    S := Source( phi );
    
    T := Range( phi );
    
    if not IsIdenticalObj( S, R ) then
        
        if HasAmbientRing( R ) then
            R := AmbientRing( R );
            M := R * M;
        fi;
        
        if HasAmbientRing( S ) then
            S := AmbientRing( S );
        fi;
        
        if not IsIdenticalObj( S, R ) then
            Error( "the source ring of the ring map phi and the ring R of the matrix are not identical\n" );
        fi;
        
        if not IsBound( phi!.RingMapFromAmbientRing ) then
            phi!.RingMapFromAmbientRing := RingMap( ImagesOfRingMapAsColumnMatrix( phi ), S, T );
        fi;
        
        return Pullback( phi!.RingMapFromAmbientRing, M );
        
    fi;
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    if IsZero( M ) then
        
        return HomalgZeroMatrix( r, c, T );
        
    fi;
    
    if IsEmptyMatrix( ImagesOfRingMapAsColumnMatrix( phi ) ) then
        
        return T * M;
        
    fi;
    
    RP := homalgTable( T );
    
    if IsBound( RP!.Pullback ) then
        
        return HomalgMatrix( RP!.Pullback( phi, M ), NumberRows( M ), NumberColumns( M ), T );
        
    fi;
    
    if not IsHomalgInternalRingRep( T ) then
        Error( "could not find a procedure called Pullback ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( Pullback,
        "for homalg rings",
        [ IsHomalgRingMap, IsRingElement ],
        
  function( phi, r )
    
    r := HomalgMatrix( [ r ], 1, 1, Source( phi ) );
    
    r := Pullback( phi, r );
    
    return r[ 1, 1 ];
    
end );

####################################
#
# methods for operations (you probably don't urgently need to replace for an external CAS):
#
####################################

##
InstallMethod( \+,
        "for homalg ring elements",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( r1, r2 )
    local R, RP;
    
    R := HomalgRing( r1 );
    
    if not HasRingElementConstructor( R ) then
        Error( "no ring element constructor found in the ring\n" );
    fi;
    
    if not IsIdenticalObj( R, HomalgRing( r2 ) ) then
        return Error( "the two elements are not in the same ring\n" );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Sum) then
        return RingElementConstructor( R )( RP!.Sum( r1, r2 ), R );
    elif IsBound(RP!.Minus) then
        return RingElementConstructor( R )( RP!.Minus( r1, RP!.Minus( Zero( R ), r2 ) ), R );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( \*,
        "for homalg ring elements",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( r1, r2 )
    local R, RP;
    
    R := HomalgRing( r1 );
    
    if not HasRingElementConstructor( R ) then
        Error( "no ring element constructor found in the ring\n" );
    fi;
    
    if not IsIdenticalObj( R, HomalgRing( r2 ) ) then
        return Error( "the two elements are not in the same ring\n" );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Product) then
        return RingElementConstructor( R )( RP!.Product( r1, r2 ), R ) ;
    fi;
    
    #=====# the fallback method #=====#
    
    return MatElm( HomalgMatrix( [ r1 ], 1, 1, R ) * HomalgMatrix( [ r2 ], 1, 1, R ), 1, 1 );
    
end );

##
InstallMethod( Degree,
        "for homalg ring elements",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, RP, deg;
    
    if IsBound( r!.Degree ) then
        return r!.Degree;
    fi;
    
    R := HomalgRing( r );
    
    ## do not delete this
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        TryNextMethod( );
    fi;
    
    RP := homalgTable( R );
    
    if not IsBound(RP!.DegreeOfRingElement) then
        TryNextMethod( );
    fi;
    
    deg := RP!.DegreeOfRingElement( r, R );
    
    r!.Degree := deg;
    
    return deg;
    
end );

##
InstallMethod( Degree,
        "for homalg ring elements",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, RP, coeffs, deg;
    
    if IsBound( r!.Degree ) then
        return r!.Degree;
    fi;
    
    if IsZero( r ) then
        return -1;
    fi;
    
    R := HomalgRing( r );
    
    if not HasRelativeIndeterminatesOfPolynomialRing( R ) then
        TryNextMethod( );
    fi;
    
    RP := homalgTable( R );
    
    if not ( IsBound(RP!.Coefficients) and IsBound( RP!.DegreeOfRingElement ) ) then
        TryNextMethod( );
    fi;
    
    coeffs := Coefficients( r );
    
    deg := RP!.DegreeOfRingElement( coeffs!.monomials[1], R );
    
    r!.Degree := deg;
    
    return deg;
    
end );

##
InstallMethod( MatrixOfSymbols,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( mat )
    local S, R, RP, symb;
    
    R := HomalgRing( mat );
    
    S := AssociatedGradedRing( R );
    
    if IsZero( mat ) then
        return HomalgZeroMatrix( NumberRows( mat ), NumberColumns( mat ), S );
    elif IsOne( mat ) then
        return HomalgIdentityMatrix( NumberRows( mat ), S );
    fi;
    
    RP := homalgTable( R );
    
    if not IsBound(RP!.MatrixOfSymbols) then
        Error( "could not find a procedure called MatrixOfSymbols ",
               "in the homalgTable of the ring\n" );
    fi;
    
    symb := RP!.MatrixOfSymbols( mat );
    
    symb := S * HomalgMatrix( symb, NumberRows( mat ), NumberColumns( mat ), R );
    
    ## TODO: add more properties and attributes to symb
    
    return symb;
    
end );

##
InstallMethod( GetRidOfRowsAndColumnsWithUnits,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local MM, R, RP, rr, cc, r, c, UI, VI, U, V, rows, columns,
          deleted_rows, deleted_columns, pos, i, j, e,
          column, column_range, row, row_range, IdU, IdV, u, v, U_M_V;
    
    if IsBound( M!.GetRidOfRowsAndColumnsWithUnits ) then
        return M!.GetRidOfRowsAndColumnsWithUnits;
    fi;
    
    MM := M;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    rr := NumberRows( M );
    cc := NumberColumns( M );
    
    r := rr;
    c := cc;
    
    UI := HomalgIdentityMatrix( rr, R );
    VI := HomalgIdentityMatrix( cc, R );
    
    U := UI;
    V := VI;
    
    if IsBound( RP!.GetRidOfRowsAndColumnsWithUnits ) then
        
        M := RP!.GetRidOfRowsAndColumnsWithUnits( M );
        
        rows := M[2];
        columns := M[3];
        
        deleted_rows := M[4];
        deleted_columns := M[5];
        
        M := M[1];
        
        Assert( 6, IsUnitFree( M ) );
        SetIsUnitFree( M, true );
        
    else
        
        rows := [ ];
        columns := [ ];
        
        deleted_rows := [ ];
        deleted_columns := [ ];
        
    fi;
    
    #=====# the fallback method #=====#
    
    pos := GetUnitPosition( M );
    
    SetIsUnitFree( M, pos = fail );
    
    while not IsUnitFree( M ) do
        
        i := pos[1]; j := pos[2];
        
        e := M[ i, j ];
        
        Assert( 6, IsUnit( e ) );
        Assert( 6, not IsZero( e ) );
        
        if IsHomalgRingElement( e ) then
            e!.IsUnit := true;
            SetIsZero( e, false );
        fi;
        
        if IsOne( e ) then
            e := HomalgIdentityMatrix( 1, R );
        else
            e := e^-1;
            Assert( 0, not e = fail );
            e := HomalgMatrix( [ e ], 1, 1, R );
            
            Assert( 6, not IsZero( e ) );
            SetIsZero( e, false );
            
        fi;
        
        Add( rows, i );
        Add( columns, j );
        
        column := CertainColumns( M, [ j ] );
        
        column_range := Concatenation( [ 1 .. j - 1 ], [ j + 1 .. c ] );
        
        M := CertainColumns( M, column_range ); c := c - 1;
        
        row := CertainRows( M, [ i ] );
        
        row_range := Concatenation( [ 1 .. i - 1 ], [ i + 1 .. r ] );
        
        column := CertainRows( column, row_range );
        
        M := CertainRows( M, row_range ); r := r - 1;
        
        ## the following line breaks the symmetry of the line redefining M,
        ## which could have been M := M - column * e * row;
        ## but since the adapted row will be reused in creating
        ## the trafo matrix V below, I decided to redefine the row
        ## for effeciency reasons
        
        row := e * row;
        
        M := M - column * row;
        
        column := column * e;
        
        Add( deleted_rows, -row );
        Add( deleted_columns, -column );
        
        pos := GetUnitPosition( M );
        
        SetIsUnitFree( M, pos = fail );
        
    od;
    
    r := rr;
    c := cc;
    
    for pos in [ 1 .. Length( rows ) ] do
        
        r := r - 1;
        c := c - 1;
        
        i := rows[pos]; j := columns[pos];
        
        IdU := HomalgIdentityMatrix( r, R );
        IdV := HomalgIdentityMatrix( c, R );
        
        u := CertainColumns( IdU, [ 1 .. i - 1 ] );
        u := UnionOfColumns( u, deleted_columns[pos] );
        u := UnionOfColumns( u, CertainColumns( IdU, [ i .. r ] ) );
        
        v := CertainRows( IdV, [ 1 .. j - 1 ] );
        v := UnionOfRows( v, deleted_rows[pos] );
        v := UnionOfRows( v, CertainRows( IdV, [ j .. c ] ) );
        
        U := u * U;
        V := V * v;
        
    od;
    
    ## now bring rows and columns to absolute positions
    
    rr := [ 1 .. rr ];
    cc := [ 1 .. cc ];
    
    Perform( rows, function( i ) Remove( rr, i ); end );
    Perform( columns, function( j ) Remove( cc, j ); end );
    
    UI := CertainColumns( UI, rr );
    VI := CertainRows( VI, cc );
    
    ## 1. Left/RightInverse is better than Left/RightInverseLazy here
    ##    as V and U are known to be a subidentity matrices
    ## 2. Caution:
    ##    (-) U * MM * V is NOT = M, in general, nor
    ##    (-) UI * M * VI is NOT = MM, in general, but
    ##    (+) U * MM and M generate the same column space
    ##    (+) MM * V and M generate the same row space
    ##    (+) UI * M generate column subspace of MM
    ##    (+) M * VI generate row subspace of MM
    
    Assert( 6, GenerateSameColumnModule( U * MM, M ) );
    Assert( 6, GenerateSameRowModule( MM * V, M ) );
    
    Assert( 6, IsZero( DecideZeroColumns( UI * M, BasisOfColumnModule( MM ) ) ) );
    Assert( 6, IsZero( DecideZeroRows( M * VI, BasisOfRowModule( MM ) ) ) );
    
    U_M_V := [ U, UI, M, VI, V ];
    
    MM!.GetRidOfRowsAndColumnsWithUnits := U_M_V;
    
    return U_M_V;
    
end );

##
## L = [ min_deg, max_deg, zt, coeff ]
## min_deg and max_deg determine the minimal and maximal degree of the element
## zt determines the percentage of the zero terms in the element
## The non-trivial coefficients belong to the interval [ 1 .. coeffs ]
##
InstallMethod( Random,
        "for a homalg ring and a list",
        [ IsHomalgRing, IsList ],
        
  function( R, L )
    local RP;
    
    RP := homalgTable( R );
    
    L := Concatenation( [ R ], L );
    
    if IsBound(RP!.RandomPol) then
        return RingElementConstructor( R )( CallFuncList( RP!.RandomPol, L ), R );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( Random,
        "for a homalg ring and an integer",
        [ IsHomalgRing, IsInt ],
        
  function( R, maxdeg )
    
    return Random( R, [ maxdeg ] );
    
end );

##
InstallMethod( Random,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    
    return Random( R, [ 0, Random( [ 0, 1, 1, 1, 2, 2, 2, 3 ] ), 80, 50 ] );
    
end );

##
InstallMethod( Random,
        "for a homalg internal ring",
        [ IsHomalgRing and IsHomalgInternalRingRep ],
        
  function( R )
    
    return Random( R!.ring );
    
end );

##
InstallMethod( Random,
        "for a homalg ring",
        [ IsHomalgRing and IsRationalsForHomalg ],
        
  function( R )
    
    if IsHomalgInternalRingRep( R ) then
        TryNextMethod( );
    fi;
    
    return Random( R, 0 );
    
end );

##
InstallMethod( Random,
        "for a homalg ring",
        [ IsHomalgRing and IsIntegersForHomalg ],
        
  function( R )
    
    if IsHomalgInternalRingRep( R ) then
        TryNextMethod( );
    fi;
    
    return Random( R, 0 );
    
end );

##
InstallMethod( Value,
        "polynomial substitution",
        [ IsHomalgRingElement, IsList, IsList ],
        
  function( p, V, O )
    local lv, lo, R, i, RP, L;
    
    lv := Length( V );
    lo := Length( O );
    
    if not ( lv > 0 and lo = lv ) then
        Error( "Second and third parameters should be nonempty lists of same size\n" );
    fi;
    
    R := HomalgRing( p );
    
    Perform( [ 1 .. lo ],
      function( i )
        if not IsHomalgRingElement( O[ i ] ) then
            O[ i ] := O[ i ] / R;
        fi;
    end );
    
    if not ( ForAll( [ 1 .. lv ], i -> IsIdenticalObj( R, HomalgRing( V[ i ] ) ) ) and ForAll( [ 1 .. lo ], i -> IsIdenticalObj( R, HomalgRing( O[ i ] ) ) ) ) then
        Error( "All the elements of the list should be in same ring\n" );
    fi;
    
    if not ForAll( V, i -> i in Indeterminates( R ) ) then
        Error( "entries in the second parameter should be ring variables\n" );
    fi;
    
    if not ForAll( O, i -> IsHomalgRingElement( i ) ) then
        Error( "entries in the third parameter should be ring elements\n" );
    fi;
    
    RP := homalgTable( R );
    
    if not IsBound(RP!.Evaluate) then
        Error( "table entry Evaluate not found\n" );
    fi;
    
    L := [ ];
    
    for i in [ 1 .. lv ] do
        L[ 2*i-1 ] := V[ i ];
        L[ 2*i ] := O[ i ];
    od;
    
    return RingElementConstructor( R )( RP!.Evaluate( p, L ), R );
    
end );

##
InstallMethod( Value,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, V, O )
    local R, RP, r, c, L, lv, MM, i, j;
    
    R := HomalgRing( M );
    RP := homalgTable( R );
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    if IsBound( RP!.EvaluateMatrix ) then
        
        L := [ ];
        
        lv := Length( V );
        
        for i in [ 1 .. lv ] do
            L[ 2*i-1 ] := V[ i ];
            L[ 2*i ] := O[ i ];
        od;
        
        return HomalgMatrix( RP!.EvaluateMatrix( M, L ), r, c, R );
        
    fi;
    
    #=====# the fallback method #=====#
    
    MM := HomalgInitialMatrix( r, c, HomalgRing( M ) );
    
    for i in [ 1 .. r ] do
        for j in [ 1 .. c ] do
            MM[ i, j ] := Value( M[ i, j ], V, O );
        od;
    od;
    
    MakeImmutable( MM );
    
    return MM;
    
end );

##
InstallMethod( Value,
        "polynomial substitution",
        [ IsObject, IsHomalgRingElement, IsRingElement ],
        
  function( p, v, o )
    
    return Value( p, [ v ], [ o ] );
    
end );

##
InstallMethod( Value,
        "polynomial substitution",
        [ IsObject, IsHomalgRingElement ],
        
  function( p, v )
    
    return o -> Value( p, v, o );
    
end );

##
InstallMethod( Numerator,
        "for homalg ring element",
        [ IsHomalgRingElement ],
        
  function( p )
    local R, RP, l;
    
    R :=  HomalgRing( p );
    
    if IsBound( p!.Numerator ) then
        return p!.Numerator;
    fi;
    
    RP := homalgTable( R );
    
    if not IsBound( RP!.NumeratorAndDenominatorOfPolynomial ) then
        Error( "table entry for NumeratorAndDenominatorOfPolynomial not found\n" );
    fi;
    
    l := RP!.NumeratorAndDenominatorOfPolynomial( p );
    
    p!.Numerator := l[1];
    p!.Denominator := l[2];
    
    return l[1];
    
end );

##
InstallMethod( Denominator,
        "for homalg ring element",
        [ IsHomalgRingElement ],
        
  function( p )
    
    if not IsBound( p!.Denominator ) then
        ## this will trigger setting p!.Denominator
        Numerator( p );
    fi;
    
    return p!.Denominator;
    
end );

##
InstallMethod( Denominator,
        "for homalg matrices",
        [ IsHomalgMatrix ],
        
  function( M )
    
    if not IsBound( M!.Denominator ) then
        ## this will trigger setting M!.Denominator
        Numerator( M );
    fi;
    
    return M!.Denominator;
    
end );

##
InstallMethod( Value,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, V, O )
    local R, r, c, MM, i, j;
    
    R := HomalgRing( M );
    
    #=====# the fallback method #=====#
    
    r := NumberRows( M );
    c := NumberColumns( M );
    
    MM := HomalgInitialMatrix( r, c, HomalgRing( M ) );
    
    for i in [ 1 .. r ] do
        for j in [ 1 .. c ] do
            MM[ i, j ] := Value( M[ i, j ], V, O );
        od;
    od;
    
    MakeImmutable( MM );
    
    return MM;
    
end );

##
InstallMethod( MonomialMatrixWeighted,
        "for homalg rings",
        [ IsInt, IsHomalgRing, IsList ],
        
  function( d, R, weights )
    local dd, set_weights, RP, vars, mon;
    
    RP := homalgTable( R );
    
    if not Length( weights ) = Length( Indeterminates( R ) ) then
        Error( "there must be as many weights as indeterminates\n" );
    fi;
    
    set_weights := Set( weights );
    
    if set_weights = [1] or set_weights = [0,1] then
        dd := d;
    elif set_weights = [-1] or set_weights = [-1,0] then
        dd := -d;
    else
        Error( "Only weights -1, 0 or 1 are accepted. The weights -1 and 1 must not appear at once." );
    fi;
    
    if dd < 0 then
        return HomalgZeroMatrix( 0, 1, R );
    fi;
    
    vars := Indeterminates( R );

    if HasIsExteriorRing( R ) and IsExteriorRing( R ) and dd > Length( vars ) then
        return HomalgZeroMatrix( 0, 1, R );
    fi;
    
    if not ( set_weights = [ 1 ] or set_weights = [ -1 ] ) then
        
        ## the variables of weight 1 or -1
        vars := vars{Filtered( [ 1 .. Length( weights ) ], p -> weights[p] <> 0 )};
        
    fi;
    
    if IsBound(RP!.MonomialMatrix) then
        mon := RP!.MonomialMatrix( dd, vars, R );        ## the external object
        mon := HomalgMatrix( mon, R );
        SetNumberColumns( mon, 1 );
        if d = 0 then
            IsOne( mon );
        fi;
        
        return mon;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called MonomialMatrix in the homalgTable of the external ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( MonomialMatrixWeighted,
        "for homalg rings",
        [ IsList, IsHomalgRing, IsList ],
        
  function( d, R, weights )
    local l, mon, w;
    
    if not Length( weights ) = Length( Indeterminates( R ) ) then
        Error( "there must be as many weights as indeterminates\n" );
    fi;
    
    l := Length( d );
    
    w := ListOfDegreesOfMultiGradedRing( l, R, weights );
    
    mon := List( [ 1 .. l ] , i -> MonomialMatrixWeighted( d[i], R, w[i] ) );
    
    return Iterated( mon, KroneckerMat );
    
end );

##
InstallMethod( ListOfDegreesOfMultiGradedRing,
        "for homalg rings",
        [ IsInt, IsHomalgRing, IsHomogeneousList ],
        
  function( l, R, weights )
    local indets, n, B, j, w, wlist, i, k;
    
    if l < 1 then
        Error( "the first argument must be a positiv integer\n" );
    fi;
    
    indets := Indeterminates( R );
    
    if not Length( weights ) = Length( indets ) then
        Error( "there must be as many weights as indeterminates\n" );
    fi;
    
    if IsList( weights[1] ) and Length( weights[1] ) = l then
        return List( [ 1 .. l ], i -> List( weights, w -> w[i] ) );
    fi;
    
    ## the rest handles the (improbable?) case of successive extensions
    ## without multiple weights
    
    if l = 1 then
        return [ weights ];
    fi;
    
    n := Length( weights );
    
    if not HasBaseRing( R ) then
        Error( "no 1. base ring found\n" );
    fi;
    
    B := BaseRing( R );
    j := Length( Indeterminates( B ) );
    
    w := Concatenation(
                 ListWithIdenticalEntries( j, 0 ),
                 ListWithIdenticalEntries( n - j, 1 )
                 );
    
    wlist := [ ListN( w, weights, \* ) ];
    
    for i in [ 2 .. l - 1 ] do
        
        if not HasBaseRing( B ) then
            Error( "no ", i, ". base ring found\n" );
        fi;
        
        B := BaseRing( B );
        k := Length( Indeterminates( B ) );
        
        w := Concatenation(
                     ListWithIdenticalEntries( k, 0 ),
                     ListWithIdenticalEntries( j - k, 1 ),
                     ListWithIdenticalEntries( n - j, 0 )
                     );
        
        Add( wlist, ListN( w, weights, \* ) );
        
        j := k;
        
    od;
    
    w := Concatenation(
                 ListWithIdenticalEntries( j, 1 ),
                 ListWithIdenticalEntries( n - j, 0 )
                 );
    
    Add( wlist, ListN( w, weights, \* ) );
    
    return wlist;
    
end );

##
InstallMethod( RandomMatrixBetweenGradedFreeLeftModulesWeighted,
        "for homalg rings",
        [ IsList, IsList, IsHomalgRing, IsList ],
        
  function( degreesS, degreesT, R, weights )
    local RP, r, c, rand, i, j, mon;
    
    RP := homalgTable( R );
    
    r := Length( degreesS );
    c := Length( degreesT );
    
    if degreesT = [ ] then
        return HomalgZeroMatrix( 0, c, R );
    elif degreesS = [ ] then
        return HomalgZeroMatrix( r, 0, R );
    fi;
    
    if IsBound(RP!.RandomMatrix) then
        rand := RP!.RandomMatrix( R, degreesT, degreesS, weights );      ## the external object
        rand := HomalgMatrix( rand, r, c, R );
        return rand;
    fi;
    
    #=====# begin of the core procedure #=====#
    
    rand := [ 1 .. r * c ];
    
    for i in [ 1 .. r ] do
        for j in [ 1 .. c ] do
            mon := MonomialMatrixWeighted( degreesS[i] - degreesT[j], R, weights );
            mon := ( R * HomalgMatrix( RandomMat( 1, NumberRows( mon ) ), HOMALG_MATRICES.ZZ ) ) * mon;
            mon := mon[ 1, 1 ];
            rand[ ( i - 1 ) * c + j ] := mon;
        od;
    od;
    
    return HomalgMatrix( rand, r, c, R );
    
end );

##
InstallMethod( RandomMatrixBetweenGradedFreeRightModulesWeighted,
        "for homalg rings",
        [ IsList, IsList, IsHomalgRing, IsList ],
        
  function( degreesT, degreesS, R, weights )
    local RP, r, c, rand, i, j, mon;
    
    RP := homalgTable( R );
    
    r := Length( degreesT );
    c := Length( degreesS );
    
    if degreesT = [ ] then
        return HomalgZeroMatrix( 0, c, R );
    elif degreesS = [ ] then
        return HomalgZeroMatrix( r, 0, R );
    fi;
    
    if IsBound(RP!.RandomMatrix) then
        rand := RP!.RandomMatrix( R, degreesT, degreesS, weights );      ## the external object
        rand := HomalgMatrix( rand, r, c, R );
        return rand;
    fi;
    
    #=====# begin of the core procedure #=====#
    
    rand := [ 1 .. r * c ];
    
    for i in [ 1 .. r ] do
        for j in [ 1 .. c ] do
            mon := MonomialMatrixWeighted( degreesS[j] - degreesT[i], R, weights );
            mon := ( R * HomalgMatrix( RandomMat( 1, NumberRows( mon ) ), HOMALG_MATRICES.ZZ ) ) * mon;
            mon := mon[ 1, 1 ];
            rand[ ( i - 1 ) * c + j ] := mon;
        od;
    od;
    
    return HomalgMatrix( rand, r, c, R );
    
end );

##
InstallMethod( RandomMatrix,
        "for three integers, a homalg ring, and a list",
        [ IsInt, IsInt, IsInt, IsHomalgRing, IsList ],
        
  function( r, c, d, R, weights )
    local degreesS, degreesT;
    
    degreesS := ListWithIdenticalEntries( r, d );
    degreesT := ListWithIdenticalEntries( c, 0 );

    return RandomMatrixBetweenGradedFreeLeftModulesWeighted( degreesS, degreesT, R, weights );
    
end );

##
InstallMethod( RandomMatrix,
        "for three integers and a homalg ring",
        [ IsInt, IsInt, IsInt, IsHomalgRing ],
        
  function( r, c, d, R )
    local weights;
    
    weights := ListWithIdenticalEntries( Length( Indeterminates( R ) ), 1 );

    return RandomMatrix( r, c, d, R, weights );
    
end );

##
## params = [ min_deg,max_deg,ze,zt,coeffs ]
##
## min_deg and max_deg determine the minimal and maximal degree of an entry in the matrix
## ze determines the percentage of the zero entries in the matrix (The default value is 50)
## zt determines the percentage of the zero terms in each entry in the matrix (The default value is 80)
## The non-trivial coefficients of each entry belong to the interval [ 1 .. coeffs ]  (The default value is 10)
##
InstallOtherMethod( RandomMatrix,
        "for two integers, a homalg ring and a list",
        [ IsInt, IsInt, IsHomalgRing, IsList ],
  function( r, c, R, params )
    local RP;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.RandomMat) then
        return HomalgMatrix( CallFuncList( RP!.RandomMat, Concatenation( [ R, r, c ], params ) ), r, c, R );
    else
        TryNextMethod();
    fi;
    
end );

##
InstallMethod( RandomMatrix,
        "for two integers and a homalg ring",
        [ IsInt, IsInt, IsHomalgRing ],
        
  function( r, c, R )
    local RP, params;
    
    # Some CAS are having a really hard time creating random empty matrices. Too many choices to make?...
    if r = 0 or c = 0 then
        
        return HomalgZeroMatrix( r, c, R );
        
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.RandomMat) then
        
        params := [ 0, Random( [ 1, 1, 1, 2, 2, 2, 3 ] ), 50, 80, 50 ];
        
        return RandomMatrix( r, c, R, params );
        
    fi;
    
    if not IsBound(RP!.RandomPol) then
        TryNextMethod( );
    fi;
    
    return HomalgMatrix( List( [ 1 .. r * c ], a -> Random( R ) ), r, c, R );
    
end );

##
InstallMethod( RandomMatrix,
        "for two integers and an internal homalg ring",
        [ IsInt, IsInt, IsHomalgInternalRingRep ],
        
  function( r, c, R )
    
    return HomalgMatrix( RandomMat( r, c, R!.ring ), r, c, R );
    
end );

##
InstallMethod( GeneralLinearCombination,
        "for a homalg ring, an integer, a list and an integer",
        [ IsHomalgRing, IsInt, IsList, IsInt ],
        
  function( R, bound, weights, n )
    local mat, m, s, B, A, r, i, indets;
    
    if n = 0 then
        return [ ];
    fi;
    
    mat := MonomialMatrixWeighted( 0, R, weights );
    
    for i in [ 1 .. bound ] do
        
        mat := UnionOfRows( mat, MonomialMatrixWeighted( i, R, weights ) );
        
    od;
    
    m := NumberRows( mat );
    
    # todo: better names for the bi: use the corresponding degree of the monomial
    s := List( [ 1 .. n ], i -> Concatenation( "b_", String( i ), "_0..", String( m - 1 ) ) );
    
    s := JoinStringsWithSeparator( s );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
        B := BaseRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
        B := CoefficientsRing( R );
    elif HasRingRelations( R ) then
        B := CoefficientsRing( AmbientRing( R ) );
        indets := Indeterminates( AmbientRing( R ) );
        
    else
        indets := [ ];
        B := R;
    fi;
    
    B := ( B * s );
    
    A := B * indets;
    
    if HasRingRelations( R ) then
        A := A / ( A * RingRelations( R ) );
    fi;
    
    if HasRelativeIndeterminatesOfPolynomialRing( B ) then
        indets := RelativeIndeterminatesOfPolynomialRing( B );
    else
        indets := IndeterminatesOfPolynomialRing( B );
    fi;
    
    indets := List( indets, a -> a / A );
    
    indets := ListToListList( indets, n, m );
    
    indets := List( indets, l -> HomalgMatrix( l, 1, m, A ) );
    
    mat := A * mat;
    
    r := List( indets, i -> i * mat[ 1, 1 ] );
    
    return List( r, rr -> rr / A );
    
end );

##
InstallMethod( GetMonic,
        "for a homalg matrix and a positive integer",
        [ IsHomalgMatrix, IsPosInt ],
        
  function( M, i )
    local R, indets, l, B, newR, m, n, p, q, f, coeffs;
    
    R := HomalgRing( M );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
        B := BaseRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
        B := CoefficientsRing( R );
    else
        Error( "the ring is not a polynomial ring\n" );
    fi;

    l := [ 1 .. Length( indets ) ];
    Remove( l, i );
    
    newR := ( B * indets{l} ) * [ indets[i] ];
    
    M := newR * M;
    
    m := NumberRows( M );
    n := NumberColumns( M );
    
    for p in [ 1 .. m ] do
        for q in [ 1 .. n ] do
            
            f := M[ p, q ];
            
            if IsMonic( f ) then
                return [ f, [ p, q ] ];
            fi;
            
        od;
    od;
    
    return fail;
    
end );

##
InstallMethod( GetMonic,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, indets, i, l;
    
    R := HomalgRing( M );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
    else
        Error( "the ring is not a polynomial ring\n" );
    fi;

    for i in Reversed( [ 1 .. Length( indets ) ] ) do
        
        l := GetMonic( M, i );
        
        if not l = fail then
            return [ l[1], l[2], i ];
        fi;
        
    od;
    
    return fail;

end );

##
InstallMethod( GetMonicUptoUnit,
        "for a homalg matrix and a positive integer",
        [ IsHomalgMatrix, IsPosInt ],
        
  function( M, i )
    local R, indets, l, B, newR, m, n, p, q, f, coeffs;
    
    R := HomalgRing( M );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
        B := BaseRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
        B := CoefficientsRing( R );
    else
        Error( "the ring is not a polynomial ring\n" );
    fi;

    l := [ 1 .. Length( indets ) ];
    Remove( l, i );
    
    newR := ( B * indets{l} ) * [ indets[i] ];
    
    M := newR * M;
    
    m := NumberRows( M );
    n := NumberColumns( M );
    
    for p in [ 1 .. m ] do
        for q in [ 1 .. n ] do
            
            f := M[ p, q ];
            
            if IsMonicUptoUnit( f ) then
                return [ f, [ p, q ] ];
            fi;
            
        od;
    od;
    
    return fail;
    
end );

##
InstallMethod( GetMonicUptoUnit,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, indets, i, l;
    
    R := HomalgRing( M );
    
    if HasRelativeIndeterminatesOfPolynomialRing( R ) then
        indets := RelativeIndeterminatesOfPolynomialRing( R );
    elif HasIndeterminatesOfPolynomialRing( R ) then
        indets := IndeterminatesOfPolynomialRing( R );
    else
        Error( "the ring is not a polynomial ring\n" );
    fi;

    for i in Reversed( [ 1 .. Length( indets ) ] ) do
        
        l := GetMonicUptoUnit( M, i );
        
        if not l = fail then
            return [ l[1], l[2], i ];
        fi;
        
    od;
    
    return fail;

end );

##
InstallMethod( Diff,
        "for homalg matrices",
        [ IsHomalgMatrix, IsHomalgMatrix ],
        
  function( D, N )
    local R, RP, diff;
    
    R := HomalgRing( D );
    
    if not IsIdenticalObj( R, HomalgRing( N ) ) then
        Error( "the two matrices must be defined over identically the same ring\n" );
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.Diff) then
        diff := RP!.Diff( D, N );
        if not IsHomalgMatrix( diff ) then
            diff := HomalgMatrix( diff, NumberRows( D ) * NumberRows( N ), NumberColumns( D ) * NumberColumns( N ), R );
        fi;
        return diff;
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called Diff ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( Diff,
        "for two homalg ring elements",
        [ IsHomalgRingElement, IsHomalgRingElement ],
        
  function( x, r )
    local R;
    
    R := HomalgRing( r );
    
    x := HomalgMatrix( [ x ], 1, 1, R );
    r := HomalgMatrix( [ r ], 1, 1, R );
    
    return MatElm( Diff( x, r ), 1, 1 );
    
end );

##
InstallMethod( Diff,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, var, x;
    
    R := HomalgRing( r );
    var := IndeterminatesOfPolynomialRing( R );
    x := var[Length( var )];
    
    return Diff( x, r );
    
end );

##
InstallMethod( TangentSpaceByEquationsAtPoint,
        "for two homalg matrices",
        [ IsHomalgMatrix, IsHomalgMatrix ],
        
  function( M, x )
    local R, var, n, k, Tx, map, i, xi, Ri, m;
    
    if not NumberColumns( M ) = 1 then
        Error( "the number of columns of the first argument M is not 1\n" );
    elif not NumberColumns( M ) = 1 then
        Error( "the number of columns of the second argument x is not 1\n" );
    fi;
    
    R := HomalgRing( M );
    
    var := IndeterminatesOfPolynomialRing( R );
    
    n := Length( var );
    
    if not n = NumberRows( x ) then
        Error( "the number of rows of the second argument x is not the number of indeterminates ", n, "\n" );
    fi;
    
    k := CoefficientsRing( R );
    
    if not IsIdenticalObj( HomalgRing( x ), k ) then
        Error( "the second argument is not a matrix over the coefficients ring ", k );
    fi;
    
    Tx := HomalgZeroMatrix( NumberRows( M ), 0, k );
    
    for i in [ 1 .. n ] do
        
        xi := String( var[i] );
        
        Ri := k * xi;
        
        xi := HomalgMatrix( [ xi / Ri ], 1, 1, Ri );
        
        map := UnionOfRows( Ri * CertainRows( x, [ 1 .. i - 1 ] ), xi, Ri * CertainRows( x, [ i + 1 .. n ] ) );
        
        map := RingMap( map, R, Ri );
        
        m := Diff( xi, Pullback( map, M ) );
        
        map := CertainRows( x, [ i ] );
        
        map := RingMap( map, Ri, k );
        
        Tx := UnionOfColumns( Tx, Pullback( map, m ) );
        
    od;
    
    return BasisOfRows( Tx );
    
end );

##
InstallMethod( TangentSpaceByEquationsAtPoint,
        "for a homalg matrix and a list",
        [ IsHomalgMatrix, IsList ],
        
  function( M, x )
    local R, k;
    
    R := HomalgRing( M );
    
    k := CoefficientsRing( R );
    
    x := HomalgMatrix( x, Length( x ), 1, k );
    
    return TangentSpaceByEquationsAtPoint( M, x );
    
end );

##
InstallMethod( NoetherNormalization,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, r, char, indets, l, k, K, m, pos_char, rand_mat, rand_inv;
    
    R := HomalgRing( M );
    r := CoefficientsRing( R );
    
    char := Characteristic( r );
    
    if char > 0 and not IsPrimeInt( char ) then
        TryNextMethod( );
    elif not HasIndeterminatesOfPolynomialRing( R ) then
        TryNextMethod( );
    fi;
    
    indets := Indeterminates( R );
    
    l := Length( indets );
    
    indets := HomalgMatrix( indets, 1, l, R );
    
    if char > 0 then
        if HasRationalParameters( r ) then
            k := HomalgRingOfIntegers( char );
        else
            k := HomalgRingOfIntegers( char, DegreeOverPrimeField( r ) );
        fi;
        K := k!.ring;
    else
        k := HOMALG_MATRICES.ZZ;
    fi;
    
    m := GetMonicUptoUnit( M );
    
    if not m = fail then
        return [ M, m, true, true ];
    fi;
    
    pos_char := char > 0;
    
    repeat
        
        if pos_char then
            rand_mat := Random( SL( l, K ) );
        else
            if l = 1 then
                rand_mat := [ [ 1 ] ];
            else
                rand_mat := RandomUnimodularMat( l );
            fi;
        fi;
        
        rand_inv := rand_mat^-1;
        
        rand_mat := HomalgMatrix( rand_mat, k );
        rand_inv := HomalgMatrix( rand_inv, k );
        
        rand_mat := R * rand_mat;
        rand_inv := R * rand_inv;
        
        SetLeftInverse( rand_mat, rand_inv );
        SetRightInverse( rand_mat, rand_inv );
        SetLeftInverse( rand_inv, rand_mat );
        SetRightInverse( rand_inv, rand_mat );
        
        rand_mat := indets * rand_mat;
        rand_inv := indets * rand_inv;
        
        rand_mat := RingMap( rand_mat, R, R );
        
        M := Pullback( rand_mat, M );
        
        m := GetMonicUptoUnit( M );
        
    until not m = fail;
    
    rand_inv := RingMap( rand_inv, R, R );
    
    SetIsIsomorphism( rand_mat, true );
    SetIsIsomorphism( rand_inv, true );
    
    return [ M, m, rand_mat, rand_inv ];
    
end );

##
InstallMethod( Inequalities,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    local r, RP, J;
    
    r := R;
    
    RP := homalgTable( R );
    
    if not IsBound(RP!.Inequalities) then
        Error( "could not find a procedure called Inequalities in the homalgTable\n" );
    fi;
    
    J := RP!.Inequalities( R );
    
    J := DuplicateFreeList( J );
    
    if HasIsFieldForHomalg( R ) and IsFieldForHomalg( R ) then
        r := R;
    else
        r := CoefficientsRing( R );
    fi;
    
    r := AssociatedPolynomialRing( r );
    
    J := List( J, a -> a / r );
    
    if IsBound( R!.Inequalities ) then
        Append( J, R!.Inequalities );
    fi;
    
    J := DuplicateFreeList( J );
    
    R!.Inequalities := J;
    
    return J;
    
end );

##
InstallMethod( ClearDenominatorsRowWise,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, m, n, coeffs;
    
    if IsZero( M ) then
        return M;
    elif IsOne( M ) then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    m := NumberRows( M );
    n := NumberColumns( M );
    
    if IsBound(RP!.ClearDenominatorsRowWise) then
        return HomalgMatrix( RP!.ClearDenominatorsRowWise( M ), m, n, R ); ## the external object
    fi;
    
    #=====# begin of the core procedure #=====#
    
    coeffs := EntriesOfHomalgMatrixAsListList( M );
    
    coeffs := List( coeffs, a -> Concatenation( List( a, b -> EntriesOfHomalgMatrix( Coefficients( b ) ) ) ) );
    
    coeffs := List( coeffs, a -> List( a, b -> DenominatorRat( Rat( String( b ) ) ) ) );
    
    coeffs := List( coeffs, Lcm );
    
    coeffs := HomalgDiagonalMatrix( List( coeffs, a -> a / R ) );
    
    return coeffs * M;
    
end );


##
InstallMethod( MaximalDegreePart,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, RP, var, B, base, weights, d, coeffs, monoms, plist;
    
    if IsZero( r ) then
        return r;
    fi;
    
    R := HomalgRing( r );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.MaximalDegreePart) then
        if HasRelativeIndeterminatesOfPolynomialRing( R ) then
            var := RelativeIndeterminatesOfPolynomialRing( R );
            B := BaseRing( R );
            if HasIndeterminatesOfPolynomialRing( B ) then
                base := IndeterminatesOfPolynomialRing( B );
            else
                base := [ ];
            fi;
            weights := Concatenation( ListWithIdenticalEntries( Length( base ), 0 ), ListWithIdenticalEntries( Length( var ), 1 ) );
        else
            var := RelativeIndeterminatesOfPolynomialRing( R );
            weights := ListWithIdenticalEntries( Length( var ), 1 );
        fi;
        
        return RingElementConstructor( R )( RP!.MaximalDegreePart( r, weights ), R );
        
    fi;
    
    d := Degree( r );
    
    coeffs := Coefficients( r );
    
    monoms := coeffs!.monomials;
    
    coeffs := EntriesOfHomalgMatrix( coeffs );
    
    plist := Positions( List( monoms, Degree ), d );
    
    return coeffs{plist} * monoms{plist};
    
end );

##
InstallMethod( MaximalDegreePartOfColumnMatrix,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R;
    
    if not NumberColumns( M ) = 1 then
        Error( "the number of columns is not 1\n" );
    fi;
    
    if IsZero( M ) then
        return M;
    fi;
    
    R := HomalgRing( M );
    
    M := List( EntriesOfHomalgMatrix( M ), MaximalDegreePart );
    
    return HomalgMatrix( M, Length( M ), 1, R );
    
end );

##
InstallMethod( LeadingModule,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( mat )
    local R, RP, lead;
    
    ## we are in the left module convention, i.e., row convention;
    ## so ideals are passed as a one column matrix
    
    R := HomalgRing( mat );
    
    RP := homalgTable( R );
    
    if IsBound(RP!.LeadingModule) then
        lead := RP!.LeadingModule( mat );
    elif IsBound(RP!.LeadingIdeal) then
        if not NumberColumns( mat ) = 1 then
            Error( "the matrix of generators of the ideal should be a one column matrix\n" );
        fi;
        lead := RP!.LeadingIdeal( mat );
    else
        Error( "could not find a procedure called LeadingModule (or LeadingIdeal) ",
               "in the homalgTable of the ring\n" );
    fi;
    
    return HomalgMatrix( lead, NumberRows( mat ), NumberColumns( mat ), R );
    
end );

##
InstallGlobalFunction( VariableForHilbertPoincareSeries,
  function( arg )
    local s;
    
    if not IsBound( HOMALG_MATRICES.variable_for_Hilbert_Poincare_series ) then
        
        if Length( arg ) > 0 and IsString( arg[1] ) then
            s := arg[1];
        else
            s := "s";
        fi;
        
        s := Indeterminate( Rationals, s );
        
        HOMALG_MATRICES.variable_for_Hilbert_Poincare_series := s;
    fi;
    
    return HOMALG_MATRICES.variable_for_Hilbert_Poincare_series;
    
end );

##
InstallGlobalFunction( VariableForHilbertPolynomial,
  function( arg )
    local t;
    
    if not IsBound( HOMALG_MATRICES.variable_for_Hilbert_polynomial ) then
        
        if Length( arg ) > 0 and IsString( arg[1] ) then
            t := arg[1];
        else
            t := "t";
        fi;
        
        t := Indeterminate( Rationals, t );
        
        HOMALG_MATRICES.variable_for_Hilbert_polynomial := t;
    fi;
    
    return HOMALG_MATRICES.variable_for_Hilbert_polynomial;
    
end );

##
InstallGlobalFunction( CoefficientsOfLaurentPolynomialsWithRange,
  function( poly )
    local coeffs, ldeg;
    
    coeffs := CoefficientsOfLaurentPolynomial( poly );
    
    ldeg := coeffs[2];
    
    coeffs := coeffs[1];
    
    return [ coeffs, [ ldeg .. ldeg + Length( coeffs ) - 1 ] ];
    
end );

##
InstallGlobalFunction( SumCoefficientsOfLaurentPolynomials,
  function( arg )
    local s, sum;
    
    s := VariableForHilbertPolynomial( );
    
    sum := Sum( arg, a -> Sum( [ 1 .. Length( a[2] ) ], i -> a[1][i] * s^a[2][i] ) ) + 0 * s;
    
    return CoefficientsOfLaurentPolynomialsWithRange( sum );
    
end );

##
InstallMethod( CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    local c, save, R, RP, t, zero_cols, free, hilb_free, non_zero_cols, hilb, l, ldeg;
    
    c := String( [ weights, degrees ] );
    
    if IsBound( M!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        save := M!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries;
        if IsBound( save.(c) ) then
            return save.(c);
        fi;
    else
        save := rec( );
        M!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries := save;
    fi;
    
    if NumberColumns( M ) <> Length( degrees ) then
        Error( "the number of columns must coincide with the number of degrees\n" );
    fi;
    
    R := HomalgRing( M );
    
    if Length( Indeterminates( R ) ) <> Length( weights ) then
        Error( "the number of indeterminates must coincide with the number of weights\n" );
    fi;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        save.(c) := [ [ ], [ ] ];
        return save.(c);
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the coefficients of the unreduced untwisted numerator
        ## differ from the twisted ones below by a shift by t
        hilb := CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries( M );
        
        if hilb = [ ] then
            ## the degenerate case
            hilb := [ [ ], [ ] ];
        else
            hilb := [ hilb, [ t .. Length( hilb ) - 1 + t ] ];
        fi;
        
        save.(c) := hilb;
        
        return save.(c);
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        zero_cols := ZeroColumns( M );
        
        if zero_cols <> [ ] and
           not ( IsZero( M ) and NumberRows( M ) = 1 and NumberColumns( M ) = 1 ) then ## avoid infinite loops
            ## take care of matrices with zero columns, especially of 0 x n matrices
            
            free := HomalgZeroMatrix( 1, 1, R );
            
            hilb_free := CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries( free, weights, [ 0 * degrees[zero_cols[1]] ] );
            
            l := Length( hilb_free[1] );
            
            hilb_free := List( degrees{zero_cols}, d -> [ hilb_free[1], [ d .. d + l - 1 ] ] );
            
            hilb_free := CallFuncList( SumCoefficientsOfLaurentPolynomials, hilb_free );
            
            if IsZero( M ) then
                save.(c) := hilb_free;
                return save.(c);
            fi;
            
            non_zero_cols := NonZeroColumns( M );
            
            M := CertainColumns( M, non_zero_cols );
            
            degrees := degrees{non_zero_cols};
            
        else
            
            hilb_free := [ [ ], [ ] ];
            
        fi;
        
        hilb := RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries( M, weights, degrees );
        
        l := Length( hilb ) - 1;
        
        if l = 0 or l = -1 then
            ## the degenerate case
            hilb := [ [ ], [ ] ];
            
        else
            
            ldeg := hilb[l + 1];
            
            hilb := hilb{[ 1 .. l ]};
            
            t := PositionNonZero( hilb );
            
            hilb := hilb{[ t .. l ]};
            
            ldeg := ldeg + t - 1;
            
            hilb := [ hilb, [ ldeg .. l - t + ldeg ] ];
            
        fi;
        
        hilb := SumCoefficientsOfLaurentPolynomials( hilb, hilb_free );
        
        save.(c) := hilb;
        
        return save.(c);
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, free, r, hilb_free, hilb;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return [ ];
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) then
        
        free := ZeroColumns( M );
        
        if free <> [ ] and
           not ( IsZero( M ) and NumberRows( M ) = 1 and NumberColumns( M ) = 1 ) then ## avoid infinite loops
            ## take care of matrices with zero columns, especially of 0 x n matrices
            
            r := Length( free );
            
            if not IsBound( R!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries_of_free_rank_1 ) then
                free := HomalgZeroMatrix( 1, 1, R );
                R!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries_of_free_rank_1 :=
                  CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries( free );
            fi;
            
            hilb_free := r * R!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries_of_free_rank_1;
            
            if IsZero( M ) then
                return hilb_free;
            fi;
            
            M := CertainColumns( M, NonZeroColumns( M ) );
            
        else
            
            if not ( IsZero( M ) and NumberRows( M ) = 1 and NumberColumns( M ) = 1 ) then
                M := BasisOfRowModule( M );
            fi;
            
            hilb_free := 0;
            
        fi;
        
        return hilb_free + RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries( M );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( CoefficientsOfNumeratorOfHilbertPoincareSeries,
        "for a rational function",
        [ IsRationalFunction ],
        
  function( series )
    local denom, ldeg, lowest_coeff, s, numer;
    
    if IsZero( series ) then
        return [ [ ], [ ] ];
    fi;
    
    denom := DenominatorOfRationalFunction( series );
    
    denom := CoefficientsOfUnivariatePolynomial( denom );
    
    ldeg := PositionNonZero( denom ) - 1;
    
    lowest_coeff := denom[ldeg + 1];
    
    if not lowest_coeff in [ 1, -1 ] then
        Error( "expected the lowest coefficient of the denominator of the Hilbert-Poincare series to be 1 or -1 but received ", lowest_coeff, "\n" );
    fi;
    
    s := IndeterminateOfUnivariateRationalFunction( series );
    
    numer := NumeratorOfRationalFunction( series ) / ( lowest_coeff * s^ldeg );
    
    return CoefficientsOfLaurentPolynomialsWithRange( numer );
    
end );

##
InstallMethod( CoefficientsOfNumeratorOfHilbertPoincareSeries,
        "for a rational function and the integer 0",
        [ IsRationalFunction, IsInt and IsZero ],
        
  function( series, i ) ## i = 0
    local coeffs;
    
    coeffs := CoefficientsOfNumeratorOfHilbertPoincareSeries( series );
    
    if coeffs[2] = [ ] then
        coeffs := coeffs[1];
    elif coeffs[2][1] = 0 then
        coeffs := coeffs[1];
    elif coeffs[2][1] > 0 then
        coeffs := Concatenation( ListWithIdenticalEntries( coeffs[2][1], 0 * coeffs[1][1] ), coeffs[1] );
    else
        Error( "expected CoefficientsOfNumeratorOfCoeffsertPoincareSeries to indicate a polynomial and not of a Laurent polynomial: ", coeffs );
    fi;
    
    return coeffs;
    
end );

##
InstallMethod( CoefficientsOfNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
  ## the fallback method
  ReturnFail );

##
InstallMethod( CoefficientsOfNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    local c, save, R, RP, t, free, s, hilb, d;
    
    c := String( [ weights, degrees ] );
    
    if IsBound( M!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        save := M!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries;
        if IsBound( save.(c) ) then
            return save.(c);
        fi;
    else
        save := rec( );
        M!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries := save;
    fi;
    
    if NumberColumns( M ) <> Length( degrees ) then
        Error( "the number of columns must coincide with the number of degrees\n" );
    fi;
    
    R := HomalgRing( M );
    
    if Length( Indeterminates( R ) ) <> Length( weights ) then
        Error( "the number of indeterminates must coincide with the number of weights\n" );
    fi;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        save.(c) := [ [ ], [ ] ];
        return save.(c);
    fi;
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the coefficients of the untwisted numerator
        ## differ from the twisted ones below by a shift by t
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        if hilb = [ ] then
            ## the degenerate case
            hilb := [ [ ], [ ] ];
        else
            hilb := [ hilb, [ t .. Length( hilb ) - 1 + t ] ];
        fi;
        
        save.(c) := hilb;
        
        return save.(c);
        
    elif IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        
        if IsZero( M ) then
            ## take care of zero matrices, especially of 0 x n matrices
            free := HomalgZeroMatrix( 1, NumberColumns( M ), R );
            hilb := RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries( free, weights, degrees );
        else
            hilb := RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries( M, weights, degrees );
        fi;
        
        save.(c) := hilb;
        
        return hilb;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        s := VariableForHilbertPoincareSeries( );
        
        hilb := HilbertPoincareSeries( M, weights, degrees, s );
        
        save.(c) := CoefficientsOfNumeratorOfHilbertPoincareSeries( hilb );
        
        return save.(c);
        
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( CoefficientsOfNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, free, hilb, lowest_coeff;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return [ ];
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) then
        
        if IsZero( M ) then
            ## take care of zero matrices, especially of 0 x n matrices
            free := HomalgZeroMatrix( 1, 1, R );
            hilb := RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries( free );
            return NumberColumns( M ) * hilb;
        else
            return RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        fi;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) then
        
        hilb := HilbertPoincareSeries( M );
        
        return CoefficientsOfNumeratorOfHilbertPoincareSeries( hilb, 0 );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
end );

##
InstallMethod( UnreducedNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix, two lists, and a ring element",
        [ IsHomalgMatrix, IsList, IsList, IsRingElement ],
        
  function( M, weights, degrees, lambda )
    local R, RP, t, hilb, range;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0 * lambda;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the unreduced numerator of the untwisted Hilbert-Poincaré series
        ## differs from the twisted one by the factor lambda^t
        hilb := UnreducedNumeratorOfHilbertPoincareSeries( M );
        
        return lambda^t * hilb;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries( M, weights, degrees );
        
        range := hilb[2];
        hilb := hilb[1];
        
        hilb := Sum( [ 1 .. Length( range ) ], i -> hilb[i] * lambda^range[i] );
        
        return hilb + 0 * lambda;
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( UnreducedNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    
    return UnreducedNumeratorOfHilbertPoincareSeries( M, weights, degrees, VariableForHilbertPoincareSeries( ) );
    
end );

##
InstallMethod( UnreducedNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and a ring element",
        [ IsHomalgMatrix, IsRingElement ],
        
  function( M, lambda )
    local R, RP, hilb;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0 * lambda;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries( M );
        
        hilb := Sum( [ 0 .. Length( hilb ) - 1 ], k -> hilb[k+1] * lambda^k );
        
        return hilb + 0 * lambda;
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( UnreducedNumeratorOfHilbertPoincareSeries,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    
    return UnreducedNumeratorOfHilbertPoincareSeries( M, VariableForHilbertPoincareSeries( ) );
    
end );

##
InstallMethod( NumeratorOfHilbertPoincareSeries,
        "for a homalg matrix, two lists, and a ring element",
        [ IsHomalgMatrix, IsList, IsList, IsRingElement ],
        
  function( M, weights, degrees, lambda )
    local R, RP, t, hilb, range;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0 * lambda;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the numerator of the untwisted Hilbert-Poincaré series
        ## differs from the twisted one by the factor lambda^t
        hilb := NumeratorOfHilbertPoincareSeries( M );
        
        return lambda^t * hilb;
        
    elif IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M, weights, degrees );
        
        if hilb = [ [ ], [ ] ] then
            return 0 * lambda;
        fi;
        
        range := hilb[2];
        hilb := hilb[1];
        
        hilb := Sum( [ 1 .. Length( range ) ], i -> hilb[i] * lambda^range[i] );
        
        return hilb + 0 * lambda;
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( NumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    
    return NumeratorOfHilbertPoincareSeries( M, weights, degrees, VariableForHilbertPoincareSeries( ) );
    
end );

##
InstallMethod( NumeratorOfHilbertPoincareSeries,
        "for a homalg matrix and a ring element",
        [ IsHomalgMatrix, IsRingElement ],
        
  function( M, lambda )
    local R, RP, hilb, lowest_coeff;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0 * lambda;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        hilb := Sum( [ 0 .. Length( hilb ) - 1 ], k -> hilb[k+1] * lambda^k );
        
        return hilb + 0 * lambda;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) then
        
        hilb := HilbertPoincareSeries( M );
        
        lowest_coeff := function( f );
            return First( CoefficientsOfUnivariatePolynomial( f ), a -> not IsZero( a ) );
        end;
        
        lowest_coeff := lowest_coeff( DenominatorOfRationalFunction( hilb ) );
        
        if not lowest_coeff in [ 1, -1 ] then
            Error( "expected the lowest coefficient of the denominator of the Hilbert-Poincare series to be 1 or -1 but received ", lowest_coeff, "\n" );
        fi;
        
        return NumeratorOfRationalFunction( hilb ) / lowest_coeff;
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( NumeratorOfHilbertPoincareSeries,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    
    return NumeratorOfHilbertPoincareSeries( M, VariableForHilbertPoincareSeries( ) );
    
end );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix, two lists, and a ring element",
        [ IsHomalgMatrix, IsList, IsList, IsRingElement ],
  ## the fallback method
  ReturnFail );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix, two lists, and a ring element",
        [ IsHomalgMatrix, IsList, IsList, IsRingElement ],
        
  function( M, weights, degrees, lambda )
    local R, RP, t, hilb, denom, n, d;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the untwisted Hilbert-Poincaré series
        ## differs from the twisted one by the factor lambda^t
        hilb := HilbertPoincareSeries( M, lambda );
        
        return lambda^t * hilb;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := UnreducedNumeratorOfHilbertPoincareSeries( M, weights, degrees, lambda );
        
        denom := Product( weights, i -> ( 1 - lambda^i ) );
        
        return hilb / denom;
        
    elif IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := NumeratorOfHilbertPoincareSeries( M, weights, degrees, lambda );
        
        ## for CASs which do not support Hilbert* for non-graded modules
        d := AffineDimension( M, weights, degrees );
        
        return hilb / ( 1 - lambda )^d;
        
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix, two lists, and a string",
        [ IsHomalgMatrix, IsList, IsList, IsString ],
        
  function( M, weights, degrees, lambda )
    
    return HilbertPoincareSeries( M, weights, degrees, Indeterminate( Rationals, lambda ) );
    
end );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    
    return HilbertPoincareSeries( M, weights, degrees, VariableForHilbertPoincareSeries( ) );
    
end );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix and a ring element",
        [ IsHomalgMatrix, IsRingElement ],
        
  function( M, lambda )
    local R, RP, hilb, n, d, weights, degrees;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if HasIsDivisionRingForHomalg( R ) and IsDivisionRingForHomalg( R ) then
        
        return ( NumberColumns( M ) - RowRankOfMatrix( M ) ) * lambda^0;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) then
        
        hilb := UnreducedNumeratorOfHilbertPoincareSeries( M, lambda );
        
        n := Length( Indeterminates( R ) );
        
        return  hilb / ( 1 - lambda )^n;
        
    elif IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) then
        
        hilb := NumeratorOfHilbertPoincareSeries( M, lambda );
        
        d := AffineDimension( M );
        
        return hilb / ( 1 - lambda )^d;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        weights := ListWithIdenticalEntries( Length( Indeterminates( R ) ), 1 );
        
        degrees := ListWithIdenticalEntries( NumberColumns( M ), 0 );
        
        return HilbertPoincareSeries( LeadingModule( M ), weights, degrees, lambda );
        
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix and a string",
        [ IsHomalgMatrix, IsString ],
        
  function( M, lambda )
    
    return HilbertPoincareSeries( M, Indeterminate( Rationals, lambda ) );
    
end );

##
InstallMethod( HilbertPoincareSeries,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    
    return HilbertPoincareSeries( M, VariableForHilbertPoincareSeries( ) );
    
end );

##
InstallGlobalFunction( _Binomial,
  function( a, b )
    local factorial;
    
    if b = 0 then
        ## ensure that the result has the type of a
        return 1 + 0 * a;
    elif b = 1 then
        return a;
    fi;
    
    factorial := Product( [ 0 .. b - 1 ], i -> a - i ) / Factorial( b );
    
    return factorial;
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a list, an integer, and a ring element",
        [ IsList, IsInt, IsRingElement ],
        
  function( coeffs, d, s )
    local range, hilb;
    
    if d <= 0 then
        return 0 * s;
    fi;
    
    if ForAll( coeffs, IsList ) and Length( coeffs ) = 2 then
        ## the case: coeffs = CoefficientsOfNumeratorOfHilbertPoincareSeries( M, weights, degrees );
        
        range := coeffs[2];
        coeffs := coeffs[1];
        
        hilb := Sum( [ 1 .. Length( range ) ], i -> coeffs[i] * _Binomial( d - 1 + s - range[i], d - 1 ) );
        
    else
        ## the case: coeffs = CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        hilb := Sum( [ 0 .. Length( coeffs ) - 1 ], k -> coeffs[k+1] * _Binomial( d - 1 + s - k, d - 1 ) );
        
    fi;
    
    return hilb + 0 * s;
    
end );

##
InstallMethod( DimensionOfHilbertPoincareSeries,
        "for a rational function",
        [ IsRationalFunction ],
        
  function( series )
    local denom, hdeg, ldeg;
    
    if IsZero( series ) then
        return HOMALG_MATRICES.DimensionOfZeroModules;
    fi;
    
    denom := DenominatorOfRationalFunction( series );
    
    hdeg := Degree( denom );
    
    denom := CoefficientsOfUnivariatePolynomial( denom );
    
    ldeg := PositionNonZero( denom ) - 1;
    
    return hdeg - ldeg;
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a list and an integer",
        [ IsList, IsInt ],
        
  function( coeffs, d )
    local s;
    
    s := VariableForHilbertPolynomial( );
    
    return HilbertPolynomial( coeffs, d, s );
    
end );

##
InstallMethod( HilbertPolynomialOfHilbertPoincareSeries,
        "for a rational function",
        [ IsRationalFunction ],
        
  function( series )
    local coeffs, d;
    
    coeffs := CoefficientsOfNumeratorOfHilbertPoincareSeries( series );
    
    d := DimensionOfHilbertPoincareSeries( series );
    
    return HilbertPolynomial( coeffs, d );
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix, two lists, and a ring element",
        [ IsHomalgMatrix, IsList, IsList, IsRingElement ],
  ## the fallback method
  ReturnFail );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix, two lists, and a ring element",
        [ IsHomalgMatrix, IsList, IsList, IsRingElement ],
        
  function( M, weights, degrees, lambda )
    local R, RP, t, hilb;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0 * lambda;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the untwisted Hilbert polynomial
        ## differs from the twisted one by a shift by t
        hilb := HilbertPolynomial( M, lambda );
        
        return Value( hilb, lambda - t );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := HilbertPoincareSeries( M, weights, degrees, lambda );
        
        return HilbertPolynomialOfHilbertPoincareSeries( hilb );
        
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix, two lists, and a string",
        [ IsHomalgMatrix, IsList, IsList, IsString ],
        
  function( M, weights, degrees, lambda )
    
    return HilbertPolynomial( M, weights, degrees, Indeterminate( Rationals, lambda ) );
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    
    return HilbertPolynomial( M, weights, degrees, VariableForHilbertPolynomial( ) );
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix and a ring element",
        [ IsHomalgMatrix, IsRingElement ],
        
  function( M, lambda )
    local R, RP, free, hilb, weights, degrees;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0 * lambda;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if HasIsDivisionRingForHomalg( R ) and IsDivisionRingForHomalg( R ) then
        
        return ( NumberColumns( M ) - RowRankOfMatrix( M ) ) * lambda^0;
        
    elif IsBound( RP!.CoefficientsOfHilbertPolynomial ) then
        
        if IsZero( M ) then
            ## take care of zero matrices, especially of 0 x n matrices
            free := HomalgZeroMatrix( 1, 1, R );
            hilb := RP!.CoefficientsOfHilbertPolynomial( free );
            hilb := NumberColumns( M ) * hilb;
        else
            hilb := RP!.CoefficientsOfHilbertPolynomial( M );
        fi;
        
        hilb := Sum( [ 0 .. Length( hilb ) - 1 ], k -> hilb[k+1] * lambda^k );
        
        return hilb + 0 * lambda;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) then
        
        hilb := HilbertPoincareSeries( M, lambda );
        
        return HilbertPolynomialOfHilbertPoincareSeries( hilb );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        weights := ListWithIdenticalEntries( Length( Indeterminates( R ) ), 1 );
        
        degrees := ListWithIdenticalEntries( NumberColumns( M ), 0 );
        
        return HilbertPolynomial( LeadingModule( M ), weights, degrees, lambda );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfHilbertPolynomial ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix and a string",
        [ IsHomalgMatrix, IsString ],
        
  function( M, lambda )
    
    return HilbertPolynomial( M, Indeterminate( Rationals, lambda ) );
    
end );

##
InstallMethod( HilbertPolynomial,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    
    return HilbertPolynomial( M, VariableForHilbertPolynomial( ) );
    
end );

## for CASs which do not support Hilbert* for non-graded modules
InstallMethod( AffineDimension,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    local R, RP, free, hilb, d;
    
    if HasAffineDimension( M ) then
        return AffineDimension( M );
    fi;
    
    R := HomalgRing( M );
    
    if NumberColumns( M ) = 0 then
        ## take care of n x 0 matrices
        return HOMALG_MATRICES.DimensionOfZeroModules;
    elif ZeroColumns( M ) <> [ ] then
        ## take care of matrices with zero columns, especially of 0 x n matrices
        if HasKrullDimension( R ) then
            return KrullDimension( R ); ## this is not a mistake
        elif not ( IsZero( M ) and NumberRows( M ) = 1 and NumberColumns( M ) = 1 ) then ## avoid infinite loops
            free := HomalgZeroMatrix( 1, 1, R );
            return AffineDimension( free, weights, degrees );
        fi;
    elif HasIsIntegersForHomalg( R ) and IsIntegersForHomalg( R ) then
        
        M := BasisOfRowModule( M );
        
        if IsZero( DecideZero( HomalgIdentityMatrix( NumberColumns( M ), R ), M ) ) then
            return HOMALG_MATRICES.DimensionOfZeroModules;
        elif NumberColumns( M ) - NumberRows( M ) = 0 then
            return 0;
        fi;
        
        return 1;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.AffineDimension ) then
        
        return AffineDimension( M );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        ## the Hilbert polynomial, as a projective invariant,
        ## cannot distinguish between empty and zero dimensional *affine* sets;
        ## they are both empty as projective sets
        hilb := HilbertPoincareSeries( M, weights, degrees );
        
        d := DimensionOfHilbertPoincareSeries( hilb );
        
        SetAffineDimension( M, d );
        
        return d;
        
    fi;
    
    ## before giving up
    return AffineDimension( M );
    
end );

##
InstallMethod( AffineDimension,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, free, hilb, d;
    
    R := HomalgRing( M );
    
    if NumberColumns( M ) = 0 then
        ## take care of n x 0 matrices
        return HOMALG_MATRICES.DimensionOfZeroModules;
    elif ZeroColumns( M ) <> [ ] then
        ## take care of matrices with zero columns, especially of 0 x n matrices
        if HasKrullDimension( R ) then
            return KrullDimension( R ); ## this is not a mistake
        elif not ( IsZero( M ) and NumberRows( M ) = 1 and NumberColumns( M ) = 1 ) then ## avoid infinite loops
            free := HomalgZeroMatrix( 1, 1, R );
            return AffineDimension( free );
        fi;
    elif ( HasIsFieldForHomalg( R ) and IsFieldForHomalg( R ) ) or
      ( HasIsIntegersForHomalg( R ) and IsIntegersForHomalg( R ) ) then
        
        M := BasisOfRowModule( M );
        
        if IsZero( DecideZero( HomalgIdentityMatrix( NumberColumns( M ), R ), M ) ) then
            return HOMALG_MATRICES.DimensionOfZeroModules;
        elif NumberColumns( M ) - NumberRows( M ) = 0 then
            return 0;
        fi;
        
        return 1;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.AffineDimension ) then
        
        if not IsZero( M ) then
            M := BasisOfRowModule( M );
        fi;
        
        d := RP!.AffineDimension( M );
        
        if d < 0 then
            d := HOMALG_MATRICES.DimensionOfZeroModules;
        fi;
        
        return d;
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) then
        
        ## the Hilbert polynomial, as a projective invariant,
        ## cannot distinguish between empty and zero dimensional *affine* sets;
        ## they are both empty as projective sets
        hilb := HilbertPoincareSeries( M );
        
        if IsZero( hilb ) then
            d := HOMALG_MATRICES.DimensionOfZeroModules;
        else
            d := Degree( DenominatorOfRationalFunction( hilb ) );
        fi;
        
        return d;
        
    elif IsBound( RP!.AffineDimensionOfIdeal ) and NumberColumns( M ) = 1 then
        
        d := RP!.AffineDimensionOfIdeal( M );
        
        if d < 0 then
            d := HOMALG_MATRICES.DimensionOfZeroModules;
        fi;
        
        return d;
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called AffineDimension ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( AffineDegree,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    local R, k, char, RP, hilb;
    
    R := HomalgRing( M );
    
    if HasCoefficientsRing( R ) then
        k := CoefficientsRing( R );
        
        if HasIsIntegersForHomalg( k ) and IsIntegersForHomalg( k ) then
            char := Eliminate( BasisOfRows( M ) );
            if not IsIdenticalObj( k, HomalgRing( char ) ) then
                char := Eliminate( char );
            fi;
            if not IsZero( char ) then
                char := EntriesOfHomalgMatrix( char );
                char := List( char, a -> EvalString( String( a ) ) );
                char := Gcd( char );
                if not IsPrime( char ) then
                    Error( "AffineDegree over a mixed characteristic, here ", char, ", is not supported yet\n" );
                fi;
                k := HomalgRingOfIntegersInUnderlyingCAS( char, k );
                R := k * List( Indeterminates( R ), String );
                M := R * M;
                M := BasisOfRows( M );
            fi;
        fi;
    fi;
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        ## the coefficients of the untwisted numerator
        ## differ from the twisted ones below by a shift
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        return Sum( hilb );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M, weights, degrees );
        
        return Sum( hilb[1] );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( AffineDegree,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, k, char, RP, hilb, weights, degrees;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0;
    fi;
    
    R := HomalgRing( M );
    
    if HasCoefficientsRing( R ) then
        k := CoefficientsRing( R );
        
        if HasIsIntegersForHomalg( k ) and IsIntegersForHomalg( k ) then
            char := Eliminate( BasisOfRows( M ) );
            if not IsIdenticalObj( k, HomalgRing( char ) ) then
                char := Eliminate( char );
            fi;
            if not IsZero( char ) then
                char := EntriesOfHomalgMatrix( char );
                char := List( char, a -> EvalString( String( a ) ) );
                char := Gcd( char );
                if not IsPrime( char ) then
                    Error( "AffineDegree over a mixed characteristic, here ", char, ", is not supported yet\n" );
                fi;
                k := HomalgRingOfIntegersInUnderlyingCAS( char, k );
                R := k * List( Indeterminates( R ), String );
                M := R * M;
                M := BasisOfRows( M );
            fi;
        fi;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
       IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries )  then
        
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        return Sum( hilb );

    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) then
        
        weights := ListWithIdenticalEntries( Length( Indeterminates( R ) ), 1 );
        
        degrees := ListWithIdenticalEntries( NumberColumns( M ), 0 );
        
        return AffineDegree( LeadingModule( M ), weights, degrees );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( ProjectiveDegree,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    local R, RP, hilb;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        hilb := HilbertPolynomial( M );
        
        if IsZero( hilb ) then
            return 0;
        fi;
        
        return LeadingCoefficient( hilb ) * Factorial( Degree( hilb ) );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := HilbertPolynomial( M, weights, degrees );
        
        if IsZero( hilb ) then
            return 0;
        fi;
        
        return LeadingCoefficient( hilb ) * Factorial( Degree( hilb ) );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( ProjectiveDegree,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, hilb;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries )  then
        
        hilb := HilbertPolynomial( M );
        
        if IsZero( hilb ) then
            hilb := 0;
        else
            hilb := LeadingCoefficient( hilb ) * Factorial( Degree( hilb ) );
        fi;
        
        return hilb;
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfNumeratorOfHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( ConstantTermOfHilbertPolynomial,
        "for a homalg matrix and two lists",
        [ IsHomalgMatrix, IsList, IsList ],
        
  function( M, weights, degrees )
    local d, R, RP, t, hilb, range;
    
    ## take care of n x 0 matrices
    if NumberColumns( M ) = 0 then
        return 0;
    fi;
    
    ## for CASs which do not support Hilbert* for non-graded modules
    d := AffineDimension( M, weights, degrees );
    
    if d <= 0 then
        return 0;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if ( IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
         IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) ) and
       Set( weights ) = [ 1 ] and Length( Set( degrees ) ) = 1 then
        
        t := Set( degrees )[ 1 ];
        
        ## the coefficients of the untwisted numerator
        ## differ from the twisted ones below by a shift by t
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        return Sum( [ 0 .. Length( hilb ) - 1 ], k -> hilb[k+1] * Binomial( d - 1 -t - k, d - 1 ) );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfWeightedHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M, weights, degrees );
        
        range := hilb[2];
        hilb := hilb[1];
        
        return Sum( [ 1 .. Length( range ) ], i -> hilb[i] * Binomial( d - 1 - range[i], d - 1 ) );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called CoefficientsOfUnreducedNumeratorOfWeightedHilbertPoincareSeries ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( ConstantTermOfHilbertPolynomial,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP, d, hilb;
    
    if NumberColumns( M ) = 0 then
        ## take care of n x 0 matrices
        return 0;
    elif IsZero( M ) then
        ## take care of zero matrices, especially of 0 x n matrices
        return NumberColumns( M );
    fi;
    
    d := AffineDimension( M );
    
    if d <= 0 then
        return 0;
    fi;
    
    R := HomalgRing( M );
    
    RP := homalgTable( R );
    
    if IsBound( RP!.ConstantTermOfHilbertPolynomial ) then
        
        return RP!.ConstantTermOfHilbertPolynomial( M );
        
    elif IsBound( RP!.CoefficientsOfUnreducedNumeratorOfHilbertPoincareSeries ) or
      IsBound( RP!.CoefficientsOfNumeratorOfHilbertPoincareSeries ) then
        
        hilb := CoefficientsOfNumeratorOfHilbertPoincareSeries( M );
        
        return Sum( [ 0 .. Length( hilb ) - 1 ], k -> hilb[k+1] * Binomial( d - 1 - k, d - 1 ) );
        
    fi;
    
    if not IsHomalgInternalRingRep( R ) then
        Error( "could not find a procedure called ConstantTermOfHilbertPolynomial ",
               "in the homalgTable of the non-internal ring\n" );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( DataOfHilbertFunction,
        "for a rational function",
        [ IsRationalFunction ],
        
  function( HP )
    local t, H, numer, denom, range, ldeg, hdeg, s, power, q, F, l, i;
    
    t := VariableForHilbertPolynomial( );
    
    if IsZero( HP ) then
        
        H := 0 * t;
        
        ## it is ugly that we need this
        SetIndeterminateOfUnivariateRationalFunction( H, t );
        
        ## checking this property sets it
        Assert( 0, IsUnivariatePolynomial( H ) );
        
        return [ [ [ ], [ ] ], H ];
        
    fi;
    
    numer := NumeratorOfRationalFunction( HP );
    denom := DenominatorOfRationalFunction( HP );
    
    denom!.IndeterminateNumberOfUnivariateRationalFunction := IndeterminateNumberOfUnivariateRationalFunction( numer );
    
    range := CoefficientsOfNumeratorOfHilbertPoincareSeries( HP )[2];
    
    ldeg := range[1];
    
    hdeg := range[Length( range )];
    
    s := IndeterminateOfUnivariateRationalFunction( HP );
    
    power := Minimum( 0, ldeg );
    
    denom := denom * s^power;
    
    ## set the property IsUnivariatePolynomial by testing it
    Assert( 0, IsUnivariatePolynomial( numer ) );
    Assert( 0, IsUnivariatePolynomial( denom ) );
    
    q := s^(hdeg - power);
    numer := EuclideanRemainder( numer, q );
    denom := EuclideanRemainder( denom, q );
    
    F := numer * GcdRepresentation( denom, q )[1];
    
    F := EuclideanRemainder( F, q ) * s^power;
    
    F := CoefficientsOfLaurentPolynomialsWithRange( F );
    
    Assert( 0, IsSubset( range, F[2] ) );
    
    range := F[2];
    
    l := Length( range );
    
    H := HilbertPolynomialOfHilbertPoincareSeries( HP );
    
    while l > 0 do
        
        if Value( H, range[l] ) <> F[1][l] then
            break;
        fi;
        
        l := l - 1;
        
        range := F[2]{[ 1 .. l ]};
        
        F := [ F[1]{[ 1 .. l ]}, range ];
        
    od;
    
    if l = 0 then
        return [ [ [ 0 ], [ ldeg - 1 ] ], H ];
    fi;
    
    return [ F, H ];
    
end );

##
InstallMethod( HilbertFunction,
        "for a rational function",
        [ IsRationalFunction ],
        
  function( HP )
    local data, H, l, ldeg, indeg;
    
    data := DataOfHilbertFunction( HP );
    
    H := data[2];
    
    data := data[1];
    
    l := Length( data[2] );
    
    if l = 0 then
        
        Assert( 0, IsZero( H ) );
        
        return t -> 0;
        
    fi;
    
    ldeg := data[2][1];
    indeg := data[2][l];
    
    data := data[1];
    
    return
      function( t )
        
        if t < ldeg then
            return 0;
        elif t <= indeg then
            if not IsInt( t ) then
                Error( "only able to evaluate integers in the interval [ ldeg, indeg ], but received ", t, "\n" );
            fi;
            return data[t - ldeg + 1];
        fi;
        
        return Value( H, t );
        
    end;
    
end );

##
InstallMethod( IndexOfRegularity,
        "for a rational function",
        [ IsRationalFunction ],
        
  function( HP )
    local range;
    
    if IsZero( HP ) then
        Error( "GAP does not support -infinity yet\n" );
    fi;
    
    range := DataOfHilbertFunction( HP )[1][2];
    
    return range[Length( range )] + 1;
    
end );

##
InstallMethod( IsPrimeModule,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( M )
    local R, RP;
    
    R := HomalgRing( M );
    
    if IsZero( M ) and HasIsIntegralDomain( R ) and IsIntegralDomain( R ) then
        return true;
    fi;
    
    RP := homalgTable( R );
    
    if IsBound( RP!.IsPrime ) then
        return RP!.IsPrime( M );
    fi;
    
    TryNextMethod( );
    
end );

##
InstallMethod( IntersectWithSubalgebra,
        "for a homalg matrix and a list",
        [ IsHomalgMatrix, IsList ],
        
  function( I, var )
    local R, indets, J, S;
    
    R := HomalgRing( I );
    
    if not ( HasIsFreePolynomialRing( R ) and IsFreePolynomialRing( R ) ) then
        TryNextMethod( );
    fi;
    
    indets := Indeterminates( R );
    
    if not IsSubset( indets, var ) then
        Error( "expecting the second argument ", var,
               " to be a subset of the set of indeterminates ", indets, "\n" );
    fi;
    
    J := Eliminate( I, Difference( indets, var ) );
    
    S := CoefficientsRing( R ) * var;
    
    return S * J;
    
end );

##
InstallMethod( MaximalIndependentSet,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( I )
    local R, indets, d, RP, i, combinations, u;
    
    R := HomalgRing( I );
    
    indets := Indeterminates( R );
    
    if IsZero( I ) then
        return indets;
    fi;
    
    I := BasisOfRowModule( I );
    
    d := AffineDimension( I );
    
    if d = 0 then
        return [ ];
    fi;
    
    RP := homalgTable( R );
    
    if IsBound(RP!.MaximalIndependentSet) then
        indets := RP!.MaximalIndependentSet( I );
        Assert( 0, Length( indets ) = d );
        return indets;
    fi;
    
    ## the fallback method
    
    combinations := IteratorOfCombinations( indets, d );
    
    for u in combinations do
        if IsZero( IntersectWithSubalgebra( I, u ) ) then
            return u;
        fi;
    od;
    
    Error( "oh, no maximal independent set found, this is a bug!\n" );
    
end );

## for ideals with affine entries
InstallMethod( MaximalIndependentSet,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( I )
    local R, indets, d, left;
    
    R := HomalgRing( I );
    
    indets := Indeterminates( R );
    
    if IsZero( I ) then
        return indets;
    fi;
    
    d := AffineDimension( I );
    
    if d = 0 then
        return [ ];
    fi;
    
    I := BasisOfRowModule( I );
    
    if not ForAll( EntriesOfHomalgMatrix( I ), a -> Degree( a ) = 1 ) then
        TryNextMethod( );
    fi;
    
    I := LeadingModule( I );
    
    return Difference( indets, EntriesOfHomalgMatrix( I ) );
    
end );

##
InstallMethod( AMaximalIdealContaining,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( I )
    local R, A, one, indets, m, v, l, n_is_one, n, a, k, d;
    
    R := HomalgRing( I );
    
    if not HasCoefficientsRing( R ) then
        TryNextMethod( );
    fi;
    
    A := CoefficientsRing( R );
    
    if not ( HasIsFieldForHomalg( A ) and IsFieldForHomalg( A ) ) then
        TryNextMethod( );
    fi;
    
    one := HomalgIdentityMatrix( 1, R );
    
    I := BasisOfRowModule( I );
    
    if IsZero( DecideZeroRows( one, I ) ) then
        Error( "expected a matrix not reducing one to zero\n" );
    fi;
    
    indets := Indeterminates( R );
    
    if IsZero( I ) then
        return HomalgMatrix( indets, Length( indets ), 1, R );
    fi;
    
    m := I;
    
    while AffineDimension( m ) > 0 do
        
        v := MaximalIndependentSet( m );
        
        n_is_one := true;
        
        while true do
            
            ## the fiber over the origin of the subspace L corresponding
            ## to the maximal independent set v
            n := UnionOfRows( m, HomalgMatrix( v, Length( v ), 1, R ) );
            
            n := BasisOfRowModule( n );
            
            ## if the fiber is not empty then break the while loop
            if not IsZero( DecideZeroRows( one, n ) ) then
                n_is_one := false;
                break;
            fi;
            
            l := Length( v );
            
            ## try fibers over bigger coordinate subspaces of L containing the origin
            if l > 1 then
                Remove( v, l );
            else
                break;
            fi;
            
        od;
        
        if n_is_one then
            
            v := v[1];
            
            a := One( R );
            k := 1;
            
            while true do
                
                n := UnionOfRows( m, HomalgMatrix( [ v^k + a ], 1, 1, R ) );
                
                n := BasisOfRowModule( n );
                
                if not IsZero( DecideZeroRows( one, n ) ) then
                    break;
                fi;
                
                a := a + 1;
                
                if IsZero( a ) then
                    k := k + 1;
                fi;
                
            od;
            
        fi;
        
        m := n;
        
    od;
    
    m := RadicalDecompositionOp( m );
    
    d := List( m, AffineDegree );
    
    d := Minimum( d );
    
    m := First( m, p -> AffineDegree( p ) = d );
    
    Assert( 4, AffineDimension( m ) = 0 );
    
    SetAffineDimension( m, 0 );
    
    return m;
    
end );

##
InstallMethod( AMaximalIdealContaining,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( I )
    local R, zz, one, indets, S, gens, gens0, lcm, p, Fp;
    
    R := HomalgRing( I );
    
    if not HasCoefficientsRing( R ) then
        TryNextMethod( );
    fi;
    
    zz := CoefficientsRing( R );
    
    if not ( HasIsIntegersForHomalg( zz ) and IsIntegersForHomalg( zz ) ) then
        TryNextMethod( );
    fi;
    
    indets := Indeterminates( R );
    
    S := zz * indets;
    
    I := S * I;
    
    one := HomalgIdentityMatrix( 1, S );
    
    I := BasisOfRowModule( I );
    
    if IsZero( DecideZeroRows( one, I ) ) then
        Error( "expected a matrix not reducing one to zero\n" );
    fi;
    
    if IsZero( I ) then
        return UnionOfRows( HomalgMatrix( "[2]", 1, 1, R ), HomalgMatrix( indets, Length( indets ), 1, R ) );
    fi;
    
    gens := EntriesOfHomalgMatrix( S * I );
    
    gens0 := Filtered( gens, g -> Degree( g ) = 0 );
    
    if not gens0 = [ ] then
        
        gens0 := List( List( gens0, String ), EvalString );
        gens0 := Gcd( gens0 );
        
        p := PrimeDivisors( gens0 )[1];
        
    else
        
        lcm := Iterated( List( gens, LeadingCoefficient ), LcmOp );
        lcm := Int( String( lcm ) );
        
        p := 2;
        
        while IsInt( lcm / p ) do
            p := NextPrimeInt( p );
        od;
        
    fi;
    
    Assert( 4, not ( p / S ) in I );
    
    Fp := HomalgRingOfIntegersInUnderlyingCAS( p, zz );
    S := Fp * indets;
    I := S * I;
    
    p := HomalgMatrix( [ p ], 1, 1, R );
    
    return UnionOfRows( p, R * AMaximalIdealContaining( I ) );
    
end );

##
InstallMethod( AMaximalIdealContaining,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( I )
    local R;
    
    R := HomalgRing( I );
    
    if not ( HasIsFieldForHomalg( R ) and IsFieldForHomalg( R ) ) then
        TryNextMethod( );
    fi;
    
    I := BasisOfRowModule( I );
    
    if not IsZero( I ) then
        Error( "expected a matrix not reducing one to zero\n" );
    fi;
    
    return I;
    
end );

##
InstallMethod( AMaximalIdealContaining,
        "for a homalg matrix",
        [ IsHomalgMatrix ],
        
  function( I )
    local R, one;
    
    R := HomalgRing( I );
    
    if not ( HasIsIntegersForHomalg( R ) and IsIntegersForHomalg( R ) ) then
        TryNextMethod( );
    fi;
    
    one := HomalgIdentityMatrix( 1, R );
    
    I := BasisOfRowModule( I );
    
    if IsZero( DecideZeroRows( one, I ) ) then
        Error( "expected a matrix not reducing one to zero\n" );
    fi;
    
    if IsZero( I ) then
        return HomalgMatrix( [ 2 ], 1, 1, R );
    fi;
    
    if not NumberRows( I ) = 1  then
        Error( "Hermite normal form failed to produce the cyclic generator ",
               "of the principal ideal\n" );
    fi;
    
    I := I[ 1, 1 ];
    I := Int( String( I ) );
    
    return HomalgMatrix( [ PrimeDivisors( I ){[1]} ], 1, 1, R );
    
end );

##
InstallMethod( IsolateIndeterminate,
        "for a homalg ring element",
        [ IsHomalgRingElement ],
        
  function( r )
    local R, indets, l, coeffs, monoms, t, degrees, pos, i, c, a;
    
    R := HomalgRing( r );
    
    indets := Indeterminates( R );
    
    l := Length( indets );
    
    if l = [ ] then
        return fail;
    fi;
    
    coeffs := Coefficients( r );
    monoms := coeffs!.monomials;
    
    t := Length( monoms );
    
    degrees := List( monoms, Degree );
    
    if not 1 in degrees then
        return fail;
    fi;
    
    pos := Positions( degrees, 1 );
    
    for i in pos do
        
        c := coeffs[ i, 1 ];
        
        if not IsUnit( c ) then
            continue;
        fi;
        
        a := monoms[i];
        
        if not ForAll( Concatenation( [ 1 .. i - 1 ], [ i + 1 .. t ] ), j -> not IsZero( DecideZero( monoms[j], a ) ) ) then
            continue;
        fi;
        
        return [ Position( indets, a ), a - ( r / c ) ];
        
    od;
    
    return fail;
    
end );

##
InstallOtherMethod( Saturate,
        "for two homalg matrices",
        [ IsHomalgMatrix, IsHomalgMatrix ],
        
  function( mat, r )
    local mat_old;
    
    if not NumberColumns( mat ) = NumberColumns( r ) then
        Error( "the matrices mat and r must have the same number of columns\n" );
    elif not NumberRows( r ) = NumberColumns( r ) then
        Error( "the matrix r is not a square matrix\n" );
    fi;
    
    repeat
        mat_old := mat;
        mat := SyzygiesOfRows( r, mat );
    until IsZero( DecideZeroRows( mat, mat_old ) );
    
    return mat;
    
end );

##
InstallMethod( Saturate,
        "for a homalg matrix and a homalg ring element",
        [ IsHomalgMatrix, IsRingElement ],
        
  function( mat, r )
    
    r := HomalgMatrix( [ r ], 1, 1, HomalgRing( mat ) );
    
    return Saturate( mat, r );
    
end );

##
InstallMethod( RingMapOntoRewrittenResidueClassRing,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    local id, I, A, k, char, indets, matrix, images, zero_rows, S, pi, ker;
    
    id := RingMap( R );
    
    if not HasAmbientRing( R ) then
        return id;
    fi;
    
    ## R = A / I
    I := BasisOfRows( MatrixOfRelations( R ) );
    
    A := AmbientRing( R );
    
    k := CoefficientsRing( A );
    
    if HasIsIntegersForHomalg( k ) and IsIntegersForHomalg( k ) then
        char := Eliminate( I );
        if not IsIdenticalObj( k, HomalgRing( char ) ) then
            char := Eliminate( char );
        fi;
        if not IsZero( char ) then
            char := EntriesOfHomalgMatrix( char );
            char := List( char, a -> EvalString( String( a ) ) );
            char := Gcd( char );
            if IsPrime( char ) then
                k := HomalgRingOfIntegersInUnderlyingCAS( char, k );
            fi;
        fi;
    fi;
    
    indets := Indeterminates( A );
    
    matrix := HomalgMatrix( indets, Length( indets ), 1, A );
    
    ## search for the standard indeterminates with respect to I: NF_I(x_i) = x_i
    images := DecideZero( matrix, I );
    
    ## the positions of the standard indeterminates with respect to I
    zero_rows := ZeroRows( matrix - images );
    
    ## create the standard subring S of A, i.e., the subring generated by the standard indeterminates
    if IsZero( DecideZeroRows( HomalgIdentityMatrix( 1, A ), I ) ) then
        S := k / One( k );
    elif Length( indets ) = Length( zero_rows ) and
       IsIdenticalObj( k, CoefficientsRing( A ) ) then
        S := A;
    else
        indets := indets{zero_rows};
        S := k * List( indets, String );
    fi;
    
    if not zero_rows = [ ] then
        ## define the surjective ring morphism pi: S ->> R = A / I
        pi := RingMap( indets, S, R );
        ## compute the kernel ker( pi )
        ker := GeneratorsOfKernelOfRingMap( pi );
        ## define the residue class ring S / ker( pi ), isomorphic to R = A / I
        S := S / ker;
    fi;
    
    images := S * images;
    
    ## define the surjective ring morphism A ->> S / ker
    pi := RingMap( images, A, S );
    
    SetIsMorphism( pi, true );
    SetIsEpimorphism( pi, true );
    
    return pi;
    
end );

##
InstallMethod( RingMapOntoSimplifiedOnceResidueClassRing,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    local id, I, i, img, A, indets, new_indets, S, map, epi;
    
    id := RingMap( R );
    
    if not HasAmbientRing( R ) then
        return id;
    fi;
    
    ## R = A / I
    A := AmbientRing( R );
    
    I := MatrixOfRelations( R );
    
    ## [ y_1, ..., y_{i-1}, y_i, y_{i+1}, ..., y_s ]
    indets := ShallowCopy( Indeterminates( A ) );
    
    if IsEmpty( indets ) and IsZero( DecideZeroRows( HomalgIdentityMatrix( 1, A ), I ) ) then
        S := CoefficientsRing( A ) / 1;
        SetIsZero( S, true );
        epi := RingMap( ListWithIdenticalEntries( Length( indets ), Zero( S ) ), A, S );
        SetIsMorphism( epi, true );
        SetIsEpimorphism( epi, true );
        return epi;
    fi;
    
    for i in [ 1 .. NumberRows( I ) ] do
        ## [ j, f/u ] where (u y_j - f) ∈ GB(I)
        img := IsolateIndeterminate( I[ i, 1 ] );
        if not img = fail then
            break;
        fi;
    od;
    
    if img = fail then
        epi := RingMap( List( indets, a -> a / R ), A, R );
        SetIsMorphism( epi, true );
        SetIsEpimorphism( epi, true );
        return epi;
    fi;
    
    new_indets := List( indets, String );
    
    ## [ y_1, ..., y_{i-1}, y_{i+1}, ..., y_s ]
    Remove( new_indets, img[1] );
    
    ## k[y_1, ..., y_{i-1}, y_{i+1}, ..., y_s]
    S := CoefficientsRing( A ) * new_indets;
    
    ## [ y_1, ..., y_{i-1}, f/u y_{i+1}, ..., y_s ]
    indets[img[1]] := img[2];
    
    indets := List( indets, a -> a / S );
    
    map := RingMap( indets, A, S );
    
    ## replace y_i -> f/u
    I := Pullback( map, I );
    
    I := BasisOfRows( I );
    
    S := S / I;
    
    indets := List( indets, a -> a / S );
    
    epi := RingMap( indets, A, S );
    
    SetIsMorphism( epi, true );
    SetIsEpimorphism( epi, true );
    
    return epi;
    
end );

##
InstallMethod( RingMapOntoSimplifiedResidueClassRing,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    local pi, psi;
    
    # R = A / I
    pi := RingMapOntoRewrittenResidueClassRing( R ); # replace pi: A -> R = A / I by pi: A -> R_1 := A_1 / I_1
    
    while true do
        
        ## construct the surjective morphism psi: A_i -> A_{i+1} / I_{i+1} =: R_{i+1}
        psi := RingMapOntoSimplifiedOnceResidueClassRing( Range( pi ) );
        
        if ( HasIsZero( Range( psi ) ) and IsZero( Range( psi ) ) ) or
           Length( Indeterminates( Source( psi ) ) ) = Length( Indeterminates( Range( psi ) ) ) then
            break;
        fi;
        
        ## compose A -pi-> A_i / I_i -psi-> A_{i+1} / I_{i+1},
        ## where we understand the above psi as the isomorphism psi: A_i / I_i -psi-> A_{i+1} / I_{i+1}
        pi := PreCompose( pi, psi );
        
    od;
    
    return pi;
    
end );

##
InstallMethod( RingMapOntoSimplifiedOnceResidueClassRingUsingLinearEquations,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    local id, I, L, A, S, pi, P, J, T, psi, epi;
    
    id := RingMap( R );
    
    if not HasAmbientRing( R ) then
        return id;
    elif HasIsZero( R ) and IsZero( R ) then
        return id;
    fi;
    
    ## R = A / I
    I := MatrixOfRelations( R );
    
    L := Filtered( EntriesOfHomalgMatrix( I ), e -> Degree( e ) <= 1 );
    
    A := AmbientRing( R );
    
    L := HomalgMatrix( L, Length( L ), 1, A );
    
    L := BasisOfRows( L );
    
    if IsZero( L ) then
        return id;
    fi;
    
    S := A / L;
    
    pi := RingMapOntoSimplifiedResidueClassRing( S );
    
    P := Range( pi );
    
    Assert( 0, ( HasIsZero( P ) and IsZero( P ) ) or not HasAmbientRing( P ) );
    
    J := Pullback( pi, I );
    
    J := CertainRows( J, NonZeroRows( J ) );
    
    T := P / J;
    
    psi := RingMap( List( Indeterminates( P ), a -> a / T ), P, T );
    
    epi := PreCompose( pi, psi );
    
    SetIsMorphism( epi, true );
    SetIsEpimorphism( epi, true );
    
    return epi;
    
end );

##
InstallMethod( RingMapOntoSimplifiedResidueClassRingUsingLinearEquations,
        "for a homalg ring",
        [ IsHomalgRing ],
        
  function( R )
    local id, pi, psi;
    
    id := RingMap( R );
    
    if not HasAmbientRing( R ) then
        return id;
    fi;
    
    # R = A / I
    pi := RingMap( Indeterminates( R ), AmbientRing( R ), R );
    
    SetIsMorphism( pi, true );
    SetIsEpimorphism( pi, true );
    
    while true do
        
        ## construct the surjective morphism psi: A_i -> A_{i+1} / I_{i+1} =: R_{i+1}
        psi := RingMapOntoSimplifiedOnceResidueClassRingUsingLinearEquations( Range( pi ) );
        
        if ( HasIsZero( Range( psi ) ) and IsZero( Range( psi ) ) ) or
           Length( Indeterminates( Source( psi ) ) ) = Length( Indeterminates( Range( psi ) ) ) then
            break;
        fi;
        
        ## compose A -pi-> A_i / I_i -psi-> A_{i+1} / I_{i+1},
        ## where we understand the above psi as the isomorphism psi: A_i / I_i -psi-> A_{i+1} / I_{i+1}
        pi := PreCompose( pi, psi );
        
    od;
    
    return pi;
    
end );
