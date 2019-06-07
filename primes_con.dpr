program primes_con;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Math,
  Windows,

  PrimesSieve in 'PrimesSieve.pas',
  PrimesWriting in 'PrimesWriting.pas';

const //CONFIGURATION
  EndValue = 1000000;
  ThreadCount = 2;
  ResultFileName = 'Result.txt';

var
  PrimesWriter: TPrimesWriterController;
  Ticks: Cardinal;

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    Ticks := GetTickCount;
    PrimesWriter := TPrimesWriterController.Create(EndValue, ThreadCount,
      ResultFileName);
    try
      WriteLn(Format('Started at %s', [TimeToStr(Now)]));
      WriteLn('=======================');
      while PrimesWriter.Working do
      begin
        Sleep(2000);
        Write('Working... ');
      end;
    finally
      PrimesWriter.Free;
    end;
    WriteLn;
    WriteLn('=======================');
    WriteLn(Format('Finished at %s (%d ms)', [TimeToStr(Now),
      GetTickCount - Ticks]));

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
