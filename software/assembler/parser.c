#include "parser.h"

// FIXME: add support to identify and parse I-type and SB-type instructions
void load_instructions(instruction_memory_t *i_mem, const char *trace)
{
    //printf("Loading trace file: %s\n\n", trace);
    FILE *fd = fopen(trace, "r");
    if (fd == NULL)
    {
        perror("Cannot open trace file. \n");
        exit(EXIT_FAILURE);
    }

    // Iterate over all the assembly instructions
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    addr_t PC = 0; // program counter points to the zeroth location initially.
    int IMEM_index = 0;

    while ((read = getline(&line, &len, fd)) != -1)
    {
        // Assign program counter
        i_mem->instructions[IMEM_index].addr = PC;

        // Extract operation or opcode from the assembly instruction
        char *raw_instr = strtok(line, " ");
        if (strcmp(raw_instr, "add") == 0 ||
            strcmp(raw_instr, "sub") == 0 ||
            strcmp(raw_instr, "sll") == 0 ||
            strcmp(raw_instr, "srl") == 0 ||
            strcmp(raw_instr, "xor") == 0 ||
            strcmp(raw_instr, "or") == 0 ||
            strcmp(raw_instr, "and") == 0)
        {
            parse_R_type(raw_instr, &(i_mem->instructions[IMEM_index]));
            i_mem->last = &(i_mem->instructions[IMEM_index]);
        }

        if (strcmp(raw_instr, "ld") == 0 ||
            strcmp(raw_instr, "addi") == 0 ||
            strcmp(raw_instr, "subi") == 0 ||
            strcmp(raw_instr, "slli") == 0 ||
            strcmp(raw_instr, "srli") == 0 ||
            strcmp(raw_instr, "xori") == 0 ||
            strcmp(raw_instr, "ori") == 0 ||
            strcmp(raw_instr, "andi") == 0)
        {
            parse_I_type(raw_instr, &(i_mem->instructions[IMEM_index]));
            i_mem->last = &(i_mem->instructions[IMEM_index]);
        }

        if (strcmp(raw_instr, "bne") == 0 ||
            strcmp(raw_instr, "beq") == 0 ||
            strcmp(raw_instr, "blt") == 0 || 
            strcmp(raw_instr, "bge") == 0 )
        {
            parse_SB_type(raw_instr, &(i_mem->instructions[IMEM_index]));
            i_mem->last = &(i_mem->instructions[IMEM_index]);
        }

        IMEM_index++;
        PC += 4;
    }

    fclose(fd);
}

// Parse and assemble R-type instruction
void parse_R_type(char *opr, instruction_t *instr)
{
    instr->instruction = 0;
    unsigned opcode = 0;
    unsigned funct3 = 0;
    unsigned funct7 = 0;

    if (strcmp(opr, "add") == 0)
    {
        opcode = 51;
        funct3 = 0;
        funct7 = 0;
    }

    char *reg = strtok(NULL, ", ");
    unsigned rd = get_register_number(reg);

    reg = strtok(NULL, ", ");
    unsigned rs_1 = get_register_number(reg);

    reg = strtok(NULL, ", ");
    reg[strlen(reg) - 1] = '\0';
    unsigned rs_2 = get_register_number(reg);

    // Print the tokens
    //printf("Opcode: %u\n", opcode);
    //printf("funct3: %u\n", funct3);
    //printf("funct7: %u\n", funct7);
    //printf("Source register 1: %u\n", rs_1);
    //printf("Source register 2: %u\n", rs_2);
    //printf("Destination register: %u\n\n", rd);

    // Contruct instruction
    instr->instruction |= opcode;
    instr->instruction |= (rd << 7);
    instr->instruction |= (funct3 << (7 + 5));
    instr->instruction |= (rs_1 << (7 + 5 + 3));
    instr->instruction |= (rs_2 << (7 + 5 + 3 + 5));
    instr->instruction |= (funct7 << (7 + 5 + 3 + 5 + 5));
}

