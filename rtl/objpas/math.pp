{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2005 by Florian Klaempfl
    member of the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{
  This unit is an equivalent to the Delphi math unit
  (with some improvements)

  What's to do:
    o some statistical functions
    o all financial functions
    o optimizations
}

{$MODE objfpc}
{$inline on }
{$GOTO on}
unit math;
interface

{$ifndef FPUNONE}
    uses
       sysutils;

    { Ranges of the IEEE floating point types, including denormals }
{$ifdef FPC_HAS_TYPE_SINGLE}
    const
      MinSingle    =  1.5e-45;
      MaxSingle    =  3.4e+38;
{$endif FPC_HAS_TYPE_SINGLE}
{$ifdef FPC_HAS_TYPE_DOUBLE}
    const
      MinDouble    =  5.0e-324;
      MaxDouble    =  1.7e+308;
{$endif FPC_HAS_TYPE_DOUBLE}
{$ifdef FPC_HAS_TYPE_EXTENDED}
    const
      MinExtended  =  3.4e-4932;
      MaxExtended  =  1.1e+4932;
{$endif FPC_HAS_TYPE_EXTENDED}
{$ifdef FPC_HAS_TYPE_COMP}
    const
      MinComp      = -9.223372036854775807e+18;
      MaxComp      =  9.223372036854775807e+18;
{$endif FPC_HAS_TYPE_COMP}

       { the original delphi functions use extended as argument, }
       { but I would prefer double, because 8 bytes is a very    }
       { natural size for the processor                          }
       { WARNING : changing float type will                      }
       { break all assembler code  PM                            }
{$ifdef FPC_HAS_TYPE_FLOAT128}
      type
         float = float128;

      const
         MinFloat = MinFloat128;
         MaxFloat = MaxFloat128;
{$else FPC_HAS_TYPE_FLOAT128}
  {$ifdef FPC_HAS_TYPE_EXTENDED}
      type
         float = extended;

      const
         MinFloat = MinExtended;
         MaxFloat = MaxExtended;
  {$else FPC_HAS_TYPE_EXTENDED}
    {$ifdef FPC_HAS_TYPE_DOUBLE}
      type
         float = double;

      const
         MinFloat = MinDouble;
         MaxFloat = MaxDouble;
    {$else FPC_HAS_TYPE_DOUBLE}
      {$ifdef FPC_HAS_TYPE_SINGLE}
      type
         float = single;

      const
         MinFloat = MinSingle;
         MaxFloat = MaxSingle;
      {$else FPC_HAS_TYPE_SINGLE}
        {$fatal At least one floating point type must be supported}
      {$endif FPC_HAS_TYPE_SINGLE}
    {$endif FPC_HAS_TYPE_DOUBLE}
  {$endif FPC_HAS_TYPE_EXTENDED}
{$endif FPC_HAS_TYPE_FLOAT128}

    type
       PFloat = ^Float;
       PInteger = ObjPas.PInteger;

       tpaymenttime = (ptendofperiod,ptstartofperiod);

       einvalidargument = class(ematherror);

       TValueRelationship = -1..1;

    const
       EqualsValue = 0;
       LessThanValue = Low(TValueRelationship);
       GreaterThanValue = High(TValueRelationship);
{$ifopt R+}
{$define RangeCheckWasOn}
{$R-}
{$endif opt R+}
{$ifopt Q+}
{$define OverflowCheckWasOn}
{$Q-}
{$endif opt Q+}
       NaN = 0.0/0.0;
       Infinity = 1.0/0.0;
       NegInfinity = -1.0/0.0;
{$ifdef RangeCheckWasOn}
{$R+}
{$undef RangeCheckWasOn}
{$endif}
{$ifdef OverflowCheckWasOn}
{$Q+}
{$undef OverflowCheckWasOn}
{$endif}

{ Min/max determination }
function MinIntValue(const Data: array of Integer): Integer;
function MaxIntValue(const Data: array of Integer): Integer;

{ Extra, not present in Delphi, but used frequently  }
function Min(a, b: Integer): Integer;inline; overload;
function Max(a, b: Integer): Integer;inline; overload;
{ this causes more trouble than it solves
function Min(a, b: Cardinal): Cardinal; overload;
function Max(a, b: Cardinal): Cardinal; overload;
}
function Min(a, b: Int64): Int64;inline; overload;
function Max(a, b: Int64): Int64;inline; overload;
{$ifdef FPC_HAS_TYPE_SINGLE}
function Min(a, b: Single): Single;inline; overload;
function Max(a, b: Single): Single;inline; overload;
{$endif FPC_HAS_TYPE_SINGLE}
{$ifdef FPC_HAS_TYPE_DOUBLE}
function Min(a, b: Double): Double;inline; overload;
function Max(a, b: Double): Double;inline; overload;
{$endif FPC_HAS_TYPE_DOUBLE}
{$ifdef FPC_HAS_TYPE_EXTENDED}
function Min(a, b: Extended): Extended;inline; overload;
function Max(a, b: Extended): Extended;inline; overload;
{$endif FPC_HAS_TYPE_EXTENDED}

function InRange(const AValue, AMin, AMax: Integer): Boolean;inline; overload;
function InRange(const AValue, AMin, AMax: Int64): Boolean;inline; overload;
{$ifdef FPC_HAS_TYPE_DOUBLE}
function InRange(const AValue, AMin, AMax: Double): Boolean;inline;  overload;
{$endif FPC_HAS_TYPE_DOUBLE}

function EnsureRange(const AValue, AMin, AMax: Integer): Integer;inline;  overload;
function EnsureRange(const AValue, AMin, AMax: Int64): Int64;inline;  overload;
{$ifdef FPC_HAS_TYPE_DOUBLE}
function EnsureRange(const AValue, AMin, AMax: Double): Double;inline;  overload;
{$endif FPC_HAS_TYPE_DOUBLE}


procedure DivMod(Dividend: Integer; Divisor: Word;  var Result, Remainder: Word);
procedure DivMod(Dividend: Integer; Divisor: Word; var Result, Remainder: SmallInt);
procedure DivMod(Dividend: DWord; Divisor: DWord; var Result, Remainder: DWord);
procedure DivMod(Dividend: Integer; Divisor: Integer; var Result, Remainder: Integer);

// Sign functions
Type
  TValueSign = -1..1;

const
  NegativeValue = Low(TValueSign);
  ZeroValue = 0;
  PositiveValue = High(TValueSign);

function Sign(const AValue: Integer): TValueSign;inline; overload;
function Sign(const AValue: Int64): TValueSign;inline; overload;
{$ifdef FPC_HAS_TYPE_SINGLE}
function Sign(const AValue: Single): TValueSign;inline; overload;
{$endif}
function Sign(const AValue: Double): TValueSign;inline; overload;
{$ifdef FPC_HAS_TYPE_EXTENDED}
function Sign(const AValue: Extended): TValueSign;inline; overload;
{$endif}

function IsZero(const A: Single; Epsilon: Single): Boolean; overload;
function IsZero(const A: Single): Boolean;inline; overload;
{$ifdef FPC_HAS_TYPE_DOUBLE}
function IsZero(const A: Double; Epsilon: Double): Boolean; overload;
function IsZero(const A: Double): Boolean;inline; overload;
{$endif FPC_HAS_TYPE_DOUBLE}
{$ifdef FPC_HAS_TYPE_EXTENDED}
function IsZero(const A: Extended; Epsilon: Extended): Boolean; overload;
function IsZero(const A: Extended): Boolean;inline; overload;
{$endif FPC_HAS_TYPE_EXTENDED}

function IsNan(const d : Double): Boolean; overload;
function IsInfinite(const d : Double): Boolean;

{$ifdef FPC_HAS_TYPE_EXTENDED}
function SameValue(const A, B: Extended): Boolean;inline; overload;
{$endif}
{$ifdef FPC_HAS_TYPE_DOUBLE}
function SameValue(const A, B: Double): Boolean;inline; overload;
{$endif}
function SameValue(const A, B: Single): Boolean;inline; overload;
{$ifdef FPC_HAS_TYPE_EXTENDED}
function SameValue(const A, B: Extended; Epsilon: Extended): Boolean; overload;
{$endif}
{$ifdef FPC_HAS_TYPE_DOUBLE}
function SameValue(const A, B: Double; Epsilon: Double): Boolean; overload;
{$endif}
function SameValue(const A, B: Single; Epsilon: Single): Boolean; overload;

type
  TRoundToRange = -37..37;

{$ifdef FPC_HAS_TYPE_DOUBLE}
function RoundTo(const AValue: Double; const Digits: TRoundToRange): Double;
{$endif}
{$ifdef FPC_HAS_TYPE_EXTENDED}
function RoundTo(const AVAlue: Extended; const Digits: TRoundToRange): Extended;
{$endif}
{$ifdef FPC_HAS_TYPE_SINGLE}
function RoundTo(const AValue: Single; const Digits: TRoundToRange): Single;
{$endif}
{$ifdef FPC_HAS_TYPE_SINGLE}
function SimpleRoundTo(const AValue: Single; const Digits: TRoundToRange = -2): Single;
{$endif}
{$ifdef FPC_HAS_TYPE_DOUBLE}
function SimpleRoundTo(const AValue: Double; const Digits: TRoundToRange = -2): Double;
{$endif}
{$ifdef FPC_HAS_TYPE_EXTENDED}
function SimpleRoundTo(const AValue: Extended; const Digits: TRoundToRange = -2): Extended;
{$endif}


{ angle conversion }

function degtorad(deg : float) : float;
function radtodeg(rad : float) : float;
function gradtorad(grad : float) : float;
function radtograd(rad : float) : float;
function degtograd(deg : float) : float;
function gradtodeg(grad : float) : float;
{ one cycle are 2*Pi rad }
function cycletorad(cycle : float) : float;
function radtocycle(rad : float) : float;

{ trigoniometric functions }

function tan(x : float) : float;
function cotan(x : float) : float;
function cot(x : float) : float; inline;
procedure sincos(theta : float;out sinus,cosinus : float);

function secant(x : float) : float; inline;
function cosecant(x : float) : float; inline;
function sec(x : float) : float; inline;
function csc(x : float) : float; inline;

{ inverse functions }

function arccos(x : float) : float;
function arcsin(x : float) : float;

{ calculates arctan(y/x) and returns an angle in the correct quadrant }
function arctan2(y,x : float) : float;

{ hyperbolic functions }

function cosh(x : float) : float;
function sinh(x : float) : float;
function tanh(x : float) : float;

{ area functions }

{ delphi names: }
function arccosh(x : float) : float;
function arcsinh(x : float) : float;
function arctanh(x : float) : float;
{ IMHO the function should be called as follows (FK) }
function arcosh(x : float) : float;
function arsinh(x : float) : float;
function artanh(x : float) : float;

{ triangle functions }

{ returns the length of the hypotenuse of a right triangle }
{ if x and y are the other sides                           }
function hypot(x,y : float) : float;

{ logarithm functions }

function log10(x : float) : float;
function log2(x : float) : float;
function logn(n,x : float) : float;

{ returns natural logarithm of x+1 }
function lnxp1(x : float) : float;

{ exponential functions }

function power(base,exponent : float) : float;
{ base^exponent }
function intpower(base : float;const exponent : Integer) : float;

operator ** (bas,expo : float) e: float; inline;
operator ** (bas,expo : int64) i: int64; inline;

{ number converting }

{ rounds x towards positive infinity }
function ceil(x : float) : Integer;
{ rounds x towards negative infinity }
function floor(x : float) : Integer;

{ misc. functions }

{ splits x into mantissa and exponent (to base 2) }
procedure Frexp(X: float; var Mantissa: float; var Exponent: integer);
{ returns x*(2^p) }
function ldexp(x : float; const p : Integer) : float;

{ statistical functions }

{$ifdef FPC_HAS_TYPE_SINGLE}
function mean(const data : array of Single) : float;
function sum(const data : array of Single) : float;
function mean(const data : PSingle; Const N : longint) : float;
function sum(const data : PSingle; Const N : Longint) : float;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function mean(const data : array of double) : float;
function sum(const data : array of double) : float;
function mean(const data : PDouble; Const N : longint) : float;
function sum(const data : PDouble; Const N : Longint) : float;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function mean(const data : array of Extended) : float;
function sum(const data : array of Extended) : float;
function mean(const data : PExtended; Const N : longint) : float;
function sum(const data : PExtended; Const N : Longint) : float;
{$endif FPC_HAS_TYPE_EXTENDED}

function sumInt(const data : PInt64;Const N : longint) : Int64;
function sumInt(const data : array of Int64) : Int64;

{$ifdef FPC_HAS_TYPE_SINGLE}
function sumofsquares(const data : array of Single) : float;
function sumofsquares(const data : PSingle; Const N : Integer) : float;
{ calculates the sum and the sum of squares of data }
procedure sumsandsquares(const data : array of Single;
  var sum,sumofsquares : float);
procedure sumsandsquares(const data : PSingle; Const N : Integer;
  var sum,sumofsquares : float);
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function sumofsquares(const data : array of double) : float;
function sumofsquares(const data : PDouble; Const N : Integer) : float;
{ calculates the sum and the sum of squares of data }
procedure sumsandsquares(const data : array of Double;
  var sum,sumofsquares : float);
procedure sumsandsquares(const data : PDouble; Const N : Integer;
  var sum,sumofsquares : float);
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function sumofsquares(const data : array of Extended) : float;
function sumofsquares(const data : PExtended; Const N : Integer) : float;
{ calculates the sum and the sum of squares of data }
procedure sumsandsquares(const data : array of Extended;
  var sum,sumofsquares : float);
procedure sumsandsquares(const data : PExtended; Const N : Integer;
  var sum,sumofsquares : float);
{$endif FPC_HAS_TYPE_EXTENDED}

{$ifdef FPC_HAS_TYPE_SINGLE}
function minvalue(const data : array of Single) : Single;
function minvalue(const data : PSingle; Const N : Integer) : Single;
function maxvalue(const data : array of Single) : Single;
function maxvalue(const data : PSingle; Const N : Integer) : Single;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function minvalue(const data : array of Double) : Double;
function minvalue(const data : PDouble; Const N : Integer) : Double;
function maxvalue(const data : array of Double) : Double;
function maxvalue(const data : PDouble; Const N : Integer) : Double;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function minvalue(const data : array of Extended) : Extended;
function minvalue(const data : PExtended; Const N : Integer) : Extended;
function maxvalue(const data : array of Extended) : Extended;
function maxvalue(const data : PExtended; Const N : Integer) : Extended;
{$endif FPC_HAS_TYPE_EXTENDED}

function minvalue(const data : array of integer) : Integer;
function MinValue(const Data : PInteger; Const N : Integer): Integer;

function maxvalue(const data : array of integer) : Integer;
function maxvalue(const data : PInteger; Const N : Integer) : Integer;

{ returns random values with gaussian distribution }
function randg(mean,stddev : float) : float;
function RandomRange(const aFrom, aTo: Integer): Integer;

{$ifdef FPC_HAS_TYPE_SINGLE}
{ calculates the standard deviation }
function stddev(const data : array of Single) : float;
function stddev(const data : PSingle; Const N : Integer) : float;
{ calculates the mean and stddev }
procedure meanandstddev(const data : array of Single;
  var mean,stddev : float);
procedure meanandstddev(const data : PSingle;
  Const N : Longint;var mean,stddev : float);
function variance(const data : array of Single) : float;
function totalvariance(const data : array of Single) : float;
function variance(const data : PSingle; Const N : Integer) : float;
function totalvariance(const data : PSingle; Const N : Integer) : float;

{ I don't know what the following functions do: }
function popnstddev(const data : array of Single) : float;
function popnstddev(const data : PSingle; Const N : Integer) : float;
function popnvariance(const data : PSingle; Const N : Integer) : float;
function popnvariance(const data : array of Single) : float;
procedure momentskewkurtosis(const data : array of Single;
  out m1,m2,m3,m4,skew,kurtosis : float);
procedure momentskewkurtosis(const data : PSingle; Const N : Integer;
  out m1,m2,m3,m4,skew,kurtosis : float);

{ geometrical function }

{ returns the euclidean L2 norm }
function norm(const data : array of Single) : float;
function norm(const data : PSingle; Const N : Integer) : float;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
{ calculates the standard deviation }
function stddev(const data : array of Double) : float;
function stddev(const data : PDouble; Const N : Integer) : float;
{ calculates the mean and stddev }
procedure meanandstddev(const data : array of Double;
  var mean,stddev : float);
procedure meanandstddev(const data : PDouble;
  Const N : Longint;var mean,stddev : float);
function variance(const data : array of Double) : float;
function totalvariance(const data : array of Double) : float;
function variance(const data : PDouble; Const N : Integer) : float;
function totalvariance(const data : PDouble; Const N : Integer) : float;

{ I don't know what the following functions do: }
function popnstddev(const data : array of Double) : float;
function popnstddev(const data : PDouble; Const N : Integer) : float;
function popnvariance(const data : PDouble; Const N : Integer) : float;
function popnvariance(const data : array of Double) : float;
procedure momentskewkurtosis(const data : array of Double;
  out m1,m2,m3,m4,skew,kurtosis : float);
procedure momentskewkurtosis(const data : PDouble; Const N : Integer;
  out m1,m2,m3,m4,skew,kurtosis : float);

{ geometrical function }

{ returns the euclidean L2 norm }
function norm(const data : array of double) : float;
function norm(const data : PDouble; Const N : Integer) : float;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
{ calculates the standard deviation }
function stddev(const data : array of Extended) : float;
function stddev(const data : PExtended; Const N : Integer) : float;
{ calculates the mean and stddev }
procedure meanandstddev(const data : array of Extended;
  var mean,stddev : float);
procedure meanandstddev(const data : PExtended;
  Const N : Longint;var mean,stddev : float);
function variance(const data : array of Extended) : float;
function totalvariance(const data : array of Extended) : float;
function variance(const data : PExtended; Const N : Integer) : float;
function totalvariance(const data : PExtended; Const N : Integer) : float;

{ I don't know what the following functions do: }
function popnstddev(const data : array of Extended) : float;
function popnstddev(const data : PExtended; Const N : Integer) : float;
function popnvariance(const data : PExtended; Const N : Integer) : float;
function popnvariance(const data : array of Extended) : float;
procedure momentskewkurtosis(const data : array of Extended;
  out m1,m2,m3,m4,skew,kurtosis : float);
procedure momentskewkurtosis(const data : PExtended; Const N : Integer;
  out m1,m2,m3,m4,skew,kurtosis : float);

{ geometrical function }

{ returns the euclidean L2 norm }
function norm(const data : array of Extended) : float;
function norm(const data : PExtended; Const N : Integer) : float;
{$endif FPC_HAS_TYPE_EXTENDED}

function ifthen(val:boolean;const iftrue:integer; const iffalse:integer= 0) :integer; inline; overload;
function ifthen(val:boolean;const iftrue:int64  ; const iffalse:int64 = 0)  :int64;   inline; overload;
function ifthen(val:boolean;const iftrue:double ; const iffalse:double =0.0):double;  inline; overload;

function CompareValue ( const A, B  : Integer) : TValueRelationship; inline;
function CompareValue ( const A, B  : Int64) : TValueRelationship; inline;
function CompareValue ( const A, B  : QWord) : TValueRelationship; inline;

{$ifdef FPC_HAS_TYPE_SINGLE}
function CompareValue ( const A, B : Single; delta : Single = 0.0 ) : TValueRelationship; inline;
{$endif}
{$ifdef FPC_HAS_TYPE_DOUBLE}
function CompareValue ( const A, B : Double; delta : Double = 0.0) : TValueRelationship; inline;
{$endif}
{$ifdef FPC_HAS_TYPE_EXTENDED}
function CompareValue ( const A, B : Extended; delta : Extended = 0.0 ) : TValueRelationship; inline;
{$endif}

function RandomFrom(const AValues: array of Double): Double; overload;
function RandomFrom(const AValues: array of Integer): Integer; overload;
function RandomFrom(const AValues: array of Int64): Int64; overload;

{ include cpu specific stuff }
{$i mathuh.inc}

implementation

{ include cpu specific stuff }
{$i mathu.inc}

ResourceString
  SMathError = 'Math Error : %s';
  SInvalidArgument = 'Invalid argument';

Procedure DoMathError(Const S : String);
begin
  Raise EMathError.CreateFmt(SMathError,[S]);
end;

Procedure InvalidArgument;

begin
  Raise EInvalidArgument.Create(SInvalidArgument);
end;


function Sign(const AValue: Integer): TValueSign;inline;

begin
  If Avalue<0 then
    Result:=NegativeValue
  else If Avalue>0 then
    Result:=PositiveValue
  else
    Result:=ZeroValue;
end;

function Sign(const AValue: Int64): TValueSign;inline;

begin
  If Avalue<0 then
    Result:=NegativeValue
  else If Avalue>0 then
    Result:=PositiveValue
  else
    Result:=ZeroValue;
end;

{$ifdef FPC_HAS_TYPE_SINGLE}
function Sign(const AValue: Single): TValueSign;inline;

begin
  If Avalue<0.0 then
    Result:=NegativeValue
  else If Avalue>0.0 then
    Result:=PositiveValue
  else
    Result:=ZeroValue;
end;
{$endif}


function Sign(const AValue: Double): TValueSign;inline;

begin
  If Avalue<0.0 then
    Result:=NegativeValue
  else If Avalue>0.0 then
    Result:=PositiveValue
  else
    Result:=ZeroValue;
end;

{$ifdef FPC_HAS_TYPE_EXTENDED}
function Sign(const AValue: Extended): TValueSign;inline;

begin
  If Avalue<0.0 then
    Result:=NegativeValue
  else If Avalue>0.0 then
    Result:=PositiveValue
  else
    Result:=ZeroValue;
end;
{$endif}

function degtorad(deg : float) : float;

  begin
     degtorad:=deg*(pi/180.0);
  end;

function radtodeg(rad : float) : float;

  begin
     radtodeg:=rad*(180.0/pi);
  end;

function gradtorad(grad : float) : float;

  begin
     gradtorad:=grad*(pi/200.0);
  end;

function radtograd(rad : float) : float;

  begin
     radtograd:=rad*(200.0/pi);
  end;

function degtograd(deg : float) : float;

  begin
     degtograd:=deg*(200.0/180.0);
  end;

function gradtodeg(grad : float) : float;

  begin
     gradtodeg:=grad*(180.0/200.0);
  end;

function cycletorad(cycle : float) : float;

  begin
     cycletorad:=(2*pi)*cycle;
  end;

function radtocycle(rad : float) : float;

  begin
     { avoid division }
     radtocycle:=rad*(1/(2*pi));
  end;

{$ifndef FPC_MATH_HAS_TAN}
function tan(x : float) : float;
  var
    _sin,_cos : float;
  begin
    sincos(x,_sin,_cos);
    tan:=_sin/_cos;
  end;
{$endif FPC_MATH_HAS_TAN}


{$ifndef FPC_MATH_HAS_COTAN}
function cotan(x : float) : float;
  var
    _sin,_cos : float;
  begin
    sincos(x,_sin,_cos);
    cotan:=_cos/_sin;
  end;
{$endif FPC_MATH_HAS_COTAN}

function cot(x : float) : float; inline;
begin
  cot := cotan(x);
end;


{$ifndef FPC_MATH_HAS_SINCOS}
procedure sincos(theta : float;out sinus,cosinus : float);
  begin
    sinus:=sin(theta);
    cosinus:=cos(theta);
  end;
{$endif FPC_MATH_HAS_SINCOS}


function secant(x : float) : float; inline;
begin
  secant := 1 / cos(x);
end;


function cosecant(x : float) : float; inline;
begin
  cosecant := 1 / sin(x);
end;


function sec(x : float) : float; inline;
begin
  sec := secant(x);
end;


function csc(x : float) : float; inline;
begin
  csc := cosecant(x);
end;


{ ArcSin and ArcCos from Arjan van Dijk (arjan.vanDijk@User.METAIR.WAU.NL) }


function arcsin(x : float) : float;
begin
  if abs(x) > 1 then InvalidArgument
  else if abs(x) < 0.5 then
    arcsin := arctan(x/sqrt(1-sqr(x)))
  else
    arcsin := sign(x) * (pi*0.5 - arctan(sqrt(1 / sqr(x) - 1)));
end;

function Arccos(x : Float) : Float;
begin
  arccos := pi*0.5 - arcsin(x);
end;


{$ifndef FPC_MATH_HAS_ARCTAN2}
function arctan2(y,x : float) : float;
  begin
    if (x=0) then
      begin
        if y=0 then
          arctan2:=0.0
        else if y>0 then
          arctan2:=pi/2
        else if y<0 then
          arctan2:=-pi/2;
      end
    else
      ArcTan2:=ArcTan(y/x);
    if x<0.0 then
      ArcTan2:=ArcTan2+pi;
    if ArcTan2>pi then
      ArcTan2:=ArcTan2-2*pi;
  end;
{$endif FPC_MATH_HAS_ARCTAN2}


function cosh(x : float) : float;

  var
     temp : float;

  begin
     temp:=exp(x);
     cosh:=0.5*(temp+1.0/temp);
  end;

function sinh(x : float) : float;

  var
     temp : float;

  begin
     temp:=exp(x);
     sinh:=0.5*(temp-1.0/temp);
  end;

Const MaxTanh = 5678.22249441322; // Ln(MaxExtended)/2

function tanh(x : float) : float;

  var Temp : float;

  begin
     if x>MaxTanh then exit(1.0)
     else if x<-MaxTanh then exit (-1.0);
     temp:=exp(-2*x);
     tanh:=(1-temp)/(1+temp)
  end;

function arccosh(x : float) : float;

  begin
     arccosh:=arcosh(x);
  end;

function arcsinh(x : float) : float;

  begin
     arcsinh:=arsinh(x);
  end;

function arctanh(x : float) : float;

  begin
     if x>1 then InvalidArgument;
     arctanh:=artanh(x);
  end;

function arcosh(x : float) : float;

  begin
     if x<1 then InvalidArgument;
     arcosh:=Ln(x+Sqrt(x*x-1));
  end;

function arsinh(x : float) : float;

  begin
     arsinh:=Ln(x+Sqrt(1+x*x));
  end;

function artanh(x : float) : float;
  begin
    If abs(x)>1 then InvalidArgument;
    artanh:=(Ln((1+x)/(1-x)))*0.5;
  end;

function hypot(x,y : float) : float;

  begin
     hypot:=Sqrt(x*x+y*y)
  end;

function log10(x : float) : float;

  begin
     log10:=ln(x)/ln(10);
  end;

function log2(x : float) : float;

  begin
     log2:=ln(x)/ln(2)
  end;

function logn(n,x : float) : float;

  begin
     if n<0 then InvalidArgument;
     logn:=ln(x)/ln(n);
  end;

function lnxp1(x : float) : float;

  begin
     if x<-1 then
       InvalidArgument;
     lnxp1:=ln(1+x);
  end;

function power(base,exponent : float) : float;

  begin
    if Exponent=0.0 then
      if base <> 0.0 then
        result:=1.0
      else
        InvalidArgument
    else if (base=0.0) and (exponent>0.0) then
      result:=0.0
    else if (abs(exponent)<=maxint) and (frac(exponent)=0.0) then
      result:=intpower(base,trunc(exponent))
    else if base>0.0 then
      result:=exp(exponent * ln (base))
    else
      InvalidArgument;
  end;

function intpower(base : float;const exponent : Integer) : float;

  var
     i : longint;

  begin
     if (base = 0.0) and (exponent = 0) then
       InvalidArgument;
     i:=abs(exponent);
     intpower:=1.0;
     while i>0 do
       begin
          while (i and 1)=0 do
            begin
               i:=i shr 1;
               base:=sqr(base);
            end;
          i:=i-1;
          intpower:=intpower*base;
       end;
     if exponent<0 then
       intpower:=1.0/intpower;
  end;


operator ** (bas,expo : float) e: float; inline;
  begin
    e:=power(bas,expo);
  end;


operator ** (bas,expo : int64) i: int64; inline;
  begin
    i:=round(intpower(bas,expo));
  end;


function ceil(x : float) : integer;

  begin
    Ceil:=Trunc(x);
    If Frac(x)>0 then
      Ceil:=Ceil+1;
  end;

function floor(x : float) : integer;

  begin
     Floor:=Trunc(x);
     If Frac(x)<0 then
       Floor := Floor-1;
  end;


procedure Frexp(X: float; var Mantissa: float; var Exponent: integer);
begin
  Exponent:=0;
  if (X<>0) then
    if (abs(X)<0.5) then
      repeat
        X:=X*2;
        Dec(Exponent);
      until (abs(X)>=0.5)
    else
      while (abs(X)>=1) do
        begin
        X:=X/2;
        Inc(Exponent);
        end;
  Mantissa:=X;
end;

function ldexp(x : float;const p : Integer) : float;

  begin
     ldexp:=x*intpower(2.0,p);
  end;

{$ifdef FPC_HAS_TYPE_SINGLE}
function mean(const data : array of Single) : float;

  begin
     Result:=Mean(PSingle(@data[0]),High(Data)+1);
  end;

function mean(const data : PSingle; Const N : longint) : float;

  begin
     mean:=sum(Data,N);
     mean:=mean/N;
  end;

function sum(const data : array of Single) : float;

  begin
     Result:=Sum(PSingle(@Data[0]),High(Data)+1);
  end;

function sum(const data : PSingle;Const N : longint) : float;

  var
     i : longint;

  begin
     sum:=0.0;
     for i:=0 to N-1 do
       sum:=sum+data[i];
  end;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function mean(const data : array of Double) : float;

  begin
     Result:=Mean(PDouble(@data[0]),High(Data)+1);
  end;

function mean(const data : PDouble; Const N : longint) : float;

  begin
     mean:=sum(Data,N);
     mean:=mean/N;
  end;

function sum(const data : array of Double) : float;

  begin
     Result:=Sum(PDouble(@Data[0]),High(Data)+1);
  end;

function sum(const data : PDouble;Const N : longint) : float;

  var
     i : longint;

  begin
     sum:=0.0;
     for i:=0 to N-1 do
       sum:=sum+data[i];
  end;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function mean(const data : array of Extended) : float;

  begin
     Result:=Mean(PExtended(@data[0]),High(Data)+1);
  end;

function mean(const data : PExtended; Const N : longint) : float;

  begin
     mean:=sum(Data,N);
     mean:=mean/N;
  end;

function sum(const data : array of Extended) : float;

  begin
     Result:=Sum(PExtended(@Data[0]),High(Data)+1);
  end;

function sum(const data : PExtended;Const N : longint) : float;

  var
     i : longint;

  begin
     sum:=0.0;
     for i:=0 to N-1 do
       sum:=sum+data[i];
  end;
{$endif FPC_HAS_TYPE_EXTENDED}

function sumInt(const data : PInt64;Const N : longint) : Int64;

  var
     i : longint;

  begin
     sumInt:=0;
     for i:=0 to N-1 do
       sumInt:=sumInt+data[i];
  end;

function sumInt(const data : array of Int64) : Int64;

  begin
     Result:=SumInt(@Data[0],High(Data)+1);
  end;

{$ifdef FPC_HAS_TYPE_SINGLE}
 function sumofsquares(const data : array of Single) : float;

 begin
   Result:=sumofsquares(PSingle(@data[0]),High(Data)+1);
 end;

 function sumofsquares(const data : PSingle; Const N : Integer) : float;

  var
     i : longint;

  begin
     sumofsquares:=0.0;
     for i:=0 to N-1 do
       sumofsquares:=sumofsquares+sqr(data[i]);
  end;

procedure sumsandsquares(const data : array of Single;
  var sum,sumofsquares : float);

begin
  sumsandsquares (PSingle(@Data[0]),High(Data)+1,Sum,sumofsquares);
end;

procedure sumsandsquares(const data : PSingle; Const N : Integer;
  var sum,sumofsquares : float);

  var
     i : Integer;
     temp : float;

  begin
     sumofsquares:=0.0;
     sum:=0.0;
     for i:=0 to N-1 do
       begin
          temp:=data[i];
          sumofsquares:=sumofsquares+sqr(temp);
          sum:=sum+temp;
       end;
  end;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
 function sumofsquares(const data : array of Double) : float;

 begin
   Result:=sumofsquares(PDouble(@data[0]),High(Data)+1);
 end;

 function sumofsquares(const data : PDouble; Const N : Integer) : float;

  var
     i : longint;

  begin
     sumofsquares:=0.0;
     for i:=0 to N-1 do
       sumofsquares:=sumofsquares+sqr(data[i]);
  end;

procedure sumsandsquares(const data : array of Double;
  var sum,sumofsquares : float);

begin
  sumsandsquares (PDouble(@Data[0]),High(Data)+1,Sum,sumofsquares);
end;

procedure sumsandsquares(const data : PDouble; Const N : Integer;
  var sum,sumofsquares : float);

  var
     i : Integer;
     temp : float;

  begin
     sumofsquares:=0.0;
     sum:=0.0;
     for i:=0 to N-1 do
       begin
          temp:=data[i];
          sumofsquares:=sumofsquares+sqr(temp);
          sum:=sum+temp;
       end;
  end;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
 function sumofsquares(const data : array of Extended) : float;

 begin
   Result:=sumofsquares(PExtended(@data[0]),High(Data)+1);
 end;

 function sumofsquares(const data : PExtended; Const N : Integer) : float;

  var
     i : longint;

  begin
     sumofsquares:=0.0;
     for i:=0 to N-1 do
       sumofsquares:=sumofsquares+sqr(data[i]);
  end;

procedure sumsandsquares(const data : array of Extended;
  var sum,sumofsquares : float);

begin
  sumsandsquares (PExtended(@Data[0]),High(Data)+1,Sum,sumofsquares);
end;

procedure sumsandsquares(const data : PExtended; Const N : Integer;
  var sum,sumofsquares : float);

  var
     i : Integer;
     temp : float;

  begin
     sumofsquares:=0.0;
     sum:=0.0;
     for i:=0 to N-1 do
       begin
          temp:=data[i];
          sumofsquares:=sumofsquares+sqr(temp);
          sum:=sum+temp;
       end;
  end;
{$endif FPC_HAS_TYPE_EXTENDED}

function randg(mean,stddev : float) : float;

  Var U1,S2 : Float;

  begin
     repeat
       u1:= 2*random-1;
       S2:=Sqr(U1)+sqr(2*random-1);
     until s2<1;
     randg:=Sqrt(-2*ln(S2)/S2)*u1*stddev+Mean;
  end;


function RandomRange(const aFrom, aTo: Integer): Integer;
begin
  Result:=Random(Abs(aFrom-aTo))+Min(aTo,AFrom);
end;


{$ifdef FPC_HAS_TYPE_SINGLE}
function stddev(const data : array of Single) : float;

begin
  Result:=Stddev(PSingle(@Data[0]),High(Data)+1)
end;

function stddev(const data : PSingle; Const N : Integer) : float;

  begin
     StdDev:=Sqrt(Variance(Data,N));
  end;

procedure meanandstddev(const data : array of Single;
  var mean,stddev : float);

begin
  Meanandstddev(PSingle(@Data[0]),High(Data)+1,Mean,stddev);
end;

procedure meanandstddev(const data : PSingle;
  Const N : Longint;var mean,stddev : float);

Var I : longint;

begin
  Mean:=0;
  StdDev:=0;
  For I:=0 to N-1 do
    begin
    Mean:=Mean+Data[i];
    StdDev:=StdDev+Sqr(Data[i]);
    end;
  Mean:=Mean/N;
  StdDev:=(StdDev-N*Sqr(Mean));
  If N>1 then
    StdDev:=Sqrt(Stddev/(N-1))
  else
    StdDev:=0;
end;

function variance(const data : array of Single) : float;

  begin
     Variance:=Variance(PSingle(@Data[0]),High(Data)+1);
  end;

function variance(const data : PSingle; Const N : Integer) : float;

  begin
     If N=1 then
       Result:=0
     else
       Result:=TotalVariance(Data,N)/(N-1);
  end;

function totalvariance(const data : array of Single) : float;

begin
  Result:=TotalVariance(PSingle(@Data[0]),High(Data)+1);
end;

function totalvariance(const data : PSingle;Const N : Integer) : float;

   var S,SS : Float;

  begin
    If N=1 then
      Result:=0
    else
      begin
      SumsAndSquares(Data,N,S,SS);
      Result := SS-Sqr(S)/N;
      end;
  end;


function popnstddev(const data : array of Single) : float;

  begin
     PopnStdDev:=Sqrt(PopnVariance(PSingle(@Data[0]),High(Data)+1));
  end;

function popnstddev(const data : PSingle; Const N : Integer) : float;

  begin
     PopnStdDev:=Sqrt(PopnVariance(Data,N));
  end;

function popnvariance(const data : array of Single) : float;

begin
  popnvariance:=popnvariance(PSingle(@data[0]),high(Data)+1);
end;

function popnvariance(const data : PSingle; Const N : Integer) : float;

  begin
     PopnVariance:=TotalVariance(Data,N)/N;
  end;

procedure momentskewkurtosis(const data : array of single;
  out m1,m2,m3,m4,skew,kurtosis : float);

begin
  momentskewkurtosis(PSingle(@Data[0]),High(Data)+1,m1,m2,m3,m4,skew,kurtosis);
end;

procedure momentskewkurtosis(
  const data: pSingle;
  Const N: integer;
  out m1: float;
  out m2: float;
  out m3: float;
  out m4: float;
  out skew: float;
  out kurtosis: float
);
var
  i: integer;
  value : psingle;
  deviation, deviation2: single;
  reciprocalN: float;
begin
  m1 := 0;
  reciprocalN := 1/N;
  value := data;
  for i := 0 to N-1 do
  begin
    m1 := m1 + value^;
    inc(value);
  end;
  m1 := reciprocalN * m1;

  m2 := 0;
  m3 := 0;
  m4 := 0;
  value := data;
  for i := 0 to N-1 do
  begin
    deviation := (value^-m1);
    deviation2 := deviation * deviation;
    m2 := m2 + deviation2;
    m3 := m3 + deviation2 * deviation;
    m4 := m4 + deviation2 * deviation2;
    inc(value);
  end;
  m2 := reciprocalN * m2;
  m3 := reciprocalN * m3;
  m4 := reciprocalN * m4;

  skew := m3 / (sqrt(m2)*m2);
  kurtosis := m4 / (m2 * m2);
end;

function norm(const data : array of Single) : float;

  begin
     norm:=Norm(PSingle(@data[0]),High(Data)+1);
  end;

function norm(const data : PSingle; Const N : Integer) : float;

  begin
     norm:=sqrt(sumofsquares(data,N));
  end;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function stddev(const data : array of Double) : float;

begin
  Result:=Stddev(PDouble(@Data[0]),High(Data)+1)
end;

function stddev(const data : PDouble; Const N : Integer) : float;

  begin
     StdDev:=Sqrt(Variance(Data,N));
  end;

procedure meanandstddev(const data : array of Double;
  var mean,stddev : float);

begin
  Meanandstddev(PDouble(@Data[0]),High(Data)+1,Mean,stddev);
end;

procedure meanandstddev(const data : PDouble;
  Const N : Longint;var mean,stddev : float);

Var I : longint;

begin
  Mean:=0;
  StdDev:=0;
  For I:=0 to N-1 do
    begin
    Mean:=Mean+Data[i];
    StdDev:=StdDev+Sqr(Data[i]);
    end;
  Mean:=Mean/N;
  StdDev:=(StdDev-N*Sqr(Mean));
  If N>1 then
    StdDev:=Sqrt(Stddev/(N-1))
  else
    StdDev:=0;
end;

function variance(const data : array of Double) : float;

  begin
     Variance:=Variance(PDouble(@Data[0]),High(Data)+1);
  end;

function variance(const data : PDouble; Const N : Integer) : float;

  begin
     If N=1 then
       Result:=0
     else
       Result:=TotalVariance(Data,N)/(N-1);
  end;

function totalvariance(const data : array of Double) : float;

begin
  Result:=TotalVariance(PDouble(@Data[0]),High(Data)+1);
end;

function totalvariance(const data : PDouble;Const N : Integer) : float;

   var S,SS : Float;

  begin
    If N=1 then
      Result:=0
    else
      begin
      SumsAndSquares(Data,N,S,SS);
      Result := SS-Sqr(S)/N;
      end;
  end;


function popnstddev(const data : array of Double) : float;

  begin
     PopnStdDev:=Sqrt(PopnVariance(PDouble(@Data[0]),High(Data)+1));
  end;

function popnstddev(const data : PDouble; Const N : Integer) : float;

  begin
     PopnStdDev:=Sqrt(PopnVariance(Data,N));
  end;

function popnvariance(const data : array of Double) : float;

begin
  popnvariance:=popnvariance(PDouble(@data[0]),high(Data)+1);
end;

function popnvariance(const data : PDouble; Const N : Integer) : float;

  begin
     PopnVariance:=TotalVariance(Data,N)/N;
  end;

procedure momentskewkurtosis(const data : array of Double;
  out m1,m2,m3,m4,skew,kurtosis : float);

begin
  momentskewkurtosis(PDouble(@Data[0]),High(Data)+1,m1,m2,m3,m4,skew,kurtosis);
end;

procedure momentskewkurtosis(
  const data: pdouble;
  Const N: integer;
  out m1: float;
  out m2: float;
  out m3: float;
  out m4: float;
  out skew: float;
  out kurtosis: float
);
var
  i: integer;
  value : pdouble;
  deviation, deviation2: double;
  reciprocalN: float;
begin
  m1 := 0;
  reciprocalN := 1/N;
  value := data;
  for i := 0 to N-1 do
  begin
    m1 := m1 + value^;
    inc(value);
  end;
  m1 := reciprocalN * m1;

  m2 := 0;
  m3 := 0;
  m4 := 0;
  value := data;
  for i := 0 to N-1 do
  begin
    deviation := (value^-m1);
    deviation2 := deviation * deviation;
    m2 := m2 + deviation2;
    m3 := m3 + deviation2 * deviation;
    m4 := m4 + deviation2 * deviation2;
    inc(value);
  end;
  m2 := reciprocalN * m2;
  m3 := reciprocalN * m3;
  m4 := reciprocalN * m4;

  skew := m3 / (sqrt(m2)*m2);
  kurtosis := m4 / (m2 * m2);
end;


function norm(const data : array of Double) : float;

  begin
     norm:=Norm(PDouble(@data[0]),High(Data)+1);
  end;

function norm(const data : PDouble; Const N : Integer) : float;

  begin
     norm:=sqrt(sumofsquares(data,N));
  end;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function stddev(const data : array of Extended) : float;

begin
  Result:=Stddev(PExtended(@Data[0]),High(Data)+1)
end;

function stddev(const data : PExtended; Const N : Integer) : float;

  begin
     StdDev:=Sqrt(Variance(Data,N));
  end;

procedure meanandstddev(const data : array of Extended;
  var mean,stddev : float);

begin
  Meanandstddev(PExtended(@Data[0]),High(Data)+1,Mean,stddev);
end;

procedure meanandstddev(const data : PExtended;
  Const N : Longint;var mean,stddev : float);

Var I : longint;

begin
  Mean:=0;
  StdDev:=0;
  For I:=0 to N-1 do
    begin
    Mean:=Mean+Data[i];
    StdDev:=StdDev+Sqr(Data[i]);
    end;
  Mean:=Mean/N;
  StdDev:=(StdDev-N*Sqr(Mean));
  If N>1 then
    StdDev:=Sqrt(Stddev/(N-1))
  else
    StdDev:=0;
end;

function variance(const data : array of Extended) : float;

  begin
     Variance:=Variance(PExtended(@Data[0]),High(Data)+1);
  end;

function variance(const data : PExtended; Const N : Integer) : float;

  begin
     If N=1 then
       Result:=0
     else
       Result:=TotalVariance(Data,N)/(N-1);
  end;

function totalvariance(const data : array of Extended) : float;

begin
  Result:=TotalVariance(PExtended(@Data[0]),High(Data)+1);
end;

function totalvariance(const data : PExtended;Const N : Integer) : float;

   var S,SS : Float;

  begin
    If N=1 then
      Result:=0
    else
      begin
      SumsAndSquares(Data,N,S,SS);
      Result := SS-Sqr(S)/N;
      end;
  end;


function popnstddev(const data : array of Extended) : float;

  begin
     PopnStdDev:=Sqrt(PopnVariance(PExtended(@Data[0]),High(Data)+1));
  end;

function popnstddev(const data : PExtended; Const N : Integer) : float;

  begin
     PopnStdDev:=Sqrt(PopnVariance(Data,N));
  end;

function popnvariance(const data : array of Extended) : float;

begin
  popnvariance:=popnvariance(PExtended(@data[0]),high(Data)+1);
end;

function popnvariance(const data : PExtended; Const N : Integer) : float;

  begin
     PopnVariance:=TotalVariance(Data,N)/N;
  end;

procedure momentskewkurtosis(const data : array of Extended;
  out m1,m2,m3,m4,skew,kurtosis : float);

begin
  momentskewkurtosis(PExtended(@Data[0]),High(Data)+1,m1,m2,m3,m4,skew,kurtosis);
end;

procedure momentskewkurtosis(
  const data: pExtended;
  Const N: integer;
  out m1: float;
  out m2: float;
  out m3: float;
  out m4: float;
  out skew: float;
  out kurtosis: float
);
var
  i: integer;
  value : pextended;
  deviation, deviation2: extended;
  reciprocalN: float;
begin
  m1 := 0;
  reciprocalN := 1/N;
  value := data;
  for i := 0 to N-1 do
  begin
    m1 := m1 + value^;
    inc(value);
  end;
  m1 := reciprocalN * m1;

  m2 := 0;
  m3 := 0;
  m4 := 0;
  value := data;
  for i := 0 to N-1 do
  begin
    deviation := (value^-m1);
    deviation2 := deviation * deviation;
    m2 := m2 + deviation2;
    m3 := m3 + deviation2 * deviation;
    m4 := m4 + deviation2 * deviation2;
    inc(value);
  end;
  m2 := reciprocalN * m2;
  m3 := reciprocalN * m3;
  m4 := reciprocalN * m4;

  skew := m3 / (sqrt(m2)*m2);
  kurtosis := m4 / (m2 * m2);
end;

function norm(const data : array of Extended) : float;

  begin
     norm:=Norm(PExtended(@data[0]),High(Data)+1);
  end;

function norm(const data : PExtended; Const N : Integer) : float;

  begin
     norm:=sqrt(sumofsquares(data,N));
  end;
{$endif FPC_HAS_TYPE_EXTENDED}


function MinIntValue(const Data: array of Integer): Integer;
var
  I: Integer;
begin
  Result := Data[Low(Data)];
  For I := Succ(Low(Data)) To High(Data) Do
    If Data[I] < Result Then Result := Data[I];
end;

function MaxIntValue(const Data: array of Integer): Integer;
var
  I: Integer;
begin
  Result := Data[Low(Data)];
  For I := Succ(Low(Data)) To High(Data) Do
    If Data[I] > Result Then Result := Data[I];
end;

function MinValue(const Data: array of Integer): Integer;

begin
  Result:=MinValue(Pinteger(@Data[0]),High(Data)+1)
end;

function MinValue(const Data: PInteger; Const N : Integer): Integer;
var
  I: Integer;
begin
  Result := Data[0];
  For I := 1 To N-1 do
    If Data[I] < Result Then Result := Data[I];
end;

function MaxValue(const Data: array of Integer): Integer;

begin
  Result:=MaxValue(PInteger(@Data[0]),High(Data)+1)
end;

function maxvalue(const data : PInteger; Const N : Integer) : Integer;

var
   i : longint;

begin
   { get an initial value }
   maxvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]>maxvalue then
       maxvalue:=data[i];
end;

{$ifdef FPC_HAS_TYPE_SINGLE}
function minvalue(const data : array of Single) : Single;

begin
   Result:=minvalue(PSingle(@data[0]),High(Data)+1);
end;

function minvalue(const data : PSingle; Const N : Integer) : Single;

var
   i : longint;

begin
   { get an initial value }
   minvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]<minvalue then
       minvalue:=data[i];
end;


function maxvalue(const data : array of Single) : Single;

begin
   Result:=maxvalue(PSingle(@data[0]),High(Data)+1);
end;

function maxvalue(const data : PSingle; Const N : Integer) : Single;

var
   i : longint;

begin
   { get an initial value }
   maxvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]>maxvalue then
       maxvalue:=data[i];
end;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function minvalue(const data : array of Double) : Double;

begin
   Result:=minvalue(PDouble(@data[0]),High(Data)+1);
end;

function minvalue(const data : PDouble; Const N : Integer) : Double;

var
   i : longint;

begin
   { get an initial value }
   minvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]<minvalue then
       minvalue:=data[i];
