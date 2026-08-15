    .z80
    .module main
    .area _CODE
    .allow_undocumented

.include /setting.inc/
.include /msx1BiosDef.inc/
.include /nekoSys.inc/
.include /msX1turboMain.inc/
.include /msx1Bios.inc/
.include /msx1BiosPsg.inc/
.include /x1Scc.inc/
.include /msx1BiosVdp.inc/

_main:
    DI
    ; モジュールをVRAMからメモリへ
    LD BC,#0x4000
    LD DE,#0x2000
    LD HL,#0xC000
main_LOOP:
        IN A,(C)
        LD (HL),A
        INC BC
        INC HL
    DEC DE
    LD A,D
    OR E
    JR NZ,main_LOOP

    ; 初期化
    CALL x1_psgReset
    CALL _INITIALIZE
    CALL _vdpInit
.ifdef ENABLE_SCC
    CALL initSCC
.endif
    CALL _CTC_SETUP
    ; 実行
    LD BC,#0x0101
    LD HL,(ROM_ADDRESS + 2)
    JP (HL)
