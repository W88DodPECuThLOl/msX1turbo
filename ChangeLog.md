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
