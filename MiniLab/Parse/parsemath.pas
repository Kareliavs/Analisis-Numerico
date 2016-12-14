unit ParseMath;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, fpexprpars,cmatriz, FileUtil, uCmdBox, TAGraph, Forms, Controls, Graphics,
Dialogs, ComCtrls, Grids, ValEdit, ExtCtrls, ShellCtrls, EditBtn, Menus,
StdCtrls, spktoolbar, spkt_Tab, spkt_Pane, spkt_Buttons, spkt_Checkboxes,
  Matrix, Inversa, NewtonG, Jacobiana, Lagrange1,
   integral,Conversor,EDO
  ;



type
  matrixa=array[1..20] of TAmatriz;

type
  TParseMath = Class

  Private
      FParser: TFPExpressionParser;
      identifier: array of TFPExprIdentifierDef;
      Procedure AddFunctions();


  Public

      Expression: string;
      respuesta:String;
      function NewValue( Variable:string; Value: Double ): Double;
      function NewValuestring( Variable: string; Value: String ): String;
      procedure AddVariable( Variable: string; Value: Double );
      function Evaluate(): Double;
      procedure AddVariableString( Variable: string; Value: String );
      constructor create();
      function EvaluateString(): String;

      destructor destroy;

  end;


var

   A,B,Error,error2,anterior,funct,x,xn_0,xn_1,signo:Double;
  i,j,tam:Integer;
  number, zero : Integer;
  MiParse: TParseMath;
  f,d:String;


implementation


constructor TParseMath.create;
begin
   FParser:= TFPExpressionParser.Create( nil );
   FParser.Builtins := [bcMath];
   AddFunctions();
   FParser.Identifiers.AddFloatVariable( 'e', 2.718281);
end;

destructor TParseMath.destroy;
begin
    FParser.Destroy;
end;

function TParseMath.NewValue( Variable: string; Value: Double ): Double;
begin
    FParser.IdentifierByName(Variable).AsFloat:= Value;

end;

function TParseMath.NewValuestring( Variable: string; Value: String ): String;
begin
    FParser.IdentifierByName(Variable).AsString:= Value;

end;

function TParseMath.Evaluate(): Float;
begin
     FParser.Expression:= Expression;
     Result:= ArgToFloat( FParser.Evaluate );
     //Result:= FParser.Evaluate.ResFloat;
end;


function TParseMath.EvaluateString(): String;
begin
     FParser.Expression:= Expression;

     Result:= (FParser.Evaluate.ResString);
end;

function IsNumber(AValue: TExprFloat): Boolean;
begin
  result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;
Function funcion(x:Double;f:String):Double;
begin
  try
     MiParse:= TParseMath.create();
     MiParse.AddVariable( 'x', x );
     MiParse.Expression:= f;//cboFuncion.Text;
     funct:=MiParse.Evaluate();
     //ShowMessage('x '+FloatToStr(x));
    //ShowMessage('x '+FloatToStr(funct));
    funcion:=funct;
    except

  //   ShowMessage('NO HAY RAIZ EN ESE INTERVALO');
     funcion:=0;
     Exit;

  end;



end;

Function funcion2(x,y:Double;f:String):Double;
begin
  try
     MiParse:= TParseMath.create();
     MiParse.AddVariable( 'x', x );
     MiParse.AddVariable( 'y', y );
     MiParse.Expression:= f;//cboFuncion.Text;
     funct:=MiParse.Evaluate();
   //  ShowMessage('x '+FloatToStr(x));
    //ShowMessage('x '+FloatToStr(funct));
    funcion2:=funct;
    except

  //   ShowMessage('NO HAY RAIZ EN ESE INTERVALO');
     funcion2:=0;
     Exit;

  end;




end;

