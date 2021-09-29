import re

'''
input file example
module exu_branchslv (
    input cmt_i_valid,
    output cmt_i_ready,
    input cmt_i_bjp,
    input cmt_i_bjp_prdt, //predicted branch taken or not
    input cmt_i_bjp_rslv,//the resolved true/false
    input [`PC_SIZE-1:0] cmt_i_pc,
    input [`XLEN-1:0] cmt_i_imm,

    input brchmis_flush_ack,//from ifu, always ready to accept flush
    output brchmis_flush_req,
    output [`PC_SIZE-1:0] brchmis_flush_add_op1,
    output [`PC_SIZE-1:0] brchmis_flush_add_op2
);
'''
def auto_wire(f_path):
    output_list = []
    f = open(f_path, "r")
    first_line = f.readline()
    module_name = re.split("[ (]", first_line)[1]
    output_list.append('{} u_{} ('.format(module_name, module_name))
    for line in f.readlines():
        if line.find("t") == -1: continue
        if line.find(';') != -1: break
        line = line.split(",", 1)[0]
        port_name = line.split()[-1]
        output_list.append('\t.{}({}),'.format(port_name, port_name))
    output_list[-1] = output_list[-1].rstrip(',')
    output_list.append('\t);')
    
    return '\n'.join(output_list)

if __name__ == "__main__":
    f_path = "module_def.txt"
    print(auto_wire(f_path))