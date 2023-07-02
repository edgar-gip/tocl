#include <mex.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Buffer sizes
#define MAX_LINE_LENGTH 65536
#define MAX_ERR_LENGTH  1024
#define MAX_ID_LENGTH   32

// Error codes
typedef enum errcode { err_noerr, err_noopen, err_premature,
                       err_linefor, err_hashfull, err_inerr,
                       err_nodocid } errcode;

// Error messages
static const char* errMessages[] =
    { "No error",
      "Cannot open file",
      "Premature end of input",
      "Wrong line format",
      "Document hash full",
      "Input error",
      "No such document id" };

// Error line and buffer
static char errBuffer[MAX_ERR_LENGTH];
static int  errLine;

// Hash table structure
#define HASH_SIZE 16384
typedef struct {
    char* hashKeys[HASH_SIZE];
    char* hashVals[HASH_SIZE];
    int   hashFill;
} hashTable;

// Hashes
static hashTable hDoc2Cat;
static hashTable hPresent;

// String duplication
static char* mxStrDup(char* string) {
    char* output;

    output = mxMalloc((strlen(string) + 1) * sizeof(char));
    strcpy(output, string);
    return output;
}


// Initialization
static void hashInit(hashTable* ht) {
    memset(ht->hashKeys, 0, HASH_SIZE * sizeof(char*));
    memset(ht->hashVals, 0, HASH_SIZE * sizeof(char*));
    ht->hashFill = 0;
}


// Deinitialization
static void hashFree(hashTable* ht) {
    int i;

    for (i = 0; i < HASH_SIZE; ++i) {
        mxFree(ht->hashKeys[i]);
        mxFree(ht->hashVals[i]);
    }
}


// Hashing
static int hashFunc(char* key) {
    int x   = 0;
    char* p = key;

    while (*p) x += *p++;
    return (x & (HASH_SIZE - 1));
}


// Get
static char* hashGet(hashTable* ht, char* key) {
    int h;

    // Linear hashing
    h = hashFunc(key);
    while (ht->hashKeys[h]) {
        if (!strcmp(ht->hashKeys[h], key))
            return ht->hashVals[h];
        ++h;
        h &= (HASH_SIZE - 1);
    }
    return NULL;
}


// Set
static int hashSet(hashTable* ht, char* key, char* val) {
    int h;

    if (ht->hashFill == HASH_SIZE - 1)
        return 0;

    // Linear hashing
    h = hashFunc(key);
    while (ht->hashKeys[h]) {
        // Reuse position?
        if (!strcmp(ht->hashKeys[h], key)) {
            mxFree(ht->hashVals[h]);
            if (val) {
                ht->hashVals[h] = mxStrDup(val);
            } else {
                mxFree(ht->hashKeys[h]);
                ht->hashKeys[h] = NULL;
                ht->hashVals[h] = NULL;
                --ht->hashFill;
            }
            return 1;
        }

        ++h;
        h &= (HASH_SIZE - 1);
    }

    // New position
    ht->hashKeys[h] = mxStrDup(key);
    if (val) {
        ht->hashVals[h] = mxStrDup(val);
    } else {
        mxFree(ht->hashKeys[h]);
        ht->hashKeys[h] = NULL;
        ht->hashVals[h] = NULL;
    }
    ++ht->hashFill;
    return 1;
}


// Read the doc2cat file
static errcode readDoc2Cat(char* doc2cat) {
    // Buffer
    char buffer [MAX_LINE_LENGTH];
    char docId  [MAX_ID_LENGTH];
    char labelId[MAX_ID_LENGTH];

    // File
    FILE* file;

    // Open the doc2cat file
    if (!(file = fopen(doc2cat, "r")))
        return err_noopen;

    // Read doc2cat
    errLine = 1;
    while(fgets(buffer, MAX_LINE_LENGTH, file)) {
        if (sscanf(buffer, "%s %s", docId, labelId) < 2)
            return err_linefor;

        if (!hashSet(&hDoc2Cat, docId, labelId))
            return err_hashfull;

        ++errLine;
    }

    // Error or EOF?
    if (ferror(file)) {
        fclose(file);
        return err_inerr;
    }

    // Close
    fclose(file);
    return err_noerr;
}


