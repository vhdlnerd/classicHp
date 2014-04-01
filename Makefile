PROJECT=classichp
TOP=$(PROJECT)_top
PART=xc3s250e-4-vq100
CALC=HP55
UART=TX_RX

BASE=${PROJECT}_${CALC}

SRCS_WORK_DIR = src/
SRCS_WORK = uart_tx.vhd uart_rx.vhd \
            utils.vhd bcd_alu_lut_pack.vhd rom_pack.vhd \
            ps2_keyboard_pack.vhd interface_ps2.vhd bcd_alu.vhd \
            tm16xxFonts.vhd sys_dcm.vhd ps2_keyboard.vhd classic_pack.vhd \
            classic.vhd classicHp_top.vhd

SRCS = $(foreach F,$(SRCS_WORK),$(SRCS_WORK_DIR)$(F))

bit   : ${BASE}.bit

syn   : ${BASE}.ngc

translate : ${BASE}.ngd

map : ${BASE}.ncd

par : ${BASE}_routed.ncd

$(PROJECT).prj : $(SRC)
	@echo $(SRCS) | sed -r 's/[ \t]+/\n/g' | sed 's/.*/vhdl work &/' > $(PROJECT).prj
	
${BASE}.xst :
	@cp -f ${PROJECT}.xst ${BASE}.xst
	@echo "-generics \"CALC_NAME=${CALC}, UART_TYPE=${UART}\"" >> ${BASE}.xst
	@echo "-ofn ${BASE}" >> ${BASE}.xst
	
${BASE}.ngc: $(PROJECT).prj $(SRCS) ${BASE}.xst
	@echo "Building for ${CALC} (UART=${UART})."
	mkdir -p xst/projnav.tmp/
	xst -intstyle silent -ifn ${BASE}.xst -ofn ${BASE}.syr

${BASE}.ngd: ${BASE}.ngc ${PROJECT}.ucf
	ngdbuild -intstyle ise -dd _ngo -nt timestamp \
	-uc ${PROJECT}.ucf -p ${PART} ${BASE}.ngc ${BASE}.ngd

${BASE}.ncd: ${BASE}.ngd
	map -intstyle ise -p ${PART} \
	 -t 42 -detail -ir off -ignore_keep_hierarchy -pr b -timing -ol high -logic_opt on  \
	-o ${BASE}.ncd ${BASE}.ngd ${BASE}.pcf 

${BASE}_routed.ncd: ${BASE}.ncd
	par -t 42 -w -intstyle ise -ol high ${BASE}.ncd ${BASE}_routed.ncd ${BASE}.pcf

${BASE}.bit: ${BASE}_routed.ncd
	bitgen -f ${PROJECT}.ut ${BASE}_routed.ncd
	mv -f ${BASE}_routed.bit ${BASE}.bit

clean:
	@rm -rf ${PROJECT}*.{prj,ngc,ngd,ncd,pcf,mrp,par}
	@rm -rf ${PROJECT}*_routed*.*
	@rm -rf ${PROJECT}_HP*.xst

realclean: clean
	rm -rf ${PROJECT}*.bit
