unit UNeuralNetwork;

interface

uses
  System.Classes, System.SysUtils, System.Math, Vcl.Dialogs, Winapi.Windows, Vcl.Graphics,
  UVector;

type
  t_vector  = UVector.t_vector;
  t_matrix  = UVector.t_matrix;
  t_array3d = UVector.t_array3d;

type
  TNeuralNetwork = class

  private //Attribute
    weights : t_array3d;
    biases : t_matrix;
    activations : t_matrix;
    zActivations : t_matrix;
    expectedOutputVector : t_vector;

    gradientWeights : t_array3d;
    gradientBiases : t_matrix;
    gradientActivations : t_matrix;

    layerSizes : TStringList;
    dataInputList : TStringList;

    amountLayers : Integer;
    currentSolution : Integer;


  public //Netzwerk erzeugen / initialisieren
    constructor Create( pSizes: TStringList ); overload;
    constructor Create( pInputPath : String ); overload;
    destructor Destroy; override;
  private
    procedure initializeWeightsAndBiases(); virtual;
    procedure declareWeightsAndBiases(); virtual;

  public//Netzwerk speichern / auslesen
    procedure saveNetwork( pOutputPath : String );
    procedure loadNetwork( pInputPath : String );
  private
    procedure saveWeightsAndBiases( pOutputPath : String ); virtual;
    procedure saveNetworkData(pOutputPath : String ); virtual;
    procedure readWeightsAndBiases( pInputPath : String ); virtual;
    procedure readNetworkData( pInputPath : String ); virtual;

  public //Netzwerk Ausgabe berechnen
    function feedForward( pInputLayer : t_vector ) : t_vector; virtual;

  public //Netzwerk Trainieren
    procedure backpropagateNetwork( pBatchSize : Integer; pRounds : Integer; pDataPath : String ); virtual;
  private
    procedure calculateOutputLayerGradient( pLayerL, pLayerL_1 : Integer ); virtual;
    procedure calculateHiddenLayerGradient( pLayerL, pLayerL_1 : Integer ); virtual;
    procedure resetGradientArrays(); virtual;

  public //Netzwerk Testen
    function calculateHitRate( pStartIndex : Integer; pEndIndex : Integer ) : Real; virtual;
    function calculateAverageCost( pStartIndex : Integer; pEndIndex : Integer ) : Real; virtual;
    function getCurrentSolution( pType : String ) : String; virtual;
    function getOutputSolution( pType : String): String; virtual;
  private
    function calculateCost( pOutputLayer : t_vector ) : Real; virtual;

  public //Netzwerk Datenbasis
    function getInputData( pIndex : Integer ) : String; virtual;
    procedure loadInputData( pInputPath : String ); virtual;
    function calculateInputActivations( pInputString : String ) : t_vector; virtual;
    function getBitmapFromPixel( pInputSize : Integer; pIndex : Integer; pDataPath : String ) : TBitmap; virtual;

  private //Berechnungsfunktionen
    procedure Split( pDelimiter: Char; pInputStr: String; pOutputList: TStrings ); virtual;
    function multiplyMatrixWithVector( pWeightMatrix : t_matrix; pActivationVector : t_vector ) : t_vector; virtual;
    function calculateSigmoid( pActivation : extended ) : extended; virtual;
    function addVectorWithVector( pActivationVector, pBiasVector : t_vector ) : t_vector; virtual;
    function calculateVectorSigmoid( pVector : t_vector ) : t_vector; virtual;
    function calculateSigmoidPrime( pActivation : extended ) : extended; virtual;
    function subtractArray( pMatrix1 : t_matrix; pMatrix2 : t_matrix; pBatchSize : Integer ) : t_matrix; overload;
    function subtractArray( p3DArray1 : t_array3d; p3DArray2 : t_array3d; pBatchSize : Integer ) : t_array3d; overload;

  end;


implementation



//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Netzwerk erzeugen / initialisieren
//+-----------------------------------------------------------------------------

//-------- Create-New (public) -------------------------------------------------
constructor TNeuralNetwork.Create( pSizes: TStringList ); begin

  inherited Create;
  randomize();

  layerSizes := pSizes;
  amountLayers := layerSizes.Count;

  declareWeightsAndBiases();
  initializeWeightsAndBiases();

