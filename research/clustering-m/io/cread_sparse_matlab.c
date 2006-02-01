#include <mex.h>

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// The most important instruction
#define skip 0

// Buffer sizes
#define MAX_LINE_LENGTH 65536
#define MAX_LINE_ELEMS  1024
#define MAX_ERR_LENGTH  1024
#define MAX_ID_LENGTH   32

// Error codes
typedef enum errcode { err_noerr, err_premature, err_illhead,
                       err_illnoval, err_illidxfor, err_illvalfor,
                       err_inerr, err_toodoc, err_idxrange } errcode;

// Error messages
static const char* errMessages[] =
    { "No error",
      "Premature end of input",
      "Ill-formed header",
      "Ill-formed line (no value)",
      "Ill-formed line (wrong index format)",
      "Ill-formed line (wrong value format)",
      "Input error",
      "Too many documents",
      "Index out of range" };

// Error line and buffer
static char errBuffer[MAX_ERR_LENGTH];
static int  errLine;

// Read the information in the file header
static errcode readHeader(FILE* file, int* ndocs, int* nterms, int* nnz) {
    // Buffer
    char buffer[MAX_LINE_LENGTH];
  
    // Read the header
    if (!fgets(buffer, MAX_LINE_LENGTH, file))
        return err_premature;
  
    // Parse
    if (sscanf(buffer, "%d %d %d", ndocs, nterms, nnz) < 3)
        return err_illhead;
        
    // Ok
    ++errLine;
    return err_noerr;
}

// Insertion sort
// Returns new size
static int insertSorted(double* valArray, int* idxArray,
                        double val, int idx,
                        int size) {
    // Find the insertion position
    int pos = size;
    while (pos > 0 && idxArray[pos - 1] > idx) {
        idxArray[pos] = idxArray[pos - 1];
        valArray[pos] = valArray[pos - 1];
        --pos;
    }
    
    // Add
    idxArray[pos] = idx;
    valArray[pos] = val;
    
    // Increase size
    return size + 1;
}
    

// Load a sparse matrix in the simple way
static errcode readSparse(FILE* file, int ndocs, int nterms,
                          int nnz, double* sr, int* irs,
                          int* jcs) {
    // Buffer
    char buffer[MAX_LINE_LENGTH];
                     
    // Document terms
    double values [MAX_LINE_ELEMS];
    int    indices[MAX_LINE_ELEMS];
    int    arrSize;
   
    // Current filling position
    int i = 0;
  
    // Current column
    int c = 0;

    // Auxiliary vars
    char *p, *q, *perr;
    unsigned long int idx;
    double val;
    bool   more;
    int    j;

    // Read every line
    while(fgets(buffer, MAX_LINE_LENGTH, file)) {
        // Check column
        if (c >= ndocs)
            return err_toodoc;
            
        // Set column start
        jcs[c] = i;
        
        // Process the line
        p       = buffer;
        more    = true;
        arrSize = 0;

        while (more) {
            // Skip blank
            while (*p && isspace(*p)) ++p;
            if (!*p) break;
      
            // Keep the pos
            q = p++;
            while(*p && !isspace(*p)) ++p;

            // Finished?
            if (!*p)
                return err_illnoval;
       
	        // Parse
            *p++ = '\0';
            idx = strtoul(q, &perr, 10);
            if (*perr)
	            return err_illidxfor;

            // Check index
            if (idx < 1 || idx > nterms)
                return err_idxrange;
                
            // Move index to where it belongs
            --idx;
            
            // Skip blank
            while (*p && isspace(*p)) ++p;
            if (!*p)
	            return err_illnoval;

            // Keep the pos
            q = p++;
            while(*p && !isspace(*p)) ++p;
      
            if (!*p) {
	            more = false;
            } else {
	            *p++ = '\0';
            }

            // Parse
            val = strtod(q, &perr);
            if (*perr)
	            return err_illvalfor;

            // If everything went fine, add it to the matrix
            arrSize = insertSorted(values, indices,
                                   val, idx, arrSize);
            
            // DEBUG
            // printf("(%d, %d) = %g\n", idx, c, val);
        }

        // Copy to the target
        for (j = 0; j < arrSize; ++j, ++i) {
            sr [i] = values [j];
            irs[i] = indices[j];
        }

        // Next column
        ++c;
        ++errLine;
    }
 
    // Error or EOF?
    if (ferror(file))
        return err_inerr;

    // Free
    fclose(file);
  
    // Enough data read?
    if (i < nnz) {
        printf("%d %d\n", i, nnz);
        return err_premature;
    }
    
    // Finish the columns
    for (j = c; j <= ndocs; ++j)
        jcs[j] = i;
        
    // Everythink OK
    return err_noerr;
}


// Access point to the loading of sparse matrices
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    // Buffers
    char filename[MAX_LINE_LENGTH];
    
    // File
    FILE* file;

    // Matrix information
    int ndocs, nterms, nnz;
    
    // Matrix contents
    double *sr;
    int    *irs, *jcs;
    
    // Auxiliary vars
    int status;
    
    // Check the number of input parameters
    if (nrhs != 1)
        mexErrMsgTxt("One input required.");

    // Check the number of output parameters    
    if (nlhs != 1)
        mexErrMsgTxt("One output required.");
     
    // Check the type of first input
    if (!mxIsChar(prhs[0]) || mxGetM(prhs[0]) != 1)
        mexErrMsgTxt("First input parameter must be a string.");
    
    // Open the file
    if (mxGetString(prhs[0], filename, MAX_LINE_LENGTH))
        mexErrMsgTxt("Filename too long.");
    if (!(file = fopen(filename, "r"))) {
        sprintf(errBuffer, "Cannot open file %s.",
                filename);
        mexErrMsgTxt(errBuffer);
    }
    
    errLine = 1;

    // Get header information
    if (status = readHeader(file, &ndocs, &nterms, &nnz)) {
        fclose(file);
        sprintf(errBuffer, "%s at %s:%d.", errMessages[status],
                filename, errLine);
        mexErrMsgTxt(errBuffer);
    }
    
    // Create matrix
    // We will return the trasposed
    plhs[0] = mxCreateSparse(nterms, ndocs, nnz, mxREAL);
    sr  = mxGetPr(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);
    
    // Read
    status = readSparse(file, ndocs, nterms, nnz, sr, irs, jcs);
    
    // Close the file
    fclose(file);
    
    // Errors?
    if (status) {
        mxDestroyArray(plhs[0]);
        plhs[0] = 0;
        sprintf(errBuffer, "%s at %s:%d.", errMessages[status],
                filename, errLine);
        mexErrMsgTxt(errBuffer);
    }
    
    // That's all!
}
