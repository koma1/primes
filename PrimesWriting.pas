unit PrimesWriting;

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
    procedure TerminateThreads;
    procedure ReleaseThread(Thread: TThread);
    function GetWorking: Boolean;
  public
    constructor Create(const AMaxValue: TNumberAlias;
      const AThreadCount: Integer;
      const AGeneralFileName: string);
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
  FFileStream := TFileStream.Create(APersonalFileName, fmCreate);
  FPool := APool;

  inherited Create;
  FreeOnTerminate := True;
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
  try
    FFileStream := TFileStream.Create(AGeneralFileName, fmCreate);
    FSieve := TPrimesSieve.Create(AMaxValue);
    FThreads := TList.Create;
    FCS := TCriticalSection.Create;
  except
    FFileStream.Free;
    FThreads.Free;
    FSieve.Free;
    FCS.Free;

    raise;
  end;

  try
    for I := 1 to AThreadCount do
      FThreads.Add(TPrimesWriterThread.Create(Self, Format('thread%d.txt', [I])));
  except //when excepted, we will terminate threads created before
    TerminateThreads;
    raise;
  end;
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

procedure TPrimesWriterController.TerminateThreads;
var
  I: Integer;
begin
  for I := 0 to FThreads.Count - 1 do
    TThread(FThreads[I]).Terminate; //completing destruct sequences: TThread.Terminate -> TThread.Free(FreeOnTerminate = True) -> TPrimesWriterPool.ReleaseThread - remove from list

  while FThreads.Count > 0 do
    Sleep(100); //waiting while threads terminating
end;

destructor TPrimesWriterController.Destroy;
begin
  TerminateThreads;

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