end;

//-------- Create-Avaible (public) ---------------------------------------------
constructor TNeuralNetwork.Create( pInputPath : String ); begin

  inherited Create;
  randomize();

  loadNetwork( pInputPath );

end;

//-------- Objekt freigeben (public) -------------------------------------------
destructor TNeuralNetwork.Destroy(); begin

 // self.layerSizes.Free;

end;

//-------- Arrays deklarieren (private) ----------------------------------------
procedure TNeuralNetwork.declareWeightsAndBiases();

var
  I : Integer;

begin

  //Activations initialisieren

    //Matrix Array festlegen - Y(Anzahl Layer), X(Knoten pro Layer)
  setLength( activations, amountLayers );
  setLength( zActivations, amountLayers );
  setLength( gradientActivations, amountLayers );
  for I := 0 to amountLayers - 1 do begin
    setLength( activations[ I ], StrToInt( layerSizes[ I ] ) );
    setLength( zActivations[ I ], StrToInt( layerSizes[ I ] ) );
    setLength( gradientActivations[ I ], StrToInt( layerSizes[ I ] ) );
  end;

  //Biases initialisieren

    //Matrix Array festlegen - Y(Anzahl Layer), X(Knoten pro Layer)
  setLength( biases, amountLayers - 1 );
  setLength( gradientBiases, amountLayers - 1 );
  for I := 0 to amountLayers - 2 do begin
    setLength( biases[ I ], StrToInt( layerSizes[ I + 1 ] ) );
    setLength( gradientBiases[ I ], StrToInt( layerSizes[ I + 1 ] ) );
  end;

  //Weights initialisieren

    //3D Array festlegen - Z(Anzahl Layer), Y(Knoten Layer L+1), X(Knoten Layer L)
    //l+1 vor L damit feedForward einfach zu berechnen ist
  setLength( weights, amountLayers - 1 );
  setLength( gradientWeights, amountLayers - 1 );
  for I := 0 to amountLayers - 2 do begin
    setLength( weights[ I ], StrToInt( layerSizes[ I + 1 ] ), StrToInt( layerSizes[ I ] ) );
    setLength( gradientWeights[ I ], StrToInt( layerSizes[ I + 1 ] ), StrToInt( layerSizes[ I ] ) );
  end;

  //Output initialisieren

  setLength( expectedOutputVector, StrToInt( layerSizes[ amountLayers - 1 ] ) );

end;

//-------- InitializeNetwork-New (private) -------------------------------------
procedure TNeuralNetwork.initializeWeightsAndBiases();

var
  I, J, K : Integer;

begin

  //Biases initialisieren

    //Wete einsetzen - b = 0
    //Anzahl der Layer - Biases für jeden Knoten jedes Layers
  for I := 0 to amountLayers - 2 do
    for J := 0 to StrToInt( layerSizes[ I + 1 ] ) - 1 do
      biases[ I ][ J ] := RandG( 0, 1 ) * sqrt( 2 / Length( layerSizes[ I ] ) );

  //Weights initialisieren

    //Werte einsetzen - w = random * Wurzel aus 2 durch Anzahl der Knoten im Layer
    //Anzahl der Verbindungen - Weights Verbindung von Layer L zu Layer L+1
  for I := 0 to amountLayers - 2 do
    for J := 0 to StrToInt( layerSizes[ I ] ) - 1 do
      for K := 0 to StrToInt( layerSizes[ I + 1 ] ) - 1 do
        weights[ I ][ K ][ J ] := RandG( 0, 1 ) * sqrt( 2 / Length( layerSizes[ I ] ) );

end;




//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Netzwerk speichern / auslesen
//+-----------------------------------------------------------------------------

//-------- Save Network (public) -----------------------------------------------
procedure TNeuralNetwork.saveNetwork( pOutputPath : String ); begin

  saveNetworkData( pOutputPath );
  saveWeightsAndBiases( pOutputPath );
  writeln( 'Netzwerkdaten erfolgreich gespeichert!' );

end;

