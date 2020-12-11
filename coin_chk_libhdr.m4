

###########################################################################
#                         LIBHDR_DFLT_HACK                                #
###########################################################################

# COIN_LIBHDR_DFLT_HACK([which],[dfltaction],[dfltuse],[dfltlink])

# A pure macro hack to get around POSIX m4's nine-parameter limit by
# overloading the [dfltaction] parameter to the PRIM_LIBHDR, CHK_LIBHDR
# and CHK_LIB macros. It's ugly but it's pure macro and will resolve at
# run_autotools.

# We're trying to control two distinct things: should the library be used
# by default (yes or no), and should the link check use only the function
# (sep(arate) or both the includes and the function (tog(ether)). This macro
# looks at the possibilities and returns the appropriate string. [which]
# ($1) controls whether it returns library usage ('usage') or the form
# of the link check ('link'). [dfltaction] ($2) is the parameter to
# be analysed. [dfltuse] ($3) specifies the default for usage, in case
# [dfltaction] doesn't specify it. [dfltlink] ($4) covers the default for
# the link check, in case [dfltaction] doesn't specify it.

# It's critical that the macro produce a result with no leading or trailing
# spaces! Be careful if you modify it. In normal use, you want this macro to
# expand immediately, so don't quote it.

AC_DEFUN([AC_COIN_LIBHDR_DFLT_HACK],
[m4_case([$2],
   [yessep],[m4_if([$1],[link],[sep],[yes])],
   [yestog],[m4_if([$1],[link],[tog],[yes])],
   [nosep],[m4_if([$1],[link],[sep],[no])],
   [notog],[m4_if([$1],[link],[tog],[no])],
   [yes],[m4_if([$1],[link],[$4],[yes])],
   [no],[m4_if([$1],[link],[$4],[no])],
   [sep],[m4_if([$1],[link],[sep],[$3])],
   [tog],[m4_if([$1],[link],[tog],[$3])],
   [m4_if([$1],[link],[$4],[$3])])])dnl 	# COIN_LIBHDR_DFLT_HACK
  


###########################################################################
#                         FIND_PRIM_LIBHDR                                #
###########################################################################

# COIN_FIND_PRIM_LIBHDR([prim],[lflgs],[cflgs],[dflgs],
#                       [function-body],[includes],
#                       [dfltaction],[cmdlineopts])

# Determine whether we can use primary library prim ($1) and assemble
# information on the required linker flags (prim_lflags), compiler flags
# (prim_cflags), and data directories (prim_data) as specified by cmdlineopts
# ($8).

# A compile check will be performed if [includes] ($6) is specified.  A link
# check will be performed if [function-body] ($5) is specified. The default is
# to use a program composed by concatenating [includes] and [function-body]
# with link flags specified by [lflgs] ($2), and compiler flags specified by
# [cflgs] ($3). If [dfltaction] ($7) ends in 'sep', the link check will be
# performed without the header (see LIBHDR_DFLT_HACK).

# There's really no reasonable assumptions that can be made about how a data
# directory is specified, so there's no attempt to test for existence.

# [cmdlineopts] ($8) specifies the set of configure command line options
# processed: 'nodata' processes --with-prim, --with-prim-lflags,
# and --with-prim-cflags; 'dataonly' processes only --with-prim and
# --with-prim-data; anything else ('all' works well) processes all four
# command line options. Shell code produced by the macro is tailored based
# on [cmdlineopts]. `nodata' is the default.

# --with-prim is interpreted as follows:
#   * --with-prim=no is equivalent to --without-prim
#     prim status is set to skipping
#   * --with-prim or --with-prim=yes is equivalent to
#       --with-prim-lflags=-lprim
#       --with-prim-data=/usr/local/share/prim
#     if the user doesn't override lflags & data from the command line
#     prim status is set to requested
#   * Any other value is taken as equivalent to
#       --with-prim-data=value (dataonly) or
#       --with-prim-lflags=value (anything else)
#     prim status is set to requested

