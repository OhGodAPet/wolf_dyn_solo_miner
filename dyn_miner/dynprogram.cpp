#include "dynprogram.h"
// WHISKERZ CODE
//#include "Windows.h"
#include <curl/curl.h>
#include <nlohmann/json.hpp>
#include <thread>
// WHISKERZ

std::string CDynProgram::execute(unsigned char* blockHeader, std::string prevBlockHash, std::string merkleRoot) {

    //initial input is SHA256 of header data

    CSHA256 ctx;

    uint32_t iResult[8];

    /*
    for (int i = 0; i < 80; i++)
        printf("%02X", blockHeader[i]);
    printf("\n");
    */


    ctx.Write(blockHeader, 80);
    ctx.Finalize((unsigned char*)iResult);

    /*
    for (int i = 0; i < 8; i++)
        printf("%08X", iResult[i]);
    printf("\n");
    */



    int line_ptr = 0;       //program execution line pointer
    int loop_counter = 0;   //counter for loop execution
    unsigned int memory_size = 0;    //size of current memory pool
    uint32_t* memPool = NULL;     //memory pool

    while (line_ptr < program.size()) {
        std::istringstream iss(program[line_ptr]);
        std::vector<std::string> tokens{ std::istream_iterator<std::string>{iss}, std::istream_iterator<std::string>{} };     //split line into tokens

        //simple ADD and XOR functions with one constant argument
        if (tokens[0] == "ADD") {
            uint32_t arg1[8];
            parseHex(tokens[1], (unsigned char*)arg1);

            for (int i = 0; i < 8; i++)
                iResult[i] += arg1[i];

        }

        else if (tokens[0] == "XOR") {
            uint32_t arg1[8];
            parseHex(tokens[1], (unsigned char*)arg1);
            for (int i = 0; i < 8; i++)
                iResult[i] ^= arg1[i];
        }

        //hash algo which can be optionally repeated several times
        else if (tokens[0] == "SHA2") {
            if (tokens.size() == 2) { //includes a loop count
                loop_counter = atoi(tokens[1].c_str());
                for (int i = 0; i < loop_counter; i++) {
                    if (tokens[0] == "SHA2") {
                        unsigned char output[32];
                        ctx.Reset();
                        ctx.Write((unsigned char*)iResult, 32);
                        ctx.Finalize(output);
                        memcpy(iResult, output, 32);
                    }
                }
            }

            else {                         //just a single run
                if (tokens[0] == "SHA2") {
                    unsigned char output[32];
                    ctx.Reset();
                    ctx.Write((unsigned char*)iResult, 32);
                    ctx.Finalize(output);
                    memcpy(iResult, output, 32);
                }
            }
        }

        //generate a block of memory based on a hashing algo
        else if (tokens[0] == "MEMGEN") {
            if (memPool != NULL)
                free(memPool);
            memory_size = atoi(tokens[2].c_str());
            memPool = (uint32_t*)malloc(memory_size * 32);
            for (int i = 0; i < memory_size; i++) {
                if (tokens[1] == "SHA2") {
                    unsigned char output[32];
                    ctx.Reset();
                    ctx.Write((unsigned char*)iResult, 32);
                    ctx.Finalize(output);
                    memcpy(iResult, output, 32);
                    memcpy(memPool + i * 8, iResult, 32);
                }
            }
        }

        //add a constant to every value in the memory block
        else if (tokens[0] == "MEMADD") {
            if (memPool != NULL) {
                uint32_t arg1[8];
                parseHex(tokens[1], (unsigned char*)arg1);

                for (int i = 0; i < memory_size; i++) {
                    for (int j = 0; j < 8; j++)
                        memPool[i * 8 + j] += arg1[j];
                }
            }
        }

        //xor a constant with every value in the memory block
        else if (tokens[0] == "MEMXOR") {
            if (memPool != NULL) {
                uint32_t arg1[8];
                parseHex(tokens[1], (unsigned char*)arg1);

                for (int i = 0; i < memory_size; i++) {
                    for (int j = 0; j < 8; j++)
                        memPool[i * 8 + j] ^= arg1[j];
                }
            }
        }

        //read a value based on an index into the generated block of memory
        else if (tokens[0] == "READMEM") {
            if (memPool != NULL) {
                unsigned int index = 0;

                if (tokens[1] == "MERKLE") {
                    uint32_t arg1[8];
                    parseHex(merkleRoot, (unsigned char*)arg1);
                    index = arg1[0] % memory_size;
                    memcpy(iResult, memPool + index * 8, 32);
                }

                else if (tokens[1] == "HASHPREV") {
                    uint32_t arg1[8];
                    parseHex(prevBlockHash, (unsigned char*)arg1);
                    index = arg1[0] % memory_size;
                    memcpy(iResult, memPool + index * 8, 32);
                }
            }
        }


        /*
        printf("line %02d    ", line_ptr);
        unsigned char xx[32];
        memcpy(xx, iResult, 32);
        for (int i = 0; i < 32; i++)
            printf("%02X", xx[i]);
        printf("\n");
        */


        line_ptr++;


    }


    if (memPool != NULL)
        free(memPool);

    return makeHex((unsigned char*)iResult, 32);
}


