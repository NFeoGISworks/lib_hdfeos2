#include <stdio.h>
#include "hdf.h"

#ifdef GCTP_STATIC
  #define EXTERN(type) extern type
#else
#   if defined (_WIN32) || defined (WINDOWS)
#    ifdef GCTP_DLL_EXPORTS
#      ifdef __GNUC__
#        define EXTERN(type) extern __attribute__((dllexport)) type
#      else        
#        define EXTERN(type) extern __declspec(dllexport) type
#      endif 
#    else
#      ifdef __GNUC__
#        define EXTERN(type) extern __attribute__((dllimport)) type
#      else        
#        define EXTERN(type) extern __declspec(dllimport) type
#      endif 
#    endif
#   else
#     if __GNUC__ >= 4
#       define EXTERN(type) __attribute__((visibility("default"))) type
#     else
#       define EXTERN(type)                extern type
#     endif 
#   endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

EXTERN int for_init(int outsys, int outzone, double *outparm, int outdatum, char *fn27, char *fn83, int *iflg, int32 (*for_trans[])(double, double, double *, double *));
EXTERN int inv_init(int insys, int inzone, double *inparm, int indatum, char *fn27, char *fn83, int *iflg, int32 (*inv_trans[])(double, double, double*, double*));

#ifdef __cplusplus
}
#endif