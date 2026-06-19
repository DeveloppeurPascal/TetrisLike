(* C2PP
  ***************************************************************************

  Tetris Like
  Copyright (c) 2021-2026 Patrick PREMARTIN

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://tetrislike.gamolf.fr

  Project site :
  https://github.com/DeveloppeurPascal/TetrisLike

  ***************************************************************************
  File last update : 2026-06-19T18:19:23.279+02:00
  Signature : 014c7d4dbe797ee51da7b7b956bc9c5d79b52928
  ***************************************************************************
*)

program TetrisLike;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  uElementsDuJeu in 'uElementsDuJeu.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
