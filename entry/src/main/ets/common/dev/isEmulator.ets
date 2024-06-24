import { deviceInfo } from '@kit.BasicServicesKit'

/**
 * 判断当前设备是否为模拟器
 * @returns
 */
export function isEmulator() {
  return deviceInfo.marketName === 'emulator'
}

/**
 * 判断当前设备是否不为模拟器
 * @returns
 */
export function isNotEmulator() {
  return deviceInfo.marketName !== 'emulator'
}