std::string CDynProgram::getProgramString() {
    std::string result;

    for (int i = 0; i < program.size(); i++)
        result += program[i] + "\n";

    return result;
}


void CDynProgram::parseHex(std::string input, unsigned char* output) {

    for (int i = 0; i < input.length(); i += 2) {
        unsigned char value = decodeHex(input[i]) * 16 + decodeHex(input[i + 1]);
        output[i / 2] = value;
    }
}

unsigned char CDynProgram::decodeHex(char in) {
    in = toupper(in);
    if ((in >= '0') && (in <= '9'))
        return in - '0';
    else if ((in >= 'A') && (in <= 'F'))
        return in - 'A' + 10;
    else
        return 0;       //todo raise error
}

std::string CDynProgram::makeHex(unsigned char* in, int len)
{
    std::string result;
    for (int i = 0; i < len; i++) {
        result += hexDigit[in[i] / 16];
        result += hexDigit[in[i] % 16];
    }
    return result;
}


void CDynProgram::initOpenCL(int platformID, int computeUnits)
{
    uint32_t largestMemgen = 0;
    uint32_t byteCodeLen = 0;
    uint32_t* byteCode = executeGPUAssembleByteCode(&largestMemgen, "0000", "0000", &byteCodeLen);  //only calling to get largestMemgen


    cl_int returnVal;
    cl_platform_id* platform_id = (cl_platform_id*)malloc(16 * sizeof(cl_platform_id));
    openCLDevices = (cl_device_id*)malloc(16 * sizeof(cl_device_id));
    cl_uint ret_num_platforms;
    cl_context* context = (cl_context*)malloc(16 * sizeof(cl_context));
    kernel = (cl_kernel*)malloc(16 * sizeof(cl_kernel));
    command_queue = (cl_command_queue*)malloc(16 * sizeof(cl_command_queue));


    //clGPUHashResultBuffer = (cl_mem*)malloc(16 * sizeof(cl_mem));
    //buffHashResult = (uint32_t**)malloc(16 * sizeof(uint32_t*));
	clNonceReturnBuf = (cl_mem *)malloc(16 * sizeof(cl_mem));
    clGPUHeaderBuffer = (cl_mem*)malloc(16 * sizeof(cl_mem));
    //buffHeader = (unsigned char**)malloc(16 * sizeof(char*));

    clGPUProgramBuffer = (cl_mem*)malloc(16 * sizeof(cl_mem));

    //Initialize context
    returnVal = clGetPlatformIDs(16, platform_id, &ret_num_platforms);
    returnVal = clGetDeviceIDs(platform_id[platformID], CL_DEVICE_TYPE_GPU, 16, openCLDevices, &numOpenCLDevices);
    
    GPUCount = numOpenCLDevices;
    
    for (int i = 0; i < numOpenCLDevices; i++)
    {
        context[i] = clCreateContext(NULL, 1, &openCLDevices[i], NULL, NULL, &returnVal);
        
        //Read the kernel source
        FILE* kernelSourceFile;

        kernelSourceFile = fopen("dyn_miner.cl", "r");
        if (!kernelSourceFile) {

            fprintf(stderr, "Failed to load kernel.\n");
            return;

        }
        fseek(kernelSourceFile, 0, SEEK_END);
        size_t sourceFileLen = ftell(kernelSourceFile) + 1;
        char* kernelSource = (char*)malloc(sourceFileLen);
        memset(kernelSource, 0, sourceFileLen);
        fseek(kernelSourceFile, 0, SEEK_SET);
        size_t numRead = fread(kernelSource, 1, sourceFileLen, kernelSourceFile);
        fclose(kernelSourceFile);


        cl_program program;

        //Create kernel program
        program = clCreateProgramWithSource(context[i], 1, (const char**)&kernelSource, (const size_t*)&numRead, &returnVal);
        returnVal = clBuildProgram(program, 1, &openCLDevices[i], "-DGPU_LOOPS=64", NULL, NULL);
        free(kernelSource);

        if (returnVal == CL_BUILD_PROGRAM_FAILURE) {
            // Determine the size of the log
            size_t log_size;
            clGetProgramBuildInfo(program, openCLDevices[i], CL_PROGRAM_BUILD_LOG, 0, NULL, &log_size);

            // Allocate memory for the log
            char* log = (char*)malloc(log_size);

            // Get the log
            clGetProgramBuildInfo(program, openCLDevices[i], CL_PROGRAM_BUILD_LOG, log_size, log, NULL);

            // Print the log
            printf("\n\n%s\n", log);
        }

        kernel[i] = clCreateKernel(program, "dyn_hash", &returnVal);
        command_queue[i] = clCreateCommandQueueWithProperties(context[i], openCLDevices[i], NULL, &returnVal);

        // Allocate program source buffer
        clGPUProgramBuffer[i] = clCreateBuffer(context[i], CL_MEM_READ_WRITE, byteCodeLen, NULL, &returnVal);
        
		// Allocate nonce return buffer
		clNonceReturnBuf[i] = clCreateBuffer(context[i], CL_MEM_READ_WRITE, sizeof(cl_uint) * 0x100, NULL, &returnVal);
		
        // Allocate header buffer
        clGPUHeaderBuffer[i] = clCreateBuffer(context[i], CL_MEM_READ_WRITE, 80, NULL, &returnVal);
        
        returnVal = clSetKernelArg(kernel[i], 0, sizeof(clGPUProgramBuffer[i]), (void*)&clGPUProgramBuffer[i]);
        returnVal = clSetKernelArg(kernel[i], 1, sizeof(clGPUHeaderBuffer[i]), (void*)&clGPUHeaderBuffer[i]);
        returnVal = clSetKernelArg(kernel[i], 2, sizeof(cl_mem), &clNonceReturnBuf[i]);
    }


}