Function falsa_posicion(A:Double;B:Double;f:String):Double;
begin
  //ShowMessage(FloatToStr(A-((funcion(A,f)*(B-A))/(funcion(B,f)-funcion(A,f)))));
  falsa_posicion:= A-((funcion(A,f)*(B-A))/(funcion(B,f)-funcion(A,f)));
end;

function derivada(x:Double;f:String):Double;
var
  h:Float;
Begin
  h:=0.01;
  derivada:=(funcion(x+h,f)-funcion(x,f))/h;
 // ShowMessage(FloatToStr(derivada));
end;

function derivada1(x:Double;f:String;e:Double):Double;
var
  h:Float;
Begin
  h:=e/10;
  derivada1:=x-(h*funcion(x,f))/(funcion(x+h,f)-funcion(x,f));
 // ShowMessage(FloatToStr(derivada));
end;

function derivada2(x:Double;f:String;e:Double;x0:Double):Double;
var
  h:Float;
Begin
  h:=e/10;
  derivada2:=x-(funcion(x,f)*(x-x0))/(funcion(x,f)-funcion(x0,f));
  //ShowMessage(FloatToStr(derivada));
end;

function derivada3(x:Double;f:String;e:Double):Double;
var
  h:Float;
Begin
  h:=e/10;
  derivada3:=x-(2*h*funcion(x,f))/(funcion(x+h,f)-funcion(x-h,f));
 // ShowMessage(FloatToStr(derivada));
end;

Function newton(x:Double;f:String;d:String):Double;
begin
  newton:=x-(funcion(x,f)/funcion(x,d));
end;

Function biyeccion(A:Double;B:Double):Double;
begin
  biyeccion:=(A+B)/2;