# The algorithm first checks for a user-specified value of --with-prim; values
# are interpreted as above.  Next, it looks for user specified values given
# with command line parameters --with-prim-lflags, --with-prim-cflags, and
# --with-prim-data. If any of these are specified, the value overrides the
# value passed as a parameter.

# The usage portion of [dfltaction] ($7) (no, yes) is used as the default
# value of --with-prim if the user offers no guidance via command line
# parameters. The (hardwired) default is yes.  See LIBHDR_DFLT_HACK for the
# full story.

# If you really wanted to use the obsolete 'build', use COIN_CHK_PKG
# instead. All COIN ThirdParty packages produce .pc files.

# This macro doesn't test that the specified values actually work unless
# [function-body] and/or [includes] are given as parameters. This
# is deliberate.  There's no guarantee that the specified library can be
# accessed just yet with the specified flags. Put another way, unless the
# user requests a compile and/or link check, all we're doing here is filling
# in variables using a complicated algorithm.

AC_DEFUN([AC_COIN_FIND_PRIM_LIBHDR],
[
dnl Set default values for flags, action, and status. These are taken from
dnl the macro parameters, if given. Otherwise, make something up.

  m4_tolower($1_lflags)="m4_default([$2],[-l$1])"
  m4_tolower($1_cflags)="m4_default([$3],[])"
  m4_tolower($1_data)="m4_default([$4],[/usr/local/share/$1])"
  m4_if(AC_COIN_LIBHDR_DFLT_HACK([usage],[$7],[yes],[foo]),yes,
    [m4_tolower(coin_has_$1)=requested],
    [m4_tolower(coin_has_$1)=skipping
     m4_tolower($1_failmode)='default'])

dnl See if the user specified --with-prim.  If the value is something other
dnl than 'yes' or 'no' and the client specified dataonly, the value is assigned
dnl to prim_data, otherwise to prim_lflags.

  withval="$m4_tolower(with_$1)"
  if test -n "$withval" ; then
    case "$withval" in
      no )
        m4_tolower(coin_has_$1)=skipping
	m4_tolower($1_failmode)='command line'
        ;;
      yes )
        m4_tolower(coin_has_$1)=requested
	m4_tolower($1_failmode)=''
        ;;
      * )
        m4_tolower(coin_has_$1)=requested
	m4_tolower($1_failmode)=''
        m4_if(m4_default($8,nodata),dataonly,
          [m4_tolower($1_data)="$withval"],
          [m4_tolower($1_lflags)="$withval"])
        ;;
    esac
  fi

dnl As long as we're not dataonly and we're not skipping prim, check for
dnl --with-prim-lflags and --with-prim-cflgs. Values will override parameter
dnl values.

  m4_if(m4_default($8,nodata),dataonly,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval="$m4_tolower(with_$1_lflags)"
       if test -n "$withval" ; then
	 m4_tolower(coin_has_$1)=requested
	 m4_tolower($1_lflags)="$withval"
       fi

       withval="$m4_tolower(with_$1_cflags)"
       if test -n "$withval" ; then
	 m4_tolower(coin_has_$1)=requested
	 m4_tolower($1_cflags)="$withval"
       fi
     fi])

dnl If we're not nodata and we're not skipping prim, check for
dnl --with-prim-data. A value will override the parameter value.

  m4_if(m4_default($8,nodata),nodata,[],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       withval="$m4_tolower(with_$1_data)"
       if test -n "$withval" ; then
	 m4_tolower(coin_has_$1)=requested
	 m4_tolower($1_data)="$withval"
       fi
     fi])

dnl At this point, coin_has_prim can be one of skipping (user said no, or
dnl default was no without override), or requested (user said yes, or default
dnl was yes without override).

dnl If we have [includes], try to compile them.

  m4_ifnblank([$6],
    [if test $m4_tolower(coin_has_$1) != skipping ; then
       ac_save_CXXFLAGS=$CXXFLAGS
       CXXFLAGS="$m4_tolower($1_cflags)"
       AC_COMPILE_IFELSE([AC_LANG_PROGRAM([$6],[])],
         [],
	 [m4_tolower(coin_has_$1)='no'
	  m4_tolower($1_failmode)="header compile"])
       CXXFLAGS=$ac_save_CXXFLAGS
     fi])

