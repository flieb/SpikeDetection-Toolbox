
#include "mex.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    mwSize i;
    int k1;
    size_t r;
    
    double *s, *Diff2, *t2;
    int fs, plp, rp;
   
    /* create a pointer to the real data in the input matrix  */   
    s = mxGetPr(prhs[0]);
    fs = (int) mxGetScalar(prhs[1]);
    plp = (int) mxGetScalar(prhs[2]);
    rp = (int) mxGetScalar(prhs[3]);
    
    r = mxGetM(prhs[0]);
    
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)r,mxREAL);
    Diff2 = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix((mwSize)r,1,mxREAL);
    t2 = mxGetPr (plhs[1]);
    
    *Diff2 = 0;
    *t2 = 0;
    
    mwSize k2,k3,k4,k5;

    double delta1, delta2, Min, Max, Minimum, Maximum;
	int j; 
	j = 0;
    plp = plp;
    for (k1=1; k1<(r-rp); k1++)
    {
        delta1 = (s[k1-1] - s[k1])*(-1);
        delta2 = (s[k1]-s[k1+1])*(-1);
    
        if (((delta1>0) && (delta2>0))||((delta1<0) &&(delta2<0)))
            Diff2[j]= 0;
        else if ((delta1>0) && (delta2<0))
            {
            	Maximum = s[k1];
            	Min = s[k1+1];
            	for (k2=k1;k2<=k1+plp;k2++)
            	{
            		if (Min>s[k2])
            		{
            			Min = s[k2];
            		}
            	}
            	
            	if (Min == s[k1+plp])
            		{
            			for (k3=k1+plp;k3<=k1+2*plp;k3++)
            			{
            				if (s[k3]>=s[k3+1])
            					Min = s[k3+1];
            			
            				else if (s[k3]<s[k3+1])
            					break;
            			}
            		}
            	          
            Diff2[j] = Maximum - Min;
        }	     
        else if ((delta1<0) && (delta2>0))
        {
        	Minimum = s[k1];
        	Max = s[k1+1];
        	for (k4=k1;k4<=k1+plp;k4++)
        	{
        		if (Max<s[k4])
        		{
        			Max = s[k4];
        		}
        	}
        	if (Max == s[k1+plp])
        		{
        			for (k5=k1+plp;k5<=k1+2*plp;k5++)
        			{
        				if (s[k5]<=s[k5+1])
							Max = s[k5+1];
						else if (s[k5]>s[k5+1])
							break;
        			}
        		}
        	
        	Diff2[j] = (Max - Minimum)*(-1);	
        }	
      t2[j]= k1/fs;
      j++; 
    } 
}