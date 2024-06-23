import axios from '@ohos/axios'
import { BASE_URL } from '../../common/constants'
import { promptAction } from '@kit.ArkUI';

/** 账号密码登录模型 */
export interface PostUserLoginPasswdData {
  /** 用户密码 */
  passwd?: string;

  /** 用户手机号 */
  phone?: string;
}

@Entry
@Component
struct AxiosTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('范型参数-约束 post 请求参数')
            .onClick(async () => {
              // 第三个范型参数： 约束 post 请求参数的类型 - 重点
              await axios.post<null, null, PostUserLoginPasswdData>(BASE_URL + '/user/login/passwd',
                {
                  phone: '120666666666',
                  passwd: '888itcast.CN764%...'
                }
              )
              promptAction.showToast({ message: '登录请求发送成功' })
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('axios进阶用法')
    .titleMode(NavigationTitleMode.Mini)
  }
}