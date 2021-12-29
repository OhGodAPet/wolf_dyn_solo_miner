
#define F1(x,y,z)   (bitselect(z,y,x))
#define F0(x,y,z)   (bitselect (x, y, ((x) ^ (z))))

uint endianSwap(uint n) {
    return ( rotate(n & 0x00FF00FF, 24U) | (rotate(n, 8U) & 0x00FF00FF) );
}


unsigned int SWAP (unsigned int val)
{
    return (rotate(((val) & 0x00FF00FF), 24U) | rotate(((val) & 0xFF00FF00), 8U));
}

#define H0 0x6a09e667
#define H1 0xbb67ae85
#define H2 0x3c6ef372
#define H3 0xa54ff53a
#define H4 0x510e527f
#define H5 0x9b05688c
#define H6 0x1f83d9ab
#define H7 0x5be0cd19

#define ROL32(x, y)		rotate(x, y ## U)
#define SHR(x, y)		(x >> y)
#define SWAP32(a)    	(as_uint(as_uchar4(a).wzyx))

#define S0(x) (ROL32(x, 25) ^ ROL32(x, 14) ^  SHR(x, 3))
#define S1(x) (ROL32(x, 15) ^ ROL32(x, 13) ^  SHR(x, 10))

#define S2(x) (ROL32(x, 30) ^ ROL32(x, 19) ^ ROL32(x, 10))
#define S3(x) (ROL32(x, 26) ^ ROL32(x, 21) ^ ROL32(x, 7))

#define P(a,b,c,d,e,f,g,h,x,K)                  \
{                                               \
    temp1 = h + S3(e) + F1(e,f,g) + (K + x);      \
    d += temp1; h = temp1 + S2(a) + F0(a,b,c);  \
}

#define F0(y, x, z) bitselect(z, y, z ^ x)
#define F1(x, y, z) bitselect(z, y, x)

#define R0 (W0 = S1(W14) + W9 + S0(W1) + W0)
#define R1 (W1 = S1(W15) + W10 + S0(W2) + W1)
#define R2 (W2 = S1(W0) + W11 + S0(W3) + W2)
#define R3 (W3 = S1(W1) + W12 + S0(W4) + W3)
#define R4 (W4 = S1(W2) + W13 + S0(W5) + W4)
#define R5 (W5 = S1(W3) + W14 + S0(W6) + W5)
#define R6 (W6 = S1(W4) + W15 + S0(W7) + W6)
#define R7 (W7 = S1(W5) + W0 + S0(W8) + W7)
#define R8 (W8 = S1(W6) + W1 + S0(W9) + W8)
#define R9 (W9 = S1(W7) + W2 + S0(W10) + W9)
#define R10 (W10 = S1(W8) + W3 + S0(W11) + W10)
#define R11 (W11 = S1(W9) + W4 + S0(W12) + W11)
#define R12 (W12 = S1(W10) + W5 + S0(W13) + W12)
#define R13 (W13 = S1(W11) + W6 + S0(W14) + W13)
#define R14 (W14 = S1(W12) + W7 + S0(W15) + W14)
#define R15 (W15 = S1(W13) + W8 + S0(W0) + W15)

#define RD14 (S1(W12) + W7 + S0(W15) + W14)
#define RD15 (S1(W13) + W8 + S0(W0) + W15)