// FIXME: parse and assemble I-type instruction
void parse_I_type(char *opr, instruction_t *instr)
{
    instr->instruction = 0;
    unsigned opcode = 0;
    unsigned funct3 = 0;

    if (strcmp(opr, "addi") == 0)
    {
        opcode = 19;
        funct3 = 7;
    }
    if (strcmp(opr, "slli") == 0)
    {
        opcode = 19;
        funct3 = 1;
    }
    if (strcmp(opr, "ld") == 0)
    {
        opcode = 3;
        funct3 = 3;
    }

    char *reg = strtok(NULL, ", ");
    unsigned rd = get_register_number(reg);

    unsigned rs_1 = 0;
    if (strcmp(opr, "ld"))
    {
        reg = strtok(NULL, ", ");
        rs_1 = get_register_number(reg);
    }
    else
    {
        reg = strtok(NULL, ", ");
        char *base = strtok(reg, "(");
        unsigned base_int = atoi(base);
        reg = strtok(NULL, ")");
        // reg[strlen(reg)-1] = '\0';
        rs_1 = get_register_number(reg);
        rs_1 = rs_1 + base_int;
    }

    unsigned imm = 0;
    if (strcmp(opr, "ld"))
    {
        reg = strtok(NULL, ", ");
        reg[strlen(reg) - 1] = '\0';
        imm = atoi(reg);
    }

    // Print the tokens
    //printf("Opcode: %u\n", opcode);
    //printf("funct3: %u\n", funct3);
    //printf("Source register 1: %u\n", rs_1);
    //printf("Immediate register : %u\n", imm);
    //printf("Destination register: %u\n\n", rd);

    // Contruct instruction
    instr->instruction |= opcode;
    instr->instruction |= (rd << 7);
    instr->instruction |= (funct3 << (7 + 5));
    instr->instruction |= (rs_1 << (7 + 5 + 3));
    instr->instruction |= (imm << (7 + 5 + 3 + 5));
}

// FIXME: parse and assemble SB-type instruction
void parse_SB_type(char *opr, instruction_t *instr)
{
    instr->instruction = 0;
    unsigned opcode = 0;
    unsigned funct3 = 0;
    int imm = 0;

    if (strcmp(opr, "bne") == 0)
    {
        opcode = 99;
        funct3 = 1;
    }
    if (strcmp(opr, "beq") == 0)
    {
        opcode = 99;
        funct3 = 0;
    }

    char *reg = strtok(NULL, ", ");

    unsigned rs_1 = get_register_number(reg);

    reg = strtok(NULL, ", ");
    //reg[strlen(reg) - 1] = '\0';
    unsigned rs_2 = get_register_number(reg);

    reg = strtok(NULL, ", ");
    reg[strlen(reg)] = '\0';
    imm = atoi(reg);

    // Print the tokens
    //printf("Opcode: %u\n", opcode);
    //printf("funct3: %u\n", funct3);
    //printf("imm: 0x%X\n", imm);
    //printf("Source register 1: %u\n", rs_1);
    //printf("Source register 2: %u\n", rs_2);

    // Make sure imm is shifted left by 1 (RISC-V uses bit[0] as 0 implicitly)
    //imm = imm >> 1; // OR: imm >>= 1;
    
    // Extract and insert immediate bits into the correct positions
    unsigned imm_11 = (imm >> 11) & 0x1;      // imm[11] -> bit 7
    unsigned imm_4_1 = (imm >> 1) & 0xF;      // imm[4:1] -> bits 11-8
    unsigned imm_10_5 = (imm >> 5) & 0x3F;    // imm[10:5] -> bits 30-25
    unsigned imm_12 = (imm >> 12) & 0x1;      // imm[12] -> bit 31
    
    instr->instruction |= (opcode & 0x7F);             // bits [6:0]
    instr->instruction |= (imm_11 << 7);               // bit 7
    instr->instruction |= ((funct3 & 0x7) << 12);      // bits [14:12]
    instr->instruction |= ((rs_1 & 0x1F) << 15);       // bits [19:15]
    instr->instruction |= ((rs_2 & 0x1F) << 20);       // bits [24:20]
    instr->instruction |= ((imm_10_5 & 0x3F) << 25);   // bits [30:25]
    instr->instruction |= (imm_12 << 31);              // bit 31
    instr->instruction |= ((imm_4_1 & 0xF) << 8);      // bits [11:8]
}

unsigned int get_register_number(char *reg)
{
    unsigned i = 0;

    for (i; i < NUM_OF_REGS; i++)
    {
        if (strcmp(REGISTER_NAME[i], reg) == 0)
            break;
    }

    return i;
}