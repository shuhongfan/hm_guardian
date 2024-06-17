import CryptoJS from '@ohos/crypto-js'

// MD5 加密函数
export function encryptMD5(str: string) {
  // 计算MD5摘要，将MD5摘要转换为加密后的字符串
  return CryptoJS.MD5(str)
    .toString()
}