dnl If we have a function-body, try to compile and link. Use both the
dnl [includes] and [function-body] unless the user has requested
dnl otherwise by '*sep' as [dfltaction].

  m4_ifnblank([$5],
    [if test "$m4_tolower(coin_has_$1)" != skipping ; then
       ac_save_LIBS=$LIBS
       ac_save_CXXFLAGS=$CXXFLAGS
       LIBS="$m4_tolower($1_lflags)"
       CXXFLAGS="$m4_tolower($1_cflags)"
       m4_if(AC_COIN_LIBHDR_DFLT_HACK([link],[$7],[foo],[tog]),[sep],
	 [AC_LINK_IFELSE([AC_LANG_SOURCE([$5])],
	    [],
	    [m4_tolower(coin_has_$1)='no'
	     if test -n "$m4_tolower($1_failmode)" ; then
	       m4_tolower($1_failmode)="$m4_tolower($1_failmode), bare link"
	     else
	       m4_tolower($1_failmode)="bare link"
	     fi])],
	 [AC_LINK_IFELSE([AC_LANG_PROGRAM([$6],[$5])],
	    [],
	    [m4_tolower(coin_has_$1)='no'
	     if test -n "$m4_tolower($1_failmode)" ; then
	       m4_tolower($1_failmode)="$m4_tolower($1_failmode), link with header"
	     else
	       m4_tolower($1_failmode)="link with header"
	     fi])])
       LIBS=$ac_save_LIBS
       CXXFLAGS=$ac_save_CXXFLAGS
     fi])

dnl If we're still showing requested, then we can say yes. We've passed all
dnl the tests requested by the user (which might be none, but that's on the
dnl user's head).

  if test $m4_tolower(coin_has_$1) = requested ; then
    m4_tolower(coin_has_$1)=yes
  fi

dnl The final value of coin_has_prim will be yes, no, or skipping. Skipping
dnl means that we defaulted to no or the user said no. No means that some
dnl check failed. Yes means that we defaulted to yes or the user made a
dnl specific request, and no check failed.

  # Define BUILDTOOLS_DEBUG to enable debugging output
  if test "$BUILDTOOLS_DEBUG" = 1 ; then
    AC_MSG_NOTICE([FIND_PRIM_LIB result for $1: "$m4_tolower(coin_has_$1)"])
    AC_MSG_NOTICE([Collected values for package '$1'])
    AC_MSG_NOTICE([m4_tolower($1_lflags) is "$m4_tolower($1_lflags)"])
    AC_MSG_NOTICE([m4_tolower($1_cflags) is "$m4_tolower($1_cflags)"])
    AC_MSG_NOTICE([m4_tolower($1_data) is "$m4_tolower($1_data)"])
    AC_MSG_NOTICE([m4_tolower($1_pcfiles) is "$m4_tolower($1_pcfiles)"])
  fi
])  # COIN_FIND_PRIM_LIBHDR


###########################################################################
#                         COIN_CHK_LIBHDR                                 #
###########################################################################

# COIN_CHK_LIBHDR([prim],[clients],[lflgs],[cflgs],[dflgs],
#              [function-body],[includes],
#              [dfltaction],[cmdopts])

# Determine whether we can use primary library [prim] ($1) and assemble
# information on the required linker flags (prim_lflags), compiler flags
# (prim_cflags), and data directories (prim_data). The call to DEF_PRIM_ARGS
# takes care of defining configure command line parameters for [prim]. The
# call to FIND_PRIM_LIBHDR sets variables for [prim] and does compile and
# link checks if requested. This macro controls the flow and sets up variables
# for use during the build.

