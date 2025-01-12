{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;

Var
  P : TPackage;
  T : TTarget;
begin
  With Installer do
    begin
{$endif ALLPACKAGES}

    P:=AddPackage('xml2');
{$ifdef ALLPACKAGES}
    P.Directory:='libxml';
{$endif ALLPACKAGES}
    P.Version:='2.2.2-0';
    P.SourcePath.Add('src');
    P.IncludePath.Add('src');

  T:=P.Targets.AddUnit('xml2.pas');
  with T.Dependencies do
    begin
      AddInclude('xinclude.inc');
      AddInclude('xpointer.inc');
      AddInclude('HTMLparser.inc');
      AddInclude('schemasInternals.inc');
      AddInclude('SAX2.inc');
      AddInclude('xmlversion.inc');
      AddInclude('globals.inc');
      AddInclude('xmlexports.inc');
      AddInclude('nanoftp.inc');
      AddInclude('SAX.inc');
      AddInclude('uri.inc');
      AddInclude('debugXML.inc');
      AddInclude('xmlunicode.inc');
//      AddInclude('DOCBparser.inc');
      AddInclude('xmlIO.inc');
      AddInclude('xmlsave.inc');
      AddInclude('HTMLtree.inc');
      AddInclude('parserInternals.inc');
      AddInclude('chvalid.inc');
      AddInclude('xmlwriter.inc');
      AddInclude('relaxng.inc');
      AddInclude('threads.inc');
      AddInclude('list.inc');
      AddInclude('encoding.inc');
      AddInclude('catalog.inc');
      AddInclude('pattern.inc');
      AddInclude('xmlregexp.inc');
      AddInclude('xmlerror.inc');
      AddInclude('xpath.inc');
      AddInclude('xmlautomata.inc');
      AddInclude('entities.inc');
      AddInclude('xmlreader.inc');
      AddInclude('xmlstring.inc');
      AddInclude('xmlmemory.inc');
      AddInclude('xmlmodule.inc');
      AddInclude('xmlschemas.inc');
      AddInclude('hash.inc');
      AddInclude('nanohttp.inc');
      AddInclude('parser.inc');
      AddInclude('tree.inc');
      AddInclude('dict.inc');
      AddInclude('xlink.inc');
      AddInclude('valid.inc');
      AddInclude('xpathInternals.inc');
      AddInclude('xmlschemastypes.inc');
      AddInclude('c14n.inc');
      AddInclude('schematron.inc');
    end;

    P.ExamplePath.Add('examples');
    P.Targets.AddExampleProgram('reader1.pas');
    P.Targets.AddExampleProgram('io2.pas');
    P.Targets.AddExampleProgram('io1.pas');
    P.Targets.AddExampleProgram('tree1.pas');
    P.Targets.AddExampleProgram('tree2.pas');
    P.Targets.AddExampleProgram('exutils.pas');
    P.Targets.AddExampleProgram('reader2.pas');
    // 'Makefile
    // 'Makefile.fpc
    // 'test1.xml
    // 'test2.xml

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