end;
////NUMERICOS
Procedure ExprBiy( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  iteraciones:String;
begin

     A:=ArgToFloat( Args[ 1 ] );
     B:=ArgToFloat(Args[2]);
     Error:=ArgToFloat( Args[ 3 ] );
     tam:=Length(FloatToStr(Error))-2;
     f:=Args[0].ResString;
     //ShowMessage('biseccion'+f);
     i:=1;

     error2:=50;
     signo:=-1;
     anterior:=0;

  while (error2>=Error) do
  begin

    try
     if funcion(A,f)=0 then
      begin
        Result.resString := FloatToStr(A);
        Exit;
      end;
     if funcion(B,f)=0 then
      begin
        Result.resString := FloatToStr(B);
        Exit;
      end;
    except
     Result.resString := 'NaN';
       Exit;
    end;
        x:=biyeccion(A,B);

    //    x:=RoundTo(falsa_posicion(A,B,f),-tam);

    signo:=RoundTo(funcion(A,f)*funcion(x,f),-tam);
    error2:= abs(anterior-x);
    anterior:=x;
    i:=i+1;
    if signo =0 then
     begin
     Result.resFloat := RoundTo(x,-tam);
     Break;
     Exit;
     end;
    if signo<0 then
      B:=x
    else if signo>0 then
      A:=x;
    iteraciones:= iteraciones+'  '+FloatToStr(x);
  end;
  //  Result.resFloat := RoundTo(x,-tam);
  Result.ResString:=iteraciones+#13#10 +' rsultado: '+FloatToStr(RoundTo(x,-tam));

end;

Procedure ExprFP( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  iteraciones:String;
begin
     A:=ArgToFloat( Args[ 1 ] );
     B:=ArgToFloat(Args[2]);
     Error:=ArgToFloat( Args[ 3 ] );
     tam:=Length(FloatToStr(Error))-2;
     f:=Args[0].ResString;

     i:=1;
      error2:=50;
      signo:=-1;
      anterior:=0;

  while (error2>Error) do
  begin

  try

   if funcion(A,f)=0 then
    begin
      //ShowMessage('A');
      Result.resString := FloatToStr(A);
      Exit;
    end;
  if funcion(B,f)=0 then
    begin
      //ShowMessage('B');
      Result.resString := FloatToStr(B);
      Exit;
    end;
  except
   //ShowMessage('NAn');
   Result.resString := 'NaN';
     Exit;
  end;
   //   x:=RoundTo(biyeccion(A,B),-tam);

    x:=falsa_posicion(A,B,f);
    //ShowMessage('asi llega'+ FloatToStr(x));

  signo:=RoundTo(funcion(A,f)*funcion(x,f),-tam);
  error2:=RoundTo( abs(anterior-x),-tam);
  anterior:=x;

  i:=i+1;
  if signo =0 then
   begin
   //ShowMessage('signo = 0');
   Result.resFloat := RoundTo(x,-tam);
   Break;
   Exit;
   end;
  if signo<0 then
    B:=x
  else
    A:=x;
  iteraciones:= iteraciones+'  '+FloatToStr(x);
  end;
  //  Result.resFloat := RoundTo(x,-tam);
  Result.ResString:=iteraciones+#13#10 +' rsultado: '+FloatToStr(RoundTo(x,-tam));

end;

Procedure ExprSecante( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  iteraciones:String;
begin

     B:=( Args[ 3 ].ResInteger );
     A:=ArgToFloat(Args[1]);
     Error:=ArgToFloat( Args[ 2 ] );
     tam:=Length(FloatToStr(Error))-2;
     f:=Args[0].ResString;
     x:=A;
      xn_0:=x-0.1;
    // Error:=0;

      i:=1;
  error2:=20;
    iteraciones:=FloatToStr(x);
    while (error2>Error) do
     begin

      if funcion(x,f)=0 then
       begin
       Result.resString := FloatToStr(x);
         //ShowMessage('La raiz es:'+FloatToStr(x));
         Exit;
       end;
     if derivada(x,f)=0 then
       begin
         Result.resString := 'NaN';
       // ShowMessage('La funcion no es continua o tiene picos');
        Exit;
       end;


     if B=1 then
       xn_1:=RoundTo(derivada1(x,f,Error),-tam);
     if B=3 then
       xn_1:=RoundTo(derivada3(x,f,Error),-tam);
     if B=2 then
       begin
        xn_1:=RoundTo(derivada2(x,f,Error,xn_0),-tam);
        error2:=RoundTo( abs(x-xn_1),-tam);
       end
     else
     begin
     error2:=RoundTo( abs(x-xn_1),-tam);
     end;
     xn_0:=x;
     x:=xn_1;
     i:=i+1;
     iteraciones:= iteraciones+'  '+FloatToStr(x);
  end;
  //  Result.resFloat := RoundTo(x,-tam);
  Result.ResString:=iteraciones+#13#10 +' rsultado: '+FloatToStr(RoundTo(x,-tam));
end;

Procedure ExprLagrange( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y,ok: string;
  a,b: matriz;
  x0,res: Real;
  n,m: integer;
  conv: TConversor;
  resul:TLagrange;
begin
    //ShowMessage('GATO');
    x := Args[ 0 ].resString;
    x0:= ArgToFloat( Args[ 1 ] );
    conv:=TConversor.create();
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    m := conv.Columnas(x);
    resul:=TLagrange.create(a,m,x0);
    res:=resul.Evaluate();
    ok:='polinomio: '+resul.Polinomio+#13#10+' Evaluado: '+FloatToStr(res);
    Result.ResString:=ok;
end;


Procedure ExprNewton( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  iteraciones:String;
begin

     A:=ArgToFloat( Args[ 2 ] );
     Error:=ArgToFloat( Args[ 3 ] );
     tam:=Length(FloatToStr(Error))-2;
     f:=Args[0].ResString;
    d:=Args[1].ResString;
    //ShowMessage('A'+FloatToStr(A));
     i:=1;
      error2:=20;
      signo:=-1;
      anterior:=0;

      x:=A;
     // Error:=0;
     iteraciones:=FloatToStr(A);
     while (error2>Error) do
      begin
      //ShowMessage(FloatTOStr(x)+' AQUI '+f);
      //newton('x*ln(x)-x','ln(x)',5,0.001)
      if x=A then
        begin
         if funcion(x,f) = 0 then
          begin
           Result.resString := FloatToStr(x);
          //  ShowMessage('La raiz es:'+FloatToStr(x));
            Exit;
          end;
        if derivada(x,f)=0 then
          begin
           Result.resString := 'NaN';
          // ShowMessage('La funcion no es continua o tiene picos');
           Exit;
          end;
        end;

      xn_1:=RoundTo(newton(x,f,d),-tam);
      ////////ingresar la funcion derivada
      error2:=RoundTo( abs(x-xn_1),-tam);
      x:=xn_1;
      i:=i+1;
     iteraciones:= iteraciones+'  '+FloatToStr(x);
  end;
  //  Result.resFloat := RoundTo(x,-tam);
  Result.ResString:=iteraciones+#13#10 +' rsultado: '+FloatToStr(RoundTo(x,-tam));


end;

////MATEMATICOS

Procedure ExprTan( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and ((frac(x - 0.5) / pi) <> 0.0) then
      Result.resFloat := tan(x)

   else
     Result.resFloat := NaN;
end;

Procedure ExprSin( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := sin(x)

end;

Procedure ExprCos( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := cos(x)

end;

Procedure ExprCot( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := cot(x)

end;

Procedure ExprSec( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := sec(x)

end;

Procedure ExprCsc( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := csc(x)

end;

Procedure ExprLn( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := ln(x)

   else
     Result.resFloat := NaN;

end;

Procedure ExprLog( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := ln(x) / ln(10)

   else
     Result.resFloat := NaN;

end;

Procedure ExprSQRT( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := sqrt(x)

   else
     Result.resFloat := NaN;

end;
Procedure ExprExp( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
  Epsilon:Real;
begin

    Epsilon:=2.718281;
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := power(epsilon,x)

   else
     Result.resFloat := NaN;

end;
Procedure ExprPower( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
    y := ArgToFloat( Args[ 1 ] );


     Result.resFloat := power(x,y);

end;
////MATRICES
Procedure ExprAddMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y,resp: string;
  a,b: matriz;
  n,m: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    y := Args[ 1 ].resString;
    conv:=TConversor.create();
    resul:=TMatriz.create ;
    a := conv.CadenaAMatriz(x);
    b := conv.CadenaAMatriz(y);
    //ShowMessage('ENTRO');
    n := conv.Filas(x);
    m := conv.Columnas(x);
    //ShowMessage('Filas: '+IntToStr(n)+' Columnas: '+IntToStr(m));

    //Result.ResString:=
    resp:=conv.MatrizACadena(resul.Suma(a,b,n,m),n,m);
    ShowMessage( resp);
    Result.ResString:=  resp;
    //Result.ResFloat:=1;
end;

Procedure ExprSubMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y,resp: string;
  a,b: matriz;
  n,m: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    y := Args[ 1 ].resString;
    conv:=TConversor.create();
    resul:=TMatriz.create ;
    a := conv.CadenaAMatriz(x);
    b := conv.CadenaAMatriz(y);
    //ShowMessage('ENTRO');
    n := conv.Filas(x);
    m := conv.Columnas(x);
    //ShowMessage('Filas: '+IntToStr(n)+' Columnas: '+IntToStr(m));

    //Result.ResString:=
    resp:=conv.MatrizACadena(resul.Resta(a,b,n,m),n,m);
    ShowMessage( resp);
    Result.ResString:=  resp;
    //Result.ResFloat:=1;
end;

Procedure ExprMulMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y,resp: string;
  a,b: matriz;
  n,m,o: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    y := Args[ 1 ].resString;
    conv:=TConversor.create();
    resul:=TMatriz.create ;
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    m := conv.Columnas(x);
    b := conv.CadenaAMatriz(y);
    //ShowMessage('ENTRO');

    o := conv.Columnas(y);
    ShowMessage('Filas: '+IntToStr(n)+' Columnas: '+IntToStr(m)+' Columnas: '+IntToStr(o));

    //Result.ResString:=
    //MulMat('[1 2 ;3 4 ]','[5 6 ;7 8 ]')
    resp:=conv.MatrizACadena(resul.Mult(a,b,n,m,o),m,o);
    ShowMessage(IntToStr(n)+'  '+IntToStr(m)+'  '+IntToStr(o));
    ShowMessage( resp);
    Result.ResString:=  resp;
    //Result.ResFloat:=1;
end;
Procedure ExprInvMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y,resp: string;
  a,b: matriz;
  n,m,o: integer;
  conv: TConversor;
  resul:TInversa;
begin
    x := Args[ 0 ].resString;
    conv:=TConversor.create();
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    resul:=TInversa.create(a,n);
    //ShowMessage('ENTRE'+IntToStr(n));
    resp:=conv.MatrizACadena(resul.Evaluate(),n,n);
    ShowMessage( resp);
    Result.ResString:=  resp;
    //Result.ResFloat:=1;
end;
Procedure ExprDetMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y: string;
  a,b: matriz;
  n,m: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    conv:=TConversor.create();
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    m := conv.Columnas(x);
    resul:=TMatriz.create();
    Result.ResFloat:=resul.Determinante(a,n,m);
end;
Procedure ExprTransMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y,res: string;
  a,b: matriz;
  n,m: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    conv:=TConversor.create();
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    m := conv.Columnas(x);
    resul:=TMatriz.create();
    res:=conv.MatrizACadena(resul.Transpuesta(a,n,m),n,m);
    ShowMessage(res);
    Result.ResString:=res;
end;
Procedure ExprTrazaMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y: string;
  a,b: matriz;
  n,m: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    conv:=TConversor.create();
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    m := conv.Columnas(x);
    resul:=TMatriz.create();
    Result.ResFloat:=resul.Traza(a,n,m);
end;
Procedure ExprMulMatEsc( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,res: string;
  y:Real;
  a,b: matriz;
  n,m: integer;
  conv: TConversor;
  resul:TMatriz;
begin
    x := Args[ 0 ].resString;
    y := ArgToFloat( Args[ 1 ] );
    conv:=TConversor.create();
    a := conv.CadenaAMatriz(x);
    n := conv.Filas(x);
    m := conv.Columnas(x);
    resul:=TMatriz.create();
    res:=conv.MatrizACadena(resul.MultEsc(a,y,n,m),n,m);
    ShowMessage(res);
    Result.ResString:=res;
end;
Procedure ExprJacob( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  variables,funciones,valores,resp: string;
  a,b: matriztext;
  c: matriz;
  n,m,o: integer;
  conv: TConversor;
  resul:TJacobiana;
begin
    ///ShowMessage('HOLA');
    variables := Args[ 0 ].resString;
    funciones := Args[ 1 ].resString;
    valores   := Args[ 2 ].resString;
    //ShowMessage('HOLA');
    conv:=TConversor.create();
    a := conv.CadenaAMatrizText(variables);
    b := conv.CadenaAMatrizText(funciones);
    c := conv.CadenaAMatriz(valores);
    n := conv.Filas(valores);
    resul:=TJacobiana.create(a,b,c,n);
    //ShowMessage('ENTRE'+IntToStr(n));
    resp:=conv.MatrizACadena(resul.Evaluate(),n,n);
    ShowMessage( resp);
    Result.ResString:=  resp;
    //Result.ResFloat:=1;
end;
Procedure ExprNewtonGen( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  variables,funciones,valores,resp: string;
  a,b: matriztext;
  c: matriz;
  y:Real;
  n,m,o: integer;
  conv: TConversor;
  resul:TNewtonG;
begin
    //ShowMessage('HOLA');
    variables := Args[ 0 ].resString;
    funciones := Args[ 1 ].resString;
    valores   := Args[ 2 ].resString;
    y := ArgToFloat( Args[ 3 ] );
    //ShowMessage('HOLA');
    conv:=TConversor.create();
    a := conv.CadenaAMatrizText(variables);
    b := conv.CadenaAMatrizText(funciones);
    c := conv.CadenaAMatriz(valores);
    n := conv.Filas(valores);
    resul:=TNewtonG.create(a,b,c,n,y);
    //ShowMessage('ENTRE'+IntToStr(n));
    resul.Evaluate();

    resp:='Iteraciones: Xn '+ conv.MatrizTextACadena(resul.Nxntext,n,1)+#13#10
    +'Jacobianas '+ conv.MatrizTextACadena(resul.Nmultext,n,1)+#13#10
    +'Error '+ conv.MatrizACadena(resul.Nerr,n,1)+#13#10
    +'Resultado'+conv.MatrizACadena(resul.Evaluate(),n,1);
    ShowMessage( resp);
    Result.ResString:=  resp;
    //Result.ResFloat:=1;
end;
Procedure ExprMat( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  resul:TConversor;

begin
    //ShowMessage('HERE');
    fun:=Args[0].ResString;
    //ShowMessage('Entro');
    resul:=TConversor.create();
    //ShowMessage('Creado');
    Result.ResFloat:=resul.CadenaACadena(fun);

end;
Procedure ExprM( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
begin
    ShowMessage('jojojo');
    Result.ResString :='ya ';

end;
///OTROS
Procedure ExprTrapecio( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  x,y: Float;
  i:Integer;
  resul:TIntegral;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    i:= Args[3].ResInteger;
    resul:=TIntegral.create(fun,x,y,i);
    Result.resFloat := resul.TrapecioEvaluateIntegral();

end;
Procedure ExprTrapecioArea( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  x,y: Float;
  i:Integer;
  resul:TIntegral;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    i:= Args[3].ResInteger;
    resul:=TIntegral.create(fun,x,y,i);
    Result.resFloat := resul.TrapecioEvaluateArea();

end;

///THE SIMPSONS =)
Procedure ExprSimpson13( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  x,y: Float;
  i:Integer;
  resul:TIntegral;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    i:= Args[3].ResInteger;
    resul:=TIntegral.create(fun,x,y,i);
    Result.resFloat := resul.SimpsonEvaluate();

end;
Procedure ExprSimpson38( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  x,y: Float;
  i:Integer;
  resul:TIntegral;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    i:= Args[3].ResInteger;
    resul:=TIntegral.create(fun,x,y,i);
    Result.resFloat := resul.Simpson38Evaluate();

end;
Procedure ExprSimpson38Compuesto( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  x,y: Float;
  i:Integer;
  resul:TIntegral;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    i:= Args[3].ResInteger;
    resul:=TIntegral.create(fun,x,y,i);
    Result.resFloat := resul.Simpson38CompuestoEvaluate();

end;
///EDO
Procedure ExprEuler( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun,ok:String;
  x,y,yo: Float;
  n:Integer;
  resul:TEDO;

begin
   ShowMessage('HI');
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    yo:= ArgToFloat( Args[ 3 ] );
    n:= Args[4].ResInteger;
    resul:=TEDO.create(fun,x,y,yo,n);
    ShowMessage('FINAL'+FloatToStr(resul.EulerEvaluate()));
    ok:=resul.Expresion;
    Result.ResString:=ok;

end;
Procedure ExprHeun( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun,ok:String;
  x,y,yo: Float;
  n:Integer;
  resul:TEDO;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    yo:= ArgToFloat( Args[ 3 ] );
    n:= Args[4].ResInteger;
    resul:=TEDO.create(fun,x,y,yo,n);
    ShowMessage('FINAL'+FloatToStr(resul.HeunEvaluate()));
    ok:=resul.Expresion;
    Result.ResString:=ok;

end;
Procedure ExprRK3( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun,ok:String;
  x,y,yo: Float;
  n:Integer;
  resul:TEDO;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    yo:= ArgToFloat( Args[ 3 ] );
    n:= Args[4].ResInteger;
    resul:=TEDO.create(fun,x,y,yo,n);
    ShowMessage('FINAL'+FloatToStr(resul.RK3Evaluate()));
    ok:=resul.Expresion;
    Result.ResString:=ok;
    //Result.resFloat := resul.RK3Evaluate();

end;
Procedure ExprRK4( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun,ok:String;
  x,y,yo: Float;
  n:Integer;
  resul:TEDO;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    yo:= ArgToFloat( Args[ 3 ] );
    n:= Args[4].ResInteger;
    resul:=TEDO.create(fun,x,y,yo,n);
    //Result.resFloat := resul.RK4Evaluate();
    ShowMessage('FINAL'+FloatToStr(resul.RK4Evaluate()));
    ok:=resul.Expresion;
    Result.ResString:=ok;

end;
Procedure ExprEDO( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun,ok,oko:String;
  x,y,yo: Float;
  n,tipo:Integer;
  resul:TEDO;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    yo:= ArgToFloat( Args[ 3 ] );
    n:= Args[4].ResInteger;
    tipo:= Args[5].ResInteger;
    resul:=TEDO.create(fun,x,y,yo,n);
    //Result.resFloat := resul.RK4Evaluate();
    Case tipo  of
    1 :oko:='EULER FINAL '+FloatToStr(resul.EulerEvaluate());
    2 :oko:='HEUN FINAL '+FloatToStr(resul.HeunEvaluate());
    3 :oko:='RK3 FINAL '+FloatToStr(resul.RK3Evaluate());
    4 :oko:='RK4 FINAL '+FloatToStr(resul.RK4Evaluate());
    else ShowMessage('OPCION INCORRECTA 0=Euler 1=Heun 2=RK3 3=RK4');
    end;

    ok:=resul.Expresion;
    Result.ResString:=ok+#13#10+oko;

end;

Procedure ExprIntegral( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun:String;
  x,y,temporal: Float;
  i,tipo:Integer;
  resul:TIntegral;
  b:Boolean;

begin
    fun:=Args[0].ResString;
    x := ArgToFloat( Args[ 1 ] );
    y := ArgToFloat( Args[ 2 ] );
    i:= Args[3].ResInteger;
    tipo:= Args[4].ResInteger;
    b:=Args[5].ResBoolean;
    resul:=TIntegral.create(fun,x,y,i);
    temporal:=0;
    Case tipo  of
    1 : begin
        ShowMessage('Trapecio');
        if b=True then  temporal:=resul.TrapecioEvaluateArea()
                  else temporal:=resul.TrapecioEvaluateIntegral() ;
        end;
    2 : begin
        ShowMessage('Simpson 1/3');
        if b=True then  temporal:=resul.SimpsonEvaluateArea()
                  else temporal:=resul.SimpsonEvaluate() ;
        end;
    3 : begin
        ShowMessage('Simpson 3/8');
        if b=True then  temporal:=resul.Simpson38EvaluateArea()
                  else temporal:=resul.Simpson38Evaluate() ;
        end;
    4 : begin
        ShowMessage('Simpson Compuesto');
        if b=True then  temporal:=resul.Simpson38CompuestoEvaluateArea()
                  else temporal:=resul.Simpson38CompuestoEvaluate() ;
        end
    else ShowMessage('OPCION INCORRECTA 0=Trapecio 1=Simpson1/3 2=Simpson3/8 3=Siompson3/8 compuest');
    end;
    Result.resFloat := temporal;
end;

Procedure TParseMath.AddFunctions();
begin
   with FParser.Identifiers do begin
       //AddFunction(bcStrings,'pos','S','SS',@ExprLagrange);
       AddFunction('tan', 'F', 'F', @ExprTan);
       AddFunction('sin', 'F', 'F', @ExprSin);
       AddFunction('sen', 'F', 'F', @ExprSin);
       AddFunction('cos', 'F', 'F', @ExprCos);

       AddFunction('cot', 'F', 'F', @ExprCot);
       AddFunction('sec', 'F', 'F', @ExprSec);
       AddFunction('csc', 'F', 'F', @ExprCsc);

       AddFunction('ln', 'F', 'F', @ExprLn);
       AddFunction('log', 'F', 'F', @ExprLog);
       AddFunction('sqrt', 'F', 'F', @ExprSQRT);
       AddFunction('exp', 'F', 'F', @ExprExp);
       AddFunction('power', 'F', 'FF', @ExprPower); //two arguments 'FF'

       AddFunction('AddMat', 'S', 'SS', @ExprAddMat);
       AddFunction('SubMat', 'S', 'SS', @ExprSubMat);
       AddFunction('MulMat', 'S', 'SS', @ExprMulMat);
       AddFunction('MulMatEsc', 'S', 'SF', @ExprMulMatEsc);
       AddFunction('InvMat', 'S', 'S' , @ExprInvMat);
       AddFunction('DetMat', 'F', 'S' , @ExprDetMat);
       AddFunction('TransMat', 'S', 'S' , @ExprTransMat);
       AddFunction('TrazaMat', 'F', 'S' , @ExprTrazaMat);
       AddFunction('Jacobiana', 'S', 'SSS', @ExprJacob);

       ///
       AddFunction('biseccion', 'S', 'SFFF', @ExprBiy);
       AddFunction('fposicion', 'S', 'SFFF', @ExprFP);
       AddFunction('newton', 'S', 'SSFF', @ExprNewton);
       AddFunction('secante', 'S', 'SFFI', @ExprSecante);
       AddFunction('lagrange', 'S', 'SF', @ExprLagrange);
       ///ECUACIONES NO LINEALES
       AddFunction('NGen', 'S', 'SSSF', @ExprNewtonGen);

       ///INTEGRALES
       //AddFunction('integral','F','SFFIIB',@ExprIntegral)
       AddFunction('trapecio','F','SFFI', @ExprTrapecio);
       AddFunction('trapecioarea','F','SFFI', @ExprTrapecioArea);
       AddFunction('simpson13','F','SFFI', @ExprSimpson13);
       AddFunction('simpson38','F','SFFI', @ExprSimpson38);
       AddFunction('simpson38compuesto','F','SFFI', @ExprSimpson38Compuesto);
       AddFunction('integral','F','SFFIIB', @ExprIntegral);
       ///EDO
       AddFunction('euler','S','SFFFI', @ExprEuler);
       AddFunction('heun','S','SFFFI', @ExprHeun);
       AddFunction('rk3','S','SFFFI', @ExprRK3);
       AddFunction('rk4','S','SFFFI', @ExprRK4);
       AddFunction('EDO','S','SFFFII',@ExprEDO);
       ///STR aMAT
       AddFunction('mat','S','S', @ExprMat);
       AddFunction('m','S','', @ExprM);
       ///integral('fx',a,b,0123..,area si es true o false)


   end

end;

procedure TParseMath.AddVariable( Variable: string; Value: Double );
var Len: Integer;
begin
   Len:= length( identifier ) + 1;
   SetLength( identifier, Len ) ;
   identifier[ Len - 1 ]:= FParser.Identifiers.AddFloatVariable( Variable, Value);


end;




procedure TParseMath.AddVariableString( Variable: string; Value: String );
var Len: Integer;
begin
   Len:= length( identifier ) + 1;
   SetLength( identifier, Len ) ;
   identifier[ Len - 1 ]:= FParser.Identifiers.AddStringVariable( Variable, Value);


end;
end.

