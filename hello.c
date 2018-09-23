
int fibonacci(int num) {
   if(num==1 || num==2)
       return 1;
   else
       return fibonacci(num-1) + fibonacci(num-2);
}

void main() {
	int a = fibonacci(10);
}