void sha256_round(uint *data, uint *buf)
{
	uint temp1;
	uint8 res;
	uint W0 = (data[0]);
	uint W1 = (data[1]);
	uint W2 = (data[2]);
	uint W3 = (data[3]);
	uint W4 = (data[4]);
	uint W5 = (data[5]);
	uint W6 = (data[6]);
	uint W7 = (data[7]);
	uint W8 = (data[8]);
	uint W9 = (data[9]);
	uint W10 = (data[10]);
	uint W11 = (data[11]);
	uint W12 = (data[12]);
	uint W13 = (data[13]);
	uint W14 = (data[14]);
	uint W15 = (data[15]);

	uint v0 = buf[0];
	uint v1 = buf[1];
	uint v2 = buf[2];
	uint v3 = buf[3];
	uint v4 = buf[4];
	uint v5 = buf[5];
	uint v6 = buf[6];
	uint v7 = buf[7];

	P(v0, v1, v2, v3, v4, v5, v6, v7, W0, 0x428A2F98);
	P(v7, v0, v1, v2, v3, v4, v5, v6, W1, 0x71374491);
	P(v6, v7, v0, v1, v2, v3, v4, v5, W2, 0xB5C0FBCF);
	P(v5, v6, v7, v0, v1, v2, v3, v4, W3, 0xE9B5DBA5);
	P(v4, v5, v6, v7, v0, v1, v2, v3, W4, 0x3956C25B);
	P(v3, v4, v5, v6, v7, v0, v1, v2, W5, 0x59F111F1);
	P(v2, v3, v4, v5, v6, v7, v0, v1, W6, 0x923F82A4);
	P(v1, v2, v3, v4, v5, v6, v7, v0, W7, 0xAB1C5ED5);
	P(v0, v1, v2, v3, v4, v5, v6, v7, W8, 0xD807AA98);
	P(v7, v0, v1, v2, v3, v4, v5, v6, W9, 0x12835B01);
	P(v6, v7, v0, v1, v2, v3, v4, v5, W10, 0x243185BE);
	P(v5, v6, v7, v0, v1, v2, v3, v4, W11, 0x550C7DC3);
	P(v4, v5, v6, v7, v0, v1, v2, v3, W12, 0x72BE5D74);
	P(v3, v4, v5, v6, v7, v0, v1, v2, W13, 0x80DEB1FE);
	P(v2, v3, v4, v5, v6, v7, v0, v1, W14, 0x9BDC06A7);
	P(v1, v2, v3, v4, v5, v6, v7, v0, W15, 0xC19BF174);

	P(v0, v1, v2, v3, v4, v5, v6, v7, R0, 0xE49B69C1);
	P(v7, v0, v1, v2, v3, v4, v5, v6, R1, 0xEFBE4786);
	P(v6, v7, v0, v1, v2, v3, v4, v5, R2, 0x0FC19DC6);
	P(v5, v6, v7, v0, v1, v2, v3, v4, R3, 0x240CA1CC);
	P(v4, v5, v6, v7, v0, v1, v2, v3, R4, 0x2DE92C6F);
	P(v3, v4, v5, v6, v7, v0, v1, v2, R5, 0x4A7484AA);
	P(v2, v3, v4, v5, v6, v7, v0, v1, R6, 0x5CB0A9DC);
	P(v1, v2, v3, v4, v5, v6, v7, v0, R7, 0x76F988DA);
	P(v0, v1, v2, v3, v4, v5, v6, v7, R8, 0x983E5152);
	P(v7, v0, v1, v2, v3, v4, v5, v6, R9, 0xA831C66D);
	P(v6, v7, v0, v1, v2, v3, v4, v5, R10, 0xB00327C8);
	P(v5, v6, v7, v0, v1, v2, v3, v4, R11, 0xBF597FC7);
	P(v4, v5, v6, v7, v0, v1, v2, v3, R12, 0xC6E00BF3);
	P(v3, v4, v5, v6, v7, v0, v1, v2, R13, 0xD5A79147);
	P(v2, v3, v4, v5, v6, v7, v0, v1, R14, 0x06CA6351);
	P(v1, v2, v3, v4, v5, v6, v7, v0, R15, 0x14292967);

	P(v0, v1, v2, v3, v4, v5, v6, v7, R0, 0x27B70A85);
	P(v7, v0, v1, v2, v3, v4, v5, v6, R1, 0x2E1B2138);
	P(v6, v7, v0, v1, v2, v3, v4, v5, R2, 0x4D2C6DFC);
	P(v5, v6, v7, v0, v1, v2, v3, v4, R3, 0x53380D13);
	P(v4, v5, v6, v7, v0, v1, v2, v3, R4, 0x650A7354);
	P(v3, v4, v5, v6, v7, v0, v1, v2, R5, 0x766A0ABB);
	P(v2, v3, v4, v5, v6, v7, v0, v1, R6, 0x81C2C92E);
	P(v1, v2, v3, v4, v5, v6, v7, v0, R7, 0x92722C85);
	P(v0, v1, v2, v3, v4, v5, v6, v7, R8, 0xA2BFE8A1);
	P(v7, v0, v1, v2, v3, v4, v5, v6, R9, 0xA81A664B);
	P(v6, v7, v0, v1, v2, v3, v4, v5, R10, 0xC24B8B70);
	P(v5, v6, v7, v0, v1, v2, v3, v4, R11, 0xC76C51A3);
	P(v4, v5, v6, v7, v0, v1, v2, v3, R12, 0xD192E819);
	P(v3, v4, v5, v6, v7, v0, v1, v2, R13, 0xD6990624);
	P(v2, v3, v4, v5, v6, v7, v0, v1, R14, 0xF40E3585);
	P(v1, v2, v3, v4, v5, v6, v7, v0, R15, 0x106AA070);

	P(v0, v1, v2, v3, v4, v5, v6, v7, R0, 0x19A4C116);
	P(v7, v0, v1, v2, v3, v4, v5, v6, R1, 0x1E376C08);
	P(v6, v7, v0, v1, v2, v3, v4, v5, R2, 0x2748774C);
	P(v5, v6, v7, v0, v1, v2, v3, v4, R3, 0x34B0BCB5);
	P(v4, v5, v6, v7, v0, v1, v2, v3, R4, 0x391C0CB3);
	P(v3, v4, v5, v6, v7, v0, v1, v2, R5, 0x4ED8AA4A);
	P(v2, v3, v4, v5, v6, v7, v0, v1, R6, 0x5B9CCA4F);
	P(v1, v2, v3, v4, v5, v6, v7, v0, R7, 0x682E6FF3);
	P(v0, v1, v2, v3, v4, v5, v6, v7, R8, 0x748F82EE);
	P(v7, v0, v1, v2, v3, v4, v5, v6, R9, 0x78A5636F);
	P(v6, v7, v0, v1, v2, v3, v4, v5, R10, 0x84C87814);
	P(v5, v6, v7, v0, v1, v2, v3, v4, R11, 0x8CC70208);
	P(v4, v5, v6, v7, v0, v1, v2, v3, R12, 0x90BEFFFA);
	P(v3, v4, v5, v6, v7, v0, v1, v2, R13, 0xA4506CEB);
	P(v2, v3, v4, v5, v6, v7, v0, v1, RD14, 0xBEF9A3F7);
	P(v1, v2, v3, v4, v5, v6, v7, v0, RD15, 0xC67178F2);

	buf[0] = (v0 + buf[0]);
	buf[1] = (v1 + buf[1]);
	buf[2] = (v2 + buf[2]);
	buf[3] = (v3 + buf[3]);
	buf[4] = (v4 + buf[4]);
	buf[5] = (v5 + buf[5]);
	buf[6] = (v6 + buf[6]);
	buf[7] = (v7 + buf[7]);
}