#define GPU_LOOPS	64

//returns 1 if timeout or 0 if successful
int CDynProgram::executeGPU(unsigned char* blockHeader, std::string prevBlockHash, std::string merkleRoot, unsigned char* nativeTarget, uint32_t* resultNonce, int numComputeUnits, uint32_t serverNonce, int gpuIndex, CDynProgram* dynProgram)
{
    uint32_t byteCodeLen = 0, junk;
    uint32_t *byteCode = executeGPUAssembleByteCode(&junk, prevBlockHash, merkleRoot, &byteCodeLen);

    cl_int returnVal;

    returnVal = clEnqueueWriteBuffer(command_queue[gpuIndex], clGPUProgramBuffer[gpuIndex], CL_TRUE, 0, byteCodeLen, byteCode, 0, NULL, NULL);

    time_t start;
    time(&start);
    time_t lastreport = start;
	
    int loops = 0;
    
    // Divide the 32-bit nonce space over the available GPUs.
	uint32_t MinNonce = (0xFFFFFFFFULL / GPUCount) * gpu;
	uint32_t MaxNonce = MinNonce + (0xFFFFFFFFULL / GPUCount);
	uint32_t nonce = MinNonce;
    
    int gpuLoops = GPU_LOOPS;
	uint64_t target = __builtin_bswap64(((uint64_t *)nativeTarget)[0]);
	returnVal = clSetKernelArg(kernel[gpuIndex], 3, sizeof(cl_ulong), &target);
	
    uint32_t startNonce = nonce;
    returnVal = clEnqueueWriteBuffer(command_queue[gpuIndex], clGPUHeaderBuffer[gpuIndex], CL_TRUE, 0, 80, blockHeader, 0, NULL, NULL);
    while ((!globalFound) && (!globalTimeout))
    {
		uint32_t zero = 0;
        
		returnVal = clEnqueueWriteBuffer(command_queue[gpuIndex], clNonceReturnBuf[gpuIndex], CL_TRUE, 0xFF * sizeof(cl_uint), sizeof(cl_uint), &zero, 0, NULL, NULL);
		
        size_t globalWorkSize = numComputeUnits;
        size_t localWorkSize = 256;
        
		size_t gOffset = nonce;
        returnVal = clEnqueueNDRangeKernel(command_queue[gpuIndex], kernel[gpuIndex], 1, &gOffset, &globalWorkSize, &localWorkSize, 0, NULL, NULL);
        returnVal = clFinish(command_queue[gpuIndex]);
                
        uint32_t results[0x100];
			returnVal = clEnqueueReadBuffer(command_queue[gpuIndex], clNonceReturnBuf[gpuIndex],
				CL_TRUE, 0, 0x100 * sizeof(cl_uint), results, 0, NULL, NULL);
		
		for(int i = 0; i < results[0xFF]; ++i)
		{
			// Solo mining - if we just mined a block, obviously
			// any and all remaining solutions are useless.
			
			globalFound = true;
			*resultNonce = results[i];
			return true;
		}
		
        time_t now;
        time(&now);
        if ((now - lastreport) >= 3) {
            time_t current;
            time(&current);
            long long diff = current - start;
            dynProgram->outputStats(dynProgram, current, start, (nonce - startNonce));

            lastreport = now;
        }
        
        if(nonce >= MaxNonce)
		{
			printf("WARNING: GPU %d ran out of work!\nTODO: Fix me.\n", gpu);
			return false;
		}
        
        loops++;
        nonce += numComputeUnits * gpuLoops;
        globalNonceCount += numComputeUnits * gpuLoops;
    }

    return false;
}