end;


function maxvalue(const data : array of Double) : Double;

begin
   Result:=maxvalue(PDouble(@data[0]),High(Data)+1);
end;

function maxvalue(const data : PDouble; Const N : Integer) : Double;

var
   i : longint;

begin
   { get an initial value }
   maxvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]>maxvalue then
       maxvalue:=data[i];
end;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function minvalue(const data : array of Extended) : Extended;

begin
   Result:=minvalue(PExtended(@data[0]),High(Data)+1);
end;

function minvalue(const data : PExtended; Const N : Integer) : Extended;

var
   i : longint;

begin
   { get an initial value }
   minvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]<minvalue then
       minvalue:=data[i];
end;


function maxvalue(const data : array of Extended) : Extended;

begin
   Result:=maxvalue(PExtended(@data[0]),High(Data)+1);
end;

function maxvalue(const data : PExtended; Const N : Integer) : Extended;

var
   i : longint;

begin
   { get an initial value }
   maxvalue:=data[0];
   for i:=1 to N-1 do
     if data[i]>maxvalue then
       maxvalue:=data[i];
end;
{$endif FPC_HAS_TYPE_EXTENDED}


function Min(a, b: Integer): Integer;inline;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Integer): Integer;inline;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

{
function Min(a, b: Cardinal): Cardinal;inline;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Cardinal): Cardinal;inline;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;
}

