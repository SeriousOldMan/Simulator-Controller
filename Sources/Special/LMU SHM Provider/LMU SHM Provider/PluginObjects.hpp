//###########################################################################
//#                                                                         #
//# Module: Header file for plugin object types                             #
//#                                                                         #
//# Description: interface declarations for plugin objects                  #
//#                                                                         #
//# This source code module, and all information, data, and algorithms      #
//# associated with it, are part of isiMotor Technology (tm).               #
//#                 PROPRIETARY AND CONFIDENTIAL                            #
//# Copyright (c) 2025 Studio 397 BV and Motorsport Games Inc.              #
//#                                                                         #
//# Change history:                                                         #
//#   tag.2008.02.15: created                                               #
//#                                                                         #
//###########################################################################

#ifndef _PLUGIN_OBJECTS_HPP_
#define _PLUGIN_OBJECTS_HPP_


// rF currently uses 4-byte packing ... whatever the current packing is will
// be restored at the end of this include with another #pragma.
#pragma pack( push, 4 )


//#########################################################################
//# types of plugins                                                       #
//##########################################################################

enum PluginObjectType
{
  PO_INVALID      = -1,
  //-------------------
  PO_GAMESTATS    =  0,
  PO_NCPLUGIN     =  1,
  PO_IVIBE        =  2,
  PO_INTERNALS    =  3,
  PO_RFONLINE     =  4,
  //-------------------
  PO_MAXIMUM
};


//#########################################################################
//#  PluginObject                                                          #
//#    - interface used by plugin classes.                                 #
//##########################################################################

class PluginObject
{
 private:

  class PluginInfo *mInfo;             // used by main executable to obtain info about the plugin that implements this object

 public:

  void SetInfo( class PluginInfo *p )  { mInfo = p; }        // used by main executable
  class PluginInfo *GetInfo() const    { return( mInfo ); }  // used by main executable
  class PluginInfo *GetInfo()          { return( mInfo ); }  // used by main executable
};


//#########################################################################
//# typedefs for dll functions - easier to use a typedef than to type      #
//# out the crazy syntax for declaring and casting function pointers       #
//##########################################################################

typedef const char *      ( __cdecl *GETPLUGINNAME )();
typedef PluginObjectType  ( __cdecl *GETPLUGINTYPE )();
typedef int               ( __cdecl *GETPLUGINVERSION )();
typedef PluginObject *    ( __cdecl *CREATEPLUGINOBJECT )();
typedef void              ( __cdecl *DESTROYPLUGINOBJECT )( PluginObject *obj );


//#########################################################################
//##########################################################################

// See #pragma at top of file
#pragma pack( pop )

#endif // _PLUGIN_OBJECTS_HPP_