//-------- Save Network Connections (private) ----------------------------------
procedure TNeuralNetwork.saveWeightsAndBiases( pOutputPath : String );

var
  I, J, K : Integer;
  cacheOutput : String;
  outputList : TStringList;

begin

  outputList := TStringList.Create;

    //Biases

  cacheOutput := '';
  for I := 0 to amountLayers - 2 do begin
    for J := 0 to StrToInt( layerSizes[ I + 1 ] ) - 1 do
      cacheOutput := cacheOutput + FloatToStr( biases[ I ][ J ] ) + ' ';
    outputList.Add( cacheOutput );
    cacheOutput := '';
  end;
  outputList.SaveToFile( pOutputPath + 'biases.txt' );
  outputList.Clear;

    //Weights

  cacheOutput := '';
  for I := 0 to amountLayers - 2 do begin
    for J := 0 to StrToInt( layerSizes[ I + 1 ] ) - 1 do begin
      for K := 0 to StrToInt( layerSizes[ I ] ) - 1 do
        cacheOutput := cacheOutput + FloatToStr( weights[ I ][ J ][ K ] ) + ' ';
      outputList.Add( cacheOutput );
      cacheOutput := '';
    end;
    outputList.Add( '' );
  end;
  outputList.SaveToFile( pOutputPath + 'weights.txt' );
  outputList.Free;

end;

//-------- Save Network Data (private) -----------------------------------------
procedure TNeuralNetwork.saveNetworkData( pOutputPath : String );

var
  I : Integer;
  outputList : TStringList;

begin

  outputList := TStringList.Create;

  outputList.Add( IntToStr( amountLayers ) );
  for I := 1 to amountLayers do
    outputList.Add( layerSizes[ I - 1 ] );

  outputList.SaveToFile( pOutputPath + 'network_data.txt' );

  outputList.Free;

end;

//-------- Load Network (public) -----------------------------------------------
procedure TNeuralNetwork.loadNetwork( pInputPath : String ); begin

  readNetworkData( pInputPath );
  declareWeightsAndBiases();
  readWeightsAndBiases( pInputPath );

end;

//-------- Read Network Connections (private) ----------------------------------
procedure TNeuralNetwork.readWeightsAndBiases( pInputPath : String );

var
  I, J, K, counter : Integer;
  inputList, cacheDataList : TStringList;

begin

  inputList := TStringList.Create;
  cacheDataList := TStringList.Create;

    //Biases

  inputList.LoadFromFile( pInputPath + 'biases.txt' );

  for I := 0 to inputList.Count - 1 do begin

    Split( ' ', inputList[ I ], cacheDataList ) ;
    for J := 0 to Length( biases[ I ] ) - 1 do
      self.biases[ I ][ J ] := StrToFloat( cacheDataList[ J ] );

  end;

    //Weights
  inputList.LoadFromFile( pInputPath + 'weights.txt' );

  K := 0; I := 0; counter := 0;
  while K < amountLayers - 1 do begin

    if inputList[ counter ] <> '' then begin

    Split( ' ', inputList[ counter ], cacheDataList ) ;
    for J := 0 to Length( weights[ K ][ I ] ) - 1 do
      weights[ K ][ I ][ J ] := StrToFloat( cacheDataList[ J ] );
    inc( I ); inc( counter );

    end else begin
      inc( K ); inc( counter );
      I := 0;
    end;

  end;

  inputList.Free; cacheDataList.Free;

end;

//-------- Read Network Data (private) -----------------------------------------
procedure TNeuralNetwork.readNetworkData( pInputPath : String );

var
  I : Integer;
  inputList : TStringList;

begin

  inputList := TStringList.Create;
  layerSizes := TStringList.Create;
  inputList.LoadFromFile( pInputPath + 'network_data.txt' );

  amountLayers := StrToInt( inputList[ 0 ] );

  for I := 1 to amountLayers do
    layerSizes.Add( inputList[ I ] );

  inputList.Free;

end;



//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Aussage treffen
//+-----------------------------------------------------------------------------

//-------- calculateOutputLayer (public) ---------------------------------------
function TNeuralNetwork.feedForward( pInputLayer : t_vector ) : t_vector;

