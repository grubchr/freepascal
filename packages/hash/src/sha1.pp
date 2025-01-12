{
    This file is part of the Free Pascal packages.
    Copyright (c) 2009 by the Free Pascal development team

    Implements a SHA-1 digest algorithm (RFC 3174)

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit sha1;
{$mode objfpc}{$h+}

interface

type
  TSHA1Digest = array[0..19] of Byte;
  
  TSHA1Context = record
    State: array[0..4] of Cardinal;
    Buffer: array[0..63] of Byte;
    BufCnt: PtrUInt;   { in current block, i.e. in range of 0..63 }
    Length: QWord;     { total count of bytes processed }
  end;

{ core }  
procedure SHA1Init(var ctx: TSHA1Context);
procedure SHA1Update(var ctx: TSHA1Context; const Buf; BufLen: PtrUInt);
procedure SHA1Final(var ctx: TSHA1Context; var Digest: TSHA1Digest);

{ auxiliary }
function SHA1String(const S: String): TSHA1Digest;
function SHA1Buffer(const Buf; BufLen: PtrUInt): TSHA1Digest;
function SHA1File(const Filename: String; const Bufsize: PtrUInt = 1024): TSHA1Digest;

{ helpers }
function SHA1Print(const Digest: TSHA1Digest): String;
function SHA1Match(const Digest1, Digest2: TSHA1Digest): Boolean;

implementation

// inverts the bytes of (Count div 4) cardinals from source to target.
procedure Invert(Source, Dest: Pointer; Count: PtrUInt);
var
  S: PByte;
  T: PCardinal;
  I: PtrUInt;
begin
  S := Source;
  T := Dest;
  for I := 1 to (Count div 4) do
  begin
    T^ := S[3] or (S[2] shl 8) or (S[1] shl 16) or (S[0] shl 24);
    inc(S,4);
    inc(T);
  end;
end;

procedure SHA1Init(var ctx: TSHA1Context);
begin
  FillChar(ctx, sizeof(TSHA1Context), 0);
  ctx.State[0] := $67452301;
  ctx.State[1] := $efcdab89;
  ctx.State[2] := $98badcfe;
  ctx.State[3] := $10325476;
  ctx.State[4] := $c3d2e1f0;
end;

const
  K20 = $5A827999;
  K40 = $6ED9EBA1;
  K60 = $8F1BBCDC;
  K80 = $CA62C1D6;
  
procedure SHA1Transform(var ctx: TSHA1Context; Buf: Pointer);
var
  A, B, C, D, E, T: Cardinal;
  Data: array[0..15] of Cardinal;
  i: Integer;
begin
  A := ctx.State[0];
  B := ctx.State[1];
  C := ctx.State[2];
  D := ctx.State[3];
  E := ctx.State[4];
  Invert(Buf, @Data, 64);
{$push}
{$r-,q-}
  i := 0;
  repeat
    T := (B and C) or (not B and D) + K20 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15], 1);
    Inc(i);
  until i > 19;
  
  repeat
    T := (B xor C xor D) + K40 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15], 1);
    Inc(i);
  until i > 39;
  
  repeat
    T := (B and C) or (B and D) or (C and D) + K60 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15], 1);
    Inc(i);
  until i > 59;  
  
  repeat
    T := (B xor C xor D) + K80 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15], 1);
    Inc(i);
  until i > 79;  

  Inc(ctx.State[0], A);
  Inc(ctx.State[1], B);
  Inc(ctx.State[2], C);
  Inc(ctx.State[3], D);
  Inc(ctx.State[4], E);
{$pop}
  Inc(ctx.Length,64);
end;

procedure SHA1Update(var ctx: TSHA1Context; const Buf; BufLen: PtrUInt);
var
  Src: PByte;
  Num: PtrUInt;
