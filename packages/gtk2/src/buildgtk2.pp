{
   Dummy unit to compile everything in one go

   This unit is part of gtk2forpascal.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the
   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
}
unit buildgtk2; // keep unit name lowercase for kylix

{$mode objfpc}{$H+}

interface

uses
  gtk2, libglade2,gdkglext,gtkglext
{$ifdef unix}  
  ,gdk2x
{$endif unix}
  ;

implementation

end.