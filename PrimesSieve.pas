unit PrimesSieve;

interface

type
  TNumberValue = Cardinal; //Cardinal compatible with D7, else must be - NativeUInt - compiler depended size (x32 or x64) or partial arrays in sieve for UInt64
  TPrimesSieve = class
  private
    FSieve: array of Boolean;
    FCurrent: TNumberValue;
    FSize: TNumberValue;
  public
    constructor Create(ASize: TNumberValue);
    function GetNext(out ANumber: TNumberValue): Boolean;
  end;

implementation

{ TPrimesSieve }

constructor TPrimesSieve.Create(ASize: TNumberValue);
var
  l, k: TNumberValue;
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

function TPrimesSieve.GetNext(out ANumber: TNumberValue): Boolean;
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
