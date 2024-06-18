#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1
#define SYS_EXIT 1
#define SYS_OPEN 5
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SHIRA_OFFSET 0x291

extern int system_call(int number, ...);
extern void infection();
extern void infector(const char *filename);

int main(int argc, char* argv[]) {
    if (argc != 2 || strncmp(argv[1], "-a", 2) != 0) {
        //Error
        system_call(SYS_EXIT, 0x55);
        return 0;
    }
    const char *filename = argv[1] + 2; // Skip the "-a"
    system_call(SYS_WRITE, STDOUT, filename, strlen(filename));
    system_call(SYS_WRITE, STDOUT, "\n", 1);
    infection();
    infector(filename);
    return 0;
}