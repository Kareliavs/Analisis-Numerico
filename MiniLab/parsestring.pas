unit parsestring;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, fpexprpars,ParseMath,cmatriz, FileUtil, uCmdBox, TAGraph, Forms, Controls, Graphics,
Dialogs, ComCtrls, Grids, ValEdit, ExtCtrls, ShellCtrls, EditBtn, Menus,
StdCtrls, spktoolbar,funciones, spkt_Tab, spkt_Pane, spkt_Buttons, spkt_Checkboxes;




type
  matrix=array[65..122] of TAmatriz;

type
  TParseMathString = Class

  Public

      MiParse: TParseMath;
      Expression: string;
      m:matrix;
      //funciones:TFunciones;
      procedure serExpression( Expression1: string );
      function NewValue( Variable:string; Value: Double ): Double;
      function NewValuestring( Variable:string; Value: String ): String;
      procedure AddVariable( Variable: string; Value: Double );
      procedure AddVariableString( Variable: string; Value: String );
      function Evaluates(): String;
      constructor create();
      destructor destroy;

  end;

implementation


constructor TParseMathString.create;
begin
   MiParse:= TParseMath.create();



end;

destructor TParseMathString.destroy;
begin
     MiParse.destroy;


end;


procedure TParseMathString.serExpression( Expression1: string );
begin

     Expression:=Expression1;

    MiParse.Expression:= Expression1;//cboFuncion.Text;
end;

function TParseMathString.NewValue( Variable: string; Value: Double ): Double;
begin
    MiParse.NewValue( Variable,Value );


end;

function TParseMathString.NewValuestring( Variable: string; Value: String ): String;
begin
    MiParse.NewValuestring( Variable,Value );


end;

function TParseMathString.Evaluates(): String;
var
  FinalLine,inicio,temp,tempa,tempb: string;
  A,rpta:TAmatriz;
  i,j,start,k,aa,b:Integer;
  fin:Double;