uint32_t* CDynProgram::executeGPUAssembleByteCode(uint32_t* largestMemgen, std::string prevBlockHash, std::string merkleRoot, uint32_t* byteCodeLen) {

    std::vector<uint32_t> code;



    int line_ptr = 0;       //program execution line pointer
    int loop_counter = 0;   //counter for loop execution
    unsigned int memory_size = 0;    //size of current memory pool
    uint32_t* memPool = NULL;     //memory pool

    while (line_ptr < program.size()) {
        std::istringstream iss(program[line_ptr]);
        std::vector<std::string> tokens{ std::istream_iterator<std::string>{iss}, std::istream_iterator<std::string>{} };     //split line into tokens

        //simple ADD and XOR functions with one constant argument
        if (tokens[0] == "ADD") {
            uint32_t arg1[8];
            parseHex(tokens[1], (unsigned char*)arg1);
            code.push_back(HASHOP_ADD);
            for (int i = 0; i < 8; i++)
                code.push_back(arg1[i]);
        }

        else if (tokens[0] == "XOR") {
            uint32_t arg1[8];
            code.push_back(HASHOP_XOR);
            parseHex(tokens[1], (unsigned char*)arg1);
            for (int i = 0; i < 8; i++)
                code.push_back(arg1[i]);
        }

        //hash algo which can be optionally repeated several times
        else if (tokens[0] == "SHA2") {
            if (tokens.size() == 2) { //includes a loop count
                loop_counter = atoi(tokens[1].c_str());
                code.push_back(HASHOP_SHA_LOOP);
                code.push_back(loop_counter);
            }

            else {                         //just a single run
                if (tokens[0] == "SHA2") {
                    code.push_back(HASHOP_SHA_SINGLE);
                }
            }
        }

        //generate a block of memory based on a hashing algo
        else if (tokens[0] == "MEMGEN") {
            memory_size = atoi(tokens[2].c_str());
            code.push_back(HASHOP_MEMGEN);
            code.push_back(memory_size);
            if (memory_size > *largestMemgen)
                *largestMemgen = memory_size;
        }

        //add a constant to every value in the memory block
        else if (tokens[0] == "MEMADD") {
            code.push_back(HASHOP_MEMADD);
            uint32_t arg1[8];
            parseHex(tokens[1], (unsigned char*)arg1);
            for (int j = 0; j < 8; j++)
                code.push_back(arg1[j]);
        }

        //xor a constant with every value in the memory block
        else if (tokens[0] == "MEMXOR") {
            code.push_back(HASHOP_MEMXOR);
            uint32_t arg1[8];
            parseHex(tokens[1], (unsigned char*)arg1);
            for (int j = 0; j < 8; j++)
                code.push_back(arg1[j]);
        }

        //read a value based on an index into the generated block of memory
        else if (tokens[0] == "READMEM") {
            code.push_back(HASHOP_MEM_SELECT);
            if (tokens[1] == "MERKLE") {
                uint32_t arg1[8];
                parseHex(merkleRoot, (unsigned char*)arg1);
                code.push_back(arg1[0]);
            }

            else if (tokens[1] == "HASHPREV") {
                uint32_t arg1[8];
                parseHex(prevBlockHash, (unsigned char*)arg1);
                code.push_back(arg1[0]);
            }
        }

        line_ptr++;
    }

    code.push_back(HASHOP_END);

    uint32_t* result = (uint32_t*)malloc(sizeof(uint32_t) * code.size());
    for (int i = 0; i < code.size(); i++)
        result[i] = code.at(i);

    *byteCodeLen = code.size() * 4;

    return result;

}

// WHISKERZ CODE:

struct MemoryStruct {
    char* memory;
    size_t size;
};

