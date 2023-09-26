int printInt(int num);
int printStr(char * c);
int readInt(int *eP);

// Add two numbers
int main() {
int x = 2;
int y = 3;
int z;
z = x + y;
printInt(x);
printStr("+");
printInt(y);
printStr(" = ");
printInt(z);
return 0;
}