var
  I : Integer;

begin

  activations[ 0 ] := pInputLayer;
  zActivations[ 0 ] := pInputLayer;

  for I := 1 to amountLayers - 1 do begin
    zActivations[ I ] := addVectorWithVector( multiplyMatrixWithVector( weights[ I - 1 ], activations[ I - 1 ] ), biases[ I - 1 ] );
    activations[ I ] := calculateVectorSigmoid( zActivations[ I ] );
  end;

  result := activations[ Length( activations ) - 1 ];

end;



//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Trainieren
//+-----------------------------------------------------------------------------

//-------- Backprogagation (public) --------------------------------------------
procedure TNeuralNetwork.backpropagateNetwork( pBatchSize : Integer; pRounds : Integer; pDataPath : String );

var
  I, J, K, L, max, counter : Integer;

begin

  loadInputData( pDataPath );

  //max := pRounds * dataInputList.Count;   88799
  max := pRounds * 88799;

  for L := 1 to pRounds do begin

    counter := 0;
    for I := 0 to dataInputList.Count - 1 do begin

      if counter = pBatchSize - 1 then begin
        subtractArray( weights, gradientWeights, pBatchSize );
        subtractArray( biases, gradientBiases, pBatchSize );
        counter := 0;
        resetGradientArrays();                                                               //Durchgang     //Derzeitige Stelle
        writeln( 'Durchgang: ' + IntToStr( L ) + '-' + IntToStr( I ) + ' - ' + FloatToStr ( ( ( L - 1 ) * dataInputList.Count ) + I ) + '/' + FloatToStr( max ) + '-' + FloatToStr( ( ( ( ( L - 1 ) * dataInputList.Count ) + I ) * 100 ) / max ) + '%' );
      end;

      for J := 0 to Length( gradientActivations ) - 1 do
        for K := 0 to Length( gradientActivations[ J ] ) - 1 do
          gradientActivations[ J ][ K ] := 0;

      feedForward( calculateInputActivations( getInputData( I ) ) );

      calculateOutputLayerGradient( Length( activations ) - 1, Length( activations ) - 2 );
      calculateHiddenLayerGradient( Length( activations ) - 2, Length( activations ) - 3 );

      inc( counter );

    end;

  end;

  writeln( 'Das Netzwerk hat ' + IntToStr( pRounds ) + ' Runden Lernen abgeschlossen!' );

end;

//-------- Gradient Descent - OutputLayer (private) ----------------------------
procedure TNeuralNetwork.calculateOutputLayerGradient( pLayerL, pLayerL_1 : Integer );

var
  I, J : Integer;

begin

    //Activations Layer-1
  for I := 0 to Length( activations[ pLayerL_1 ] ) - 1 do
    for J := 0 to Length( activations[ pLayerL ] ) - 1 do
      gradientActivations[ pLayerL_1 ][ I ] :=    gradientActivations[ pLayerL_1 ][ I ] + weights[ pLayerL_1 ][ J ][ I ] * calculateSigmoidPrime( zActivations[ pLayerL ][ J ] ) * ( 2 * ( activations[ pLayerL ][ J ] - expectedOutputVector[ J ] ) );


    //Weights and Biases
  for I := 0 to Length( activations[ pLayerL ] ) - 1 do begin
    for J := 0 to Length( activations[ pLayerL_1 ] ) - 1 do                                
      gradientWeights[ pLayerL - 1 ][ I ][ J ] := gradientWeights[ pLayerL - 1 ][ I ][ J ] +         activations[ pLayerL_1 ][ J ] * calculateSigmoidPrime( zActivations[ pLayerL ][ I ] ) * ( 2 * ( activations[ pLayerL ][ I ] - expectedOutputVector[ I ] ) );
    gradientBiases[ pLayerL - 1][ I ] :=          gradientBiases [ pLayerL - 1 ][ I ]      +                                         calculateSigmoidPrime( zActivations[ pLayerL ][ I ] ) * ( 2 * ( activations[ pLayerL ][ I ] - expectedOutputVector[ I ] ) );
  end;

end;

