program primes_con;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Math,
  Windows,
  PrimesSieve in 'PrimesSieve.pas',
  WriterThread in 'WriterThread.pas';

const
  EndValue = 1000000;

var
  PrimesPool: TPrimesWriterController;
  Ticks: Cardinal;

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    Ticks := GetTickCount;
    PrimesPool := TPrimesWriterController.Create(1000000, 2, 'Result.txt');
    try
      WriteLn(Format('Started at %s', [TimeToStr(Now)]));
      WriteLn('=======================');
      while PrimesPool.Working do
      begin
        Sleep(2000);
        Write('Working... ');
      end;
    finally
      PrimesPool.Free;
    end;
    WriteLn;
    WriteLn('=======================');
    WriteLn(Format('Finished at %s (%d ms)', [TimeToStr(Now),
      GetTickCount - Ticks]));

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Readln;
end.
