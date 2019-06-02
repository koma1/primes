unit PrimesSieve;

interface

type
  TNumberAlias = Cardinal; //Cardinal compatible with D7, else must be - NativeUInt - compiler depended size (x32 or x64) or partial arrays in sieve for UInt64
  TPrimesSieve = class
  private
    FSieve: array of Boolean;
    FCurrent: TNumberAlias;
    FSize: TNumberAlias;
  public
    constructor Create(ASize: TNumberAlias);
    destructor Destroy; override;

    function GetNext(out ANumber: TNumberAlias): Boolean;
  end;

implementation

{ TPrimesSieve }

constructor TPrimesSieve.Create(ASize: TNumberAlias);
var
  l, k: TNumberAlias;
begin
  FCurrent := 1;
  FSize := ASize;

  SetLength(FSieve, FSize - 1);

  k := 2;
  while (FSize >= (k * k)) do
  begin
    if not FSieve[k] then
    begin
      l := k * k;
      while FSize >= l do
      begin
        FSieve[l] := True;
        l := l + k;
      end;
    end;

    Inc(k);
  end;
end;

destructor TPrimesSieve.Destroy;
begin
  FSieve := nil;

  inherited;
end;

function TPrimesSieve.GetNext(out ANumber: TNumberAlias): Boolean;
begin
  while (FCurrent < FSize) do
  begin
    Inc(FCurrent);
    if not FSieve[FCurrent] then
    begin
      ANumber := FCurrent;
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

end.
