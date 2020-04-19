unit WaveViewer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Contnrs,
  Vcl.Graphics,
  Vcl.Controls;

type
  TWaveViewer = class;
  TWaveLine = class;

  TCursorOrientation = (cuHorizontal, cuVertical);
  TCursorViewMode = (cvmSimple, cvmFull);

  TWaveCursor = class(TComponent)
  private
    FColor: TColor;
    FLineStyle: TPenStyle;
    FOrientation: TCursorOrientation;
    FParent: TWaveLine;
    FVisable: Boolean;
    FViewMode: TCursorViewMode;
    FPosition: Integer;
    procedure SetColor(Value: TColor);
    procedure SetLineStyle(Value: TPenStyle);
    procedure SetOrientation(Value: TCursorOrientation);
    procedure SetParent(Value: TWaveLine);
    procedure SetVisable(Value: Boolean);
    procedure SetViewMode(Value: TCursorViewMode);
    procedure SetPosition(Value: Integer);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint;
  published
    property Color: TColor read FColor write SetColor;
    property LineStyle: TPenStyle read FLineStyle write SetLineStyle default psDash;
    property Orientation: TCursorOrientation read FOrientation write SetOrientation;
    property Parent: TWaveLine read FParent write SetParent;
    property Visable : Boolean read FVisable write SetVisable default True;
    property ViewMode: TCursorViewMode read FViewMode write SetViewMode default cvmFull;
    property Position: Integer read FPosition write SetPosition;
  end;

  TWaveCursorList = class(TComponentList)
  private
  protected
    function GetItem(Index: Integer): TWaveCursor; inline;
    procedure SetItem(Index: Integer; AObject: TWaveCursor); inline;
  public
    constructor Create(AOwnsObjects: Boolean);

    function Add(AComponent: TWaveCursor): Integer; inline;
    function Remove(AComponent: TWaveCursor): Integer; inline;
    function RemoveItem(AComponent: TWaveCursor; ADirection: TList.TDirection): Integer; inline;
    function IndexOf(AComponent: TWaveCursor): Integer; inline;
    function IndexOfItem(AComponent: TWaveCursor; ADirection: TList.TDirection): Integer; inline;
    function First: TWaveCursor; inline;
    function Last: TWaveCursor; inline;
    procedure Insert(Index: Integer; AComponent: TWaveCursor); inline;
    property Items[Index: Integer]: TWaveCursor read GetItem write SetItem;
  published
  end;

  TWaveViewMode = (wvmCover, wvmRoll);

  TWaveLine = class(TComponent)
  private
    FColor: TColor;
    FWaveViewMode: TWaveViewMode;
    FVisable: Boolean;
    FValueOfXGrid: Integer;
    FValueOfYGrid: Single;
    FParent: TWaveViewer;
    FDataLength: Integer;
    FCursorList: TWaveCursorList;
    procedure SetColor(Value: TColor);
    procedure SetWaveViewMode(Value: TWaveViewMode);
    procedure SetVisable(Value: Boolean);
    procedure SetDataLength(Value: Integer);
    procedure SetValueOfXGrid(Value: Integer);
    procedure SetValueOfYGrid(Value: Single);
    procedure SetParent(Value: TWaveViewer);
    procedure SetCursorList(Value: TWaveCursorList);
  protected
  public
    BaseMarkVisable: Boolean;
    Order: Integer;
    Datas: array of Single;
    Points: array of TPoint;
    CurrentPoint: Integer;
    procedure AddData(Value: Single);
    procedure UpdatePoints;
    constructor Create(AOwner: TComponent); override;
    procedure Paint;
  published
    property Color: TColor read FColor write SetColor;
    property WaveViewMode: TWaveViewMode read FWaveViewMode write SetWaveViewMode;
    property Visable: Boolean read FVisable write SetVisable default True;
    property ValueOfXGrid: Integer read FValueOfXGrid write SetValueOfXGrid;
    property ValueOfYGrid: Single read FValueOfYGrid write SetValueOfYGrid;
    property Parent: TWaveViewer read FParent write SetParent;
    property DataLength: Integer read FDataLength write SetDataLength;
    property CursorList: TWaveCursorList read FCursorList write SetCursorList;
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

  TBaseLineStyle = (blsCustom, blsTop, blsBottom, blsMid);

  TWaveViewer = class(TGraphicControl)
  private
    FWaveLineList: TWaveLineList;
    FGridVisable: Boolean;
    FXGridSize: Integer;
    FYGridSize: Integer;
    FWaveRect: TRect;
    FBaseLineVisable: Boolean;
    FBaseLineStyle: TBaseLineStyle;
    XBase: Integer;
    YBase: Integer;
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
    procedure SetWaveRect(Value: TRect);
    procedure SetBaseLineVisable(Value: Boolean);
    procedure SetBaseLineStyle(Value: TBaseLineStyle);    
    procedure SetWaveLineList(Value: TWaveLineList);
  protected
    procedure Paint; override;
  public
    procedure AttachWaveLine(AWaveLine: TWaveLine);
    procedure DeAttachWaveLine(AWaveLine: TWaveLine);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;
  published
    property Align;
    property GridVisable: Boolean read FGridVisable write SetGridVisable default True;
    property XGridSize: Integer read FXGridSize write SetXGridSize default 20;
    property YGridSize: Integer read FYGridSize write SetYGridSize default 20;
    property WaveRect: TRect read FWaveRect write SetWaveRect;
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
  RegisterComponents('CloudControl', [TWaveCursor]);
