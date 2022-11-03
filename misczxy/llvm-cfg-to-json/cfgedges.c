#include<stdio.h>

int sum(int a, int b) {
printf("sumab");
  return a+b;
}

int sub(int a,int b){
printf("subab");
    return a-b;
}

int tiao(int a ,int b){
    if(a>b){
    	return sum(a,b);
    }else{
         return sub(a,b);
    }
}
int main() {
  int a = 10,b = 9;
  
   
  printf("%d",tiao(a,b));
}
