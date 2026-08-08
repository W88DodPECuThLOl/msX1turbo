SYSTEM_STACK    .equ    0x4000 ; システム用のスタックアドレス

; VDP PORT
VDP_DR .equ 0xC6 ; 読み込み
VDP_WR .equ 0xC8 ; 書き込み

; MSX WORK
LINL40 .equ 0xF3AE ; 1バイト 初期値 40      Screen 0の時の１行の幅。Screen 0の時のWidth文で設定する。
LINL32 .equ 0xF3AF ; 1バイト 初期値 40      Screen 1の時の１行の幅。Screen 1の時のWidth文で設定する。
LINLEN .equ 0xF3B0 ; 1バイト 初期値 29      現在の画面の１行の幅。
CRTCNT .equ 0xF3B1 ; 1バイト 初期値 24      現在の画面の行数
CLMLST .equ 0xF3B2 ; 1バイト 初期値 14      PRINT文の制御に使用、LINLEN-(LINLEN MOD 14)-14
T32NAM .equ 0xF3BD ; 2バイト 初期値 0x1800  パターンネームテーブルのアドレス
T32COL .equ 0xF3BF ; 2バイト 初期値 0x2000  カラーテーブルのアドレス
T32CGP .equ 0xF3C1 ; 2バイト 初期値 0x0000  パターンジェネレータテーブルのアドレス
T32ATR .equ 0xF3C3 ; 2バイト 初期値 0x1B00  スプライトアトリビュートテーブルのアドレス
T32PAT .equ 0xF3C5 ; 2バイト 初期値 0x3800  スプライトジェネレータテーブルのアドレス
CLIKSW .equ 0xF3DB ; 1バイト 初期値 0xFF    キークリックスイッチ（0 = OFF、NZ = ON）
CSRY   .equ 0xF3DC ; 1バイト               カーソルのY座標
CSRX   .equ 0xF3DD ; 1バイト               カーソルのX座標
CNSDFG .equ 0xF3DE ; 1バイト 初期値 0xFF    ファンクションキー表示スイッチ（0 = 非表示、NZ = 表示）

RG0SAV .equ 0xF3DF ; 1バイト VDPレジスタ0の保存場所
RG1SAV .equ 0xF3E0 ; 1バイト VDPレジスタ1の保存場所
RG2SAV .equ 0xF3E1 ; 1バイト VDPレジスタ2の保存場所
RG3SAV .equ 0xF3E2 ; 1バイト VDPレジスタ3の保存場所
RG4SAV .equ 0xF3E3 ; 1バイト VDPレジスタ4の保存場所
RG5SAV .equ 0xF3E4 ; 1バイト VDPレジスタ5の保存場所
RG6SAV .equ 0xF3E5 ; 1バイト VDPレジスタ6の保存場所
RG7SAV .equ 0xF3E6 ; 1バイト VDPレジスタ7の保存場所
STATFL .equ 0xF3E7 ; 1バイト VDPのSTATUS(MSX2、MSX2+ではSTATUSレジスタ0の値)
TRGFLG .equ 0xF3E8 ; 1バイト ジョイスティックのトリガボタンの状態
FORCLR .equ 0xF3E9 ; 1バイト 前景色（フォアグラウンドカラー）省略値
BAKCLR .equ 0xF3EA ; 1バイト 背景色（バックグラウンドカラー）省略値
BDRCLR .equ 0xF3EB ; 1バイト 周辺色（ボーダーカラー）省略値
MAXUPD .equ 0xF3EC ; 3バイト LINE文が内部で使用（C3H、00H、00H）
MINUPD .equ 0xF3EF ; 3バイト LINE文が内部で使用（C3H、00H、00H）
ATRBYT .equ 0xF3F2 ; 1バイト グラフィック使用時の色、アトリビュートバイト
QUEUES .equ 0xF3F3 ; 2バイト PLAY文実行時のキューテーブルを指す
FRCNEW .equ 0xF3F5 ; 1バイト インタープリタが内部で使用
SCNCNT .equ 0xF3F6 ; 1バイト キースキャンの時間間隔
REPCNT .equ 0xF3F7 ; 1バイト キーのオートリピート開始までの時間間隔
PUTPNT .equ 0xF3F8 ; 2バイト キーバッファへの書き込みを行う番地を指す
GETPNT .equ 0xF3FA ; 2バイト キーバッファからの読み込みを行う番地を指す

GRPNAM .equ 0xF3C7 ; 2バイト パターンネームテーブルの先頭アドレス
GRPCOL .equ 0xF3C9 ; 2バイト カラーテーブルの先頭アドレス
GRPCGP .equ 0xF3CB ; 2バイト パターンジェネレータテーブルの先頭アドレス
GRPATR .equ 0xF3CD ; 2バイト スプライトアトリビュートテーブルの先頭アドレス
GRPPAT .equ 0xF3CF ; 2バイト スプライトジェネレータテーブルの先頭アドレス

NAMBAS .equ 0xF922 ; 2バイト 現在表示に使用されているパターンネームテーブルの先頭アドレス
CGPBAS .equ 0xF924 ; 2バイト 現在のパターンジェネレータテーブルのベースアドレス
PATBAS .equ 0xF926 ; 2バイト 現在のスプライトジェネレータテーブルのベースアドレス
ATRBAS .equ 0xF928 ; 2バイト 現在のスプライトアトリビュートテーブルのベースアドレス

CLIKFL .equ 0xFBD9 ; 1バイト キークリックフラグ
OLDKEY .equ 0xFBDA ; 11バイト 旧キーの状態
NEWKEY .equ 0xFBE5 ; 11バイト 新キーの状態
KEYBUF .equ 0xFBF0 ; 40バイト キーコードバッファ
BUFEND .equ 0xFC18 ;         KEYBUFの終り

JIFFY  .equ 0xFC9E ; 2バイト PLAY文が内部で使用。BASICのシステム変数TIMEと同じ値を返す
INTVAL .equ 0xFCA0 ; 2バイト インターバルの間隔。ON INTERVAL GOSUB文により設定される
INTCNT .equ 0xFCA2 ; 2バイト インターバルのためのカウンタ
SCRMOD .equ 0xFCAF ; 1バイト 現在のスクリーンモードの番号
OLDSCR .equ 0xFCB0 ; 1バイト スクリーンモード保存エリア

H_KEYI .equ 0xFD9A ; 5バイト HOOK H.KEYI 割り込み処理の始め、RS-232Cなど
H_TIMI .equ 0xFD9F ; 5バイト HOOK H.TIMI タイマー割り込み処理の追加