end;


{ TWaveViewer }


procedure TWaveViewer.AttachWaveLine(AWaveLine: TWaveLine);
begin
  FWaveLineList.Add(AWaveLine);
  AWaveLine.Parent := Self;
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

procedure TWaveViewer.DeAttachWaveLine(AWaveLine: TWaveLine);
begin
  FWaveLineList.Remove(AWaveLine);
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
  i : Integer;
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

procedure TWaveViewer.SetWaveRect(Value: TRect);
begin
  if Value <> FWaveRect then
  begin
    FWaveRect := Value;
    Invalidate;
  end;
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

constructor TWaveLine.Create(AOwner: TComponent);
begin
  inherited;
  FVisable := True;
  FValueOfXGrid := 1;
  FValueOfYGrid := 1;
  FParent := nil;
  FCursorList := TWaveCursorList.Create(True);
end;

procedure TWaveLine.Paint;
var
  i : Integer;
begin
  if Parent = nil then
    Exit;
  if FVisable then
  begin
    UpdatePoints;
    with Parent.Canvas do
    begin
      Pen.Color := FColor;
      Pen.Style := psSolid;
      case FWaveViewMode of
        wvmCover:
        begin
          MoveTo(Points[0].X, Points[0].Y);
          for i := 0 to CurrentPoint-1 do
          begin
            LineTo(Points[i].X, Points[i].Y);
          end;
          MoveTo(Points[CurrentPoint].X, Points[CurrentPoint].Y);
          for i := CurrentPoint to DataLength-1 do
          begin
            LineTo(Points[i].X, Points[i].Y);
          end;
        end;
        wvmRoll:
        begin
          MoveTo(Points[0].X, Points[CurrentPoint].Y);
          for i := CurrentPoint to DataLength-1 do
          begin
            LineTo(Points[i-CurrentPoint].X, Points[i].Y);
          end;
          for i := 0 to CurrentPoint-1 do
          begin
            LineTo(Points[i+DataLength-CurrentPoint].X, Points[i].Y);
          end;
        end;
      end;
    end;
  end;
  for i := 0 to FCursorList.Count-1 do
  begin
    FCursorList.Items[i].Paint;
  end;
end;

procedure TWaveLine.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
    if FParent <> nil then
      Parent.Invalidate;
  end;
end;

procedure TWaveLine.SetCursorList(Value: TWaveCursorList);
begin

end;

procedure TWaveLine.SetParent(Value: TWaveViewer);
begin
  if Value <> FParent then
  begin
    // DeAttach if attached before
    if FParent <> nil then
    begin
      FParent.DeAttachWaveLine(Self);
      FParent.Invalidate;
    end;
    FParent := Value;
    // Attach if want to attach a new wave viwer
    if FParent <> nil then
    begin
      FParent.AttachWaveLine(Self);
      FParent.Invalidate;
    end;
  end;
end;

procedure TWaveLine.SetValueOfXGrid(Value: Integer);
begin
  if Value <> FValueOfXGrid then
  begin
    FValueOfXGrid := Value;
    if FParent <> nil then
      Parent.Invalidate;
  end;
end;

procedure TWaveLine.SetValueOfYGrid(Value: Single);
begin
  if Value <> FValueOfYGrid then
  begin
    FValueOfYGrid := Value;
    if FParent <> nil then
      Parent.Invalidate;
  end;
end;

procedure TWaveLine.SetVisable(Value: Boolean);
begin
  if Value <> FVisable then
  begin
    FVisable := Value;
    if FParent <> nil then
      Parent.Invalidate;
  end;
end;

procedure TWaveLine.SetDataLength(Value: Integer);
begin
  if Value <> FDataLength then
  begin
    SetLength(Datas, Value);
    SetLength(Points, Value);
    ZeroMemory(Datas, SizeOf(Datas));
    ZeroMemory(Points, SizeOf(Points));
    CurrentPoint := 0;
    FDataLength := Value;
  end;
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
var
  i : Integer;
