// 指纹或面容ID（生物特征识别）
import { userAuth } from '@kit.UserAuthenticationKit'

class UserAuthManager {
  // 认证信任等级，等级越高，面容指纹检测时越严格
  authTrustLevel: userAuth.AuthTrustLevel = userAuth.AuthTrustLevel.ATL3
  // 认证类型列表
  authTypes: userAuth.UserAuthType[] = [
    userAuth.UserAuthType.PIN, // 锁屏密码
    userAuth.UserAuthType.FACE, // 面容
    userAuth.UserAuthType.FINGERPRINT,// 指纹
  ]

  // 查询认证能力是否支持，有一项支持即可
  checkUserAuthSupport() {
    // 遍历认证类型列表
    const res = this.authTypes.map((item) => {
      try {
        // 检测是否可用
        userAuth.getAvailableStatus(item, this.authTrustLevel)
        return true
      } catch {
        return false
      }
    })
    // some    条件中有一项为 true，结果就返回 true
    // every   条件中所有项为 true，结果才返回 true
    // 有一项支持即可
    return res.some(v => v === true)
  }
}

export const userAuthManager = new UserAuthManager()