// Swap two numbers
int printInt(int n);
int printStr(char * c);
int readInt(int *eP);

// Swap two numbers
void swap(int* a, int* b);


int main() {
int x;
int y;
readInt(&x);
readInt(&y);
printStr("Before swap:\n");
printStr("x = "); printInt(x);
printStr(" y = "); printInt(y);
swap(&x, &y);
printStr("\nAfter swap:\n");
printStr("x = "); printInt(x);
printStr(" y = "); printInt(y);
return 0;
}
void swap(int *p, int *q) {
    int a=5;
    int b=6;
int t;
t = *p;
*p = *q;
*q = t;
return;
}