static errcode readRLabel(int ndocs, char* filename,
                          char*** labels) {
    // Buffer
    char buffer [MAX_LINE_LENGTH];
    char docId  [MAX_ID_LENGTH];

    // File
    FILE* file;

    // Open the rlabel file
    if (!(file = fopen(filename, "r")))
        return err_noopen;

    // Reserve memory
    *labels = mxMalloc(ndocs * sizeof(char*));

    // Read rlabel
    errLine = 1;
    while(fgets(buffer, MAX_LINE_LENGTH, file)) {
        if (sscanf(buffer, "%s", docId) < 1) {
            mxFree(*labels);
            fclose(file);
            return err_linefor;
        }

        if (!((*labels)[errLine - 1] = hashGet(&hDoc2Cat, docId))) {
            mxFree(*labels);
            fclose(file);
            return err_nodocid;
        }

        if (!hashGet(&hPresent, (*labels)[errLine - 1]))
            hashSet(&hPresent, (*labels)[errLine - 1], "present");

        ++errLine;
    }

    // Error or EOF?
    if (ferror(file)) {
        mxFree(*labels);
        fclose(file);
        return err_inerr;
    }

    // Close
    fclose(file);

    // No error
    return err_noerr;
}


// Create a cell array filled with strings
static mxArray* fillCellArray(int size, char** content) {
    mxArray* output;
    int i;

    output = mxCreateCellMatrix(size, 1);
    for (i = 0; i < size; ++i)
        mxSetCell(output, i, mxCreateString(content[i]));

    return output;
}


// Create a cell array filled with the keys of a hash
static mxArray* fillCellArrayWithKeys(hashTable* ht) {
    mxArray* output;
    int i, j;

    output = mxCreateCellMatrix(ht->hashFill, 1);
    for (i = 0, j = 0; i < HASH_SIZE && j < ht->hashFill; ++i)
        if (ht->hashKeys[i])
            mxSetCell(output, j++, mxCreateString(ht->hashKeys[i]));

    return output;
}


// Access point to the loading of labels
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    // Buffer
    char filename[MAX_LINE_LENGTH];

    // Matrix information
    int ndocs;

    // Outputs
    char** labels;

    // Auxiliary vars
    int status;

    // Check the number of input parameters
    if (nrhs != 3)
        mexErrMsgTxt("Input parameters: <rlabel> <doc2cat> <ndocs>");

    // Check the number of output parameters
    if (nlhs < 1 ||nlhs > 2)
        mexErrMsgTxt("One or two outputs required.");

    // Check the type of first input
    if (!mxIsChar(prhs[0]) || mxGetM(prhs[0]) != 1)
        mexErrMsgTxt("First input parameter must be a string.");

    // Check the type of second input
    if (!mxIsChar(prhs[1]) || mxGetM(prhs[1]) != 1)
        mexErrMsgTxt("Second input parameter must be a string.");

    // Check the type of third input
    if (!mxIsNumeric(prhs[2]) || mxGetM(prhs[2]) != 1 || mxGetN(prhs[2]) != 1)
        mexErrMsgTxt("Third input parameter must be a single number.");

    // Initialize the hash
    hashInit(&hDoc2Cat);

    // Read doc2cat
    if (mxGetString(prhs[1], filename, MAX_LINE_LENGTH))
        mexErrMsgTxt("<doc2cat> filename too long.");
    if (status = readDoc2Cat(filename)) {
        sprintf(errBuffer, "%s at %s:%d.", errMessages[status],
                filename, errLine);
        mexErrMsgTxt(errBuffer);
    }

    // Create document label list
    if (mxGetString(prhs[0], filename, MAX_LINE_LENGTH)) {
        hashFree(&hDoc2Cat);
        mexErrMsgTxt("<rlabel> filename too long.");
    }

    // Read the dimension
    ndocs = (int)(mxGetScalar(prhs[2]));

    // Initialize the hash
    hashInit(&hPresent);

    // Read rlabel
    if (status = readRLabel(ndocs, filename, &labels)) {
        hashFree(&hDoc2Cat);
        hashFree(&hPresent);
        sprintf(errBuffer, "%s at %s:%d.", errMessages[status],
                filename, errLine);
        mexErrMsgTxt(errBuffer);
    }

    // Return
    plhs[0] = fillCellArray(ndocs, labels);
    if (nlhs == 2)
        plhs[1] = fillCellArrayWithKeys(&hPresent);

    // Free the hashes
    hashFree(&hDoc2Cat);
    hashFree(&hPresent);

    // That's all!
}
