import { deviceInfo } from '@kit.BasicServicesKit'

export function isEmulator() {
  return deviceInfo.marketName === 'emulator'
}