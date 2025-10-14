(* C2PP
  ***************************************************************************

  Tetris Like

  Copyright 2021-2025 Patrick PREMARTIN under MIT license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://tetrislike.gamolf.fr

  Project site :
  https://github.com/DeveloppeurPascal/TetrisLike

  ***************************************************************************
  File last update : 2025-10-14T11:43:37.921+02:00
  Signature : 64e5b5601b93ae2dfef966c3eec9249ee5e9f778
  ***************************************************************************
*)

unit uElementsDuJeu;

interface

uses
  System.UITypes, FMX.Objects;

type
  TTetrisBloc = array [1 .. 4, 1 .. 4] of boolean;

  TTetrisPiece = class
  private
    x, y: single;
    ListeCases: array [1 .. 4, 1 .. 4] of trectangle;
    Parent: trectangle;
    FLargeurPiece: byte;
    FHauteurPiece: byte;
    FCol: integer;
    FLig: integer;
    procedure SetCol(const Value: integer);
    procedure SetLig(const Value: integer);
  public
    Blocs: TTetrisBloc;
    Couleur: TAlphaColor;
    property Col: integer read FCol write SetCol;
    property Lig: integer read FLig write SetLig;
    property LargeurPiece: byte read FLargeurPiece;
    property HauteurPiece: byte read FHauteurPiece;
    procedure Dessine;
    procedure FaitDescendre(Vitesse: byte);
    function TestCollision: boolean;
    procedure FaitTourner;
    procedure DeplaceVersLaGauche;
    procedure DeplaceVersLaDroite;
    procedure Figer;
    constructor Create(ZoneDeJeu: trectangle); overload; virtual;
    destructor Destroy; override;
  end;

  TTetrisLigne = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

  TTetrisCarre = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

  TTetrisL = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

  TTetrisLInverse = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

  TTetrisT = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

  TTetrisZ = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

  TTetrisZInverse = class(TTetrisPiece)
  public
    constructor Create(ZoneDeJeu: trectangle); override;
  end;

implementation

uses fMain, FMX.Graphics, System.Types, System.SysUtils, System.Math;

{ TTetrisPiece }

constructor TTetrisPiece.Create(ZoneDeJeu: trectangle);
var
  i, j: integer;
begin
  inherited Create;
  Parent := ZoneDeJeu;
  for i := 1 to 4 do
    for j := 1 to 4 do
      ListeCases[i, j] := nil;
  Couleur := talphacolors.white;
  FHauteurPiece := 0;
  FLargeurPiece := 0;
end;

procedure TTetrisPiece.DeplaceVersLaDroite;
begin
  if Col + FLargeurPiece <= CNBColonnes then
  begin
    Col := Col + 1;
    if TestCollision then
      Col := Col - 1;
  end;
end;

procedure TTetrisPiece.DeplaceVersLaGauche;
begin
  if Col > 1 then
  begin
    Col := Col - 1;
    if TestCollision then
      Col := Col + 1;
  end;
end;

procedure TTetrisPiece.Dessine;
var
  i, j: integer;
begin
  for i := 1 to 4 do
    for j := 1 to 4 do
    begin
      if Blocs[i, j] and (not assigned(ListeCases[i, j])) then
      begin
        ListeCases[i, j] := trectangle.Create(Parent);
        ListeCases[i, j].Parent := Parent;
        ListeCases[i, j].Stroke.Kind := tbrushkind.solid;
        ListeCases[i, j].Stroke.Color := talphacolors.darkgrey;
        ListeCases[i, j].fill.Kind := tbrushkind.solid;
        ListeCases[i, j].fill.Color := Couleur;
        ListeCases[i, j].width := CTailleBloc;
        ListeCases[i, j].height := CTailleBloc;
      end;
      if assigned(ListeCases[i, j]) then
      begin
        ListeCases[i, j].position.Point := pointf(x + (i - 1) * CTailleBloc,
          y + (j - 1) * CTailleBloc);
        ListeCases[i, j].visible := Blocs[i, j];
      end;
    end;
end;

destructor TTetrisPiece.Destroy;
var
  i, j: integer;
begin
  for i := 1 to 4 do
    for j := 1 to 4 do
      if assigned(ListeCases[i, j]) then
        ListeCases[i, j].Free;
  inherited;
end;

procedure TTetrisPiece.FaitDescendre(Vitesse: byte);
var
  LY: single;
  LLig: integer;
begin
  LY := y + Vitesse;
  LLig := trunc(LY / CTailleBloc) + 1;
  if LLig + HauteurPiece > CNBLignes then // anti dépassement par le bas
    Lig := CNBLignes - HauteurPiece + 1
  else if LLig > Lig then
  begin
    Lig := LLig;
    y := LY;
  end
  else
    y := LY;
end;

procedure TTetrisPiece.FaitTourner;
var
  i, j, k: integer;
  LBlocs: TTetrisBloc;
  BlocActif: boolean;
  NewLargeurPiece, NewHauteurPiece: integer;
