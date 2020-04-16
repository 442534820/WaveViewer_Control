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
              
  TWaveLine = class(TObject)
  private       
    FColor: TColor;  
    procedure SetColor(Value: TColor);
  protected
  public
    BaseMarkVisable: Boolean;
    Visable: Boolean;
    Order: Integer;
    ValueOfXGrid: Integer;
    ValueOfYGrid: Single;
    Datas: array of Single;
    Points: array of Integer;
    DataLength: Integer;
    CurrentPoint: Integer;
    WaveViewMode: TWaveViewMode;
    Parent: TWaveViewer;
    procedure SetWaveLength(Value: Integer);
    procedure AddData(Value: Single);
    constructor Create(AOwner: TWaveViewer); overload;
    constructor Create(AOwner: TWaveViewer; Len: Integer); overload;
  published
    property Color: TColor read FColor write SetColor;
  end;

  TWaveLineList = class(TObjectList)
  private
  public
    constructor Create(AOwnsObjects: Boolean);
  published
  end;

  TWaveViewer = class(TGraphicControl)
  private
    FWaveLineList: TWaveLineList;
    FGridVisable: Boolean;
    FGridSize: Integer;
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
    procedure SetGridSize(Value: Integer);
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
    property GridSize: Integer read FGridSize write SetGridSize default 20;
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
  FGridSize := 20;
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
  xStep := FGridSize;
  yStep := FGridSize;
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

procedure TWaveViewer.SetGridSize(Value: Integer);
begin
  if FGridSize <> Value then
  begin
    FGridSize := Value;
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
end;

constructor TWaveLine.Create(AOwner: TWaveViewer; Len: Integer);
begin
  Create(AOwner);
  SetWaveLength(Len);
  AOwner.AttachWaveLine(Self);
end;

procedure TWaveLine.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
  end;
  Parent.Invalidate;
end;

procedure TWaveLine.SetWaveLength(Value: Integer);
begin
  SetLength(Datas, Value);
  SetLength(Points, Value);
  ZeroMemory(Datas, Value);
  ZeroMemory(Points, Value);
  CurrentPoint := 0;
  DataLength := Value;
end;

{ TWaveLineList }

constructor TWaveLineList.Create(AOwnsObjects: Boolean);
begin
  inherited;

end;

end.
