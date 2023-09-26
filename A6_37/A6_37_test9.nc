int printInt(int num);
int printStr(char *c);
int readInt(int *eP);

// Forward declarations
void swap(int *p, int *q);
void readArray(int size);
void printArray(int size);
void bubbleSort(int n);
int arr[20]; // Global array
// Driver program to test above functions

int x;
int y = 5;

void swap(int *p, int *q)
{ /* Swap two numbers */
    int t = *p;
    *p = *q;
    *q = t;
    return;
}
void readArray(int size)
{ /* Function to read an array */
    int i;
    for (i = 0; i < size; i = i + 1)
    {
        printStr("Input next element\n");
        readInt(&arr[i]);
    }
    return;
}
void printArray(int size)
{ /* Function to print an array */
    int i;
    for (i = 0; i < size; i = i + 1)
    {
        printInt(arr[i]);
        printStr(" ");
    }
    printStr("\n");
    return;
}
void bubbleSort(int n)
{ /* A function to implement bubble sort */
    int i;
    int j;
    for (i = 0; i < n - 1; i = i + 1)
        // Last i elements are already in place
        for (j = 0; j < n - i - 1; j = j + 1)
            if (arr[j] > arr[j + 1])
                swap(&arr[j], &arr[j + 1]);
    return;
}
int main()
{
    int n;
    printStr("Input array size: \n");
    readInt(&n);
    printStr("Input array elements: \n");
    readArray(n);
    printStr("Input array: \n");
    printArray(n);
    bubbleSort(n);
    printStr("Sorted array: \n");
    printArray(n);
    return 0;
}