begin
  if BufLen = 0 then
    Exit;

  Src := @Buf;
  Num := 0;

  // 1. Transform existing data in buffer
  if ctx.BufCnt > 0 then
  begin
    // 1.1 Try to fill buffer up to block size
    Num := 64 - ctx.BufCnt;
    if Num > BufLen then
      Num := BufLen;

    Move(Src^, ctx.Buffer[ctx.BufCnt], Num);
    Inc(ctx.BufCnt, Num);
    Inc(Src, Num);

    // 1.2 If buffer is filled, transform it
    if ctx.BufCnt = 64 then
    begin
      SHA1Transform(ctx, @ctx.Buffer);
      ctx.BufCnt := 0;
    end;
  end;

  // 2. Transform input data in 64-byte blocks
  Num := BufLen - Num;
  while Num >= 64 do
  begin
    SHA1Transform(ctx, Src);
    Inc(Src, 64);
    Dec(Num, 64);
  end;

  // 3. If there's less than 64 bytes left, add it to buffer
  if Num > 0 then
  begin
    ctx.BufCnt := Num;
    Move(Src^, ctx.Buffer, Num);
  end;
end;

const
  PADDING: array[0..63] of Byte = 
    ($80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    );

procedure SHA1Final(var ctx: TSHA1Context; var Digest: TSHA1Digest);
var
  Length: QWord;
  Pads: Cardinal;
begin
  // 1. Compute length of the whole stream in bits
  Length := 8 * (ctx.Length + ctx.BufCnt);

  // 2. Append padding bits
  if ctx.BufCnt >= 56 then
    Pads := 120 - ctx.BufCnt
  else
    Pads := 56 - ctx.BufCnt;
  SHA1Update(ctx, PADDING, Pads);

  // 3. Append length of the stream (8 bytes)
  Length := NtoBE(Length);
  SHA1Update(ctx, Length, 8);

  // 4. Invert state to digest
  Invert(@ctx.State, @Digest, 20);
  FillChar(ctx, sizeof(TSHA1Context), 0);  
end;

function SHA1String(const S: String): TSHA1Digest;
var
  Context: TSHA1Context;
begin
  SHA1Init(Context);
  SHA1Update(Context, PChar(S)^, length(S));
  SHA1Final(Context, Result);
end;

function SHA1Buffer(const Buf; BufLen: PtrUInt): TSHA1Digest;
var
  Context: TSHA1Context;
begin
  SHA1Init(Context);
  SHA1Update(Context, buf, buflen);
  SHA1Final(Context, Result);
end;

function SHA1File(const Filename: String; const Bufsize: PtrUInt): TSHA1Digest;
var
  F: File;
  Buf: Pchar;
  Context: TSHA1Context;
  Count: Cardinal;
  ofm: Longint;
begin
  SHA1Init(Context);

  Assign(F, Filename);
  {$i-}
  ofm := FileMode;
  FileMode := 0;
  Reset(F, 1);
  {$i+}

  if IOResult = 0 then
  begin
    GetMem(Buf, BufSize);
    repeat
      BlockRead(F, Buf^, Bufsize, Count);
      if Count > 0 then
        SHA1Update(Context, Buf^, Count);
    until Count < BufSize;
    FreeMem(Buf, BufSize);
    Close(F);
  end;

  SHA1Final(Context, Result);
  FileMode := ofm;
end;

const
  HexTbl: array[0..15] of char='0123456789abcdef';     // lowercase

function SHA1Print(const Digest: TSHA1Digest): String;
var
  I: Integer;
  P: PChar;
begin
  SetLength(Result, 40);
  P := Pointer(Result);
  for I := 0 to 19 do
  begin
    P[0] := HexTbl[(Digest[i] shr 4) and 15];
    P[1] := HexTbl[Digest[i] and 15];
    Inc(P,2);
  end;
end;

function SHA1Match(const Digest1, Digest2: TSHA1Digest): Boolean;
var
  A: array[0..4] of Cardinal absolute Digest1;
  B: array[0..4] of Cardinal absolute Digest2;
begin
  Result := (A[0] = B[0]) and (A[1] = B[1]) and (A[2] = B[2]) and (A[3] = B[3]) and (A[4] = B[4]);
end;

end.