static size_t WriteMemoryCallback(void* contents, size_t size, size_t nmemb, void* userp)
{
    size_t realsize = size * nmemb;
    struct MemoryStruct* mem = (struct MemoryStruct*)userp;

    char* ptr = (char*)realloc(mem->memory, mem->size + realsize + 1);
    if (ptr == NULL) {
        /* out of memory! */
        printf("not enough memory (realloc returned NULL)\n");
        return 0;
    }

    mem->memory = ptr;
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;

    return realsize;
}





bool CDynProgram::outputStats(CDynProgram* dynProgram, time_t now, time_t start, uint32_t nonce)
{
    //HANDLE hConsole = GetStd//HANDLE(STD_OUTPUT_//HANDLE);

    struct tm* timeinfo;
    char timestamp[80];
    timeinfo = localtime(&now);
    strftime(timestamp, 80, "%F %T", timeinfo);
    char rateDisplay[256];
    float hashrate = (float)nonce / (float)(now - start);
    if (hashrate >= tb)
        sprintf(rateDisplay, "%.2f TH/s", (float)hashrate / tb);
    else if (hashrate >= gb && hashrate < tb)
        sprintf(rateDisplay, "%.2f GH/s", (float)hashrate / gb);
    else if (hashrate >= mb && hashrate < gb)
        sprintf(rateDisplay, "%.2f MH/s", (float)hashrate / mb);
    else if (hashrate >= kb && hashrate < mb)
        sprintf(rateDisplay, "%.2f KH/s", (float)hashrate / kb);
    else if (hashrate < kb)
        sprintf(rateDisplay, "%.2f H/s ", hashrate);
    else
        sprintf(rateDisplay, "%.2f H/s", hashrate);

    int uptimeSeconds = difftime(now, dynProgram->miningStartTime);
    std::string uptime = convertSecondsToUptime(uptimeSeconds);
    float uptimeMinutes = (float)uptimeSeconds / (float)60;
    float coinsPerMinute = 0;
    if (dynProgram->acceptedBlocks > 0) {
        coinsPerMinute = (float)dynProgram->acceptedBlocks / uptimeMinutes;
    }
    else {
        coinsPerMinute = 0;
    }

    //SetConsoleTextAttribute(hConsole, LIGHTBLUE);
    printf("%s: ", timestamp);
    //SetConsoleTextAttribute(hConsole, GREEN);
    printf("%s", rateDisplay);
    //SetConsoleTextAttribute(hConsole, LIGHTGRAY);
    printf(" | ");
    //SetConsoleTextAttribute(hConsole, LIGHTGREEN);
    printf("%d", dynProgram->height);
    //SetConsoleTextAttribute(hConsole, LIGHTGRAY);
    printf(" | ");
    //SetConsoleTextAttribute(hConsole, BLUE);
    printf("Uptime:%s", uptime.c_str());
    //SetConsoleTextAttribute(hConsole, LIGHTGRAY);
    printf(" | ");
    //SetConsoleTextAttribute(hConsole, LIGHTGREEN);
    printf("A:%d", dynProgram->acceptedBlocks);
    //SetConsoleTextAttribute(hConsole, GREEN);
    printf(" (%.2f/m)", coinsPerMinute);
    //SetConsoleTextAttribute(hConsole, RED);
    printf(" R:%d", dynProgram->rejectedBlocks);
    //SetConsoleTextAttribute(hConsole, LIGHTGRAY);
    printf(" | ");
    //SetConsoleTextAttribute(hConsole, LIGHTMAGENTA);
    printf("DynMiner %s %s\n", minerVersion, dynProgram->minerType);
    //SetConsoleTextAttribute(hConsole, LIGHTGRAY);

    return(true);
}

std::string CDynProgram::convertSecondsToUptime(int n)
{
    int days = n / (24 * 3600);

    n = n % (24 * 3600);
    int hours = n / 3600;

    n %= 3600;
    int minutes = n / 60;

    n %= 60;
    int seconds = n;

    std::string uptimeString;
    if (days > 0) {
        uptimeString = std::to_string(days) + "d" + std::to_string(hours) + "h" + std::to_string(minutes) + "m" + std::to_string(seconds) + "s";
    }
    else if (hours > 0) {
        uptimeString = std::to_string(hours) + "h" + std::to_string(minutes) + "m" + std::to_string(seconds) + "s";
    }
    else if (minutes > 0) {
        uptimeString = std::to_string(minutes) + "m" + std::to_string(seconds) + "s";
    }
    else {
        uptimeString = std::to_string(seconds) + "s";
    }

    return(uptimeString);
}
// END WHISKERZ