void SHA2_256_80(uint *hdr, uint *digestOut)
{
	uint W[16];
	uint digest[8];

	digest[0] = H0;
	digest[1] = H1;
	digest[2] = H2;
	digest[3] = H3;
	digest[4] = H4;
	digest[5] = H5;
	digest[6] = H6;
	digest[7] = H7;
	
	for(int i = 0; i < 16; ++i) W[i] = SWAP32(hdr[i]);
	
	sha256_round(W, digest);
	
	for(int i = 0; i < 4; ++i) W[i] = SWAP32(hdr[16 + i]);
	
	W[4] = 0x80000000;
	
	for(int i = 5; i < 15; ++i) W[i] = 0x00;
	
	W[15] = 80 * 8;
	sha256_round(W, digest);
	
	for(int i = 0; i < 8; ++i) digestOut[i] = SWAP32(digest[i]);
}

void SHA2_256_32(unsigned char *plain_key,  uint *digestOut) {

	int t, gid, msg_pad;
	int stop, mmod;
	uint i, item, total;
	uint W[80], temp, A,B,C,D,E,F,G,H,T1,T2;
	int current_pad;
	
	msg_pad=0;

	total = 32%64>=56?2:1 + 32/64;

	uint digest[8];

	digest[0] = H0;
	digest[1] = H1;
	digest[2] = H2;
	digest[3] = H3;
	digest[4] = H4;
	digest[5] = H5;
	digest[6] = H6;
	digest[7] = H7;

	A = digest[0];
	B = digest[1];
	C = digest[2];
	D = digest[3];
	E = digest[4];
	F = digest[5];
	G = digest[6];
	H = digest[7];

	for (t = 0; t < 80; t++){
	W[t] = 0x00000000;
	}

	current_pad = 32;

	i=current_pad;

	for (t = 0 ; t < 8 ; t++)
	W[t] = endianSwap(((uint *)plain_key)[(msg_pad >> 2) + t]);

	W[8] =  0x80000000;

	W[15] =  32*8 ;

	sha256_round(W, digest);

	for ( int i = 0; i < 8; i++)
	digestOut[i] = endianSwap(digest[i]);

}

