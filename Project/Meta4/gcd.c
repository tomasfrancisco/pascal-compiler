#include <stdio.h>
#include <stdlib.h>

int x, y;

int gcd(int a, int b) {
	if(a == 0) {
		return b;
	}
	else {
		while(b > 0) {
			if(a > b) {
				a = a - b;
			} 
			else {
				b = b - a;
			}
			return a;
		}
	}
}

void main(int argc, char** argv) {
	if(argc >= 2) {
		x = argv[0];
		y = argv[1];
		printf("%d\n", gcd(x, y));
	}
	else {
		printf("Error: two parameters required.\n");
	}
}