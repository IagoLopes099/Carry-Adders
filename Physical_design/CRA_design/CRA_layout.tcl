# 1. Ler bibliotecas físicas e de timing
read_lef /home/iago/Documentos/HDL/libs_cells/NanGate_45nm_OCL_v2010_12/NanGate_45nm_OCL_v2010_12/pdk_v1.3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.tech.lef
read_lef /home/iago/Documentos/HDL/libs_cells/NanGate_45nm_OCL_v2010_12/NanGate_45nm_OCL_v2010_12/pdk_v1.3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.lef
read_liberty /home/iago/Documentos/HDL/libs_cells/NanGate_45nm_OCL_v2010_12/NanGate_45nm_OCL_v2010_12/pdk_v1.3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/NangateOpenCellLibrary_PDKv1_3_v2010_12/Front_End/Liberty/NLDM/NangateOpenCellLibrary_typical.lib

# 2. Ler o netlist já sintetizado (o que o Yosys gerou)
read_verilog carry_ripple_adder_synth_45nm.v
link_design carry_ripple_adder

# 3. Ler as restrições de timing (você precisa criar um .sdc básico)
read_sdc constraints.sdc

# 4. Floorplan — define a área do chip
initialize_floorplan -utilization 40 -aspect_ratio 1.0 -core_space 2 -site FreePDK45_38x28_10R_NP_162NW_34O

make_tracks metal2 -x_offset 0.07 -x_pitch 0.14 -y_offset 0.095 -y_pitch 0.19

# 4.5 Posicionar os pinos de I/O nas bordas do chip
place_pins -hor_layers metal3 -ver_layers metal2

# 5. Placement (posicionar as células)
global_placement
detailed_placement

# 6. Clock Tree Synthesis (mesmo sendo combinacional, pode pular se não houver clock)
# clock_tree_synthesis ...

# 7. Roteamento
global_route
detailed_route

# 8. Escrever o resultado final
write_def carry_ripple_adder_final.def
write_gds carry_ripple_adder_final.gds