function Min(a, b: Int64): Int64;inline;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Int64): Int64;inline;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

{$ifdef FPC_HAS_TYPE_SINGLE}
function Min(a, b: Single): Single;inline;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Single): Single;inline;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;
{$endif FPC_HAS_TYPE_SINGLE}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function Min(a, b: Double): Double;inline;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Double): Double;inline;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function Min(a, b: Extended): Extended;inline;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Extended): Extended;inline;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;
{$endif FPC_HAS_TYPE_EXTENDED}

function InRange(const AValue, AMin, AMax: Integer): Boolean;inline;

begin
  Result:=(AValue>=AMin) and (AValue<=AMax);
end;

function InRange(const AValue, AMin, AMax: Int64): Boolean;inline;
begin
  Result:=(AValue>=AMin) and (AValue<=AMax);
end;

{$ifdef FPC_HAS_TYPE_DOUBLE}
function InRange(const AValue, AMin, AMax: Double): Boolean;inline;

begin
  Result:=(AValue>=AMin) and (AValue<=AMax);
end;
{$endif FPC_HAS_TYPE_DOUBLE}

function EnsureRange(const AValue, AMin, AMax: Integer): Integer;inline;

begin
  Result:=AValue;
  If Result<AMin then
    Result:=AMin
  else if Result>AMax then
    Result:=AMax;
