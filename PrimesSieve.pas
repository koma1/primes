unit PrimesSieve;

interface

type
  TNumberAlias = UInt64; //64-bit not signed integer
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

  SetLength(FSieve, FSize + 1);

  for k := 2 to FSize do
    FSieve[k] := True;

  k := 2;
  while (FSize >= (k * k)) do
  begin
    if FSieve[k] then
    begin
      l := k * k;
      while FSize >= l do
        begin
          FSieve[l] := False;
          l := l + k;
        end ;
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
  while (FCurrent <= FSize) do
  begin
    Inc(FCurrent);
    if FSieve[FCurrent] then
    begin
      ANumber := FCurrent;
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

end.
