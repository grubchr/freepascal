{
    Copyright (c) 2000-2002 by Florian Klaempfl

    Type checking and register allocation for set/case nodes

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}
unit nset;

{$i fpcdefs.inc}

interface

    uses
       cclasses,constexp,
       node,globtype,globals,
       aasmbase,aasmtai,aasmdata,ncon,symtype,strings;

    type
       TLabelType = (ltOrdinal, ltConstString);

       pcaselabel = ^tcaselabel;
       tcaselabel = record
          { unique blockid }
          blockid : longint;
          { left and right tree node }
          less,
          greater : pcaselabel;

          { range type }
          case label_type : TLabelType of
            ltOrdinal:
            (
              _low,
              _high       : TConstExprInt;
            );
            ltConstString:
            (
              _low_str,
              _high_str   : TConstString;
              _str_type   : TConstStringType;
            );
       end;

       pcaseblock = ^tcaseblock;
       tcaseblock = record
          { label (only used in pass_generate_code) }
          blocklabel : tasmlabel;
          { instructions }
          statement  : tnode;
       end;

       tsetelementnode = class(tbinarynode)
          constructor create(l,r : tnode);virtual;
          function pass_typecheck:tnode;override;
          function pass_1 : tnode;override;
       end;
       tsetelementnodeclass = class of tsetelementnode;

       tinnode = class(tbinopnode)
          constructor create(l,r : tnode);virtual;reintroduce;
          function pass_typecheck:tnode;override;
          function simplify:tnode;override;
          function pass_1 : tnode;override;
       end;
       tinnodeclass = class of tinnode;

       trangenode = class(tbinarynode)
          constructor create(l,r : tnode);virtual;
          function pass_typecheck:tnode;override;
          function pass_1 : tnode;override;
       end;
       trangenodeclass = class of trangenode;

       tcasenode = class(tunarynode)
          labels    : pcaselabel;
          blocks    : TFPList;
          elseblock : tnode;
          constructor create(l:tnode);virtual;
          destructor destroy;override;
          constructor ppuload(t:tnodetype;ppufile:tcompilerppufile);override;
          procedure ppuwrite(ppufile:tcompilerppufile);override;
          procedure buildderefimpl;override;
          procedure derefimpl;override;
          function dogetcopy : tnode;override;
          procedure insertintolist(l : tnodelist);override;
          function pass_typecheck:tnode;override;
          function pass_1 : tnode;override;
          function docompare(p: tnode): boolean; override;
          procedure addlabel(blockid:longint;l,h : TConstExprInt); overload;
          procedure addlabel(blockid:longint;l,h : TConstString; str_type : TConstStringType); overload;
          procedure addblock(blockid:longint;instr:tnode);
          procedure addelseblock(instr:tnode);
       end;
       tcasenodeclass = class of tcasenode;

    var
       csetelementnode : tsetelementnodeclass;
       cinnode : tinnodeclass;
       crangenode : trangenodeclass;
       ccasenode : tcasenodeclass;

    { counts the labels }
    function case_count_labels(root : pcaselabel) : longint;
    { searches the highest label }
    function case_get_max(root : pcaselabel) : tconstexprint;
    { searches the lowest label }
    function case_get_min(root : pcaselabel) : tconstexprint;


implementation

    uses
      systems,
      verbose,
      symconst,symdef,symsym,symtable,defutil,defcmp,
      htypechk,pass_1,
      nadd,nbas,ncnv,nld,nflw,cgobj,cgbase,
      widestr;


{*****************************************************************************
                           TSETELEMENTNODE
*****************************************************************************}

    constructor tsetelementnode.create(l,r : tnode);

      begin
         inherited create(setelementn,l,r);
      end;


    function tsetelementnode.pass_typecheck:tnode;
      begin
         result:=nil;
         typecheckpass(left);
         if assigned(right) then
          typecheckpass(right);
         set_varstate(left,vs_read,[vsf_must_be_valid]);
         if codegenerror then
          exit;

         resultdef:=left.resultdef;
      end;


    function tsetelementnode.pass_1 : tnode;

      begin
         result:=nil;
         firstpass(left);
         if assigned(right) then
          firstpass(right);
         if codegenerror then
          exit;

         expectloc:=left.expectloc;
      end;


