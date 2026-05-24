# msX1turbo
Sharp X1turboでMSXを動かしてみる試み

# ビルド方法

## 必要な物
* SDCC
* AILZ80ASM
* HuDisk
* SWXCV110.d88

## 手順
1. SDCC、AILZ80ASM、HuDiskにパスを通しておきます。
1. SWXCV110.d88をresにコピーします。  
無くても大丈夫ですが、あると起動できるd88イメージを作成します。  
便利です。
1. make.batを実行します。
1. msX1turbo.d88が作成されます。

以上

# ご使用方法

1. S-OSを起動します。
2. 16KiB以下のMSX用のROMイメージを0x4000から読み込みます。
3. msX1turbo.BINを読み込み、実行します。
4. 動かなければ潔く諦めましょう！