inline void loadUintHash ( unsigned char* dest, uint* src) {


    uchar4 num0 = as_uchar4(src[0]);
    dest[3] = num0.w;
    dest[2] = num0.z;
    dest[1] = num0.y;
    dest[0] = num0.x;

    uchar4 num1 = as_uchar4(src[1]);
    dest[7] = num1.w;
    dest[6] = num1.z;
    dest[5] = num1.y;
    dest[4] = num1.x;

    uchar4 num2 = as_uchar4(src[2]);
    dest[11] = num2.w;
    dest[10] = num2.z;
    dest[9] = num2.y;
    dest[8] = num2.x;

    uchar4 num3 = as_uchar4(src[3]);
    dest[15] = num3.w;
    dest[14] = num3.z;
    dest[13] = num3.y;
    dest[12] = num3.x;

    uchar4 num4 = as_uchar4(src[4]);
    dest[19] = num4.w;
    dest[18] = num4.z;
    dest[17] = num4.y;
    dest[16] = num4.x;

    uchar4 num5 = as_uchar4(src[5]);
    dest[23] = num5.w;
    dest[22] = num5.z;
    dest[21] = num5.y;
    dest[20] = num5.x;

    uchar4 num6 = as_uchar4(src[6]);
    dest[27] = num6.w;
    dest[26] = num6.z;
    dest[25] = num6.y;
    dest[24] = num6.x;

    uchar4 num7 = as_uchar4(src[7]);
    dest[31] = num7.w;
    dest[30] = num7.z;
    dest[29] = num7.y;
    dest[28] = num7.x;



}


#define HASHOP_ADD 0
#define HASHOP_XOR 1
#define HASHOP_SHA_SINGLE 2
#define HASHOP_SHA_LOOP 3
#define HASHOP_MEMGEN 4
#define HASHOP_MEMADD 5
#define HASHOP_MEMXOR 6
#define HASHOP_MEM_SELECT 7
#define HASHOP_END 8

__constant uint AddConsts[8] =
{
	0xBB524EDB, 0xA0D2A1C9, 0x30AE0621, 0x92491F82,
	0xF7569DAB, 0x892814B6, 0x5FA17E37, 0x22BE7B70
};

