// Sum the numbers 0-9 and return the result

int sum_numbers(int max) {
  int sum =0;
  int i;
  for(i=0; i<max; i++) {
    sum = sum + i;
  }

  return sum;
}


int main(void)
{
  return sum_numbers(10);
}


