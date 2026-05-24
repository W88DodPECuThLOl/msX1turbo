#ifndef INCL_sos_printf__h
#define INCL_sos_printf__h

#define SOS_PRINTF_BUFFER_SIZE (128)

/**
 * @brief 書式付きの文字列表示
 * @param format 書式
 * @note 最大文字列はSOS_PRINTF_BUFFER_SIZEまで
 */
void sos_printf(const char *format, ...);

#endif // INCL_sos_printf__h
