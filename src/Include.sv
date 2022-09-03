
typedef enum logic[5:0]
{
    INT_ADD,
    INT_XOR,
    INT_OR,
    INT_AND,
    INT_SLL,
    INT_SRL,
    INT_SLT,
    INT_SLTU,
    INT_SUB,
    INT_SRA,
    INT_BEQ,
    INT_BNE,
    INT_BLT,
    INT_BGE,
    INT_BLTU,
    INT_BGEU,
    INT_LUI,
    INT_AUIPC,
    INT_JAL,
    INT_JALR,
    INT_SYS,
    INT_UNDEFINED
} OPCode_INT;

typedef enum logic[5:0]
{
    MUL_MUL,
    MUL_MULH,
    MUL_MULSU,
    MUL_MULU
} OPCode_MUL;

typedef enum logic[5:0]
{
    DIV_DIV,
    DIV_DIVU,
    DIV_REM,
    DIV_REMU
} OPCode_DIV;

typedef enum logic[5:0]
{
    LSU_LB, 
    LSU_LH, 
    LSU_LW, 
    LSU_LBU,
    LSU_LHU,
    LSU_SB,
    LSU_SH,
    LSU_SW
} OPCode_LSU;

typedef enum logic[1:0] {FU_INT, FU_LSU, FU_MUL, FU_DIV} FuncUnit;
typedef enum logic[0:0] {FLAGS_NONE, FLAGS_BRK} Flags;

typedef struct packed
{
    logic[31:0] imm;
    logic[31:0] pc;
    logic[4:0] rs0; 
    logic[4:0] rs1;
    logic pcA;
    // only useful when we otherwise need a duplicate opcode -> maybe rework some things
    logic immB;
    logic[4:0] rd;
    logic[5:0] opcode;
    FuncUnit fu;
    logic[5:0] branchID;
    logic branchPred;
    logic valid;
} D_UOp;

typedef struct packed
{
    logic[31:0] imm;
    logic[31:0] pc;
    // TODO: Keep some tags always reserved, use as special values for pc, imm, ...
    logic availA;
    logic[5:0] tagA;
    logic availB;
    logic[5:0] tagB;
    logic pcA;
    logic immB;
    logic[5:0] sqN;
    logic[5:0] tagDst;
    logic[4:0] nmDst;
    logic[5:0] opcode;
    logic[5:0] branchID;
    logic branchPred;
    logic[5:0] storeSqN;
    logic[5:0] loadSqN;
    FuncUnit fu;
} R_UOp;


typedef struct packed
{
    logic[31:0] imm;
    logic[31:0] srcA;
    logic availA;
    logic[5:0] tagA;
    logic[31:0] srcB;
    logic availB;
    logic[5:0] tagB;
    logic[5:0] sqN;
    logic[5:0] tagDst;
    logic[4:0] nmDst;
    logic[5:0] opcode;
    logic valid;
} UOp;

typedef struct packed
{
    logic[31:0] srcA;
    logic[31:0] srcB;
    logic zcFwdSrcA;
    logic zcFwdSrcB;
    logic[31:0] pc;
    logic[31:0] imm;
    logic[5:0] opcode;
    logic[5:0] tagDst;
    logic[4:0] nmDst;
    logic[5:0] sqN;
    logic[5:0] branchID;
    logic branchPred;
    logic[5:0] storeSqN;
    logic[5:0] loadSqN;
    logic valid;
} EX_UOp;

typedef struct packed
{
    bit[31:0] result;
    bit[5:0] tagDst;
    bit[4:0] nmDst;
    bit[5:0] sqN;
} RES_UOp;


typedef struct packed
{
    bit taken;
    bit[31:0] dstPC;
    bit[5:0] sqN;
    bit[5:0] storeSqN;
    bit[5:0] loadSqN;
    
} BranchProv;
