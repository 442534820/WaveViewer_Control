unit WaveViewer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Contnrs,
  Vcl.Graphics,
  Vcl.Controls;

type
  TBaseLineStyle = (blsCustom, blsTop, blsBottom, blsMid);
  TWaveViewMode = (wvmCover, wvmRoll);

  TWaveViewer = class;

  TWaveLine = class(TComponent)
  private
    FColor: TColor;
    FWaveViewMode: TWaveViewMode;
    FVisable: Boolean;
    procedure SetColor(Value: TColor);
    procedure SetWaveViewMode(Value: TWaveViewMode);
    procedure SetVisable(Value: Boolean);
    procedure SetWaveLength(Value: Integer);
  protected
  public
    BaseMarkVisable: Boolean;
    Order: Integer;
    ValueOfXGrid: Integer;
    ValueOfYGrid: Single;
    Datas: array of Single;
    Points: array of TPoints;
    DataLength: Integer;
    CurrentPoint: Integer;
    Parent: TWaveViewer;
    procedure AddData(Value: Single);
    procedure UpdatePoints;
    constructor Create(AOwner: TWaveViewer); overload;
    constructor Create(AOwner: TWaveViewer; Len: Integer); overload;
    procedure Paint;
  published
    property Color: TColor read FColor write SetColor;
    property WaveViewMode: TWaveViewMode read FWaveViewMode write SetWaveViewMode;
    property Visable: Boolean read FVisable write SetVisable default True;
  end;

  TWaveLineList = class(TComponentList)
  private
  protected
    function GetItem(Index: Integer): TWaveLine; inline;
    procedure SetItem(Index: Integer; AObject: TWaveLine); inline;
  public
    constructor Create(AOwnsObjects: Boolean);

    function Add(AComponent: TWaveLine): Integer; inline;
    function Remove(AComponent: TWaveLine): Integer; inline;
    function RemoveItem(AComponent: TWaveLine; ADirection: TList.TDirection): Integer; inline;
    function IndexOf(AComponent: TWaveLine): Integer; inline;
    function IndexOfItem(AComponent: TWaveLine; ADirection: TList.TDirection): Integer; inline;
    function First: TWaveLine; inline;
    function Last: TWaveLine; inline;
    procedure Insert(Index: Integer; AComponent: TWaveLine); inline;
    property Items[Index: Integer]: TWaveLine read GetItem write SetItem;
  published
  end;

  TWaveViewer = class(TGraphicControl)
  private
    FWaveLineList: TWaveLineList;
    FGridVisable: Boolean;
    FXGridSize: Integer;
    FYGridSize: Integer;
    FWaveRect: TRect;
    FBaseLineVisable: Boolean;
    FBaseLineStyle: TBaseLineStyle;
    xBase: Integer;
    yBase: Integer;
    procedure UpdateBase;
    procedure DrawGrid;
    procedure DrawBaseLine;
    procedure DrawFrame;
    procedure DrawWave;
    procedure UpdateDataPoints;
    procedure DrawCursor;
    procedure SetGridVisable(Value: Boolean);
    procedure SetXGridSize(Value: Integer);
    procedure SetYGridSize(Value: Integer);
    procedure SetBaseLineVisable(Value: Boolean);
    procedure SetBaseLineStyle(Value: TBaseLineStyle);
    procedure SetWaveLineList(Value: TWaveLineList);
    protected
    procedure Paint; override;
  public
    procedure AttachWaveLine(AWaveLine: TWaveLine);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;
  published
    property GridVisable: Boolean read FGridVisable write SetGridVisable default True;
    property XGridSize: Integer read FXGridSize write SetXGridSize default 20;
    property YGridSize: Integer read FYGridSize write SetYGridSize default 20;
    property BaseLineVisable: Boolean read FBaseLineVisable write SetBaseLineVisable default True;
    property BaseLineStyle: TBaseLineStyle read FBaseLineStyle write SetBaseLineStyle default blsMid;
    property WaveLineItems: TWaveLineList read FWaveLineList write SetWaveLineList;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;


procedure Register;

implementation

procedure register;
begin
  RegisterComponents('CloudControl', [TWaveViewer]);
  RegisterComponents('CloudControl', [TWaveLine]);
end;


{ TWaveViewer }


