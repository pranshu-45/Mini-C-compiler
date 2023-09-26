int calcAverage(int count);
/*multiline 
comment */

int main()
{
    int count;

    printf("Enter the number of integers: ");
    scanf("%d", &count);

    int average = calcAverage(count);
    // single line comment 
    printf("Average = %.2f", average);

    return 0;
}

// function to calculate average
int calcAverage(int count)
{
   int sum=0;
   int num;
   int average;
   // dummy array;
   int array[10];
   int i;
   for(i=0;i<10;i++){
      arr[i]+++1;
   }

   printf("Enter %d integers:\n", count);

   for(i=0; i<count; i=i+1)
   {
      scanf("%d", &num);
      sum = sum+num;
   }

   average = sum / count;

   return average;
}

void *dummyFunct(){
   // checks void* 
   int x = 10-10;
}
// end of program