end;

function EnsureRange(const AValue, AMin, AMax: Int64): Int64;inline;

begin
  Result:=AValue;
  If Result<AMin then
    Result:=AMin
  else if Result>AMax then
    Result:=AMax;
end;

{$ifdef FPC_HAS_TYPE_DOUBLE}
function EnsureRange(const AValue, AMin, AMax: Double): Double;inline;

begin
  Result:=AValue;
  If Result<AMin then
    Result:=AMin
  else if Result>AMax then
    Result:=AMax;
end;
{$endif FPC_HAS_TYPE_DOUBLE}

Const
  EZeroResolution = 1E-16;
  DZeroResolution = 1E-12;
  SZeroResolution = 1E-4;


function IsZero(const A: Single; Epsilon: Single): Boolean;

begin
  if (Epsilon=0) then
    Epsilon:=SZeroResolution;
  Result:=Abs(A)<=Epsilon;
end;

function IsZero(const A: Single): Boolean;inline;

begin
  Result:=IsZero(A,single(SZeroResolution));
end;

{$ifdef FPC_HAS_TYPE_DOUBLE}
function IsZero(const A: Double; Epsilon: Double): Boolean;

begin
  if (Epsilon=0) then
    Epsilon:=DZeroResolution;
  Result:=Abs(A)<=Epsilon;