procedure TWaveViewer.AttachWaveLine(AWaveLine: TWaveLine);
begin
  FWaveLineList.Add(AWaveLine);
end;

constructor TWaveViewer.Create(AOwner: TComponent);
begin
  inherited;
  FGridVisable := True;
  BaseLineVisable := True;
  BaseLineStyle := blsMid;
  FXGridSize := 20;
  FYGridSize := 20;
  FWaveLineList := TWaveLineList.Create(True);
end;

destructor TWaveViewer.Destroy;
begin
  FWaveLineList.Free;
end;

procedure TWaveViewer.DrawBaseLine;
begin
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(xBase, yBase);
  Canvas.LineTo(FWaveRect.Right-1, yBase);
end;

procedure TWaveViewer.DrawCursor;
begin

end;

procedure TWaveViewer.DrawFrame;
begin
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Style := psSolid;
  Canvas.MoveTo(0,0);
  Canvas.LineTo(Width-1, 0);
  Canvas.LineTo(Width-1, Height-1);
  Canvas.LineTo(0, Height-1);
  Canvas.LineTo(0, 0);
  Canvas.MoveTo(FWaveRect.Left, FWaveRect.Top);
  Canvas.LineTo(FWaveRect.Right, FWaveRect.Top);
  Canvas.LineTo(FWaveRect.Right, FWaveRect.Bottom);
  Canvas.LineTo(FWaveRect.Left, FWaveRect.Bottom);
  Canvas.LineTo(FWaveRect.Left, FWaveRect.Top);
end;

procedure TWaveViewer.DrawGrid;
var
  x, y: Integer;
  xStep, yStep: Integer;
  xSize, ySize : Integer;
begin
  Canvas.Pen.Color := clGray;
  //Draw Up
  xStep := FXGridSize;
  yStep := FYGridSize;
  Canvas.Pen.Style := psDot;
  y := yBase - yStep;
  while y >= FWaveRect.Top do
  begin
    Canvas.MoveTo(xBase, y);
    Canvas.LineTo(FWaveRect.Right-1, y);
    y := y - yStep;
  end;
  //Draw Down
  y := yBase + yStep;
  while y <= FWaveRect.Bottom-1 do
  begin
    Canvas.MoveTo(xBase, y);
    Canvas.LineTo(FWaveRect.Right-1, y);
    y := y + yStep;
  end;
  //X A
  x := xBase + xStep;
  while x <= FWaveRect.Right-1 do
  begin
    Canvas.MoveTo(x, FWaveRect.Top);
    Canvas.LineTo(x, FWaveRect.Bottom-1);
    x := x + xStep;
  end;
end;

procedure TWaveViewer.DrawWave;
begin

end;

procedure TWaveViewer.Paint;
var
  i: Integer;
begin
  inherited;

  FWaveRect.Left := 40;
  FWaveRect.Top := 20;
  FWaveRect.Width := Self.Width - 80;
  FWaveRect.Height := Self.Height - 40;
  UpdateBase;
  if FGridVisable then
  begin
    DrawGrid;
  end;
  if FBaseLineVisable then
  begin
    DrawBaseLine;
  end;
  DrawFrame;
  for i := 0 to FWaveLineList.Count-1 do
  begin
    FWaveLineList.Items[i].Paint;
  end;
end;

procedure TWaveViewer.SetBaseLineStyle(Value: TBaseLineStyle);
begin
  if FBaseLineStyle <> Value then
  begin
    FBaseLineStyle := Value;
    Invalidate;
  end;
end;

procedure TWaveViewer.SetBaseLineVisable(Value: Boolean);
begin
  if FBaseLineVisable <> Value then
  begin
    FBaseLineVisable := Value;
    Invalidate;
  end;
end;

procedure TWaveViewer.SetGridVisable(Value: Boolean);
begin
  if FGridVisable <> Value then
  begin
    FGridVisable := Value;
    Invalidate;
  end;
end;

procedure TWaveViewer.SetWaveLineList(Value: TWaveLineList);
begin

end;

procedure TWaveViewer.SetXGridSize(Value: Integer);
begin
  if FXGridSize <> Value then
  begin
    FXGridSize := Value;
    Invalidate;
  end;
end;

procedure TWaveViewer.SetYGridSize(Value: Integer);
begin
  if FYGridSize <> Value then
  begin
    FYGridSize := Value;
    Invalidate;
  end;
end;

