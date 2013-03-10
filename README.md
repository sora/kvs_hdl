## CPU-less KVS

**Spec**

- KVS protocol
    * Memcache Binary Protocol
- Transport protocol
    * UDP
    * port: 11211
- Key length
    * variable length
- Value size
    * 32 byte
- Storage type
    * Dual-Port BRAM
    * 131,072 byte
- Commands
    * Set and Get

------------------------

**Source files**

Verilog2001で記述

- top.v
    * topモジュール．memcachebinaryprotocolを解釈
- lookup.v
    * set/getを発行
- memory.v
    * データの保存場所
- crc.v
    * 今回はhashkeyの生成にCRC32を利用

------------------------

** Block diagram**

![ブロックダイアグラム](https://raw.github.com/sora/ethernet-2013/master/fig/kvs_block_diagram.png?login=sora&token=99c98daccccdc0989f68b9de3aa6d5f6)

------------------------

**DC_RAM_TRUE**

![]()

------------------------

**メモリアドレス設計**

![]()

------------------------

**Valueの構造**

![]()

------------------------

**Reply送信タイミング**

![内部遅延](https://raw.github.com/sora/ethernet-2013/master/fig/kvs_logic_delay.png?login=sora&token=aaef10cb63989633ca84420436081f7e)

今回の設計では，できるだけ内部ロジックの遅延を低くするために，Requestパケットを受信し終える前にReplayパケットを送信し始めています．
具体的には，RequestパケットのMemcachedヘッダのMagic Fieldを受信した次のクロックから，応答メッセージ送信を開始しています．
これだけ遅延を切り詰めた設計でも，100GE ワイヤーレートを実現することは難しいです．ここらへんの遅延の考え方は，10G事始めで少しだけ触れたいと思います．