end;

function IsZero(const A: Double): Boolean;inline;

begin
  Result:=IsZero(A,DZeroResolution);
end;
{$endif FPC_HAS_TYPE_DOUBLE}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function IsZero(const A: Extended; Epsilon: Extended): Boolean;

begin
  if (Epsilon=0) then
    Epsilon:=EZeroResolution;
  Result:=Abs(A)<=Epsilon;
end;

function IsZero(const A: Extended): Boolean;inline;

begin
  Result:=IsZero(A,EZeroResolution);
end;
{$endif FPC_HAS_TYPE_EXTENDED}


type
  TSplitDouble = packed record
    cards: Array[0..1] of cardinal;
  end;

function IsNan(const d : Double): Boolean;
  var
    fraczero, expMaximal: boolean;
  begin
{$if defined(FPC_BIG_ENDIAN) or defined(FPC_DOUBLE_HILO_SWAPPED)}
    expMaximal := ((TSplitDouble(d).cards[0] shr 20) and $7ff) = 2047;
    fraczero:= (TSplitDouble(d).cards[0] and $fffff = 0) and
                (TSplitDouble(d).cards[1] = 0);
{$else FPC_BIG_ENDIAN}
    expMaximal := ((TSplitDouble(d).cards[1] shr 20) and $7ff) = 2047;
    fraczero := (TSplitDouble(d).cards[1] and $fffff = 0) and
                (TSplitDouble(d).cards[0] = 0);
{$endif FPC_BIG_ENDIAN}
    Result:=expMaximal and not(fraczero);
  end;


