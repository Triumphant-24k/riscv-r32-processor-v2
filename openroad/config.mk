export DESIGN_NICKNAME = educational_rv32i
export DESIGN_NAME     = cpu_core
export PLATFORM        = sky130hd

PROJECT_HOME := $(abspath $(dir $(DESIGN_CONFIG))/..)

export VERILOG_FILES = \
    $(PROJECT_HOME)/rtl/alu.v \
    $(PROJECT_HOME)/rtl/branch_unit.v \
    $(PROJECT_HOME)/rtl/control_unit.v \
    $(PROJECT_HOME)/rtl/cpu_core.v \
    $(PROJECT_HOME)/rtl/immediate_generator.v \
    $(PROJECT_HOME)/rtl/load_store_unit.v \
    $(PROJECT_HOME)/rtl/register_file.v

export SDC_FILE = $(PROJECT_HOME)/openroad/constraint.sdc

export CORE_UTILIZATION = 35
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN = 2
export PLACE_DENSITY_LB_ADDON = 0.10
