#include <stdio.h>
#include "hdf.h"

#if defined (_WIN32) || defined (WINDOWS)
#    ifdef GCTP_DLL_EXPORTS
#        define EXTERN extern __declspec(dllexport)
#    else
#        define EXTERN extern __declspec(dllimport)
#    endif
#else
#    define EXTERN extern
#endif

#ifdef __cplusplus
extern "C" {
#endif

EXTERN int for_init(int outsys, int outzone, double *outparm, int outdatum, char *fn27, char *fn83, int *iflg, int32 (*for_trans[])(double, double, double *, double *));
EXTERN int inv_init(int insys, int inzone, double *inparm, int indatum, char *fn27, char *fn83, int *iflg, int32 (*inv_trans[])(double, double, double*, double*));

#ifdef __cplusplus
}
#endif