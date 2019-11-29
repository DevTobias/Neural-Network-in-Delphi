program neuralnetwork;

uses
  Vcl.Forms,
  UGui in 'UGui.pas',
  UNeuralNetwork in 'UNeuralNetwork.pas',
  UVector in 'UVector.pas',
  UReader in 'UReader.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
