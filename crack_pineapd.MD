1. download the latest firmware from here: https://www.wifipineapple.com/downloads
Latest firmware version 2.7.0 as time of writing

2. Unpacking

I use binwalk, but other unpacking tools are fine. Any unpacking tool that supports squashfs will work. The purpose of unpacking is to get the pineapd file.

3. Open the usr/sbin directory, and find pineapd.

4. Use Ghidra to load pineapd

I'm using the latest version of Ghidra, the highest version of Ghidra as of now is 9.1.2

5. open Ghidra's string window

Thank goodness official wifipineapple didn't shell pineapd, or it would be cool. Opening the string window will reveal a couple of shell commands

6. Find the authentication part of the data segment

Following up on these strings of shell commands on the data side, the point of finding the data segment is to cross-reference the next step, so you can clearly see which logical code in the code end is referencing that data
It is something like:

```
s_dmesh_|_head_-n2_|_awk_'FNR_==_2_0041c0d4
```


7. Cross-references

Cross Reference See which functions use this data. The address `0040e960` was found to reference this data

8. According to the cross-reference to find the verification function logic code, and draw the patch method

This paragraph starts with the logic of the pineapd validation function, and on the right is the flowchart.
As we can see from the code, if the validation is successful, it will return _s2, which is a pointer variable that will most likely be called by another function. One is to modify the data side of the program directly to enable the program to execute unintended shell commands, and then read the return value of the shell command into the program in accordance with the operation of the program itself, and then return it to normal after the strcmp command.
The second method is to directly modify the runtime environment of dmesg, so that dmesg after the original shell command output can be normal. Here I will introduce you to the first method, first construct a shell command with an output of 44b65156.
Use echo and awk or whatever you can. Here I use the awk command

`awk 'BEGIN{print "44b65156"}' `

or

`echo "44b65156"`

9. Modify the shell command to assign the correct value to the `__S2` pointer variable.

ghidra is easy to modify strings, you can find the physical address of a string and modify it directly in the editor. What if the original command is very long, but the command we want to change is very short? You can just use 20, which is the space bar. For example:

```
/* WARNING: Unknown calling convention yet parameter storage is locked */
/* gtmgc() */

char * gtmgc(void)

{
  char *__s2;
  int iVar1;

  __s2 = (char *)exec("cat /proc/cmdline | awk \\'{ split($1,x,\"=\"); print x[2] }\'");
  iVar1 = strncmp("WIFI-PINEAPPLE-NANO",__s2,0x13);
  if (iVar1 == 0) {
    __s2 = (char *)exec(
                       "awk \'BEGIN{print \"44b65156\\"}\' "
                       );
    iVar1 = strncmp("44b65156",__s2,8);
  }
  else {
    iVar1 = strncmp("PINEAPPLE-TETRA",__s2,0xf);
    if (iVar1 ! = 0) {
      return (char *)0;
    }
    __s2 = (char *)exec("dmesg | head -n4 | awk \'FNR == 4 { print($5, $6) }\'");
    iVar1 = strncmp("AR9344 rev",__s2,10);
  }
  if (iVar1 ! = 0) {
    return (char *)0;
  }
  return __s2;
}
```

10. repack the bin file and it's done