begin
    //ShowMessage(Expression);

    FinalLine:=Expression;

     if Pos( '=', FinalLine ) > 0 then
     begin
    //  AddVariable( Pos( '=', FinalLine ) - 1 );  //bota la x
      if FinalLine[Pos( '=', FinalLine )+1]='[' then
         begin

          A:=TAmatriz.Create;


          A.f:=1;
          A.c:=1;
          i:=Pos( '=', FinalLine )+2;

          while i< length(FinalLine)-1 do
          begin
            if FinalLine[i]= ',' then
             begin
              A.f:=A.f +1;
                i:=i+1;
                A.c:=1;
              //  ShowMessage('fila'+IntToStr(A.f))

             end
            else
            begin
             start:=i;
            while FinalLine[i]<> ' ' do
                begin
                i:=i+1;
                end;

             inicio:=Copy(FinalLine,start,i-start);
             A.matrix[A.f,A.c]:=StrToFloat(inicio);
             A.c:=A.c +1;
            end;
            i:=i+1;

          end;
           temp:= FinalLine[ Pos( '=', FinalLine ) - 1];
        m[Ord( FinalLine[ Pos( '=', FinalLine ) - 1])]:=A;



        {  with ValueListEditor1 do
          begin
                  ListVar.Add(  FinalLine );

                  //.AddVariable( ListVar.Names[ ListVar.Count - 1 ], StrToFloat( ListVar.ValueFromIndex[ ListVar.Count - 1 ]) );
                  ValueListEditor1.Cells[ 0, RowCount - 1 ]:= ListVar.Names[ ListVar.Count - 1 ];
                  ValueListEditor1.Cells[ 1, RowCount - 1 ]:= ListVar.ValueFromIndex[ ListVar.Count - 1 ];
                  RowCount:= RowCount + 1;
          end;

         }
        // AddVariable( Pos( '=', FinalLine ) - 1 );
         end;



     end
     else
     begin



      temp:=Copy(FinalLine,1,4);
      //ShowMessage(temp);

      if temp='suma' then
       begin

        rpta:=TAmatriz.Create;
        tempa:=Copy(FinalLine,6,1);//buscarlo en el array de matrices

        tempb:=Copy(FinalLine,Pos(',', FinalLine )+1,1);//buscarlo en el array de matrices
         rpta:=m[Ord(tempa[1])].suma(m[Ord(tempb[1])]);
          rpta.f:=m[Ord(tempa[1])].f;
         rpta.c:=m[Ord(tempa[1])].c-1;
         Result:=(rpta.generar_smatriz);

       end
      else
      begin



      temp:=Copy(FinalLine,1,5);

      if temp='resta' then
       begin

        rpta:=TAmatriz.Create;
        tempa:=Copy(FinalLine,7,1);//buscarlo en el array de matrices

        tempb:=Copy(FinalLine,Pos(',', FinalLine )+1,1);//buscarlo en el array de matrices
      {  for  fin:=0 to ListVar.Count-1 do
         begin
         ShowMessage(ListVar.Names[ fin ]+IntToStr(fin));
         ShowMessage(tempa);
         ShowMessage(tempb);
         if ListVar.Names[ fin ]=tempa then
            aa:=fin;
         if ListVar.Names[ fin ]=tempb then
            b:=fin;
         end;
         ShowMessage(IntToStr(aa)+' '+IntToStr(b));   }


         rpta:=m[Ord(tempa[1])].resta(m[Ord(tempb[1])]);
         rpta.f:=m[Ord(tempa[1])].f;
         rpta.c:=m[Ord(tempa[1])].c;


    //     memCMD.Lines.Add(rpta.generar_smatriz)
         Result:=(rpta.generar_smatriz);
       end
      else
      begin



      temp:=Copy(FinalLine,1,11);

      if temp='multescalar' then
       begin

        rpta:=TAmatriz.Create;
        tempa:=Copy(FinalLine,13,1);//buscarlo en el array de matrices

        tempb:=Copy(FinalLine,Pos(',', FinalLine )+1,Length(FinalLine)-Pos(',', FinalLine )-1);//buscarlo en el array de matrices

         rpta:=m[Ord(tempa[1])].mult_escalar(StrToFloat(tempb));
          rpta.f:=m[Ord(tempa[1])].f;
         rpta.c:=m[Ord(tempa[1])].c-1;



         Result:=(rpta.generar_smatriz);
       end
      else
      begin



      temp:=Copy(FinalLine,1,5);

      if temp='traza' then
       begin

        rpta:=TAmatriz.Create;
        tempa:=Copy(FinalLine,7,1);//buscarlo en el array de matrices

         fin:=m[Ord(tempa[1])].traza;


         Result:=FloatToStr(fin);
       end
      else
      begin
       temp:=Copy(FinalLine,1,10);

      if temp='multmatriz' then
       begin

        rpta:=TAmatriz.Create;
        tempa:=Copy(FinalLine,12,1);//buscarlo en el array de matrices

        tempb:=Copy(FinalLine,Pos(',', FinalLine )+1,1);//buscarlo en el array de matrices

         rpta:=m[Ord(tempa[1])].mult_matriz(m[Ord(tempb[1])]);
          rpta.f:=m[Ord(tempa[1])].f;
         rpta.c:=m[Ord(tempb[1])].c-1;


          Result:=rpta.generar_smatriz;
       end
      else
      begin


       temp:=Copy(FinalLine,1,3);

      if temp='det' then
       begin

        rpta:=TAmatriz.Create;
        tempa:=Copy(FinalLine,5,1);//buscarlo en el array de matrices

        tempb:=Copy(FinalLine,Pos(',', FinalLine )+1,1);//buscarlo en el array de matrices
      {  for  fin:=0 to ListVar.Count-1 do
         begin
         ShowMessage(ListVar.Names[ fin ]+IntToStr(fin));
         ShowMessage(tempa);
         ShowMessage(tempb);
         if ListVar.Names[ fin ]=tempa then
            aa:=fin;
         if ListVar.Names[ fin ]=tempb then
            b:=fin;
         end;
         ShowMessage(IntToStr(aa)+' '+IntToStr(b));   }

       //  tempb:=Copy(FinalLine,Pos(',', FinalLine )+1,Length(FinalLine)-Pos(',', FinalLine )-1);//buscarlo en el array de matrices
         ShowMessage(FloatToStr( rpta.f));
         fin:=m[Ord(tempa[1])].determinante(m[Ord(tempa[1])],m[Ord(tempa[1])].f);

         Result:=FloatToStr(fin);

       end
       else
       begin
       temp:=Copy(FinalLine,1,4);
       end;
      if (temp='heun') or (temp='AddM')or (temp='SubM')or (temp='MulM')or (temp='InvM')or (temp='Tran') or (temp='Jaco')or (temp='NGen') or(temp='bise')or(temp='fpos')or(temp='newt')or(temp='seca')(*or (temp='trap')  or (temp='simp') or   (temp='inte') *)  then
       begin

         Result:= MiParse.EvaluateString();
       end
      else
       begin
       temp:=Copy(FinalLine,1,3);

      if (temp='eul') or (temp='rk3')  or (temp='rk4')  or (temp='EDO') then
       begin
         //ShowMessage('AQUIEES');
         Result:= MiParse.EvaluateString();
       end
       else
       begin
       temp:=Copy(FinalLine,1,8);

      if (temp='lagrange')  then
       begin

         Result:= MiParse.EvaluateString();
       end

      else
       begin

        Result:= FloatToStr(MiParse.Evaluate());

     end;


      end;

      end;

      end;

      end;

      end;

     end;



end;



     end;

end;

procedure TParseMathString.AddVariableString( Variable: string; Value: String );
var Len: Integer;
begin
   MiParse.AddVariableString( Variable, Value);

end;



procedure TParseMathString.AddVariable( Variable: string; Value: Double );
begin

   MiParse.AddVariable( Variable, Value);



end;

end.

