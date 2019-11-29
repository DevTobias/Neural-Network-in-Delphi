unit UVector;

interface

type
  t_vector  = array of extended;
  t_matrix  = array of t_vector;
  t_array3d = array of t_matrix;

type
  TVector = class

  public //Methoden
    function subtractArray( pMatrix1 : t_matrix; pMatrix2 : t_matrix ) : t_matrix; overload;
    function subtractArray( p3DArray1 : t_array3d; p3DArray2 : t_array3d ) : t_array3d; overload;
    function addArray( p3DArray1 : t_array3d; p3DArray2 : t_array3d ) : t_array3d; overload;
    function addArray( pMatrix1 : t_matrix; pMatrix2 : t_matrix ) : t_matrix; overload;
    function multiplyArray( pMatrix : t_matrix; pVector : t_vector ) : t_vector; overload;

  end;

implementation


//+-----------------------------------------------------------------------------
//|         Vektoren multiplizieren
//+-----------------------------------------------------------------------------

//-------- Matrix auf Vector multiplizieren (public) ----------------------------
function TVector.multiplyArray( pMatrix : t_matrix; pVector : t_vector ) : t_vector;

//var
//  I, J : Integer;

begin

 { for I := 0 to Length( pMatrix ) - 1 do
    for J := 0 to Length( pMatrix[ I ] ) - 1 do
      if ( I = 0 ) and ( J = 0 ) then
        t_vector[ I ] := ( t_vector[ J ] * pMatrix[ I ][ J ] )
      else
        t_vector[ I ] := t_vector[ I ] + ( t_vector[ J ] * pMatrix[ I ][ J ] );

  result := t_vector;
 }
end;


//+-----------------------------------------------------------------------------
//|         Vektoren subtrahieren
//+-----------------------------------------------------------------------------

//-------- 3D Array subtrahieren (public) --------------------------------------
function TVector.addArray( p3DArray1 : t_array3d; p3DArray2 : t_array3d ) : t_array3d;

var
  I, J, K : Integer;

begin

  for I := 0 to Length( p3DArray1 ) - 1 do
    for J := 0 to Length( p3DArray1[ I ] ) - 1 do
      for K := 0 to Length( p3DArray1[ I ][ J ] ) - 1 do
        p3DArray1[ I ][ J ][ K ] := p3DArray1[ I ][ J ][ K ] + p3DArray2[ I ][ J ][ K ];

  result := p3DArray1;

end;

//-------- Matrix subtrahieren (public) ----------------------------------------
function TVector.addArray( pMatrix1 : t_matrix; pMatrix2 : t_matrix ) : t_matrix;

var
  I, J : Integer;

begin

  for I := 0 to Length( pMatrix1 ) - 1 do
    for J := 0 to Length( pMatrix1[ I ] ) - 1 do
      pMatrix1[ I ][ J ] := pMatrix1[ I ][ J ] + pMatrix2[ I ][ J ];

  result := pMatrix1;

end;



//+-----------------------------------------------------------------------------
//|         Vektoren addieren
//+-----------------------------------------------------------------------------

//-------- 3D Array addieren (public) ------------------------------------------
function TVector.subtractArray( p3DArray1 : t_array3d; p3DArray2 : t_array3d ) : t_array3d;

var
  I, J, K : Integer;

begin

  for I := 0 to Length( p3DArray1 ) - 1 do
    for J := 0 to Length( p3DArray1[ I ] ) - 1 do
      for K := 0 to Length( p3DArray1[ I ][ J ] ) - 1 do
        p3DArray1[ I ][ J ][ K ] := p3DArray1[ I ][ J ][ K ] - p3DArray2[ I ][ J ][ K ];

  result := p3DArray1;

end;

//-------- Matrix addieren (public) --------------------------------------------
function TVector.subtractArray( pMatrix1 : t_matrix; pMatrix2 : t_matrix ) : t_matrix;

var
  I, J : Integer;

begin

  for I := 0 to Length( pMatrix1 ) - 1 do
    for J := 0 to Length( pMatrix1[ I ] ) - 1 do
      pMatrix1[ I ][ J ] := pMatrix1[ I ][ J ] - pMatrix2[ I ][ J ];

  result := pMatrix1;

end;


end.