function IsInfinite(const d : Double): Boolean;
  var
    fraczero, expMaximal: boolean;
  begin
{$if defined(FPC_BIG_ENDIAN) or defined(FPC_DOUBLE_HILO_SWAPPED)}
    expMaximal := ((TSplitDouble(d).cards[0] shr 20) and $7ff) = 2047;
    fraczero:= (TSplitDouble(d).cards[0] and $fffff = 0) and
                (TSplitDouble(d).cards[1] = 0);
{$else FPC_BIG_ENDIAN}
    expMaximal := ((TSplitDouble(d).cards[1] shr 20) and $7ff) = 2047;
    fraczero := (TSplitDouble(d).cards[1] and $fffff = 0) and
                (TSplitDouble(d).cards[0] = 0);
{$endif FPC_BIG_ENDIAN}
    Result:=expMaximal and fraczero;
  end;


{$ifdef FPC_HAS_TYPE_EXTENDED}
function SameValue(const A, B: Extended; Epsilon: Extended): Boolean;

begin
  if (Epsilon=0) then
    Epsilon:=Max(Min(Abs(A),Abs(B))*EZeroResolution,EZeroResolution);
  if (A>B) then
    Result:=((A-B)<=Epsilon)
  else
    Result:=((B-A)<=Epsilon);