# A compile check will be performed if [includes] ($7) is specified.  A link
# check will be performed if [function-body] ($6) is specified. The default is
# to use a program composed by concatenating [includes] and [function-body]
# with link flags specified by [lflgs] ($3) and compiler flags specified by
# [cflgs] ($4). If you need to override this, have a look at LIBHDR_DFLT_HACK
# and set [dfltaction] accordingly.

# The configure command line options offered to the user are controlled
# by [cmdopts] ($9). 'nodata' offers --with-prim, --with-prim-lflags, and
# --with-prim-cflags; 'dataonly' offers --with-prim and --with-prim-data;
# 'all' offers all four. DEF_PRIM_ARGS and FIND_PRIM_LIB are tailored
# accordingly. The (hardwired) default is 'nodata'.

# Macro parameters [lflgs] ($3), [cflgs] ($4), and [dflgs] ($5) are used
# for --with-prim-lflags, --with-prim-cflags, and --with-prim-data if and
# only if there are no user-supplied values on the command line. A command
# line value will override the parameter value.

# [dfltaction] ($8) (no, yes) is used as the default value of --with-prim if
# the user offers no guidance via command line parameters. The (hardwired)
# default is yes.  'Yes or no' is a simplification; see LIBHDR_DFLT_HACK
# for the full story.

# If you really wanted to use the obsolete 'build', use COIN_CHK_PKG
# instead. All COIN ThirdParty packages produce .pc files.

# Define an automake conditional COIN_HAS_PRIM to record the result. If we
# decide to use prim, also define a preprocessor symbol COIN_HAS_PRIM.

# Linker and compiler flag information will be propagated to the space-
# separated list of client packages [clients] ($2) using the _LFLAGS and
# _CFLAGS variables of the clients. These variables match Libs.private and
# Cflags.private, respectively, in a .pc file.

# Data directory information is used differently. Typically what's wanted is
# individual variables specifying the data directory for each primitive. Hence
# the macro defines PRIM_DATA for the primitive.

