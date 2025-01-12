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

    P:=AddPackage('ldap');
{$ifdef ALLPACKAGES}
    P.Directory:='ldap';
{$endif ALLPACKAGES}
    P.Version:='2.2.2-0';
    P.Author := 'Library: Howard Chu, Pierangelo Masarati and Kurt Zeilenga, header: Ivo Steinmann';
    P.License := 'Library: OpenLDAP Public License (3 clause BSD like), header: LGPL with modification';
    P.HomepageURL := 'www.freepascal.org';
    P.Email := '';
    P.Description := 'Header to openldap, a library that to access directory services';
    P.NeedLibC:= true;  // true for headers that indirectly link to libc?


    P.SourcePath.Add('src');
    P.IncludePath.Add('src');

    T:=P.Targets.AddUnit('lber.pas');
      with T.Dependencies do
        begin
          AddInclude('lber_typesh.inc');
          AddInclude('lberh.inc');
        end;
    T:=P.Targets.AddUnit('ldap.pas');
      with T.Dependencies do
        begin
          AddInclude('ldap_featuresh.inc');
          AddInclude('ldap_schemah.inc');
          AddInclude('ldaph.inc');
          AddUnit('lber');
        end;


{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
