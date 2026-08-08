# Ver. 0.0.6

## BIOS
* CALPATを実装
* CALATRを実装
* GSPSIZを実装
* DISSCRを実装
* ENASCRを実装
* OLDKEYを初期化するように
* NEWKEYを初期化するように

## その他
* 「OUT (0x98),A」命令をフックするように
* 「IN A,(0x99)」命令をフックするように
* 「OUT (0x99),A」命令をフックするように
* 「OUT (0xA0),A」命令をフックするように
* 「OUT (0xA1),A」命令をフックするように
* 「IN (0xA2),A」命令をフックするように
* 「IN (0xA9),A」命令をフックするように
* 「OUT (0xAA),A」命令をフックするように

# Ver. 0.0.5
* 32KiB以上のROMに対応
* ファイル選択機能を実装
* ips形式のパッチに対応

# Ver. 0.0.4

## BIOS
* INIT32を実装

# Ver. 0.0.3

## BIOS
* SETWRTでHLレジスタを破壊していたのを修正
* RDPSGでジョイスティック2の入力が出来ていなかった不具合を修正

## VDP
* スプライト描画を高速化

# Ver. 0.0.2

## BIOS
* GICINIを実装
* WRTPSGとRDPSGを修正しジョイスティックが正常に読み込めるように
* LDIRMVを実装
* DISSCRとENASCRのダミーを追加

## VDP
* Graphic2の768個のパターン定義に対応

## その他
* 「OUT (0x98),A」命令をフックするように

# Ver. 0.0.1
* 初期リリース