__constant uint AddConsts2[8] =
{
	0xBB524EDB, 0xA0D2A1C9, 0x30AE0621, 0x92991982,
	0xF7569DAB, 0x892814B6, 0x5FA17E37, 0x22BE7B70
};

__constant uint XORConsts[8] =
{
	0x124E4358, 0x0615C709, 0x8417434B, 0xD4DDBC5E,
	0x33E3CD17, 0x17FEB0A9, 0xCA8FA352, 0x3A502E7F
};

__constant uint XORConsts2[8] =
{
	0x124E4358, 0x0615C709, 0x8417434B, 0x9499BC5E,
	0x33E3CD17, 0x17FEB0A9, 0xCA8FA352, 0x3A502E7F
};

__constant uint MemDataConsts[8] =
{
	0xA63FB75F, 0x4A42DCC2, 0x86DA33C7, 0x4DC1206B,
	0x3D079D17, 0x632048D6, 0x441EE458, 0x0AE604BA
};

#define SWAP32(x)	as_uint(as_uchar4(x).s3210)

#ifndef GPU_LOOPS
#define GPU_LOOPS 64
#endif

void SolveLegacyProgram(uint *HashRes, uint idx0, uint idx1)
{
	uint scratch[8];
	
	// First insn - SHA2 5
	for(int i = 0; i < 5; ++i)
	{
		#pragma unroll
		for(int x = 0; x < 8; ++x) scratch[x] = HashRes[x];
		
		SHA2_256_32(scratch, HashRes);
	}
		
	// Second insn - ADD
	for(int i = 0; i < 8; ++i) HashRes[i] += AddConsts[i];

	// Third insn - XOR
	for(int i = 0; i < 8; ++i) HashRes[i] ^= XORConsts[i];
	
	// Fourth insn - SHA2 2
	for(int i = 0; i < 2; ++i)
	{
		#pragma unroll
		for(int x = 0; x < 8; ++x) scratch[x] = HashRes[x];
		
		SHA2_256_32(scratch, HashRes);
	}
		
	// Fifth insn - ADD
	for(int i = 0; i < 8; ++i) HashRes[i] += AddConsts2[i];
		
	// Sixth insn - XOR
	for(int i = 0; i < 8; ++i) HashRes[i] ^= XORConsts2[i];
		
	uint GenBuf[8];
		
	// Seventh insn - MEMGEN SHA2 64	
	// Generates only the needed item
	#pragma unroll 1
	for ( int i = 0; i < idx0; i++)
	{
		#pragma unroll
		for(int x = 0; x < 8; ++x) scratch[x] = HashRes[x];
		
		SHA2_256_32(scratch, HashRes);
	}
   
	SHA2_256_32(HashRes, GenBuf);
      
	// Ninth insn - READMEM MERKLE
	
	for(int i = 0; i < 8; ++i)
		HashRes[i] = GenBuf[i] ^ MemDataConsts[i];
		
	// Tenth insn - MEMGEN 32
	// Extracts only the needed item
	for(int i = 0; i < idx1; ++i)
	{
		#pragma unroll
		for(int x = 0; x < 8; ++x) scratch[x] = HashRes[x];
		
		SHA2_256_32(scratch, HashRes);
	}
	
	SHA2_256_32(HashRes, GenBuf);
	
	// Eleventh & twelveth insn
	// MEMADD & READMEM HASHPREV
	
	#pragma unroll
	for (int i = 0; i < 8; ++i)
		HashRes[i] = GenBuf[i] + MemDataConsts[i];
			
	// Thirteenth insn - XOR
	for(int i = 0; i < 8; ++i) HashRes[i] ^= MemDataConsts[i];
		
	#pragma unroll
	for(int i = 0; i < 8; ++i) scratch[i] = HashRes[i];
	
	SHA2_256_32(scratch, HashRes);	
}