{*****************************************************************************
                              TINNODE
*****************************************************************************}

    constructor tinnode.create(l,r : tnode);
      begin
         inherited create(inn,l,r);
      end;


    function tinnode.pass_typecheck:tnode;

      var
        t : tnode;
        pst : pconstset;

        function createsetconst(psd : tsetdef) : pconstset;
        var
          pcs : pconstset;
          pes : tenumsym;
          i : longint;
        begin
          new(pcs);
          case psd.elementdef.typ of
            enumdef :
              begin
                pes:=tenumsym(tenumdef(psd.elementdef).firstenum);
                while assigned(pes) do
                  begin
                    include(pcs^,pes.value);
                    pes:=pes.nextenum;
                  end;
              end;
            orddef :
              begin
                for i:=int64(torddef(psd.elementdef).low) to int64(torddef(psd.elementdef).high) do
                  include(pcs^,i);
              end;
          end;
          createsetconst:=pcs;
        end;

      begin
         result:=nil;
         resultdef:=booltype;
         typecheckpass(right);
         set_varstate(right,vs_read,[vsf_must_be_valid]);
         if codegenerror then
          exit;

         { Convert array constructor first to set }
         if is_array_constructor(right.resultdef) then
          begin
            arrayconstructor_to_set(right);
            firstpass(right);
            if codegenerror then
             exit;
          end;

         if right.resultdef.typ<>setdef then
           CGMessage(sym_e_set_expected);

         if codegenerror then
           exit;

         if (right.nodetype=typen) then
           begin
             { we need to create a setconstn }
             pst:=createsetconst(tsetdef(ttypenode(right).resultdef));
             t:=csetconstnode.create(pst,ttypenode(right).resultdef);
             dispose(pst);
             right.free;
             right:=t;
             typecheckpass(right);
           end;

         typecheckpass(left);
         set_varstate(left,vs_read,[vsf_must_be_valid]);
         if codegenerror then
           exit;

         if not assigned(left.resultdef) then
           internalerror(20021126);

         if (m_tp7 in current_settings.modeswitches) then
           begin
             { insert a hint that a range check error might occur on non-byte
               elements with the in operator.
             }
             if  (
                   (left.resultdef.typ = orddef) and not
                   (torddef(left.resultdef).ordtype in [s8bit,u8bit,uchar,pasbool,bool8bit])
                 )
                or
                 (
                   (left.resultdef.typ = enumdef) and
                   (tenumdef(left.resultdef).maxval > 255)
                 )
               then
                 CGMessage(type_h_in_range_check);

             { type conversion/check }
             if assigned(tsetdef(right.resultdef).elementdef) then
               inserttypeconv(left,tsetdef(right.resultdef).elementdef);
           end
         else if not is_ordinal(left.resultdef) or (left.resultdef.size > u32inttype.size) then
           begin
             CGMessage(type_h_in_range_check);
             if is_signed(left.resultdef) then
               inserttypeconv(left,s32inttype)
             else
               inserttypeconv(left,u32inttype);
           end
         else if assigned(tsetdef(right.resultdef).elementdef) and
                 not(is_integer(tsetdef(right.resultdef).elementdef) and
                     is_integer(left.resultdef)) then
            { Type conversion to check things like 'char in set_of_byte'. }
            { Can't use is_subequal because that will fail for            }
            { 'widechar in set_of_char'                                   }
            { Can't use the type conversion for integers because then     }
            { "longint in set_of_byte" will give a range check error      }
            { instead of false                                            }
            inserttypeconv(left,tsetdef(right.resultdef).elementdef);

         { empty set then return false }
         if not assigned(tsetdef(right.resultdef).elementdef) or
            ((right.nodetype = setconstn) and
             (tnormalset(tsetconstnode(right).value_set^) = [])) then
          begin
            t:=cordconstnode.create(0,booltype,false);
            typecheckpass(t);
            result:=t;
            exit;
          end;

         result:=simplify;
      end;


    function tinnode.simplify:tnode;
      var
        t : tnode;
      begin
         result:=nil;
         { constant evaluation }
         if (left.nodetype=ordconstn) then
           begin
             if (right.nodetype=setconstn) then
               begin
                 { tordconstnode.value is int64 -> signed -> the expression }
                 { below will be converted to longint on 32 bit systems due }
                 { to the rule above -> will give range check error if      }
                 { value > high(longint) if we don't take the signedness    }
                 { into account                                             }
                 if Tordconstnode(left).value.signed then
                   t:=cordconstnode.create(byte(tordconstnode(left).value.svalue in Tsetconstnode(right).value_set^),
                     booltype,true)
                 else
                   t:=cordconstnode.create(byte(tordconstnode(left).value.uvalue in Tsetconstnode(right).value_set^),
                     booltype,true);
                 typecheckpass(t);
                 result:=t;
                 exit;
               end
             else
               begin
                 if (Tordconstnode(left).value<int64(tsetdef(right.resultdef).setbase)) or
                    (Tordconstnode(left).value>int64(Tsetdef(right.resultdef).setmax)) then
                   begin
                     t:=cordconstnode.create(0, booltype, true);
                     typecheckpass(t);
                     result:=t;
                     exit;
                   end;
               end;
           end;
      end;


    function tinnode.pass_1 : tnode;
      begin
         result:=nil;
         expectloc:=LOC_REGISTER;

         firstpass(right);
         firstpass(left);
         if codegenerror then
           exit;
      end;


{*****************************************************************************
                              TRANGENODE
*****************************************************************************}

    constructor trangenode.create(l,r : tnode);
      var
        value: string;

      begin
         { if right is char and left is string then }
         { right should be treated as one-symbol string }
         if is_conststringnode(l) and is_constcharnode(r) then
           begin
             value := char(tordconstnode(r).value.uvalue) + ''#0;
             r.free;
             r := cstringconstnode.createstr(value);
             do_typecheckpass(r);
           end;
         inherited create(rangen,l,r);
      end;


    function trangenode.pass_typecheck : tnode;
      begin
         result:=nil;
         typecheckpass(left);
         typecheckpass(right);
         set_varstate(left,vs_read,[vsf_must_be_valid]);
         set_varstate(right,vs_read,[vsf_must_be_valid]);
         if codegenerror then
           exit;
         { both types must be compatible }
         if compare_defs(left.resultdef,right.resultdef,left.nodetype)=te_incompatible then
           IncompatibleTypes(left.resultdef,right.resultdef);
         { Check if only when its a constant set }
         if (left.nodetype=ordconstn) and (right.nodetype=ordconstn) then
          begin
            { upper limit must be greater or equal than lower limit }
            if (tordconstnode(left).value>tordconstnode(right).value) and
               ((tordconstnode(left).value<0) or (tordconstnode(right).value>=0)) then
              CGMessage(parser_e_upper_lower_than_lower);
          end;
        resultdef:=left.resultdef;
      end;


    function trangenode.pass_1 : tnode;
      begin
         result:=nil;
         firstpass(left);
         firstpass(right);
         if codegenerror then
           exit;
        expectloc:=left.expectloc;
      end;


{*****************************************************************************
                              Case Helpers
*****************************************************************************}

    function case_count_labels(root : pcaselabel) : longint;
      var
         _l : longint;

      procedure count(p : pcaselabel);
        begin
           inc(_l);
           if assigned(p^.less) then
             count(p^.less);
           if assigned(p^.greater) then
             count(p^.greater);
        end;

      begin
         _l:=0;
         count(root);
         case_count_labels:=_l;
      end;


    function case_get_max(root : pcaselabel) : tconstexprint;
      var
         hp : pcaselabel;
      begin
         hp:=root;
         while assigned(hp^.greater) do
           hp:=hp^.greater;
         case_get_max:=hp^._high;
      end;


    function case_get_min(root : pcaselabel) : tconstexprint;
      var
         hp : pcaselabel;
      begin
         hp:=root;
         while assigned(hp^.less) do
           hp:=hp^.less;
         case_get_min:=hp^._low;
      end;

    procedure deletecaselabels(p : pcaselabel);

      begin
         if assigned(p^.greater) then
           deletecaselabels(p^.greater);
         if assigned(p^.less) then
           deletecaselabels(p^.less);
         if (p^.label_type = ltConstString) then
           begin
             if (p^._str_type in [cst_widestring, cst_unicodestring]) then
               begin
                 donewidestring(pcompilerwidestring(p^._low_str));
                 donewidestring(pcompilerwidestring(p^._high_str));
               end
             else
               begin
                 freemem(p^._low_str);
                 freemem(p^._high_str);
               end;
           end;
         dispose(p);
      end;

    function copycaselabel(p : pcaselabel) : pcaselabel;

      var
         n : pcaselabel;

      begin
         new(n);
         n^:=p^;
         if (p^.label_type = ltConstString) then
           begin
             if (p^._str_type in [cst_widestring, cst_unicodestring]) then
               begin
                 initwidestring(pcompilerwidestring(n^._low_str));
                 initwidestring(pcompilerwidestring(n^._high_str));
                 copywidestring(
                   pcompilerwidestring(p^._low_str), pcompilerwidestring(n^._low_str));
                 copywidestring(
                   pcompilerwidestring(p^._high_str), pcompilerwidestring(n^._high_str));
               end
             else
               begin
                 getmem(n^._low_str, strlen(p^._low_str) + 1);
                 strcopy(n^._low_str, p^._low_str);
                 n^._low_str[strlen(p^._low_str)] := #0;
                 getmem(n^._high_str, strlen(p^._high_str) + 1);
                 strcopy(n^._high_str, p^._high_str);
                 n^._high_str[strlen(p^._high_str)] := #0;
               end;
           end;
         if assigned(p^.greater) then
           n^.greater:=copycaselabel(p^.greater);
         if assigned(p^.less) then
           n^.less:=copycaselabel(p^.less);
         copycaselabel:=n;
      end;


    procedure ppuwritecaselabel(ppufile:tcompilerppufile;p : pcaselabel);

      procedure ppuwritestring(str_type : tconststringtype; value : pchar);

        var
          len : integer;
        begin
          if str_type in [cst_widestring, cst_unicodestring] then
            begin
              len := pcompilerwidestring(value)^.len;
              ppufile.putlongint(len);
              ppufile.putdata(pcompilerwidestring(value)^.data, len * sizeof(tcompilerwidechar));
            end
          else
            begin
              len := strlen(value);
              ppufile.putlongint(len);
              ppufile.putdata(value^, len);
            end;
        end;

      var
        b : byte;
      begin
        ppufile.putbyte(byte(p^.label_type = ltConstString));
        if (p^.label_type = ltConstString) then
          begin
            ppufile.putbyte(byte(p^._str_type));
            ppuwritestring(p^._str_type, p^._low_str);
            ppuwritestring(p^._str_type, p^._high_str);
          end
        else
          begin
            ppufile.putexprint(p^._low);
            ppufile.putexprint(p^._high);
          end;

        ppufile.putlongint(p^.blockid);
        b:=0;
        if assigned(p^.greater) then
         b:=b or 1;
        if assigned(p^.less) then
         b:=b or 2;
        ppufile.putbyte(b);
        if assigned(p^.greater) then
          ppuwritecaselabel(ppufile,p^.greater);
        if assigned(p^.less) then
          ppuwritecaselabel(ppufile,p^.less);
      end;


    function ppuloadcaselabel(ppufile:tcompilerppufile):pcaselabel;

      procedure ppuloadstring(str_type : tconststringtype; out value : pchar);

        var
          pw : pcompilerwidestring;
          len : integer;
        begin
          len := ppufile.getlongint;
          if str_type in [cst_widestring, cst_unicodestring] then
            begin
              initwidestring(pw);
              setlengthwidestring(pw, len);
              ppufile.getdata(pw^.data, pw^.len * sizeof(tcompilerwidechar));
              pcompilerwidestring(value) := pw
            end
          else
            begin
              getmem(value, len + 1);
              ppufile.getdata(value^, len);
              value[len] := #0;
            end;
        end;

      var
        b : byte;
        p : pcaselabel;
      begin
        new(p);
        if boolean(ppufile.getbyte) then
          begin
            p^.label_type := ltConstString;
            p^._str_type := tconststringtype(ppufile.getbyte);

            ppuloadstring(p^._str_type, p^._low_str);
            ppuloadstring(p^._str_type, p^._high_str);
          end
        else
          begin
            p^.label_type := ltOrdinal;

            p^._low:=ppufile.getexprint;
            p^._high:=ppufile.getexprint;
          end;

        p^.blockid:=ppufile.getlongint;
        b:=ppufile.getbyte;
        if (b and 1)=1 then
         p^.greater:=ppuloadcaselabel(ppufile)
        else
         p^.greater:=nil;
        if (b and 2)=2 then
         p^.less:=ppuloadcaselabel(ppufile)
        else
         p^.less:=nil;
        ppuloadcaselabel:=p;
      end;


{*****************************************************************************
                              TCASENODE
*****************************************************************************}

    constructor tcasenode.create(l:tnode);
      begin
         inherited create(casen,l);
         labels:=nil;
         blocks:=TFPList.create;
         elseblock:=nil;
      end;


    destructor tcasenode.destroy;
      var
        i : longint;
        hp : pcaseblock;
      begin
         elseblock.free;
         deletecaselabels(labels);
         for i:=0 to blocks.count-1 do
           begin
             pcaseblock(blocks[i])^.statement.free;
             hp:=pcaseblock(blocks[i]);
             dispose(hp);
           end;
         blocks.free;
         inherited destroy;
      end;


    constructor tcasenode.ppuload(t:tnodetype;ppufile:tcompilerppufile);
      var
        cnt,i : longint;
      begin
        inherited ppuload(t,ppufile);
        elseblock:=ppuloadnode(ppufile);
        cnt:=ppufile.getlongint();
        blocks:=TFPList.create;
        for i:=0 to cnt-1 do
          addblock(i,ppuloadnode(ppufile));
        labels:=ppuloadcaselabel(ppufile);
      end;


    procedure tcasenode.ppuwrite(ppufile:tcompilerppufile);
      var
        i : longint;
      begin
        inherited ppuwrite(ppufile);
        ppuwritenode(ppufile,elseblock);
        ppufile.putlongint(blocks.count);
        for i:=0 to blocks.count-1 do
          ppuwritenode(ppufile,pcaseblock(blocks[i])^.statement);
        ppuwritecaselabel(ppufile,labels);
      end;


    procedure tcasenode.buildderefimpl;
      var
        i : integer;
      begin
        inherited buildderefimpl;
        if assigned(elseblock) then
          elseblock.buildderefimpl;
        for i:=0 to blocks.count-1 do
          pcaseblock(blocks[i])^.statement.buildderefimpl;
      end;


    procedure tcasenode.derefimpl;
      var
        i : integer;
      begin
        inherited derefimpl;
        if assigned(elseblock) then
          elseblock.derefimpl;
        for i:=0 to blocks.count-1 do
          pcaseblock(blocks[i])^.statement.derefimpl;
      end;


    function tcasenode.pass_typecheck : tnode;
      begin
        result:=nil;
        resultdef:=voidtype;
      end;


    function tcasenode.pass_1 : tnode;
      var
         i  : integer;
         node_thenblock,node_elseblock,if_node : tnode;
         tempcaseexpr : ttempcreatenode;
         if_block, init_block : tblocknode;
         stmt : tstatementnode;

      function makeifblock(const labtree : pcaselabel; prevconditblock : tnode): tnode;
        var
          condit : tnode;
        begin
          result := nil;
          if assigned(labtree^.less) then
            result := makeifblock(labtree^.less, prevconditblock)
          else
            result := prevconditblock;
          prevconditblock := nil;

          if (labtree^._str_type in [cst_widestring, cst_unicodestring]) then
            begin
              condit := caddnode.create(
                equaln, left.getcopy,
                cstringconstnode.createwstr(pcompilerwidestring(labtree^._low_str)));
 
              if (
                comparewidestrings(
                  pcompilerwidestring(labtree^._low_str),
                  pcompilerwidestring(labtree^._high_str)) <> 0) then
                begin
                  condit.nodetype := gten;
                  condit := caddnode.create(
                    andn, condit, caddnode.create(
                      lten, left.getcopy, cstringconstnode.createwstr(
                        pcompilerwidestring(labtree^._high_str))));
                end;
            end
          else
            begin
              condit := caddnode.create(
                equaln, left.getcopy, cstringconstnode.createstr(labtree^._low_str));

              if (compare_strings(labtree^._low_str, labtree^._high_str) <> 0) then
                begin
                  condit.nodetype := gten;
                  condit := caddnode.create(
                    andn, condit, caddnode.create(
                      lten, left.getcopy, cstringconstnode.createstr(labtree^._high_str)));
                end;
            end;
          
          result :=
            cifnode.create(
              condit, pcaseblock(blocks[labtree^.blockid])^.statement, result);
          pcaseblock(blocks[labtree^.blockid])^.statement := nil;

          if assigned(labtree^.greater) then
            result := makeifblock(labtree^.greater, result);

          typecheckpass(result);
        end;

      begin
         result:=nil;
         init_block:=nil;
         expectloc:=LOC_VOID;

         { evalutes the case expression }
         firstpass(left);
         set_varstate(left,vs_read,[vsf_must_be_valid]);
         if codegenerror then
           exit;

         { Load caseexpr into temp var if complex. }
         { No need to do this for ordinal, because }
         { in that case caseexpr is generated once }
         if (labels^.label_type = ltConstString) and (not valid_for_addr(left, false)) and
           (blocks.count > 0) then
           begin
             init_block := internalstatements(stmt);
             tempcaseexpr :=
               ctempcreatenode.create(
                 left.resultdef, left.resultdef.size, tt_persistent, true);
             typecheckpass(tnode(tempcaseexpr));

             addstatement(stmt, tempcaseexpr);
             addstatement(
               stmt, cassignmentnode.create(
                 ctemprefnode.create(tempcaseexpr), left));

             left := ctemprefnode.create(tempcaseexpr);
             typecheckpass(left);
           end;

         { first case }
         for i:=0 to blocks.count-1 do
           firstpass(pcaseblock(blocks[i])^.statement);

         { may be handle else tree }
         if assigned(elseblock) then
           begin
             firstpass(elseblock);

             { kill case? }
             if blocks.count=0 then
               begin
                 result:=elseblock;
                 elseblock:=nil;
                 exit;
               end;
           end
         else
           if blocks.count=0 then
             begin
               result:=cnothingnode.create;
               exit;
             end;

         if (labels^.label_type = ltConstString) then
           begin
             if_node := makeifblock(labels, elseblock);
             if assigned(init_block) then
               begin
                 firstpass(tnode(init_block));
                 if_block := internalstatements(stmt);
                 addstatement(stmt, init_block);
                 addstatement(stmt, if_node);
                 result := if_block;
               end
             else
               result := if_node;
             init_block := nil;
             elseblock := nil;
             exit;
           end;

         if is_boolean(left.resultdef) then
           begin
             case blocks.count of
               2:
                 begin
                   if boolean(qword(labels^._low))=false then
                     begin
                       node_thenblock:=pcaseblock(blocks[labels^.greater^.blockid])^.statement;
                       node_elseblock:=pcaseblock(blocks[labels^.blockid])^.statement;
                       pcaseblock(blocks[labels^.greater^.blockid])^.statement:=nil;
                     end
                   else
                     begin
                       node_thenblock:=pcaseblock(blocks[labels^.blockid])^.statement;
                       node_elseblock:=pcaseblock(blocks[labels^.less^.blockid])^.statement;
                       pcaseblock(blocks[labels^.less^.blockid])^.statement:=nil;
                     end;
                   pcaseblock(blocks[labels^.blockid])^.statement:=nil;
                 end;
               1:
                 begin
                   if labels^._low=labels^._high then
                     begin
                       if boolean(qword(labels^._low))=false then
                         begin
                           node_thenblock:=elseblock;
                           node_elseblock:=pcaseblock(blocks[labels^.blockid])^.statement;
                         end
                       else
                         begin
                           node_thenblock:=pcaseblock(blocks[labels^.blockid])^.statement;
                           node_elseblock:=elseblock;
                         end;
                       pcaseblock(blocks[labels^.blockid])^.statement:=nil;
                       elseblock:=nil;
                     end
                   else
                     begin
                       result:=pcaseblock(blocks[labels^.blockid])^.statement;
                       pcaseblock(blocks[labels^.blockid])^.statement:=nil;
                       elseblock:=nil;
                       exit;
                     end;
                 end;
             else
               internalerror(200805031);
           end;
           result:=cifnode.create(left,node_thenblock,node_elseblock);
           left:=nil;
         end;
      end;


    function tcasenode.dogetcopy : tnode;

      var
         n : tcasenode;
         i : longint;
      begin
         n:=tcasenode(inherited dogetcopy);
         if assigned(elseblock) then
           n.elseblock:=elseblock.dogetcopy
         else
           n.elseblock:=nil;
         if assigned(labels) then
           n.labels:=copycaselabel(labels)
         else
           n.labels:=nil;
         if assigned(blocks) then
           begin
             n.blocks:=TFPList.create;
             for i:=0 to blocks.count-1 do
               begin
                 if not assigned(blocks[i]) then
                   internalerror(200411302);
                 n.addblock(i,pcaseblock(blocks[i])^.statement.dogetcopy);
               end;
           end
         else
           n.blocks:=nil;
         dogetcopy:=n;
      end;

    procedure tcasenode.insertintolist(l : tnodelist);

      begin
      end;

    function caselabelsequal(n1,n2: pcaselabel): boolean;
      begin
        result :=
          (not assigned(n1) and not assigned(n2)) or
          (assigned(n1) and assigned(n2) and
           (n1^._low = n2^._low) and
           (n1^._high = n2^._high) and
           { the rest of the fields don't matter for equality (JM) }
           caselabelsequal(n1^.less,n2^.less) and
           caselabelsequal(n1^.greater,n2^.greater))
      end;


    function caseblocksequal(b1,b2:TFPList): boolean;
      var
        i : longint;
      begin
        result:=false;
        if b1.count<>b2.count then
          exit;
        for i:=0 to b1.count-1 do
          begin
            if not pcaseblock(b1[i])^.statement.isequal(pcaseblock(b2[i])^.statement) then
              exit;
          end;
        result:=true;
      end;


    function tcasenode.docompare(p: tnode): boolean;
      begin
        result :=
          inherited docompare(p) and
          caselabelsequal(labels,tcasenode(p).labels) and
          caseblocksequal(blocks,tcasenode(p).blocks) and
          elseblock.isequal(tcasenode(p).elseblock);
      end;


    procedure tcasenode.addblock(blockid:longint;instr:tnode);
      var
        hcaseblock : pcaseblock;
      begin
        new(hcaseblock);
        fillchar(hcaseblock^,sizeof(hcaseblock^),0);
        hcaseblock^.statement:=instr;
        if blockid>=blocks.count then
          blocks.count:=blockid+1;
        blocks[blockid]:=hcaseblock;
      end;


    procedure tcasenode.addelseblock(instr:tnode);
      begin
        elseblock:=instr;
      end;


    procedure tcasenode.addlabel(blockid:longint;l,h : TConstExprInt);
      var
        hcaselabel : pcaselabel;

        function insertlabel(var p : pcaselabel):pcaselabel;
          begin
             if p=nil then
               begin
                 p:=hcaselabel;
                 result:=p;
               end
             else
              if (p^._low>hcaselabel^._low) and
                 (p^._low>hcaselabel^._high) then
                begin
                  if (hcaselabel^.blockid = p^.blockid) and
                     (p^._low = hcaselabel^._high + 1) then
                    begin
                      p^._low := hcaselabel^._low;
                      dispose(hcaselabel);
                      result:=p;
                    end
                  else
                    result:=insertlabel(p^.less)
                end
             else
               if (p^._high<hcaselabel^._low) and
                  (p^._high<hcaselabel^._high) then
                 begin
                    if (hcaselabel^.blockid = p^.blockid) and
                       (p^._high+1 = hcaselabel^._low) then
                      begin
                        p^._high := hcaselabel^._high;
                        dispose(hcaselabel);
                        result:=p;
                      end
                    else
                      result:=insertlabel(p^.greater);
                 end
             else
               Message(parser_e_double_caselabel);
          end;

      begin
        new(hcaselabel);
        fillchar(hcaselabel^,sizeof(tcaselabel),0);
        hcaselabel^.blockid:=blockid;
        hcaselabel^.label_type:=ltOrdinal;
        hcaselabel^._low:=l;
        hcaselabel^._high:=h;
        insertlabel(labels);
      end;

    procedure tcasenode.addlabel(blockid : longint; l, h : TConstString; str_type : TConstStringType);

      function str_compare(l, h : TConstString) : longint;
        begin
          if (str_type in [cst_widestring, cst_unicodestring]) then
            result := comparewidestrings(pcompilerwidestring(l), pcompilerwidestring(h))
          else
            result := compare_strings(l, h);
        end;

      var
        hcaselabel : pcaselabel;

      function insertlabel(var p : pcaselabel) : pcaselabel;
        begin
          if not assigned(p) then
            begin
              p := hcaselabel;
              result := p;
            end
          else
            if (str_compare(p^._low_str, hcaselabel^._high_str) > 0) then
              result := insertlabel(p^.less)
          else
            if (str_compare(p^._high_str, hcaselabel^._low_str) < 0) then
              result := insertlabel(p^.greater)
          else
            Message(parser_e_double_caselabel);
        end;

      begin
        new(hcaselabel);
        fillchar(hcaselabel^, sizeof(tcaselabel), 0);
        hcaselabel^.blockid := blockid;
        hcaselabel^.label_type := ltConstString;

        if (str_type in [cst_widestring, cst_unicodestring]) then
          begin
            initwidestring(pcompilerwidestring(hcaselabel^._low_str));
            initwidestring(pcompilerwidestring(hcaselabel^._high_str));
            copywidestring(pcompilerwidestring(l), pcompilerwidestring(hcaselabel^._low_str));
            copywidestring(pcompilerwidestring(h), pcompilerwidestring(hcaselabel^._high_str));
          end
        else
          begin
            getmem(hcaselabel^._low_str, strlen(l) + 1);
            getmem(hcaselabel^._high_str, strlen(h) + 1);
            strcopy(hcaselabel^._low_str, l);
            strcopy(hcaselabel^._high_str, h);
            hcaselabel^._low_str[strlen(l)] := #0;
            hcaselabel^._high_str[strlen(h)] := #0;
          end;

        hcaselabel^._str_type := str_type;
        insertlabel(labels);
      end;

begin
   csetelementnode:=tsetelementnode;
   cinnode:=tinnode;
   crangenode:=trangenode;
   ccasenode:=tcasenode;
end.
