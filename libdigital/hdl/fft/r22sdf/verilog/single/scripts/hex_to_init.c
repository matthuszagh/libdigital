#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ROW_SIZE 3
#define MEM_SIZE 1024
#define BANK_SIZE 64

char *strrev(char *str)
{
	char *p1, *p2;

	if (!str || !*str)
		return str;
	for (p1 = str, p2 = str + strlen(str) - 1; p2 > p1; ++p1, --p2) {
		*p1 ^= *p2;
		*p2 ^= *p1;
		*p1 ^= *p2;
	}
	return str;
}

int hex2int(char ch)
{
	if (ch >= '0' && ch <= '9')
		return ch - '0';
	if (ch >= 'A' && ch <= 'F')
		return ch - 'A' + 10;
	if (ch >= 'a' && ch <= 'f')
		return ch - 'a' + 10;
	return -1;
}

// Remove the upper 2 bits from a hex digit and get the resulting
// numeric value.
int low2bits_hex(char ch)
{
	if (ch >= '0' && ch <= '9')
		return (ch - '0') % 4;
	if (ch >= 'A' && ch <= 'F')
		return (ch - 'A' + 10) % 4;
	if (ch >= 'a' && ch <= 'f')
		return (ch - 'a' + 10) % 4;
	return -1;
}

// Remove the lower 2 bits from a hex digit and get the resulting
// numeric value.
int high2bits_hex(char ch) { return (hex2int(ch) - low2bits_hex(ch)) / 4; }

int main()
{
	const char *infiles[8] = {
		"../roms/fft_r22sdf_rom_s0_re.hex", "../roms/fft_r22sdf_rom_s0_im.hex",
		"../roms/fft_r22sdf_rom_s1_re.hex", "../roms/fft_r22sdf_rom_s1_im.hex",
		"../roms/fft_r22sdf_rom_s2_re.hex", "../roms/fft_r22sdf_rom_s2_im.hex",
		"../roms/fft_r22sdf_rom_s3_re.hex", "../roms/fft_r22sdf_rom_s3_im.hex"};
	const char *outfiles[8] = {"s0_re.txt", "s0_im.txt", "s1_re.txt", "s1_im.txt",
				   "s2_re.txt", "s2_im.txt", "s3_re.txt", "s3_im.txt"};

	size_t f_idx = 0;

	while (f_idx < 8) {
		FILE *fin = fopen(infiles[f_idx], "r");
		FILE *fout = fopen(outfiles[f_idx], "w");
		char *mem = malloc((MEM_SIZE + 1) * ROW_SIZE * sizeof(char));
		memset(mem, '\0', MEM_SIZE + 1);
		char *row_mem = malloc((ROW_SIZE + 1) * sizeof(char));
		memset(row_mem, '\0', ROW_SIZE + 1);

		// read data and pad MSB 0's if needed
		int c;
		size_t col = 0;
		size_t mem_idx = 0;
		while ((c = fgetc(fin)) != EOF) {
			if (c == '\n') {
				if (col == 2) {
					row_mem[2] = row_mem[1];
					row_mem[1] = row_mem[0];
					row_mem[0] = '0';
				} else {
					if (col == 1) {
						row_mem[2] = row_mem[0];
						row_mem[1] = '0';
						row_mem[0] = '0';
					}
				}

				col = 0;
				mem[mem_idx++] = row_mem[2];
				mem[mem_idx++] = row_mem[1];
				mem[mem_idx++] = row_mem[0];
				memset(row_mem, '\0', ROW_SIZE + 1);
			} else {
				row_mem[col] = c;
				++col;
			}
		}

		// Nice code, but not necessary.
		/* // Since the size of each word is 10 bits, currently */
		/* // every 3rd hex digit is only 2 bits instead of 4. We */
		/* // need to compress these. */
		/* size_t comp_size = mem_idx * 5 / 6; */
		/* char *comp_array = malloc((comp_size + 1) * sizeof(char)); */
		/* memset(comp_array, '\0', comp_size + 1); */

		/* for (size_t i = 0; i < mem_idx; i += 6) { */
		/* 	comp_array[5 * i / 6] = mem[i]; */
		/* 	comp_array[5 * i / 6 + 1] = mem[i + 1]; */
		/* 	// only 2 bits of hex digit 2 and lower 2 of hex digit 3 */
		/* 	int hex_2 = hex2int(mem[i + 2]); */
		/* 	int lowhex_3 = 4 * low2bits_hex(mem[i + 3]); */
		/* 	char ch23[2]; */
		/* 	sprintf(ch23, "%X", hex_2 + lowhex_3); */
		/* 	comp_array[5 * i / 6 + 2] = ch23[0]; */
		/* 	// upper 2 of hex 3 and lower 2 of hex 4 */
		/* 	int high_hex_3 = high2bits_hex(mem[i + 3]); */
		/* 	int low_hex_4 = 4 * low2bits_hex(mem[i + 4]); */
		/* 	char ch34[2]; */
		/* 	sprintf(ch34, "%X", high_hex_3 + low_hex_4); */
		/* 	comp_array[5 * i / 6 + 3] = ch34[0]; */
		/* 	// upper 2 of hex 4 and lower 2 of hex 5 */
		/* 	int high_hex_4 = high2bits_hex(mem[i + 4]); */
		/* 	int low_hex_5 = 4 * low2bits_hex(mem[i + 5]); */
		/* 	char ch45[2]; */
		/* 	sprintf(ch45, "%X", high_hex_4 + low_hex_5); */
		/* 	comp_array[5 * i / 6 + 4] = ch45[0]; */
		/* } */

		// Xilinx requires data to be stored in specific sized
		// chunks. The smallest corresponding size greater
		// than 10 bits is 16 bits (this is documented in the
		// Libraries Guide in the RAMB18E1
		// section). Therefore, we need to pad 6 zeros to the
		// end of each word.
		size_t padded_size = 4 * mem_idx / 3;
		char *pad_mem = malloc(padded_size + 1);
		pad_mem[padded_size] = '\0';
		for (size_t i = 0; i < padded_size; i += 4) {
			pad_mem[i] = mem[3 * i / 4];
			pad_mem[i + 1] = mem[3 * i / 4 + 1];
			pad_mem[i + 2] = mem[3 * i / 4 + 2];
			pad_mem[i + 3] = '0';
		}

		// break up mem into chunks of 256 hex digits, then reverse
		// them.
		char *bank_mem = malloc((BANK_SIZE + 1) * sizeof(char));
		memset(bank_mem, '\0', BANK_SIZE + 1);

		size_t bank_ctr = 0;
		size_t num_arrays = (padded_size + BANK_SIZE - 1) / BANK_SIZE;
		for (size_t j = 0; j < num_arrays; ++j) {
			size_t i = 0;
			while (i < BANK_SIZE) {
				bank_mem[i] = pad_mem[BANK_SIZE * j + i];
				++i;
			}
			bank_mem = strrev(bank_mem);
			fprintf(fout, "      .INIT_%02zX(256'h%s),\n", bank_ctr, bank_mem);
			++bank_ctr;
		}

		fclose(fin);
		fclose(fout);
		free(pad_mem);
		free(row_mem);
		free(mem);
		free(bank_mem);
		++f_idx;
	}
}