//__kernel void dyn_hash (__global uint* byteCode, __global uint* memGenBuffer, int memGenSize, __global uint* hashResult, __global unsigned char* header, __global unsigned char* shaScratch) {
//__kernel void dyn_hash (__global uint* byteCode, __global uint* hashResult, __global uint *BlkHdr, __global uint *NonceRetBuf, const ulong target)
__kernel void dyn_hash (__global uint* byteCode, __global uint *BlkHdr, __global uint *NonceRetBuf, const ulong target)
{
    uint hdr[20];
    uint myHashResult[8];

    for ( int i = 0; i < 19; i++)
        hdr[i] = BlkHdr[i];
    
    uint nonce = get_global_id(0) * GPU_LOOPS;
    
    uint idx0 = SWAP32(hdr[16]) & 63;
    uint idx1 = hdr[1] & 31;
    
    for(int hashCount = 0; hashCount < GPU_LOOPS; ++hashCount)
    {
		hdr[19] = nonce;
		
        SHA2_256_80(hdr, myHashResult);
        		
		SolveLegacyProgram(myHashResult, idx0, idx1);
		
		#ifdef XXX
		
        while (done == 0) {

            if (byteCode[linePtr] == HASHOP_ADD) {
                linePtr++;
                for ( int i = 0; i < 8; i++) 
                    myHashResult[i] += byteCode[linePtr+i];
                linePtr += 8;
            }


            else if (byteCode[linePtr] == HASHOP_XOR) {
                linePtr++;
                for ( int i = 0; i < 8; i++) 
                    myHashResult[i] ^= byteCode[linePtr+i];
                linePtr += 8;
            }


            else if (byteCode[linePtr] == HASHOP_SHA_SINGLE) {
                loadUintHash(myScratch, myHashResult);
                sha256 (  32, myScratch, myHashResult );
                linePtr++;
            }


            else if (byteCode[linePtr] == HASHOP_SHA_LOOP) {
                linePtr++;
                uint loopCount = byteCode[linePtr];
                for ( int i = 0; i < loopCount; i++) {
                    loadUintHash(myScratch, myHashResult);
                    sha256 (  32, myScratch, myHashResult );
                }
                linePtr++;
            }


            else if (byteCode[linePtr] == HASHOP_MEMGEN) {
                linePtr++;

                currentMemSize = byteCode[linePtr];
                for ( int i = 0; i < currentMemSize; i++) {
                    loadUintHash(myScratch, myHashResult);
                    sha256 (  32, myScratch, myHashResult );
                    for ( int j = 0; j < 8; j++)
                        myMemGen[i*8+j] = myHashResult[j];
                }
                
            
                linePtr++;
            }


            else if (byteCode[linePtr] == HASHOP_MEMADD) {
                linePtr++;
            
                for ( int i = 0; i < currentMemSize; i++) {
                    for ( int j = 0; j < 8; j++)
                        myMemGen[i*8+j] += byteCode[linePtr+j];
                }
            
                linePtr += 8;
            }


            else if (byteCode[linePtr] == HASHOP_MEMXOR) {
                linePtr++;
            
                for ( int i = 0; i < currentMemSize; i++) {
                    for ( int j = 0; j < 8; j++)
                        myMemGen[i*8+j] ^= byteCode[linePtr+j];
                }
            
                linePtr += 8;
            }


            else if (byteCode[linePtr] == HASHOP_MEM_SELECT) {
                linePtr++;
            
                uint index = byteCode[linePtr] % currentMemSize;
                for ( int j = 0; j < 8; j++)
                    myHashResult[j] = myMemGen[index * 8 + j];
                
                linePtr++;
            }


            else if (byteCode[linePtr] == HASHOP_END) {
                done = 1;
            }

        }
		#endif
		
		ulong res = as_ulong(as_uchar8(((ulong *)myHashResult)[0]).s76543210);
		if(res < target)
		{
			NonceRetBuf[atomic_inc(NonceRetBuf + 0xFF)] = nonce;
			break;	// we are solo mining, any other solutions will go to waste anyhow
		}
        //hashCount++;
        nonce++;
    }
}