end;

function SameValue(const A, B: Extended): Boolean;inline;

begin
  Result:=SameValue(A,B,0);
end;
{$endif FPC_HAS_TYPE_EXTENDED}


{$ifdef FPC_HAS_TYPE_DOUBLE}
function SameValue(const A, B: Double): Boolean;inline;

begin
  Result:=SameValue(A,B,0);
end;

function SameValue(const A, B: Double; Epsilon: Double): Boolean;

begin
  if (Epsilon=0) then
    Epsilon:=Max(Min(Abs(A),Abs(B))*DZeroResolution,DZeroResolution);
  if (A>B) then
    Result:=((A-B)<=Epsilon)
  else
    Result:=((B-A)<=Epsilon);
end;
{$endif FPC_HAS_TYPE_DOUBLE}

function SameValue(const A, B: Single): Boolean;inline;

begin
  Result:=SameValue(A,B,0);
end;

function SameValue(const A, B: Single; Epsilon: Single): Boolean;

begin
  if (Epsilon=0) then
    Epsilon:=Max(Min(Abs(A),Abs(B))*SZeroResolution,SZeroResolution);
  if (A>B) then
    Result:=((A-B)<=Epsilon)
  else
    Result:=((B-A)<=Epsilon);
end;

// Some CPUs probably allow a faster way of doing this in a single operation...
// There weshould define  FPC_MATH_HAS_CPUDIVMOD in the header mathuh.inc and implement it using asm.
{$ifndef FPC_MATH_HAS_DIVMOD}
procedure DivMod(Dividend: Integer; Divisor: Word; var Result, Remainder: Word);
begin
  Result:=Dividend Div Divisor;
  Remainder:=Dividend -(Result*Divisor);
