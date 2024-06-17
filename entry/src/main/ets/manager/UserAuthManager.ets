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
  // 设置认证参数
  private authParam: userAuth.AuthParam = {
    challenge: new Uint8Array([49, 49, 49, 49, 49, 49]), // 挑战值，用来防重放攻击。
    authType: this.authTypes, // 认证类型列表
    authTrustLevel: this.authTrustLevel, // 认证信任等级
  }
  // 配置认证界面
  private widgetParam: userAuth.WidgetParam = {
    title: '请进行身份认证', // 用户认证界面的标题, 仅在 PIN/指纹 密码时展示
  }

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

  // 发起原生用户认证
  startUserAuth(): Promise<boolean> {
    // 返回 Promise 对象，在认证结束后决定返回 resolve 成功，还是 reject 失败
    return new Promise((resolve, reject) => {
      // 1. 获取认证对象
      const userAuthInstance = userAuth.getUserAuthInstance(this.authParam, this.widgetParam)
      // 2. 订阅认证结果
      userAuthInstance.on('result', {
        // 认证结束会触发 onResult 获取认证结果
        onResult(result) {
          // 如果认证结果为 12500000 表示 SUCCESS 成功
          if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
            // 标记为成功 resolve
            resolve(true)
          } else {
            // 标记为失败 reject
            reject(false)
          }
          // 认证结束后，主动关闭订阅，释放资源
          userAuthInstance.off('result')
        }
      })
      // 3. 开始认证
      userAuthInstance.start()
    })
  }
}

export const userAuthManager = new UserAuthManager()