begin
  Result := Count;
  for i := 0 to Count-1 do
  begin
    if AComponent = Items[i] then
      Exit;
  end;
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

{ TWaveCursor }

constructor TWaveCursor.Create(AOwner: TComponent);
begin
  inherited;
  FVisable := True;
  FLineStyle := psDash;
  FViewMode := cvmFull;
  FParent := nil;
end;

procedure TWaveCursor.Paint;
var
  i : Integer;
begin
  if (Parent = nil) or (Parent.Parent = nil) then
    Exit;
  if FVisable then
  begin
    with Parent.Parent.Canvas do
    begin
      Pen.Color := FColor;
      Pen.Style := psSolid;
      case ViewMode of
        cvmSimple:
        begin

        end;
       cvmFull:
        begin
          case FOrientation of
            cuHorizontal:
            begin
              MoveTo(Parent.Parent.WaveRect.Left, FPosition);
              LineTo(Parent.Parent.WaveRect.Right, FPosition);
            end;
            cuVertical:
            begin
              MoveTo(FPosition, Parent.Parent.WaveRect.Top);
              LineTo(FPosition, Parent.Parent.WaveRect.Bottom);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TWaveCursor.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
  end;
end;

procedure TWaveCursor.SetLineStyle(Value: TPenStyle);
begin
  if Value <> FLineStyle then
  begin
    FLineStyle := Value;
  end;
end;

procedure TWaveCursor.SetOrientation(Value: TCursorOrientation);
begin
  if Value <> FOrientation then
  begin
    FOrientation := Value;
  end;
end;

procedure TWaveCursor.SetParent(Value: TWaveLine);
begin
  if Value <> FParent then
  begin
    if FParent <> nil then
    begin
      FParent.CursorList.Remove(Self);
      if FParent.Parent <> nil then
        FParent.Parent.Invalidate;
    end;
    FParent := Value;
    if FParent <> nil then
    begin
      FParent.CursorList.Add(Self);
      if FParent.Parent <> nil then
        FParent.Parent.Invalidate;
    end;
  end;
end;

procedure TWaveCursor.SetPosition(Value: Integer);
begin
  if Value <> FPosition then
  begin
    FPosition := Value;
    if (Parent <> nil) and (Parent.Parent <> nil) then
    begin
      Parent.Parent.Invalidate;
    end;
  end;
end;

procedure TWaveCursor.SetViewMode(Value: TCursorViewMode);
begin
  if Value <> FViewMode then
  begin
    FViewMode := Value;
  end;
end;

procedure TWaveCursor.SetVisable(Value: Boolean);
begin
  if Value <> FVisable then
  begin
    FVisable := Value;
  end;
end;

{ TWaveCursorList }

function TWaveCursorList.Add(AComponent: TWaveCursor): Integer;
var
  i : Integer;
begin
  Result := Count;
  for i := 0 to Count-1 do
  begin
    if AComponent = Items[i] then
      Exit;
  end;
  Result := inherited Add(AComponent);
end;

constructor TWaveCursorList.Create(AOwnsObjects: Boolean);
begin
  inherited;
end;

function TWaveCursorList.First: TWaveCursor;
begin
  Result := inherited First as TWaveCursor;
end;

function TWaveCursorList.GetItem(Index: Integer): TWaveCursor;
begin
  Result := inherited Items[Index] as TWaveCursor;
end;

function TWaveCursorList.IndexOf(AComponent: TWaveCursor): Integer;
begin
  Result := inherited IndexOf(AComponent);
end;

function TWaveCursorList.IndexOfItem(AComponent: TWaveCursor;
  ADirection: TList.TDirection): Integer;
begin
  Result := inherited IndexOfItem(AComponent, ADirection);
end;

procedure TWaveCursorList.Insert(Index: Integer; AComponent: TWaveCursor);
begin
  inherited Insert(Index, AComponent);
end;

function TWaveCursorList.Last: TWaveCursor;
begin
  Result := inherited Last as TWaveCursor;
end;

function TWaveCursorList.Remove(AComponent: TWaveCursor): Integer;
begin
  Result := inherited Remove(AComponent);
end;

function TWaveCursorList.RemoveItem(AComponent: TWaveCursor;
  ADirection: TList.TDirection): Integer;
begin
  Result := inherited RemoveItem(AComponent, ADirection);
end;

procedure TWaveCursorList.SetItem(Index: Integer; AObject: TWaveCursor);
begin
  inherited Items[Index] := AObject;
end;

end.