AC_DEFUN([AC_COIN_CHK_LIBHDR],
[ 
  AC_MSG_CHECKING(
    m4_ifnblank([$6],
      m4_ifnblank([$7],
        m4_normalize([for package $1 with
	  m4_if(AC_COIN_LIBHDR_DFLT_HACK([link],[$8],[foo],[tog]),[tog],
	    [combined link and compile check],
	    [separate link and compile checks])]),
        [for package $1 with link check]),
      m4_ifnblank([$7],[for package $1 with compile check],
                       [for package $1])))

dnl Make sure the necessary variables exist for each client package.

  m4_foreach_w([myvar],[$2],
    [AC_SUBST(m4_toupper(myvar)_LFLAGS)
     AC_SUBST(m4_toupper(myvar)_CFLAGS)
    ])

dnl Check to see if the user has overridden configure parameters from the
dnl environment.

  m4_tolower(coin_has_$1)=noInfo
  if test x"$COIN_SKIP_PROJECTS" != x ; then
    for pkg in $COIN_SKIP_PROJECTS ; do
      if test "$m4_tolower(pkg)" = "$m4_tolower($1)" ; then
        m4_tolower(coin_has_$1)=skipping
      fi
    done
  fi

dnl If we are not skipping this project, define and process the command line
dnl options according to the cmdopts parameter. Then invoke FIND_PRIM_PKG
dnl to do the heavy lifting.

  if test "$m4_tolower(coin_has_$1)" != skipping ; then
    m4_case(m4_default($9,nodata),
      nodata,  [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,no,
                AC_COIN_LIBHDR_DFLT_HACK([usage],[$8],[yes],[foo]))],
      dataonly,[AC_COIN_DEF_PRIM_ARGS([$1],yes,no,no,yes,
                AC_COIN_LIBHDR_DFLT_HACK([usage],[$8],[yes],[foo]))],
               [AC_COIN_DEF_PRIM_ARGS([$1],yes,yes,yes,yes,
	        AC_COIN_LIBHDR_DFLT_HACK([usage],[$8],[yes],[foo]))])
    AC_COIN_FIND_PRIM_LIBHDR(m4_tolower($1),
      [$3],[$4],[$5],[$6],[$7],[$8],[$9])
    if test -n "$m4_tolower($1_failmode)" ; then
      AC_MSG_RESULT([$m4_tolower(coin_has_$1) ($m4_tolower($1_failmode))])
    else
      AC_MSG_RESULT([$m4_tolower(coin_has_$1)])
    fi
  else
    AC_MSG_RESULT([$m4_tolower(coin_has_$1) (COIN_SKIP_PROJECTS)])
  fi

dnl Possibilities are `yes', `no', or `skipping'. 'Skipping' implies we
dnl decided to skip the package for some reason. 'No' means we wanted the
dnl package but failed a test. 'Yes' means we wanted the package and didn't
dnl fail any tests. Normalise to yes or no for the remainder.

  if test "$m4_tolower(coin_has_$1)" != yes ; then
    m4_tolower(coin_has_$1)=no
  fi

dnl Create an automake conditional COIN_HAS_PRIM.

  AM_CONDITIONAL(m4_toupper(COIN_HAS_$1),
                   [test $m4_tolower(coin_has_$1) = yes])

dnl If we've located the package, define preprocessor symbol PACKAGE_HAS_PRIM
dnl and augment the necessary variables for the client packages.

  if test $m4_tolower(coin_has_$1) = yes ; then
    AC_DEFINE(m4_toupper(AC_PACKAGE_NAME)_HAS_[]m4_toupper($1),[1],
      [Define to 1 if the $1 package is available])
    m4_foreach_w([myvar],[$2],
      [m4_toupper(myvar)_LFLAGS="$m4_tolower($1_lflags) $m4_toupper(myvar)_LFLAGS"
       m4_toupper(myvar)_CFLAGS="$m4_tolower($1_cflags) $m4_toupper(myvar)_CFLAGS"
      ])

dnl Finally, set up PRIM_DATA, unless the user specified nodata.

    m4_if(m4_default([$9],nodata),nodata,[],
      [AC_SUBST(m4_toupper($1)_DATA)
       m4_toupper($1)_DATA=$m4_tolower($1_data)])
  fi

])   # COIN_CHK_LIBHDR


###########################################################################
#                          COIN_CHK_LIB                                   #
###########################################################################

# COIN_CHK_LIB([prim],[clients],[lflgs],[cflgs],[dflgs],
#              [func],[header],[dfltaction],[cmdopts])

# This is a wrapper for COIN_CHK_LIBHDR (which see) that makes two simplifying
# assumptions:
#  * func is a function name and can be redeclared as
#      extern 'C' void func()
#    for the purpose of a link check
#  * header is a file name and can be used as
#      #include "header"
#    for the purpose of a compile check.
# It goes without saying that the the header file should not be included as
# part of the link check, lest the proper declaration of func in the header
# conflict with the simplified declaration used for the link check. If you
# want the real thing, use COIN_CHK_LIBHDR directly.

# The dual calls to LIBHDR_DFLT_HACK are intended to pick up the usual use
# case (configure.ac specifies usage as yes or no) and tack on a request for
# separate compile and link tests. The odd line break avoids an interior space.
# The calls to m4_ifnblank must expand here --- we want to pass the result
# of expansion to CHK_LIBHDR. Hence the double quoting for the code strings.

AC_DEFUN([AC_COIN_CHK_LIB],
[ AC_COIN_CHK_LIBHDR([$1],[$2],[$3],[$4],[$5],
    m4_ifnblank([$6],
      [[
#ifdef __cplusplus
  extern "C"
#endif
  void $6() ;
  int main () { $6() ; return (0) ; }]],[]),
    m4_ifnblank([$7],[[#include "$7"]],[]),
    AC_COIN_LIBHDR_DFLT_HACK([usage],[$8],
      [yes],[foo])AC_COIN_LIBHDR_DFLT_HACK([link],[$8],[foo],[sep]),
    [$9])
])   # COIN_CHK_LIBv2

