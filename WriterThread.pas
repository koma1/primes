unit WriterThread;

interface

uses
  SysUtils,
  Classes,
  SyncObjs,
  PrimesSieve;

type
  TPrimesWriterController = class
  private
    FSieve: TPrimesSieve;
    FThreads: TList;
    FFileStream: TFileStream;
    FCS: TCriticalSection;
    procedure ReleaseThread(Thread: TThread);
    function GetWorking: Boolean;
  public
    constructor Create(
      const AMaxValue: TNumberAlias = 1000000;
      const AThreadCount: Integer = 2;
      const AGeneralFileName: string = 'Result.txt');
    destructor Destroy; override;

    property Working: Boolean read GetWorking;
  end;

implementation

type
  TPrimesWriterThread = class(TThread)
  private
    FPool: TPrimesWriterController;
    FFileStream: TFileStream;
  protected
    procedure Execute; override;
  public
    constructor Create(const APool: TPrimesWriterController;
      const APersonalFileName: string);
    destructor Destroy; override; //1) remove it from pool list; 2) close personal file
  end;

{ TPrimesWriter }

constructor TPrimesWriterThread.Create(const APool: TPrimesWriterController;
  const APersonalFileName: string);
begin
  inherited Create(True); //suspended
  FreeOnTerminate := True;

  FPool := APool;
  FFileStream := TFileStream.Create(APersonalFileName, fmCreate);

  Resume; //depreacated, but compatible with D7
end;

destructor TPrimesWriterThread.Destroy;
begin
  FPool.ReleaseThread(Self); //notify pool about destruction

  FFileStream.Free;

  inherited;
end;

procedure TPrimesWriterThread.Execute;
var
  LValue: TNumberAlias;
  LStr: AnsiString;
  LRes: Boolean;
begin
  while (not Terminated) do
  begin
    FPool.FCS.Acquire;
    try
      LRes := FPool.FSieve.GetNext(LValue);
      if LRes then //GENERAL Log
      begin
        LStr := AnsiString(UIntToStr(UInt64(LValue)) + ' ');
        FPool.FFileStream.Write(LStr[1], Length(LStr));
      end;
    finally
      FPool.FCS.Release;
    end;

    if LRes then
      FFileStream.Write(LStr[1], Length(LStr)) //Personal log
    else
      Terminate; //finalize work correctly
  end;
end;

{ TPrimesWriterPool }

constructor TPrimesWriterController.Create(const AMaxValue: TNumberAlias;
  const AThreadCount: Integer; const AGeneralFileName: string);
var
  I: Integer;
begin
  FThreads := TList.Create;
  FSieve := TPrimesSieve.Create(AMaxValue);
  FFileStream := TFileStream.Create(AGeneralFileName, fmCreate);
  FCS := TCriticalSection.Create;

  for I := 1 to AThreadCount do
    FThreads.Add(TPrimesWriterThread.Create(Self, Format('thread%d.txt', [I])));
end;

procedure TPrimesWriterController.ReleaseThread(Thread: TThread);
var
  LIndex: Integer;
begin
  FCS.Acquire;
  try
    LIndex := FThreads.IndexOf(Thread);
    if LIndex >= 0 then
      FThreads.Delete(LIndex);
  finally
    FCS.Release;
  end;
end;

destructor TPrimesWriterController.Destroy;
var
  I: Integer;
begin
  for I := 0 to FThreads.Count - 1 do
    TThread(FThreads[I]).Terminate; //completing destruct sequences: TThread.Terminate -> TThread.Free(FreeOnTerminate = True) -> TPrimesWriterPool.ReleaseThread - remove from list

  while FThreads.Count > 0 do
    Sleep(100); //waiting while threads terminating

  FreeAndNil(FThreads);

  FSieve.Free;
  FFileStream.Free;
  FCS.Free;

  inherited;
end;

function TPrimesWriterController.GetWorking: Boolean;
begin
  Result := FThreads.Count > 0;
end;

end.