//-------- Gradient Descent - HiddenLayer (private) ----------------------------
procedure TNeuralNetwork.calculateHiddenLayerGradient( pLayerL, pLayerL_1 : Integer );

var
  I, J : Integer;
  K : Integer;

begin

  for K := layerSizes.Count - 2 downTo 1 do begin

    for I := 0 to Length( activations[ pLayerL_1 ] ) - 1 do
      for J := 0 to Length( activations[ pLayerL ] ) - 1 do
              gradientActivations[ pLayerL_1 ][ I ] := gradientActivations[ pLayerL_1 ][ I ] + gradientActivations[ pLayerL ][ J ] * weights[ pLayerL_1 ][ J ][ I ] * calculateSigmoidPrime( zActivations[ pLayerL ][ J ] );

     {for I := 0 to Length( activations[ pLayerL_1 ] ) - 1 do
      for J := 0 to Length( activations[ pLayerL ] ) - 1 do
        gradientActivations[ pLayerL_1 ][ I ] :=    gradientActivations[ pLayerL_1 ][ I ] + weights[ pLayerL_1 ][ J ][ I ] * calculateSigmoidPrime( zActivations[ pLayerL ][ J ] ) * ( 2 * ( activations[ pLayerL ][ J ] - gradientActivations[ pLayerL ][ J ] ) );
        }

      //Weights and Biases
    for I := 0 to Length( activations[ pLayerL ] ) - 1 do begin
      for J := 0 to Length( activations[ pLayerL_1 ] ) - 1 do
        gradientWeights[ pLayerL_1 ][ I ][ J ] := gradientWeights[ pLayerL_1 ][ I ][ J ]  +  (         activations[ pLayerL_1 ][ J ] * gradientActivations[ pLayerL ][ I ] * calculateSigmoidPrime( zActivations[ pLayerL ][ I ] ) );
      gradientBiases[ pLayerL - 1 ][ I ] :=       gradientBiases[ pLayerL - 1 ][ I ]      +  (                                         gradientActivations[ pLayerL ][ I ] * calculateSigmoidPrime( zActivations[ pLayerL ][ I ] ) );
    end;

    dec( pLayerL );
    dec( pLayerL_1 );

  end;

end;

//-------- Reset Arrays (private) ----------------------------------------------
procedure TNeuralNetwork.resetGradientArrays();

var
  I, J, K : Integer;

begin

  for I := 0 to Length( gradientWeights ) - 1 do
    for J := 0 to Length( gradientWeights[ I ] ) - 1 do
      for K := 0 to Length( gradientWeights[ I ][ J ] ) - 1 do
        gradientWeights[ I ][ J ][ K ] := 0;

  for I := 0 to Length( gradientBiases ) - 1 do
    for J := 0 to Length( gradientBiases[ I ] ) - 1 do
      gradientBiases[ I ][ J ] := 0;

end;



//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Testen
//+-----------------------------------------------------------------------------

//-------- Get Expected Solution (public) --------------------------------------
function TNeuralNetwork.getCurrentSolution( pType : String ) : String;

var
  alphabet : String;

begin

  if UpperCase( pType ) = 'TLETTER' then begin

    alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    result := alphabet[ currentSolution ];

  end else result := IntToStr( currentSolution );

end;

//-------- Get Brightest Neuron (public) ---------------------------------------
function TNeuralNetwork.getOutputSolution( pType : String): String;

var
  I, layerIndex : Integer;
  maxActivation : Real;
  prediction : Integer;
  alphabet : String;

begin

  layerIndex := layerSizes.Count - 1;

  maxActivation := -1; prediction := -1;
  for I := 0 to StrToInt( layerSizes[ amountLayers - 1 ] ) - 1 do begin

    if activations[ layerIndex ][ I ] > maxActivation then begin
      maxActivation := activations[ layerIndex][ I ];
      prediction := I;
    end;

  end;

  if UpperCase( pType ) = 'TLETTER' then begin

    alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    result := alphabet[ prediction ];

  end else result := IntToStr( prediction );

end;

//-------- Average Test Cost (public) ------------------------------------------
function TNeuralNetwork.calculateAverageCost( pStartIndex : Integer; pEndIndex : Integer ): Real;