begin
  // rotation
  for i := 1 to 4 do
    for j := 1 to 4 do
      LBlocs[5 - j, i] := Blocs[i, j];
  // remonter le motif si lignes blanches au dessus
  k := 0;
  for j := 1 to 4 do
  begin
    BlocActif := false;
    for i := 1 to 4 do
      BlocActif := BlocActif or LBlocs[i, j];
    if BlocActif then
    begin
      k := j; // première ligne avec bloc actif
      break;
    end;
  end;
  NewHauteurPiece := 0;
  for j := 1 to 4 do
  begin
    BlocActif := false;
    for i := 1 to 4 do
    begin
      if (j - 1 + k > 4) then
        LBlocs[i, j] := false
      else
        LBlocs[i, j] := LBlocs[i, j - 1 + k];
      BlocActif := BlocActif or LBlocs[i, j];
    end;
    if BlocActif then
      inc(NewHauteurPiece);
  end;
  // décaler le motif à gauche si colonnes blanches à gauche
  k := 0;
  for i := 1 to 4 do
  begin
    BlocActif := false;
    for j := 1 to 4 do
      BlocActif := BlocActif or LBlocs[i, j];
    if BlocActif then
    begin
      k := i; // première colonne avec bloc actif
      break;
    end;
  end;
  NewLargeurPiece := 0;
  for i := 1 to 4 do
  begin
    BlocActif := false;
    for j := 1 to 4 do
    begin
      if (i - 1 + k > 4) then
        LBlocs[i, j] := false
      else
        LBlocs[i, j] := LBlocs[i - 1 + k, j];
      BlocActif := BlocActif or LBlocs[i, j];
    end;
    if BlocActif then
      inc(NewLargeurPiece);
  end;
  // copie de la nouvelle version dans la finale
  if (Col + NewLargeurPiece - 1 <= CNBColonnes) and (not TestCollision) then
  begin
    for i := 1 to 4 do
      for j := 1 to 4 do
        Blocs[i, j] := LBlocs[i, j];
    FHauteurPiece := NewHauteurPiece;
    FLargeurPiece := NewLargeurPiece;
  end;
end;

procedure TTetrisPiece.Figer;
var
  i, j: integer;
begin
  for i := 1 to 4 do
    for j := 1 to 4 do
      if Blocs[i, j] then
      begin
        frmmain.GrilleDeJeu[Col + i - 1, Lig + j - 1] := true;
        if assigned(ListeCases[i, j]) then
        begin
          ListeCases[i, j].Tag := Lig + j - 1;
          ListeCases[i, j].position.y := (Lig - 1 + j - 1) * CTailleBloc;
        end;
      end
      else if assigned(ListeCases[i, j]) then
        freeandnil(ListeCases[i, j]);
end;

procedure TTetrisPiece.SetCol(const Value: integer);
begin
  FCol := Value;
  x := (FCol - 1) * CTailleBloc;
end;

procedure TTetrisPiece.SetLig(const Value: integer);
begin
  FLig := Value;
  y := (FLig - 1) * CTailleBloc;
end;

function TTetrisPiece.TestCollision: boolean;
var
  i, j: integer;
begin
  result := false;
  for i := 1 to FLargeurPiece do
    for j := 1 to FHauteurPiece do
    begin
      result := Blocs[i, j] and ((frmmain.GrilleDeJeu[Col + i - 1, Lig + j - 1])
        or (frmmain.GrilleDeJeu[Col + i - 1, (Lig + 1) + j - 1]));
      if result then
        exit;
    end;
end;

{ TTetrisLigne }

constructor TTetrisLigne.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 1] := true;
  Blocs[2, 1] := true;
  Blocs[3, 1] := true;
  Blocs[4, 1] := true;
  FHauteurPiece := 1;
  FLargeurPiece := 4;
  Couleur := talphacolors.red;
end;

{ TTetrisCarre }

constructor TTetrisCarre.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 1] := true;
  Blocs[1, 2] := true;
  Blocs[2, 1] := true;
  Blocs[2, 2] := true;
  FHauteurPiece := 2;
  FLargeurPiece := 2;
  Couleur := talphacolors.green;
end;

{ TTetrisL }

constructor TTetrisL.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 1] := true;
  Blocs[2, 1] := true;
  Blocs[3, 1] := true;
  Blocs[4, 1] := true;
  Blocs[4, 2] := true;
  FHauteurPiece := 2;
  FLargeurPiece := 4;
  Couleur := talphacolors.blue;
end;

{ TTetrisT }

constructor TTetrisT.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 1] := true;
  Blocs[2, 1] := true;
  Blocs[3, 1] := true;
  Blocs[2, 2] := true;
  FHauteurPiece := 2;
  FLargeurPiece := 3;
  Couleur := talphacolors.yellow;
end;

{ TTetrisZ }

constructor TTetrisZ.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 1] := true;
  Blocs[2, 1] := true;
  Blocs[2, 2] := true;
  Blocs[3, 2] := true;
  FHauteurPiece := 2;
  FLargeurPiece := 3;
  Couleur := talphacolors.Violet;
end;

{ TTetrisZInverse }

constructor TTetrisZInverse.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 2] := true;
  Blocs[2, 2] := true;
  Blocs[2, 1] := true;
  Blocs[3, 1] := true;
  FHauteurPiece := 2;
  FLargeurPiece := 3;
  Couleur := talphacolors.orange;
end;

{ TTetrisLInverse }

constructor TTetrisLInverse.Create(ZoneDeJeu: trectangle);
begin
  inherited;
  Blocs[1, 1] := true;
  Blocs[1, 2] := true;
  Blocs[2, 1] := true;
  Blocs[3, 1] := true;
  Blocs[4, 1] := true;
  FHauteurPiece := 2;
  FLargeurPiece := 4;
  Couleur := talphacolors.white;
end;

end.
