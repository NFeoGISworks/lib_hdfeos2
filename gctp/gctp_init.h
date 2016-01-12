#include <stdio.h>
#include "hdf.h"

#ifdef GCTP_STATIC
  #define EXTERN extern
#else
#   if defined (_WIN32) || defined (WINDOWS)
#    ifdef GCTP_DLL_EXPORTS
#      ifdef __GNUC__
#        define EXTERN extern __attribute__((dllexport))
#      else        
#        define EXTERN extern __declspec(dllexport)
#      endif 
#    else
#      ifdef __GNUC__
#        define EXTERN extern __attribute__((dllimport))
#      else        
#        define EXTERN extern __declspec(dllimport)
#      endif 
#    endif
#   else
#     if __GNUC__ >= 4
#       define EXTERN __attribute__((visibility("default")))
#     else
#       define EXTERN               extern
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