var
  I : Integer;
  cacheAverage : Real;

begin

  cacheAverage := 0;
  for I := pStartIndex to pEndIndex do begin
    cacheAverage := cacheAverage + calculateCost( feedForward( calculateInputActivations( getInputData( I ) ) ) );
    //writeLn( 'Cost: ' + IntToStr( I ) + '-' + FloatToStr( cacheAverage / I ) );
  end;

  result := cacheAverage / ( pEndIndex - pStartIndex );

end;

//-------- Average Hit rate (public) -------------------------------------------
function TNeuralNetwork.calculateHitRate( pStartIndex : Integer; pEndIndex : Integer ) : Real;

var
  I, correct : Integer;

begin

  correct := 0;
  for I := pStartIndex to pEndIndex do begin
    feedForward( calculateInputActivations( getInputData( I ) ) );
    if StrToInt( getCurrentSolution( 'TNumber' ) ) = StrToInt( getOutputSolution( 'TNumber' ) ) then
      inc( correct );
    //writeLn( 'Rate: ' + IntToStr( I ) + '-' + IntToStr( correct ) + '/' + IntToStr( I ) );
  end;

  result := 100 * ( correct / ( pEndIndex - pStartIndex ) )

end;

//-------- Single Test Cost (private) ------------------------------------------
function TNeuralNetwork.calculateCost( pOutputLayer : t_vector ) : Real;

var
  I : Integer;
  cost : Real;

begin

  cost := 0;
  for I := 0 to Length( pOutputLayer ) - 1 do
    cost := cost + sqr( pOutputLayer[ I ] - expectedOutputVector[ I ] );

  result := cost;

end;



//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Datenbasis
//+-----------------------------------------------------------------------------

//-------- Read Input Data Line (public) ---------------------------------------
function TNeuralNetwork.getInputData( pIndex : Integer ) : String; begin

  result := dataInputList.Strings[ pIndex ];

end;

//-------- Load Database (public) ----------------------------------------------
procedure TNeuralNetwork.loadInputData( pInputPath : String ); begin

  if dataInputList = nil then begin
    dataInputList := TStringList.Create;
    dataInputList.LoadFromFile( pInputPath );
  end;

end;

//-------- Interpret Greyvalue (public) ----------------------------------------
function TNeuralNetwork.calculateInputActivations( pInputString : String ) : t_vector;

var
  I : Integer;
  cacheDataList : TStringList;
  outputVector : t_vector;

const
  baseValue = 255;

begin

  cacheDataList := TStringList.Create;

  Split( ',', pInputString, cacheDataList ) ;
  self.currentSolution := StrToInt( cacheDataList[ 0 ] );
  setLength( outputVector, cacheDataList.Count - 1 );

  for I := 0 to Length( expectedOutputVector ) - 1 do
    if I = currentSolution then
      self.expectedOutputVector[ I ] := 1
    else
      self.expectedOutputVector[ I ] := 0;

  for I := 1 to cacheDataList.Count - 1 do
    if ( StrToInt( cacheDataList[ I ] ) <> 0 ) then
      outputVector[ I - 1 ] := StrToInt( cacheDataList[ I ] ) / baseValue
    else outputVector[ I - 1 ] := 0.0;

  result := outputVector;

  cacheDataList.Free;

end;

//-------- Greyvalue to Bitmap (public) ----------------------------------------
function TNeuralNetwork.getBitmapFromPixel( pInputSize : Integer; pIndex : Integer; pDataPath : String ) : TBitmap;

var
  picture : TBitmap;
  I, J : Integer;
  input : String;
  inputList : TStringList;
  colorValue, counter : Integer;

begin

  loadInputData( pDataPath);

  picture := TBitmap.Create;
  picture.SetSize( pInputSize, pInputSize );

  input := getInputData( pIndex  );
  inputList := TStringList.Create;

  Split( ',', input, inputList ) ;

  counter := 1;
  for I := 0 to pInputSize - 1 do
    for J := 0 to pInputSize - 1 do begin
      colorValue := 255 - StrToInt( inputList[ counter ] );
      picture.Canvas.Pixels[ I, J ] := TColor( RGB( colorValue, colorValue, colorValue ) );
      inc( counter );
    end;
  inputList.Free;

  result := picture;

