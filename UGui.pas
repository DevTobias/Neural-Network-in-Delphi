unit UGui;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.UITypes, Vcl.ExtCtrls, Vcl.Menus,
  UNeuralNetwork, UVector, UReader;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Button3: TButton;
    Label1: TLabel;
    Label4: TLabel;
    Button4: TButton;
    Label5: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    Index1: TMenuItem;
    Commands1: TMenuItem;
    Procedures1: TMenuItem;
    Keyboard1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    Tutorial1: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    About1: TMenuItem;
    Edit2: TEdit;
    Button5: TButton;
    Edit3: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  end;

var
  Form1: TForm1;
  network : TNeuralNetwork;
  layerLengths : TStringList;
  inputImageList : UReader.t_letter_list;

const
  //dataBase = 'Ressourcen/Database/mnist_train.csv';
  dataBase = 'Ressourcen/Database/emnist-letters-train.csv';

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject); begin

  network.backpropagateNetwork( 50, StrToInt( Edit2.Text ), dataBase );
  network.saveNetwork( 'Ressourcen/Network/' );

end;

procedure fillListBox();

var
  outputArray : UVector.t_vector;
  I : Integer;
  alphabet : String;

begin

  alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  outputArray := network.feedForward( network.calculateInputActivations( network.getInputData( StrToInt( Form1.Edit1.Text ) ) ) );
  for I := 0 to Length( outputArray ) - 1 do
    Form1.ListBox1.Items.Add( alphabet[ I + 1 ] + '-' + FloatToStr( outputArray[ I ] ) );


  Form1.Label3.Caption := 'Output: ' + network.getOutputSolution( 'TLetter' );
  Form1.Label5.Caption := 'True Output: ' + network.getCurrentSolution( 'TLetter' );

end;

procedure TForm1.Button2Click(Sender: TObject); begin

  network.loadInputData( dataBase );
  ListBox1.Clear;

  image1.Picture.Bitmap.SetSize( 100, 100 );
  image1.Canvas.StretchDraw( Rect( 0, 0, 100, 100 ), network.getBitmapFromPixel( 28, StrToInt( Edit1.Text), dataBase ) );

  fillListBox();

end;

procedure TForm1.Button3Click(Sender: TObject); begin

  network.loadInputData( dataBase );
  Label1.Caption := 'Sicherheit: ' + FloatToStr( network.calculateHitRate( 0, 88799 ) ) + '%' ;
  Label4.Caption := 'Quallität: ' + FloatToStr( network.calculateAverageCost( 0, 88799 ) );

end;

procedure TForm1.Button4Click(Sender: TObject); begin

  network.saveNetwork( 'Ressourcen/Network/' );

end;




//+-----------------------------------------------------------------------------
//|         Scanner
//+-----------------------------------------------------------------------------

procedure TForm1.Button5Click(Sender: TObject);

var
  reader : TReader;

begin

  reader := TReader.Create( 'Ressourcen/Inputs/test.jpeg' );
  reader.ResizePicture( 100, 100 );
  //reader.improveQuality( StrToInt( Edit3.Text ) );
  reader.improveQuality( 200 );
  reader.savePicture( 'Ressourcen/Inputs/test_out.jpeg' );
  reader.splitPicture;
  reader.ResizeLetterList( 28, 28 );
  reader.savePictureInDatabase( 'Ressourcen/Inputs/databse.txt' );

  image1.Picture.Bitmap.SetSize( 100, 100 );
  image1.Canvas.StretchDraw( Rect( 0, 0, 100, 100 ), network.getBitmapFromPixel( 28, 0, 'Ressourcen/Inputs/databse.txt' ) );


end;




//+-----------------------------------------------------------------------------
//|         GUI
//+-----------------------------------------------------------------------------

procedure TForm1.FormCreate(Sender: TObject);

//var
  //inputArray : UNeuralNetwork.t_vector;

begin

  Button1.Caption := 'Trainieren';
  Button2.Caption := 'Bestimmen';
  Button3.Caption := 'Testen';
  Button4.Caption := 'Speichern';
  Edit1.Clear;
  Edit2.Clear;

  layerLengths := TStringList.Create;
  layerLengths.add( '784' );
  layerLengths.add( '75' );
  layerLengths.add( '75' );
  layerLengths.add( '26' );

  {layerLengths.add( '1' );
  layerLengths.add( '2' );
  layerLengths.add( '2' );
  layerLengths.add( '2' ); }

  network := TNeuralNetwork.Create( layerLengths );
  //network := TNeuralNetwork.Create( 'Ressourcen/Network/' );

  AllocConsole;
  //writeln('Network correctly initialized!');

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction); begin

  layerlengths.Free;
  network.Free;

end;

end.