end;


procedure DivMod(Dividend: Integer; Divisor: Word; var Result, Remainder: SmallInt);
var
  UnsignedResult: Word absolute Result;
  UnsignedRemainder: Word absolute Remainder;
begin
  DivMod(Dividend, Divisor, UnsignedResult, UnsignedRemainder);
end;


procedure DivMod(Dividend: DWord; Divisor: DWord; var Result, Remainder: DWord);
begin
  Result:=Dividend Div Divisor;
  Remainder:=Dividend -(Result*Divisor);
end;


procedure DivMod(Dividend: Integer; Divisor: Integer; var Result, Remainder: Integer);
var
  UnsignedResult: DWord absolute Result;
  UnsignedRemainder: DWord absolute Remainder;
begin
  DivMod(Dividend, Divisor, UnsignedResult, UnsignedRemainder);
end;
{$endif FPC_MATH_HAS_DIVMOD}


function ifthen(val:boolean;const iftrue:integer; const iffalse:integer= 0) :integer;
begin
  if val then result:=iftrue else result:=iffalse;
end;

function ifthen(val:boolean;const iftrue:int64  ; const iffalse:int64 = 0)  :int64;
begin
  if val then result:=iftrue else result:=iffalse;
end;

function ifthen(val:boolean;const iftrue:double ; const iffalse:double =0.0):double;
begin
  if val then result:=iftrue else result:=iffalse;
end;

// dilemma here. asm can do the two comparisons in one go?
// but pascal is portable and can be i inline;ed. Ah well, we need purepascal's anyway:
function CompareValue ( const A, B  : Integer) : TValueRelationship;

begin
  result:=GreaterThanValue;
  if a=b then
    result:=EqualsValue
  else
   if a<b then
     result:=LessThanValue;
end;

function CompareValue ( const A, B  : Int64) : TValueRelationship;

begin
  result:=GreaterThanValue;
  if a=b then
    result:=EqualsValue
  else
   if a<b then
     result:=LessThanValue;
end;

function CompareValue ( const A, B : QWord) : TValueRelationship;

begin
  result:=GreaterThanValue;
  if a=b then
    result:=EqualsValue
  else
   if a<b then
     result:=LessThanValue;
end;

{$ifdef FPC_HAS_TYPE_SINGLE}
function CompareValue ( const A, B : Single; delta : Single = 0.0) : TValueRelationship;
begin
  result:=GreaterThanValue;
  if abs(a-b)<=delta then
    result:=EqualsValue
  else
   if a<b then
     result:=LessThanValue;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function CompareValue ( const A, B : Double; delta : Double = 0.0) : TValueRelationship;
begin
  result:=GreaterThanValue;
  if abs(a-b)<=delta then
    result:=EqualsValue
  else
   if a<b then
     result:=LessThanValue;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function CompareValue ( const A, B : Extended; delta : Extended = 0.0) : TValueRelationship;
begin
  result:=GreaterThanValue;
  if abs(a-b)<=delta then
    result:=EqualsValue
  else
   if a<b then
     result:=LessThanValue;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function RoundTo(const AValue: Double; const Digits: TRoundToRange): Double;

var
  RV : Double;

begin
  RV:=IntPower(10,Digits);
  Result:=Round(AValue/RV)*RV;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function RoundTo(const AVAlue: Extended; const Digits: TRoundToRange): Extended;

var
  RV : Extended;

begin
  RV:=IntPower(10,Digits);
  Result:=Round(AValue/RV)*RV;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_SINGLE}
function RoundTo(const AValue: Single; const Digits: TRoundToRange): Single;

var
  RV : Single;

begin
  RV:=IntPower(10,Digits);
  Result:=Round(AValue/RV)*RV;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_SINGLE}
function SimpleRoundTo(const AValue: Single; const Digits: TRoundToRange = -2): Single;

var
  RV : Single;

begin
  RV := IntPower(10, -Digits);
  if AValue < 0 then
    Result := Trunc((AValue*RV) - 0.5)/RV
  else
    Result := Trunc((AValue*RV) + 0.5)/RV;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_DOUBLE}
function SimpleRoundTo(const AValue: Double; const Digits: TRoundToRange = -2): Double;

var
  RV : Double;

begin
  RV := IntPower(10, -Digits);
  if AValue < 0 then
    Result := Trunc((AValue*RV) - 0.5)/RV
  else
    Result := Trunc((AValue*RV) + 0.5)/RV;
end;
{$endif}

{$ifdef FPC_HAS_TYPE_EXTENDED}
function SimpleRoundTo(const AValue: Extended; const Digits: TRoundToRange = -2): Extended;

var
  RV : Extended;

begin
  RV := IntPower(10, -Digits);
  if AValue < 0 then
    Result := Trunc((AValue*RV) - 0.5)/RV
  else
    Result := Trunc((AValue*RV) + 0.5)/RV;
end;
{$endif}

function RandomFrom(const AValues: array of Double): Double; overload;
begin
  result:=AValues[random(High(AValues)+1)];
end;

function RandomFrom(const AValues: array of Integer): Integer; overload;
begin
  result:=AValues[random(High(AValues)+1)];
end;

function RandomFrom(const AValues: array of Int64): Int64; overload;
begin
  result:=AValues[random(High(AValues)+1)];
end;


{$else}
implementation
{$endif FPUNONE}

end.
