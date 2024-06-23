import axios, { AxiosResponse } from '@ohos/axios'
import { BASE_URL } from '../../common/constants'
import { promptAction } from '@kit.ArkUI';

// 温馨提示：网络请求接口的类型，可通过 Apifox 工具生成 CV 过来
/** 账号密码登录模型 */
export interface PostUserLoginPasswdData {
  /** 用户密码 */
  passwd?: string;

  /** 用户手机号 */
  phone?: string;
}

/** 后端数据响应模型<R> */
export interface ServiceResponse<R> {
  code: number;
  msg?: string;
  resTime?: Date;
  result?: R;
  tips?: string;
}

/** 登录 Result */
export interface Result {
  accessToken?: string;
  avatar?: string;
  nickname?: string;
  renewalToken?: string;
}

@Entry
@Component
struct AxiosTestPage {
  // 定义头像数据
  @State avatar: string = ''

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('范型参数-约束 post 请求参数')
            .onClick(async () => {
              /**
               *  axios 范型参数：
               *     第二个范型参数： 约束后端返回数据的类型 - 重点学习
               *     第三个范型参数： 约束请求体(data)参数的类型 - 重点学习
               */
              const res =
                await axios.post<null, AxiosResponse<ServiceResponse<Result>, null>, PostUserLoginPasswdData>(
                  BASE_URL + '/user/login/passwd',
                  {
                    phone: '120666666666',
                    passwd: '888itcast.CN764%...'
                  }
                )
              // promptAction.showToast({ message: '登录请求发送成功' })
              // AlertDialog.show({ message: JSON.stringify(res, null, 2) })
              if (res.data.code === 200) {
                // 保存头像
                this.avatar = res.data.result?.avatar as string
              } else {
                // 显示后端错误信息
                promptAction.showToast({ message: res.data.msg })
              }
            })
          Image(this.avatar)
            .width(200)
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