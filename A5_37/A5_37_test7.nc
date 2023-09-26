int printInt(int num);
int printStr(char * c);
int readInt(int *eP);

// Find factorial by recursion
int factorial(int n) {
if (n == 0)
return 1;
else
{
    int z = factorial(n-1);
    printInt(z);
    printStr("\n");
    return n*z;}
}
int main() {
int n = 5;
int r;
r = factorial(n);
printInt(n);
printStr("! = ");
printInt(r);
return 0;
}