procedure TWaveViewer.UpdateBase;
begin
  xBase := FWaveRect.Left;
  case FBaseLineStyle of
    blsCustom: yBase := 0 ;
    blsTop: yBase := FWaveRect.Top;
    blsBottom: yBase := FWaveRect.Bottom;
    blsMid: yBase := FWaveRect.Top + FWaveRect.Height div 2;
  end;
end;

procedure TWaveViewer.UpdateDataPoints;
begin

end;


{ TWaveLine }

procedure TWaveLine.AddData(Value: Single);
begin
  Datas[CurrentPoint] := Value;
  CurrentPoint := CurrentPoint + 1;
  if CurrentPoint >= DataLength then
  begin
    CurrentPoint := 0;
  end;
end;

constructor TWaveLine.Create(AOwner: TWaveViewer);
begin
  Parent := AOwner;
  Visable := True;
end;

constructor TWaveLine.Create(AOwner: TWaveViewer; Len: Integer);
begin
  Create(AOwner);
  SetWaveLength(Len);
  AOwner.AttachWaveLine(Self);
end;

procedure TWaveLine.Paint;
var
  i : Integer;
begin
  if FVisable then
  begin
    UpdatePoints;
    with Parent.Canvas do
    begin
      Pen.Color := FColor;
      Pen.Style := psSolid;
      MoveTo(Points[0].X, Points[0].Y);
      for i := 0 to DataLength-1 do
      begin
        LineTo(Points[i].X, Points[i].Y);
      end;
    end;
  end;
end;

procedure TWaveLine.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
  end;
  Parent.Invalidate;
end;

procedure TWaveLine.SetVisable(Value: Boolean);
begin
  if Value <> FVisable then
  begin
    FVisable := Value;
    Parent.Invalidate;
  end;
end;

procedure TWaveLine.SetWaveLength(Value: Integer);
begin
  SetLength(Datas, Value);
  SetLength(Points, Value);
  ZeroMemory(Datas, Sizeof(Datas));
  ZeroMemory(Points, Sizeof(Points));
  CurrentPoint := 0;
  DataLength := Value;
end;

procedure TWaveLine.SetWaveViewMode(Value: TWaveViewMode);
begin
  if Value <> FWaveViewMode then
  begin
    FWaveViewMode := Value;
  end;
end;

procedure TWaveLine.UpdatePoints;
var
  i : Integer;
begin
  //TODO: do optimization avoid over calculation
  for i := 0 to DataLength-1 do
  begin
    Points[i].X := Parent.xBase + Round(i * Parent.XGridSize / ValueOfXGrid);
    Points[i].Y := Parent.yBase - Round(Datas[i] * Parent.YGridSize / ValueOfYGrid);
  end;
end;

{ TWaveLineList }

function TWaveLineList.Add(AComponent: TWaveLine): Integer;
begin
  Result := inherited Add(AComponent);
end;

constructor TWaveLineList.Create(AOwnsObjects: Boolean);
begin
  inherited;

end;

function TWaveLineList.First: TWaveLine;
begin
  Result := inherited First as TWaveLine;
end;

function TWaveLineList.GetItem(Index: Integer): TWaveLine;
begin
  Result := inherited Items[Index] as TWaveLine;
end;

function TWaveLineList.IndexOf(AComponent: TWaveLine): Integer;
begin
  Result := inherited IndexOf(AComponent);
end;

function TWaveLineList.IndexOfItem(AComponent: TWaveLine;
  ADirection: TList.TDirection): Integer;
begin
  Result := inherited IndexOfItem(AComponent, ADirection);
end;

procedure TWaveLineList.Insert(Index: Integer; AComponent: TWaveLine);
begin
  inherited Insert(Index, AComponent);
end;

function TWaveLineList.Last: TWaveLine;
begin
  Result := inherited Last as TWaveLine;
end;

function TWaveLineList.Remove(AComponent: TWaveLine): Integer;
begin
  Result := inherited Remove(AComponent);
end;

function TWaveLineList.RemoveItem(AComponent: TWaveLine;
  ADirection: TList.TDirection): Integer;
begin
  Result := inherited RemoveItem(AComponent, ADirection);
end;

procedure TWaveLineList.SetItem(Index: Integer; AObject: TWaveLine);
begin
  inherited Items[Index] := AObject;
end;

end.
