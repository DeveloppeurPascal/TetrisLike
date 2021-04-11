unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, uElementsDuJeu, FMX.Objects;

const
  CTailleBloc = 20;
  CNBLignes = 25;
  CNBColonnes = 10;

type
  TGrilleDeJeu = array [1 .. CNBColonnes, 1 .. CNBLignes] of boolean;

  TfrmMain = class(TForm)
    btnJouer: TButton;
    lblScore: TLabel;
    BoucleDuJeu: TTimer;
    zoneJeu: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure btnJouerClick(Sender: TObject);
    procedure BoucleDuJeuTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Déclarations privées }
    FScore: integer;
    FNiveauDuJeu: integer;
    FPartieEnCours: boolean;
    procedure SetScore(const Value: integer);
    procedure InitialiseEcran;
    procedure LancerPartie;
    procedure AjouteUnePiece;
    procedure SetNiveauDuJeu(const Value: integer);
    procedure PartiePerdue;
    procedure FigerPiece;
    procedure SetPartieEnCours(const Value: boolean);
  public
    { Déclarations publiques }
    GrilleDeJeu: TGrilleDeJeu;
    PieceEnCours: TTetrisPiece;
    VitesseDeChute: integer;
    property PartieEnCours: boolean read FPartieEnCours write SetPartieEnCours;
    property NiveauDuJeu: integer read FNiveauDuJeu write SetNiveauDuJeu;
    property Score: integer read FScore write SetScore;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.AjouteUnePiece;
var
  Piece: TTetrisPiece;
  i: integer;
begin
  case random(7) of
    0:
      Piece := TTetrisLigne.Create(zoneJeu);
    1:
      Piece := TTetrisCarre.Create(zoneJeu);
    2:
      Piece := TTetrisL.Create(zoneJeu);
    3:
      Piece := TTetrist.Create(zoneJeu);
    4:
      Piece := TTetrisLInverse.Create(zoneJeu);
    5:
      Piece := TTetrisZInverse.Create(zoneJeu);
  else
    Piece := TTetrisz.Create(zoneJeu);
  end;
  i := 10;
  Piece.Col := random(CNBColonnes - 4) + 1;
  Piece.Lig := 1;
  while (random(100) < 90) and (i > 0) do
  begin
    dec(i);
    Piece.FaitTourner;
  end;
  PieceEnCours := Piece;
  VitesseDeChute := NiveauDuJeu;
  if VitesseDeChute > CTailleBloc div 2 then
    VitesseDeChute := CTailleBloc div 2;
end;

procedure TfrmMain.BoucleDuJeuTimer(Sender: TObject);
begin
  if assigned(PieceEnCours) then
  begin
    PieceEnCours.FaitDescendre(VitesseDeChute);
    PieceEnCours.Dessine;
    if (PieceEnCours.Lig + PieceEnCours.HauteurPiece - 1 >= CNBLignes) then
      FigerPiece
    else if PieceEnCours.TestCollision then
    begin
      if PieceEnCours.Lig <= 2 then
        PartiePerdue
      else
        FigerPiece;
    end;
  end;
end;

procedure TfrmMain.btnJouerClick(Sender: TObject);
begin
  LancerPartie;
end;

procedure TfrmMain.FigerPiece;
var
  i, j, k: integer;
  LigneComplete: boolean;
  Bonus: integer;
begin
  if assigned(PieceEnCours) then
  begin
    PieceEnCours.Figer;
    j := CNBLignes;
    Bonus := 1;
    while (j >= PieceEnCours.Lig) do
    begin
      LigneComplete := true;
      for i := 1 to CNBColonnes do
        LigneComplete := LigneComplete and GrilleDeJeu[i, j];
      if LigneComplete then
      begin
        Score := Score + NiveauDuJeu * Bonus;
        inc(Bonus);
        // on traite la grille du jeu pour tout descendre d'une ligne
        for k := j downto 1 do
          for i := 1 to CNBColonnes do
            if k = 1 then
              GrilleDeJeu[i, k] := false
            else
              GrilleDeJeu[i, k] := GrilleDeJeu[i, k - 1];
        // on supprime les rectangles de la ligne en cours
        for k := zoneJeu.ChildrenCount - 1 downto 0 do
          if (zoneJeu.Children[k] is TRectangle) and
            ((zoneJeu.Children[k] as TRectangle).tag = j) then
            (zoneJeu.Children[k] as TRectangle).free;
        // on descend les rectangles qui étaient au dessus
        for k := 0 to zoneJeu.ChildrenCount - 1 do
          if (zoneJeu.Children[k] is TRectangle) and
            ((zoneJeu.Children[k] as TRectangle).tag < j) then
          begin
            (zoneJeu.Children[k] as TRectangle).tag :=
              (zoneJeu.Children[k] as TRectangle).tag + 1;
            (zoneJeu.Children[k] as TRectangle).position.y :=
              (zoneJeu.Children[k] as TRectangle).position.y + CTailleBloc;
          end;
      end
      else
        dec(j);
    end;
  end;
  AjouteUnePiece;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  PieceEnCours := nil;
  Score := 0;
  NiveauDuJeu := CTailleBloc;
  PartieEnCours := false;
  InitialiseEcran;
  AjouteUnePiece;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if PartieEnCours and assigned(PieceEnCours) then
  begin
    if KeyChar = ' ' then
    begin
      KeyChar := #0;
      PieceEnCours.FaitTourner;
    end
    else if Key = vkDown then
    begin
      Key := 0;
      VitesseDeChute := CTailleBloc;
    end
    else if Key = vkLeft then
    begin
      Key := 0;
      PieceEnCours.DeplaceVersLaGauche;
    end
    else if Key = vkRight then
    begin
      Key := 0;
      PieceEnCours.DeplaceVersLaDroite;
    end;
  end;
end;

procedure TfrmMain.InitialiseEcran;
var
  i, j: integer;
begin
  if assigned(PieceEnCours) then
    FreeAndNil(PieceEnCours);
  zoneJeu.width := CTailleBloc * CNBColonnes;
  zoneJeu.height := CTailleBloc * CNBLignes;
  while (zoneJeu.ChildrenCount > 0) do
    zoneJeu.Children[0].free;
  for i := 1 to CNBColonnes do
    for j := 1 to CNBLignes do
      GrilleDeJeu[i, j] := false;
end;

procedure TfrmMain.LancerPartie;
begin
  InitialiseEcran;
  Score := 0;
  NiveauDuJeu := 1;
  PartieEnCours := true;
  AjouteUnePiece;
end;

procedure TfrmMain.PartiePerdue;
begin
  if PartieEnCours then
  begin
    PartieEnCours := false;
    showmessage('Perdu');
  end
  else
  begin
    InitialiseEcran;
    AjouteUnePiece;
  end;
end;

procedure TfrmMain.SetNiveauDuJeu(const Value: integer);
begin
  FNiveauDuJeu := Value;
end;

procedure TfrmMain.SetPartieEnCours(const Value: boolean);
begin
  FPartieEnCours := Value;
  btnJouer.Visible := not FPartieEnCours;
  if btnJouer.Visible then
    btnJouer.BringToFront;
end;

procedure TfrmMain.SetScore(const Value: integer);
begin
  FScore := Value;
  lblScore.Text := 'Score : ' + FScore.ToString;
end;

initialization

randomize;

end.
