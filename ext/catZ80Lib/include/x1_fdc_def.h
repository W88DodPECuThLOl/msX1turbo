#ifndef INCL_x1_fdc_def__h
#define INCL_x1_fdc_def__h

/**
 * @brief FDCのコントロールレジスタのポートアドレス
 */
#define FDC_PORT_CR  (0x0FF8)

/**
 * @brief FDCのステータスレジスタのポートアドレス
 */
 #define FDC_PORT_STR (0x0FF8)

/**
 * @brief FDCのトラックスレジスタのポートアドレス
 */
#define FDC_PORT_TR  (0x0FF9)

/**
 * @brief FDCのセクタレジスタのポートアドレス
 */
#define FDC_PORT_SCR (0x0FFA)

/**
 * @brief FDCのデータスレジスタのポートアドレス
 */
#define FDC_PORT_DR  (0x0FFB)

/**
 * @brief FDCのドライブ指定、ドライブ電源、サイド設定のポートアドレス
 */
#define FDC_PORT_DSM (0x0FFC)


/**
 * @brief FDCのリストアコマンド(TYPE I)
 */
#define FDC_COMMAND_RESTORE (0x02)

/**
 * @brief FDCのシークコマンド(TYPE I)
 */
#define FDC_COMMAND_SEEK (0x1E)

/**
 * @brief FDCのステップコマンド(TYPE I)
 */
#define FDC_COMMAND_STEP (0x3A)

/**
 * @brief FDCのステップインコマンド(TYPE I)
 */
#define FDC_COMMAND_STEP_IN (0x5A)

/**
 * @brief FDCのステップアウトコマンド(TYPE I)
 */
#define FDC_COMMAND_STEP_OUT (0x7A)

/**
 * @brief FDCのデータリードコマンド(TYPE II)
 */
#define FDC_COMMAND_READ_DATA (0x80)


// TYPE Iのステータス
#define FDC_STATUS_TYPE1_NOT_READY        (1 << 7)
#define FDC_STATUS_TYPE1_WRITE_PROTECT    (1 << 6)
#define FDC_STATUS_TYPE1_HEAD_ENGAGED     (1 << 5)
#define FDC_STATUS_TYPE1_SEEK_ERROR       (1 << 4)
#define FDC_STATUS_TYPE1_CRC_ERROR        (1 << 3)
#define FDC_STATUS_TYPE1_TRACK_00         (1 << 2)
#define FDC_STATUS_TYPE1_INDEX            (1 << 1)
#define FDC_STATUS_TYPE1_BUSY             (1     )


// TYPE II/IIIのステータス
#define FDC_STATUS_TYPE23_NOT_READY        (1 << 7)
#define FDC_STATUS_TYPE23_WRITE_PROTECT    (1 << 6)
#define FDC_STATUS_TYPE23_RECORD_TYPE      (1 << 5)
#define FDC_STATUS_TYPE23_WRITE_FAIL       (1 << 5)
#define FDC_STATUS_TYPE23_RECORD_NOT_FOUND (1 << 4)
#define FDC_STATUS_TYPE23_CRC_ERROR        (1 << 3)
#define FDC_STATUS_TYPE23_LOST_DATA        (1 << 2)
#define FDC_STATUS_TYPE23_DATA_REQUEST     (1 << 1)
#define FDC_STATUS_TYPE23_BUSY             (1     )

#endif // INCL_x1_fdc_def__h