end;



//+-----------------------------------------------------------------------------
//|         NeuralNetwork: Berechnungsoperationen
//+-----------------------------------------------------------------------------

//-------- String Splitter (private) -------------------------------------------
procedure TNeuralNetwork.Split( pDelimiter: Char; pInputStr: String; pOutputList: TStrings ) ; begin

   pOutputList.Clear;
   pOutputList.Delimiter       := pDelimiter;
   pOutputList.StrictDelimiter := True;
   pOutputList.DelimitedText   := pInputStr;

end;

//-------- multiply Matrix-Vector (private) ------------------------------------
function TNeuralNetwork.multiplyMatrixWithVector( pWeightMatrix : t_matrix; pActivationVector : t_vector ) : t_vector;

var
  I, J : Integer;
  multiVector : t_vector;

begin

  setLength( multiVector, Length( pWeightMatrix ) );

  for I := 0 to Length( pWeightMatrix ) - 1 do
    for J := 0 to Length( pWeightMatrix[ I ] ) - 1 do
      multiVector[ I ] := multiVector[ I ] + ( pActivationVector[ J ] * pWeightMatrix[ I ][ J ] );

  result := multiVector;

end;

//-------- add Vector-Vector (private) -----------------------------------------
function TNeuralNetwork.addVectorWithVector( pActivationVector, pBiasVector : t_vector ) : t_vector;

var
  I, arrayDimension : Integer;
  addVector : t_vector;

begin

  arrayDimension :=  Length( pActivationVector );
  setLength( addVector, arrayDimension );

  for I := 0 to arrayDimension - 1 do
    addVector[ I ] := pActivationVector[ I ] + pBiasVector[ I ];

  result := addVector;

end;

//-------- Subtract 3D Array (private) -----------------------------------------
function TNeuralNetwork.subtractArray( p3DArray1 : t_array3d; p3DArray2 : t_array3d; pBatchSize : Integer ) : t_array3d;

var
  I, J, K : Integer;

begin

  for I := 0 to Length( p3DArray1 ) - 1 do
    for J := 0 to Length( p3DArray1[ I ] ) - 1 do
      for K := 0 to Length( p3DArray1[ I ][ J ] ) - 1 do
        p3DArray1[ I ][ J ][ K ] := p3DArray1[ I ][ J ][ K ] - ( p3DArray2[ I ][ J ][ K ] / pBatchSize );

  result := p3DArray1;

end;

//-------- Subtract Matrix (private) -------------------------------------------
function TNeuralNetwork.subtractArray( pMatrix1 : t_matrix; pMatrix2 : t_matrix; pBatchSize : Integer ) : t_matrix;

var
  I, J : Integer;

begin

  for I := 0 to Length( pMatrix1 ) - 1 do
    for J := 0 to Length( pMatrix1[ I ] ) - 1 do
      pMatrix1[ I ][ J ] := pMatrix1[ I ][ J ] - ( pMatrix2[ I ][ J ]  / pBatchSize );

  result := pMatrix1;

end;

//-------- Sigmoid Vector (private) --------------------------------------------
function TNeuralNetwork.calculateVectorSigmoid( pVector : t_vector ) : t_vector;

var
  I, arrayDimension : Integer;
  sigVector : t_vector;

begin

  arrayDimension :=  Length( pVector );
  setLength( sigVector, arrayDimension );

  for I := 0 to arrayDimension - 1 do
    sigVector[ I ] := calculateSigmoid( pVector[ I ] );

  result := sigVector;

end;

//-------- Sigmoid function (private) ------------------------------------------
function TNeuralNetwork.calculateSigmoid( pActivation : extended ) : extended; begin

  result := 1 / ( 1 + Exp( -pActivation ) );

end;

//-------- Sigmoid function Derivative (private) -------------------------------
function TNeuralNetwork.calculateSigmoidPrime( pActivation : extended ) : extended; begin

  result := calculateSigmoid( pActivation ) * ( 1 - calculateSigmoid( pActivation ) );

end;


end.
