#include <stdio.h>
#include <stdlib.h>

void process(FILE *, FILE *);
void prn_info();

int main(int argc, char **argv)
{
	FILE *ifp, *ofp;

	if (argc != 2) {
		prn_info();
		exit(1);
	}

	ifp = fopen(argv[1], "r");
	ofp = fopen("program.mif", "w");
	process(ifp, ofp);
	fclose(ifp);
	fclose(ofp);
	return 0;
}

void process(FILE *ifp, FILE *ofp)
{
	int c;

	fprintf(ofp, "width = 16;\ndepth = 512;\n\n"
	"address_radix = hex;\ndata_radix = hex;\n\n"
	"content begin\n[0..1ff]: 0;\n\n");

	while((c = getc(ifp)) != EOF) {
		if (c != '\n')
			putc(c, ofp);
		else {
			putc(';', ofp);
			putc(c, ofp);
		}
	}

	fprintf(ofp, "\n\nend;");

	printf("Mission Accomplished");
}

void prn_info()
{
	printf("Mission Failed");
}
